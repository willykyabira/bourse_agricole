import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bourse_agricole/features/presentation/blocs/events.dart';
import 'package:bourse_agricole/features/presentation/blocs/states.dart';
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';

// ================= CONNEXION =================

class AuthentifierBloc extends Bloc<BanEvent, BanState> {
  final AuthRepository authRepository;

  AuthentifierBloc({required this.authRepository}) : super(IdleState()) {

    on<AuthentifierEvent>((event, emit) async {
      emit(LoadingState());
      try {
        await authRepository.signIn(
          email: event.email,
          password: event.motDePasse,
        );
        emit(SuccesState<bool>(true));
      } catch (e) {
        emit(EchecState(e.toString()));
      }
    });
  }
}

// ================= INSCRIPTION =================

class EnregistrerBloc extends Bloc<BanEvent, BanState> {
  final AuthRepository authRepository;

  EnregistrerBloc({required this.authRepository}) : super(IdleState()) {
    on<EnregistrerEvent>((event, emit) async {
      emit(LoadingState());
      try {
        await authRepository.signUp(
          email: event.email,
          password: event.motDePasse,
          nom: event.nomComplet,
          telephone: event.telephone,
          role: event.role,
        );
        emit(SuccesState<bool>(true));
      } catch (e) {
        emit(EchecState(e.toString()));
      }
    });
  }
}

// ================= PRODUITS =================

class ProduitBloc extends Bloc<BanEvent, BanState> {
  ProduitBloc() : super(IdleState()) {
    on<AjouterProduitEvent>((event, emit) async {
      emit(LoadingState());
    });
  }
}
