-- Step 1: Create professionals table and insert data
CREATE TABLE IF NOT EXISTS professionals (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(100),
    description TEXT,
    profile_picture_url TEXT,
    cover_picture_url TEXT,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    status VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_professionals_updated_at
    BEFORE UPDATE ON professionals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert demo professional
INSERT INTO professionals (
    id, 
    first_name,
    last_name,
    email,
    phone,
    address,
    city,
    description,
    profile_picture_url,
    is_available,
    status
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Sarah',
    'Martin',
    'sarah.martin@example.com',
    '+33612345678',
    '123 Rue de la Beauté',
    'Paris',
    'Coiffeuse et maquilleuse professionnelle avec plus de 10 ans d''expérience.',
    'https://picsum.photos/id/64/400/400',
    true,
    'active'
);

-- Step 2: Add RLS policies
ALTER TABLE professionals ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users for active professionals
CREATE POLICY "Anyone can view active professionals"
ON professionals FOR SELECT
TO authenticated
USING (is_available = true);

-- Allow professionals to view and update their own profile
CREATE POLICY "Professionals can manage their own profile"
ON professionals FOR ALL
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
