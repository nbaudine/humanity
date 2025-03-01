// lib/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service pour gérer les connexions WebSocket et Socket.IO
class SocketService {
  // Socket.IO pour les connexions serveur en temps réel
  io.Socket? _socket;
  
  // WebSocketChannel pour l'alternative WebSocket standard
  WebSocketChannel? _webSocketChannel;
  
  // État de la connexion
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  // Méthode pour se connecter à un serveur Socket.IO
  Future<void> connect(String url) async {
    try {
      // Fermer toute connexion existante
      disconnect();
      
      // Créer une nouvelle connexion Socket.IO
      _socket = io.io(
        url,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .build(),
      );
      
      // Configurer les écouteurs d'événements
      _socket!.onConnect((_) {
        _isConnected = true;
        debugPrint('Connected to Socket.IO server');
      });
      
      _socket!.onDisconnect((_) {
        _isConnected = false;
        debugPrint('Disconnected from Socket.IO server');
      });
      
      _socket!.onError((error) {
        debugPrint('Socket.IO Error: $error');
      });
      
      _socket!.onConnectError((error) {
        debugPrint('Socket.IO Connect Error: $error');
        // Essayer de se reconnecter avec WebSocket standard
        _tryWebSocketConnection(url);
      });
      
      // Se connecter au serveur
      _socket!.connect();
      
      // Attendre la connexion
      Completer<void> completer = Completer<void>();
      _socket!.once('connect', (_) => completer.complete());
      
      // Timeout après 5 secondes
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _tryWebSocketConnection(url);
          return;
        },
      );
    } catch (e) {
      debugPrint('Error connecting to socket: $e');
      _tryWebSocketConnection(url);
    }
  }
  
  // Essayer une connexion WebSocket standard si Socket.IO échoue
  void _tryWebSocketConnection(String url) {
    try {
      // Convertir l'URL en format WebSocket si nécessaire
      if (url.startsWith('http')) {
        url = url.replaceFirst('http', 'ws');
      } else if (!url.startsWith('ws')) {
        url = 'ws://$url';
      }
      
      // Créer le canal WebSocket
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(url));
      
      // Écouter les événements
      _webSocketChannel!.stream.listen(
        (dynamic message) {
          if (message is String) {
            try {
              final Map<String, dynamic> data = jsonDecode(message);
              final String event = data['event'] ?? 'message';
              final dynamic payload = data['data'];
              
              // Déclencher les callbacks pour cet événement
              if (_eventHandlers.containsKey(event)) {
                for (final callback in _eventHandlers[event]!) {
                  callback(payload);
                }
              }
            } catch (e) {
              debugPrint('Error parsing WebSocket message: $e');
            }
          }
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
        },
      );
      
      _isConnected = true;
      debugPrint('Connected to WebSocket server');
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _isConnected = false;
    }
  }
  
  // Déconnecter du serveur
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    if (_webSocketChannel != null) {
      _webSocketChannel!.sink.close();
      _webSocketChannel = null;
    }
    
    _isConnected = false;
  }
  
  // Émettre un événement au serveur
  void emit(String event, [dynamic data]) {
    if (!_isConnected) {
      debugPrint('Cannot emit event: not connected');
      return;
    }
    
    if (_socket != null) {
      _socket!.emit(event, data);
    } else if (_webSocketChannel != null) {
      final message = jsonEncode({
        'event': event,
        'data': data,
      });
      _webSocketChannel!.sink.add(message);
    }
  }
  
  // Map pour stocker les gestionnaires d'événements
  final Map<String, List<Function(dynamic)>> _eventHandlers = {};
  
  // Écouter un événement
  void on(String event, Function(dynamic) callback) {
    if (_eventHandlers.containsKey(event)) {
      _eventHandlers[event]!.add(callback);
    } else {
      _eventHandlers[event] = [callback];
    }
    
    // S'abonner à l'événement si connecté via Socket.IO
    if (_socket != null) {
      _socket!.on(event, (data) => callback(data));
    }
  }
  
  // Écouter un événement une seule fois
void once(String event, Function(dynamic) callback) {
  if (_socket != null) {
    _socket!.once(event, (data) => callback(data));
  } else {
    // Pour WebSocket, implémenter une logique similaire
    var wrappedCallback;
    wrappedCallback = (dynamic data) {
      callback(data);
      off(event, wrappedCallback);
    };
    
    on(event, wrappedCallback);
  }
}
  
  // Supprimer un écouteur d'événement
  void off(String event, [Function(dynamic)? callback]) {
    if (callback == null) {
      // Supprimer tous les écouteurs pour cet événement
      _eventHandlers.remove(event);
      if (_socket != null) {
        _socket!.off(event);
      }
    } else {
      // Supprimer un écouteur spécifique
      if (_eventHandlers.containsKey(event)) {
        _eventHandlers[event]!.remove(callback);
        if (_eventHandlers[event]!.isEmpty) {
          _eventHandlers.remove(event);
        }
      }
    }
  }
  
  // Callback pour la connexion
  void onConnect(Function() callback) {
    if (_socket != null) {
      _socket!.onConnect((_) => callback());
    }
  }
  
  // Callback pour la déconnexion
  void onDisconnect(Function() callback) {
    if (_socket != null) {
      _socket!.onDisconnect((_) => callback());
    }
  }
}