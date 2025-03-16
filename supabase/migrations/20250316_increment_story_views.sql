-- Création de la procédure stockée pour incrémenter les vues d'une story
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
