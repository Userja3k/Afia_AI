import pandas as pd
import numpy as np
from sklearn.ensemble import GradientBoostingClassifier  # Meilleur que RandomForest pour les données tabulaires
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import RobustScaler  # Moins sensible aux outliers
import joblib
import onnxruntime as ort
import skl2onnx
from skl2onnx.common.data_types import FloatTensorType

# 1. Chargement des données
df = pd.read_csv('data/malaria_symptoms.csv')
X = df.drop('severity', axis=1)
y = df['severity']

# 2. Séparation entraînement/test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)

# 3. Modèle avec pipeline intégré
model = make_pipeline(
    RobustScaler(),
    GradientBoostingClassifier(
        n_estimators=150,
        max_depth=3,
        learning_rate=0.1,
        random_state=42
    )
)

# 4. Entraînement
model.fit(X_train, y_train)

# 5. Évaluation
print("Rapport de classification :\n")
print(classification_report(
    y_test, 
    model.predict(X_test),
    target_names=['Normal', 'Simple', 'Sévère']
))

# 6. Export ONNX
initial_type = [('input', FloatTensorType([None, 6]))]
onnx_model = skl2onnx.convert_sklearn(
    model,
    initial_types=initial_type,
    options={id(model): {'zipmap': False}}
)

with open("models/malaria_model.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())

print("\n✅ Modèle ONNX exporté dans models/malaria_model.onnx")

# 7. Test ONNX
sess = ort.InferenceSession("models/malaria_model.onnx")
input_name = sess.get_inputs()[0].name

# Test avec un cas sévère
test_case = np.array([[40.0, 1, 1, 1, 1, 1]], dtype=np.float32)
pred = sess.run(None, {input_name: test_case})[0]

print(f"\nTest ONNX - Cas sévère : Prédiction = {pred[0]} (attendu : 2)")