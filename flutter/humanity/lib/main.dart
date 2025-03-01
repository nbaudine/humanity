// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Vous pouvez conserver cet import pour utiliser les constantes de routes
import 'config/routes.dart';
import 'services/game_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Forcer l'orientation paysage pour le jeu
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialiser Firebase (commenté pour l'instant)
  // await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fournir les services à toute l'application
        ChangeNotifierProvider(create: (_) => GameService()),
      ],
      child: MaterialApp(
        title: 'Jeu de Cartes Flutter Flame',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        // Supprimez ces deux lignes ⬇️
        // initialRoute: AppRoutes.home,
        // routes: AppRoutes.routes,
        // Gardez uniquement la ligne home ⬇️
        home: const HomeScreen(),
      ),
    );
  }
}