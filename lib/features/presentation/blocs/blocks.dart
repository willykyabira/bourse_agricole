import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bourse_agricole/features/presentation/blocs/events.dart';
import 'package:bourse_agricole/features/presentation/blocs/states.dart';
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';

// ==========================================
// 1. BLOC DE CONNEXION (AUTHENTIFICATION)
// ==========================================
class AuthentifierBloc extends Bloc<BanEvent, BanState> {
  final AuthRepository authRepository;

  AuthentifierBloc({required this.authRepository}) : super(IdleState()) {
    on<AuthentifierEvent>((event, emit) async {
      emit(LoadingState()); // Active le chargement
      try {
        await authRepository.signIn(
          email: event.email,
          password: event.motDePasse,
        );
        // On renvoie SuccesState avec 'true' dans la variable 'valeur'
        emit(SuccesState<bool>(true));
      } catch (e) {
        emit(EchecState(e.toString()));
      }
    });
  }
}

// ==========================================
// 2. BLOC D'INSCRIPTION (CRÉATION DE COMPTE)
// ==========================================
class EnregistrerBloc extends Bloc<BanEvent, BanState> {
  final AuthRepository authRepository;

  EnregistrerBloc({required this.authRepository}) : super(IdleState()) {
    on<EnregistrerEvent>((event, emit) async {
      emit(LoadingState()); // Fait tourner le bouton à Bunia
      try {
        // Envoi des données complètes vers le trigger SQL Supabase
        await authRepository.signUp(
          email: event.email,
          password: event.motDePasse,
          nom: event.nomComplet,
          telephone: event.telephone,
          role: event.role, // Sera "client" par défaut
        );
        
        // Succès : valeur = true
        emit(SuccesState<bool>(true));
      } catch (e) {
        emit(EchecState(e.toString()));
      }
    });
  }
}

// ==========================================
// 3. BLOC PRODUITS (GESTION DU STOCK)
// ==========================================
class ProduitBloc extends Bloc<BanEvent, BanState> {
  // Tu pourras ajouter ton ProduitRepository ici plus tard
  ProduitBloc() : super(IdleState()) {
    // Exemple pour l'ajout de produit
    on<AjouterProduitEvent>((event, emit) async {
      emit(LoadingState());
      // Logique d'ajout...
    });
  }
}