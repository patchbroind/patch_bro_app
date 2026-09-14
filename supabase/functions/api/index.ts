import { createClient } from "npm:@supabase/supabase-js@2";

const JOB_MEDIA_BUCKET = "job-media";

const MAX_IMAGES = 2;
const MAX_IMAGE_SIZE = 6 * 1024 * 1024; // 6 MB
const MAX_AUDIO_SIZE = 10 * 1024 * 1024; // 10 MB

const ALLOWED_IMAGE_TYPES = new Set<string>([
  "image/jpeg",
  "image/jpg",
  "image/png",
  "image/webp",
]);

const ALLOWED_AUDIO_TYPES = new Set<string>([
  "audio/m4a",
  "audio/mp4",
  "audio/aac",
  "audio/x-m4a",
  "audio/mpeg",
  "audio/mp3",
  "audio/wav",
  "audio/x-wav",
  "audio/webm",
  "audio/ogg",
]);

type ApiError = {
  status: number;
  message: string;
};

function apiError(
  status: number,
  message: string,
): ApiError {
  return {
    status,
    message,
  };
}

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: {
        "Content-Type": "application/json",
      },
    },
  );
}

function getRequiredString(
  formData: FormData,
  key: string,
): string | null {
  const value = formData.get(key);

  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();

  return trimmed.length > 0 ? trimmed : null;
}

function getOptionalString(
  formData: FormData,
  key: string,
): string | null {
  const value = formData.get(key);

  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();

  return trimmed.length > 0 ? trimmed : null;
}

function isValidDate(value: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }

  const date = new Date(`${value}T00:00:00Z`);

  return !Number.isNaN(date.getTime());
}

function isValidTime(value: string): boolean {
  return /^([01]\d|2[0-3]):([0-5]\d)(:[0-5]\d)?$/.test(
    value,
  );
}

function extensionFromMimeType(
  mimeType: string,
): string {
  switch (mimeType.toLowerCase()) {
    case "image/jpeg":
    case "image/jpg":
      return "jpg";

    case "image/png":
      return "png";

    case "image/webp":
      return "webp";

    case "audio/m4a":
    case "audio/x-m4a":
    case "audio/mp4":
      return "m4a";

    case "audio/aac":
      return "aac";

    case "audio/mpeg":
    case "audio/mp3":
      return "mp3";

    case "audio/wav":
    case "audio/x-wav":
      return "wav";

    case "audio/webm":
      return "webm";

    case "audio/ogg":
      return "ogg";

    default:
      return "bin";
  }
}

async function cleanupJob(
  supabaseAdmin: ReturnType<typeof createClient>,
  jobId: string,
  uploadedPaths: string[],
): Promise<void> {
  if (uploadedPaths.length > 0) {
    const { error: storageError } =
      await supabaseAdmin.storage
        .from(JOB_MEDIA_BUCKET)
        .remove(uploadedPaths);

    if (storageError) {
      console.error(
        "Storage cleanup failed:",
        storageError,
      );
    }
  }

  const { error: mediaDeleteError } =
    await supabaseAdmin
      .from("job_media")
      .delete()
      .eq("job_id", jobId);

  if (mediaDeleteError) {
    console.error(
      "Job media cleanup failed:",
      mediaDeleteError,
    );
  }

  const { error: jobDeleteError } =
    await supabaseAdmin
      .from("jobs")
      .delete()
      .eq("id", jobId);

  if (jobDeleteError) {
    console.error(
      "Job cleanup failed:",
      jobDeleteError,
    );
  }
}

function getCorsHeaders(): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods":
      "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  };
}

function jsonCorsResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: {
        ...getCorsHeaders(),
        "Content-Type": "application/json",
      },
    },
  );
}

const supabaseUrl =
  Deno.env.get("SUPABASE_URL") ?? "";

const supabaseAnonKey =
  Deno.env.get("SUPABASE_ANON_KEY") ?? "";

const supabaseServiceRoleKey =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const missingEnvironmentVariables: string[] = [];

if (!supabaseUrl) {
  missingEnvironmentVariables.push(
    "SUPABASE_URL",
  );
}

if (!supabaseAnonKey) {
  missingEnvironmentVariables.push(
    "SUPABASE_ANON_KEY",
  );
}

if (!supabaseServiceRoleKey) {
  missingEnvironmentVariables.push(
    "SUPABASE_SERVICE_ROLE_KEY",
  );
}

const supabaseAdmin = createClient(
  supabaseUrl,
  supabaseServiceRoleKey,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  },
);

Deno.serve(async (req: Request): Promise<Response> => {
  /*
   * ============================================================
   * CORS
   * ============================================================
   */

  if (req.method === "OPTIONS") {
    return new Response("ok", {
      status: 200,
      headers: getCorsHeaders(),
    });
  }

  /*
   * ============================================================
   * ENVIRONMENT CHECK
   * ============================================================
   */

  if (missingEnvironmentVariables.length > 0) {
    console.error(
      "Missing environment variables:",
      missingEnvironmentVariables,
    );

    return jsonCorsResponse(
      {
        success: false,
        message:
          "Server configuration is incomplete",
      },
      500,
    );
  }

  let createdJobId: string | null = null;
  const uploadedPaths: string[] = [];

  try {
    const url = new URL(req.url);

    /*
     * ============================================================
     * ROUTE
     * ============================================================
     *
     * Function:
     *
     * /functions/v1/api
     *
     * API:
     *
     * /employer/jobs
     *
     * Final:
     *
     * /functions/v1/api/employer/jobs
     */

    const isCreateJobRoute =
      req.method === "POST" &&
      url.pathname.endsWith(
        "/employer/jobs",
      );

    if (!isCreateJobRoute) {
      return jsonCorsResponse(
        {
          success: false,
          message: "Route not found",
        },
        404,
      );
    }

    /*
     * ============================================================
     * AUTHENTICATION
     * ============================================================
     */

    const authorization =
      req.headers.get("Authorization");

    if (!authorization) {
      return jsonCorsResponse(
        {
          success: false,
          message: "Authorization token is required",
        },
        401,
      );
    }

    if (
      !authorization
        .toLowerCase()
        .startsWith("bearer ")
    ) {
      return jsonCorsResponse(
        {
          success: false,
          message:
            "Invalid authorization header",
        },
        401,
      );
    }

    const accessToken =
      authorization.substring(7).trim();

    if (!accessToken) {
      return jsonCorsResponse(
        {
          success: false,
          message: "Access token is missing",
        },
        401,
      );
    }

    /*
     * User-scoped client.
     *
     * This client uses the authenticated user's JWT,
     * so normal RLS policies are respected.
     */

    const supabase = createClient(
      supabaseUrl,
      supabaseAnonKey,
      {
        global: {
          headers: {
            Authorization:
              `Bearer ${accessToken}`,
          },
        },
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      },
    );

    /*
     * Verify the Supabase Auth token.
     */

    const {
      data: authData,
      error: authError,
    } = await supabase.auth.getUser(
      accessToken,
    );

    if (
      authError ||
      !authData.user
    ) {
      console.error(
        "Authentication failed:",
        authError,
      );

      return jsonCorsResponse(
        {
          success: false,
          message: "Invalid or expired session",
        },
        401,
      );
    }

    const userId = authData.user.id;

    /*
     * ============================================================
     * VERIFY EMPLOYER
     * ============================================================
     */

    const {
      data: employerProfile,
      error: employerError,
    } = await supabase
      .from("employer_profiles")
      .select("id")
      .eq("id", userId)
      .maybeSingle();

    if (employerError) {
      console.error(
        "Employer profile lookup failed:",
        employerError,
      );

      return jsonCorsResponse(
        {
          success: false,
          message:
            "Unable to verify employer profile",
        },
        500,
      );
    }

    if (!employerProfile) {
      return jsonCorsResponse(
        {
          success: false,
          message:
            "Only registered employers can create jobs",
        },
        403,
      );
    }

    /*
     * ============================================================
     * CONTENT TYPE
     * ============================================================
     */

    const contentType =
      req.headers.get("content-type") ?? "";

    if (
      !contentType
        .toLowerCase()
        .startsWith("multipart/form-data")
    ) {
      return jsonCorsResponse(
        {
          success: false,
          message:
            "Request must use multipart/form-data",
        },
        415,
      );
    }

    /*
     * ============================================================
     * FORM DATA
     * ============================================================
     */

    const formData =
      await req.formData();

    /*
     * ============================================================
     * JOB FIELDS
     * ============================================================
     */

    const category =
      getRequiredString(
        formData,
        "category",
      );

    const skill =
      getRequiredString(
        formData,
        "skill",
      );

    const scheduledDate =
      getRequiredString(
        formData,
        "scheduled_date",
      );

    const scheduledTime =
      getRequiredString(
        formData,
        "scheduled_time",
      );

    const locationAddress =
      getRequiredString(
        formData,
        "location_address",
      );

    const description =
      getOptionalString(
        formData,
        "description",
      );

    const latitudeString =
      getOptionalString(
        formData,
        "latitude",
      );

    const longitudeString =
      getOptionalString(
        formData,
        "longitude",
      );

    /*
     * ============================================================
     * REQUIRED FIELD VALIDATION
     * ============================================================
     */

    if (!category) {
      throw apiError(
        400,
        "Category is required",
      );
    }

    if (!skill) {
      throw apiError(
        400,
        "Skill is required",
      );
    }

    if (!scheduledDate) {
      throw apiError(
        400,
        "Scheduled date is required",
      );
    }

    if (!isValidDate(scheduledDate)) {
      throw apiError(
        400,
        "Invalid scheduled date",
      );
    }

    if (!scheduledTime) {
      throw apiError(
        400,
        "Scheduled time is required",
      );
    }

    if (!isValidTime(scheduledTime)) {
      throw apiError(
        400,
        "Invalid scheduled time",
      );
    }

    if (!locationAddress) {
      throw apiError(
        400,
        "Location is required",
      );
    }

    /*
     * ============================================================
     * LOCATION
     * ============================================================
     */

    let latitude: number | null = null;
    let longitude: number | null = null;

    if (latitudeString) {
      latitude = Number(latitudeString);

      if (!Number.isFinite(latitude)) {
        throw apiError(
          400,
          "Invalid latitude",
        );
      }

      if (
        latitude < -90 ||
        latitude > 90
      ) {
        throw apiError(
          400,
          "Latitude must be between -90 and 90",
        );
      }
    }

    if (longitudeString) {
      longitude = Number(longitudeString);

      if (!Number.isFinite(longitude)) {
        throw apiError(
          400,
          "Invalid longitude",
        );
      }

      if (
        longitude < -180 ||
        longitude > 180
      ) {
        throw apiError(
          400,
          "Longitude must be between -180 and 180",
        );
      }
    }

    /*
     * ============================================================
     * IMAGES
     * ============================================================
     */

    const imageValues =
      formData.getAll("images");

    const images: File[] = [];

    for (
      const value of imageValues
    ) {
      if (
        value instanceof File &&
        value.size > 0
      ) {
        images.push(value);
      }
    }

    if (images.length > MAX_IMAGES) {
      throw apiError(
        400,
        `Maximum ${MAX_IMAGES} images are allowed`,
      );
    }

    /*
     * Validate images.
     */

    for (const image of images) {
      const mimeType =
        image.type.toLowerCase();

      if (
        !ALLOWED_IMAGE_TYPES.has(
          mimeType,
        )
      ) {
        throw apiError(
          400,
          `Unsupported image format: ${image.type}`,
        );
      }

      if (
        image.size > MAX_IMAGE_SIZE
      ) {
        throw apiError(
          400,
          "Each image must be 6 MB or smaller",
        );
      }
    }

    /*
     * ============================================================
     * AUDIO
     * ============================================================
     */

    const audioValue =
      formData.get("audio");

    const audio =
      audioValue instanceof File &&
      audioValue.size > 0
        ? audioValue
        : null;

    if (audio) {
      const mimeType =
        audio.type.toLowerCase();

      if (
        !ALLOWED_AUDIO_TYPES.has(
          mimeType,
        )
      ) {
        throw apiError(
          400,
          `Unsupported audio format: ${audio.type}`,
        );
      }

      if (
        audio.size > MAX_AUDIO_SIZE
      ) {
        throw apiError(
          400,
          "Voice recording must be 10 MB or smaller",
        );
      }
    }

    /*
     * ============================================================
     * CREATE JOB
     * ============================================================
     */

    const {
      data: job,
      error: jobError,
    } = await supabase
      .from("jobs")
      .insert({
        employer_id: userId,
        category,
        skill,
        scheduled_date:
          scheduledDate,
        scheduled_time:
          scheduledTime,
        latitude,
        longitude,
        location_address:
          locationAddress,
        description,
      })
      .select("id")
      .single();

    if (jobError || !job) {
      console.error(
        "Job creation failed:",
        jobError,
      );

      return jsonCorsResponse(
        {
          success: false,
          message:
            "Failed to create job",
        },
        500,
      );
    }

    createdJobId = job.id;

    /*
     * ============================================================
     * UPLOAD IMAGES
     * ============================================================
     */

    let sortOrder = 0;

    for (const image of images) {
      const mimeType =
        image.type.toLowerCase();

      const extension =
        extensionFromMimeType(
          mimeType,
        );

      const fileName =
        `${crypto.randomUUID()}.${extension}`;

      const storagePath =
        `${job.id}/images/${fileName}`;

      const fileBuffer =
        new Uint8Array(
          await image.arrayBuffer(),
        );

      const {
        error: uploadError,
      } = await supabaseAdmin.storage
        .from(JOB_MEDIA_BUCKET)
        .upload(
          storagePath,
          fileBuffer,
          {
            contentType:
              mimeType ||
              "application/octet-stream",
            upsert: false,
          },
        );

      if (uploadError) {
        console.error(
          "Image upload failed:",
          uploadError,
        );

        throw apiError(
          500,
          "Failed to upload job image",
        );
      }

      uploadedPaths.push(
        storagePath,
      );

      const {
        error: mediaError,
      } = await supabase
        .from("job_media")
        .insert({
          job_id: job.id,
          media_type: "image",
          storage_path:
            storagePath,
          mime_type:
            mimeType ||
            "application/octet-stream",
          file_size: image.size,
          sort_order: sortOrder,
        });

      if (mediaError) {
        console.error(
          "Image media record creation failed:",
          mediaError,
        );

        throw apiError(
          500,
          "Failed to save job image information",
        );
      }

      sortOrder++;
    }

    /*
     * ============================================================
     * UPLOAD AUDIO
     * ============================================================
     */

    if (audio) {
      const mimeType =
        audio.type.toLowerCase();

      const extension =
        extensionFromMimeType(
          mimeType,
        );

      const fileName =
        `${crypto.randomUUID()}.${extension}`;

      const storagePath =
        `${job.id}/audio/${fileName}`;

      const audioBuffer =
        new Uint8Array(
          await audio.arrayBuffer(),
        );

      const {
        error: uploadError,
      } = await supabaseAdmin.storage
        .from(JOB_MEDIA_BUCKET)
        .upload(
          storagePath,
          audioBuffer,
          {
            contentType:
              mimeType ||
              "application/octet-stream",
            upsert: false,
          },
        );

      if (uploadError) {
        console.error(
          "Audio upload failed:",
          uploadError,
        );

        throw apiError(
          500,
          "Failed to upload voice description",
        );
      }

      uploadedPaths.push(
        storagePath,
      );

      const {
        error: mediaError,
      } = await supabase
        .from("job_media")
        .insert({
          job_id: job.id,
          media_type: "audio",
          storage_path:
            storagePath,
          mime_type:
            mimeType ||
            "application/octet-stream",
          file_size: audio.size,
          sort_order: 0,
        });

      if (mediaError) {
        console.error(
          "Audio media record creation failed:",
          mediaError,
        );

        throw apiError(
          500,
          "Failed to save voice description information",
        );
      }
    }

    /*
     * ============================================================
     * SUCCESS
     * ============================================================
     */

    return jsonCorsResponse({
      success: true,
      message:
        "Job created successfully",
      data: {
        job_id: job.id,
      },
    });
  } catch (error) {
    /*
     * ============================================================
     * CLEANUP
     * ============================================================
     */

    if (createdJobId) {
      try {
        await cleanupJob(
          supabaseAdmin,
          createdJobId,
          uploadedPaths,
        );
      } catch (cleanupError) {
        console.error(
          "Cleanup failed:",
          cleanupError,
        );
      }
    }

    /*
     * ============================================================
     * KNOWN API ERROR
     * ============================================================
     */

    const errorValue =
      error as Partial<ApiError>;

    if (
      typeof errorValue.status ===
        "number" &&
      typeof errorValue.message ===
        "string"
    ) {
      return jsonCorsResponse(
        {
          success: false,
          message:
            errorValue.message,
        },
        errorValue.status,
      );
    }

    /*
     * ============================================================
     * UNKNOWN ERROR
     * ============================================================
     */

    console.error(
      "Unexpected API error:",
      error,
    );

    return jsonCorsResponse(
      {
        success: false,
        message:
          "Something went wrong while creating the job",
      },
      500,
    );
  }
});