-- ============================================================
-- Patch Bro
-- Job Invitation Notifications
-- ============================================================

-- ============================================================
-- 1. CREATE NOTIFICATION WHEN A WORKER IS INVITED
-- ============================================================

create or replace function public.create_job_invitation(
  p_job_id uuid,
  p_worker_id uuid
)
returns public.job_invitations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_job public.jobs;
  v_invitation public.job_invitations;
  v_active_count integer;
begin

  -- ----------------------------------------------------------
  -- Authentication
  -- ----------------------------------------------------------

  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;


  -- ----------------------------------------------------------
  -- Expire old invitations first.
  -- ----------------------------------------------------------

  perform public.expire_job_invitations();


  -- ----------------------------------------------------------
  -- Get and lock the job.
  -- ----------------------------------------------------------

  select *
  into v_job
  from public.jobs
  where id = p_job_id
  for update;


  if v_job.id is null then
    raise exception 'Job not found';
  end if;


  -- ----------------------------------------------------------
  -- Only employer who owns the job can invite.
  -- ----------------------------------------------------------

  if v_job.employer_id <> auth.uid() then
    raise exception
      'You are not allowed to invite workers for this job';
  end if;


  -- ----------------------------------------------------------
  -- Do not allow invitations after assignment.
  -- ----------------------------------------------------------

  if v_job.accepted_worker_id is not null then
    raise exception
      'This job has already been assigned to a worker';
  end if;


  -- ----------------------------------------------------------
  -- Job must still be active.
  -- ----------------------------------------------------------

  if lower(v_job.status) not in (
    'active',
    'open',
    'pending'
  ) then
    raise exception
      'This job is no longer available for invitations';
  end if;


  -- ----------------------------------------------------------
  -- Employer cannot invite himself.
  -- ----------------------------------------------------------

  if p_worker_id = auth.uid() then
    raise exception 'You cannot invite yourself';
  end if;


  -- ----------------------------------------------------------
  -- Worker must have a worker profile.
  -- ----------------------------------------------------------

  if not exists (
    select 1
    from public.worker_profiles
    where id = p_worker_id
  ) then
    raise exception 'Worker profile not found';
  end if;


  -- ----------------------------------------------------------
  -- Duplicate active invitation.
  -- ----------------------------------------------------------

  if exists (
    select 1
    from public.job_invitations
    where job_id = p_job_id
      and worker_id = p_worker_id
      and status = 'pending'
      and expires_at > now()
  ) then
    raise exception
      'This worker already has an active invitation';
  end if;


  -- ----------------------------------------------------------
  -- Maximum 5 active invitations.
  -- ----------------------------------------------------------

  select count(*)
  into v_active_count
  from public.job_invitations
  where job_id = p_job_id
    and status = 'pending'
    and expires_at > now();


  if v_active_count >= 5 then
    raise exception
      'Maximum 5 active worker invitations are allowed for this job';
  end if;


  -- ----------------------------------------------------------
  -- Create invitation.
  -- ----------------------------------------------------------

  insert into public.job_invitations (
    job_id,
    employer_id,
    worker_id,
    status,
    created_at,
    expires_at
  )
  values (
    p_job_id,
    auth.uid(),
    p_worker_id,
    'pending',
    now(),
    now() + interval '15 minutes'
  )
  returning *
  into v_invitation;


  -- ----------------------------------------------------------
  -- Create worker notification.
  -- ----------------------------------------------------------

  insert into public.notifications (
    user_id,
    type,
    title,
    message,
    data
  )
  values (
    p_worker_id,
    'job_invitation',
    'New Job Invitation',
    'You have received a new job invitation.',
    jsonb_build_object(
      'job_id', v_job.id,
      'invitation_id', v_invitation.id,
      'employer_id', v_job.employer_id,
      'job_category', v_job.category,
      'job_skill', v_job.skill
    )
  );


  return v_invitation;


exception
  when unique_violation then
    raise exception
      'This worker already has an active invitation';
end;
$$;


-- ============================================================
-- FUNCTION PERMISSION
-- ============================================================

revoke all on function
  public.create_job_invitation(uuid, uuid)
from public;

grant execute on function
  public.create_job_invitation(uuid, uuid)
to authenticated;