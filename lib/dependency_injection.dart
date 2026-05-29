import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// REPOSITORIES
import 'package:bourse_agricole/features/domain/repositories/auth_repository.dart';
import 'package:bourse_agricole/features/data/repositories/auth_repository_impl.dart';

// USE CASES
import 'package:bourse_agricole/features/domain/usecases/authentification.dart';

// BLOCS
import 'package:bourse_agricole/features/presentation/blocs/blocks.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. EXTERNAL
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // 2. REPOSITORIES
  // On enregistre l'implémentation en lui passant le client Supabase
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<SupabaseClient>()));
  
  // Note: Assure-toi que ProduitRepositoryImpl accepte sl() (le client ou la datasource)


  // 3. USE CASES
  // On passe le repository avec le nom de paramètre "repository" comme défini dans le fichier 3
  sl.registerLazySingleton(() => Authentifier(repository: sl<AuthRepository>()));
  sl.registerLazySingleton(() => Enregistrer(repository: sl<AuthRepository>()));

  // 4. BLOCS
  // Inscription & Connexion : Ils utilisent directement le repository
  sl.registerFactory(() => EnregistrerBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory(() => AuthentifierBloc(authRepository: sl<AuthRepository>()));
}