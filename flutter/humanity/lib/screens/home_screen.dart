// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isConnecting = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    
    // Animation pour l'entrée des éléments
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // Rejoindre ou créer une partie
  void _joinGame(bool createNew) async {
    final name = _nameController.text.trim();
    final server = _serverController.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un nom de joueur';
      });
      return;
    }
    
    // Utiliser localhost par défaut si le serveur n'est pas spécifié
    final serverUrl = server.isEmpty ? 'http://localhost:3000' : server;
    
    setState(() {
      _isConnecting = true;
      _errorMessage = '';
    });
    
    try {
      final gameService = Provider.of<GameService>(context, listen: false);
      
      // Créer un joueur local
      gameService.createPlayer(name, '');
      
      // Essayer de se connecter au serveur (limité à 3 secondes)
      try {
        await gameService.connect(serverUrl);
      } catch (e) {
        // Mode hors ligne pour le développement
        print('Impossible de se connecter au serveur, mode hors ligne activé');
      }
      
      if (createNew) {
        // Créer une nouvelle partie
        gameService.createRoom('Nouvelle partie', {
          'maxPlayers': 4,
          'timePerTurn': 60,
          'gameMode': 'standard',
        });
        
        // Naviguer vers l'écran de jeu (directement pour le développement)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nouvelle partie créée (mode développement)')),
          );
        }
      } else {
        // Rejoindre le lobby pour voir les parties disponibles
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rejoindre une partie (mode développement)')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'Erreur de connexion: $e';
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
              Colors.indigo.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(16),
                  color: Colors.white.withOpacity(0.9),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo et titre
                        const Icon(
                          Icons.casino,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Jeu de Cartes en Ligne',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Avec Flutter et Flame',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Formulaire de connexion
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Votre nom',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _serverController,
                          decoration: const InputDecoration(
                            labelText: 'Serveur (optionnel)',
                            hintText: 'http://localhost:3000',
                            prefixIcon: Icon(Icons.computer),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        
                        // Message d'erreur
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 32),
                        
                        // Boutons d'action
                        if (_isConnecting)
                          const CircularProgressIndicator()
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _joinGame(false),
                                  child: const Text('Rejoindre une partie'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _joinGame(true),
                                  child: const Text('Nouvelle partie'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}