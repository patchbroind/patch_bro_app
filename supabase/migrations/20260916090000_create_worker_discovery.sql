-- ============================================================
-- Patch Bro
-- Worker Discovery
--
-- Adds worker information required by the Employer Workers
-- screen and employer favourite workers.
-- ============================================================


-- ============================================================
-- 1. WORKER PROFILE DETAILS
-- ============================================================

alter table public.worker_profiles

  add column if not exists profession text
    not null default 'Other',

  add column if not exists skills text[]
    not null default '{}',

  add column if not exists about text
    not null default '',

  add column if not exists experience_years integer
    not null default 0,

  add column if not exists jobs_completed integer
    not null default 0,

  add column if not exists response_rate integer
    not null default 0,

  add column if not exists rating numeric(2,1)
    not null default 0,

  add column if not exists review_count integer
    not null default 0,

  add column if not exists availability_days text[]
    not null default '{}',

  add column if not exists available_today boolean
    not null default false,

  add column if not exists available_tomorrow boolean
    not null default false,

  add column if not exists avatar_url text,

  add column if not exists verified boolean
    not null default false;


-- ============================================================
-- 2. VALIDATION
-- ============================================================

alter table public.worker_profiles
  drop constraint if exists worker_profiles_experience_years_check;

alter table public.worker_profiles
  add constraint worker_profiles_experience_years_check
  check (experience_years >= 0);


alter table public.worker_profiles
  drop constraint if exists worker_profiles_jobs_completed_check;

alter table public.worker_profiles
  add constraint worker_profiles_jobs_completed_check
  check (jobs_completed >= 0);


alter table public.worker_profiles
  drop constraint if exists worker_profiles_response_rate_check;

alter table public.worker_profiles
  add constraint worker_profiles_response_rate_check
  check (response_rate >= 0 and response_rate <= 100);


alter table public.worker_profiles
  drop constraint if exists worker_profiles_rating_check;

alter table public.worker_profiles
  add constraint worker_profiles_rating_check
  check (rating >= 0 and rating <= 5);


alter table public.worker_profiles
  drop constraint if exists worker_profiles_review_count_check;

alter table public.worker_profiles
  add constraint worker_profiles_review_count_check
  check (review_count >= 0);


-- ============================================================
-- 3. INDEXES
-- ============================================================

create index if not exists worker_profiles_profession_idx
  on public.worker_profiles(profession);

create index if not exists worker_profiles_rating_idx
  on public.worker_profiles(rating);

create index if not exists worker_profiles_available_today_idx
  on public.worker_profiles(available_today);


-- ============================================================
-- 4. EMPLOYER FAVOURITE WORKERS
-- ============================================================

create table if not exists public.employer_worker_favourites (
  employer_id uuid not null
    references public.employer_profiles(id)
    on delete cascade,

  worker_id uuid not null
    references public.worker_profiles(id)
    on delete cascade,

  created_at timestamptz not null default now(),

  primary key (employer_id, worker_id)
);


create index if not exists employer_worker_favourites_worker_idx
  on public.employer_worker_favourites(worker_id);


-- ============================================================
-- 5. ENABLE RLS
-- ============================================================

alter table public.employer_worker_favourites
  enable row level security;


-- ============================================================
-- 6. WORKER PROFILE READ POLICY
-- ============================================================

drop policy if exists
  "Employers can view worker profiles"
on public.worker_profiles;


create policy
  "Employers can view worker profiles"
on public.worker_profiles
for select
to authenticated
using (
  auth.uid() = id
  or exists (
    select 1
    from public.employer_profiles ep
    where ep.id = auth.uid()
  )
);


-- ============================================================
-- 7. BASIC WORKER PROFILE READ POLICY
-- ============================================================

drop policy if exists
  "Employers can view worker basic profiles"
on public.profiles;


create policy
  "Employers can view worker basic profiles"
on public.profiles
for select
to authenticated
using (
  auth.uid() = id
  or (
    exists (
      select 1
      from public.employer_profiles ep
      where ep.id = auth.uid()
    )
    and exists (
      select 1
      from public.worker_profiles wp
      where wp.id = public.profiles.id
    )
  )
);


-- ============================================================
-- 8. FAVOURITE POLICIES
-- ============================================================

drop policy if exists
  "Employers can view their favourite workers"
on public.employer_worker_favourites;


create policy
  "Employers can view their favourite workers"
on public.employer_worker_favourites
for select
to authenticated
using (
  employer_id = auth.uid()
);


drop policy if exists
  "Employers can favourite workers"
on public.employer_worker_favourites;


create policy
  "Employers can favourite workers"
on public.employer_worker_favourites
for insert
to authenticated
with check (
  employer_id = auth.uid()
);


drop policy if exists
  "Employers can unfavourite workers"
on public.employer_worker_favourites;


create policy
  "Employers can unfavourite workers"
on public.employer_worker_favourites
for delete
to authenticated
using (
  employer_id = auth.uid()
);


-- ============================================================
-- 9. WORKER DISCOVERY RPC
-- ============================================================

create or replace function public.get_employer_workers()
returns table (
  id uuid,
  name text,
  profession text,
  rating numeric,
  review_count integer,
  distance_km numeric,
  is_favourite boolean,
  is_available_today boolean,
  available_tomorrow boolean,
  skills text[],
  avatar_url text,
  about text,
  experience_years integer,
  jobs_completed integer,
  response_rate integer,
  availability_days text[],
  location text,
  phone text,
  verified boolean
)
language sql
security invoker
set search_path = public
as $$
  select
    wp.id,
    p.name,
    wp.profession,
    wp.rating,
    wp.review_count,

    case
      when employer_profile.location is not null
        and p.location is not null
      then round(
        (
          public.st_distance(
            employer_profile.location,
            p.location,
            true
          ) / 1000
        )::numeric,
        1
      )
      else 0::numeric
    end as distance_km,

    exists (
      select 1
      from public.employer_worker_favourites f
      where f.employer_id = auth.uid()
        and f.worker_id = wp.id
    ) as is_favourite,

    wp.available_today,
    wp.available_tomorrow,
    wp.skills,
    wp.avatar_url,
    wp.about,
    wp.experience_years,
    wp.jobs_completed,
    wp.response_rate,
    wp.availability_days,
    p.location_address,
    p.phone,
    wp.verified

  from public.worker_profiles wp

  inner join public.profiles p
    on p.id = wp.id

  left join public.profiles employer_profile
    on employer_profile.id = auth.uid()

  where exists (
    select 1
    from public.employer_profiles ep
    where ep.id = auth.uid()
  )

  order by
    wp.available_today desc,
    wp.rating desc,
    distance_km asc,
    p.name asc;
$$;


-- ============================================================
-- 10. GRANT RPC ACCESS
-- ============================================================

grant execute
on function public.get_employer_workers()
to authenticated;