
-- Notify employer when assigned worker progress changes.

-- Create or update the notification trigger function.
CREATE OR REPLACE FUNCTION public.notify_employer_worker_progress()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN

    -- Notify only when progress status actually changes.
    IF OLD.worker_progress_status
       IS DISTINCT FROM NEW.worker_progress_status THEN

        -- Notify employer when worker starts travelling.
        IF NEW.worker_progress_status = 'on_the_way'
           AND NEW.employer_id IS NOT NULL THEN

            INSERT INTO public.notifications (
                user_id,
                type,
                title,
                message,
                data
            )
            VALUES (
                NEW.employer_id,
                'worker_on_the_way',
                'Worker Is On The Way',
                'Your assigned worker has started travelling to your location.',
                jsonb_build_object('job_id', NEW.id)
            );

        -- Notify employer when worker reaches the location.
        ELSIF NEW.worker_progress_status = 'reached'
              AND NEW.employer_id IS NOT NULL THEN

            INSERT INTO public.notifications (
                user_id,
                type,
                title,
                message,
                data
            )
            VALUES (
                NEW.employer_id,
                'worker_reached',
                'Worker Has Reached',
                'Your assigned worker has reached the job location.',
                jsonb_build_object('job_id', NEW.id)
            );

        END IF;

    END IF;

    RETURN NEW;
END;
$$;


-- Remove existing trigger if present.
DROP TRIGGER IF EXISTS
    jobs_worker_progress_notification
ON public.jobs;


-- Create notification trigger.
CREATE TRIGGER jobs_worker_progress_notification
AFTER UPDATE OF worker_progress_status
ON public.jobs
FOR EACH ROW
EXECUTE FUNCTION public.notify_employer_worker_progress();
