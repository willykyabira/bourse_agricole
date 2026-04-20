import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../router.dart';
import '../../../data/models/user_model.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  
  // Rôle sélectionné par défaut
  UserRole _selectedRole = UserRole.vendeur;

  void _handleLogin() async {
    final authRepo = AuthRepository();
    try {
      // Tentative de connexion via Supabase/Repository
      await authRepo.signIn(_email.text.trim(), _pass.text.trim());
      
      if (mounted) {
        // Redirection vers l'écran correspondant au rôle choisi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppRouter.getRoleBasedScreen(_selectedRole),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Identifiants incorrects : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20); 

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), 
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- LOGO BAN ---
                Image.asset(
                  'assets/images/logo_ban.png', 
                  height: 90,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.agriculture, size: 80, color: primaryGreen
                  ),
                ),
                
                const SizedBox(height: 10),
                const Text(
                  "Bourse Agricole Numérique",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: primaryGreen
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // --- CHAMP EMAIL ---
                _buildLabel("Email"),
                _buildTextField(_email, "", Icons.person_outline),
                
                const SizedBox(height: 20),
                
                // --- CHAMP MOT DE PASSE ---
                _buildLabel("Mot de Passe"),
                _buildTextField(_pass, "••••••", Icons.lock_outline, obscure: true),
                
                const SizedBox(height: 20),

                // --- LISTE DÉROULANTE DES RÔLES ---
                _buildLabel("Se connecter en tant que :"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    color: const Color(0xFFF8F9FA),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      value: _selectedRole,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: primaryGreen),
                      items: const [
                        DropdownMenuItem(value: UserRole.vendeur, child: Text("Vendeur (Agriculteur)")),
                        DropdownMenuItem(value: UserRole.acheteur, child: Text("Acheteur")),
                        DropdownMenuItem(value: UserRole.gestionnaire, child: Text("Gestionnaire de Stock")),
                        DropdownMenuItem(value: UserRole.finance, child: Text("Chargé de Finance")),
                        DropdownMenuItem(value: UserRole.admin, child: Text("Administrateur")),
                      ],
                      onChanged: (UserRole? newValue) {
                        if (newValue != null) setState(() => _selectedRole = newValue);
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 35),
                
                // --- BOUTON SE CONNECTER ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handleLogin, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Se Connecter", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // --- LIEN CRÉATION DE COMPTE ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Nouveau sur BAN ?", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const RegisterScreen())
                      ), 
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                
                TextButton(
                  onPressed: () {}, 
                  child: const Text("Mot de passe oublié ?", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}