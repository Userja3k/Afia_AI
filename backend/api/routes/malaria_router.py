from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from typing import Optional
import os
from backend.schemas.malaria_input import MalariaSymptoms, MalariaDiagnosis
from backend.services.prediction_service import prediction_service
from backend.services.audio_preprocess import audio_preprocessor
from backend.core.utils import generate_filename, validate_file_type, create_upload_dir

router = APIRouter(prefix="/paludisme", tags=["paludisme"])

@router.post("/diagnose", response_model=MalariaDiagnosis)
async def diagnose_malaria(symptoms: MalariaSymptoms):
    """Diagnostic du paludisme basé sur les symptômes"""
    try:
        # Validation des données
        if symptoms.age < 0 or symptoms.age > 120:
            raise HTTPException(status_code=400, detail="Âge invalide")
        
        if symptoms.sexe not in ['M', 'F']:
            raise HTTPException(status_code=400, detail="Sexe invalide")
        
        # Prédiction
        result = prediction_service.predict_malaria(symptoms.dict())
        
        return MalariaDiagnosis(**result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors du diagnostic: {str(e)}")

@router.post("/diagnose-with-media")
async def diagnose_malaria_with_media(
    # Symptômes de base
    age: int = Form(...),
    sexe: str = Form(...),
    fievre: bool = Form(...),
    temperature: Optional[float] = Form(37.0),
    maux_tete: bool = Form(...),
    fatigue: bool = Form(...),
    hallucinations: bool = Form(...),
    vomissements: bool = Form(...),
    confusion: Optional[bool] = Form(False),
    difficulte_respiration: Optional[bool] = Form(False),
    nom: Optional[str] = Form(None),
    
    # Fichiers optionnels
    image: Optional[UploadFile] = File(None),
    audio: Optional[UploadFile] = File(None)
):
    """Diagnostic du paludisme avec photo et audio optionnels"""
    try:
        create_upload_dir()
        
        # Préparation des données de symptômes
        symptoms_data = {
            "age": age,
            "sexe": sexe,
            "fievre": fievre,
            "temperature": temperature,
            "maux_tete": maux_tete,
            "fatigue": fatigue,
            "hallucinations": hallucinations,
            "vomissements": vomissements,
            "confusion": confusion,
            "difficulte_respiration": difficulte_respiration,
            "nom": nom
        }
        
        # Traitement de l'image si fournie
        if image:
            if not validate_file_type(image.filename, ['.jpg', '.jpeg', '.png']):
                raise HTTPException(status_code=400, detail="Type d'image non supporté")
            
            image_filename = generate_filename(image.filename)
            image_path = f"static/uploads/{image_filename}"
            
            with open(image_path, "wb") as buffer:
                content = await image.read()
                buffer.write(content)
            
            symptoms_data["image_file"] = image_path
        
        # Traitement de l'audio si fourni
        audio_analysis = None
        if audio:
            if not validate_file_type(audio.filename, ['.wav', '.mp3', '.m4a']):
                raise HTTPException(status_code=400, detail="Type d'audio non supporté")
            
            audio_filename = generate_filename(audio.filename)
            audio_path = f"static/uploads/{audio_filename}"
            
            with open(audio_path, "wb") as buffer:
                content = await audio.read()
                buffer.write(content)
            
            # Analyse audio
            try:
                features = audio_preprocessor.extract_features(audio_path)
                audio_analysis = audio_preprocessor.analyze_voice_health(features)
                symptoms_data["audio_analysis"] = audio_analysis
            except Exception as e:
                print(f"Erreur analyse audio: {e}")
        
        # Prédiction
        result = prediction_service.predict_malaria(symptoms_data)
        
        # Ajustement basé sur l'analyse audio si disponible
        if audio_analysis and audio_analysis.get("voice_quality") == "faible":
            if result["gravite"] == "modérée":
                result["gravite"] = "élevée"
                result["urgence"] = True
        
        return MalariaDiagnosis(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors du diagnostic: {str(e)}")

@router.get("/info")
async def get_malaria_info():
    """Informations sur le paludisme"""
    return {
        "description": "Le paludisme est une maladie parasitaire transmise par les moustiques",
        "symptomes_courants": [
            "Fièvre",
            "Maux de tête",
            "Fatigue",
            "Frissons"
        ],
        "symptomes_graves": [
            "Hallucinations",
            "Vomissements",
            "Confusion",
            "Difficultés respiratoires"
        ],
        "prevention": [
            "Utiliser des moustiquaires",
            "Éliminer les eaux stagnantes",
            "Porter des vêtements longs",
            "Utiliser des répulsifs"
        ]
    }