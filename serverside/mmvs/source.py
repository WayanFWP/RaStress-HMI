import time
import math
import random
import asyncio
from abc import ABC, abstractmethod
from .connection import RadarConnection # From previous step
from .parser import DataParser          # From previous step

class DataSource(ABC):
    @abstractmethod
    def get_data(self):
        """Returns a dictionary of vital sign data or None."""
        pass

    @abstractmethod
    def stop(self):
        pass

class DummySensor(DataSource):
    def __init__(self):
        self.t = 0
        print("[INFO] Using Dummy Sensor (Simulation Mode)")

    def get_data(self):
        # Simulate 20 FPS roughly
        self.t += 0.05 
        
        breath_wave = math.sin(2 * math.pi * 0.2 * self.t) + (random.random() * 0.1)
        heart_wave = math.sin(2 * math.pi * 1.2 * self.t) + (random.random() * 0.1)

        data = {
            "frame": int(self.t * 20),
            "heartRateEst_FFT": 75 + (math.sin(self.t)*2), 
            "breathingRateEst_FFT": 14 + (math.sin(self.t)*1), 
            "outputFilterBreathOut": breath_wave,
            "outputFilterHeartOut": heart_wave,
            "unwrapPhasePeak_mm": breath_wave * 5, 
            "sumEnergyBreathWfm": 1000,
            "sumEnergyHeartWfm": 500,
            "RangeProfile": [abs(math.sin(x + self.t)) * 1000 for x in range(50)]
        }
        return data

    def stop(self):
        print("[INFO] Stopping Dummy Sensor")

class RealSensor(DataSource):
    def __init__(self, config_lines, cli_port, data_port):
        print(f"[INFO] Connecting to Real Sensor at {cli_port}")
        self.radar = RadarConnection(cli_port, data_port)
        self.radar.connect()
        self.radar.send_configuration(config_lines)
        self.parser = DataParser()

    def get_data(self):
        # Read bytes
        raw_data = self.radar.read_into_buffer()
        if raw_data:
            return self.parser.parse_stream(raw_data)
        return None

    def stop(self):
        self.radar.stop_sensor()
        self.radar.close()