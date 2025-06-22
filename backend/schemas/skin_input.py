from pydantic import BaseModel
from typing import Optional

class SkinAnalysisInput(BaseModel):
    # Informations sur les symptômes
    duree: str
    demangeaisons: bool
    douleur: bool
    changement_recent: Optional[bool] = False
    
    # Métadonnées
    age: Optional[int] = None
    sexe: Optional[str] = None

class SkinDiagnosis(BaseModel):
    maladie: str
    confiance: float
    gravite: str
    recommandations: list[str]
    urgence: bool
    type: str = "peau"