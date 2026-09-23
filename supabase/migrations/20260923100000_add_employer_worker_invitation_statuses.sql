-- ============================================================
-- Patch Bro
-- Employer Worker Invitation Statuses
-- ============================================================
--
-- Returns the current invitation status for one worker
-- across the authenticated employer's jobs.
--
-- This is intentionally NOT a worker-wide "invited" flag.
--
-- The relationship remains:
--
--     employer + worker + job
--
-- ============================================================

create or replace function
  public.get_employer_worker_invitation_statuses(
    p_worker_id uuid
  )
returns table (
  id uuid,
  job_id uuid,
  employer_id uuid,
  worker_id uuid,
  status text,
  created_at timestamptz,
  expires_at timestamptz,
  responded_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
begin

  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  -- Expire old pending invitations first.
  perform public.expire_job_invitations();

  return query
  select distinct on (ji.job_id)
    ji.id,
    ji.job_id,
    ji.employer_id,
    ji.worker_id,
    ji.status,
    ji.created_at,
    ji.expires_at,
    ji.responded_at

  from public.job_invitations ji

  where ji.employer_id = auth.uid()
    and ji.worker_id = p_worker_id
    and ji.status in (
      'pending',
      'accepted'
    )

  order by
    ji.job_id,
    ji.created_at desc;

end;
$$;


-- ============================================================
-- FUNCTION PERMISSIONS
-- ============================================================

revoke all on function
  public.get_employer_worker_invitation_statuses(uuid)
from public;

grant execute on function
  public.get_employer_worker_invitation_statuses(uuid)
to authenticated;