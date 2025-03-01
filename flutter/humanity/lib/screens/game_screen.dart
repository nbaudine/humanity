// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import '../game/card_game.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../widgets/game_controls.dart';
import '../widgets/player_status.dart';
import '../widgets/game_chat.dart';

class GameScreen extends StatefulWidget {
  final String gameId;
  
  const GameScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Référence au jeu Flame
  CardGame? _game;
  
  // État du jeu
  bool _showChat = false;
  bool _showSettings = false;
  bool _isFullScreen = false;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }
  
  // Initialiser le jeu
  void _initializeGame() {
    // Obtenir le service de jeu
    final gameService = Provider.of<GameService>(context, listen: false);
    
    // Créer le jeu Flame avec l'état actuel
    _game = CardGame(
      boardWidth: MediaQuery.of(context).size.width,
      boardHeight: MediaQuery.of(context).size.height * 0.8,
      gameState: gameService.currentGame,
      currentPlayer: gameService.localPlayer,
      onGameEvent: _handleGameEvent,
    );
    
    // S'abonner aux événements de jeu
    gameService.gameEvents.listen(_onGameEvent);
    
    // Si nous sommes en développement, créer un jeu hors ligne
    if (gameService.currentGame == null) {
      Future.delayed(Duration.zero, () {
        gameService.createOfflineGame([
          gameService.localPlayer!,
          Player(id: 'cpu1', name: 'Ordinateur 1'),
          Player(id: 'cpu2', name: 'Ordinateur 2'),
        ]);
      });
    }
  }
  
  // Gérer les événements du jeu provenant de Flame
  void _handleGameEvent(String event, Map<String, dynamic> data) {
    final gameService = Provider.of<GameService>(context, listen: false);
    
    switch (event) {
      case 'play_card':
        gameService.playCard(data['cardId']);
        break;
      case 'draw_card':
        gameService.drawCard();
        break;
      case 'end_turn':
        gameService.endTurn();
        break;
      case 'error':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        break;
    }
  }
  
  // Recevoir les événements du service de jeu
  void _onGameEvent(Map<String, dynamic> event) {
    if (!mounted) return;
    
    switch (event['event']) {
      case 'game_updated':
        if (_game != null) {
          final gameState = event['gameState'] as GameState;
          _game!.updateGameState(gameState);
        }
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<GameService>(
          builder: (context, gameService, child) {
            if (gameService.currentGame == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return Stack(
              children: [
                // Jeu principal
                Positioned.fill(
                  child: _game != null
                      ? GameWidget(game: _game!)
                      : const Center(child: CircularProgressIndicator()),
                ),
                
                // Contrôles du jeu
                if (!_isFullScreen)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: GameControls(
                        onEndTurn: () {
                          gameService.endTurn();
                        },
                        onDrawCard: () {
                          gameService.drawCard();
                        },
                        onToggleChat: () {
                          setState(() {
                            _showChat = !_showChat;
                          });
                        },
                        onToggleSettings: () {
                          setState(() {
                            _showSettings = !_showSettings;
                          });
                        },
                        onToggleFullScreen: () {
                          setState(() {
                            _isFullScreen = !_isFullScreen;
                          });
                        },
                      ),
                    ),
                  ),
                
                // Statut des joueurs
                if (!_isFullScreen)
                  Positioned(
                    top: 60,
                    right: 0,
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: PlayerStatus(
                        players: gameService.currentGame!.players,
                        currentPlayerId: gameService.localPlayer?.id ?? '',
                        currentTurn: gameService.currentGame!.currentTurn,
                      ),
                    ),
                  ),
                
                // Chat du jeu (si visible)
                if (_showChat && !_isFullScreen)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    width: 300,
                    height: 200,
                    child: GameChat(
                      gameId: widget.gameId,
                      onClose: () {
                        setState(() {
                          _showChat = false;
                        });
                      },
                    ),
                  ),
                
                // Panneau de paramètres (si visible)
                if (_showSettings && !_isFullScreen)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Paramètres',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Quitter la partie
                                  Navigator.pop(context);
                                },
                                child: const Text('Quitter la partie'),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showSettings = false;
                                  });
                                },
                                child: const Text('Fermer'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Bouton pour sortir du mode plein écran
                if (_isFullScreen)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isFullScreen = false;
                          });
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}