import 'package:flutter/material.dart';

class AppTheme {
  // Le mot-clé 'static' est indispensable ici
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF2E7D32), // Vert agriculture
      scaffoldBackgroundColor: Colors.white,
      // Ajoutez ici les autres configurations de votre thème
    );
  }
}