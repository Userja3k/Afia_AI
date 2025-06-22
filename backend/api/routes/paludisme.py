from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import numpy as np
import onnxruntime as ort
import json

router = APIRouter()
model = ort.InferenceSession("models/paludisme.onnx")

# Load metadata for scaler parameters
with open("models/paludisme_metadata.json", "r") as f:
    metadata = json.load(f)

scaler_mean = np.array(metadata["scaler_mean"], dtype=np.float32)
scaler_scale = np.array(metadata["scaler_scale"], dtype=np.float32)

class SymptomesInput(BaseModel):
    fievre: bool
    temperature: Optional[float]
    maux_tete: bool
    fatigue: bool
    hallucinations: bool
    vomissements: bool
    audio_file: Optional[str]

@router.post("/diagnose")
async def diagnose_paludisme(symptomes: SymptomesInput):
    raw_input = np.array([
        symptomes.temperature or 37.0,
        float(symptomes.fievre),
        float(symptomes.maux_tete),
        float(symptomes.fatigue),
        float(symptomes.hallucinations),
        float(symptomes.vomissements),
    ], dtype=np.float32)

    # Normalize input using scaler parameters
    input_data = (raw_input - scaler_mean) / scaler_scale

    prediction = model.run(
        None,
        {"input": input_data.reshape(1, -1)}
    )[0]

    risk_level = prediction[0]
    is_severe = risk_level > 0.7

    return {
        "diagnostic": "paludisme_grave" if is_severe else "paludisme_simple",
        "gravite": "élevée" if is_severe else "modérée",
        "urgence": is_severe,
        "recommandations": [
            "Consultation urgente" if is_severe else "Repos et hydratation",
            "Paracétamol si fièvre",
        ]
    }
