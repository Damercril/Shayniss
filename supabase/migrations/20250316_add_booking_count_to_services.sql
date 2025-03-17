-- Add booking_count column to services table
alter table services
add column if not exists booking_count integer not null default 0;

-- Add index for faster sorting by booking_count
create index if not exists idx_services_booking_count on services(booking_count desc);

-- Update RLS policies to allow reading booking_count
create policy "Anyone can read services booking_count"
on services for select
to public
using (true);

-- Only service owner can increment booking_count through RPC
create policy "Only service owner can increment booking_count"
on services for update
to authenticated
using (
  professional_id = auth.uid()
)
with check (
  professional_id = auth.uid()
);
