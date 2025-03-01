import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  // Noms des routes
  static const String home = '/';
  static const String lobby = '/lobby';
  static const String game = '/game';
  
  // Définir les routes
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    // Commenté temporairement
    // lobby: (context) => const LobbyScreen(),
    // game: (context) => GameScreen(gameId: 'test'),
  };
}

class GameScreenArgs {
  final String gameId;
  
  GameScreenArgs({required this.gameId});
}