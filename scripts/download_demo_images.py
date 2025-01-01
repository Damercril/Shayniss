import os
import requests
import shutil

# Créer le dossier des services s'il n'existe pas
services_dir = '../assets/images/services'
os.makedirs(services_dir, exist_ok=True)

# Liste des images de démonstration (Unsplash)
demo_images = {
    'coiffure': [
        'https://images.unsplash.com/photo-1560869713-da86a9ec0744',  # Coiffure 1
        'https://images.unsplash.com/photo-1562322140-8baeececf3df',  # Coiffure 2
        'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1',  # Coiffure 3
        'https://images.unsplash.com/photo-1605497788044-5a32c7078486',  # Coiffure 4
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e',  # Coiffure 5
    ],
    'coupe': [
        'https://images.unsplash.com/photo-1622287162716-f311baa1a2b8',  # Coupe 1
        'https://images.unsplash.com/photo-1634449571010-02389ed0f9b0',  # Coupe 2
        'https://images.unsplash.com/photo-1599351431202-1e0f0137899a',  # Coupe 3
    ],
    'coloration': [
        'https://images.unsplash.com/photo-1617391765934-f7ac7aa648bc',  # Coloration 1
        'https://images.unsplash.com/photo-1626015365107-476dee3904a6',  # Coloration 2
        'https://images.unsplash.com/photo-1600948836101-f9ffda59d250',  # Coloration 3
    ],
    'soin': [
        'https://images.unsplash.com/photo-1616394584738-fc6e612e71b9',  # Soin 1
        'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881',  # Soin 2
        'https://images.unsplash.com/photo-1632345031435-8727f6897d53',  # Soin 3
    ],
}

# Paramètres pour le téléchargement
params = {
    'w': 800,  # Largeur
    'q': 80,   # Qualité
    'fm': 'jpg', # Format
    'fit': 'crop', # Mode de recadrage
}

# Télécharger les images
for category, urls in demo_images.items():
    for i, url in enumerate(urls, 1):
        filename = f'service_{category}_{i}.jpg'
        filepath = os.path.join(services_dir, filename)
        
        # Ajouter les paramètres à l'URL
        url = f"{url}?{'&'.join(f'{k}={v}' for k, v in params.items())}"
        
        try:
            response = requests.get(url, stream=True)
            if response.status_code == 200:
                with open(filepath, 'wb') as f:
                    response.raw.decode_content = True
                    shutil.copyfileobj(response.raw, f)
                print(f"Téléchargé : {filename}")
            else:
                print(f"Erreur lors du téléchargement de {filename}")
        except Exception as e:
            print(f"Erreur pour {filename}: {str(e)}")

print("\nTéléchargement terminé !")
