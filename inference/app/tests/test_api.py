import app.main as main
from fastapi.testclient import TestClient
from app.main import app


import numpy as np

class DummyModel:
    def predict(self, df):
        return np.array([42] * len(df))


def setup_dummy_model():
   
    main.model = DummyModel()


def test_health_ok():
    setup_dummy_model()
    client = TestClient(app)

    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_predict_success():
    setup_dummy_model()
    client = TestClient(app)

    r = client.post(
        "/predict",
        json={
            "features": {
                "sepal_length": 5.1,
                "sepal_width": 3.5,
                "petal_length": 1.4,
                "petal_width": 0.2
            }
        }
    )

    assert r.status_code == 200

    body = r.json()

    assert "prediction" in body
    assert body["prediction"] == [42]
    assert "latency_ms" in body


def test_drift_endpoint():
    setup_dummy_model()
    client = TestClient(app)

    # 用 4 维数据（匹配 drift baseline）
    for _ in range(15):
        client.post(
            "/predict",
            json={
                "features": {
                    "sepal_length": 5.1,
                    "sepal_width": 3.5,
                    "petal_length": 1.4,
                    "petal_width": 0.2
                }
            }
        )

    r = client.get("/drift")
    assert r.status_code == 200
    assert "drift" in r.json()