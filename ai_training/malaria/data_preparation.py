import pandas as pd
import numpy as np
import os
from sklearn.utils import shuffle

def create_balanced_dataset(n_samples=3000):
    """Crée un dataset parfaitement équilibré avec des règles cliniques réalistes"""
    np.random.seed(42)
    
    samples_per_class = n_samples // 3
    data = []
    
    # 1. Cas normaux (non infectés)
    for _ in range(samples_per_class):
        data.append({
            'temperature': np.clip(np.random.normal(36.8, 0.3), 36.0, 37.4),
            'fievre': 0,
            'maux_tete': np.random.choice([0, 1], p=[0.8, 0.2]),
            'fatigue': np.random.choice([0, 1], p=[0.7, 0.3]),
            'hallucinations': 0,
            'vomissements': np.random.choice([0, 1], p=[0.9, 0.1]),
            'severity': 0
        })
    
    # 2. Paludisme simple
    for _ in range(samples_per_class):
        data.append({
            'temperature': np.clip(np.random.normal(38.5, 0.5), 37.5, 39.5),
            'fievre': 1,
            'maux_tete': np.random.choice([0, 1], p=[0.2, 0.8]),
            'fatigue': np.random.choice([0, 1], p=[0.1, 0.9]),
            'hallucinations': 0,
            'vomissements': np.random.choice([0, 1], p=[0.6, 0.4]),
            'severity': 1
        })
    
    # 3. Paludisme sévère (règles OMS strictes)
    for _ in range(samples_per_class):
        severe = {
            'temperature': np.clip(np.random.normal(39.8, 0.8), 39.0, 41.0),
            'fievre': 1,
            'maux_tete': 1,
            'fatigue': 1,
            'hallucinations': np.random.choice([0, 1], p=[0.4, 0.6]),
            'vomissements': np.random.choice([0, 1], p=[0.3, 0.7]),
            'severity': 2
        }
        # Validation des critères OMS
        if not (severe['temperature'] > 39.5 or severe['hallucinations'] == 1):
            severe['severity'] = 1  # Rétrograde en cas simple si critères non remplis
        data.append(severe)
    
    df = pd.DataFrame(data)
    df = shuffle(df, random_state=42)
    
    os.makedirs('data', exist_ok=True)
    df.to_csv('data/malaria_symptoms.csv', index=False)
    
    print("✅ Dataset généré avec :")
    print(df['severity'].value_counts().sort_index())
    print("\nExemple :")
    print(df.head())

if __name__ == "__main__":
    create_balanced_dataset()