import os
import mlflow
import mlflow.pyfunc


def load_production_model():
    tracking_uri = os.environ.get("MLFLOW_TRACKING_URI", "http://localhost:5000")
    model_name = os.environ.get("MODEL_NAME", "iris-model")

    mlflow.set_tracking_uri(tracking_uri)

    model_uri = f"models:/{model_name}@staging"

    print(f"[MLFLOW] Loading model from {model_uri}")
    model = mlflow.pyfunc.load_model(model_uri)

    return model