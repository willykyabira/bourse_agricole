import 'package:flutter/material.dart';
import '../../../data/repositories/repertoire_authentification.dart';
import '../../../router.dart';
import '../../../data/models/modele_utilisateur.dart';
import 'creer_compte.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});

  @override
  State<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends State<EcranConnexion> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  
  // Rôle sélectionné par défaut
  UserRole _selectedRole = UserRole.vendeur;

  // État pour afficher/masquer le mot de passe
  bool _obscureText = true;

  void _handleLogin() async {
    final authRepo = RepertoireAuthentification();
    try {
      await authRepo.signIn(_email.text.trim(), _pass.text.trim());
      
      if (mounted) {
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
                
                _buildLabel("Email"),
                _buildTextField(_email, "Entrez votre email", Icons.person_outline),
                
                const SizedBox(height: 20),
                
                _buildLabel("Mot de Passe"),
                // UTILISATION DU CHAMP MOT DE PASSE AVEC L'OEIL
                _buildPasswordField(),
                
                const SizedBox(height: 20),

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
                        DropdownMenuItem(value: UserRole.vendeur, child: Text("Vendeur")),
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
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Nouveau sur BAN ?", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const CreationCompte())
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

  // Widget générique pour l'email
  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
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

  // WIDGET SPÉCIFIQUE POUR LE MOT DE PASSE AVEC ICÔNE DE VISIBILITÉ
  Widget _buildPasswordField() {
    return TextField(
      controller: _pass,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: "••••••",
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        // AJOUT DE L'ICÔNE OEIL
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
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