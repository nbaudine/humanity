// lib/models/card.dart

class GameCard {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int value;
  final CardType type;
  final Map<String, dynamic> attributes;
  bool isRevealed;

  GameCard({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.value,
    required this.type,
    this.attributes = const {},
    this.isRevealed = false,
  });

  // Créer une carte à partir d'un Map (JSON)
  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      value: json['value'],
      type: CardType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CardType.standard,
      ),
      attributes: json['attributes'] ?? {},
      isRevealed: json['isRevealed'] ?? false,
    );
  }

  // Convertir la carte en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'value': value,
      'type': type.toString().split('.').last,
      'attributes': attributes,
      'isRevealed': isRevealed,
    };
  }

  // Créer une copie de la carte avec des propriétés modifiées
  GameCard copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? value,
    CardType? type,
    Map<String, dynamic>? attributes,
    bool? isRevealed,
  }) {
    return GameCard(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      value: value ?? this.value,
      type: type ?? this.type,
      attributes: attributes ?? this.attributes,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }
}

enum CardType {
  standard,
  action,
  special,
  character,
  event,
}