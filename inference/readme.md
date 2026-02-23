# ML Inference Service (FastAPI + MLflow Registry)

This service loads a model from **MLflow Model Registry** and exposes a prediction API using FastAPI.

---

## Features

- Loads model from MLflow Registry:
  - `models:/<MODEL_NAME>@<MODEL_ALIAS>`
- REST API for inference (`/predict`)
- Health endpoint (`/health`)
- Prometheus metrics endpoint (`/metrics`)
- Simple drift detection (mean distance baseline)
- Unit tests with pytest (no real MLflow required)

---

## Environment Variables

- `MLFLOW_TRACKING_URI` (required)
- `MODEL_NAME` (default: `iris-model`)
- `MODEL_ALIAS` (default: `staging`)
- `DRIFT_WINDOW_SIZE` (default: 1000)

Optional:
- `API_KEY` (protect `/model/reload` if implemented)

---

## Local Development

Install dependencies:

```bash
uv pip install -r requirements.txt
```

Run service:

```bash
uvicorn app.main:app --reload --port 8000
```

Run tests:

```bash
uv run pytest
```

---

## Example Request

```
POST /predict
```

```json
{
  "features": {
    "sepal_length": 5.1,
    "sepal_width": 3.5,
    "petal_length": 1.4,
    "petal_width": 0.2
  }
}
```

---

## AWS / IRSA Notes

If MLflow artifacts are stored in S3, this service requires:

- `sts:AssumeRoleWithWebIdentity`
- `s3:GetObject`
- `s3:ListBucket`

On EKS, use IRSA with a ServiceAccount bound to an IAM role.

---

## Architecture Overview

Training → MLflow Registry → Inference Service → Metrics & Drift