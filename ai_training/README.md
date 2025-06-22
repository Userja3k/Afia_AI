# Guide d'entraînement des modèles IA

## Configuration de l'environnement

1. Créer un environnement virtuel Python:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

2. Installer les dépendances:
```bash
pip install -r requirements.txt
```

## Modèle Paludisme

1. Préparer les données:
```bash
cd malaria
python data_preparation.py
```

2. Entraîner le modèle:
```bash
python train.py
```

## Modèle Dermatologique

1. Organiser les données:
- Placer les images dans `skin/raw_data/` avec la structure suivante:
  ```
  raw_data/
  ├── eczema/
  ├── psoriasis/
  ├── acne/
  └── melanome/
  ```

2. Préparer les données:
```bash
cd skin
python data_preparation.py
```

3. Entraîner le modèle:
```bash
python train.py
```

## Structure des données

### Paludisme
Le fichier CSV contient les colonnes suivantes:
- temperature: température corporelle
- fievre: présence de fièvre (0/1)
- maux_tete: présence de maux de tête (0/1)
- fatigue: présence de fatigue (0/1)
- hallucinations: présence d'hallucinations (0/1)
- vomissements: présence de vomissements (0/1)
- severity: gravité (0: normal, 1: simple, 2: sévère)

### Dermatologie
Les images doivent être organisées par classe:
- eczema
- psoriasis
- acne
- melanome

## Validation des modèles

Les scripts d'entraînement incluent:
- Validation croisée
- Métriques de performance
- Export au format ONNX

## Notes importantes

1. Données:
   - Utiliser des données représentatives
   - Équilibrer les classes
   - Augmenter les données si nécessaire

2. Hyperparamètres:
   - Ajuster selon les résultats
   - Utiliser la validation croisée

3. Évaluation:
   - Vérifier la précision
   - Tester sur des cas réels
   - Valider les faux positifs/négatifs