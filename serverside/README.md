<!-- filepath: /mnt/dev/project/RaStrest/README.md -->
# RaStrest

A real-time vital signs monitoring system using mmWave radar sensors for contactless heart rate and breathing rate detection.

## Overview

RaStrest is a comprehensive sensor data pipeline that captures vital signs data from TI mmWave radar sensors and streams it to mobile applications via WebSocket communication. The system supports both real sensor hardware and simulation modes for development and testing.

## Architecture

The system follows a multi-stage pipeline architecture:

```
mmWave Sensor → Laptop → WebSocket Server → Mobile App
     ↓             ↓           ↓              ↓
   Hardware     main.py    server.py    Flutter App
```

### Pipeline Flow

1. **Sensor Connection**: TI mmWave radar sensor (XWR6843) connects to laptop via USB serial ports
2. **Data Collection**: [`main.py`](main.py) handles sensor configuration and real-time data acquisition
3. **Data Transmission**: [`server.py`](server.py) provides WebSocket server for real-time data streaming
4. **Mobile Frontend**: Flutter-based mobile application receives and visualizes vital signs data *(Work in Progress)*

## Components

### Core Modules

#### [`main.py`](main.py) - Main Data Collection Controller
- Configures and manages sensor connections
- Supports both real hardware and dummy simulation modes
- Streams vital signs data via WebSocket client
- Real-time data processing and transmission

#### [`server.py`](server.py) - WebSocket Communication Server
- Asynchronous WebSocket server using `websockets` library
- Broadcasts sensor data to all connected mobile clients
- Handles multiple client connections simultaneously
- Environment-based configuration via `.env` file

### MMVS Package (`mmvs/`)

#### [`source.py`](mmvs/source.py) - Data Source Management
- **`DummySensor`**: Simulated vital signs data generator for testing
- **`RealSensor`**: Hardware interface for TI mmWave radar sensors
- Abstracts data collection with unified interface

#### [`parser.py`](mmvs/parser.py) - Radar Data Processing
- Parses TI mmWave binary data streams
- Extracts vital signs metrics (heart rate, breathing rate)
- Handles range profile and vital signs TLV messages
- Real-time frame synchronization and buffer management

#### [`connection.py`](mmvs/connection.py) - Hardware Communication
- Serial port management for CLI and data channels
- Sensor configuration command transmission
- Raw data buffer reading from radar sensor

#### [`config.py`](mmvs/config.py) - Configuration Management
- Parses mmWave CLI configuration files
- Calculates radar parameters (range resolution, max range)
- Supports various sensor profiles

### Configuration

#### [`profiles/xwr6843_profile_VitalSigns_20fps_Front.cfg`](profiles/xwr6843_profile_VitalSigns_20fps_Front.cfg)
- TI mmWave sensor configuration profile
- Optimized for vital signs detection at 20 FPS
- Front-facing radar setup parameters

## Data Format

The system streams vital signs data in JSON format containing:

```json
{
  "frame": 1234,
  "heartRateEst_FFT": 75.2,
  "breathingRateEst_FFT": 14.1,
  "outputFilterBreathOut": 0.15,
  "outputFilterHeartOut": 0.08,
  "unwrapPhasePeak_mm": 2.3,
  "sumEnergyBreathWfm": 1000,
  "sumEnergyHeartWfm": 500,
  "RangeProfile": [...]
}
```

## Getting Started

### Prerequisites

- Python 3.7+
- TI mmWave radar sensor (XWR6843) *(optional - can use dummy mode)*
- Serial port access (`/dev/ttyUSB0`, `/dev/ttyUSB1` on Linux or `COM3`, `COM4` on Windows)
- Mobile device for testing *(Flutter app in development)*

### Dependencies

Install the required Python packages:

```bash
pip install websockets python-dotenv pyserial numpy asyncio
```

Or using a requirements.txt file:

```txt
websockets>=11.0.3
python-dotenv>=1.0.0
pyserial>=3.5
numpy>=1.24.0
```

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd RaStrest
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   # or manually:
   pip install websockets python-dotenv pyserial numpy
   ```

3. Create environment configuration:
   ```bash
   cp .env.example .env
   # Edit .env with your IP and port settings
   ```

### Usage

#### 1. Start the WebSocket Server

```bash
python server.py
```

The server will start on the configured IP and port (default: localhost:8765).

#### 2. Run Data Collection

**Simulation Mode (No Hardware Required):**
```bash
# Edit main.py: set USE_DUMMY_DATA = True
python main.py
```

**Real Sensor Mode:**
```bash
# Edit main.py: set USE_DUMMY_DATA = False
# Ensure sensor is connected to serial ports
python main.py
```

#### 3. Connect Mobile Client

The Flutter mobile application (in development) will connect to the WebSocket server to receive real-time vital signs data.

### Environment Variables

Create a `.env` file with:

```env
IP=localhost
PORT=8765
```

## Development Status

- ✅ mmWave sensor integration and data parsing
- ✅ Real-time WebSocket data streaming
- ✅ Simulation mode for development
- ✅ Multi-client server support
- ✅ Cross-platform compatibility (Windows/Linux)
- 🚧 Flutter mobile application frontend
- 📋 Comprehensive testing and documentation

## Technical Details

### Sensor Capabilities
- **Heart Rate Detection**: 30-200 BPM range
- **Breathing Rate Detection**: 5-40 breaths/minute
- **Range**: 0.3-0.9 meters (configurable)
- **Frame Rate**: 20 FPS
- **Contactless**: No physical contact required

### Communication Protocol
- **WebSocket**: Real-time bidirectional communication
- **JSON Format**: Structured data transmission
- **Asynchronous**: Non-blocking server architecture

## Troubleshooting

### Common Issues

1. **Serial Port Access**: 
   - Linux: Ensure proper permissions for `/dev/ttyUSB*` devices (`sudo usermod -a -G dialout $USER`)
   - Windows: Check Device Manager for correct COM port numbers
2. **Connection Refused**: Verify server is running before starting main.py
3. **Sensor Configuration**: Check that config file path is correct and sensor is properly connected
4. **Module Not Found**: Ensure all dependencies are installed (`pip install -r requirements.txt`)

### Debug Mode

Set `USE_DUMMY_DATA = True` in [`main.py`](main.py) for testing without hardware.