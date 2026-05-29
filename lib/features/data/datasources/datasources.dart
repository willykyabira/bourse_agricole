import 'package:bourse_agricole/core/resultat/resultat.dart';

abstract class DatabaseDatasource {
  // --- AUTHENTIFICATION & PROFILS ---
  
  // Utilise Supabase Auth + insertion dans la table 'profiles' via votre Trigger SQL
  FutureResultat enregistrer({
    required String email,
    required String nomComplet,
    required String motDePasse,
    required String role, // 'acheteur' ou 'vendeur'
  });

  // Authentification standard
  FutureResultat authentifier(String email, String motDePasse);


  // --- GESTION DES PRODUITS (Table 'public.produits') ---

  // Pour la section Ventes : Ajoute une ligne dans 'produits'
  // Note : On utilise un Map pour passer les colonnes : nom, prix_unitaire, categorie_id, etc.
  FutureResultat ajouterProduit(Map<String, dynamic> donneesProduit);

  // Pour la section Accueil : Récupère la liste avec jointure sur 'vendeurs' et 'categories'
  FutureResultat consulterListeProduits();

  // Pour l'écran de détail (Alibaba style)
  FutureResultat consulterDetailProduit(String idProduit);

  // Pour la barre de recherche de la section Achats
  FutureResultat rechercherProduits(String nomProduit);

  // Pour permettre au vendeur de retirer un article
  FutureResultat supprimerProduit(String idProduit);


  // --- GESTION DES COMMANDES (Table 'public.commandes') ---

  // Création d'une commande quand l'acheteur clique sur "Acheter"
  FutureResultat creerCommande(Map<String, dynamic> donneesCommande);
  
  // Pour la section Profil/Achats : Liste des commandes de l'utilisateur
  FutureResultat consulterMesCommandes(String userId);
}