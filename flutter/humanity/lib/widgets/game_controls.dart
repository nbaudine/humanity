// lib/widgets/game_controls.dart

import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onEndTurn;
  final VoidCallback onDrawCard;
  final VoidCallback onToggleChat;
  final VoidCallback onToggleSettings;
  final VoidCallback onToggleFullScreen;
  
  const GameControls({
    Key? key,
    required this.onEndTurn,
    required this.onDrawCard,
    required this.onToggleChat,
    required this.onToggleSettings,
    required this.onToggleFullScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bouton pour piocher une carte
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Piocher'),
          onPressed: onDrawCard,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        
        // Bouton pour finir son tour
        ElevatedButton.icon(
          icon: const Icon(Icons.skip_next),
          label: const Text('Fin de tour'),
          onPressed: onEndTurn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        
        const Spacer(),
        
        // Bouton pour afficher/masquer le chat
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          onPressed: onToggleChat,
          tooltip: 'Chat',
        ),
        
        // Bouton pour afficher/masquer les paramètres
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: onToggleSettings,
          tooltip: 'Paramètres',
        ),
        
        // Bouton pour le mode plein écran
        IconButton(
          icon: const Icon(Icons.fullscreen, color: Colors.white),
          onPressed: onToggleFullScreen,
          tooltip: 'Plein écran',
        ),
      ],
    );
  }
}