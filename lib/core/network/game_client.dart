import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class GameClient {
  WebSocketChannel? _channel;
  
  // Callbacks so the UI can react when messages arrive
  Function(Map<String, dynamic>)? onGameStarted;
  Function(Map<String, dynamic>)? onGameOver;

  void connect(String ipAddress) {
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:8080');
      _channel = WebSocketChannel.connect(wsUrl);
      print('Client connected to $wsUrl');

      // Listen for messages from the Host
      _channel?.stream.listen((message) {
        print('Client received: $message');
        _handleIncomingMessage(message.toString());
      }, onError: (error) {
        print('WebSocket Error: $error');
      }, onDone: () {
        print('Disconnected from Host');
      });
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  void _handleIncomingMessage(String message) {
    try {
      final data = jsonDecode(message);
      
      if (data['action'] == 'start') {
        // Trigger the UI to navigate to the game screen
        onGameStarted?.call(data);
      } else if (data['action'] == 'i_won') {
        // Trigger the UI to show the results screen
        onGameOver?.call(data);
      }
    } catch (e) {
      print('Error parsing message from Host: $e');
    }
  }

  // Send a message to the Host
  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
