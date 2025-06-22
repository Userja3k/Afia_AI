import onnxruntime as ort
import numpy as np
from typing import Dict, Any
from ..core.config import settings
from ..core.utils import preprocess_image

class PredictionService:
    def __init__(self):
        self.malaria_session = None
        self.skin_session = None
        self._load_models()
    
    def _load_models(self):
        """Charge les modèles ONNX"""
        try:
            if settings.malaria_model_path:
                print(f"Chargement du modèle malaria depuis {settings.malaria_model_path}")
                self.malaria_session = ort.InferenceSession(settings.malaria_model_path)
            
            if settings.skin_model_path:
                print(f"Chargement du modèle skin depuis {settings.skin_model_path}")
                self.skin_session = ort.InferenceSession(settings.skin_model_path)
        except Exception as e:
            print(f"Erreur lors du chargement des modèles: {e}")
    
    def predict_malaria(self, symptoms: Dict[str, Any]) -> Dict[str, Any]:
        """Prédit le risque de paludisme"""
        if not self.malaria_session:
            return self._mock_malaria_prediction(symptoms)
        
        try:
            import json
            # Load scaler parameters from metadata
            with open("models/paludisme_metadata.json", "r") as f:
                metadata = json.load(f)
            scaler_mean = np.array(metadata["scaler_mean"], dtype=np.float32)
            scaler_scale = np.array(metadata["scaler_scale"], dtype=np.float32)
            
            # Prepare raw input
            raw_input = np.array([
                symptoms.get('temperature', 37.0),
                float(symptoms.get('fievre', False)),
                float(symptoms.get('maux_tete', False)),
                float(symptoms.get('fatigue', False)),
                float(symptoms.get('hallucinations', False)),
                float(symptoms.get('vomissements', False)),
            ], dtype=np.float32)
            
            # Normalize input
            input_data = (raw_input - scaler_mean) / scaler_scale
            input_data = input_data.reshape(1, -1)
            
            # Prediction
            input_name = self.malaria_session.get_inputs()[0].name
            result = self.malaria_session.run(None, {input_name: input_data})
            
            # Interpret results
            prediction = result[0][0]
            
            if prediction > 0.8:
                diagnostic = "paludisme_grave"
                gravite = "élevée"
                urgence = True
                recommandations = [
                    "Consultation médicale urgente",
                    "Hospitalisation recommandée",
                    "Surveillance constante"
                ]
            elif prediction > 0.5:
                diagnostic = "paludisme_simple"
                gravite = "modérée"
                urgence = False
                recommandations = [
                    "Consultation médicale dans les 24h",
                    "Repos et hydratation",
                    "Paracétamol si fièvre"
                ]
            else:
                diagnostic = "pas_de_paludisme"
                gravite = "faible"
                urgence = False
                recommandations = [
                    "Surveillance des symptômes",
                    "Repos et hydratation",
                    "Consulter si aggravation"
                ]
            
            return {
                "diagnostic": diagnostic,
                "gravite": gravite,
                "urgence": urgence,
                "confiance": float(prediction),
                "recommandations": recommandations
            }
            
        except Exception as e:
            print(f"Erreur lors de la prédiction: {e}")
            return self._mock_malaria_prediction(symptoms)
    
    def predict_skin_disease(self, image_path: str, symptoms: Dict[str, Any]) -> Dict[str, Any]:
        """Prédit la maladie de peau"""
        if not self.skin_session:
            return self._mock_skin_prediction(symptoms)
        
        try:
            # Prétraitement de l'image
            image_array = preprocess_image(image_path)
            
            # Prédiction
            input_name = self.skin_session.get_inputs()[0].name
            result = self.skin_session.run(None, {input_name: image_array})
            
            # Classes de maladies
            diseases = ["eczema", "psoriasis", "acne", "melanome"]
            predictions = result[0][0]
            
            # Maladie la plus probable
            disease_index = np.argmax(predictions)
            confidence = float(predictions[disease_index])
            disease = diseases[disease_index]
            
            # Détermination de la gravité et recommandations
            if disease == "melanome":
                gravite = "élevée"
                urgence = True
                recommandations = [
                    "Consultation dermatologique URGENTE",
                    "Biopsie recommandée",
                    "Ne pas attendre"
                ]
            elif confidence > 0.8:
                gravite = "modérée"
                urgence = False
                recommandations = [
                    "Consultation dermatologique recommandée",
                    "Application de crème adaptée",
                    "Surveillance de l'évolution"
                ]
            else:
                gravite = "légère"
                urgence = False
                recommandations = [
                    "Soins locaux appropriés",
                    "Hygiène renforcée",
                    "Consulter si pas d'amélioration"
                ]
            
            return {
                "maladie": disease,
                "confiance": confidence,
                "gravite": gravite,
                "urgence": urgence,
                "recommandations": recommandations
            }
            
        except Exception as e:
            print(f"Erreur lors de la prédiction: {e}")
            return self._mock_skin_prediction(symptoms)
    
    def _mock_malaria_prediction(self, symptoms: Dict[str, Any]) -> Dict[str, Any]:
        """Prédiction simulée pour le paludisme"""
        has_fever = symptoms.get('fievre', False)
        has_severe_symptoms = symptoms.get('hallucinations', False) or symptoms.get('vomissements', False)
        
        if has_severe_symptoms:
            return {
                "diagnostic": "paludisme_grave",
                "gravite": "élevée",
                "urgence": True,
                "confiance": 0.85,
                "recommandations": [
                    "Consultation médicale urgente",
                    "Hospitalisation recommandée"
                ]
            }
        elif has_fever:
            return {
                "diagnostic": "paludisme_simple",
                "gravite": "modérée",
                "urgence": False,
                "confiance": 0.65,
                "recommandations": [
                    "Consultation médicale dans les 24h",
                    "Repos et hydratation"
                ]
            }
        else:
            return {
                "diagnostic": "pas_de_paludisme",
                "gravite": "faible",
                "urgence": False,
                "confiance": 0.75,
                "recommandations": [
                    "Surveillance des symptômes",
                    "Repos recommandé"
                ]
            }
    
    def _mock_skin_prediction(self, symptoms: Dict[str, Any]) -> Dict[str, Any]:
        """Prédiction simulée pour la peau"""
        has_itching = symptoms.get('demangeaisons', False)
        has_pain = symptoms.get('douleur', False)
        
        if has_pain and has_itching:
            disease = "eczema"
            confidence = 0.75
        elif has_itching:
            disease = "psoriasis"
            confidence = 0.68
        else:
            disease = "acne"
            confidence = 0.72
        
        return {
            "maladie": disease,
            "confiance": confidence,
            "gravite": "modérée",
            "urgence": False,
            "recommandations": [
                "Application de crème hydratante",
                "Éviter les irritants",
                "Consulter si pas d'amélioration"
            ]
        }

# Instance globale
prediction_service = PredictionService()