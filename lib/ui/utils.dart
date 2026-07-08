import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bourse_agricole/ui/couleurs.dart';

/// ======================================================================
/// Affiche un message temporaire (SnackBar).
///
/// [message] : texte à afficher.
/// [alerte]  :
///    - true  → message d'erreur (rouge)
///    - false → message de succès (vert)
/// ======================================================================
void afficherMessage(
  BuildContext context,
  String message,
  bool alerte,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // Choix automatique de la couleur
      backgroundColor: alerte ? couleurAlerte : couleurSucces,

      // Le texte est centré dans la barre
      content: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),

      // La barre flotte au-dessus de l'écran
      behavior: SnackBarBehavior.floating,
    ),
  );
}