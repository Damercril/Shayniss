-- Create galleries table
CREATE TABLE IF NOT EXISTS galleries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    professional_id UUID NOT NULL REFERENCES professionals(id),
    image_url TEXT NOT NULL,
    caption TEXT,
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS galleries_professional_id_idx ON galleries(professional_id);

-- Create trigger to update updated_at
CREATE TRIGGER update_galleries_updated_at
    BEFORE UPDATE ON galleries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add RLS policies
ALTER TABLE galleries ENABLE ROW LEVEL SECURITY;

-- Anyone can view active gallery photos
CREATE POLICY "Anyone can view active gallery photos"
ON galleries FOR SELECT
TO authenticated
USING (is_active = true);

-- Professionals can manage their own gallery
CREATE POLICY "Professionals can manage their own gallery"
ON galleries FOR ALL
TO authenticated
USING (
    auth.uid() = professional_id
)
WITH CHECK (
    auth.uid() = professional_id
);
