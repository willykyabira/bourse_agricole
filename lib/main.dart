import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // 1. AJOUT DE CET IMPORT

import 'package:bourse_agricole/dependency_injection.dart' as di;

// Pages de l'application
import 'package:bourse_agricole/features/presentation/pages/connexion.dart';
import 'package:bourse_agricole/features/presentation/pages/creer_compte.dart';
import 'package:bourse_agricole/features/presentation/pages/page_accueil_client.dart';

// 2. AJOUT DE CETTE CLASSE POUR CONTOURNER LES BLOCAGES SSL SUR L'ÉMULATEUR
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// ======================================================================
/// Point d'entrée de l'application.
/// ======================================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. ACTIVATION DU CORRECTIF RÉSEAU
  HttpOverrides.global = MyHttpOverrides();

  try {
    // --------------------------------------------------------------
    // 1. Charger les variables d'environnement (.env)
    // --------------------------------------------------------------
    await dotenv.load(fileName: ".env");

    // --------------------------------------------------------------
    // 2. Initialiser Supabase
    // --------------------------------------------------------------
    await Supabase.initialize(
      url: dotenv.get("SUPABASE_URL"),
      anonKey: dotenv.get("SUPABASE_ANON_KEY"),
    );

    // --------------------------------------------------------------
    // 3. Initialiser les dépendances
    // --------------------------------------------------------------
    await di.init();

    // --------------------------------------------------------------
    // 4. Lancer l'application
    // --------------------------------------------------------------
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              "ERREUR DE DÉMARRAGE\n\n$e",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================================================================
/// Widget principal
/// ======================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color banGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BAN ITURI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: banGreen,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const EcranConnexionClient(),
        '/inscription': (_) => const CreationCompte(),
        '/accueil': (_) => const PageAccueilClient(
              role: 'Acheteur',
            ),
      },
    );
  }
}