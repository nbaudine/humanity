// lib/game/components/card_component.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

import '../../models/card.dart';

class CardComponent extends PositionComponent with TapCallbacks, DragCallbacks {
  final GameCard card;
  final double cardWidth;
  final double cardHeight;
  final VoidCallback? onTap;
  final void Function(CardComponent card)? onCardSelected;
  
  bool isSelected = false;
  bool isDragging = false;
  Vector2 dragDelta = Vector2.zero();
  Vector2 originalPosition = Vector2.zero();
  
  // Sprites pour la carte
  Sprite? frontSprite;
  Sprite? backSprite;
  
  // Effets visuels
  double _hoverScale = 1.0;
  double _targetHoverScale = 1.0;
  final double _hoverScaleSpeed = 5.0;
  
  // Couleurs et styles
  final Paint _shadowPaint = Paint()
    ..color = Colors.black.withOpacity(0.3)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  
  final Paint _bgPaint = Paint()..color = Colors.white;
  
  final Paint _selectedPaint = Paint()
    ..color = Colors.blue.withOpacity(0.3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  
  CardComponent({
    required this.card,
    required this.cardWidth,
    required this.cardHeight,
    this.onTap,
    this.onCardSelected,
    super.position,
    super.scale,
    super.angle,
    super.priority = 0,
  }) : super(size: Vector2(cardWidth, cardHeight));
  
  @override
  Future<void> onLoad() async {
    // Charger les sprites de la carte
    try {
      if (card.imageUrl.isNotEmpty) {
        try {
          frontSprite = await Sprite.load('cards/${card.imageUrl}');
        } catch (e) {
          debugPrint('Erreur au chargement de l\'image de carte: $e');
          // Utiliser une image de secours ou générer une carte sans image
        }
      }
      try {
        backSprite = await Sprite.load('cards/card_back.png');
      } catch (e) {
        debugPrint('Erreur au chargement du dos de carte: $e');
        // Le dos de carte sera généré par code si l'image n'est pas trouvée
      }
    } catch (e) {
      debugPrint('Erreur générale de chargement: $e');
    }
    
    // Sauvegarder la position d'origine
    originalPosition = position.clone();
  }
  
  @override
  void render(Canvas canvas) {
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(8),
    );
    
    // Dessiner l'ombre
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 5, width, height),
      const Radius.circular(8),
    );
    canvas.drawRRect(shadowRect, _shadowPaint);
    
    // Dessiner le fond de la carte
    canvas.drawRRect(cardRect, _bgPaint);
    
    // Dessiner l'image ou le contenu de la carte
    if (card.isRevealed && frontSprite != null) {
      frontSprite!.render(
        canvas,
        position: Vector2(width / 2, height / 2),
        anchor: Anchor.center,
        size: Vector2(width - 16, height - 40),
      );
      
      // Dessiner le nom et la valeur de la carte
      final textPaint = TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      
      // Dessiner le nom en bas
      textPaint.render(
        canvas,
        card.name,
        Vector2(width / 2, height - 15),
        anchor: Anchor.center,
      );
      
      // Dessiner la valeur en haut à gauche
      textPaint.render(
        canvas,
        '${card.value}',
        Vector2(10, 15),
        anchor: Anchor.centerLeft,
      );
      
    } else if (backSprite != null) {
      // Dessiner le dos de la carte
      backSprite!.render(
        canvas,
        position: Vector2(width / 2, height / 2),
        anchor: Anchor.center,
        size: Vector2(width - 16, height - 16),
      );
    } else {
      // Dessiner un dos de carte générique par défaut
      final Paint backPattern = Paint()
        ..color = Colors.blue.shade800
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(8, 8, width - 16, height - 16),
          const Radius.circular(4),
        ),
        backPattern,
      );
      
      // Motif décoratif sur le dos
      final Paint patternPaint = Paint()
        ..color = Colors.blue.shade500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(16, 16, width - 32, height - 32),
          const Radius.circular(2),
        ),
        patternPaint,
      );
    }
    
    // Dessiner le contour
    final Paint borderPaint = Paint()
      ..color = isSelected ? Colors.blue : Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3 : 1;
    
    canvas.drawRRect(cardRect, borderPaint);
    
    // Dessiner un indicateur de sélection si la carte est sélectionnée
    if (isSelected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 2, width - 4, height - 4),
          const Radius.circular(6),
        ),
        _selectedPaint,
      );
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Animation du survol
    if (_hoverScale != _targetHoverScale) {
      _hoverScale += (_targetHoverScale - _hoverScale) * _hoverScaleSpeed * dt;
      if ((_hoverScale - _targetHoverScale).abs() < 0.01) {
        _hoverScale = _targetHoverScale;
      }
      scale = Vector2.all(_hoverScale);
    }
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    if (onTap != null) {
      onTap!();
    }
    
    toggleSelection();
  }
  
  void toggleSelection() {
    isSelected = !isSelected;
    
    if (isSelected && onCardSelected != null) {
      onCardSelected!(this);
    }
    
    // Effet visuel de sélection
    _targetHoverScale = isSelected ? 1.1 : 1.0;
  }
  
  @override
  void onDragStart(DragStartEvent event) {
    isDragging = true;
    dragDelta = Vector2.zero();
    priority = 100; // Mettre la carte au premier plan pendant le glissement
  }
  
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isDragging) {
      dragDelta += event.delta;
      position = originalPosition + dragDelta;
    }
  }
  
  @override
  void onDragEnd(DragEndEvent event) {
    isDragging = false;
    priority = 0; // Restaurer la priorité normale
    
    // Réinitialiser la position ou laisser la carte à sa nouvelle position
    // selon la logique du jeu
  }
  
  @override
  void onDragCancel(DragCancelEvent event) {
    isDragging = false;
    position = originalPosition;
    priority = 0;
  }
  
  // Méthode pour retourner la carte
  void flip() {
    card.isRevealed = !card.isRevealed;
  }
  
  // Réinitialiser la position
  void resetPosition() {
    position = originalPosition.clone();
  }
  
  // Définir une nouvelle position d'origine
  void setOriginalPosition(Vector2 newPosition) {
    originalPosition = newPosition.clone();
    position = originalPosition.clone();
  }
}