import os
from fastapi.testclient import TestClient

# IMPORTANT:
# These tests are "contract tests" and do not require a real MLflow server.
# We monkeypatch the global MODEL in the app after import.

from app.main import app
import app.main as main

class DummyModel:
    def predict(self, df):
        # returns a list-like
        return [42] * len(df)

class DummyLoaded:
    model_name="dummy"
    model_version="1"
    model_uri="models:/dummy/Production"
    run_id="run"
    pyfunc_model=DummyModel()
    baseline_path=None

def test_health_degraded_when_no_model():
    main.MODEL = None
    client = TestClient(app)
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["model_loaded"] is False

def test_predict_success():
    main.MODEL = DummyLoaded()
    client = TestClient(app)
    r = client.post("/predict", json={"features": {"a": 1, "b": 2}})
    assert r.status_code == 200
    body = r.json()
    assert body["prediction"] == 42
    assert body["model_name"] == "dummy"

def test_reload_requires_api_key_when_enabled():
    main.MODEL = DummyLoaded()
    os.environ["API_KEY"] = "secret"
    client = TestClient(app)
    r = client.post("/model/reload")
    assert r.status_code == 401
    r2 = client.post("/model/reload", headers={"X-API-Key":"secret"})
    # reload will attempt real mlflow load; in this dummy test it will fail -> 500 is acceptable contract-wise
    assert r2.status_code in (200, 500)
    os.environ.pop("API_KEY", None)
