-- Fonction pour incrémenter le nombre de réservations d'un service
CREATE OR REPLACE FUNCTION increment_service_booking_count(service_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE services
  SET booking_count = booking_count + 1
  WHERE id = service_id;
END;
$$;

-- Politique RLS pour permettre aux utilisateurs authentifiés d'appeler la fonction
CREATE POLICY "Utilisateurs authentifiés peuvent incrémenter le nombre de réservations"
ON services
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
