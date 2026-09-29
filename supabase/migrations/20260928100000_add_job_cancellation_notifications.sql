-- ============================================================
-- Patch Bro
-- Job Cancellation + Worker Notifications
-- ============================================================


-- ============================================================
-- 1. NOTIFICATIONS TABLE
-- ============================================================

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references public.profiles(id)
    on delete cascade,

  type text not null,

  title text not null,

  message text not null,

  data jsonb not null default '{}'::jsonb,

  read_at timestamptz,

  created_at timestamptz not null default now()
);


-- ============================================================
-- 2. INDEXES
-- ============================================================

create index if not exists idx_notifications_user_id
on public.notifications(user_id);

create index if not exists idx_notifications_user_created_at
on public.notifications(user_id, created_at desc);

create index if not exists idx_notifications_unread
on public.notifications(user_id, read_at);


-- ============================================================
-- 3. ROW LEVEL SECURITY
-- ============================================================

alter table public.notifications enable row level security;


drop policy if exists "Users can view own notifications"
on public.notifications;

create policy "Users can view own notifications"
on public.notifications
for select
to authenticated
using (
  user_id = auth.uid()
);


drop policy if exists "Users can update own notifications"
on public.notifications;

create policy "Users can update own notifications"
on public.notifications
for update
to authenticated
using (
  user_id = auth.uid()
)
with check (
  user_id = auth.uid()
);


-- ============================================================
-- 4. GRANTS
-- ============================================================

grant select, update
on public.notifications
to authenticated;


-- ============================================================
-- 5. CANCEL JOB FUNCTION
-- ============================================================

create or replace function public.cancel_job(
  p_job_id uuid
)
returns public.jobs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.jobs;
  v_now timestamptz := now();

begin

  -- ----------------------------------------------------------
  -- Authentication
  -- ----------------------------------------------------------

  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;


  -- ----------------------------------------------------------
  -- Find and lock the job.
  --
  -- Only the employer who owns the job can cancel it.
  -- FOR UPDATE prevents concurrent lifecycle operations
  -- from racing with the cancellation.
  -- ----------------------------------------------------------

  select *
  into v_job
  from public.jobs
  where id = p_job_id
    and employer_id = auth.uid()
  for update;


  if v_job.id is null then
    raise exception 'Job not found';
  end if;


  -- ----------------------------------------------------------
  -- Completed jobs cannot be cancelled.
  -- ----------------------------------------------------------

  if lower(v_job.status::text) = 'completed' then
    raise exception 'Completed jobs cannot be cancelled';
  end if;


  -- ----------------------------------------------------------
  -- Prevent cancelling an already cancelled job.
  -- ----------------------------------------------------------

  if lower(v_job.status::text) = 'cancelled' then
    raise exception 'Job is already cancelled';
  end if;


  -- ----------------------------------------------------------
  -- Cancel the job.
  -- ----------------------------------------------------------

  update public.jobs
  set
    status = 'cancelled',
    updated_at = v_now
  where id = p_job_id
  returning *
  into v_job;


  -- ----------------------------------------------------------
  -- Create notification for the assigned worker.
  --
  -- accepted_worker_id is the worker who accepted the job.
  -- If nobody has accepted the job, no worker notification
  -- is created.
  -- ----------------------------------------------------------

  if v_job.accepted_worker_id is not null then

    insert into public.notifications (
      user_id,
      type,
      title,
      message,
      data
    )
    values (
      v_job.accepted_worker_id,
      'job_cancelled',
      'Job Cancelled',
      'The employer has cancelled a job assigned to you.',
      jsonb_build_object(
        'job_id', v_job.id,
        'job_category', v_job.category,
        'job_skill', v_job.skill
      )
    );

  end if;


  -- ----------------------------------------------------------
  -- Return the updated job.
  -- ----------------------------------------------------------

  return v_job;

end;
$$;


-- ============================================================
-- 6. FUNCTION PERMISSIONS
-- ============================================================

revoke all on function public.cancel_job(uuid)
from public;

grant execute on function public.cancel_job(uuid)
to authenticated;


-- ============================================================
-- 7. ENABLE REALTIME FOR NOTIFICATIONS
-- ============================================================

alter publication supabase_realtime
add table public.notifications;