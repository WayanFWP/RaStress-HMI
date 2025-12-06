import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/sensor_model.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;

  final ValueNotifier<SensorData?> latestData = ValueNotifier(null);
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<bool> isReceivingData = ValueNotifier(false);
  final ValueNotifier<String> connectionStatus = ValueNotifier("Disconnected");

  DateTime? _lastDataReceivedTime;
  Timer? _dataCheckTimer;
  
  // If no data received for 3 seconds, consider it as not receiving
  static const Duration _dataTimeoutDuration = Duration(seconds: 3);

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
    _dataCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lastDataReceivedTime != null) {
        final timeSinceLastData = DateTime.now().difference(_lastDataReceivedTime!);
        
        if (timeSinceLastData > _dataTimeoutDuration) {
          // No data received for timeout duration
          isReceivingData.value = false;
          if (isConnected.value) {
            connectionStatus.value = "Connected - No data received";
          }
        }
      } else {
        isReceivingData.value = false;
      }
    });
  }

  void reconnect() {
    dispose();
    Future.delayed(const Duration(seconds: 2), () {
      connect();
    });
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