
-- Track worker journey progress independently from job status.

alter table public.jobs
  add column if not exists worker_progress_status text
    not null default 'not_started';

alter table public.jobs
  add column if not exists worker_on_the_way_at timestamptz;

alter table public.jobs
  add column if not exists worker_reached_at timestamptz;

alter table public.jobs
  drop constraint if exists jobs_worker_progress_status_check;

alter table public.jobs
  add constraint jobs_worker_progress_status_check
  check (
    worker_progress_status in (
      'not_started',
      'on_the_way',
      'reached'
    )
  );

create index if not exists jobs_worker_progress_status_idx
  on public.jobs(worker_progress_status);