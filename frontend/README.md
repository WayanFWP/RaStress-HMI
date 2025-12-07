# RaStress-HMI Frontend

A Flutter-based mobile application for real-time vital signs monitoring using mmWave radar technology.

## Features

### Home Dashboard
- **Circular Stress Level Indicator** - Visual representation of stress levels (Relaxed/Normal/High Stress)
- **Real-time Vital Signs Summary** - Average heart rate and breathing rate trends
- **Multiple Source Detection** - Warns when multiple breathing sources are detected
- **Live Connection Status** - Real-time WebSocket connection monitoring
- **Tappable Trend Cards** - Quick access to detailed trend analysis

### Sensor Information Screen
- **Live Waveform Visualization** - Real-time heart and breathing waveforms
- **Detection Range Analysis** - Range profile with bin visualization
- **Signal Quality Assessment** - Quality percentage with color-coded indicators
- **Vital Signs Display** - Current heart rate, breathing rate, and chest displacement
- **High-frequency Data Processing** - Optimized 1 FPS UI updates from 20-50Hz sensor data

### Trend Analysis
- **Historical Data Tracking** - Up to 5 minutes of vital signs trends
- **Interactive Charts** - Heart rate and breathing rate trend visualization
- **Statistical Summaries** - Min, max, and average calculations
- **Export to WhatsApp** - Share trend charts with text summaries
- **Real-time Updates** - Data aggregated every 3 seconds

### Stress Detail Analysis
- **Comprehensive Stress Metrics** - Detailed stress level breakdown
- **Vital Alerts System** - Real-time alerts for abnormal vital signs
- **Animated Progress Indicators** - Visual representation of heart and breathing rates
- **Historical Context** - Timestamp-based stress level tracking
- **Alert Categories**: High/low heart rate, high/low breathing rate, sudden movement detection

### Settings & Customization
- **Theme Options**: Neon (default), Dark Monochrome, Light, Night Owl
- **Font Size Adjustment**: Small, Medium, Large with live preview
- **Dyslexic Font Support**: OpenDyslexic font option
- **Color Blind Modes**: Support for Protanopia, Deuteranopia, and Tritanopia
- **Persistent Settings**: All preferences saved across sessions

### Alert System
- High Heart Rate (>100 BPM)
- Low Heart Rate (<50 BPM)
- High Breathing Rate (>25 breaths/min)
- Low Breathing Rate (<10 breaths/min)
- Sudden Movement Detection (>5mm displacement change)

## Technical Architecture

### Data Flow
```
mmWave Sensor → WebSocket Server → Flutter App
                      ↓
            High-frequency data (20-50Hz)
                      ↓
        ┌─────────────┴──────────────┐
        ↓                            ↓
  WaveformService            StressLevelService
  (Ring Buffers)              (5-sec analysis)
        ↓                            ↓
  UI Updates (1 FPS)      TrendService (3-sec aggregation)
                                     ↓
                          Historical Data (5 min buffer)
```

### Core Architecture

#### Core Services (`lib/core/`)
- **WebSocketService** - Real-time WebSocket communication with auto-reconnect
- **WaveformService** - Waveform data processing with ring buffers (120 points)
- **TrendService** - Historical trend aggregation (3-second intervals, 100 points max)
- **StressLevelService** - Stress analysis engine (5-second intervals)
- **SettingsService** - Persistent user preferences with ChangeNotifier
- **RangeProfileAnalyzer** - Multi-source detection and peak analysis
- **TrendExportService** - Chart capture and WhatsApp sharing

#### UI Components (`lib/ui/`)

**Screens:**
- `HomeScreen` - Main dashboard with stress indicator
- `SensorInfoScreen` - Live waveforms and sensor data
- `TrendDetailScreen` - Historical trend analysis
- `StressDetailScreen` - Detailed stress metrics
- `SettingsScreen` - User preferences and customization
- `MainNavigationScreen` - Bottom navigation controller

**Widgets:**
- `CircularStressIndicator` - Animated stress level gauge
- `WaveFormCard` - Real-time waveform visualization
- `StatCard` / `StatCardWithWaveform` - Metric display cards
- `SensorInfoWidget` - Comprehensive sensor status
- `ShareableTrendChart` - Exportable trend visualization
- `AlertCard` - Visual alert notifications
- `StatusBadge` - Connection status indicator
- `SectionHeader` - Consistent section headers

#### Utilities (`lib/core/utils/`)
- **VitalSignsUtils** - Vital signs calculations and status checks
- **VitalAlertsChecker** - Alert detection and validation

#### Constants (`lib/core/constants/`, `lib/ui/constants/`)
- **AppConstants** - Application-wide configuration values
- **UIConstants** - UI styling constants with theme-aware helpers

### Performance Optimization
- **UI Throttling**: Sensor screen updates at 1 FPS (1-second intervals)
- **Ring Buffers**: Efficient waveform memory management (120 points = 6 seconds)
- **Data Aggregation**: Trend data collected every 3 seconds
- **Stress Analysis**: Computed every 5 seconds to reduce CPU load
- **Data Caching**: High-frequency data buffered, UI updated at lower rate

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

## Data Structures

### Sensor Data Model
```dart
class SensorData {
  final double heartRate;              // BPM
  final double breathRate;             // breaths/min
  final double heartEnergy;            // Signal energy
  final double breathEnergy;           // Signal energy
  final List<double> rangeProfile;     // Range bins (64 bins)
  final double heartWaveform;          // Raw heart signal
  final double breathWaveform;         // Raw breath signal
  final double chestDisplacement;      // Chest movement in mm
}
```

### Stress Level Data
```dart
enum StressLevel { relaxed, normal, highStress }

class StressLevelData {
  final StressLevel level;
  final String label;
  final DateTime timestamp;
}

class VitalsSnapshot {
  final double heartRate;
  final double breathingRate;
  final double chestDisplacement;
  final List<VitalAlert> activeAlerts;
  final DateTime timestamp;
}
```

### Trend Data
```dart
class TrendDataPoint {
  final DateTime timestamp;
  final double heartRate;
  final double breathRate;
}
```

### WebSocket Data Format
The app expects JSON data with the following structure:
```json
{
  "vitals": {
    "heartRateEst_FFT": 75.2,
    "breathingRateEst_FFT": 16.8,
    "sumEnergyHeartWfm": 1250.5,
    "sumEnergyBreathWfm": 890.3,
    "outputFilterHeartOut": 0.25,
    "outputFilterBreathOut": -0.15,
    "unwrapPhasePeak_mm": 3.5,
    "RangeProfile": [120.5, 340.2, ..., 64 values]
  }
}
```

## Theme System

### Available Themes
1. **Neon Theme** (Default)
   - Primary: `#2BE4DC` (Cyan)
   - Secondary: `#7B61FF` (Purple)
   - Background: `#0A0F1C` (Dark Blue)
   - Surface: `#151B2D` (Dark Gray)

2. **Dark Monochrome**
   - Primary: `#FFFFFF` (White)
   - Grayscale palette
   - Minimal color usage

3. **Night Owl**
   - Primary: `#7FDBCA` (Mint)
   - Background: `#011627` (Navy)
   - Warm, eye-friendly colors

### Typography
- **Font Family**: SF Pro (default) / OpenDyslexic (optional)
- **Font Sizes**: 
  - Large Title: 28px
  - Title: 18px
  - Subtitle: 16px
  - Body: 14px
  - Caption: 11px
- **Font Size Multipliers**:
  - Small: 0.85x
  - Medium: 1.0x (default)
  - Large: 1.15x

### Accessibility
- Color blind mode support (Protanopia, Deuteranopia, Tritanopia)
- Dyslexic-friendly font option
- Adjustable font sizes
- High contrast themes
- Theme-aware color helpers

## Configuration Constants

### Application Constants (`AppConstants`)
- **Range Profile Bins**: 64
- **Detection Range**: 0.3m - 2.5m
- **Peak Detection Threshold**: 30% of strongest peak
- **Waveform Buffer Size**: 120 points (6 seconds at 20Hz)
- **Trend Data Max Points**: 100 (5 minutes at 3-second intervals)
- **Sensor Data Buffer**: 100 points (~5 seconds at 20Hz)

### Vital Signs Thresholds
- **Heart Rate**: Normal 60-100 BPM, High >100, Low <50
- **Breathing Rate**: Normal 12-20 breaths/min, High >25, Low <10
- **Sudden Movement**: >5mm displacement change

### Timing Intervals
- **Stress Analysis**: Every 5 seconds
- **Trend Aggregation**: Every 3 seconds
- **Data Timeout**: 3 seconds without data
- **Reconnect Delay**: 2 seconds

## Performance Metrics

- **UI Update Rate**: 1 FPS (1000ms intervals) on Sensor Screen
- **Data Acquisition**: 20-50 Hz from sensor
- **Waveform Buffer**: 120 points (6 seconds at 20Hz)
- **Trend Buffer**: 100 points (5 minutes of data)
- **Stress Analysis**: Every 5 seconds
- **Memory Usage**: Optimized with ring buffers
- **Battery Life**: Efficient rendering reduces power consumption

## Development

### Project Structure
```
lib/
├── core/                           # Business logic & services
│   ├── constants/
│   │   └── app_constants.dart      # Application configuration
│   ├── utils/
│   │   ├── vital_signs_utils.dart  # Vital signs calculations
│   │   └── vital_alerts_checker.dart # Alert validation
│   ├── websocket_services.dart     # WebSocket communication
│   ├── waveform_service.dart       # Waveform processing
│   ├── trend_service.dart          # Historical trend tracking
│   ├── stress_level_service.dart   # Stress analysis engine
│   ├── settings_service.dart       # User preferences
│   ├── trend_export_service.dart   # Chart export & sharing
│   ├── range_profile_analyzer.dart # Multi-source detection
│   └── sensor_model.dart           # Data models
│
├── ui/                             # User interface
│   ├── constants/
│   │   └── ui_constants.dart       # UI styling constants
│   ├── themes/
│   │   └── app_theme.dart          # Theme definitions
│   ├── screens/
│   │   ├── main_navigation_screen.dart  # Bottom navigation
│   │   ├── home_screen.dart             # Dashboard
│   │   ├── sensor_info_screen.dart      # Live waveforms
│   │   ├── trend_detail_screen.dart     # Trend analysis
│   │   ├── stress_detail_screen.dart    # Stress details
│   │   └── settings_screen.dart         # User settings
│   └── widgets/
│       ├── common/
│       │   ├── alert_card.dart          # Alert notifications
│       │   ├── status_badge.dart        # Connection status
│       │   └── section_header.dart      # Section headers
│       ├── circular_stress_indicator.dart # Stress gauge
│       ├── waveform_chart.dart          # Live waveforms
│       ├── stat_card.dart               # Metric cards
│       ├── stat_card_w_chart.dart       # Cards with mini charts
│       ├── sensor_information.dart      # Sensor status
│       ├── shareable_trend_chart.dart   # Exportable charts
│       ├── range_profile_chart.dart     # Range bins visualization
│       └── section_title.dart           # Legacy section headers
│
└── main.dart                       # Application entry point
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
- Verify WebSocket server is running at `ws://<IP>:<PORT>`
- Check IP and PORT in `.env` file
- Ensure device is on the same network as the sensor
- Check firewall settings on both device and server
- Look for "Live" or "No Data" status badge in header
- Connection auto-reconnects after 2 seconds on failure

#### Data Not Showing
- Check if "Multiple Sources Detected" warning appears
- Ensure only one person is in detection range (0.3m - 2.5m)
- Verify sensor is properly configured and streaming data
- Check WebSocket data format matches expected JSON structure
- Look for data timeout after 3 seconds without new data

#### Performance Issues
- Sensor screen should update at ~1 FPS (1-second intervals)
- Check for memory leaks in waveform buffers (120 points max)
- Verify ring buffer implementation is working
- Monitor stress analysis (runs every 5 seconds)
- Trend aggregation should occur every 3 seconds

#### Theme/Display Issues
- If light theme is unreadable, switch to another theme in Settings
- Font size changes should show in preview card immediately
- All themes should work with proper contrast
- Color blind modes apply color adjustments automatically

#### Build Errors
- Run `flutter clean` and `flutter pub get`
- Check Flutter SDK version: `>=3.9.2`
- Verify `pubspec.yaml` dependencies are correct
- Check Gradle configuration in `android/gradle.properties`
- Ensure `.env` file exists with IP and PORT

### Debug Information
The app provides real-time debug information:
- **Status Badge**: "Live" (green) or "No Data" (red)
- **Signal Quality**: Percentage and color-coded description
- **Connection State**: Active/inactive WebSocket status
- **Multiple Sources Warning**: Alert when >1 breathing source detected
- **Stress Level**: Real-time stress analysis updates
- **Alert System**: Visual alerts for abnormal vital signs

## Dependencies

### Core Dependencies
- `flutter`: Flutter framework (SDK ^3.9.2)
- `web_socket_channel`: ^3.0.2 - WebSocket communication
- `flutter_dotenv`: ^6.0.0 - Environment configuration
- `shared_preferences`: ^2.3.5 - Persistent settings storage
- `provider`: ^6.1.2 - State management
- `intl`: ^0.20.2 - Date formatting

### UI & Export Dependencies  
- `share_plus`: ^10.3.0 - Social sharing (WhatsApp export)
- `path_provider`: ^2.1.5 - File system access

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: ^6.0.0 - Code quality and linting

### Optional Dependencies (Assets)
- `cupertino_icons`: ^1.0.8 - iOS-style icons
- Custom fonts: SF Pro, OpenDyslexic

## Key Features Implementation

### State Management
- **ValueNotifier** pattern for reactive updates
- **ChangeNotifier** for settings persistence
- Efficient listener management with proper disposal

### Data Processing Pipeline
1. **WebSocket** receives high-frequency data (20-50Hz)
2. **Services** process and buffer data:
   - WaveformService: Ring buffers (120 points)
   - TrendService: Aggregates every 3 seconds
   - StressLevelService: Analyzes every 5 seconds
3. **UI** updates at optimized intervals (1 FPS for sensor screen)

### Export Feature
- Captures trend chart as PNG image
- Generates formatted text summary
- Shares via WhatsApp using `share_plus`
- Includes statistics: min, max, average, duration

### Multi-Source Detection
- Analyzes range profile for multiple peaks
- Detects breathing sources >0.3m apart
- Provides visual warning on dashboard
- Helps ensure measurement accuracy

## Code Quality Standards

### Architecture Principles
- **Separation of Concerns**: Core logic separated from UI
- **Single Responsibility**: Each service has focused purpose
- **DRY**: Constants centralized, utilities reusable
- **Theme-Aware**: All components adapt to selected theme
- **Performance-First**: Optimized updates, efficient buffers

### Code Organization
- Constants extracted to dedicated files
- Utility functions for common calculations
- Reusable widgets for consistent UI
- Proper error handling and null safety
- Comprehensive documentation

**Note**: This app is designed for research and educational purposes. Consult healthcare professionals for medical advice.