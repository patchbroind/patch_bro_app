-- ============================================================
-- Patch Bro
-- Worker Discovery
-- Exclude Current Employer From Worker Results
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

  -- ==========================================================
  -- IMPORTANT
  --
  -- An account can have BOTH:
  --   employer_profiles
  --   worker_profiles
  --
  -- Therefore we must exclude the current employer by USER ID,
  -- not by phone number.
  -- ==========================================================

  and wp.id <> auth.uid()

  order by
    wp.available_today desc,
    wp.rating desc,
    distance_km asc,
    p.name asc;
$$;


-- ============================================================
-- Ensure authenticated users can execute the RPC
-- ============================================================

grant execute
on function public.get_employer_workers()
to authenticated;