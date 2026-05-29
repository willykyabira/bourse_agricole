import 'package:bourse_agricole/core/resultat/resultat.dart';

abstract class ProduitRepository {
  
  // --- MÉTHODES D'AUTHENTIFICATION (À ajouter pour corriger les erreurs) ---
  
  /// Permet de connecter un utilisateur
  FutureResultat authentifier(String email, String motDePasse);

  /// Permet de créer un compte avec nom et rôle
  FutureResultat enregistrer({
    required String email,
    required String nomComplet,
    required String motDePasse,
    required String role,
  });

  // --- MÉTHODES DE PRODUITS ---

  FutureResultat ajouterProduit(Map<String, dynamic> produitData);
  
  FutureResultat supprimerProduit(String id);
  
  FutureResultat consulterListeProduits();
  
  FutureResultat consulterDetailProduit(String id);

  FutureResultat rechercherProduits(String query);
  
  // Ajout de la commande pour le flux complet
  FutureResultat creerCommande(Map<String, dynamic> donneesCommande);
}