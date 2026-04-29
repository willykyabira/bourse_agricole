import 'package:flutter/material.dart';
import 'data/models/modele_utilisateur.dart';

// Imports des écrans existants
import 'features/web_gestionnaire/screens/tableau_de_bord.dart'; 
import 'features/web_finance/screens/ecran_finance.dart'; 
import 'features/mobile_vendeur/screens/page_accueil_vendeur.dart'; 
import 'features/mobile_acheteur/screens/page_accueil_acheteur.dart'; 

// AJOUT : Import de votre nouvel écran d'administration système
import 'features/web_admin/screens/ecran_admin_systeme.dart'; 

class AppRouter {
  /// Redirige vers le bon écran selon le rôle de l'utilisateur
  static Widget getRoleBasedScreen(UserRole role) {
    switch (role) {
      case UserRole.admin:
        // REMPLACEMENT : On appelle l'écran réel au lieu du texte "Écran Admin"
        return const EcranAdminSysteme(); 

      case UserRole.gestionnaire:
        return const TableauDeBord();
        
      case UserRole.vendeur:
        return const PageAccueilVendeur(); 
        
      case UserRole.finance:
        return const EcranFinance(); 
        
      case UserRole.acheteur:
        return const PageAccueilAcheteur(); 
        
      default:
        return const Scaffold(
          body: Center(child: Text("Rôle non reconnu ou accès restreint")),
        );
    }
  }
}