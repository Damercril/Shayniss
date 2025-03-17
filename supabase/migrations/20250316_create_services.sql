-- Create services table
CREATE TABLE IF NOT EXISTS services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    professional_id UUID NOT NULL REFERENCES professionals(id),
    category_id UUID NOT NULL REFERENCES service_categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    duration INTEGER NOT NULL CHECK (duration > 0),
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    is_active BOOLEAN DEFAULT true,
    booking_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_services_professional_id ON services(professional_id);
CREATE INDEX IF NOT EXISTS idx_services_category_id ON services(category_id);
CREATE INDEX IF NOT EXISTS idx_services_is_active ON services(is_active);

-- Add RLS policies
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users for active services
CREATE POLICY "Anyone can view active services"
ON services FOR SELECT
TO authenticated
USING (is_active = true);

-- Allow professionals to view all their services (active and inactive)
CREATE POLICY "Professionals can view all their services"
ON services FOR SELECT
TO authenticated
USING (auth.uid() = professional_id);

-- Allow professionals to create services
CREATE POLICY "Professionals can create services"
ON services FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = professional_id);

-- Allow professionals to update their own services
CREATE POLICY "Professionals can update their own services"
ON services FOR UPDATE
TO authenticated
USING (auth.uid() = professional_id)
WITH CHECK (auth.uid() = professional_id);

-- Create trigger to update updated_at
CREATE TRIGGER update_services_updated_at
    BEFORE UPDATE ON services
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert demo services
INSERT INTO services (id, professional_id, category_id, name, description, duration, price, is_active, booking_count) VALUES
    ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', (SELECT id FROM service_categories WHERE name = 'Coiffure'), 'Coupe Femme', 'Coupe, shampoing et brushing', 90, 45.00, true, 0),
    ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', (SELECT id FROM service_categories WHERE name = 'Coiffure'), 'Coloration', 'Coloration complète avec soin', 120, 65.00, true, 0),
    ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', (SELECT id FROM service_categories WHERE name = 'Coiffure'), 'Brushing', 'Brushing et mise en forme', 45, 30.00, true, 0),
    ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', (SELECT id FROM service_categories WHERE name = 'Maquillage'), 'Maquillage Jour', 'Maquillage naturel pour la journée', 45, 35.00, true, 0);
