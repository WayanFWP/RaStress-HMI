import asyncio
import websockets
import json
import sys
from mmvs.source import DummySensor, RealSensor
from mmvs.config import SensorConfig
from dotenv import load_dotenv
import os

load_dotenv()  

# --- CONFIGURATION ---
USE_DUMMY_DATA = True
IP = os.getenv("IP")
PORT = os.getenv("PORT")

SERVER_URI = f"ws://{IP}:{PORT}"

# ---------------------

async def send_vital_signs():
    if USE_DUMMY_DATA:
        sensor = DummySensor()
    else:
        # Load config real sensor
        cfg = SensorConfig()
        lines = cfg.parse_file("profiles/xwr6843_profile_VitalSigns_20fps_Front.cfg")
        sensor = RealSensor(lines, '/dev/ttyUSB0', '/dev/ttyUSB1')

    print(f"[LAPTOP] Connecting to {SERVER_URI}...")
    try:
        async with websockets.connect(SERVER_URI) as websocket:
            print("[LAPTOP] Connected! Sending data stream...")
            
            while True:
                data = sensor.get_data()

                if data:
                    json_payload = json.dumps(data)
                    await websocket.send(json_payload)                    
                    print(f"\r[Sent] HR: {int(data.get('heartRateEst_FFT',0))} | BR: {int(data.get('breathingRateEst_FFT',0))}", end="")
                await asyncio.sleep(0.05)

    except ConnectionRefusedError:
        print(f"\n[ERROR] Could not connect to server at {SERVER_URI}. Is server.py running?")
    except KeyboardInterrupt:
        print("\n[INFO] Stopping...")
    finally:
        sensor.stop()

if __name__ == "__main__":
    asyncio.run(send_vital_signs())