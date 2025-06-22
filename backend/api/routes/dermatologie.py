from fastapi import APIRouter, File, UploadFile, HTTPException
from PIL import Image
import numpy as np
import io
import onnxruntime as ort

router = APIRouter()
model = ort.InferenceSession("models/skin.onnx")

@router.post("/diagnose")
async def diagnose_skin(image: UploadFile = File(...)):
    image_data = await image.read()
    img = Image.open(io.BytesIO(image_data))
    img = img.resize((224, 224))
    img_array = np.array(img).astype(np.float32) / 255.0
    
    prediction = model.run(
        None,
        {"input": img_array.reshape(1, 224, 224, 3)}
    )[0]

    disease_index = np.argmax(prediction)
    confidence = float(prediction[disease_index])

    diseases = ["eczema", "psoriasis", "acne", "melanome"]
    disease = diseases[disease_index]

    return {
        "maladie": disease,
        "confiance": confidence,
        "gravite": "élevée" if disease == "melanome" else "modérée",
        "recommandations": [
            "Consultation dermatologique urgente" if disease == "melanome"
            else "Application de crème hydratante",
        ]
    }