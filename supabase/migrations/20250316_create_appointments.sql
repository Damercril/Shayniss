-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES auth.users(id),
    service_id UUID NOT NULL REFERENCES services(id),
    client_id UUID NOT NULL REFERENCES auth.users(id),
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_appointments_professional_id ON appointments(professional_id);
CREATE INDEX IF NOT EXISTS idx_appointments_client_id ON appointments(client_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date_time ON appointments(date_time);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);

-- Add RLS policies
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Allow read access to authenticated users for their own appointments (as client or professional)
CREATE POLICY "Users can view their own appointments"
ON appointments FOR SELECT
TO authenticated
USING (
    auth.uid() = client_id 
    OR 
    auth.uid() = professional_id
);

-- Allow professionals to create appointments
CREATE POLICY "Professionals can create appointments"
ON appointments FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() = professional_id
);

-- Allow professionals to update their own appointments
CREATE POLICY "Professionals can update their own appointments"
ON appointments FOR UPDATE
TO authenticated
USING (auth.uid() = professional_id)
WITH CHECK (auth.uid() = professional_id);

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert demo appointments
INSERT INTO appointments (professional_id, service_id, client_id, date_time, status) VALUES
    -- Today's appointments
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', NOW() + INTERVAL '2 hours', 'confirmed'),
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', NOW() + INTERVAL '4 hours', 'confirmed'),
    -- Tomorrow's appointments
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', NOW() + INTERVAL '1 day 2 hours', 'confirmed'),
    -- Next week's appointments
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000005', NOW() + INTERVAL '7 days', 'confirmed');
