import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../router.dart';
import '../../../data/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  void _handleLogin() async {
    final authRepo = AuthRepository();
    try {
      final response = await authRepo.login(_email.text, _pass.text);
      final roleStr = await authRepo.getUserRole(response.user!.id);
      
      // Conversion du String de Supabase vers l'Enum Dart
      final role = UserRole.values.firstWhere((e) => e.name == roleStr);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AppRouter.getRoleBasedScreen(role)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400, // Format adapté au Web et Mobile
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.agriculture, size: 80, color: Colors.green),
              const Text("BOURSE AGRICOLE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _handleLogin, child: const Text("Se connecter")),
              TextButton(onPressed: () {}, child: const Text("S'enregistrer (Créer un compte)"))
            ],
          ),
        ),
      ),
    );
  }
}
