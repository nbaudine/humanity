// lib/game/card_game.dart

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/card.dart';
import '../models/player.dart';
import 'components/card_component.dart';
import 'components/hand_component.dart';
import 'components/board_component.dart';

class CardGame extends FlameGame with TapDetector, DragDetector, HasCollisionDetection {
  // Dimensions du jeu
  final double boardWidth;
  final double boardHeight;
  
  // État du jeu
  GameState? gameState;
  Player? currentPlayer;
  
  // Callback pour communiquer avec l'UI Flutter
  final void Function(String, Map<String, dynamic>)? onGameEvent;
  
  // Composants principaux
  late BoardComponent boardComponent;
  late HandComponent handComponent;
  late TextComponent statusComponent;
  
  // Référence à la caméra
  late CameraComponent cameraComponent;

  CardGame({
    required this.boardWidth,
    required this.boardHeight,
    this.gameState,
    this.currentPlayer,
    this.onGameEvent,
  });

  @override
  Future<void> onLoad() async {
    // Configurer la caméra
    cameraComponent = CameraComponent(
      world: world,
      viewfinder: Viewfinder()..anchor = Anchor.center,
    );
    addAll([cameraComponent]);
    
    // Charger les assets
    await images.loadAllImages();
    
    // Ajouter le fond de table
    final background = RectangleComponent(
      size: Vector2(boardWidth, boardHeight),
      paint: Paint()..color = const Color(0xFF076324), // Vert foncé pour la table
    );
    world.add(background);
    
    // Ajouter le plateau de jeu
    boardComponent = BoardComponent(
      size: Vector2(boardWidth, boardHeight * 0.7),
      position: Vector2(0, 0),
    );
    world.add(boardComponent);
    
    // Ajouter la main du joueur
    handComponent = HandComponent(
      size: Vector2(boardWidth, boardHeight * 0.3),
      position: Vector2(0, boardHeight * 0.7),
      player: currentPlayer,
      onCardPlayed: _onCardPlayed,
    );
    world.add(handComponent);
    
    // Composant de texte pour les statuts
    statusComponent = TextComponent(
      text: 'En attente...',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 20),
      anchor: Anchor.topLeft,
    );
    camera.viewfinder.add(statusComponent);
    
    // Initialiser le jeu avec l'état actuel
    if (gameState != null) {
      updateGameState(gameState!);
    }
  }
  
  // Mettre à jour l'état du jeu
  void updateGameState(GameState newState) {
    gameState = newState;
    
    // Mettre à jour le texte de statut
    statusComponent.text = 'Tour ${gameState!.round} - ${_getPhaseText(gameState!.phase)}';
    
    // Mettre à jour le plateau
    boardComponent.updateTableCards(gameState!.tableCards);
    
    // Mettre à jour la main du joueur si disponible
    if (currentPlayer != null) {
      final playerInGame = gameState!.players.firstWhere(
        (p) => p.id == currentPlayer!.id,
        orElse: () => currentPlayer!,
      );
      currentPlayer = playerInGame;
      handComponent.updateHand(currentPlayer!);
    }
  }
  
  // Callback quand une carte est jouée
  void _onCardPlayed(GameCard card) {
    if (gameState == null || currentPlayer == null) return;
    
    // Vérifier si c'est le tour du joueur
    final playerIndex = gameState!.players.indexWhere((p) => p.id == currentPlayer!.id);
    if (playerIndex != gameState!.currentTurn) {
      _triggerGameEvent('error', {'message': 'Ce n\'est pas votre tour!'});
      return;
    }
    
    // Mettre à jour localement (sera écrasé par la mise à jour du serveur)
    if (currentPlayer != null) {
      currentPlayer = currentPlayer!.playCard(card.id);
      handComponent.updateHand(currentPlayer!);
      
      // Ajouter la carte au plateau
      final playedCards = List<GameCard>.from(gameState!.tableCards);
      playedCards.add(card);
      boardComponent.updateTableCards(playedCards);
    }
    
    // Envoyer l'événement au serveur ou au service de jeu
    _triggerGameEvent('play_card', {'cardId': card.id});
  }
  
  // Convertir la phase en texte lisible
  String _getPhaseText(GamePhase phase) {
    switch (phase) {
      case GamePhase.waiting:
        return 'En attente des joueurs';
      case GamePhase.setup:
        return 'Préparation du jeu';
      case GamePhase.playing:
        return 'En jeu';
      case GamePhase.roundEnd:
        return 'Fin du tour';
      case GamePhase.gameEnd:
        return 'Fin de partie';
      default:
        return 'Inconnu';
    }
  }
  
  // Déclencher un événement vers la couche Flutter
  void _triggerGameEvent(String event, Map<String, dynamic> data) {
    if (onGameEvent != null) {
      onGameEvent!(event, data);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    // Logique de mise à jour du jeu
  }
}