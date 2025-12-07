import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/sensor_model.dart';
import 'constants/app_constants.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;

  final ValueNotifier<SensorData?> latestData = ValueNotifier(null);
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<bool> isReceivingData = ValueNotifier(false);
  final ValueNotifier<String> connectionStatus = ValueNotifier("Disconnected");

  DateTime? _lastDataReceivedTime;
  Timer? _dataCheckTimer;

  WebSocketService(this.url);

  void connect() {
    try {
      connectionStatus.value = "Connecting to $url...";
      if (kDebugMode) {
        print("Attempting to connect to: $url");
      }

      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Start monitoring data reception
      _startDataMonitoring();

      _channel!.stream.listen(
        (event) {
          isConnected.value = true;
          connectionStatus.value = "Connected - Receiving data";

          // Update last data received timestamp
          _lastDataReceivedTime = DateTime.now();
          isReceivingData.value = true;

          try {
            final jsonData = jsonDecode(event);
            final newData = SensorData.fromJson(jsonData);
            latestData.value = newData;
          } catch (e) {
            if (kDebugMode) {
              print("JSON parse error: $e");
            }
          }
        },
        onError: (error) {
          isConnected.value = false;
          isReceivingData.value = false;
          connectionStatus.value = "Connection error: $error";
          if (kDebugMode) {
            print("WebSocket error: $error");
          }
        },
        onDone: () {
          isConnected.value = false;
          isReceivingData.value = false;
          connectionStatus.value = "Connection closed";
          if (kDebugMode) {
            print("WebSocket connection closed");
          }
        },
      );
    } catch (e) {
      isConnected.value = false;
      isReceivingData.value = false;
      connectionStatus.value = "Failed to connect: $e";
      if (kDebugMode) {
        print("Connection error: $e");
      }
    }
  }

  /// Monitor if data is still being received
  void _startDataMonitoring() {
    _dataCheckTimer?.cancel();
    _dataCheckTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkDataTimeout(),
    );
  }

  void _checkDataTimeout() {
    if (_lastDataReceivedTime == null) {
      isReceivingData.value = false;
      return;
    }

    final timeSinceLastData = DateTime.now().difference(_lastDataReceivedTime!);

    if (timeSinceLastData > AppConstants.dataTimeoutDuration) {
      isReceivingData.value = false;
      if (isConnected.value) {
        connectionStatus.value = "Connected - No data received";
      }
    }
  }

  void reconnect() {
    dispose();
    Future.delayed(AppConstants.reconnectDelay, connect);
  }

  void dispose() {
    _dataCheckTimer?.cancel();
    _channel?.sink.close();
    isConnected.value = false;
    isReceivingData.value = false;
    connectionStatus.value = "Disconnected";
    _lastDataReceivedTime = null;
  }
}
