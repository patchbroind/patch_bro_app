alter table public.jobs
  add column if not exists scheduled_slots text[] not null default '{}';

create or replace function public.update_employer_job_scheduled_slots(
  p_job_id uuid,
  p_scheduled_slots text[]
)
returns table (scheduled_slots text[])
language plpgsql
security definer
set search_path = public
as $$
declare
  saved_slots text[];
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if p_scheduled_slots is null
    or cardinality(p_scheduled_slots) not between 1 and 4
    or cardinality(p_scheduled_slots) <> (
      select count(distinct slot_id)
      from unnest(p_scheduled_slots) as slots(slot_id)
    )
    or exists (
      select 1
      from unnest(p_scheduled_slots) as slots(slot_id)
      where slot_id not in (
        'morning_1',
        'morning_2',
        'afternoon_1',
        'afternoon_2'
      )
    )
  then
    raise exception 'Invalid scheduled time slots';
  end if;

  update public.jobs as job
  set scheduled_slots = p_scheduled_slots,
      updated_at = now()
  where job.id = p_job_id
    and job.employer_id = auth.uid()
  returning job.scheduled_slots into saved_slots;

  if not found then
    raise exception 'Job not found or not owned by the authenticated employer';
  end if;

  return query select saved_slots;
end;
$$;

create or replace function public.get_employer_job_scheduled_slots(
  p_job_ids uuid[]
)
returns table (job_id uuid, scheduled_slots text[])
language sql
stable
security definer
set search_path = public
as $$
  select job.id, job.scheduled_slots
  from public.jobs as job
  where job.employer_id = auth.uid()
    and job.id = any(p_job_ids);
$$;

revoke all on function public.update_employer_job_scheduled_slots(uuid, text[])
  from public;
grant execute on function public.update_employer_job_scheduled_slots(uuid, text[])
  to authenticated;

revoke all on function public.get_employer_job_scheduled_slots(uuid[])
  from public;
grant execute on function public.get_employer_job_scheduled_slots(uuid[])
  to authenticated;
