-- ============================================================
-- PATCH BRO - JOBS
-- ============================================================

create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),

  employer_id uuid not null
    references public.profiles(id)
    on delete restrict,

  category text not null,
  skill text not null,

  scheduled_date date not null,
  scheduled_time time not null,

  latitude double precision not null,
  longitude double precision not null,

  location_address text not null,

  description text not null default '',

  status text not null default 'open'
    check (
      status in (
        'open',
        'assigned',
        'in_progress',
        'completed',
        'cancelled'
      )
    ),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);


-- ============================================================
-- JOB MEDIA
-- ============================================================

create table if not exists public.job_media (
  id uuid primary key default gen_random_uuid(),

  job_id uuid not null
    references public.jobs(id)
    on delete cascade,

  media_type text not null
    check (
      media_type in ('image', 'audio')
    ),

  storage_path text not null,

  mime_type text,

  file_size bigint,

  sort_order integer not null default 0,

  created_at timestamptz not null default now()
);


-- ============================================================
-- INDEXES
-- ============================================================

create index if not exists idx_jobs_employer_id
  on public.jobs(employer_id);

create index if not exists idx_jobs_status
  on public.jobs(status);

create index if not exists idx_jobs_scheduled_date
  on public.jobs(scheduled_date);

create index if not exists idx_job_media_job_id
  on public.job_media(job_id);


-- ============================================================
-- RLS
-- ============================================================

alter table public.jobs enable row level security;

alter table public.job_media enable row level security;


-- ============================================================
-- JOB POLICIES
-- ============================================================

drop policy if exists "Employers can view own jobs"
on public.jobs;

create policy "Employers can view own jobs"
on public.jobs
for select
to authenticated
using (
  employer_id = auth.uid()
);


drop policy if exists "Employers can create own jobs"
on public.jobs;

create policy "Employers can create own jobs"
on public.jobs
for insert
to authenticated
with check (
  employer_id = auth.uid()
);


drop policy if exists "Employers can update own jobs"
on public.jobs;

create policy "Employers can update own jobs"
on public.jobs
for update
to authenticated
using (
  employer_id = auth.uid()
)
with check (
  employer_id = auth.uid()
);


-- ============================================================
-- JOB MEDIA POLICIES
-- ============================================================

drop policy if exists "Employers can view own job media"
on public.job_media;

create policy "Employers can view own job media"
on public.job_media
for select
to authenticated
using (
  exists (
    select 1
    from public.jobs
    where jobs.id = job_media.job_id
    and jobs.employer_id = auth.uid()
  )
);


drop policy if exists "Employers can create own job media"
on public.job_media;

create policy "Employers can create own job media"
on public.job_media
for insert
to authenticated
with check (
  exists (
    select 1
    from public.jobs
    where jobs.id = job_media.job_id
    and jobs.employer_id = auth.uid()
  )
);


-- ============================================================
-- GRANTS
-- ============================================================

grant select, insert, update
on public.jobs
to authenticated;

grant select, insert
on public.job_media
to authenticated;


-- ============================================================
-- UPDATED AT
-- ============================================================

create or replace function public.update_jobs_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


drop trigger if exists jobs_updated_at
on public.jobs;

create trigger jobs_updated_at
before update on public.jobs
for each row
execute function public.update_jobs_updated_at();