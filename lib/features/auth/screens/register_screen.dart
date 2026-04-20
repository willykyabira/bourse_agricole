import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/repertoire_authentification.dart';
import '../../../data/models/modele_utilisateur.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  final Color primaryGreen = const Color(0xFF1B5E20); 
  UserRole _selectedRole = UserRole.acheteur;
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() => _isLoading = true);
    final authRepo = RepertoireAuthentification();
    try {
      String roleSql;
      switch (_selectedRole) {
        case UserRole.vendeur: roleSql = 'vendeur'; break;
        case UserRole.gestionnaire: roleSql = 'gestionnaire'; break;
        case UserRole.finance: roleSql = 'finance'; break;
        case UserRole.admin: roleSql = 'admin'; break;
        default: roleSql = 'acheteur';
      }

      await authRepo.signUp(_email.text.trim(), _pass.text.trim(), _name.text.trim(), roleSql);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte créé avec succès !")));
        context.go(roleSql == 'vendeur' ? '/vendeur-home' : '/stock-dashboard');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo_ban.png', height: 90, errorBuilder: (context, error, stack) => Icon(Icons.agriculture, size: 70, color: primaryGreen)),
                const SizedBox(height: 15),
                Text("CRÉER UN COMPTE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: primaryGreen, letterSpacing: 1.2)),
                const SizedBox(height: 35),
                TextField(controller: _name, decoration: const InputDecoration(labelText: "Nom complet", prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: _email, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe", prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder())),
                const SizedBox(height: 25),
                const Align(alignment: Alignment.centerLeft, child: Text("Rôle sur la plateforme :", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                const SizedBox(height: 5),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  isExpanded: true,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: UserRole.acheteur, child: Text("Acheteur")),
                    DropdownMenuItem(value: UserRole.vendeur, child: Text("Vendeur (Agriculteur)")),
                    DropdownMenuItem(value: UserRole.gestionnaire, child: Text("Gestionnaire de Stock")),
                    DropdownMenuItem(value: UserRole.finance, child: Text("Chargé de Finance")),
                  ],
                  onChanged: (UserRole? newValue) { if (newValue != null) setState(() => _selectedRole = newValue); },
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("S'ENREGISTRER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ),
                ),
                const SizedBox(height: 25),
                const Divider(),
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Déjà inscrit ? Retour à la connexion", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}