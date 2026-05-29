import 'package:bourse_agricole/features/data/datasources/datasources.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bourse_agricole/core/exceptions/exceptions.dart';
import 'package:bourse_agricole/core/resultat/resultat.dart';

// 1. BIEN IMPORTER l'interface

// 2. CORRECTION : Le nom de la classe commence par une Majuscule 
// et elle implémente (extends) l'interface DatabaseDatasource
class SupabaseDatasourceImpl extends DatabaseDatasource {
  final SupabaseClient client;

  SupabaseDatasourceImpl(this.client);
  
  // ignore: non_constant_identifier_names, strict_top_level_inference
  get ProduitModel => null;

  @override
  FutureResultat authentifier(String email, String motDePasse) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: motDePasse,
      );
      if (response.user != null) {
        return Succes(true);
      }
      throw ServerException(message: "Erreur d'authentification.");
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: "Erreur de connexion.");
    }
  }

  @override
  FutureResultat enregistrer({
    required String email,
    required String nomComplet,
    required String motDePasse,
    required String role,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: motDePasse,
        data: {
          'nom_complet': nomComplet,
          'role': role,
        },
      );
      if (response.user != null) {
        return Succes(true);
      }
      throw ServerException(message: "Erreur lors de l'inscription.");
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: "Erreur inattendue.");
    }
  }

  @override
  FutureResultat ajouterProduit(Map<String, dynamic> donneesProduit) async {
    try {
      await client.from('produits').insert(donneesProduit);
      return Succes(true);
    } catch (e) {
      throw ServerException(message: "Impossible d'ajouter le produit.");
    }
  }

  @override
  FutureResultat consulterListeProduits() async {
    try {
      final resultat = await client.from('produits').select('''
            *,
            categories(nom),
            vendeurs(nom_exploitation)
          ''').order('created_at', ascending: false);

      final produits = (resultat as List)
          .map((json) => ProduitModel.fromJSON(json))
          .toList();
          
      return Succes(produits);
    } catch (e) {
      throw ServerException(message: "Erreur de récupération.");
    }
  }

  @override
  FutureResultat consulterDetailProduit(String idProduit) async {
    try {
      final resultat = await client.from('produits').select('''
            *,
            categories(nom),
            vendeurs(*, profiles(nom_complet))
          ''').eq('id', idProduit).single();

      return Succes(ProduitModel.fromJSON(resultat));
    } catch (e) {
      throw ServerException(message: "Produit introuvable.");
    }
  }

  @override
  FutureResultat rechercherProduits(String nomProduit) async {
    try {
      final resultat = await client
          .from('produits')
          .select('*, categories(nom)')
          .ilike('nom', '%$nomProduit%');

      final produits = (resultat as List)
          .map((json) => ProduitModel.fromJSON(json))
          .toList();

      return Succes(produits);
    } catch (e) {
      throw ServerException(message: "Erreur de recherche.");
    }
  }

  @override
  FutureResultat supprimerProduit(String idProduit) async {
    try {
      await client.from('produits').delete().eq('id', idProduit);
      return Succes(true);
    } catch (e) {
      throw ServerException(message: "Impossible de supprimer.");
    }
  }

  @override
  FutureResultat creerCommande(Map<String, dynamic> donneesCommande) async {
    try {
      await client.from('commandes').insert(donneesCommande);
      return Succes(true);
    } catch (e) {
      throw ServerException(message: "Échec de la commande.");
    }
  }
  
  @override
  FutureResultat consulterMesCommandes(String userId) => throw UnimplementedError();
}