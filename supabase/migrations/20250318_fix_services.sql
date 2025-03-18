-- Vérifier les services existants
SELECT 
    s.id,
    s.name as service_name,
    p.name as professional_name,
    c.name as category_name
FROM services s
JOIN professionals p ON s.professional_id = p.id
JOIN service_categories c ON s.category_id = c.id;

-- Insérer les services pour Marie Dubois
INSERT INTO services (id, name, description, price, duration, professional_id, category_id)
SELECT 
    's1',
    'Massage Relaxant',
    'Un massage relaxant pour soulager le stress et les tensions',
    75.00,
    60,
    p.id,
    c.id
FROM professionals p, service_categories c
WHERE p.name = 'Marie Dubois' AND c.name = 'Massage'
ON CONFLICT (id) DO NOTHING;

-- Vérifier les services après insertion
SELECT 
    s.id,
    s.name as service_name,
    p.name as professional_name,
    c.name as category_name,
    s.price,
    s.duration
FROM services s
JOIN professionals p ON s.professional_id = p.id
JOIN service_categories c ON s.category_id = c.id;
