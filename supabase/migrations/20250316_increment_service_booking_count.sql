-- Create a function to increment the booking_count for a service
create or replace function increment_service_booking_count(service_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  update services
  set booking_count = booking_count + 1,
      updated_at = now()
  where id = service_id;
end;
$$;
