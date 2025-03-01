// lib/models/game_state.dart

import 'card.dart';
import 'player.dart';

enum GamePhase {
  waiting,   // En attente de joueurs
  setup,     // Préparation du jeu
  playing,   // Partie en cours
  roundEnd,  // Fin d'un tour
  gameEnd,   // Fin de la partie
}

class GameState {
  final String gameId;
  final List<Player> players;
  final List<GameCard> deck;
  final List<GameCard> discardPile;
  final List<GameCard> tableCards;
  final GamePhase phase;
  final int currentTurn;
  final int round;
  final int maxRounds;
  final DateTime lastUpdated;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> customData;

  GameState({
    required this.gameId,
    this.players = const [],
    this.deck = const [],
    this.discardPile = const [],
    this.tableCards = const [],
    this.phase = GamePhase.waiting,
    this.currentTurn = 0,
    this.round = 0,
    this.maxRounds = 10,
    DateTime? lastUpdated,
    this.settings = const {},
    this.customData = const {},
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Créer un état de jeu à partir d'un Map (JSON)
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      gameId: json['gameId'],
      players: json['players'] != null
          ? List<Player>.from(json['players'].map((x) => Player.fromJson(x)))
          : [],
      deck: json['deck'] != null
          ? List<GameCard>.from(json['deck'].map((x) => GameCard.fromJson(x)))
          : [],
      discardPile: json['discardPile'] != null
          ? List<GameCard>.from(
              json['discardPile'].map((x) => GameCard.fromJson(x)))
          : [],
      tableCards: json['tableCards'] != null
          ? List<GameCard>.from(
              json['tableCards'].map((x) => GameCard.fromJson(x)))
          : [],
      phase: json['phase'] != null
          ? GamePhase.values.firstWhere(
              (e) => e.toString().split('.').last == json['phase'],
              orElse: () => GamePhase.waiting,
            )
          : GamePhase.waiting,
      currentTurn: json['currentTurn'] ?? 0,
      round: json['round'] ?? 0,
      maxRounds: json['maxRounds'] ?? 10,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      settings: json['settings'] ?? {},
      customData: json['customData'] ?? {},
    );
  }

  // Convertir l'état du jeu en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'players': players.map((x) => x.toJson()).toList(),
      'deck': deck.map((x) => x.toJson()).toList(),
      'discardPile': discardPile.map((x) => x.toJson()).toList(),
      'tableCards': tableCards.map((x) => x.toJson()).toList(),
      'phase': phase.toString().split('.').last,
      'currentTurn': currentTurn,
      'round': round,
      'maxRounds': maxRounds,
      'lastUpdated': lastUpdated.toIso8601String(),
      'settings': settings,
      'customData': customData,
    };
  }

  // Créer une copie avec des propriétés modifiées
  GameState copyWith({
    String? gameId,
    List<Player>? players,
    List<GameCard>? deck,
    List<GameCard>? discardPile,
    List<GameCard>? tableCards,
    GamePhase? phase,
    int? currentTurn,
    int? round,
    int? maxRounds,
    DateTime? lastUpdated,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? customData,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      players: players ?? this.players,
      deck: deck ?? this.deck,
      discardPile: discardPile ?? this.discardPile,
      tableCards: tableCards ?? this.tableCards,
      phase: phase ?? this.phase,
      currentTurn: currentTurn ?? this.currentTurn,
      round: round ?? this.round,
      maxRounds: maxRounds ?? this.maxRounds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      settings: settings ?? this.settings,
      customData: customData ?? this.customData,
    );
  }

  // Passer au joueur suivant
  GameState nextTurn() {
    if (players.isEmpty) return this;
    
    final nextTurn = (currentTurn + 1) % players.length;
    return copyWith(currentTurn: nextTurn);
  }

  // Passer au tour suivant
  GameState nextRound() {
    return copyWith(
      round: round + 1,
      currentTurn: 0,
      phase: round + 1 >= maxRounds ? GamePhase.gameEnd : GamePhase.playing,
    );
  }

  // Obtenir le joueur actuel
  Player? get currentPlayer {
    if (players.isEmpty || currentTurn >= players.length) return null;
    return players[currentTurn];
  }
}