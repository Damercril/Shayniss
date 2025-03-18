-- Vérifier les catégories existantes
SELECT * FROM service_categories;

-- Insérer les catégories manquantes si elles n'existent pas déjà
INSERT INTO service_categories (id, name, description)
VALUES 
  ('c1', 'Massage', 'Services de massage et relaxation'),
  ('c2', 'Coiffure', 'Services de coiffure et soins capillaires'),
  ('c3', 'Maquillage', 'Services de maquillage professionnel'),
  ('c4', 'Soins', 'Soins du visage et du corps'),
  ('c5', 'Cils', 'Extensions et soins des cils'),
  ('c6', 'Onglerie', 'Manucure, pédicure et nail art')
ON CONFLICT (name) DO NOTHING;

-- Vérifier les catégories après insertion
SELECT * FROM service_categories;
