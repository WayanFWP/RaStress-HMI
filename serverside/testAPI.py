# laptop_publisher.py
import os
import time
import json
import queue
import threading
import asyncio
import struct
import numpy as np
import serial
from collections import deque
from dotenv import load_dotenv
from pyqtgraph.Qt import QtWidgets
import pyqtgraph as pg
from mmvs.com import serialConfig, parseConfigFile

load_dotenv()
WS_RELAY_URL = os.getenv("WS_RELAY_URL")  # set your relay server here
WS_SEND_QUEUE_MAX = 1000

# -------------------- SHARED BUFFERS / STATE --------------------
send_queue = queue.Queue(maxsize=WS_SEND_QUEUE_MAX)

byteBuffer = np.zeros(2 ** 15, dtype='uint8')
byteBufferLength = 0
numRangeBinProcessed = 33 - 11 + 1

# Time-series and UI buffers
Breathsignal = list(range(0, 250))
Heartbeatsignal = list(range(0, 250))
Chestdisplacement = [0] * 250
Rangeprofile = [0] * 250
Breathenerge = [0] * 250
Heartenerge = [0] * 250

state = {
    "frameNumber": 0,
    "breathingRate_bpm": None,
    "heartRate_bpm": None,
    "breathing_confidence": None,
    "heart_confidence": None,
    "chestDisplacement_mm": None,
    "motionDetected": None,
    "rangeResolution_m": None,
    "rangeStart": None,
    "rangeEnd": None,
    "maxRange": None,
    "fps": 20,
    "rangeProfile": None
}

breath_wave = deque(maxlen=250)
heart_wave = deque(maxlen=250)
chest_wave = deque(maxlen=250)

# -------------------- UTIL --------------------
def safe_json(obj):
    """Convert parser outputs to JSON-serializable python types."""
    if obj is None:
        return None
    if isinstance(obj, (int, float, str, bool)):
        return obj
    if isinstance(obj, np.ndarray):
        return obj.tolist()
    if isinstance(obj, bytes):
        return obj.decode(errors='ignore')
    if isinstance(obj, dict):
        return {k: safe_json(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [safe_json(v) for v in obj]
    try:
        return float(obj)
    except Exception:
        return str(obj)

# -------------------- VITALS CALLBACK (same logic) --------------------
def on_new_vitals(vitalsign: dict, configParameters: dict, frameNumber: int | None = None):
    if frameNumber is not None:
        state["frameNumber"] = int(frameNumber)
    br = vitalsign.get("breathingRateEst_FFT")
    hr = vitalsign.get("heartRateEst_FFT")
    state["breathingRate_bpm"] = float(br) if br is not None else None
    state["heartRate_bpm"] = float(hr) if hr is not None else None
    cb = vitalsign.get("confidenceMetricBreathOut")
    ch = vitalsign.get("confidenceMetricHeartOut")
    state["breathing_confidence"] = float(cb) if cb is not None else None
    state["heart_confidence"] = float(ch) if ch is not None else None
    disp = vitalsign.get("unwrapPhasePeak_mm")
    state["chestDisplacement_mm"] = float(disp) if disp is not None else None
    motion = vitalsign.get("motionDetectedFlag", 0)
    try:
        state["motionDetected"] = bool(round(float(motion)))
    except Exception:
        state["motionDetected"] = False

    if configParameters:
        if "rangeResolutionMeters" in configParameters:
            state["rangeResolution_m"] = float(configParameters["rangeResolutionMeters"])
        if "rangeStart" in configParameters:
            state["rangeStart"] = float(configParameters["rangeStart"])
        if "rangeEnd" in configParameters:
            state["rangeEnd"] = float(configParameters["rangeEnd"])
        if "maxRange" in configParameters:
            state["maxRange"] = float(configParameters["maxRange"])

    rp = vitalsign.get("RangeProfile")
    if rp is not None:
        state["rangeProfile"] = [float(v) for v in rp]

    # Append waveform buffers
    if "outputFilterBreathOut" in vitalsign:
        try:
            breath_wave.append(float(vitalsign["outputFilterBreathOut"]))
        except Exception:
            pass
    if "outputFilterHeartOut" in vitalsign:
        try:
            heart_wave.append(float(vitalsign["outputFilterHeartOut"]))
        except Exception:
            pass
    if "unwrapPhasePeak_mm" in vitalsign:
        try:
            chest_wave.append(float(vitalsign["unwrapPhasePeak_mm"]))
        except Exception:
            pass

# -------------------- PARSER (copied, unchanged semantics) --------------------
def readAndParseData68xx(Dataport, configParameters):
    global byteBuffer, byteBufferLength, numRangeBinProcessed
    OBJ_STRUCT_SIZE_BYTES = 12
    BYTE_VEC_ACC_MAX_SIZE = 2 ** 15
    MMWDEMO_UART_MSG_DETECTED_POINTS = 1
    MMWDEMO_UART_MSG_RANGE_PROFILE = 2
    MMWDEMO_UART_MSG_VITALSIGN = 6
    maxBufferSize = 2 ** 15
    tlvHeaderLengthInBytes = 8
    pointLengthInBytes = 16
    magicWord = [2, 1, 4, 3, 6, 5, 8, 7]

    magicOK = 0
    dataOK = 0
    frameNumber = 0
    vitalsign = {}

    try:
        readBuffer = Dataport.read(Dataport.in_waiting or 1)
    except Exception:
        # serial read error -> no data
        return 0, None, None

    if not readBuffer:
        return 0, None, None

    byteVec = np.frombuffer(readBuffer, dtype='uint8')
    byteCount = len(byteVec)

    if (byteBufferLength + byteCount) < maxBufferSize:
        byteBuffer[byteBufferLength:(byteBufferLength + byteCount)] = byteVec[0:byteCount]
        byteBufferLength = byteBufferLength + byteCount

    if byteBufferLength > 16:
        possibleLocs = np.where(byteBuffer == magicWord[0])[0]
        startIdx = []
        for loc in possibleLocs:
            check = byteBuffer[loc:loc + 8]
            if np.all(check == magicWord):
                startIdx.append(loc)

        if startIdx:
            if 0 < startIdx[0] < byteBufferLength:
                byteBuffer[:byteBufferLength - startIdx[0]] = byteBuffer[startIdx[0]:byteBufferLength]
                byteBuffer[byteBufferLength - startIdx[0]:] = np.zeros(len(byteBuffer[byteBufferLength - startIdx[0]:]),
                                                                       dtype='uint8')
                byteBufferLength = byteBufferLength - startIdx[0]

            if byteBufferLength < 0:
                byteBufferLength = 0
            if byteBufferLength < 16:
                return dataOK, None, None
            totalPacketLen = int.from_bytes(byteBuffer[12:12 + 4], byteorder='little')
            if (byteBufferLength >= totalPacketLen) and (byteBufferLength != 0):
                magicOK = 1
    if magicOK:
        idX = 0
        # header
        idX += 8
        idX += 4
        totalPacketLen = int.from_bytes(byteBuffer[idX:idX + 4], byteorder='little'); idX += 4
        idX += 4
        frameNumber = int.from_bytes(byteBuffer[idX:idX + 4], byteorder='little'); idX += 4
        idX += 4
        vitalsign["numDetectedObj"] = numDetectedObj = int.from_bytes(byteBuffer[idX:idX + 4], byteorder='little'); idX += 4
        numTLVs = int.from_bytes(byteBuffer[idX:idX + 4], byteorder='little'); idX += 4
        idX += 4  # subFrameNumber

        for tlvIdx in range(numTLVs):
            tlv_type = int.from_bytes(byteBuffer[idX:idX + 4], byteorder='little'); idX += 4
            tlv_length = int.from_bytes(byteBuffer[idX:idX + 4], byteorder='little'); idX += 4

            if tlv_type == MMWDEMO_UART_MSG_VITALSIGN:
                vitalsign["rangeBinIndexMax"] = int.from_bytes(byteBuffer[idX:idX + 2], byteorder='little'); idX += 2
                vitalsign["rangeBinIndexPhase"] = int.from_bytes(byteBuffer[idX:idX + 2], byteorder='little'); idX += 2
                vitalsign["maxVal"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["processingCyclesOut"] = int.from_bytes(byteBuffer[idX:idX + 4], byteorder='little'); idX += 4
                vitalsign["rangeBinStartIndex"] = int.from_bytes(byteBuffer[idX:idX + 2], byteorder='little'); idX += 2
                vitalsign["rangeBinEndIndex"] = int.from_bytes(byteBuffer[idX:idX + 2], byteorder='little'); idX += 2
                vitalsign["unwrapPhasePeak_mm"] = byteBuffer[idX:idX + 4].view(dtype=np.float32)[0]; idX += 4
                vitalsign["outputFilterBreathOut"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["outputFilterHeartOut"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["heartRateEst_FFT"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["heartRateEst_FFT_4Hz"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0] / 2; idX += 4
                vitalsign["heartRateEst_xCorr"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["heartRateEst_peakCount"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["breathingRateEst_FFT"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["breathingRateEst_xCorr"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["breathingRateEst_peakCount"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["confidenceMetricBreathOut"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["confidenceMetricBreathOut_xCorr"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["confidenceMetricHeartOut"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["confidenceMetricHeartOut_4Hz"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["confidenceMetricHeartOut_xCorr"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["sumEnergyBreathWfm"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["sumEnergyHeartWfm"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                vitalsign["motionDetectedFlag"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]; idX += 4
                idX += 40
                # RPlength may be after the 40 bytes offset (original code)
                try:
                    vitalsign["RPlength"] = struct.unpack('<f', byteBuffer[idX:idX + 4])[0]
                except Exception:
                    pass
                dataOK = 1

            if tlv_type == MMWDEMO_UART_MSG_RANGE_PROFILE:
                if vitalsign.__contains__("rangeBinEndIndex"):
                    numRangeBinProcessed = vitalsign["rangeBinEndIndex"] - vitalsign["rangeBinStartIndex"] + 1
                vitalsign["RangeProfile"] = []
                for i in range(numRangeBinProcessed):
                    RPrealpart = int.from_bytes(byteBuffer[idX:idX + 2], byteorder='big'); idX += 2
                    RPimagelpart = int.from_bytes(byteBuffer[idX:idX + 2], byteorder='big'); idX += 2
                    vitalsign["RangeProfile"].append((RPrealpart * RPrealpart + RPimagelpart * RPimagelpart) ** 0.5)

        if 0 < idX < byteBufferLength:
            shiftSize = totalPacketLen
            byteBuffer[:byteBufferLength - shiftSize] = byteBuffer[shiftSize:byteBufferLength]
            byteBuffer[byteBufferLength - shiftSize:] = np.zeros(len(byteBuffer[byteBufferLength - shiftSize:]), dtype='uint8')
            byteBufferLength = byteBufferLength - shiftSize
            if byteBufferLength < 0:
                byteBufferLength = 0

    return dataOK, frameNumber, vitalsign

# -------------------- UPDATE (UI + enqueue to WS) --------------------
def update_and_enqueue(Dataport, configParameters):
    dataOk, frameNumber, vitalsign = readAndParseData68xx(Dataport, configParameters)
    if dataOk:
        # update plotting buffers
        try:
            Breathsignal.append(vitalsign["outputFilterBreathOut"])
            Heartbeatsignal.append(vitalsign["outputFilterHeartOut"])
            Chestdisplacement.append(float(vitalsign["unwrapPhasePeak_mm"]))
            Breathenerge.append(float(vitalsign["sumEnergyBreathWfm"]) / 1e6)
            Heartenerge.append(float(vitalsign["sumEnergyHeartWfm"]))
            if vitalsign.__contains__("RangeProfile"):
                global Rangeprofile
                Rangeprofile = vitalsign["RangeProfile"]
        except Exception:
            pass

        # trim
        if len(Breathsignal) > 250: Breathsignal.pop(0)
        if len(Heartbeatsignal) > 250: Heartbeatsignal.pop(0)
        if len(Chestdisplacement) > 250: Chestdisplacement.pop(0)
        if len(Breathenerge) > 250: Breathenerge.pop(0)
        if len(Heartenerge) > 250: Heartenerge.pop(0)

        # update label/UI if present (s1..s6 expected to be defined globally)
        try:
            s1.setData(np.array((list(range(0, 250)), Breathsignal)).T)
            s2.setData(np.array((list(range(0, 250)), Heartbeatsignal)).T)
            s3.setData(np.array((list(range(0, 250)), Chestdisplacement)).T)
            s4.setData(np.array((list(np.arange(0, numRangeBinProcessed * configParameters["rangeResolutionMeters"], configParameters["rangeResolutionMeters"])), Rangeprofile)).T)
            s5.setData(np.array((list(range(0, 250)), Breathenerge)).T)
            s6.setData(np.array((list(range(0, 250)), Heartenerge)).T)
            labelItem1.setText(text='Breath Rate:' + str(vitalsign.get("breathingRateEst_FFT", "")), size='12pt', color='#000000')
            labelItem2.setText(text='Heart Rate:' + str(vitalsign.get("heartRateEst_FFT", "")), size='12pt', color='#000000')
            QtWidgets.QApplication.processEvents()
        except Exception:
            pass

        # push to local state
        on_new_vitals(vitalsign, configParameters, frameNumber=frameNumber)

        # enqueue JSON-safe payload to send queue
        payload = {
            "ts": time.time(),
            "frame": int(frameNumber),
            "vitals": safe_json(vitalsign),
            "config": safe_json(configParameters)
        }
        try:
            send_queue.put_nowait(payload)
        except queue.Full:
            # queue overloaded -> drop oldest then put
            try:
                _ = send_queue.get_nowait()
                send_queue.put_nowait(payload)
            except Exception:
                pass

        return True
    return False

# -------------------- ASYNC WEBSOCKET SENDER --------------------
async def ws_sender_loop(loop_stop_event: threading.Event):
    import websockets
    backoff = 1.0
    while not loop_stop_event.is_set():
        try:
            async with websockets.connect(WS_RELAY_URL, ping_interval=10, ping_timeout=5) as ws:
                print(f"[WS] Connected to relay {WS_RELAY_URL}")
                backoff = 1.0
                # send loop: drain queue and send messages
                while not loop_stop_event.is_set():
                    try:
                        payload = send_queue.get(timeout=0.5)  # blocking with timeout
                    except queue.Empty:
                        await asyncio.sleep(0.01)
                        continue
                    # send as compact JSON
                    try:
                        await ws.send(json.dumps(payload, separators=(",", ":"), ensure_ascii=False))
                    except Exception as e:
                        # push back if send fails
                        try:
                            send_queue.put_nowait(payload)
                        except Exception:
                            pass
                        raise e
        except Exception as e:
            print(f"[WS] Connection failed: {e}. Reconnect in {backoff:.1f}s")
            await asyncio.sleep(backoff)
            backoff = min(backoff * 1.5, 30.0)

def start_ws_thread(loop_stop_event: threading.Event):
    asyncio.run(ws_sender_loop(loop_stop_event))

# -------------------- SETUP SERIAL + CONFIG --------------------
# using your serialConfig helper from mmVS.com
CLIport, Dataport = serialConfig('profiles/xwr6843_profile_VitalSigns_20fps_Front.cfg')
configParameters = parseConfigFile('profiles/xwr6843_profile_VitalSigns_20fps_Front.cfg')

# populate state with config
try:
    state["rangeResolution_m"] = float(configParameters.get("rangeResolutionMeters", state["rangeResolution_m"]))
    state["rangeStart"] = float(configParameters.get("rangeStart", 0.0))
    state["rangeEnd"] = float(configParameters.get("rangeEnd", 0.0))
    state["maxRange"] = float(configParameters.get("maxRange", 0.0))
    if "fps" in configParameters:
        state["fps"] = int(configParameters["fps"])
except Exception:
    pass

# -------------------- START WS SENDER THREAD --------------------
loop_stop_event = threading.Event()
ws_thread = threading.Thread(target=start_ws_thread, args=(loop_stop_event,), daemon=True)
ws_thread.start()

# -------------------- SETUP UI (pyqtgraph) --------------------
app_qt = QtWidgets.QApplication([])
pg.setConfigOption('background', 'w')
win = pg.GraphicsLayoutWidget(show=True, title="Vital Sign")
win.resize(1200, 700)

# Plot panels (same as original)
p1 = win.addPlot(row=1, col=0)
p1.setTitle("Breathing Waveform", color=(0, 128, 128), size='12pt')
p1.setXRange(0, 250)
p1.setYRange(-2, 2)
p1.setLabel('left', text='Position (mm)')
p1.setLabel('bottom', text='Time (pre 50ms)')
s1 = p1.plot([], [], pen=pg.mkPen(width=2))

labelItem1 = pg.LabelItem(text='Breath Rate:')
win.addItem(labelItem1, row=0, col=0)

p2 = win.addPlot(row=1, col=1)
p2.setTitle("Cardiac Waveform", color='#008080', size='12pt')
p2.setXRange(0, 250)
p2.setYRange(-2, 2)
p2.setLabel('left', text='Position (mm)')
p2.setLabel('bottom', text='Time (pre 50ms)')
s2 = p2.plot([], [], pen=pg.mkPen(width=2))

labelItem2 = pg.LabelItem(text='Heartbeat Rate:')
win.addItem(labelItem2, row=0, col=1)

p3 = win.addPlot(row=2, col=0)
p3.setTitle("Chest Displacement", color='#008080', size='12pt')
p3.setXRange(0, 250)
p3.setLabel('left', text='Displacement (a.u.)')
p3.setLabel('bottom', text='Frame (pre index)')
s3 = p3.plot([], [], pen=pg.mkPen(width=2))

p4 = win.addPlot(row=2, col=1)
p4.setTitle("Range Profile", color='#008080', size='12pt')
p4.setLabel('left', text='Magnitude (a.u.)')
p4.setLabel('bottom', text='Range (m)')
p4.setYRange(0, 100000, padding=0)
s4 = p4.plot([], [], pen=pg.mkPen(width=2))

p5 = win.addPlot(row=3, col=0)
p5.setTitle("Breath Energy", color='#008080', size='12pt')
p5.setXRange(0, 250)
p5.setLabel('left', text='Wave Energy (a.u.10^6)')
p5.setLabel('bottom', text='Time (pre 50ms)')
s5 = p5.plot([], [], pen=pg.mkPen(width=2))

p6 = win.addPlot(row=3, col=1)
p6.setTitle("Cardiac Energy", color='#008080', size='12pt')
p6.setXRange(0, 250)
p6.setLabel('left', text='Wave Energy (a.u.)')
p6.setLabel('bottom', text='Time (pre 50ms)')
s6 = p6.plot([], [], pen=pg.mkPen(width=2))

# show config labels
labelItem3 = pg.LabelItem(text='Range Start:')
win.addItem(labelItem3, row=5, col=0)
labelItem3.setText(text='Range Start:' + str(configParameters.get("rangeStart", "")) + " m", size='12pt')

labelItem4 = pg.LabelItem(text='Range End:')
win.addItem(labelItem4, row=5, col=1)
labelItem4.setText(text='Range End:' + str(configParameters.get("rangeEnd", "")) + " m", size='12pt')

labelItem5 = pg.LabelItem(text='Max Range:')
win.addItem(labelItem5, row=6, col=0)
labelItem5.setText(text='Max Range:' + str(round(configParameters.get("maxRange", 0.0), 2)) + " m", size='12pt')

labelItem6 = pg.LabelItem(text='Range Resolution Meters:')
win.addItem(labelItem6, row=6, col=1)
labelItem6.setText(text='Range Resolution:' + str(round(configParameters.get("rangeResolutionMeters", 0.0) * 100, 2)) + " cm", size='12pt')

# -------------------- MAIN LOOP --------------------
try:
    while True:
        try:
            update_and_enqueue(Dataport, configParameters)
            # small sleep to reduce CPU; adjust to match radar fps
            time.sleep(0.005)
        except Exception:
            time.sleep(0.01)
except KeyboardInterrupt:
    print("Shutting down...")
    loop_stop_event.set()
    ws_thread.join(timeout=2)
    try:
        CLIport.write(('sensorStop\n').encode())
    except Exception:
        pass
    try:
        CLIport.close()
        Dataport.close()
    except Exception:
        pass
    try:
        win.close()
    except Exception:
        pass
