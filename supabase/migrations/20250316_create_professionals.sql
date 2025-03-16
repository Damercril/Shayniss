-- Create professionals table
CREATE TABLE IF NOT EXISTS professionals (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    bio TEXT,
    profile_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE professionals ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users for active professionals
CREATE POLICY "Anyone can view active professionals"
ON professionals FOR SELECT
TO authenticated
USING (is_active = true);

-- Allow professionals to view and update their own profile
CREATE POLICY "Professionals can manage their own profile"
ON professionals FOR ALL
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create trigger to update updated_at
CREATE TRIGGER update_professionals_updated_at
    BEFORE UPDATE ON professionals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert demo professional
INSERT INTO professionals (id, name, email, phone, bio, is_active) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Sarah Martin', 'sarah.martin@example.com', '+33612345678', 'Coiffeuse et maquilleuse professionnelle avec plus de 10 ans d''expérience.', true);
