-- Vérifier les professionnels existants
SELECT id, name FROM professionals;

-- Vérifier les catégories existantes
SELECT id, name FROM service_categories;

-- Insérer les associations professionnels-catégories
INSERT INTO professional_categories (professional_id, category_id)
SELECT p.id, c.id
FROM professionals p, service_categories c
WHERE p.name = 'Marie Dubois' AND c.name = 'Massage'
ON CONFLICT (professional_id, category_id) DO NOTHING;

-- Vérifier les associations
SELECT 
    p.name as professional_name,
    c.name as category_name
FROM professionals p
JOIN professional_categories pc ON p.id = pc.professional_id
JOIN service_categories c ON c.id = pc.category_id;
