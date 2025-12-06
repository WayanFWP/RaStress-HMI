import time
import math
import random
import asyncio
from abc import ABC, abstractmethod
from .connection import RadarConnection
from .parser import DataParser

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
        self.base_heart_rate = 75  # Base heart rate
        self.base_breath_rate = 16  # Base breathing rate
        print("[INFO] Using Dummy Sensor (Simulation Mode)")

    def get_data(self):
        # Simulate 20 FPS (50ms per frame)
        self.t += 0.05 
        
        # Generate realistic vital signs
        current_hr = self.base_heart_rate + random.uniform(-3, 3)
        current_br = self.base_breath_rate + random.uniform(-1, 1)
        
        # Heart waveform: Fast spiky pattern (1.25 Hz = 75 BPM)
        heart_freq = current_hr / 60.0  # Convert BPM to Hz
        heart_base = math.sin(2 * math.pi * heart_freq * self.t)
        heart_spike = 0
        
        phase = (2 * math.pi * heart_freq * self.t) % (2 * math.pi)
        if 0 < phase < 0.3:  # Systolic peak
            heart_spike = 3 * math.exp(-10 * (phase - 0.15)**2)
        elif 0.3 < phase < 0.5:  # Small diastolic bump
            heart_spike = 0.5 * math.exp(-20 * (phase - 0.4)**2)
            
        heart_wave = heart_base + heart_spike + random.uniform(-0.05, 0.05)
        
        # Breathing waveform: Slower smooth pattern (0.27 Hz = 16 breaths/min)
        breath_freq = current_br / 60.0  # Convert breaths/min to Hz
        breath_wave = math.sin(2 * math.pi * breath_freq * self.t) + random.uniform(-0.1, 0.1)
        
        # Chest displacement in mm (based on breathing)
        chest_displacement = 2.5 + 1.5 * breath_wave  # 1-4mm range
        
        # Energy levels (simulate processing outputs)
        heart_energy = 800 + 200 * abs(heart_wave) + random.uniform(-50, 50)
        breath_energy = 1200 + 300 * abs(breath_wave) + random.uniform(-80, 80)
        
        # Range profile simulation 
        range_profile = []
        for i in range(64):  # 64 range bins
            distance_m = 0.3 + (i * 0.02)  # 0.3m to 1.6m range
            # Simulate human body reflection at ~1m
            if 0.8 <= distance_m <= 1.2:
                reflection = 800 + 400 * math.exp(-5 * (distance_m - 1.0)**2)
                reflection += 100 * abs(breath_wave)  # Breathing modulation
            else:
                reflection = 50 + random.uniform(0, 30)  # Background noise
            range_profile.append(reflection)

        data = {
            "frame": int(self.t * 20),
            "vitals": {
                # Vital signs
                "heartRateEst_FFT": current_hr,
                "breathingRateEst_FFT": current_br,
                
                # Waveform outputs (these are the key for your charts)
                "outputFilterBreathOut": breath_wave,
                "outputFilterHeartOut": heart_wave,
                
                # Physical measurements
                "unwrapPhasePeak_mm": chest_displacement,
                
                # Energy measurements
                "sumEnergyBreathWfm": breath_energy,
                "sumEnergyHeartWfm": heart_energy,
                
                # Range profiless
                "RangeProfile": range_profile,
                
                # Additional fields for completeness
                "rangeBinIndexMax": 45,  # Peak at ~1m
                "rangeBinIndexPhase": 45,
                "maxVal": max(range_profile),
                "processingCyclesOut": int(self.t * 1000) % 10000,
                "rangeBinStartIndex": 15,  # 0.6m
                "rangeBinEndIndex": 60,   # 1.5m
            }
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