import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bourse_agricole/features/presentation/blocs/events.dart';
import 'package:bourse_agricole/features/presentation/blocs/states.dart';
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';

// ================= CONNEXION =================

class AuthentifierBloc extends Bloc<BanEvent, BanState> {
  final AuthRepository authRepository;

  AuthentifierBloc({required this.authRepository}) : super(IdleState()) {

    // Écoute l'événement de connexion.
    on<AuthentifierEvent>((event, emit) async {

      // Affiche le chargement.
      emit(LoadingState());

      try {
        // Vérifie les identifiants.
        await authRepository.signIn(
          email: event.email,
          password: event.motDePasse,
        );

        // Connexion réussie.
        emit(SuccesState<bool>(true));

      } catch (e) {
        // Une erreur est survenue.
        emit(EchecState(e.toString()));
      }
    });
  }
}

// ================= INSCRIPTION =================

class EnregistrerBloc extends Bloc<BanEvent, BanState> {
  final AuthRepository authRepository;

  EnregistrerBloc({required this.authRepository}) : super(IdleState()) {

    // Écoute l'événement de création de compte.
    on<EnregistrerEvent>((event, emit) async {

      emit(LoadingState());

      try {
        // Enregistre le nouvel utilisateur.
        await authRepository.signUp(
          email: event.email,
          password: event.motDePasse,
          nom: event.nomComplet,
          telephone: event.telephone,
          role: event.role,
        );

        // Inscription réussie.
        emit(SuccesState<bool>(true));

      } catch (e) {
        // Erreur d'inscription.
        emit(EchecState(e.toString()));
      }
    });
  }
}

// ================= PRODUITS =================

class ProduitBloc extends Bloc<BanEvent, BanState> {

  // Le ProduitRepository pourra être ajouté plus tard.
  ProduitBloc() : super(IdleState()) {

    // Écoute l'ajout d'un produit.
    on<AjouterProduitEvent>((event, emit) async {

      emit(LoadingState());

      // La logique d'ajout sera implémentée ici.
    });
  }
}