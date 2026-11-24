-- Deliver every persisted inbox notification to the user's active FCM devices.
-- Configure these database settings in Supabase before relying on push delivery:
--   app.settings.supabase_url
--   app.settings.push_webhook_secret (must match PUSH_WEBHOOK_SECRET)
-- Supply the values from the Dashboard SQL editor as:
--   alter database postgres set app.settings.supabase_url = 'https://<project-ref>.supabase.co';
--   alter database postgres set app.settings.push_webhook_secret = '<same value as the Edge Function secret>';
-- Then restart the database for ALTER DATABASE settings to take effect.
-- The trigger runs after commit through pg_net so notification writes remain
-- independent of the Edge Function's response time.

create extension if not exists pg_net with schema extensions;

create or replace function public.deliver_notification_push()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_supabase_url text := current_setting('app.settings.supabase_url', true);
  v_webhook_secret text := current_setting('app.settings.push_webhook_secret', true);
begin
  if coalesce(v_supabase_url, '') = ''
     or coalesce(v_webhook_secret, '') = '' then
    raise warning 'Push delivery settings are missing; notification % remains in inbox only.', new.id;
    return new;
  end if;

  perform net.http_post(
    url := rtrim(v_supabase_url, '/') || '/functions/v1/push-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', v_webhook_secret
    ),
    body := jsonb_build_object('record', to_jsonb(new))
  );

  return new;
end;
$$;

drop trigger if exists notifications_deliver_push on public.notifications;

create trigger notifications_deliver_push
  after insert on public.notifications
  for each row
  execute function public.deliver_notification_push();
