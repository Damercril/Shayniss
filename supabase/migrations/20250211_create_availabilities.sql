-- Create availabilities table
CREATE TABLE availabilities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  professional_id UUID NOT NULL REFERENCES auth.users(id),
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_rule TEXT, -- Format iCal RRULE
  excluded_dates TEXT[], -- Dates exclues de la récurrence
  is_available BOOLEAN DEFAULT TRUE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Add RLS policies
ALTER TABLE availabilities ENABLE ROW LEVEL SECURITY;

-- Policy pour les professionnels : peuvent voir et modifier leurs propres disponibilités
CREATE POLICY "Professionals can manage their own availabilities"
  ON availabilities
  FOR ALL
  USING (auth.uid() = professional_id);

-- Policy pour les clients : peuvent voir les disponibilités actives
CREATE POLICY "Clients can view active availabilities"
  ON availabilities
  FOR SELECT
  USING (is_available = true);

-- Trigger pour mettre à jour updated_at
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON availabilities
  FOR EACH ROW
  EXECUTE FUNCTION trigger_set_updated_at();
