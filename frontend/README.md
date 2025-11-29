# RaStress-HMI Frontend

A Flutter-based mobile application for real-time vital signs monitoring using mmWave radar technology. 

## Features

- **Real-time Vital Signs Monitoring**
  - Heart rate (BPM) with live waveform visualization
  - Breathing rate (breaths/min) with respiratory waveform
  - Energy levels for both heart and breath signals

- **Advanced Signal Processing**
  - High-frequency data acquisition (20-50Hz) from WebSocket
  - UI throttling at 10 FPS for optimal performance
  - Ring buffer implementation for smooth waveform rendering
  - Real-time signal quality assessment

- **Sensor Information Dashboard**
  - Detection range with range bin visualization
  - Maximum sensor range display
  - API connection status monitoring
  - Signal quality indicator with descriptive feedback

### Main Dashboard
- Real-time vital signs display
- Live waveform charts for heart and breathing
- Sensor information panel with signal quality

### Connection Status
- Real-time WebSocket connection monitoring
- Visual indicators for data reception status
- Automatic reconnection handling

## Technical Architecture

### Data Flow
```
mmWave Sensor → WebSocket Server → Flutter App
                      ↓
            High-frequency data (20-50Hz)
                      ↓
              Ring Buffer Processing
                      ↓
            UI Updates (10 FPS throttled)
```

### Key Components

#### Core Services
- **WebSocketService**: Handles real-time communication with the sensor backend
- **SensorData Model**: Data structure for parsing and managing sensor readings

#### UI Widgets
- **WaveformChart**: Custom painter for real-time signal visualization
- **StatCard**: Displays vital sign metrics with color-coded indicators
- **SensorInfoWidget**: Comprehensive sensor status and quality display
- **SectionTitle**: Consistent section headers with icons

#### Performance Optimization
- **UI Throttling**: Updates at 3 FPS to prevent excessive redraws
- **Ring Buffers**: Efficient memory management for waveform data
- **Data Caching**: Separates high-frequency data processing from UI updates

## Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Android Studio / VS Code
- Android device or emulator
- Access to mmWave sensor WebSocket server

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/WayanFWP/RaStress-HMI.git
   cd RaStress-HMI/frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   Create a `.env` file in the project root:
   ```env
   IP=your.server.ip.address
   PORT=your.server.port
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

#### Environment Variables (.env)
- `IP`: WebSocket server IP address
- `PORT`: WebSocket server port

#### Build Configuration
- **Target SDK**: Android API 34
- **Minimum SDK**: Android API 21
- **Gradle**: 8.12
- **JVM Heap**: 8GB allocated for build optimization

## Data Structure

### Sensor Data Model
```dart
class SensorData {
  final double heartRate;          // BPM
  final double breathRate;         // breaths/min
  final double heartEnergy;        // Signal energy
  final double breathEnergy;       // Signal energy
  final List<double> rangeProfile; // Range bins
  final double heartWaveform;      // Raw heart signal
  final double breathWaveform;     // Raw breath signal
}
```

### WebSocket Data Format
The app expects JSON data with the following structure:
```json
{
  "heartRateEst_FFT": 75.2,
  "breathingRateEst_FFT": 16.8,
  "sumEnergyHeartWfm": 1250.5,
  "sumEnergyBreathWfm": 890.3,
  "outputFilterHeartOut": 0.25,
  "outputFilterBreathOut": -0.15,
  "RangeProfile": [120.5, 340.2, ...]
}
```

## UI Components

### Color Scheme
- **Primary**: `#2BE4DC` (Cyan)
- **Secondary**: `#7B61FF` (Purple)
- **Background**: `#0A0F1C` (Dark Blue)
- **Cards**: `#151B2D` (Dark Gray)

### Typography
- **Font Family**: SF Pro
- **Headers**: 22px, Bold
- **Body**: 14-16px, Regular
- **Values**: 24-32px, Bold

## Performance Metrics

- **UI Update Rate**: 10 FPS (100ms intervals)
- **Data Acquisition**: 20-50 Hz from sensor
- **Waveform Buffer**: 120 points (6 seconds at 20Hz)
- **Memory Usage**: Optimized with ring buffers
- **Battery Life**: Efficient rendering reduces power consumption

## Development

### Project Structure
```
lib/
├── core/
│   ├── websocket_services.dart    # WebSocket communication
│   └── sensor_model.dart          # Data models
├── ui/
│   ├── screens/
│   │   └── dashboard_screen.dart  # Main application screen
│   ├── widgets/
│   │   ├── waveform_chart.dart    # Signal visualization
│   │   ├── stat_card.dart         # Metric display cards
│   │   ├── sensor_information.dart # Sensor status widget
│   │   └── section_title.dart     # Section headers
│   └── themes/
│       └── app_theme.dart         # Application theming
└── main.dart                      # Application entry point
```

### Build Commands

#### Development Build
```bash
flutter run --debug
```

#### Release Build
```bash
flutter build apk --release
```

#### Profile Build (Performance Testing)
```bash
flutter run --profile
```

## Troubleshooting

### Common Issues

#### Connection Problems
- Verify WebSocket server is running
- Check IP and PORT in `.env` file
- Ensure device is on the same network
- Check firewall settings

#### Performance Issues
- Monitor UI update rate (should be ~10 FPS)
- Check for memory leaks in waveform buffers
- Verify data throttling is working correctly

#### Build Errors
- Run `flutter clean` and `flutter pub get`
- Check Gradle configuration in `android/gradle.properties`
- Verify Flutter SDK version compatibility

### Debug Information
The app provides debug information:
- Connection status in header
- UI update rate display
- Signal quality indicators
- WebSocket connection state

## Dependencies

### Core Dependencies
- `flutter`: Framework
- `web_socket_channel`: WebSocket communication
- `flutter_dotenv`: Environment configuration

### UI Dependencies  
- `fl_chart`: Chart visualization (future use)
- `syncfusion_flutter_gauges`: Gauge widgets (future use)

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality