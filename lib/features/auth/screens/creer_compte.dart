import 'package:flutter/material.dart';
// Vérifiez bien que ce chemin correspond à l'emplacement de votre fichier ecran_connexion.dart
import '../../auth/screens/ecran_connexion.dart'; 
import '../../../data/repositories/repertoire_authentification.dart';
import '../../../data/models/modele_utilisateur.dart';

class CreationCompte extends StatefulWidget {
  const CreationCompte({super.key});

  @override
  State<CreationCompte> createState() => _CreationCompteState();
}

class _CreationCompteState extends State<CreationCompte> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  final Color primaryGreen = const Color(0xFF1B5E20); 
  
  // Par défaut, on propose Acheteur pour l'inscription publique
  UserRole _selectedRole = UserRole.acheteur; 
  bool _isLoading = false;

  void _handleRegister() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs"))
      );
      return;
    }

    setState(() => _isLoading = true);
    final authRepo = RepertoireAuthentification();
    
    try {
      String roleSql;
      switch (_selectedRole) {
        case UserRole.vendeur: 
          roleSql = 'vendeur'; 
          break;
        default: 
          roleSql = 'acheteur';
      }

      await authRepo.signUp(
        _email.text.trim(), 
        _pass.text.trim(), 
        _name.text.trim(), 
        roleSql
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé avec succès !"))
        );
        
        // Après inscription, on retourne à l'écran de connexion pour que l'utilisateur s'identifie
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EcranConnexion()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red)
        );
      }
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), 
                  blurRadius: 25, 
                  offset: const Offset(0, 10)
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_ban.png', 
                  height: 90, 
                  errorBuilder: (context, error, stack) => Icon(Icons.agriculture, size: 70, color: primaryGreen)
                ),
                const SizedBox(height: 15),
                Text(
                  "CRÉER UN COMPTE", 
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 20, 
                    color: primaryGreen, 
                    letterSpacing: 1.2
                  )
                ),
                const SizedBox(height: 35),
                TextField(
                  controller: _name, 
                  decoration: const InputDecoration(
                    labelText: "Nom complet", 
                    prefixIcon: Icon(Icons.person_outline), 
                    border: OutlineInputBorder()
                  )
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _email, 
                  decoration: const InputDecoration(
                    labelText: "Email", 
                    prefixIcon: Icon(Icons.email_outlined), 
                    border: OutlineInputBorder()
                  )
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _pass, 
                  obscureText: true, 
                  decoration: const InputDecoration(
                    labelText: "Mot de passe", 
                    prefixIcon: Icon(Icons.lock_outline), 
                    border: OutlineInputBorder()
                  )
                ),
                const SizedBox(height: 25),
                
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text(
                    "Vous êtes :", 
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)
                  )
                ),
                const SizedBox(height: 5),
                
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10), 
                    border: OutlineInputBorder()
                  ),
                  items: const [
                    DropdownMenuItem(value: UserRole.acheteur, child: Text("Acheteur (Client)")),
                    DropdownMenuItem(value: UserRole.vendeur, child: Text("Vendeur (Agriculteur)")),
                  ],
                  onChanged: (UserRole? newValue) { 
                    if (newValue != null) setState(() => _selectedRole = newValue); 
                  },
                ),
                
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity, 
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen, 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          ) 
                        : const Text("S'ENREGISTRER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ),
                ),
                const SizedBox(height: 25),
                const Divider(),
                
                // --- BOUTON RETOUR CORRIGÉ ---
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const EcranConnexion()),
                      (route) => false,
                    );
                  }, 
                  child: Text(
                    "Déjà inscrit ? Retour à la connexion", 
                    style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}