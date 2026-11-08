
-- ============================================================
-- Patch Bro
-- Add scheduled time slots to worker invitations
-- ============================================================

-- IMPORTANT:
-- We must DROP the existing function first because PostgreSQL
-- does not allow CREATE OR REPLACE to change its return type.

DROP FUNCTION IF EXISTS public.get_worker_invitations();


-- ============================================================
-- RECREATE WORKER INVITATIONS FUNCTION
-- ============================================================

CREATE FUNCTION public.get_worker_invitations()
RETURNS TABLE (
  id uuid,
  job_id uuid,
  employer_id uuid,
  worker_id uuid,
  status text,
  created_at timestamptz,
  expires_at timestamptz,
  responded_at timestamptz,

  employer_name text,

  job_category text,
  job_skill text,
  scheduled_date date,
  scheduled_time time,
  location_address text,
  description text,

  -- NEW FIELD
  scheduled_slots text[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN

  -- Expire old invitations before fetching.
  PERFORM public.expire_job_invitations();

  RETURN QUERY
  SELECT
    ji.id,
    ji.job_id,
    ji.employer_id,
    ji.worker_id,
    ji.status,
    ji.created_at,
    ji.expires_at,
    ji.responded_at,

    employer_profile.name AS employer_name,

    j.category AS job_category,
    j.skill AS job_skill,
    j.scheduled_date,
    j.scheduled_time,
    j.location_address,
    COALESCE(j.description, '') AS description,

    -- NEW FIELD
    COALESCE(j.scheduled_slots, ARRAY[]::text[]) AS scheduled_slots

  FROM public.job_invitations ji

  INNER JOIN public.jobs j
    ON j.id = ji.job_id

  INNER JOIN public.profiles employer_profile
    ON employer_profile.id = ji.employer_id

  WHERE ji.worker_id = auth.uid()

  ORDER BY ji.created_at DESC;

END;
$$;


-- ============================================================
-- FUNCTION PERMISSIONS
-- ============================================================

REVOKE ALL ON FUNCTION public.get_worker_invitations()
FROM public;

GRANT EXECUTE ON FUNCTION public.get_worker_invitations()
TO authenticated;


-- ============================================================
-- MIGRATION COMPLETE
-- ============================================================
