-- Push registration and server-backed notification preferences.
-- worker_profiles.id and employer_profiles.id both reference profiles.id.

create table if not exists public.user_device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  fcm_token text not null unique,
  platform text not null check (platform in ('android', 'ios', 'web')),
  app_flavor text not null check (app_flavor in ('worker', 'employer')),
  device_id text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists user_device_tokens_user_active_idx
  on public.user_device_tokens(user_id, is_active);

alter table public.user_device_tokens enable row level security;
create policy "Users manage own device tokens"
  on public.user_device_tokens for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
grant select, insert, update, delete on public.user_device_tokens to authenticated;

create table if not exists public.notification_preferences (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  push_notifications boolean not null default true,
  job_updates boolean not null default true,
  messages boolean not null default true,
  reminders boolean not null default true,
  offers_and_promotions boolean not null default false,
  app_announcements boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.notification_preferences enable row level security;
create policy "Users manage own notification preferences"
  on public.notification_preferences for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
grant select, insert, update on public.notification_preferences to authenticated;

-- Seed defaults without overwriting any preferences already present.
insert into public.notification_preferences(user_id)
select id from public.profiles
on conflict (user_id) do nothing;

-- Add notification table to Realtime only if it is not already published.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table public.notifications;
  end if;
end $$;

-- Preserve the existing acceptance validation and assignment transaction, then
-- insert the employer inbox record only after successful assignment.
create or replace function public.accept_job_invitation(p_invitation_id uuid)
returns public.job_invitations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invitation public.job_invitations;
  v_job public.jobs;
  v_now timestamptz := now();
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  perform public.expire_job_invitations();

  select * into v_invitation
  from public.job_invitations
  where id = p_invitation_id and worker_id = auth.uid()
  for update;
  if v_invitation.id is null then raise exception 'Invitation not found'; end if;
  if v_invitation.status <> 'pending' then
    raise exception 'This invitation is no longer available';
  end if;
  if v_invitation.expires_at <= v_now then
    update public.job_invitations set status = 'expired', responded_at = v_now
    where id = p_invitation_id;
    raise exception 'This invitation has expired';
  end if;

  select * into v_job from public.jobs where id = v_invitation.job_id for update;
  if v_job.id is null then raise exception 'Job not found'; end if;
  if v_invitation.employer_id <> v_job.employer_id then
    raise exception 'This invitation does not belong to the job owner';
  end if;
  if v_job.accepted_worker_id is not null and v_job.accepted_worker_id <> auth.uid() then
    raise exception 'Another worker has already accepted this job';
  end if;
  if lower(v_job.status) not in ('active', 'open', 'pending') then
    raise exception 'This job is no longer available';
  end if;

  update public.job_invitations set status = 'accepted', responded_at = v_now
  where id = p_invitation_id returning * into v_invitation;
  update public.jobs set accepted_worker_id = auth.uid(), accepted_at = v_now,
    status = 'assigned', updated_at = v_now where id = v_invitation.job_id;
  update public.job_invitations set status = 'cancelled', responded_at = v_now
  where job_id = v_invitation.job_id and id <> p_invitation_id and status = 'pending';

  insert into public.notifications(user_id, type, title, message, data)
  values (
    v_invitation.employer_id,
    'job_invitation_accepted',
    'Worker Accepted Your Job',
    'A worker has accepted your job invitation.',
    jsonb_build_object(
      'job_id', v_job.id,
      'invitation_id', v_invitation.id,
      'worker_id', auth.uid(),
      'job_category', v_job.category,
      'job_skill', v_job.skill
    )
  );

  return v_invitation;
end;
$$;
revoke all on function public.accept_job_invitation(uuid) from public;
grant execute on function public.accept_job_invitation(uuid) to authenticated;
