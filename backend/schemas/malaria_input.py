from pydantic import BaseModel
from typing import Optional

class MalariaSymptoms(BaseModel):
    # Informations de base
    nom: Optional[str] = None
    age: int
    sexe: str
    
    # Symptômes courants
    fievre: bool
    temperature: Optional[float] = 37.0
    maux_tete: bool
    fatigue: bool
    
    # Symptômes graves
    hallucinations: bool
    vomissements: bool
    confusion: Optional[bool] = False
    difficulte_respiration: Optional[bool] = False
    
    # Données supplémentaires
    audio_file: Optional[str] = None
    image_file: Optional[str] = None

class MalariaDiagnosis(BaseModel):
    diagnostic: str
    gravite: str
    urgence: bool
    confiance: Optional[float] = None
    recommandations: list[str]
    type: str = "paludisme"