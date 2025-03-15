-- Create stories table
CREATE TABLE IF NOT EXISTS stories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  professional_id UUID REFERENCES professionals(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('image', 'video')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  seen BOOLEAN DEFAULT FALSE,
  views INTEGER DEFAULT 0
);

-- Add RLS policies
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

-- Allow anyone to view stories
CREATE POLICY "Anyone can view stories" ON stories
  FOR SELECT USING (true);

-- Allow professionals to manage their own stories
CREATE POLICY "Professionals can manage their own stories" ON stories
  FOR ALL USING (auth.uid() = professional_id);

-- Function to increment story views
CREATE OR REPLACE FUNCTION increment_story_views(story_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE stories
  SET views = views + 1
  WHERE id = story_id;
END;
$$ LANGUAGE plpgsql;
