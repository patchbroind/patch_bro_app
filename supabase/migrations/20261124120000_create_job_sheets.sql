
-- ============================================================
-- PatchBro: Job Sheets
-- One submitted Job Sheet per job.
-- ============================================================

create table if not exists public.job_sheets (
  id uuid primary key default gen_random_uuid(),

  job_id uuid not null
    references public.jobs(id) on delete cascade,

  worker_id uuid not null
    references public.worker_profiles(id) on delete restrict,

  employer_id uuid not null
    references public.employer_profiles(id) on delete restrict,

  work_summary text not null,
  additional_notes text,
  materials_used text,

  -- Original job details and original employer media paths
  -- are preserved when the worker submits the sheet.
  job_snapshot jsonb not null default '{}'::jsonb,

  submitted_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint job_sheets_one_per_job unique (job_id),
  constraint job_sheets_summary_not_empty
    check (length(trim(work_summary)) > 0)
);

create table if not exists public.job_sheet_media (
  id uuid primary key default gen_random_uuid(),

  job_sheet_id uuid not null
    references public.job_sheets(id) on delete cascade,

  media_type text not null
    check (media_type in ('image', 'audio')),

  storage_path text not null unique,
  mime_type text not null,
  file_size bigint not null check (file_size > 0),
  sort_order integer not null default 0,

  created_at timestamptz not null default now()
);

-- A Job Sheet can have multiple images, but only one audio recording.
create unique index if not exists
  job_sheet_media_one_audio_per_sheet
on public.job_sheet_media(job_sheet_id)
where media_type = 'audio';

create index if not exists job_sheets_worker_id_idx
  on public.job_sheets(worker_id);

create index if not exists job_sheets_employer_id_idx
  on public.job_sheets(employer_id);

create index if not exists job_sheet_media_sheet_id_idx
  on public.job_sheet_media(job_sheet_id);

-- Keep updated_at consistent with the rest of the project.
drop trigger if exists update_job_sheets_updated_at
  on public.job_sheets;

create trigger update_job_sheets_updated_at
before update on public.job_sheets
for each row
execute function public.update_updated_at_column();

-- The Edge Function uses the service role and performs
-- ownership checks before every read/write.
alter table public.job_sheets enable row level security;
alter table public.job_sheet_media enable row level security;

revoke all on public.job_sheets from anon, authenticated;
revoke all on public.job_sheet_media from anon, authenticated;

grant select, insert, update, delete
  on public.job_sheets to service_role;

grant select, insert, update, delete
  on public.job_sheet_media to service_role;