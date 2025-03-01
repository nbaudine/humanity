// lib/game/components/board_component.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../models/card.dart';
import 'card_component.dart';

class BoardComponent extends PositionComponent {
  // Cartes sur le plateau
  final List<CardComponent> tableCardComponents = [];
  
  // Zones de jeu sur le plateau
  final List<RectangleComponent> playZones = [];
  
  // Dimensions et mise en page
  static const int maxPlayZones = 5;
  static const double zoneSpacing = 20.0;
  static const double cardScale = 0.9;
  
  // Création du plateau
  BoardComponent({
    required super.size,
    required super.position,
    super.priority = 5,
  });
  
  @override
  Future<void> onLoad() async {
    // Créer les zones de jeu
    _createPlayZones();
  }
  
  // Créer les zones où les cartes peuvent être placées
  void _createPlayZones() {
    // Nettoyer les zones existantes
    for (final zone in playZones) {
      remove(zone);
    }
    playZones.clear();
    
    // Calculer les dimensions des zones
    final zoneWidth = HandComponent.cardWidth * 1.1;
    final zoneHeight = HandComponent.cardHeight * 1.1;
    
    // Calculer la largeur totale des zones
    final totalWidth = maxPlayZones * (zoneWidth + zoneSpacing) - zoneSpacing;
    final startX = (size.x - totalWidth) / 2;
    
    // Position verticale au centre du plateau
    final posY = size.y / 2;
    
    // Créer les zones de jeu rectangulaires
    for (int i = 0; i < maxPlayZones; i++) {
      final zoneX = startX + i * (zoneWidth + zoneSpacing);
      
      final zone = RectangleComponent(
        size: Vector2(zoneWidth, zoneHeight),
        position: Vector2(zoneX, posY),
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      
      // Ajouter une étiquette de zone
      final label = TextComponent(
        text: 'Zone ${i + 1}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        position: Vector2(zoneWidth / 2, zoneHeight + 10),
        anchor: Anchor.topCenter,
      );
      
      zone.add(label);
      playZones.add(zone);
      add(zone);
    }
  }
  
  // Mettre à jour les cartes sur le plateau
  void updateTableCards(List<GameCard> cards) {
    // Supprimer les cartes existantes
    for (final card in tableCardComponents) {
      remove(card);
    }
    tableCardComponents.clear();
    
    if (cards.isEmpty) return;
    
    // Limiter le nombre de cartes à afficher au nombre de zones
    final cardsToShow = cards.length > maxPlayZones
        ? cards.sublist(cards.length - maxPlayZones)
        : cards;
    
    // Placer les cartes dans les zones correspondantes
    for (int i = 0; i < cardsToShow.length; i++) {
      final zoneIndex = i % playZones.length;
      final cardPosition = playZones[zoneIndex].position.clone();
      
      // Petite variation aléatoire pour l'angle et la position
      final random = math.Random();
      final angleVariation = (random.nextDouble() - 0.5) * 0.2;
      final posVariation = Vector2(
        (random.nextDouble() - 0.5) * 5,
        (random.nextDouble() - 0.5) * 5,
      );
      
      final card = CardComponent(
        card: cardsToShow[i].copyWith(isRevealed: true), // Toujours visible sur le plateau
        cardWidth: HandComponent.cardWidth,
        cardHeight: HandComponent.cardHeight,
        position: cardPosition + posVariation,
        angle: angleVariation,
        scale: Vector2.all(cardScale),
        priority: i + 10, // Assurer que les cartes les plus récentes sont au-dessus
      );
      
      tableCardComponents.add(card);
      add(card);
    }
  }
  
  @override
  void render(Canvas canvas) {
    // Dessiner un cadre autour du plateau
    final boardFrame = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.x - 20, size.y - 20),
      const Radius.circular(15),
    );
    
    final framePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(boardFrame, framePaint);
    
    // Dessiner des lignes décoratives sur le plateau
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Ligne horizontale au centre
    canvas.drawLine(
      Offset(20, size.y / 2),
      Offset(size.x - 20, size.y / 2),
      linePaint,
    );
    
    // Quelques lignes diagonales décoratives
    canvas.drawLine(
      Offset(20, 20),
      Offset(size.x - 20, size.y - 20),
      linePaint,
    );
    
    canvas.drawLine(
      Offset(size.x - 20, 20),
      Offset(20, size.y - 20),
      linePaint,
    );
  }
}