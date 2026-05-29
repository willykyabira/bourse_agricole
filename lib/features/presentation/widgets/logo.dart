import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoBAN extends StatelessWidget {
  const LogoBAN({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation de vos couleurs officielles
    const Color banGreen = Color(0xFF1B5E20);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        // Remplacement du SVG par une icône Flutter en attendant votre fichier design
        // Si vous avez un logo.svg, décommentez la partie SvgPicture ci-dessous
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: banGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.eco_rounded, // Icône de feuille/agriculture
            size: 60,
            color: banGreen,
          ),
        ),
        
        /* SvgPicture.asset(
          "assets/design/logo_ban.svg",
          width: 70,
          height: 70,
          colorFilter: const ColorFilter.mode(banGreen, BlendMode.srcIn),
        ), 
        */

        const SizedBox(height: 15),
        
        // Nom de l'application avec une police professionnelle
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