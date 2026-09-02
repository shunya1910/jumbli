import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GameServer {
  HttpServer? _server;
  final List<WebSocketChannel> _clients = [];
  Function(Map<String, dynamic>)? onPlayerWon;
  Function(String)? onPlayerJoined;
  Function(String)? onError;

  // Start the WebSocket server on port 8080
  Future<void> startServer() async {
    var handler = webSocketHandler((webSocket) {
      _clients.add(webSocket);
      debugPrint('A new player joined! Total players: ${_clients.length}');

      webSocket.stream.listen(
        (message) {
          debugPrint('Server received: $message');
          _handleIncomingMessage(message.toString(), webSocket);
        },
        onDone: () {
          _clients.remove(webSocket);
          debugPrint('A player left. Total players: ${_clients.length}');
        },
      );
    });

    // Bind to all network interfaces on port 8080 with shared: true to allow rebinding
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080, shared: true);
    debugPrint('WebSocket Server running on ws://${_server?.address.host}:${_server?.port}');
  }

  // Handle messages received from clients (like "i_won")
  void _handleIncomingMessage(String message, WebSocketChannel sender) {
    try {
      final data = jsonDecode(message);
      
      // If a player won, broadcast it to everyone else
      if (data['action'] == 'i_won') {
        broadcast(message); // Forward the exact same win message to all phones
        onPlayerWon?.call(data); // Notify the Host UI
      } else if (data['action'] == 'join') {
        // Send a confirmation back so the client knows they successfully connected
        sender.sink.add(jsonEncode({'action': 'connected'}));
        final playerName = data['name'] ?? 'A player';
        debugPrint('$playerName joined the lobby.');
        onPlayerJoined?.call(playerName);
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
      onError?.call('Error parsing message: $e');
    }
  }

  // Send a message to ALL connected phones
  void broadcast(String message) {
    for (var client in _clients) {
      client.sink.add(message);
    }
  }

  // Stop the server when the game is over or host leaves
  Future<void> stopServer() async {
    for (var client in _clients) {
      client.sink.close();
    }
    _clients.clear();
    await _server?.close(force: true);
    debugPrint('Server shut down.');
  }
}