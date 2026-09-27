-- ============================================================
-- Patch Bro
-- Job Lifecycle
-- ============================================================

-- We intentionally keep the existing jobs.status column as TEXT.
-- Lifecycle transitions will be controlled through RPCs rather
-- than allowing arbitrary status updates from the Flutter client.


-- ============================================================
-- 1. Validate allowed lifecycle status values
-- ============================================================

alter table public.jobs
drop constraint if exists jobs_status_check;

alter table public.jobs
add constraint jobs_status_check
check (
  status in (
    'open',
    'assigned',
    'on_the_way',
    'arrived',
    'identity_verified',
    'job_sheet_pending',
    'job_sheet_confirmed',
    'in_progress',
    'completed',
    'cancelled',
    'expired'
  )
);


-- ============================================================
-- 2. Keep new jobs as OPEN by default
-- ============================================================

alter table public.jobs
alter column status set default 'open';


-- ============================================================
-- 3. Helpful lifecycle indexes
-- ============================================================

create index if not exists idx_jobs_status
on public.jobs(status);

create index if not exists idx_jobs_accepted_worker_id
on public.jobs(accepted_worker_id);

create index if not exists idx_jobs_status_worker
on public.jobs(status, accepted_worker_id);


-- ============================================================
-- 4. Documentation
-- ============================================================

comment on column public.jobs.status is
'Job lifecycle status. Valid values: open, assigned, on_the_way, arrived, identity_verified, job_sheet_pending, job_sheet_confirmed, in_progress, completed, cancelled, expired.';