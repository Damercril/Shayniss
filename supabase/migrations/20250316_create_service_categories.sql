-- Create service_categories table
CREATE TABLE IF NOT EXISTS service_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE service_categories ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users
CREATE POLICY "Allow read access for all authenticated users"
ON service_categories FOR SELECT
TO authenticated
USING (true);

-- Insert default categories
INSERT INTO service_categories (name, icon, description) VALUES
    ('Coiffure', '💇‍♀️', 'Coupes, colorations, coiffures'),
    ('Maquillage', '💄', 'Maquillage jour et soirée'),
    ('Ongles', '💅', 'Manucure et pédicure'),
    ('Soins', '✨', 'Soins visage et corps'),
    ('Massage', '💆‍♀️', 'Massages relaxants'),
    ('Épilation', '🌸', 'Épilation visage et corps');

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_service_categories_updated_at
    BEFORE UPDATE ON service_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
