from PIL import Image, ImageEnhance, ImageFilter
import numpy as np
from typing import Tuple, Optional
import cv2

class ImagePreprocessor:
    def __init__(self, target_size: Tuple[int, int] = (224, 224)):
        self.target_size = target_size
    
    def enhance_image(self, image_path: str, output_path: Optional[str] = None) -> str:
        """Améliore la qualité de l'image pour l'analyse"""
        try:
            # Ouverture de l'image
            image = Image.open(image_path)
            
            # Conversion en RGB si nécessaire
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Amélioration du contraste
            enhancer = ImageEnhance.Contrast(image)
            image = enhancer.enhance(1.2)
            
            # Amélioration de la netteté
            enhancer = ImageEnhance.Sharpness(image)
            image = enhancer.enhance(1.1)
            
            # Réduction du bruit
            image = image.filter(ImageFilter.MedianFilter(size=3))
            
            # Sauvegarde
            if output_path:
                image.save(output_path, quality=95)
                return output_path
            else:
                enhanced_path = image_path.replace('.', '_enhanced.')
                image.save(enhanced_path, quality=95)
                return enhanced_path
                
        except Exception as e:
            print(f"Erreur lors de l'amélioration de l'image: {e}")
            return image_path
    
    def detect_skin_region(self, image_path: str) -> Optional[np.ndarray]:
        """Détecte et isole les régions de peau dans l'image"""
        try:
            # Chargement avec OpenCV
            image = cv2.imread(image_path)
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Conversion en HSV pour la détection de peau
            hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # Plages de couleur pour la peau (ajustées pour différents tons)
            lower_skin1 = np.array([0, 20, 70], dtype=np.uint8)
            upper_skin1 = np.array([20, 255, 255], dtype=np.uint8)
            
            lower_skin2 = np.array([0, 0, 0], dtype=np.uint8)
            upper_skin2 = np.array([180, 80, 255], dtype=np.uint8)
            
            # Création des masques
            mask1 = cv2.inRange(hsv, lower_skin1, upper_skin1)
            mask2 = cv2.inRange(hsv, lower_skin2, upper_skin2)
            mask = cv2.bitwise_or(mask1, mask2)
            
            # Nettoyage du masque
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
            mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
            mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
            
            # Application du masque
            result = cv2.bitwise_and(image_rgb, image_rgb, mask=mask)
            
            return result
            
        except Exception as e:
            print(f"Erreur lors de la détection de peau: {e}")
            return None
    
    def extract_texture_features(self, image_path: str) -> dict:
        """Extrait les caractéristiques de texture de l'image"""
        try:
            # Chargement en niveaux de gris
            image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
            
            if image is None:
                return {}
            
            # Redimensionnement
            image = cv2.resize(image, self.target_size)
            
            features = {}
            
            # Calcul de la variance (mesure de texture)
            features['variance'] = np.var(image)
            
            # Calcul du gradient (détection de contours)
            grad_x = cv2.Sobel(image, cv2.CV_64F, 1, 0, ksize=3)
            grad_y = cv2.Sobel(image, cv2.CV_64F, 0, 1, ksize=3)
            gradient_magnitude = np.sqrt(grad_x**2 + grad_y**2)
            features['gradient_mean'] = np.mean(gradient_magnitude)
            features['gradient_std'] = np.std(gradient_magnitude)
            
            # Analyse de l'histogramme
            hist = cv2.calcHist([image], [0], None, [256], [0, 256])
            features['hist_mean'] = np.mean(hist)
            features['hist_std'] = np.std(hist)
            
            # Entropie (mesure de complexité)
            hist_norm = hist / np.sum(hist)
            hist_norm = hist_norm[hist_norm > 0]  # Éviter log(0)
            features['entropy'] = -np.sum(hist_norm * np.log2(hist_norm))
            
            return features
            
        except Exception as e:
            print(f"Erreur lors de l'extraction des caractéristiques: {e}")
            return {}
    
    def prepare_for_model(self, image_path: str) -> np.ndarray:
        """Prépare l'image pour l'inférence du modèle"""
        try:
            # Amélioration de l'image
            enhanced_path = self.enhance_image(image_path)
            
            # Chargement et redimensionnement
            image = Image.open(enhanced_path)
            image = image.resize(self.target_size)
            
            # Conversion en array numpy
            image_array = np.array(image).astype(np.float32)
            
            # Normalisation
            image_array = image_array / 255.0
            
            # Ajout de la dimension batch
            image_array = np.expand_dims(image_array, axis=0)
            
            return image_array
            
        except Exception as e:
            print(f"Erreur lors de la préparation de l'image: {e}")
            # Retour d'un array par défaut
            return np.zeros((1, *self.target_size, 3), dtype=np.float32)

# Instance globale
image_preprocessor = ImagePreprocessor()