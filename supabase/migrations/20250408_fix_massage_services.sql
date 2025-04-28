-- Vérifier les catégories existantes et leurs IDs
SELECT id, name FROM service_categories;

-- Vérifier les professionnels disponibles
SELECT id, name, email, is_available FROM professionals;

-- Vérifier les services existants et leurs catégories
SELECT 
    s.id,
    s.name as service_name,
    p.name as professional_name,
    c.name as category_name,
    s.price,
    s.duration,
    p.is_available
FROM services s
JOIN professionals p ON s.professional_id = p.id
JOIN service_categories c ON s.category_id = c.id;

-- Récupérer l'ID de la catégorie Massage
DO $$
DECLARE
    massage_category_id UUID;
    marie_id UUID;
BEGIN
    -- Récupérer l'ID de la catégorie Massage
    SELECT id INTO massage_category_id FROM service_categories WHERE name = 'Massage';
    
    -- Récupérer l'ID de Marie Dubois
    SELECT id INTO marie_id FROM professionals WHERE name = 'Marie Dubois';
    
    -- Afficher les IDs pour vérification
    RAISE NOTICE 'Massage category ID: %', massage_category_id;
    RAISE NOTICE 'Marie Dubois ID: %', marie_id;
    
    -- S'assurer que Marie Dubois est disponible
    UPDATE professionals SET is_available = true WHERE id = marie_id;
    
    -- Vérifier si un service de massage existe déjà pour Marie
    IF NOT EXISTS (
        SELECT 1 FROM services 
        WHERE professional_id = marie_id AND category_id = massage_category_id
    ) THEN
        -- Ajouter un service de massage pour Marie Dubois
        INSERT INTO services (
            name, 
            description, 
            price, 
            duration, 
            professional_id, 
            category_id
        ) VALUES (
            'Massage Relaxant Premium',
            'Un massage relaxant profond pour soulager le stress et les tensions musculaires',
            95.00,
            75,
            marie_id,
            massage_category_id
        );
        
        RAISE NOTICE 'Service de massage ajouté pour Marie Dubois';
    ELSE
        RAISE NOTICE 'Un service de massage existe déjà pour Marie Dubois';
    END IF;
    
    -- Ajouter un deuxième prestataire de massage (Sophie Laurent)
    IF NOT EXISTS (SELECT 1 FROM professionals WHERE name = 'Sophie Laurent') THEN
        INSERT INTO professionals (
            name,
            email,
            phone,
            bio,
            profile_image_url,
            rating,
            is_available
        ) VALUES (
            'Sophie Laurent',
            'sophie.laurent@example.com',
            '+33612345678',
            'Spécialiste en massages thérapeutiques avec 8 ans d''expérience',
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
            4.8,
            true
        );
        
        -- Récupérer l'ID de Sophie Laurent
        DECLARE sophie_id UUID;
        SELECT id INTO sophie_id FROM professionals WHERE name = 'Sophie Laurent';
        
        -- Ajouter des services de massage pour Sophie
        INSERT INTO services (
            name, 
            description, 
            price, 
            duration, 
            professional_id, 
            category_id
        ) VALUES (
            'Massage Suédois',
            'Massage classique pour détendre les muscles et améliorer la circulation',
            85.00,
            60,
            sophie_id,
            massage_category_id
        ), (
            'Massage aux Pierres Chaudes',
            'Massage relaxant utilisant des pierres chaudes pour soulager les tensions profondes',
            110.00,
            90,
            sophie_id,
            massage_category_id
        );
        
        RAISE NOTICE 'Prestataire Sophie Laurent ajoutée avec 2 services de massage';
    END IF;
END $$;

-- Vérifier les services de massage après modifications
SELECT 
    s.id,
    s.name as service_name,
    p.name as professional_name,
    c.name as category_name,
    s.price,
    s.duration,
    p.is_available
FROM services s
JOIN professionals p ON s.professional_id = p.id
JOIN service_categories c ON s.category_id = c.id
WHERE c.name = 'Massage';
