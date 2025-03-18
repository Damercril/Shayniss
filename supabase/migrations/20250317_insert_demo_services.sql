-- Insert demo services
INSERT INTO services (
    professional_id,
    name,
    description,
    price,
    duration_minutes,
    category,
    image_url,
    is_active
) VALUES 
-- Services for Sarah Martin
(
    (SELECT id FROM professionals WHERE email = 'sarah.martin@example.com'),
    'Coiffure Mariage',
    'Coiffure complète pour la mariée, incluant essai et accessoires',
    150.00,
    120,
    'Coiffure',
    'https://images.pexels.com/photos/3065209/pexels-photo-3065209.jpeg',
    true
),
(
    (SELECT id FROM professionals WHERE email = 'sarah.martin@example.com'),
    'Maquillage Événement',
    'Maquillage professionnel longue tenue pour vos événements spéciaux',
    85.00,
    60,
    'Maquillage',
    'https://images.pexels.com/photos/3065210/pexels-photo-3065210.jpeg',
    true
),
-- Services for Marie Dubois
(
    (SELECT id FROM professionals WHERE email = 'marie.dubois@example.com'),
    'Soin du Visage Premium',
    'Soin complet avec massage et masque personnalisé',
    95.00,
    90,
    'Soins',
    'https://images.pexels.com/photos/3738345/pexels-photo-3738345.jpeg',
    true
),
(
    (SELECT id FROM professionals WHERE email = 'marie.dubois@example.com'),
    'Massage Relaxant',
    'Massage corps complet aux huiles essentielles',
    120.00,
    75,
    'Massage',
    'https://images.pexels.com/photos/3738349/pexels-photo-3738349.jpeg',
    true
),
-- Services for Julie Bernard
(
    (SELECT id FROM professionals WHERE email = 'julie.bernard@example.com'),
    'Extensions de Cils Volume Russe',
    'Pose complète volume russe, effet spectaculaire et naturel',
    130.00,
    120,
    'Cils',
    'https://images.pexels.com/photos/3738355/pexels-photo-3738355.jpeg',
    true
),
(
    (SELECT id FROM professionals WHERE email = 'julie.bernard@example.com'),
    'Manucure Semi-permanent',
    'Pose complète avec vernis semi-permanent, design au choix',
    65.00,
    60,
    'Onglerie',
    'https://images.pexels.com/photos/3738359/pexels-photo-3738359.jpeg',
    true
),
-- Services for Sophie Lambert
(
    (SELECT id FROM professionals WHERE email = 'sophie.lambert@example.com'),
    'Coloration Complète',
    'Coloration professionnelle avec soin et coupe inclus',
    110.00,
    150,
    'Coiffure',
    'https://images.pexels.com/photos/3738365/pexels-photo-3738365.jpeg',
    true
),
(
    (SELECT id FROM professionals WHERE email = 'sophie.lambert@example.com'),
    'Balayage et Coupe',
    'Balayage personnalisé avec coupe et brushing',
    140.00,
    180,
    'Coiffure',
    'https://images.pexels.com/photos/3738369/pexels-photo-3738369.jpeg',
    true
);
