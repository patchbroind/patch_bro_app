-- ============================================================
-- Patch Bro
-- Profile Tables
-- ============================================================

-- ============================================================
-- 1. Profiles
-- ============================================================

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,

  name text not null,

  phone text not null,

  address_1 text not null,

  address_2 text,

  pin_code text not null,

  state text not null,

  created_at timestamptz not null default now(),

  updated_at timestamptz not null default now()
);


-- ============================================================
-- 2. Worker Profiles
-- ============================================================

create table public.worker_profiles (
  id uuid primary key references public.profiles(id) on delete cascade,

  created_at timestamptz not null default now(),

  updated_at timestamptz not null default now()
);


-- ============================================================
-- 3. Employer Profiles
-- ============================================================

create table public.employer_profiles (
  id uuid primary key references public.profiles(id) on delete cascade,

  created_at timestamptz not null default now(),

  updated_at timestamptz not null default now()
);


-- ============================================================
-- 4. Indexes
-- ============================================================

create index profiles_phone_idx
  on public.profiles(phone);

create index worker_profiles_id_idx
  on public.worker_profiles(id);

create index employer_profiles_id_idx
  on public.employer_profiles(id);


-- ============================================================
-- 5. Row Level Security
-- ============================================================

alter table public.profiles enable row level security;

alter table public.worker_profiles enable row level security;

alter table public.employer_profiles enable row level security;


-- ============================================================
-- 6. Profiles Policies
-- ============================================================

create policy "Users can view their own profile"
on public.profiles
for select
to authenticated
using (
  auth.uid() = id
);


create policy "Users can insert their own profile"
on public.profiles
for insert
to authenticated
with check (
  auth.uid() = id
);


create policy "Users can update their own profile"
on public.profiles
for update
to authenticated
using (
  auth.uid() = id
)
with check (
  auth.uid() = id
);


-- ============================================================
-- 7. Worker Profile Policies
-- ============================================================

create policy "Users can view their own worker profile"
on public.worker_profiles
for select
to authenticated
using (
  auth.uid() = id
);


create policy "Users can insert their own worker profile"
on public.worker_profiles
for insert
to authenticated
with check (
  auth.uid() = id
);


create policy "Users can update their own worker profile"
on public.worker_profiles
for update
to authenticated
using (
  auth.uid() = id
)
with check (
  auth.uid() = id
);


-- ============================================================
-- 8. Employer Profile Policies
-- ============================================================

create policy "Users can view their own employer profile"
on public.employer_profiles
for select
to authenticated
using (
  auth.uid() = id
);


create policy "Users can insert their own employer profile"
on public.employer_profiles
for insert
to authenticated
with check (
  auth.uid() = id
);


create policy "Users can update their own employer profile"
on public.employer_profiles
for update
to authenticated
using (
  auth.uid() = id
)
with check (
  auth.uid() = id
);


-- ============================================================
-- 9. Updated At Function
-- ============================================================

create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


-- ============================================================
-- 10. Updated At Triggers
-- ============================================================

create trigger update_profiles_updated_at
before update on public.profiles
for each row
execute function public.update_updated_at_column();


create trigger update_worker_profiles_updated_at
before update on public.worker_profiles
for each row
execute function public.update_updated_at_column();


create trigger update_employer_profiles_updated_at
before update on public.employer_profiles
for each row
execute function public.update_updated_at_column();