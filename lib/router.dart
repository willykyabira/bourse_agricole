import 'package:bourse_agricole/features/mobile_vendeur/screens/page_accueil_vendeur.dart';
import 'package:flutter/material.dart';
import 'data/models/modele_utilisateur.dart';
// Importez vos écrans ici
import 'features/web_gestionnaire/screens/tableau_de_bord.dart'; 
// AJOUTEZ CET IMPORT (vérifiez bien le chemin selon votre dossier)
import 'features/mobile_vendeur/screens/page_accueil_vendeur.dart'; 

class AppRouter {
  /// Redirige vers le bon écran selon le rôle de l'utilisateur
  static Widget getRoleBasedScreen(UserRole role) {
    switch (role) {
      case UserRole.gestionnaire:
        return const TableauDeBord();
      case UserRole.vendeur:
        // REMPLACEZ LA LIGNE PRÉCÉDENTE PAR CELLE-CI :
        return const PageAccueilVendeur(); 
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