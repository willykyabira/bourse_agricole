import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bourse_agricole/dependency_injection.dart';
import 'package:bourse_agricole/features/presentation/blocs/blocks.dart';
import 'package:bourse_agricole/features/presentation/blocs/events.dart';
import 'package:bourse_agricole/features/presentation/blocs/states.dart';
import 'package:bourse_agricole/features/presentation/pages/page_accueil_client.dart';

import 'creer_compte.dart';

/// Écran de connexion destiné aux clients.
class EcranConnexionClient extends StatefulWidget {
  const EcranConnexionClient({super.key});

  @override
  State<EcranConnexionClient> createState() =>
      _EcranConnexionClientState();
}

class _EcranConnexionClientState
    extends State<EcranConnexionClient> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authBloc = sl<AuthentifierBloc>();

  bool _obscureText = true;

  static const Color banGreenTop = Color(0xFF1B5E20);
  static const Color banPurpleBottom = Color(0xFF3F51B5);
  static const Color darkButton = Color(0xFF303F9F);
  static const Color inputFill = Color(0xFFF3F4F6);

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthentifierBloc, BanState>(
        bloc: _authBloc,
        listener: (context, state) {
          if (state is SuccesState<bool>) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const PageAccueilClient(role: "Acheteur"),
              ),
            );
          } else if (state is EchecState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
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
              colors: [
                banGreenTop,
                banPurpleBottom,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  const Text(
                    "BAN",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),

                  const Text(
                    "Bourse Agricole Numérique",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 60),

                  _buildModelInput(
                    controller: _emailController,
                    hint: "votre adresse email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  _buildPasswordInput(),

                  const SizedBox(height: 40),

                  /// Bouton de connexion.
                  BlocBuilder<AuthentifierBloc, BanState>(
                    bloc: _authBloc,
                    builder: (context, state) {
                      return _buildModelButton(
                        text: "CONNECTEZ-VOUS",
                        isLoading: state is LoadingState,
                        onPressed: state is LoadingState
                            ? null
                            : _handleLogin,
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Vous n'avez pas encore de compte ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildModelButton(
                    text: "CREEZ UN COMPTE",
                    isLoading: false,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CreationCompte(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Vérifie les informations puis lance la connexion.
  void _handleLogin() {
    if (_emailController.text.isEmpty ||
        _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
        ),
      );
      return;
    }

    _authBloc.add(
      AuthentifierEvent(
        email: _emailController.text.trim(),
        motDePasse: _passController.text.trim(),
      ),
    );
  }

  /// Champ de saisie du mot de passe.
  Widget _buildPasswordInput() => TextField(
        controller: _passController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: "mot de passe",
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: banPurpleBottom,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off
                  : Icons.visibility,
              // ignore: deprecated_member_use
              color: banPurpleBottom.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          filled: true,
          fillColor: inputFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              color: Color(0xFF1A202C),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
      );

  /// Champ de saisie personnalisé.
  Widget _buildModelInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: banPurpleBottom,
          ),
          filled: true,
          fillColor: inputFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              color: Color(0xFF1A202C),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
      );

  /// Bouton utilisé pour les actions de connexion.
  Widget _buildModelButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkButton,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
}