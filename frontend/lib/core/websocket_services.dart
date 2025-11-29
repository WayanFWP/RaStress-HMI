import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/sensor_model.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;

  final ValueNotifier<SensorData?> latestData = ValueNotifier(null);
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<String> connectionStatus = ValueNotifier("Disconnected");

  WebSocketService(this.url);

  void connect() {
    try {
      connectionStatus.value = "Connecting to $url...";
      if (kDebugMode) {
        print("Attempting to connect to: $url");
      }
      
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (event) {
          isConnected.value = true;
          connectionStatus.value = "Connected - Receiving data";
        //   if (kDebugMode) {
        //     print("Raw data received: $event");
        //   }
          
          try {
            final jsonData = jsonDecode(event);
            final newData = SensorData.fromJson(jsonData);
            latestData.value = newData;
            // if (kDebugMode) {
            //   print("Parsed - HR: ${newData.heartRate}, BR: ${newData.breathRate}");
            // }
          } catch (e) {
            if (kDebugMode) {
              print("JSON parse error: $e");
            }
          }
        },
        onError: (error) {
          isConnected.value = false;
          connectionStatus.value = "Connection error: $error";
          if (kDebugMode) {
            print("WebSocket error: $error");
          }
        },
        onDone: () {
          isConnected.value = false;
          connectionStatus.value = "Connection closed";
          if (kDebugMode) {
            print("WebSocket connection closed");
          }
        },
      );
    } catch (e) {
      isConnected.value = false;
      connectionStatus.value = "Failed to connect: $e";
      if (kDebugMode) {
        print("Connection error: $e");
      }
    }
  }

  void reconnect() {
    dispose();
    Future.delayed(const Duration(seconds: 2), () {
      connect();
    });
  }

  void dispose() {
    _channel?.sink.close();
    isConnected.value = false;
    connectionStatus.value = "Disconnected";
  }
}