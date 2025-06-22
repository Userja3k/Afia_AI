from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from typing import Optional
import os
from backend.schemas.skin_input import SkinAnalysisInput, SkinDiagnosis
from backend.services.prediction_service import prediction_service
from backend.services.image_preprocess import image_preprocessor
from backend.core.utils import generate_filename, validate_file_type, create_upload_dir

router = APIRouter(prefix="/skin", tags=["dermatologie"])

@router.post("/diagnose", response_model=SkinDiagnosis)
async def diagnose_skin(
    image: UploadFile = File(...),
    duree: str = Form(...),
    demangeaisons: bool = Form(...),
    douleur: bool = Form(...),
    changement_recent: Optional[bool] = Form(False),
    age: Optional[int] = Form(None),
    sexe: Optional[str] = Form(None)
):
    """Diagnostic dermatologique basé sur une image et des symptômes"""
    try:
        create_upload_dir()
        
        # Validation du fichier image
        if not validate_file_type(image.filename, ['.jpg', '.jpeg', '.png']):
            raise HTTPException(status_code=400, detail="Type d'image non supporté")
        
        # Sauvegarde de l'image
        image_filename = generate_filename(image.filename)
        image_path = f"static/uploads/{image_filename}"
        
        with open(image_path, "wb") as buffer:
            content = await image.read()
            buffer.write(content)
        
        # Préparation des données de symptômes
        symptoms_data = {
            "duree": duree,
            "demangeaisons": demangeaisons,
            "douleur": douleur,
            "changement_recent": changement_recent,
            "age": age,
            "sexe": sexe
        }
        
        # Amélioration de l'image
        try:
            enhanced_path = image_preprocessor.enhance_image(image_path)
            
            # Extraction des caractéristiques de texture
            texture_features = image_preprocessor.extract_texture_features(enhanced_path)
            symptoms_data["texture_features"] = texture_features
            
        except Exception as e:
            print(f"Erreur lors du prétraitement de l'image: {e}")
        
        # Prédiction
        result = prediction_service.predict_skin_disease(image_path, symptoms_data)
        
        # Nettoyage des fichiers temporaires
        try:
            if os.path.exists(image_path):
                os.remove(image_path)
            if 'enhanced_path' in locals() and os.path.exists(enhanced_path):
                os.remove(enhanced_path)
        except Exception as e:
            print(f"Erreur lors du nettoyage: {e}")
        
        return SkinDiagnosis(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors du diagnostic: {str(e)}")

@router.post("/analyze-texture")
async def analyze_skin_texture(image: UploadFile = File(...)):
    """Analyse uniquement la texture de la peau"""
    try:
        create_upload_dir()
        
        # Validation et sauvegarde
        if not validate_file_type(image.filename, ['.jpg', '.jpeg', '.png']):
            raise HTTPException(status_code=400, detail="Type d'image non supporté")
        
        image_filename = generate_filename(image.filename)
        image_path = f"static/uploads/{image_filename}"
        
        with open(image_path, "wb") as buffer:
            content = await image.read()
            buffer.write(content)
        
        # Extraction des caractéristiques
        features = image_preprocessor.extract_texture_features(image_path)
        
        # Détection des régions de peau
        skin_region = image_preprocessor.detect_skin_region(image_path)
        
        # Nettoyage
        if os.path.exists(image_path):
            os.remove(image_path)
        
        return {
            "texture_features": features,
            "skin_detected": skin_region is not None,
            "analysis": {
                "texture_complexity": features.get("entropy", 0),
                "surface_roughness": features.get("variance", 0),
                "edge_density": features.get("gradient_mean", 0)
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de l'analyse: {str(e)}")

@router.get("/diseases")
async def get_skin_diseases_info():
    """Informations sur les maladies de peau détectables"""
    return {
        "diseases": {
            "eczema": {
                "description": "Inflammation chronique de la peau",
                "symptoms": ["Démangeaisons", "Rougeurs", "Peau sèche"],
                "treatment": ["Crèmes hydratantes", "Corticoïdes topiques"]
            },
            "psoriasis": {
                "description": "Maladie auto-immune de la peau",
                "symptoms": ["Plaques rouges", "Squames", "Démangeaisons"],
                "treatment": ["Crèmes à base de vitamine D", "Photothérapie"]
            },
            "acne": {
                "description": "Inflammation des follicules pileux",
                "symptoms": ["Boutons", "Points noirs", "Inflammation"],
                "treatment": ["Nettoyage doux", "Traitements topiques"]
            },
            "melanome": {
                "description": "Cancer de la peau",
                "symptoms": ["Grain de beauté asymétrique", "Changement de couleur"],
                "treatment": ["CONSULTATION URGENTE", "Biopsie", "Chirurgie"]
            }
        },
        "warning": "Ce diagnostic est informatif. Consultez toujours un dermatologue."
    }