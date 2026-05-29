import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bourse_agricole/dependency_injection.dart' as di;

// Imports de tes pages
import 'package:bourse_agricole/features/presentation/pages/connexion.dart';
import 'package:bourse_agricole/features/presentation/pages/creer_compte.dart';
import 'package:bourse_agricole/features/presentation/pages/page_accueil_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Chargement config
    await dotenv.load(fileName: ".env");

    // 2. Initialisation Base de données
// DANS VOTRE main.dart
// 2. Initialisation Base de données
    await Supabase.initialize(
      // On donne le NOM de la variable définie dans le fichier .env
      url: dotenv.get("SUPABASE_URL"), 
      anonKey: dotenv.get("SUPABASE_ANON_KEY"), 
    );

    // 3. Initialisation Injections (Blocs, Repos)
    await di.init();

    runApp(const MyApp());
  } catch (e) {
    // Si ça plante ici, on affiche l'erreur en gros sur l'écran
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text("ERREUR DE DÉMARRAGE :\n$e", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BAN ITURI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const EcranConnexionClient(),
        '/inscription': (context) => const CreationCompte(),
        '/accueil': (context) => const PageAccueilClient(role: 'Acheteur'),
      },
    );
  }
}