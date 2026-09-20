-- ============================================================
-- Patch Bro
-- Worker Profile Permissions
-- ============================================================

-- ------------------------------------------------------------
-- TABLE ACCESS
-- ------------------------------------------------------------

grant select, insert, update
on table public.worker_profiles
to authenticated;


-- ------------------------------------------------------------
-- RLS
-- ------------------------------------------------------------

alter table public.worker_profiles
enable row level security;


-- ------------------------------------------------------------
-- WORKER: READ OWN PROFILE
-- ------------------------------------------------------------

drop policy if exists
  "Workers can view their own worker profile"
on public.worker_profiles;

create policy
  "Workers can view their own worker profile"
on public.worker_profiles
for select
to authenticated
using (
  auth.uid() = id
);


-- ------------------------------------------------------------
-- WORKER: CREATE OWN PROFILE
-- ------------------------------------------------------------

drop policy if exists
  "Workers can create their own worker profile"
on public.worker_profiles;

create policy
  "Workers can create their own worker profile"
on public.worker_profiles
for insert
to authenticated
with check (
  auth.uid() = id
);


-- ------------------------------------------------------------
-- WORKER: UPDATE OWN PROFILE
-- ------------------------------------------------------------

drop policy if exists
  "Workers can update their own worker profile"
on public.worker_profiles;

create policy
  "Workers can update their own worker profile"
on public.worker_profiles
for update
to authenticated
using (
  auth.uid() = id
)
with check (
  auth.uid() = id
);