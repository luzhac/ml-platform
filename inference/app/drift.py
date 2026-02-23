import numpy as np


class DriftMonitor:

    def __init__(self, threshold=0.5, window_size=50):
        self.threshold = threshold
        self.window_size = window_size
        self.recent_data = []

        # 简单 baseline（Iris 训练均值）
        self.baseline_mean = np.array([0, 0, 0, 0])

    def update(self, feature_array):
        self.recent_data.append(feature_array)

        if len(self.recent_data) > self.window_size:
            self.recent_data.pop(0)

    def check_drift(self):
        if len(self.recent_data) < 10:
            return {"drift": False, "message": "Not enough data"}

        recent_mean = np.mean(self.recent_data, axis=0)
        distance = np.linalg.norm(recent_mean - self.baseline_mean)

        if distance > self.threshold:
            return {"drift": True, "distance": float(distance)}

        return {"drift": False, "distance": float(distance)}