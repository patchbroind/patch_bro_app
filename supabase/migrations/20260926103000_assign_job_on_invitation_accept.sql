-- ============================================================
-- Patch Bro
-- Assign Job When Worker Accepts Invitation
-- ============================================================

-- ============================================================
-- 1. ACCEPT JOB INVITATION
-- ============================================================

create or replace function public.accept_job_invitation(
  p_invitation_id uuid
)
returns public.job_invitations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invitation public.job_invitations;
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
  -- Expire old invitations first.
  -- ----------------------------------------------------------

  perform public.expire_job_invitations();


  -- ----------------------------------------------------------
  -- Lock the invitation.
  --
  -- Only the worker who received the invitation can accept it.
  -- ----------------------------------------------------------

  select *
  into v_invitation
  from public.job_invitations
  where id = p_invitation_id
    and worker_id = auth.uid()
  for update;


  if v_invitation.id is null then
    raise exception 'Invitation not found';
  end if;


  -- ----------------------------------------------------------
  -- Invitation must still be pending.
  -- ----------------------------------------------------------

  if v_invitation.status <> 'pending' then
    raise exception
      'This invitation is no longer available';
  end if;


  -- ----------------------------------------------------------
  -- Invitation must not be expired.
  -- ----------------------------------------------------------

  if v_invitation.expires_at <= v_now then

    update public.job_invitations
    set
      status = 'expired',
      responded_at = v_now
    where id = p_invitation_id;

    raise exception 'This invitation has expired';
  end if;


  -- ----------------------------------------------------------
  -- Lock the job.
  --
  -- This is important for concurrency:
  -- two workers cannot accept the same job at the same time.
  -- ----------------------------------------------------------

  select *
  into v_job
  from public.jobs
  where id = v_invitation.job_id
  for update;


  if v_job.id is null then
    raise exception 'Job not found';
  end if;


  -- ----------------------------------------------------------
  -- Make sure the invitation belongs to the job owner.
  -- ----------------------------------------------------------

  if v_invitation.employer_id <> v_job.employer_id then
    raise exception
      'This invitation does not belong to the job owner';
  end if;


  -- ----------------------------------------------------------
  -- Prevent another worker from accepting the job.
  -- ----------------------------------------------------------

  if v_job.accepted_worker_id is not null
     and v_job.accepted_worker_id <> auth.uid() then

    raise exception
      'Another worker has already accepted this job';
  end if;


  -- ----------------------------------------------------------
  -- Job must still be available for acceptance.
  --
  -- "open" is the current job creation status.
  -- "active" and "pending" are retained here for compatibility
  -- with any older data/function behavior.
  -- ----------------------------------------------------------

  if lower(v_job.status) not in (
    'active',
    'open',
    'pending'
  ) then

    raise exception
      'This job is no longer available';
  end if;


  -- ----------------------------------------------------------
  -- Accept the invitation.
  -- ----------------------------------------------------------

  update public.job_invitations
  set
    status = 'accepted',
    responded_at = v_now
  where id = p_invitation_id
  returning *
  into v_invitation;


  -- ----------------------------------------------------------
  -- Assign the worker to the job.
  --
  -- IMPORTANT:
  -- The job now moves from OPEN → ASSIGNED.
  -- ----------------------------------------------------------

  update public.jobs
  set
    accepted_worker_id = auth.uid(),
    accepted_at = v_now,
    status = 'assigned',
    updated_at = v_now
  where id = v_invitation.job_id;


  -- ----------------------------------------------------------
  -- Cancel every other pending invitation.
  --
  -- The accepted worker is now the only assigned worker.
  -- ----------------------------------------------------------

  update public.job_invitations
  set
    status = 'cancelled',
    responded_at = v_now
  where job_id = v_invitation.job_id
    and id <> p_invitation_id
    and status = 'pending';


  -- ----------------------------------------------------------
  -- Return the accepted invitation.
  -- ----------------------------------------------------------

  return v_invitation;

end;
$$;


-- ============================================================
-- 2. FUNCTION PERMISSIONS
-- ============================================================

revoke all on function public.accept_job_invitation(uuid)
from public;


grant execute on function public.accept_job_invitation(uuid)
to authenticated;