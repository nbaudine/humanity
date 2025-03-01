// lib/widgets/player_status.dart

import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerStatus extends StatelessWidget {
  final List<Player> players;
  final String currentPlayerId;
  final int currentTurn;
  
  const PlayerStatus({
    Key? key,
    required this.players,
    required this.currentPlayerId,
    required this.currentTurn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Joueurs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < players.length; i++)
          _buildPlayerItem(players[i], i),
      ],
    );
  }
  
  Widget _buildPlayerItem(Player player, int index) {
    final isCurrentPlayer = player.id == currentPlayerId;
    final isCurrentTurn = index == currentTurn;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentTurn 
            ? Colors.blue.withOpacity(0.3) 
            : Colors.black26,
        border: Border.all(
          color: isCurrentPlayer
              ? Colors.yellow
              : Colors.transparent,
          width: isCurrentPlayer ? 2 : 0,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Avatar ou icône du joueur
          CircleAvatar(
            radius: 14,
            backgroundColor: isCurrentPlayer ? Colors.yellow : Colors.grey,
            child: Text(
              player.name.isNotEmpty
                  ? player.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCurrentPlayer ? Colors.black : Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Nom du joueur
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Indicateur de tour
          if (isCurrentTurn)
            const Icon(
              Icons.play_arrow,
              color: Colors.yellow,
              size: 16,
            ),
          
          // Nombre de cartes
          Text(
            '${player.hand.length}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          
          const Icon(
            Icons.credit_card,
            color: Colors.white70,
            size: 12,
          ),
        ],
      ),
    );
  }
}