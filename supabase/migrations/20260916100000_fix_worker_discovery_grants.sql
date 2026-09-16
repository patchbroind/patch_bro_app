-- ============================================================
-- Patch Bro
-- Worker Discovery
-- Fix authenticated table privileges
-- ============================================================

-- ------------------------------------------------------------
-- WORKER PROFILES
-- ------------------------------------------------------------

grant select
on table public.worker_profiles
to authenticated;


-- ------------------------------------------------------------
-- PROFILES
-- ------------------------------------------------------------

grant select
on table public.profiles
to authenticated;


-- ------------------------------------------------------------
-- EMPLOYER PROFILES
-- ------------------------------------------------------------

grant select
on table public.employer_profiles
to authenticated;


-- ------------------------------------------------------------
-- EMPLOYER WORKER FAVOURITES
-- ------------------------------------------------------------

grant select, insert, delete
on table public.employer_worker_favourites
to authenticated;


-- ------------------------------------------------------------
-- RPC
-- ------------------------------------------------------------

grant execute
on function public.get_employer_workers()
to authenticated;