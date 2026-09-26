import { createClient } from "npm:@supabase/supabase-js@2";

const JOB_MEDIA_BUCKET = "job-media";

const MAX_IMAGES = 2;
const MAX_IMAGE_SIZE = 6 * 1024 * 1024;
const MAX_AUDIO_SIZE = 10 * 1024 * 1024;

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

type JobRow = {
  id: string;
  employer_id: string;
  category: string;
  skill: string;
  scheduled_date: string;
  scheduled_time: string;
  latitude: number;
  longitude: number;
  location_address: string;
  description: string | null;
  status: string;
  created_at: string;
  updated_at: string;
};

type JobMediaRow = {
  job_id: string;
  media_type: string;
  storage_path: string;
  mime_type: string | null;
  file_size: number | null;
  sort_order: number;
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

async function removeStorageFiles(
  supabaseAdmin: ReturnType<typeof createClient>,
  paths: string[],
): Promise<void> {
  if (paths.length === 0) {
    return;
  }

  const uniquePaths = [
    ...new Set(
      paths.filter(
        (path) =>
          typeof path === "string" &&
          path.trim().length > 0,
      ),
    ),
  ];

  if (uniquePaths.length === 0) {
    return;
  }

  const { error } =
    await supabaseAdmin.storage
      .from(JOB_MEDIA_BUCKET)
      .remove(uniquePaths);

  if (error) {
    console.error(
      "Storage removal failed:",
      error,
    );
  }
}

async function cleanupJob(
  supabaseAdmin: ReturnType<typeof createClient>,
  jobId: string,
  uploadedPaths: string[],
): Promise<void> {
  if (uploadedPaths.length > 0) {
    await removeStorageFiles(
      supabaseAdmin,
      uploadedPaths,
    );
  }

  const {
    data: mediaRows,
    error: mediaFetchError,
  } = await supabaseAdmin
    .from("job_media")
    .select("storage_path")
    .eq("job_id", jobId);

  if (mediaFetchError) {
    console.error(
      "Job media cleanup lookup failed:",
      mediaFetchError,
    );
  }

  if (mediaRows && mediaRows.length > 0) {
    await removeStorageFiles(
      supabaseAdmin,
      mediaRows
        .map(
          (item) =>
            item.storage_path as string,
        ),
    );
  }

  const {
    error: mediaDeleteError,
  } = await supabaseAdmin
    .from("job_media")
    .delete()
    .eq("job_id", jobId);

  if (mediaDeleteError) {
    console.error(
      "Job media cleanup failed:",
      mediaDeleteError,
    );
  }

  const {
    error: jobDeleteError,
  } = await supabaseAdmin
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

function parseJsonStringArray(
  formData: FormData,
  key: string,
): string[] {
  const value = formData.get(key);

  if (typeof value !== "string") {
    return [];
  }

  if (value.trim().length === 0) {
    return [];
  }

  try {
    const parsed = JSON.parse(value);

    if (!Array.isArray(parsed)) {
      return [];
    }

    return parsed
      .filter(
        (item): item is string =>
          typeof item === "string",
      )
      .map((item) => item.trim())
      .filter(
        (item) => item.length > 0,
      );
  } catch (error) {
    console.error(
      `Failed to parse ${key}:`,
      error,
    );

    throw apiError(
      400,
      `Invalid ${key} format`,
    );
  }
}

function parseBoolean(
  formData: FormData,
  key: string,
): boolean {
  const value = formData.get(key);

  if (typeof value !== "string") {
    return false;
  }

  return value.trim().toLowerCase() === "true";
}

function validateImages(
  images: File[],
): void {
  if (images.length > MAX_IMAGES) {
    throw apiError(
      400,
      `Maximum ${MAX_IMAGES} images are allowed`,
    );
  }

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

    if (image.size > MAX_IMAGE_SIZE) {
      throw apiError(
        400,
        "Each image must be 6 MB or smaller",
      );
    }
  }
}

function validateAudio(
  audio: File | null,
): void {
  if (!audio) {
    return;
  }

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

  if (audio.size > MAX_AUDIO_SIZE) {
    throw apiError(
      400,
      "Voice recording must be 10 MB or smaller",
    );
  }
}

async function getSignedMedia(
  supabaseAdmin: ReturnType<typeof createClient>,
  mediaRows: JobMediaRow[],
): Promise<{
  images: Array<{
    url: string;
    storage_path: string;
    sort_order: number;
  }>;
  audio: {
    url: string;
    storage_path: string;
  } | null;
}> {
  const images: Array<{
    url: string;
    storage_path: string;
    sort_order: number;
  }> = [];

  let audio: {
    url: string;
    storage_path: string;
  } | null = null;

  for (const item of mediaRows) {
    const {
      data,
      error,
    } = await supabaseAdmin.storage
      .from(JOB_MEDIA_BUCKET)
      .createSignedUrl(
        item.storage_path,
        3600,
      );

    if (error) {
      console.error(
        "Signed URL creation failed:",
        error,
      );
      continue;
    }

    const signedUrl =
      data?.signedUrl;

    if (!signedUrl) {
      continue;
    }

    if (
      item.media_type === "image"
    ) {
      images.push({
        url: signedUrl,
        storage_path:
          item.storage_path,
        sort_order:
          item.sort_order,
      });
    }

    if (
      item.media_type === "audio"
    ) {
      audio = {
        url: signedUrl,
        storage_path:
          item.storage_path,
      };
    }
  }

  images.sort(
    (a, b) =>
      a.sort_order - b.sort_order,
  );

  return {
    images,
    audio,
  };
}

async function uploadJobImages(
  supabaseAdmin: ReturnType<typeof createClient>,
  supabase: ReturnType<typeof createClient>,
  jobId: string,
  images: File[],
  startingSortOrder = 0,
): Promise<string[]> {
  const uploadedPaths: string[] = [];

  let sortOrder =
    startingSortOrder;

  try {
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
        `${jobId}/images/${fileName}`;

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
          job_id: jobId,
          media_type: "image",
          storage_path:
            storagePath,
          mime_type:
            mimeType ||
            "application/octet-stream",
          file_size:
            image.size,
          sort_order:
            sortOrder,
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

    return uploadedPaths;
  } catch (error) {
    await removeStorageFiles(
      supabaseAdmin,
      uploadedPaths,
    );

    throw error;
  }
}

async function uploadJobAudio(
  supabaseAdmin: ReturnType<typeof createClient>,
  supabase: ReturnType<typeof createClient>,
  jobId: string,
  audio: File,
): Promise<string> {
  const mimeType =
    audio.type.toLowerCase();

  const extension =
    extensionFromMimeType(
      mimeType,
    );

  const fileName =
    `${crypto.randomUUID()}.${extension}`;

  const storagePath =
    `${jobId}/audio/${fileName}`;

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

  const {
    error: mediaError,
  } = await supabase
    .from("job_media")
    .insert({
      job_id: jobId,
      media_type: "audio",
      storage_path:
        storagePath,
      mime_type:
        mimeType ||
        "application/octet-stream",
      file_size:
        audio.size,
      sort_order: 0,
    });

  if (mediaError) {
    await removeStorageFiles(
      supabaseAdmin,
      [storagePath],
    );

    console.error(
      "Audio media record creation failed:",
      mediaError,
    );

    throw apiError(
      500,
      "Failed to save voice description information",
    );
  }

  return storagePath;
}

const supabaseUrl =
  Deno.env.get("SUPABASE_URL") ?? "";

const supabaseAnonKey =
  Deno.env.get("SUPABASE_ANON_KEY") ?? "";

const supabaseServiceRoleKey =
  Deno.env.get(
    "SUPABASE_SERVICE_ROLE_KEY",
  ) ?? "";

const missingEnvironmentVariables:
  string[] = [];

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

const supabaseAdmin =
  createClient(
    supabaseUrl,
    supabaseServiceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );

Deno.serve(
  async (
    req: Request,
  ): Promise<Response> => {
    if (req.method === "OPTIONS") {
      return new Response(
        "ok",
        {
          status: 200,
          headers:
            getCorsHeaders(),
        },
      );
    }

    if (
      missingEnvironmentVariables
        .length > 0
    ) {
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

    let createdJobId:
      string | null = null;

    const uploadedPaths:
      string[] = [];

    try {
      const url =
        new URL(req.url);

      /*
       * ============================================================
       * ROUTE
       * ============================================================
       */

      const employerJobsRoute =
        url.pathname.endsWith(
          "/employer/jobs",
        );

      const employerJobMatch =
        url.pathname.match(
          /\/employer\/jobs\/([^/]+)$/,
        );

      if (
        !employerJobsRoute &&
        !employerJobMatch
      ) {
        return jsonCorsResponse(
          {
            success: false,
            message:
              "Route not found",
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
        req.headers.get(
          "Authorization",
        );

      if (!authorization) {
        return jsonCorsResponse(
          {
            success: false,
            message:
              "Authorization token is required",
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
        authorization
          .substring(7)
          .trim();

      if (!accessToken) {
        return jsonCorsResponse(
          {
            success: false,
            message:
              "Access token is missing",
          },
          401,
        );
      }

      const supabase =
        createClient(
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
              autoRefreshToken:
                false,
              persistSession:
                false,
            },
          },
        );

      const {
        data: authData,
        error: authError,
      } =
        await supabase.auth.getUser(
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
            message:
              "Invalid or expired session",
          },
          401,
        );
      }

      const userId =
        authData.user.id;

      /*
       * ============================================================
       * VERIFY EMPLOYER
       * ============================================================
       */

      const {
        data:
          employerProfile,
        error:
          employerError,
      } =
        await supabase
          .from(
            "employer_profiles",
          )
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
              "Only registered employers can manage jobs",
          },
          403,
        );
      }

      /*
       * ============================================================
       * GET EMPLOYER JOBS
       * ============================================================
       */

      if (
        req.method === "GET" &&
        employerJobsRoute
      ) {
        const {
          data: jobs,
          error: jobsError,
        } =
          await supabaseAdmin
            .from("jobs")
            .select(`
              id,
              employer_id,
              category,
              skill,
              scheduled_date,
              scheduled_time,
              latitude,
              longitude,
              location_address,
              description,
              status,
              created_at,
              updated_at
            `)
            .eq(
              "employer_id",
              userId,
            )
            .order(
              "created_at",
              {
                ascending:
                  false,
              },
            );

        if (jobsError) {
          console.error(
            "Employer jobs fetch failed:",
            jobsError,
          );

          return jsonCorsResponse(
            {
              success: false,
              message:
                "Failed to fetch employer jobs",
            },
            500,
          );
        }

        const jobRows =
          Array.isArray(jobs)
            ? (jobs as JobRow[])
            : [];

        const jobIds =
          jobRows.map(
            (job) => job.id,
          );

        let media:
          JobMediaRow[] = [];

        if (
          jobIds.length > 0
        ) {
          const {
            data: mediaData,
            error:
              mediaError,
          } =
            await supabaseAdmin
              .from("job_media")
              .select(`
                job_id,
                media_type,
                storage_path,
                mime_type,
                file_size,
                sort_order
              `)
              .in(
                "job_id",
                jobIds,
              )
              .order(
                "sort_order",
                {
                  ascending:
                    true,
                },
              );

          if (mediaError) {
            console.error(
              "Employer job media fetch failed:",
              mediaError,
            );

            return jsonCorsResponse(
              {
                success: false,
                message:
                  "Failed to fetch job media",
              },
              500,
            );
          }

          media =
            (mediaData ??
              []) as JobMediaRow[];
        }

        const mediaByJobId =
          new Map<
            string,
            JobMediaRow[]
          >();

        for (
          const item of media
        ) {
          finalAddMedia:
          {
            const current =
              mediaByJobId.get(
                item.job_id,
              ) ??
              [];

            current.push(item);

            mediaByJobId.set(
              item.job_id,
              current,
            );
          }
        }

        const responseJobs =
          [];

        for (
          const job of jobRows
        ) {
          const jobMedia =
            mediaByJobId.get(
              job.id,
            ) ??
            [];

          const signedMedia =
            await getSignedMedia(
              supabaseAdmin,
              jobMedia,
            );

          responseJobs.push({
            id: job.id,
            category:
              job.category,
            skill: job.skill,
            scheduled_date:
              job.scheduled_date,
            scheduled_time:
              job.scheduled_time,
            latitude:
              job.latitude,
            longitude:
              job.longitude,
            location_address:
              job.location_address,
            description:
              job.description ??
              "",
            status:
              job.status,
            created_at:
              job.created_at,
            updated_at:
              job.updated_at,

            image_url:
              signedMedia
                .images[0]?.url ??
              null,

            image_urls:
              signedMedia.images.map(
                (item) =>
                  item.url,
              ),

            image_media:
              signedMedia.images.map(
                (item) => ({
                  url: item.url,
                  storage_path:
                    item.storage_path,
                  sort_order:
                    item.sort_order,
                }),
              ),

            audio_url:
              signedMedia
                .audio?.url ??
              null,

            audio_storage_path:
              signedMedia
                .audio
                ?.storage_path ??
              null,
          });
        }

        return jsonCorsResponse({
          success: true,
          message:
            "Jobs fetched successfully",
          data: responseJobs,
        });
      }

      /*
       * ============================================================
       * GET /employer/jobs/{id}
       * ============================================================
       */

      if (
        req.method === "GET" &&
        employerJobMatch
      ) {
        const jobId =
          employerJobMatch[1];

        const {
          data: job,
          error: jobError,
        } =
          await supabaseAdmin
            .from("jobs")
            .select(`
              id,
              employer_id,
              category,
              skill,
              scheduled_date,
              scheduled_time,
              latitude,
              longitude,
              location_address,
              description,
              status,
              created_at,
              updated_at
            `)
            .eq("id", jobId)
            .eq(
              "employer_id",
              userId,
            )
            .maybeSingle();

        if (jobError) {
          console.error(
            "Job fetch failed:",
            jobError,
          );

          return jsonCorsResponse(
            {
              success: false,
              message:
                "Failed to fetch job",
            },
            500,
          );
        }

        if (!job) {
          return jsonCorsResponse(
            {
              success: false,
              message:
                "Job not found",
            },
            404,
          );
        }

        const {
          data: mediaData,
          error: mediaError,
        } =
          await supabaseAdmin
            .from("job_media")
            .select(`
              job_id,
              media_type,
              storage_path,
              mime_type,
              file_size,
              sort_order
            `)
            .eq(
              "job_id",
              jobId,
            )
            .order(
              "sort_order",
              {
                ascending:
                  true,
              },
            );

        if (mediaError) {
          console.error(
            "Job media fetch failed:",
            mediaError,
          );

          return jsonCorsResponse(
            {
              success: false,
              message:
                "Failed to fetch job media",
            },
            500,
          );
        }

        const signedMedia =
          await getSignedMedia(
            supabaseAdmin,
            (mediaData ??
              []) as JobMediaRow[],
          );

        return jsonCorsResponse({
          success: true,
          message:
            "Job fetched successfully",
          data: {
            id: job.id,
            category:
              job.category,
            skill: job.skill,
            scheduled_date:
              job.scheduled_date,
            scheduled_time:
              job.scheduled_time,
            latitude:
              job.latitude,
            longitude:
              job.longitude,
            location_address:
              job.location_address,
            description:
              job.description ?? "",
            status:
              job.status,
            created_at:
              job.created_at,
            updated_at:
              job.updated_at,

            image_url:
              signedMedia
                .images[0]?.url ??
              null,

            image_urls:
              signedMedia.images.map(
                (item) =>
                  item.url,
              ),

            image_media:
              signedMedia.images.map(
                (item) => ({
                  url: item.url,
                  storage_path:
                    item.storage_path,
                  sort_order:
                    item.sort_order,
                }),
              ),

            audio_url:
              signedMedia
                .audio?.url ??
              null,

            audio_storage_path:
              signedMedia
                .audio
                ?.storage_path ??
              null,
          },
        });
      }

      /*
       * ============================================================
       * CREATE / UPDATE CONTENT TYPE
       * ============================================================
       */

      const contentType =
        req.headers.get(
          "content-type",
        ) ??
        "";

      if (
        !contentType
          .toLowerCase()
          .startsWith(
            "multipart/form-data",
          )
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

      if (
        !isValidDate(
          scheduledDate,
        )
      ) {
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

      if (
        !isValidTime(
          scheduledTime,
        )
      ) {
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

      if (
        !latitudeString ||
        !longitudeString
      ) {
        throw apiError(
          400,
          "Valid location coordinates are required",
        );
      }

      const latitude =
        Number(latitudeString);

      const longitude =
        Number(longitudeString);

      if (
        !Number.isFinite(
          latitude,
        )
      ) {
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

      if (
        !Number.isFinite(
          longitude,
        )
      ) {
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

      /*
       * ============================================================
       * MEDIA
       * ============================================================
       */

      const imageValues =
        formData.getAll(
          "images",
        );

      const images: File[] =
        [];

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

      validateImages(
        images,
      );

      const audioValue =
        formData.get("audio");

      const audio =
        audioValue instanceof File &&
        audioValue.size > 0
          ? audioValue
          : null;

      validateAudio(
        audio,
      );

      /*
       * ============================================================
       * CREATE JOB
       * ============================================================
       */

      if (
        req.method === "POST" &&
        employerJobsRoute
      ) {
        const {
          data: job,
          error: jobError,
        } =
          await supabase
            .from("jobs")
            .insert({
              employer_id:
                userId,
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

        if (
          jobError ||
          !job
        ) {
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

        createdJobId =
          job.id;

        const imagePaths =
          await uploadJobImages(
            supabaseAdmin,
            supabase,
            job.id,
            images,
            0,
          );

        uploadedPaths.push(
          ...imagePaths,
        );

        if (audio) {
          const audioPath =
            await uploadJobAudio(
              supabaseAdmin,
              supabase,
              job.id,
              audio,
            );

          uploadedPaths.push(
            audioPath,
          );
        }

        return jsonCorsResponse({
          success: true,
          message:
            "Job created successfully",
          data: {
            job_id: job.id,
          },
        });
      }

      /*
       * ============================================================
       * UPDATE JOB
       * ============================================================
       */

      if (
        req.method === "PATCH" &&
        employerJobMatch
      ) {
        const jobId =
          employerJobMatch[1];

        /*
         * Verify ownership.
         */

        const {
          data: existingJob,
          error:
            existingJobError,
        } =
          await supabaseAdmin
            .from("jobs")
            .select(`
              id,
              employer_id
            `)
            .eq("id", jobId)
            .eq(
              "employer_id",
              userId,
            )
            .maybeSingle();

        if (existingJobError) {
          console.error(
            "Job ownership lookup failed:",
            existingJobError,
          );

          return jsonCorsResponse(
            {
              success: false,
              message:
                "Unable to verify job ownership",
            },
            500,
          );
        }

        if (!existingJob) {
          return jsonCorsResponse(
            {
              success: false,
              message:
                "Job not found",
            },
            404,
          );
        }

        /*
         * Existing media.
         */

        const {
          data: existingMediaData,
          error:
            existingMediaError,
        } =
          await supabaseAdmin
            .from("job_media")
            .select(`
              job_id,
              media_type,
              storage_path,
              mime_type,
              file_size,
              sort_order
            `)
            .eq(
              "job_id",
              jobId,
            )
            .order(
              "sort_order",
              {
                ascending:
                  true,
              },
            );

        if (
          existingMediaError
        ) {
          console.error(
            "Existing job media lookup failed:",
            existingMediaError,
          );

          return jsonCorsResponse(
            {
              success: false,
              message:
                "Unable to load existing job media",
            },
            500,
          );
        }

        const existingMedia =
          (existingMediaData ??
            []) as JobMediaRow[];

        /*
         * Client sends storage paths that should be deleted.
         */

        const keepImagePaths =
          parseJsonStringArray(
            formData,
            "keep_image_paths",
          );

        const deleteAudio =
          parseBoolean(
            formData,
            "delete_audio",
          );

        /*
         * Only allow deletion of media belonging
         * to this job.
         */

        const validExistingPaths =
          new Set(
            existingMedia.map(
              (item) =>
                item.storage_path,
            ),
          );

        const existingImagePaths =
          existingMedia
            .filter(
              (item) =>
                item.media_type ===
                "image",
            )
            .map(
              (item) =>
                item.storage_path,
            );

        const imagePathsToDelete =
          existingImagePaths.filter(
            (path) =>
              !keepImagePaths.includes(
                path,
              ),
          );

        const audioMedia =
          existingMedia.find(
            (item) =>
              item.media_type ===
              "audio",
          );

        const audioPathToDelete =
          deleteAudio &&
          audioMedia &&
          validExistingPaths.has(
            audioMedia.storage_path,
          )
            ? audioMedia.storage_path
            : null;

        /*
         * Calculate remaining images.
         */

        const remainingImages =
          existingMedia.filter(
            (item) =>
              item.media_type ===
                "image" &&
              !imagePathsToDelete.includes(
                item.storage_path,
              ),
          );

        if (
          remainingImages.length +
            images.length >
          MAX_IMAGES
        ) {
          throw apiError(
            400,
            `A maximum of ${MAX_IMAGES} images are allowed`,
          );
        }

        /*
         * Update database fields first.
         */

        const {
          data: updatedJob,
          error:
            updateJobError,
        } =
          await supabaseAdmin
            .from("jobs")
            .update({
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
              updated_at:
                new Date().toISOString(),
            })
            .eq("id", jobId)
            .eq(
              "employer_id",
              userId,
            )
            .select(`
              id,
              category,
              skill,
              scheduled_date,
              scheduled_time,
              latitude,
              longitude,
              location_address,
              description,
              status,
              created_at,
              updated_at
            `)
            .single();

        if (
          updateJobError ||
          !updatedJob
        ) {
          console.error(
            "Job update failed:",
            updateJobError,
          );

          return jsonCorsResponse(
            {
              success: false,
              message:
                "Failed to update job",
            },
            500,
          );
        }

        /*
         * Delete selected image records.
         */

        if (
          imagePathsToDelete
            .length > 0
        ) {
          const {
            error:
              imageDeleteError,
          } =
            await supabaseAdmin
              .from("job_media")
              .delete()
              .eq(
                "job_id",
                jobId,
              )
              .eq(
                "media_type",
                "image",
              )
              .in(
                "storage_path",
                imagePathsToDelete,
              );

          if (
            imageDeleteError
          ) {
            console.error(
              "Image media deletion failed:",
              imageDeleteError,
            );

            throw apiError(
              500,
              "Failed to remove selected job images",
            );
          }

          await removeStorageFiles(
            supabaseAdmin,
            imagePathsToDelete,
          );
        }

        /*
         * Delete existing audio.
         */

        if (audioPathToDelete) {
          const {
            error:
              audioDeleteError,
          } =
            await supabaseAdmin
              .from("job_media")
              .delete()
              .eq(
                "job_id",
                jobId,
              )
              .eq(
                "media_type",
                "audio",
              )
              .eq(
                "storage_path",
                audioPathToDelete,
              );

          if (
            audioDeleteError
          ) {
            console.error(
              "Audio media deletion failed:",
              audioDeleteError,
            );

            throw apiError(
              500,
              "Failed to remove existing voice description",
            );
          }

          await removeStorageFiles(
            supabaseAdmin,
            [audioPathToDelete],
          );
        }

        /*
         * Recalculate image order after deletions.
         */

        const {
          data:
            remainingImageRows,
          error:
            remainingImageError,
        } =
          await supabaseAdmin
            .from("job_media")
            .select(`
              storage_path,
              sort_order
            `)
            .eq(
              "job_id",
              jobId,
            )
            .eq(
              "media_type",
              "image",
            )
            .order(
              "sort_order",
              {
                ascending:
                  true,
              },
            );

        if (
          remainingImageError
        ) {
          throw apiError(
            500,
            "Failed to load remaining job images",
          );
        }

        let nextSortOrder =
          remainingImageRows
            ?.length ??
          0;

        /*
         * Upload newly added images.
         */

        if (
          images.length > 0
        ) {
          const newImagePaths =
            await uploadJobImages(
              supabaseAdmin,
              supabase,
              jobId,
              images,
              nextSortOrder,
            );

          uploadedPaths.push(
            ...newImagePaths,
          );
        }

        /*
         * Replace audio if a new recording
         * was supplied.
         *
         * A new audio file always replaces
         * the old one.
         */

        if (audio) {
          if (
            audioMedia &&
            !deleteAudio
          ) {
            const {
              error:
                oldAudioDeleteError,
            } =
              await supabaseAdmin
                .from("job_media")
                .delete()
                .eq(
                  "job_id",
                  jobId,
                )
                .eq(
                  "media_type",
                  "audio",
                );

            if (
              oldAudioDeleteError
            ) {
              throw apiError(
                500,
                "Failed to replace existing voice description",
              );
            }

            await removeStorageFiles(
              supabaseAdmin,
              [
                audioMedia.storage_path,
              ],
            );
          }

          const audioPath =
            await uploadJobAudio(
              supabaseAdmin,
              supabase,
              jobId,
              audio,
            );

          uploadedPaths.push(
            audioPath,
          );
        }

        /*
         * Return updated job + media.
         */

        const {
          data:
            finalMediaData,
          error:
            finalMediaError,
        } =
          await supabaseAdmin
            .from("job_media")
            .select(`
              job_id,
              media_type,
              storage_path,
              mime_type,
              file_size,
              sort_order
            `)
            .eq(
              "job_id",
              jobId,
            )
            .order(
              "sort_order",
              {
                ascending:
                  true,
              },
            );

        if (
          finalMediaError
        ) {
          throw apiError(
            500,
            "Failed to load updated job media",
          );
        }

        const finalSignedMedia =
          await getSignedMedia(
            supabaseAdmin,
            (finalMediaData ??
              []) as JobMediaRow[],
          );

        return jsonCorsResponse({
          success: true,
          message:
            "Job updated successfully",
          data: {
            job_id:
              updatedJob.id,

            job: {
              id:
                updatedJob.id,
              category:
                updatedJob.category,
              skill:
                updatedJob.skill,
              scheduled_date:
                updatedJob.scheduled_date,
              scheduled_time:
                updatedJob.scheduled_time,
              latitude:
                updatedJob.latitude,
              longitude:
                updatedJob.longitude,
              location_address:
                updatedJob.location_address,
              description:
                updatedJob.description ??
                "",
              status:
                updatedJob.status,
              created_at:
                updatedJob.created_at,
              updated_at:
                updatedJob.updated_at,

              image_url:
                finalSignedMedia
                  .images[0]
                  ?.url ??
                null,

              image_urls:
                finalSignedMedia.images.map(
                  (item) =>
                    item.url,
                ),

              image_media:
                finalSignedMedia.images.map(
                  (item) => ({
                    url: item.url,
                    storage_path:
                      item.storage_path,
                    sort_order:
                      item.sort_order,
                  }),
                ),

              audio_url:
                finalSignedMedia
                  .audio?.url ??
                null,

              audio_storage_path:
                finalSignedMedia
                  .audio
                  ?.storage_path ??
                null,
            },
          },
        });
      }

      return jsonCorsResponse(
        {
          success: false,
          message:
            "Unsupported method",
        },
        405,
      );
    } catch (error) {
      /*
       * ============================================================
       * CREATE JOB CLEANUP
       * ============================================================
       */

      if (createdJobId) {
        try {
          await cleanupJob(
            supabaseAdmin,
            createdJobId,
            uploadedPaths,
          );
        } catch (
          cleanupError
        ) {
          console.error(
            "Cleanup failed:",
            cleanupError,
          );
        }
      }

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

      console.error(
        "Unexpected API error:",
        error,
      );

      return jsonCorsResponse(
        {
          success: false,
          message:
            "Something went wrong while processing the job",
        },
        500,
      );
    }
  },
);