// lib/services/game_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import 'socket_service.dart';

class GameService extends ChangeNotifier {
  // Instance de SocketService pour la communication en temps réel
  final SocketService _socketService = SocketService();
  
  // État actuel du jeu
  GameState? _currentGame;
  GameState? get currentGame => _currentGame;
  
  // Joueur local
  Player? _localPlayer;
  Player? get localPlayer => _localPlayer;
  
  // Liste des salles disponibles
  List<Map<String, dynamic>> _availableRooms = [];
  List<Map<String, dynamic>> get availableRooms => _availableRooms;
  
  // UUID pour générer des identifiants uniques
  final _uuid = Uuid();
  
  // Contrôleurs de flux pour les événements du jeu
  final _gameEventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get gameEvents => _gameEventController.stream;
  
  // Constructeur
  GameService() {
    _initSocketListeners();
  }
  
  // Initialiser les écouteurs de socket
  void _initSocketListeners() {
    _socketService.onConnect(() {
      _gameEventController.add({'event': 'connected'});
    });
    
    _socketService.onDisconnect(() {
      _gameEventController.add({'event': 'disconnected'});
    });
    
    _socketService.on('game_update', (data) {
      if (data != null) {
        final gameState = GameState.fromJson(data);
        _updateGameState(gameState);
      }
    });
    
    _socketService.on('available_rooms', (data) {
      if (data != null) {
        _availableRooms = List<Map<String, dynamic>>.from(data);
        notifyListeners();
      }
    });
  }
  
  // Mettre à jour l'état du jeu
  void _updateGameState(GameState gameState) {
    _currentGame = gameState;
    
    // Mettre à jour le joueur local si présent dans le jeu
    if (_localPlayer != null) {
      final playerInGame = gameState.players.firstWhere(
        (p) => p.id == _localPlayer!.id,
        orElse: () => _localPlayer!,
      );
      _localPlayer = playerInGame;
    }
    
    notifyListeners();
    _gameEventController.add({'event': 'game_updated', 'gameState': gameState});
  }
  
  // Connexion au serveur
  Future<void> connect(String serverUrl) async {
    await _socketService.connect(serverUrl);
  }
  
  // Déconnexion du serveur
  void disconnect() {
    _socketService.disconnect();
  }
  
  // Créer un nouveau joueur
  void createPlayer(String name, String avatarUrl) {
    _localPlayer = Player(
      id: _uuid.v4(),
      name: name,
      avatarUrl: avatarUrl,
    );
    notifyListeners();
  }
  
  // Créer une nouvelle salle de jeu
  void createRoom(String roomName, Map<String, dynamic> settings) {
    if (_localPlayer == null) return;
    
    final roomId = _uuid.v4();
    _socketService.emit('create_room', {
      'roomId': roomId,
      'roomName': roomName,
      'hostId': _localPlayer!.id,
      'settings': settings,
    });
  }
  
  // Rejoindre une salle
  void joinRoom(String roomId) {
    if (_localPlayer == null) return;
    
    _socketService.emit('join_room', {
      'roomId': roomId,
      'player': _localPlayer!.toJson(),
    });
  }
  
  // Quitter une salle
  void leaveRoom(String roomId) {
    if (_localPlayer == null) return;
    
    _socketService.emit('leave_room', {
      'roomId': roomId,
      'playerId': _localPlayer!.id,
    });
  }
  
  // Démarrer le jeu
  void startGame(String roomId) {
    _socketService.emit('start_game', {
      'roomId': roomId,
    });
  }
  
  // Jouer une carte
  void playCard(String cardId) {
    if (_currentGame == null || _localPlayer == null) return;
    
    _socketService.emit('play_card', {
      'gameId': _currentGame!.gameId,
      'playerId': _localPlayer!.id,
      'cardId': cardId,
    });
  }
  
  // Piocher une carte
  void drawCard() {
    if (_currentGame == null || _localPlayer == null) return;
    
    _socketService.emit('draw_card', {
      'gameId': _currentGame!.gameId,
      'playerId': _localPlayer!.id,
    });
  }
  
  // Fin du tour
  void endTurn() {
    if (_currentGame == null || _localPlayer == null) return;
    
    _socketService.emit('end_turn', {
      'gameId': _currentGame!.gameId,
      'playerId': _localPlayer!.id,
    });
  }
  
  // Pour le développement : créer un jeu hors ligne
  void createOfflineGame(List<Player> players) {
    if (_localPlayer == null) return;
    
    // Créer un deck de cartes
    final deck = _createSampleDeck();
    
    // Distribuer des cartes aux joueurs
    final updatedPlayers = players.map((player) {
      final cards = <GameCard>[];
      for (var i = 0; i < 5; i++) {
        if (deck.isNotEmpty) {
          final card = deck.removeAt(0);
          cards.add(card.copyWith(isRevealed: player.id == _localPlayer!.id));
        }
      }
      return player.copyWith(hand: cards);
    }).toList();
    
    // Créer l'état initial du jeu
    final gameState = GameState(
      gameId: _uuid.v4(),
      players: updatedPlayers,
      deck: deck,
      phase: GamePhase.playing,
    );
    
    _updateGameState(gameState);
  }
  
  // Créer un deck d'exemple pour les tests
  List<GameCard> _createSampleDeck() {
    final deck = <GameCard>[];
    
    // Cartes standard (valeurs 1-10)
    for (var type in [CardType.standard, CardType.action]) {
      for (var i = 1; i <= 10; i++) {
        deck.add(GameCard(
          id: _uuid.v4(),
          name: 'Card $i',
          description: 'This is card $i of type ${type.toString().split('.').last}',
          imageUrl: 'card_$i.png',
          value: i,
          type: type,
        ));
      }
    }
    
    // Cartes spéciales
    for (var i = 1; i <= 5; i++) {
      deck.add(GameCard(
        id: _uuid.v4(),
        name: 'Special $i',
        description: 'Special card with unique effect',
        imageUrl: 'special_$i.png',
        value: i * 2,
        type: CardType.special,
      ));
    }
    
    // Mélanger le deck
    deck.shuffle();
    
    return deck;
  }
  
  @override
  void dispose() {
    _socketService.disconnect();
    _gameEventController.close();
    super.dispose();
  }
}