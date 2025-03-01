// lib/game/components/hand_component.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../models/player.dart';
import '../../models/card.dart';
import 'card_component.dart';

class HandComponent extends PositionComponent {
  Player? player;
  final List<CardComponent> cardComponents = [];
  
  // Callback quand une carte est jouée
  final void Function(GameCard card)? onCardPlayed;
  
  // Mise en page de la main
  static const double cardSpacing = 20.0;
  static const double cardOverlap = 30.0;
  static const double cardScale = 0.8;
  static const double selectedCardLiftAmount = 30.0;
  
  // Références pour le drag & drop
  CardComponent? selectedCard;
  
  // Dimensions standard des cartes
  static const double cardWidth = 80.0;
  static const double cardHeight = 120.0;
  
  // Bouton pour jouer la carte
  late RectangleComponent playButton;
  bool showPlayButton = false;
  
  HandComponent({
    required super.size,
    required super.position,
    this.player,
    this.onCardPlayed,
    super.priority = 10,
  });
  
  @override
  Future<void> onLoad() async {
    // Créer le bouton pour jouer la carte sélectionnée
    playButton = RectangleComponent(
      size: Vector2(120, 40),
      position: Vector2(size.x / 2, size.y - 50),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.green,
    );
    
    // Ajouter le texte au bouton
    final buttonText = TextComponent(
      text: 'JOUER',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(60, 20),
    );
    
    playButton.add(buttonText);
    add(playButton);
    playButton.visible = false;
    
    // Ajouter la détection de tap sur le bouton
    playButton.add(
      RectangleHitbox()..onTapUp = (_) => playSelectedCard(),
    );
    
    if (player != null) {
      await _createCardComponents();
    }
  }
  
  // Créer les composants de carte pour la main du joueur
  Future<void> _createCardComponents() async {
    // Supprimer les anciennes cartes
    for (final card in cardComponents) {
      remove(card);
    }
    cardComponents.clear();
    
    if (player == null || player!.hand.isEmpty) return;
    
    // Calculer la disposition des cartes
    final int cardCount = player!.hand.length;
    final double totalWidth = math.min(
      size.x - 40,  // 20px de padding de chaque côté
      cardCount * (cardWidth - cardOverlap) + cardOverlap
    );
    final double startX = (size.x - totalWidth) / 2;
    
    // Créer les composants de carte
    for (int i = 0; i < cardCount; i++) {
      final GameCard card = player!.hand[i];
      final double xPos = startX + i * (cardWidth - cardOverlap);
      
      final cardComponent = CardComponent(
        card: card,
        cardWidth: cardWidth,
        cardHeight: cardHeight,
        position: Vector2(xPos, 20),
        priority: i,
        onCardSelected: _handleCardSelected,
      );
      
      cardComponents.add(cardComponent);
      add(cardComponent);
    }
  }
  
  // Mettre à jour la main avec un nouveau joueur
  void updateHand(Player newPlayer) {
    player = newPlayer;
    _createCardComponents();
  }
  
  // Gérer la sélection de carte
  void _handleCardSelected(CardComponent card) {
    // Désélectionner les autres cartes
    for (final otherCard in cardComponents) {
      if (otherCard != card && otherCard.isSelected) {
        otherCard.toggleSelection();
      }
    }
    
    // Mettre à jour la référence de la carte sélectionnée
    selectedCard = card.isSelected ? card : null;
    
    // Montrer/cacher le bouton pour jouer
    playButton.visible = selectedCard != null;
    
    // Animer la carte sélectionnée vers le haut
    if (selectedCard != null) {
      selectedCard!.setOriginalPosition(
        Vector2(selectedCard!.position.x, 20 - selectedCardLiftAmount)
      );
    }
  }
  
  // Méthode pour jouer la carte sélectionnée
  void playSelectedCard() {
    if (selectedCard != null && onCardPlayed != null) {
      onCardPlayed!(selectedCard!.card);
      
      // Supprimer la carte de la main visuellement
      remove(selectedCard!);
      cardComponents.remove(selectedCard!);
      selectedCard = null;
      
      // Cacher le bouton de jeu
      playButton.visible = false;
      
      // Réorganiser la main
      _rearrangeHand();
    }
  }
  
  // Réorganiser les cartes dans la main après qu'une carte a été jouée
  void _rearrangeHand() {
    final int cardCount = cardComponents.length;
    if (cardCount == 0) return;
    
    final double totalWidth = math.min(
      size.x - 40,
      cardCount * (cardWidth - cardOverlap) + cardOverlap
    );
    final double startX = (size.x - totalWidth) / 2;
    
    for (int i = 0; i < cardCount; i++) {
      final double xPos = startX + i * (cardWidth - cardOverlap);
      cardComponents[i].setOriginalPosition(Vector2(xPos, 20));
    }
  }
  
  @override
  void render(Canvas canvas) {
    // Dessiner un fond pour la zone de la main
    final Paint bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(15),
      ),
      bgPaint,
    );
    
    // Dessiner le nom du joueur
    if (player != null) {
      final textPaint = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );
      
      textPaint.render(
        canvas,
        player!.name,
        Vector2(size.x - 20, size.y - 20),
        anchor: Anchor.bottomRight,
      );
      
      // Dessiner le nombre de cartes
      textPaint.render(
        canvas, 
        'Cartes: ${player!.hand.length}',
        Vector2(20, size.y - 20),
        anchor: Anchor.bottomLeft,
      );
    }
  }