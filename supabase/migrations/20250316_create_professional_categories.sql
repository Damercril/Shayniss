-- Create professional_categories table for many-to-many relationship
CREATE TABLE IF NOT EXISTS professional_categories (
    professional_id UUID NOT NULL REFERENCES professionals(id),
    category_id UUID NOT NULL REFERENCES service_categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (professional_id, category_id)
);

-- Add RLS policies
ALTER TABLE professional_categories ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users
CREATE POLICY "Anyone can view professional categories"
ON professional_categories FOR SELECT
TO authenticated
USING (true);

-- Allow professionals to manage their own categories
CREATE POLICY "Professionals can manage their own categories"
ON professional_categories FOR ALL
TO authenticated
USING (auth.uid() = professional_id)
WITH CHECK (auth.uid() = professional_id);

-- Insert demo categories for our demo professional
INSERT INTO professional_categories (professional_id, category_id)
SELECT 
    '00000000-0000-0000-0000-000000000001'::uuid as professional_id,
    id as category_id
FROM service_categories
WHERE name IN ('Coiffure', 'Maquillage');
