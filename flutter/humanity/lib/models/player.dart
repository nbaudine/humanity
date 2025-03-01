// lib/models/player.dart

import 'card.dart';

class Player {
  final String id;
  final String name;
  final String avatarUrl;
  final List<GameCard> hand;
  final List<GameCard> playedCards;
  int score;
  bool isReady;
  bool isOnline;
  bool isTurn;
  Map<String, dynamic> stats;

  Player({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.hand = const [],
    this.playedCards = const [],
    this.score = 0,
    this.isReady = false,
    this.isOnline = false,
    this.isTurn = false,
    this.stats = const {},
  });

  // Créer un joueur à partir d'un Map (JSON)
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'] ?? '',
      hand: json['hand'] != null
          ? List<GameCard>.from(
              json['hand'].map((x) => GameCard.fromJson(x)))
          : [],
      playedCards: json['playedCards'] != null
          ? List<GameCard>.from(
              json['playedCards'].map((x) => GameCard.fromJson(x)))
          : [],
      score: json['score'] ?? 0,
      isReady: json['isReady'] ?? false,
      isOnline: json['isOnline'] ?? false,
      isTurn: json['isTurn'] ?? false,
      stats: json['stats'] ?? {},
    );
  }

  // Convertir le joueur en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'hand': hand.map((x) => x.toJson()).toList(),
      'playedCards': playedCards.map((x) => x.toJson()).toList(),
      'score': score,
      'isReady': isReady,
      'isOnline': isOnline,
      'isTurn': isTurn,
      'stats': stats,
    };
  }

  // Ajouter une carte à la main du joueur
  Player addCard(GameCard card) {
    final newHand = List<GameCard>.from(hand)..add(card);
    return copyWith(hand: newHand);
  }

  // Jouer une carte (déplacer de la main aux cartes jouées)
  Player playCard(String cardId) {
    final cardIndex = hand.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return this;

    final newHand = List<GameCard>.from(hand);
    final playedCard = newHand.removeAt(cardIndex);
    final newPlayedCards = List<GameCard>.from(playedCards)..add(playedCard);

    return copyWith(
      hand: newHand,
      playedCards: newPlayedCards,
    );
  }

  // Créer une copie du joueur avec des propriétés modifiées
  Player copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    List<GameCard>? hand,
    List<GameCard>? playedCards,
    int? score,
    bool? isReady,
    bool? isOnline,
    bool? isTurn,
    Map<String, dynamic>? stats,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hand: hand ?? this.hand,
      playedCards: playedCards ?? this.playedCards,
      score: score ?? this.score,
      isReady: isReady ?? this.isReady,
      isOnline: isOnline ?? this.isOnline,
      isTurn: isTurn ?? this.isTurn,
      stats: stats ?? this.stats,
    );
  }
}