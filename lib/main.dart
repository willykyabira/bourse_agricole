import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/ecran_connexion.dart';

void main() async {
  // 1. Assure l'initialisation des widgets Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation de Supabase (remplacez par vos vraies clés)
  await Supabase.initialize(
    url: 'https://djrywiufzvpuybkzqlow.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqcnl3aXVmenZwdXlia3pxbG93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNjU5NTIsImV4cCI6MjA4MDk0MTk1Mn0.1I1qDV59WJrQ-dNHRLgASxlB2kMQxm5ZXzZTGQKI1Gw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAN Portal',
      debugShowCheckedModeBanner: false,
      
      // --- THÈME COULEUR BAN ---
      theme: ThemeData(
        primaryColor: const Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Ou votre police préférée
      ),

      // 3. Point d'entrée : l'écran de Login que vous avez corrigé
      home: const EcranConnexion(),
    );
  }
}
