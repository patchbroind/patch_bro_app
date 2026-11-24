
import { createClient } from "npm:@supabase/supabase-js@2";

type SupabaseAdmin = ReturnType<typeof createClient>;

type HandlerParams = {
  req: Request;
  jobId: string;
  userId: string;
  supabaseAdmin: SupabaseAdmin;
  jsonCorsResponse: (
    body: Record<string, unknown>,
    status?: number,
  ) => Response;
};

const BUCKET = "job-media";
const MAX_IMAGES = 5;
const MAX_IMAGE_SIZE = 6 * 1024 * 1024;
const MAX_AUDIO_SIZE = 10 * 1024 * 1024;

const IMAGE_TYPES = new Set([
  "image/jpeg",
  "image/jpg",
  "image/png",
  "image/webp",
]);

const AUDIO_TYPES = new Set([
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

function getExtension(mime: string): string {
  const extensions: Record<string, string> = {
    "image/jpeg": "jpg",
    "image/jpg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
    "audio/m4a": "m4a",
    "audio/x-m4a": "m4a",
    "audio/mp4": "m4a",
    "audio/aac": "aac",
    "audio/mpeg": "mp3",
    "audio/mp3": "mp3",
    "audio/wav": "wav",
    "audio/x-wav": "wav",
    "audio/webm": "webm",
    "audio/ogg": "ogg",
  };

  return extensions[mime.toLowerCase()] ?? "bin";
}

function requiredString(form: FormData, key: string): string | null {
  const value = form.get(key);

  if (typeof value !== "string") return null;

  const result = value.trim();
  return result.length > 0 ? result : null;
}

function optionalString(form: FormData, key: string): string | null {
  const value = form.get(key);

  if (typeof value !== "string") return null;

  const result = value.trim();
  return result.length > 0 ? result : null;
}

async function signMedia(
  admin: SupabaseAdmin,
  rows: Record<string, unknown>[],
): Promise<Record<string, unknown>[]> {
  const result: Record<string, unknown>[] = [];

  for (const row of rows) {
    const path = String(row.storage_path ?? "");
    if (!path) continue;

    const { data, error } = await admin.storage
      .from(BUCKET)
      .createSignedUrl(path, 3600);

    if (error || !data?.signedUrl) {
      console.error("Job Sheet media signing failed:", error);
      continue;
    }

    result.push({
      media_type: row.media_type,
      url: data.signedUrl,
      mime_type: row.mime_type,
      file_size: row.file_size,
      sort_order: row.sort_order,
    });
  }

  return result;
}

export async function handleJobSheetRequest({
  req,
  jobId,
  userId,
  supabaseAdmin,
  jsonCorsResponse,
}: HandlerParams): Promise<Response> {
  if (req.method !== "GET" && req.method !== "POST") {
    return jsonCorsResponse(
      { success: false, message: "Method not allowed" },
      405,
    );
  }

  // Verify job and its assigned parties.
  const { data: job, error: jobError } = await supabaseAdmin
    .from("jobs")
    .select(`
      id,
      employer_id,
      category,
      skill,
      scheduled_date,
      scheduled_time,
      scheduled_slots,
      latitude,
      longitude,
      location_address,
      description,
      status,
      created_at,
      updated_at,
      accepted_worker_id,
      worker_progress_status
    `)
    .eq("id", jobId)
    .maybeSingle();

  if (jobError) {
    console.error("Job Sheet job lookup failed:", jobError);
    return jsonCorsResponse(
      { success: false, message: "Unable to verify job" },
      500,
    );
  }

  if (!job) {
    return jsonCorsResponse(
      { success: false, message: "Job not found" },
      404,
    );
  }

  const isWorker = job.accepted_worker_id === userId;
  const isEmployer = job.employer_id === userId;

  if (!isWorker && !isEmployer) {
    return jsonCorsResponse(
      { success: false, message: "You are not allowed to access this Job Sheet" },
      403,
    );
  }

  // ============================================================
  // CREATE JOB SHEET
  // ============================================================

  if (req.method === "POST") {
    if (!isWorker) {
      return jsonCorsResponse(
        { success: false, message: "Only the assigned worker can submit this Job Sheet" },
        403,
      );
    }

    if (job.worker_progress_status !== "reached") {
      return jsonCorsResponse(
        { success: false, message: "You must reach the job location first" },
        409,
      );
    }

    if (!["assigned", "in_progress"].includes(String(job.status))) {
      return jsonCorsResponse(
        { success: false, message: "This job is not available for Job Sheet submission" },
        409,
      );
    }

    let form: FormData;

    try {
      form = await req.formData();
    } catch {
      return jsonCorsResponse(
        { success: false, message: "Invalid multipart form data" },
        400,
      );
    }

    const workSummary = requiredString(form, "work_summary");
    const additionalNotes = optionalString(form, "additional_notes");
    const materialsUsed = optionalString(form, "materials_used");

    if (!workSummary || workSummary.length < 5) {
      return jsonCorsResponse(
        { success: false, message: "Work summary must contain at least 5 characters" },
        400,
      );
    }

    const images = form.getAll("images").filter(
      (item): item is File => item instanceof File,
    );

    const audioValue = form.get("audio");
    const audio = audioValue instanceof File ? audioValue : null;

    if (images.length > MAX_IMAGES) {
      return jsonCorsResponse(
        { success: false, message: `Maximum ${MAX_IMAGES} images are allowed` },
        400,
      );
    }

    for (const image of images) {
      if (!IMAGE_TYPES.has(image.type.toLowerCase())) {
        return jsonCorsResponse(
          { success: false, message: `Unsupported image format: ${image.type}` },
          400,
        );
      }

      if (image.size <= 0 || image.size > MAX_IMAGE_SIZE) {
        return jsonCorsResponse(
          { success: false, message: "Each image must be 6 MB or smaller" },
          400,
        );
      }
    }

    if (audio) {
      if (!AUDIO_TYPES.has(audio.type.toLowerCase())) {
        return jsonCorsResponse(
          { success: false, message: `Unsupported audio format: ${audio.type}` },
          400,
        );
      }

      if (audio.size <= 0 || audio.size > MAX_AUDIO_SIZE) {
        return jsonCorsResponse(
          { success: false, message: "Voice recording must be 10 MB or smaller" },
          400,
        );
      }
    }

    // Get original employer attachments.
    const { data: originalMedia, error: originalMediaError } =
      await supabaseAdmin
        .from("job_media")
        .select("media_type, storage_path, mime_type, file_size, sort_order")
        .eq("job_id", jobId)
        .order("sort_order", { ascending: true });

    if (originalMediaError) {
      console.error("Original job media lookup failed:", originalMediaError);
      return jsonCorsResponse(
        { success: false, message: "Unable to load original job attachments" },
        500,
      );
    }

    const jobSnapshot = {
      id: job.id,
      employer_id: job.employer_id,
      category: job.category,
      skill: job.skill,
      scheduled_date: job.scheduled_date,
      scheduled_time: job.scheduled_time,
      scheduled_slots: job.scheduled_slots,
      latitude: job.latitude,
      longitude: job.longitude,
      location_address: job.location_address,
      description: job.description,
      status: job.status,
      created_at: job.created_at,
      updated_at: job.updated_at,
      original_media: originalMedia ?? [],
    };

    // Unique job_id constraint prevents duplicate sheets.
    const { data: sheet, error: insertError } = await supabaseAdmin
      .from("job_sheets")
      .insert({
        job_id: jobId,
        worker_id: userId,
        employer_id: job.employer_id,
        work_summary: workSummary,
        additional_notes: additionalNotes,
        materials_used: materialsUsed,
        job_snapshot: jobSnapshot,
      })
      .select("*")
      .single();

    if (insertError || !sheet) {
      if (insertError?.code === "23505") {
        return jsonCorsResponse(
          { success: false, message: "A Job Sheet already exists for this job" },
          409,
        );
      }

      console.error("Job Sheet insert failed:", insertError);
      return jsonCorsResponse(
        { success: false, message: "Failed to create Job Sheet" },
        500,
      );
    }

    const uploadedPaths: string[] = [];
    const mediaRows: Record<string, unknown>[] = [];

    try {
      // Upload images.
      for (let index = 0; index < images.length; index++) {
        const image = images[index];
        const mime = image.type.toLowerCase();
        const path =
          `${jobId}/job-sheets/${sheet.id}/images/${crypto.randomUUID()}.${getExtension(mime)}`;

        const { error } = await supabaseAdmin.storage
          .from(BUCKET)
          .upload(
            path,
            new Uint8Array(await image.arrayBuffer()),
            { contentType: mime, upsert: false },
          );

        if (error) throw error;

        uploadedPaths.push(path);

        mediaRows.push({
          job_sheet_id: sheet.id,
          media_type: "image",
          storage_path: path,
          mime_type: mime,
          file_size: image.size,
          sort_order: index,
        });
      }

      // Upload optional audio.
      if (audio) {
        const mime = audio.type.toLowerCase();
        const path =
          `${jobId}/job-sheets/${sheet.id}/audio/${crypto.randomUUID()}.${getExtension(mime)}`;

        const { error } = await supabaseAdmin.storage
          .from(BUCKET)
          .upload(
            path,
            new Uint8Array(await audio.arrayBuffer()),
            { contentType: mime, upsert: false },
          );

        if (error) throw error;

        uploadedPaths.push(path);

        mediaRows.push({
          job_sheet_id: sheet.id,
          media_type: "audio",
          storage_path: path,
          mime_type: mime,
          file_size: audio.size,
          sort_order: 0,
        });
      }

      if (mediaRows.length > 0) {
        const { error } = await supabaseAdmin
          .from("job_sheet_media")
          .insert(mediaRows);

        if (error) throw error;
      }
    } catch (error) {
      console.error("Job Sheet attachment upload failed:", error);

      if (uploadedPaths.length > 0) {
        await supabaseAdmin.storage
          .from(BUCKET)
          .remove(uploadedPaths);
      }

      await supabaseAdmin
        .from("job_sheets")
        .delete()
        .eq("id", sheet.id);

      return jsonCorsResponse(
        { success: false, message: "Failed to upload Job Sheet attachments" },
        500,
      );
    }
  }

  // ============================================================
  // FETCH JOB SHEET
  // ============================================================

  const { data: savedSheet, error: sheetError } = await supabaseAdmin
    .from("job_sheets")
    .select("*")
    .eq("job_id", jobId)
    .maybeSingle();

  if (sheetError) {
    console.error("Job Sheet fetch failed:", sheetError);
    return jsonCorsResponse(
      { success: false, message: "Unable to load Job Sheet" },
      500,
    );
  }

  if (!savedSheet) {
    return jsonCorsResponse({
      success: true,
      message: "No Job Sheet submitted yet",
      data: null,
    });
  }

  const { data: media, error: mediaError } = await supabaseAdmin
    .from("job_sheet_media")
    .select("media_type, storage_path, mime_type, file_size, sort_order")
    .eq("job_sheet_id", savedSheet.id)
    .order("sort_order", { ascending: true });

  if (mediaError) {
    console.error("Job Sheet media fetch failed:", mediaError);
    return jsonCorsResponse(
      { success: false, message: "Unable to load Job Sheet attachments" },
      500,
    );
  }

  const snapshot = (savedSheet.job_snapshot ?? {}) as Record<string, unknown>;

  const originalRows = Array.isArray(snapshot.original_media)
    ? snapshot.original_media as Record<string, unknown>[]
    : [];

  const [originalSigned, workerSigned, workerProfile] = await Promise.all([
    signMedia(supabaseAdmin, originalRows),
    signMedia(supabaseAdmin, (media ?? []) as Record<string, unknown>[]),
    supabaseAdmin
      .from("profiles")
      .select("name")
      .eq("id", savedSheet.worker_id)
      .maybeSingle(),
  ]);

  const workerMedia = workerSigned;

  return jsonCorsResponse({
    success: true,
    message: "Job Sheet fetched successfully",
    data: {
      id: savedSheet.id,
      job_id: savedSheet.job_id,
      worker_id: savedSheet.worker_id,
      employer_id: savedSheet.employer_id,
      work_summary: savedSheet.work_summary,
      additional_notes: savedSheet.additional_notes,
      materials_used: savedSheet.materials_used,
      submitted_at: savedSheet.submitted_at,
      worker_name: workerProfile.data?.name ?? "Worker",
      original_job: {
        ...snapshot,
        original_media: originalSigned,
      },
      worker_media: {
        images: workerMedia.filter((item) => item.media_type === "image"),
        audio: workerMedia.find((item) => item.media_type === "audio") ?? null,
      },
    },
  });
}