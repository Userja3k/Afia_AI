from pydantic_settings import BaseSettings
from pydantic import validator
import os
import json

class Settings(BaseSettings):
    app_name: str = "AfiaAI Backend"
    debug: bool = True
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Modèles ONNX
    malaria_model_path: str = "models/paludisme.onnx"
    skin_model_path: str = "models/skin.onnx"
    
    # Upload settings
    upload_dir: str = "static/uploads"
    max_file_size: int = 10 * 1024 * 1024  # 10MB
    
    # CORS settings
    cors_origins: list = ["*"]

    @validator("cors_origins", pre=True)
    def parse_cors_origins(cls, v):
        if isinstance(v, str):
            if not v:
                return ["*"]
            try:
                return json.loads(v)
            except Exception:
                return [v]
        return v
    
    class Config:
        env_file = ".env"

settings = Settings()
