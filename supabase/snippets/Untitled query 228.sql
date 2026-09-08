create index if not exists profiles_location_gix
on public.profiles
using gist (location);