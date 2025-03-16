-- Create stories table
CREATE TABLE IF NOT EXISTS stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  professional_id UUID NOT NULL REFERENCES professionals(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('image', 'video')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  seen BOOLEAN DEFAULT FALSE,
  views INTEGER DEFAULT 0,
  thumbnail_url TEXT,
  CONSTRAINT valid_expires_at CHECK (expires_at > created_at)
);

-- Create indexes for better performance
CREATE INDEX stories_professional_id_idx ON stories(professional_id);
CREATE INDEX stories_expires_at_idx ON stories(expires_at);

-- Enable Row Level Security
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view stories"
  ON stories FOR SELECT
  USING (true);

CREATE POLICY "Professionals can create their own stories"
  ON stories FOR INSERT
  TO authenticated
  WITH CHECK (professional_id = auth.uid());

CREATE POLICY "Professionals can update their own stories"
  ON stories FOR UPDATE
  TO authenticated
  USING (professional_id = auth.uid());

CREATE POLICY "Professionals can delete their own stories"
  ON stories FOR DELETE
  TO authenticated
  USING (professional_id = auth.uid());

-- Create function to increment views
CREATE OR REPLACE FUNCTION increment_story_views(story_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE stories
  SET views = views + 1
  WHERE id = story_id;
END;
$$;
