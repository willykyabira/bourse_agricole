import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repositories
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';
import 'package:bourse_agricole/features/data/repositories/auth_repository_impl.dart';

// Use Cases
import 'package:bourse_agricole/features/domain/usecases/authentification.dart';

// Blocs
import 'package:bourse_agricole/features/presentation/blocs/blocks.dart';

/// Instance unique de GetIt (Injection de dépendances).
final sl = GetIt.instance;

/// Enregistre tous les services de l'application.
Future<void> init() async {
  // =========================
  // Services externes
  // =========================

  /// Client Supabase partagé dans toute l'application.
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // =========================
  // Repositories
  // =========================

  /// Gestion de l'authentification.
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseClient>()),
  );

  // =========================
  // Use Cases
  // =========================

  /// Connexion.
  sl.registerLazySingleton(
    () => Authentifier(repository: sl<AuthRepository>()),
  );

  /// Création d'un compte.
  sl.registerLazySingleton(
    () => Enregistrer(repository: sl<AuthRepository>()),
  );

  // =========================
  // Blocs
  // =========================

  /// Bloc d'inscription.
  sl.registerFactory(
    () => EnregistrerBloc(
      authRepository: sl<AuthRepository>(),
    ),
  );

  /// Bloc de connexion.
  sl.registerFactory(
    () => AuthentifierBloc(
      authRepository: sl<AuthRepository>(),
    ),
  );
}