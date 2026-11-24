
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const encoder = new TextEncoder();

type NotificationRow = {
  id: string;
  user_id: string;
  type: string;
  title: string;
  message: string;
  data?: Record<string, unknown>;
};

type NotificationPreferences = {
  push_notifications: boolean;
  job_updates: boolean;
  messages: boolean;
  reminders: boolean;
  offers_and_promotions: boolean;
  app_announcements: boolean;
};

function base64Url(bytes: Uint8Array): string {
  let binary = "";

  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function getPreferenceKey(
  type: string,
): keyof Omit<NotificationPreferences, "push_notifications"> | null {
  const normalized = type.toLowerCase();

  if (
    normalized.startsWith("job_") ||
    normalized.startsWith("invitation_") ||
    normalized.startsWith("worker_")
  ) {
    return "job_updates";
  }

  if (
    normalized === "message" ||
    normalized.startsWith("message_") ||
    normalized === "new_message"
  ) {
    return "messages";
  }

  if (
    normalized === "reminder" ||
    normalized.startsWith("reminder_")
  ) {
    return "reminders";
  }

  if (
    normalized === "offer" ||
    normalized.startsWith("offer_") ||
    normalized === "promotion" ||
    normalized.startsWith("promotion_")
  ) {
    return "offers_and_promotions";
  }

  if (
    normalized === "announcement" ||
    normalized.startsWith("announcement_") ||
    normalized === "app_announcement" ||
    normalized.startsWith("app_announcement_")
  ) {
    return "app_announcements";
  }

  return null;
}

async function firebaseAccessToken(): Promise<string> {
  const email = Deno.env.get("FIREBASE_CLIENT_EMAIL");
  const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
  const privateKey = Deno.env.get("FIREBASE_PRIVATE_KEY");

  if (!email || !projectId || !privateKey) {
    throw new Error("Firebase service account configuration is missing");
  }

  const pem = privateKey.replace(/\\n/g, "\n");

  const keyContent = pem.replace(
    /-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\s/g,
    "",
  );

  const keyBytes = Uint8Array.from(
    atob(keyContent),
    (character) => character.charCodeAt(0),
  );

  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );

  const now = Math.floor(Date.now() / 1000);

  const header = base64Url(
    encoder.encode(
      JSON.stringify({
        alg: "RS256",
        typ: "JWT",
      }),
    ),
  );

  const payload = base64Url(
    encoder.encode(
      JSON.stringify({
        iss: email,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
      }),
    ),
  );

  const unsignedToken = `${header}.${payload}`;

  const signature = new Uint8Array(
    await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      key,
      encoder.encode(unsignedToken),
    ),
  );

  const jwt = `${unsignedToken}.${base64Url(signature)}`;

  const response = await fetch(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: {
        "content-type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt,
      }),
    },
  );

  if (!response.ok) {
    const errorBody = await response.text();

    throw new Error(
      `Firebase OAuth failed (${response.status}): ${errorBody}`,
    );
  }

  const result = await response.json();

  if (!result.access_token) {
    throw new Error("Firebase OAuth response did not contain an access token");
  }

  return result.access_token as string;
}

function getDefaultPreferences(): NotificationPreferences {
  return {
    push_notifications: true,
    job_updates: true,
    messages: true,
    reminders: true,
    offers_and_promotions: false,
    app_announcements: true,
  };
}

function isPreferenceEnabled(
  preferences: NotificationPreferences,
  type: string,
): boolean {
  if (!preferences.push_notifications) {
    return false;
  }

  const preferenceKey = getPreferenceKey(type);

  // Unknown notification types still respect the master push setting.
  if (!preferenceKey) {
    return true;
  }

  return preferences[preferenceKey];
}

function toFcmData(
  row: NotificationRow,
): Record<string, string> {
  const data: Record<string, string> = {};

  for (const [key, value] of Object.entries(row.data ?? {})) {
    if (value !== null && value !== undefined) {
      data[key] = typeof value === "string"
        ? value
        : JSON.stringify(value);
    }
  }

  data.type = row.type;
  data.notification_id = row.id;

  return data;
}

function formatError(error: unknown): Record<string, unknown> {
  if (error instanceof Error) {
    return {
      name: error.name,
      message: error.message,
      stack: error.stack,
    };
  }

  if (typeof error === "object" && error !== null) {
    return error as Record<string, unknown>;
  }

  return {
    message: String(error),
  };
}

Deno.serve(async (request: Request) => {
  let stage = "request_validation";

  const hookSecret = Deno.env.get("PUSH_WEBHOOK_SECRET");

  if (
    request.method !== "POST" ||
    !hookSecret ||
    request.headers.get("x-webhook-secret") !== hookSecret
  ) {
    return new Response("Unauthorized", {
      status: 401,
    });
  }

  try {
    stage = "reading_payload";

    const payload = await request.json();

    stage = "validating_notification_payload";

    const row = (payload.record ?? payload) as NotificationRow;

    if (
      !row.id ||
      !row.user_id ||
      !row.type ||
      !row.title ||
      !row.message
    ) {
      return Response.json(
        {
          error: "Invalid notification payload",
        },
        {
          status: 400,
        },
      );
    }

    stage = "loading_server_configuration";

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID");

    if (!supabaseUrl || !serviceRoleKey || !firebaseProjectId) {
      throw new Error("Server configuration is incomplete");
    }

    stage = "initializing_supabase_client";

    const db = createClient(
      supabaseUrl,
      serviceRoleKey,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      },
    );

    stage = "fetching_preferences_and_device_tokens";

    const [
      preferencesResult,
      tokensResult,
    ] = await Promise.all([
      db
        .from("notification_preferences")
        .select(`
          push_notifications,
          job_updates,
          messages,
          reminders,
          offers_and_promotions,
          app_announcements
        `)
        .eq("user_id", row.user_id)
        .maybeSingle(),

      db
        .from("user_device_tokens")
        .select("id, fcm_token")
        .eq("user_id", row.user_id)
        .eq("is_active", true),
    ]);

    stage = "checking_preferences_and_device_tokens";

    if (preferencesResult.error) {
      throw preferencesResult.error;
    }

    if (tokensResult.error) {
      throw tokensResult.error;
    }

    const preferences =
      (preferencesResult.data ??
        getDefaultPreferences()) as NotificationPreferences;

    if (!isPreferenceEnabled(preferences, row.type)) {
      return Response.json({
        sent: 0,
        skipped: "notification_preferences",
      });
    }

    const tokens = tokensResult.data ?? [];

    if (tokens.length === 0) {
      return Response.json({
        sent: 0,
        skipped: "no_active_device_tokens",
      });
    }

    stage = "generating_firebase_access_token";

    const accessToken = await firebaseAccessToken();

    stage = "preparing_fcm_payload";

    const notificationData = toFcmData(row);

    let sent = 0;
    let failed = 0;
    let deactivated = 0;

    stage = "sending_fcm_notifications";

    for (const device of tokens) {
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
        {
          method: "POST",
          headers: {
            authorization: `Bearer ${accessToken}`,
            "content-type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: device.fcm_token,
              notification: {
                title: row.title,
                body: row.message,
              },
              data: notificationData,
              android: {
                priority: "high",
              },
              apns: {
                payload: {
                  aps: {
                    sound: "default",
                  },
                },
              },
            },
          }),
        },
      );

      if (response.ok) {
        sent++;
        continue;
      }

      failed++;

      const error = await response.json().catch(() => ({}));

      const errorCode =
        error?.error?.details?.find(
          (item: { errorCode?: string }) => item.errorCode,
        )?.errorCode;

      console.error("FCM delivery failed:", {
        status: response.status,
        errorCode: errorCode ?? "unknown",
        message: error?.error?.message ?? "No error message provided",
      });

      if (
        errorCode === "UNREGISTERED" ||
        errorCode === "INVALID_ARGUMENT"
      ) {
        stage = "deactivating_invalid_device_token";

        const { error: updateError } = await db
          .from("user_device_tokens")
          .update({
            is_active: false,
            updated_at: new Date().toISOString(),
          })
          .eq("id", device.id);

        if (!updateError) {
          deactivated++;
        } else {
          console.error("Device token deactivation failed:", {
            message: updateError.message,
          });
        }
      }
    }

    stage = "completed";

    return Response.json({
      success: true,
      sent,
      failed,
      deactivated,
    });
  } catch (error) {
    console.error("Push notification processing failed:", {
      stage,
      ...formatError(error),
    });

    return Response.json(
      {
        error: "Notification delivery failed",
      },
      {
        status: 500,
      },
    );
  }
});
