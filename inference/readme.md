# Inference Service (FastAPI + MLflow Registry)

This service loads a model from **MLflow Model Registry** and serves predictions via FastAPI.

## What this implements (production-ish)

- Loads a model from MLflow Registry:
  - Prefer alias: `models:/<MODEL_NAME>@<MODEL_ALIAS>`
  - Fallback to stage: `models:/<MODEL_NAME>/<MODEL_STAGE>`
- Metrics endpoint for Prometheus: `/metrics`
- Basic shared-secret auth (optional) for model reload:
  - Set `API_KEY` env var, then call `/model/reload` with header `X-API-Key`
- Simple drift monitoring (PSI) if training logged `baseline_stats.json`
  - Endpoint: `/drift`

## Environment variables

- `MLFLOW_TRACKING_URI` (required), e.g. `http://mlflow.mlflow.svc.cluster.local:5000`
- `MODEL_NAME` (default: `iris-model`)
- `MODEL_ALIAS` (default: `production`)
- `MODEL_STAGE` (default: `Production`) used if alias not found
- `API_KEY` (optional) protect `/model/reload`
- `DRIFT_WINDOW_SIZE` (default: 1000)

## Local run

```bash
export MLFLOW_TRACKING_URI=http://localhost:5000
export MODEL_NAME=iris-model
export MODEL_ALIAS=production

pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Test:

```bash
curl -s http://localhost:8000/health
curl -s -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"features":{"sepal_length":5.1,"sepal_width":3.5,"petal_length":1.4,"petal_width":0.2}}'
curl -s http://localhost:8000/metrics | head
```

## Notes about AWS / IRSA

If MLflow artifacts are stored in S3, this service also needs AWS credentials to **download model artifacts**.
On EKS you should use IRSA and a ServiceAccount annotated with the IAM role that allows:
- `sts:AssumeRoleWithWebIdentity`
- `s3:GetObject`, `s3:ListBucket` (and optionally `PutObject` if you also upload)

