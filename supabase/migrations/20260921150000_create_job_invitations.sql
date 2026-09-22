-- ============================================================
-- Patch Bro
-- Job Invitations
-- ============================================================

-- ============================================================
-- 1. JOB ACCEPTED WORKER
-- ============================================================

alter table public.jobs
  add column if not exists accepted_worker_id uuid
    references public.worker_profiles(id)
    on delete set null;

alter table public.jobs
  add column if not exists accepted_at timestamptz;

create index if not exists jobs_accepted_worker_id_idx
  on public.jobs(accepted_worker_id);


-- ============================================================
-- 2. JOB INVITATIONS
-- ============================================================

create table if not exists public.job_invitations (
  id uuid primary key default gen_random_uuid(),

  job_id uuid not null
    references public.jobs(id)
    on delete cascade,

  employer_id uuid not null
    references public.profiles(id)
    on delete cascade,

  worker_id uuid not null
    references public.worker_profiles(id)
    on delete cascade,

  status text not null default 'pending'
    check (
      status in (
        'pending',
        'accepted',
        'rejected',
        'expired',
        'cancelled'
      )
    ),

  created_at timestamptz not null default now(),

  expires_at timestamptz not null
    default (now() + interval '15 minutes'),

  responded_at timestamptz
);


-- ============================================================
-- 3. INDEXES
-- ============================================================

create index if not exists job_invitations_job_id_idx
  on public.job_invitations(job_id);

create index if not exists job_invitations_worker_id_idx
  on public.job_invitations(worker_id);

create index if not exists job_invitations_employer_id_idx
  on public.job_invitations(employer_id);

create index if not exists job_invitations_status_idx
  on public.job_invitations(status);

create index if not exists job_invitations_expires_at_idx
  on public.job_invitations(expires_at);


-- ============================================================
-- 4. PREVENT DUPLICATE ACTIVE INVITATION
-- ============================================================

create unique index if not exists
  job_invitations_active_worker_unique_idx
on public.job_invitations(job_id, worker_id)
where status = 'pending';


-- ============================================================
-- 5. RLS
-- ============================================================

alter table public.job_invitations
enable row level security;


-- ============================================================
-- 6. DIRECT SELECT POLICIES
--
-- Inserts/updates/deletes are intentionally NOT allowed
-- directly from Flutter.
--
-- Those operations happen through SECURITY DEFINER RPCs.
-- ============================================================

drop policy if exists
  "Employers can view invitations for their jobs"
on public.job_invitations;

create policy
  "Employers can view invitations for their jobs"
on public.job_invitations
for select
to authenticated
using (
  employer_id = auth.uid()
);


drop policy if exists
  "Workers can view their invitations"
on public.job_invitations;

create policy
  "Workers can view their invitations"
on public.job_invitations
for select
to authenticated
using (
  worker_id = auth.uid()
);


-- ============================================================
-- 7. EXPIRE INVITATIONS
-- ============================================================

create or replace function public.expire_job_invitations()
returns void
language sql
security definer
set search_path = public
as $$
  update public.job_invitations
  set
    status = 'expired',
    responded_at = coalesce(responded_at, now())
  where status = 'pending'
    and expires_at <= now();
$$;


-- ============================================================
-- 8. CREATE INVITATION
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

  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;


  -- ----------------------------------------------------------
  -- Expire old invitations first.
  -- ----------------------------------------------------------

  perform public.expire_job_invitations();


  -- ----------------------------------------------------------
  -- Get job.
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
  -- Only the employer who owns the job can invite.
  -- ----------------------------------------------------------

  if v_job.employer_id <> auth.uid() then
    raise exception 'You are not allowed to invite workers for this job';
  end if;


  -- ----------------------------------------------------------
  -- Job must still be active.
  -- ----------------------------------------------------------

  if lower(v_job.status) not in (
    'active',
    'open',
    'pending'
  ) then
    raise exception 'This job is no longer available for invitations';
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
    raise exception 'This worker already has an active invitation';
  end if;


  -- ----------------------------------------------------------
  -- Count active invitations.
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


  return v_invitation;

exception
  when unique_violation then
    raise exception
      'This worker already has an active invitation';
end;
$$;


-- ============================================================
-- 9. EMPLOYER INVITATIONS FOR A JOB
-- ============================================================

create or replace function public.get_employer_job_invitations(
  p_job_id uuid
)
returns table (
  id uuid,
  job_id uuid,
  employer_id uuid,
  worker_id uuid,
  status text,
  created_at timestamptz,
  expires_at timestamptz,
  responded_at timestamptz,

  worker_name text,
  worker_phone text,
  worker_avatar_url text
)
language plpgsql
security definer
set search_path = public
as $$
begin

  perform public.expire_job_invitations();

  return query
  select
    ji.id,
    ji.job_id,
    ji.employer_id,
    ji.worker_id,
    ji.status,
    ji.created_at,
    ji.expires_at,
    ji.responded_at,

    p.name as worker_name,
    p.phone as worker_phone,
    wp.avatar_url as worker_avatar_url

  from public.job_invitations ji

  inner join public.worker_profiles wp
    on wp.id = ji.worker_id

  inner join public.profiles p
    on p.id = ji.worker_id

  where ji.job_id = p_job_id
    and ji.employer_id = auth.uid()

  order by ji.created_at desc;

end;
$$;


-- ============================================================
-- 10. WORKER INVITATIONS
-- ============================================================

create or replace function public.get_worker_invitations()
returns table (
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
  description text
)
language plpgsql
security definer
set search_path = public
as $$
begin

  perform public.expire_job_invitations();

  return query
  select
    ji.id,
    ji.job_id,
    ji.employer_id,
    ji.worker_id,
    ji.status,
    ji.created_at,
    ji.expires_at,
    ji.responded_at,

    employer_profile.name as employer_name,

    j.category as job_category,
    j.skill as job_skill,
    j.scheduled_date,
    j.scheduled_time,
    j.location_address,
    coalesce(j.description, '') as description

  from public.job_invitations ji

  inner join public.jobs j
    on j.id = ji.job_id

  inner join public.profiles employer_profile
    on employer_profile.id = ji.employer_id

  where ji.worker_id = auth.uid()

  order by ji.created_at desc;

end;
$$;


-- ============================================================
-- 11. ACCEPT INVITATION
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
begin

  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;


  perform public.expire_job_invitations();


  -- ----------------------------------------------------------
  -- Lock invitation.
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


  if v_invitation.status <> 'pending' then
    raise exception
      'This invitation is no longer available';
  end if;


  if v_invitation.expires_at <= now() then

    update public.job_invitations
    set
      status = 'expired',
      responded_at = now()
    where id = p_invitation_id;

    raise exception 'This invitation has expired';
  end if;


  -- ----------------------------------------------------------
  -- Lock job.
  -- ----------------------------------------------------------

  select *
  into v_job
  from public.jobs
  where id = v_invitation.job_id
  for update;


  if v_job.id is null then
    raise exception 'Job not found';
  end if;


  if v_job.accepted_worker_id is not null
     and v_job.accepted_worker_id <> auth.uid() then
    raise exception
      'Another worker has already accepted this job';
  end if;


  if lower(v_job.status) not in (
    'active',
    'open',
    'pending'
  ) then
    raise exception
      'This job is no longer available';
  end if;


  -- ----------------------------------------------------------
  -- Accept invitation.
  -- ----------------------------------------------------------

  update public.job_invitations
  set
    status = 'accepted',
    responded_at = now()
  where id = p_invitation_id
  returning *
  into v_invitation;


  -- ----------------------------------------------------------
  -- Store accepted worker on job.
  -- ----------------------------------------------------------

  update public.jobs
  set
    accepted_worker_id = auth.uid(),
    accepted_at = now(),
    updated_at = now()
  where id = v_invitation.job_id;


  -- ----------------------------------------------------------
  -- Cancel every other pending invitation.
  -- ----------------------------------------------------------

  update public.job_invitations
  set
    status = 'cancelled',
    responded_at = now()
  where job_id = v_invitation.job_id
    and id <> p_invitation_id
    and status = 'pending';


  return v_invitation;

end;
$$;


-- ============================================================
-- 12. REJECT INVITATION
-- ============================================================

create or replace function public.reject_job_invitation(
  p_invitation_id uuid
)
returns public.job_invitations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invitation public.job_invitations;
begin

  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;


  perform public.expire_job_invitations();


  select *
  into v_invitation
  from public.job_invitations
  where id = p_invitation_id
    and worker_id = auth.uid()
  for update;


  if v_invitation.id is null then
    raise exception 'Invitation not found';
  end if;


  if v_invitation.status <> 'pending' then
    raise exception
      'This invitation is no longer available';
  end if;


  if v_invitation.expires_at <= now() then

    update public.job_invitations
    set
      status = 'expired',
      responded_at = now()
    where id = p_invitation_id;

    raise exception 'This invitation has expired';
  end if;


  update public.job_invitations
  set
    status = 'rejected',
    responded_at = now()
  where id = p_invitation_id
  returning *
  into v_invitation;


  return v_invitation;

end;
$$;


-- ============================================================
-- 13. FUNCTION PERMISSIONS
-- ============================================================

revoke all on function public.create_job_invitation(uuid, uuid)
from public;

revoke all on function public.get_employer_job_invitations(uuid)
from public;

revoke all on function public.get_worker_invitations()
from public;

revoke all on function public.accept_job_invitation(uuid)
from public;

revoke all on function public.reject_job_invitation(uuid)
from public;

revoke all on function public.expire_job_invitations()
from public;


grant execute on function
  public.create_job_invitation(uuid, uuid)
to authenticated;

grant execute on function
  public.get_employer_job_invitations(uuid)
to authenticated;

grant execute on function
  public.get_worker_invitations()
to authenticated;

grant execute on function
  public.accept_job_invitation(uuid)
to authenticated;

grant execute on function
  public.reject_job_invitation(uuid)
to authenticated;


-- ============================================================
-- 14. REALTIME
-- ============================================================

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'job_invitations'
  ) then

    alter publication supabase_realtime
      add table public.job_invitations;

  end if;
end;
$$;