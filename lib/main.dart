import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import 'package:bourse_agricole/dependency_injection.dart' as di;
import 'package:bourse_agricole/core/services/toast_service.dart';

// Pages de l'application
import 'package:bourse_agricole/features/presentation/pages/splash_screen.dart';
import 'package:bourse_agricole/features/presentation/pages/connexion.dart';
import 'package:bourse_agricole/features/presentation/pages/creer_compte.dart';
import 'package:bourse_agricole/features/presentation/pages/page_accueil_client.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  try {
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: dotenv.get("SUPABASE_URL"),
      anonKey: dotenv.get("SUPABASE_ANON_KEY"),
    );

    await di.init();

    di.sl<ToastService>();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color banGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BAN ITURI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: banGreen),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/': (_) => const EcranConnexionClient(),
        '/inscription': (_) => const CreationCompte(),
        '/accueil': (_) => const PageAccueilClient(role: 'Acheteur'),
      },
    );
  }
}
