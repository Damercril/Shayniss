-- Create service_images table
CREATE TABLE IF NOT EXISTS service_images (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    category VARCHAR(255) NOT NULL,
    subcategory VARCHAR(255),
    url TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE service_images ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users
CREATE POLICY "Allow read access for all authenticated users"
ON service_images FOR SELECT
TO authenticated
USING (true);

-- Insert demo images
INSERT INTO service_images (category, subcategory, url, description) VALUES
    -- Coiffure
    ('coiffure', 'salon', 'https://picsum.photos/id/64/800/600', 'Salon de coiffure'),
    ('coiffure', 'style', 'https://picsum.photos/id/65/800/600', 'Style moderne'),
    ('coiffure', 'modern', 'https://picsum.photos/id/66/800/600', 'Coiffure moderne'),
    ('coiffure', 'classic', 'https://picsum.photos/id/67/800/600', 'Coiffure classique'),
    ('coiffure', 'trendy', 'https://picsum.photos/id/68/800/600', 'Coiffure tendance'),
    -- Coupe
    ('coupe', 'court', 'https://picsum.photos/id/69/800/600', 'Coupe courte'),
    ('coupe', 'moyen', 'https://picsum.photos/id/70/800/600', 'Coupe moyenne'),
    ('coupe', 'long', 'https://picsum.photos/id/71/800/600', 'Coupe longue'),
    -- Coloration
    ('coloration', 'blonde', 'https://picsum.photos/id/72/800/600', 'Coloration blonde'),
    ('coloration', 'brune', 'https://picsum.photos/id/73/800/600', 'Coloration brune'),
    ('coloration', 'rouge', 'https://picsum.photos/id/74/800/600', 'Coloration rouge'),
    -- Soin
    ('soin', 'traitement', 'https://picsum.photos/id/75/800/600', 'Traitement capillaire'),
    ('soin', 'masque', 'https://picsum.photos/id/76/800/600', 'Masque capillaire'),
    ('soin', 'huile', 'https://picsum.photos/id/77/800/600', 'Huile capillaire');

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_service_images_updated_at
    BEFORE UPDATE ON service_images
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
