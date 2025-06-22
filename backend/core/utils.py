import os
import uuid
from typing import Optional
from PIL import Image
import numpy as np

def create_upload_dir():
    """Crée le répertoire d'upload s'il n'existe pas"""
    os.makedirs("static/uploads", exist_ok=True)

def generate_filename(original_filename: str) -> str:
    """Génère un nom de fichier unique"""
    ext = os.path.splitext(original_filename)[1]
    return f"{uuid.uuid4()}{ext}"

def preprocess_image(image_path: str, target_size: tuple = (224, 224)) -> np.ndarray:
    """Prétraite une image pour l'analyse IA"""
    try:
        image = Image.open(image_path)
        image = image.convert('RGB')
        image = image.resize(target_size)
        
        # Normalisation
        image_array = np.array(image).astype(np.float32) / 255.0
        
        # Mean and std normalization (from skin_metadata.json)
        mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
        std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
        
        image_array = (image_array - mean) / std
        
        # Ajout de la dimension batch
        image_array = np.expand_dims(image_array, axis=0)
        
        # Transpose to channels first (NCHW)
        image_array = image_array.transpose(0, 3, 1, 2)
        
        return image_array
    except Exception as e:
        raise ValueError(f"Erreur lors du prétraitement de l'image: {str(e)}")

def validate_file_type(filename: str, allowed_types: list) -> bool:
    """Valide le type de fichier"""
    ext = os.path.splitext(filename)[1].lower()
    return ext in allowed_types

def cleanup_old_files(directory: str, max_age_hours: int = 24):
    """Nettoie les anciens fichiers uploadés"""
    import time
    current_time = time.time()
    
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        if os.path.isfile(file_path):
            file_age = current_time - os.path.getctime(file_path)
            if file_age > max_age_hours * 3600:
                os.remove(file_path)