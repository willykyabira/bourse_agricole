import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ======================================================================
/// LOGO OFFICIEL DE LA BOURSE AGRICOLE NUMÉRIQUE (BAN ITURI)
/// Ce widget peut être utilisé sur tous les écrans de l'application.
/// ======================================================================
class LogoBAN extends StatelessWidget {
  const LogoBAN({super.key});

  /// Couleur officielle de la plateforme
  static const Color banGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),

        // -----------------------------------------------------------------
        // Icône principale
        // -----------------------------------------------------------------
        // Vous pouvez remplacer cette icône par votre logo SVG plus tard.
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: banGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 60,
            color: banGreen,
          ),
        ),

        /*
        --------------------------------------------------------------------
        Si vous possédez un fichier logo_ban.svg,
        décommentez ce code après avoir ajouté flutter_svg.
        --------------------------------------------------------------------

        SvgPicture.asset(
          "assets/design/logo_ban.svg",
          width: 70,
          height: 70,
          colorFilter: const ColorFilter.mode(
            banGreen,
            BlendMode.srcIn,
          ),
        ),
        */

        const SizedBox(height: 15),

        // -----------------------------------------------------------------
        // Nom de l'application
        // -----------------------------------------------------------------
        Text(
          "BAN ITURI",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: banGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 5),

        // -----------------------------------------------------------------
        // Slogan
        // -----------------------------------------------------------------
        Text(
          "Bourse Agricole Numérique",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}