import os
import shutil
from sklearn.model_selection import train_test_split

def prepare_data(source_dir="raw_data", dest_dir="data"):
    classes = ["eczema", "psoriasis", "acne", "melanome"]
    splits = ["train", "val"]
    
    # Création des dossiers
    for split in splits:
        for cls in classes:
            os.makedirs(os.path.join(dest_dir, split, cls), exist_ok=True)

    # Répartition des images
    for cls in classes:
        images = [f for f in os.listdir(os.path.join(source_dir, cls)) 
                 if f.endswith((".jpg", ".png", ".jpeg"))]
        
        train, val = train_test_split(images, test_size=0.2, random_state=42)
        
        for img in train:
            shutil.copy(
                os.path.join(source_dir, cls, img),
                os.path.join(dest_dir, "train", cls, img)
            )
        
        for img in val:
            shutil.copy(
                os.path.join(source_dir, cls, img),
                os.path.join(dest_dir, "val", cls, img)
            )
        
        print(f"{cls}: {len(train)} train, {len(val)} val")

if __name__ == "__main__":
    prepare_data()
    print("✅ Données prêtes dans le dossier 'data'")