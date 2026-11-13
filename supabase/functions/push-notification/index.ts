import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = { "content-type": "application/json" };
const encoder = new TextEncoder();

function base64Url(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

async function firebaseAccessToken(): Promise<string> {
  const email = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
  const projectId = Deno.env.get("FIREBASE_PROJECT_ID")!;
  const privateKey = Deno.env.get("FIREBASE_PRIVATE_KEY")!.replace(/\\n/g, "\n");
  const pem = privateKey.replace(/-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\s/g, "");
  const keyBytes = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8", keyBytes, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"],
  );
  const now = Math.floor(Date.now() / 1000);
  const head = base64Url(encoder.encode(JSON.stringify({ alg: "RS256", typ: "JWT" })));
  const body = base64Url(encoder.encode(JSON.stringify({
    iss: email, scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token", iat: now, exp: now + 3600,
  })));
  const unsigned = `${head}.${body}`;
  const signature = new Uint8Array(await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, encoder.encode(unsigned)));
  const jwt = `${unsigned}.${base64Url(signature)}`;
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST", headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({ grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: jwt }),
  });
  if (!response.ok) throw new Error(`Firebase OAuth failed (${response.status})`);
  return (await response.json()).access_token as string;
}

Deno.serve(async (request) => {
  const hookSecret = Deno.env.get("PUSH_WEBHOOK_SECRET");
  if (request.method !== "POST" || !hookSecret || request.headers.get("x-webhook-secret") !== hookSecret) {
    return new Response("Unauthorized", { status: 401 });
  }
  try {
    const payload = await request.json();
    const row = payload.record ?? payload;
    if (!row?.id || !row?.user_id || !row?.type) return Response.json({ error: "Invalid record" }, { status: 400 });

    const url = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const db = createClient(url, serviceKey, { auth: { persistSession: false } });
    const [{ data: prefs }, { data: tokens }] = await Promise.all([
      db.from("notification_preferences").select("*").eq("user_id", row.user_id).maybeSingle(),
      db.from("user_device_tokens").select("id,fcm_token").eq("user_id", row.user_id).eq("is_active", true),
    ]);
    const preference = prefs ?? { push_notifications: true, job_updates: true };
    if (!preference.push_notifications || (row.type.startsWith("job_") && !preference.job_updates)) {
      return Response.json({ skipped: "preferences" });
    }
    if (!tokens?.length) return Response.json({ sent: 0 });

    const accessToken = await firebaseAccessToken();
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID")!;
    const data = Object.fromEntries(Object.entries(row.data ?? {}).map(([k, v]) => [k, String(v ?? "")]));
    Object.assign(data, { type: String(row.type), notification_id: String(row.id) });
    let sent = 0;
    for (const token of tokens) {
      const result = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
        method: "POST", headers: { authorization: `Bearer ${accessToken}`, "content-type": "application/json" },
        body: JSON.stringify({ message: { token: token.fcm_token, notification: { title: row.title, body: row.message }, data } }),
      });
      if (result.ok) { sent++; continue; }
      const error = await result.json().catch(() => ({}));
      const code = error?.error?.details?.find((item: { errorCode?: string }) => item.errorCode)?.errorCode;
      if (result.status === 404 || code === "UNREGISTERED" || code === "INVALID_ARGUMENT") {
        await db.from("user_device_tokens").update({ is_active: false, updated_at: new Date().toISOString() }).eq("id", token.id);
      } else {
        console.error("FCM delivery failed", result.status);
      }
    }
    return Response.json({ sent });
  } catch (error) {
    console.error("Push notification processing failed", error instanceof Error ? error.message : "unknown error");
    return Response.json({ error: "Notification delivery failed" }, { status: 500 });
  }
});
