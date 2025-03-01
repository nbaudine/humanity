// lib/widgets/game_chat.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';

class GameChat extends StatefulWidget {
  final String gameId;
  final VoidCallback onClose;
  
  const GameChat({
    Key? key,
    required this.gameId,
    required this.onClose,
  }) : super(key: key);

  @override
  State<GameChat> createState() => _GameChatState();
}

class _GameChatState extends State<GameChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  // Simuler des messages pour la démo
  @override
  void initState() {
    super.initState();
    
    // Ajouter quelques messages de test
    _messages.addAll([
      ChatMessage(
        sender: 'Système',
        message: 'Bienvenue dans le chat du jeu!',
        isSystem: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        sender: 'Joueur 1',
        message: 'Bonjour à tous!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        sender: 'Joueur 2',
        message: 'Salut, prêt pour la partie?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ]);
    
    // Faire défiler vers le bas après le rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  
  // Faire défiler vers le bas
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  // Envoyer un message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final gameService = Provider.of<GameService>(context, listen: false);
    final playerName = gameService.localPlayer?.name ?? 'Joueur';
    
    // Ajouter le message à la liste locale
    setState(() {
      _messages.add(ChatMessage(
        sender: playerName,
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
      ));
      
      _messageController.clear();
    });
    
    // Faire défiler vers le bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    
    // Envoyer le message au serveur (dans une implémentation réelle)
    // gameService.sendChatMessage(widget.gameId, _messageController.text.trim());
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.grey.shade800,
      elevation: 8,
      child: Column(
        children: [
          // En-tête du chat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.blue.shade800,
            child: Row(
              children: [
                const Icon(Icons.chat, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Chat du jeu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
              ],
            ),
          ),
          
          // Liste des messages
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade900,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageItem(message);
                },
              ),
            ),
          ),
          
          // Zone de saisie de message
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Saisissez un message...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade700,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageItem(ChatMessage message) {
    final gameService = Provider.of<GameService>(context, listen: false);
    final isCurrentUser = message.sender == gameService.localPlayer?.name;
    
    // Formater l'heure du message
    final time = '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    
    if (message.isSystem) {
      // Message système
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }
    
    // Message d'utilisateur
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue.shade700,
              child: Text(
                message.sender.isNotEmpty
                    ? message.sender[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          
          const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue.shade700 : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.sender,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  Text(
                    message.message,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isCurrentUser)
            const SizedBox(width: 8),
          
          if (isCurrentUser)
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue.shade700,
              child: Text(
                message.sender.isNotEmpty
                    ? message.sender[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isSystem;
  
  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    this.isSystem = false,
  });
}