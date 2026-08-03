import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repositories
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';
import 'package:bourse_agricole/features/data/repositories/auth_repository_impl.dart';

// Use Cases
import 'package:bourse_agricole/features/domain/usecases/authentification.dart';

// Blocs
import 'package:bourse_agricole/features/presentation/blocs/blocks.dart';

// Services
import 'package:bourse_agricole/core/services/toast_service.dart';

/// Instance unique de GetIt (Injection de dépendances).
final sl = GetIt.instance;

/// Enregistre tous les services de l'application.
Future<void> init() async {
  // =========================
  // Services externes
  // =========================

  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // =========================
  // Services
  // =========================

  sl.registerLazySingleton<ToastService>(
    () => ToastService(),
  );

  // =========================
  // Repositories
  // =========================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseClient>()),
  );

  // =========================
  // Use Cases
  // =========================

  sl.registerLazySingleton(
    () => Authentifier(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton(
    () => Enregistrer(repository: sl<AuthRepository>()),
  );

  // =========================
  // Blocs
  // =========================

  sl.registerFactory(
    () => EnregistrerBloc(
      authRepository: sl<AuthRepository>(),
    ),
  );

  sl.registerFactory(
    () => AuthentifierBloc(
      authRepository: sl<AuthRepository>(),
    ),
  );
}
