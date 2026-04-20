import 'package:flutter/material.dart';
import 'data/models/user_model.dart';
// Importez vos écrans ici
import 'features/web_gestionnaire/screens/stock_dashboard.dart'; 

class AppRouter {
  /// Redirige vers le bon écran selon le rôle de l'utilisateur
  static Widget getRoleBasedScreen(UserRole role) {
    switch (role) {
      case UserRole.gestionnaire:
        return const StockDashboard();
      case UserRole.vendeur:
        // Remplacez par votre écran Vendeur
        return const Scaffold(body: Center(child: Text("Écran Vendeur"))); 
      case UserRole.acheteur:
        return const Scaffold(body: Center(child: Text("Écran Acheteur")));
      case UserRole.finance:
        return const Scaffold(body: Center(child: Text("Écran Finance")));
      case UserRole.admin:
        return const Scaffold(body: Center(child: Text("Écran Admin")));
      default:
        return const Scaffold(body: Center(child: Text("Rôle non reconnu")));
    }
  }
}