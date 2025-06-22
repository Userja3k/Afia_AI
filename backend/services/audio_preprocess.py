import librosa
import numpy as np
from typing import Optional, Dict, Any

class AudioPreprocessor:
    def __init__(self, sample_rate: int = 22050, duration: float = 30.0):
        self.sample_rate = sample_rate
        self.duration = duration
        self.target_length = int(sample_rate * duration)
    
    def extract_features(self, audio_path: str) -> Dict[str, Any]:
        """Extrait les caractéristiques audio pour l'analyse"""
        try:
            # Chargement de l'audio
            audio, sr = librosa.load(audio_path, sr=self.sample_rate, duration=self.duration)
            
            # Padding ou troncature pour avoir une longueur fixe
            if len(audio) < self.target_length:
                audio = np.pad(audio, (0, self.target_length - len(audio)))
            else:
                audio = audio[:self.target_length]
            
            # Extraction des caractéristiques
            features = {}
            
            # MFCC (Mel-frequency cepstral coefficients)
            mfccs = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=13)
            features['mfcc_mean'] = np.mean(mfccs, axis=1)
            features['mfcc_std'] = np.std(mfccs, axis=1)
            
            # Spectral features
            spectral_centroids = librosa.feature.spectral_centroid(y=audio, sr=sr)[0]
            features['spectral_centroid_mean'] = np.mean(spectral_centroids)
            features['spectral_centroid_std'] = np.std(spectral_centroids)
            
            # Zero crossing rate
            zcr = librosa.feature.zero_crossing_rate(audio)[0]
            features['zcr_mean'] = np.mean(zcr)
            features['zcr_std'] = np.std(zcr)
            
            # RMS Energy
            rms = librosa.feature.rms(y=audio)[0]
            features['rms_mean'] = np.mean(rms)
            features['rms_std'] = np.std(rms)
            
            # Tempo
            tempo, _ = librosa.beat.beat_track(y=audio, sr=sr)
            features['tempo'] = tempo
            
            return features
            
        except Exception as e:
            print(f"Erreur lors de l'extraction des caractéristiques audio: {e}")
            return {}
    
    def analyze_voice_health(self, features: Dict[str, Any]) -> Dict[str, Any]:
        """Analyse les caractéristiques vocales pour détecter des signes de maladie"""
        analysis = {
            "voice_quality": "normal",
            "breathing_pattern": "normal",
            "energy_level": "normal",
            "confidence": 0.5
        }
        
        try:
            # Analyse de l'énergie vocale
            if features.get('rms_mean', 0) < 0.01:
                analysis["energy_level"] = "faible"
                analysis["voice_quality"] = "faible"
            elif features.get('rms_mean', 0) > 0.1:
                analysis["energy_level"] = "élevé"
            
            # Analyse du rythme respiratoire
            if features.get('zcr_mean', 0) > 0.1:
                analysis["breathing_pattern"] = "irrégulier"
            
            # Analyse de la qualité vocale
            if features.get('spectral_centroid_mean', 0) < 1000:
                analysis["voice_quality"] = "rauque"
            elif features.get('spectral_centroid_mean', 0) > 3000:
                analysis["voice_quality"] = "tendue"
            
            # Calcul de la confiance basé sur la qualité des caractéristiques
            if len(features) > 10:
                analysis["confidence"] = min(0.8, 0.3 + len(features) * 0.05)
            
        except Exception as e:
            print(f"Erreur lors de l'analyse vocale: {e}")
        
        return analysis

# Instance globale
audio_preprocessor = AudioPreprocessor()