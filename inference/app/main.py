import time
import pandas as pd
from fastapi import FastAPI
from pydantic import BaseModel
from typing import Dict, Any
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response
from contextlib import asynccontextmanager

from app.mlflow_loader import load_production_model
from app.metrics import REQUEST_COUNT, REQUEST_ERRORS, REQUEST_LATENCY
from app.drift import DriftMonitor


model = None
drift_monitor = DriftMonitor()


@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    try:
        model = load_production_model()
        print("[SYSTEM] Model loaded successfully")
    except Exception as e:
        print(f"[SYSTEM] Model load failed: {e}")
        model = None
    yield


app = FastAPI(
    lifespan=lifespan,
    docs_url="/swagger",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    title="Iris Production Inference API",
    version="1.0.0"
)

model = None
drift_monitor = DriftMonitor()


class PredictionRequest(BaseModel):
    features: Dict[str, Any]


 

@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict")
def predict(request: PredictionRequest):
    REQUEST_COUNT.inc()

    start_time = time.time()

    try:
        df = pd.DataFrame([request.features])
        prediction = model.predict(df)

        feature_array = df.values[0]
        drift_monitor.update(feature_array)

        latency = time.time() - start_time
        REQUEST_LATENCY.observe(latency)

        return {
            "prediction": prediction.tolist(),
            "latency_ms": round(latency * 1000, 2)
        }

    except Exception as e:
        REQUEST_ERRORS.inc()
        return {"error": str(e)}


@app.get("/drift")
def check_drift():
    return drift_monitor.check_drift()


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)