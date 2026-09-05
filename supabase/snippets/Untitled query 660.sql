alter table public.profiles
add column if not exists location extensions.geography(Point, 4326),
add column if not exists location_address text;