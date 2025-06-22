# AfiaAI - Intelligence Artificielle pour la Santé en Afrique 🌍

## 🎯 Description
AfiaAI est une application mobile innovante qui utilise l'intelligence artificielle pour faciliter le diagnostic précoce du paludisme et des maladies dermatologiques en Afrique. Elle combine des modèles d'IA optimisés avec une interface utilisateur intuitive et multilingue.

## 🚀 Fonctionnalités
- Diagnostic du paludisme via symptômes, voix et photos
- Détection des maladies de peau par analyse d'image
- Assistant IA (Google Gemini) pour guider les utilisateurs
- Interface multilingue (FR, EN, ES, PT)
- Mode hors-ligne pour zones à faible connectivité
- Historique des diagnostics
- Recommandations médicales personnalisées

## 🛠️ Technologies
- Frontend: Flutter
- Backend: FastAPI
- IA: Modèles ONNX optimisés
- Assistant: Google Gemini API

## 📋 Guide d'entraînement des modèles IA

### 1. Modèle Paludisme
```python
import onnx
import torch
from sklearn.ensemble import RandomForestClassifier

# 1. Préparer les données
X_train = [...] # Symptômes (fièvre, fatigue, etc.)
y_train = [...] # Labels (0: sain, 1: paludisme simple, 2: grave)

# 2. Entraîner le modèle
model = RandomForestClassifier()
model.fit(X_train, y_train)

# 3. Convertir en ONNX
from skl2onnx import convert_sklearn
onnx_model = convert_sklearn(model, 'malaria_model')
onnx.save(onnx_model, 'models/paludisme.onnx')
```

### 2. Modèle Dermatologie
```python
import torch
import torchvision

# 1. Charger un modèle pré-entraîné
model = torchvision.models.mobilenet_v2(pretrained=True)
model.classifier[1] = torch.nn.Linear(model.last_channel, 4)  # 4 classes

# 2. Entraîner sur dataset dermatologique
train_loader = DataLoader(skin_dataset, batch_size=32)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters())

for epoch in range(epochs):
    for images, labels in train_loader:
        outputs = model(images)
        loss = criterion(outputs, labels)
        optimizer.step()

# 3. Exporter en ONNX
dummy_input = torch.randn(1, 3, 224, 224)
torch.onnx.export(model, dummy_input, 'models/skin.onnx')
```

## 🤖 Intégration de Google Gemini

1. Obtenir une clé API Gemini:
```bash
export GEMINI_API_KEY='votre_clé_api'
```

2. Utilisation dans Flutter:
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
);

Future<String> getPageDescription(String pageName) async {
  final prompt = 'Explique la page $pageName et ses fonctionnalités';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  return response.text ?? 'Description non disponible';
}
```

## 📱 Installation et Déploiement

### Frontend (Flutter)
```bash
flutter pub get
flutter run
```

### Backend (FastAPI)
```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

## 🔒 Sécurité et Confidentialité
- Aucune donnée personnelle stockée
- Traitement local des images quand possible
- Avertissements médicaux clairs
- Mode hors-ligne pour zones isolées

## 📊 Datasets Recommandés
- Paludisme: WHO Malaria Dataset
- Dermatologie: HAM10000, ISIC Archive
- Voix: VoxCeleb (pour analyse vocale)

## 🌟 Contribution
Projet open-source développé pour le Google AI Hackathon 2025.