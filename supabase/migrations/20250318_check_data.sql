-- Vérifier les catégories
SELECT * FROM service_categories;

-- Vérifier les associations professionnels-catégories
SELECT 
    p.name as professional_name,
    sc.name as category_name
FROM professionals p
JOIN professional_categories pc ON p.id = pc.professional_id
JOIN service_categories sc ON sc.id = pc.category_id
WHERE p.name = 'Marie Dubois';

-- Vérifier les services
SELECT 
    p.name as professional_name,
    s.name as service_name,
    sc.name as category_name
FROM professionals p
JOIN services s ON p.id = s.professional_id
JOIN service_categories sc ON sc.id = s.category_id
WHERE p.name = 'Marie Dubois';
