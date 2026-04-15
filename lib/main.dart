import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'VOTRE_URL_SUPABASE',
    anonKey: 'VOTRE_ANON_KEY',
  );
  runApp(const BourseAgricoleApp());
}

class BourseAgricoleApp extends StatelessWidget {
  const BourseAgricoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bourse Agricole Numérique',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
