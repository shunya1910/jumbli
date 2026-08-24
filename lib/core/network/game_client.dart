import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GameClient {
  WebSocketChannel? _channel;
  
  // Callbacks so the UI can react when messages arrive
  Function(Map<String, dynamic>)? onGameStarted;
  Function(Map<String, dynamic>)? onGameOver;
  Function()? onConnected;

  void connect(String ipAddress) {
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:8080');
      _channel = WebSocketChannel.connect(wsUrl);
      debugPrint('Client connected to $wsUrl');

      // Listen for messages from the Host
      _channel?.stream.listen((message) {
        debugPrint('Client received: $message');
        _handleIncomingMessage(message.toString());
      }, onError: (error) {
        debugPrint('WebSocket Error: $error');
      }, onDone: () {
        debugPrint('Disconnected from Host');
      });

      // Send the initial handshake message
      sendMessage({'action': 'join', 'name': 'Player'});
    } catch (e) {
      debugPrint('Connection failed: $e');
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
      } else if (data['action'] == 'connected') {
        // Host acknowledged our connection
        onConnected?.call();
      }
    } catch (e) {
      debugPrint('Error parsing message from Host: $e');
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
