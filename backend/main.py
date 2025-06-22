from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import uvicorn
import os

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from core.config import settings
from core.utils import create_upload_dir, cleanup_old_files
from api.routes import malaria_router, skin_router

# Création de l'application FastAPI
app = FastAPI(
    title="AfiaAI Backend",
    description="API pour le diagnostic médical par IA",
    version="1.0.0"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Création des répertoires nécessaires
create_upload_dir()

# Montage des fichiers statiques
if os.path.exists("static"):
    app.mount("/static", StaticFiles(directory="static"), name="static")

# Inclusion des routes
app.include_router(malaria_router.router, prefix="/api")
app.include_router(skin_router.router, prefix="/api")

@app.get("/")
async def root():
    """Point d'entrée de l'API"""
    return {
        "message": "AfiaAI Backend API",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "malaria": "/api/paludisme",
            "skin": "/api/skin",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    """Vérification de l'état de l'API"""
    return {
        "status": "healthy",
        "models": {
            "malaria": os.path.exists(settings.malaria_model_path),
            "skin": os.path.exists(settings.skin_model_path)
        }
    }

@app.on_event("startup")
async def startup_event():
    """Événements au démarrage"""
    print("🚀 AfiaAI Backend démarré")
    print(f"📊 Modèles chargés:")
    print(f"   - Paludisme: {os.path.exists(settings.malaria_model_path)}")
    print(f"   - Dermatologie: {os.path.exists(settings.skin_model_path)}")

@app.on_event("shutdown")
async def shutdown_event():
    """Nettoyage à l'arrêt"""
    print("🧹 Nettoyage des fichiers temporaires...")
    cleanup_old_files("static/uploads", max_age_hours=1)
    print("👋 AfiaAI Backend arrêté")

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    )