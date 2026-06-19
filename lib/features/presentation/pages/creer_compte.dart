import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bourse_agricole/dependency_injection.dart'; 
import 'package:bourse_agricole/features/presentation/blocs/blocks.dart';
import 'package:bourse_agricole/features/presentation/blocs/events.dart';
import 'package:bourse_agricole/features/presentation/blocs/states.dart';

class CreationCompte extends StatefulWidget {
  const CreationCompte({super.key});

  @override
  State<CreationCompte> createState() => _CreationCompteState();
}

class _CreationCompteState extends State<CreationCompte> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController(); // Nouveau champ
  final _passController = TextEditingController();
  
  bool _obscureText = true;
  final _registerBloc = sl<EnregistrerBloc>();

  static const Color banGreenTop = Color(0xFF1B5E20); 
  static const Color banPurpleBottom = Color(0xFF3F51B5); 
  static const Color darkButton = Color(0xFF303F9F); 
  static const Color inputFill = Color(0xFFF3F4F6); 

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EnregistrerBloc, BanState>(
        bloc: _registerBloc,
        listener: (context, state) {
          if (state is SuccesState<bool>) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Compte créé avec succès !"), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is EchecState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [banGreenTop, banPurpleBottom],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text("INSCRIPTION", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                  const Text("BAN BUNIA", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 50),

                  _buildModelInput(controller: _nomController, hint: "Nom complet", icon: Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildModelInput(controller: _emailController, hint: "Adresse email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildModelInput(controller: _telephoneController, hint: "Téléphone (ex: +243...)", icon: Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildPasswordInput(),
                  
                  const SizedBox(height: 50),

                  BlocBuilder<EnregistrerBloc, BanState>(
                    bloc: _registerBloc,
                    builder: (context, state) {
                      return _buildModelButton(
                        text: "CRÉER MON COMPTE",
                        isLoading: state is LoadingState,
                        onPressed: state is LoadingState ? null : _handleSignUp,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Déjà un compte ? Connectez-vous", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() {
    if (_emailController.text.isEmpty || _nomController.text.isEmpty || _passController.text.isEmpty || _telephoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs"), backgroundColor: Colors.orange));
      return;
    }
    
    // On envoie "client" comme rôle pour correspondre au SQL
    _registerBloc.add(EnregistrerEvent(
      email: _emailController.text.trim(),
      nomComplet: _nomController.text.trim(),
      motDePasse: _passController.text.trim(),
      telephone: _telephoneController.text.trim(), 
      role: "client", 
    ));
  }

  // --- DESIGN WIDGETS ---

  Widget _buildPasswordInput() {
    return TextField(
      controller: _passController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: "Mot de passe",
        prefixIcon: const Icon(Icons.lock_outline, color: banPurpleBottom),
        suffixIcon: IconButton(
          // ignore: deprecated_member_use
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: banPurpleBottom.withOpacity(0.6)),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        filled: true,
        fillColor: inputFill,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: const BorderSide(color: Color(0xFF1A202C), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: const BorderSide(color: Colors.white, width: 2)),
      ),
    );
  }

  Widget _buildModelInput({required TextEditingController controller, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: banPurpleBottom),
        filled: true,
        fillColor: inputFill,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: const BorderSide(color: Color(0xFF1A202C), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: const BorderSide(color: Colors.white, width: 2)),
      ),
    );
  }

  Widget _buildModelButton({required String text, required VoidCallback? onPressed, required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: darkButton, foregroundColor: Colors.white, shape: const StadiumBorder()),
        child: isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}