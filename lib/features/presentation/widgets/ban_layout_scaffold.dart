import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_header_ban.dart';

/// Un layout de page réutilisable et homogène pour toute l'application BAN ITURI.
/// Il affiche l'en-tête officiel en dégradé, suivi d'un grand conteneur blanc
/// aux coins arrondis superposé contenant le titre et le corps de page.
class BanLayoutScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String bodyTitle;
  final Widget body;
  final bool showNotifications;
  final bool showBackButton;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const BanLayoutScaffold({
    super.key,
    this.title = "BAN ITURI",
    this.subtitle = "Bourse Agricole Numérique",
    required this.bodyTitle,
    required this.body,
    this.showNotifications = false,
    this.showBackButton = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          // En-tête BAN uniforme
          AppHeaderBan(
            title: title,
            subtitle: subtitle,
            showNotifications: showNotifications,
            showBackButton: showBackButton,
          ),

          // Corps de page uniforme avec décalage de superposition
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -45),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Titre uniforme de la page active
                    Text(
                      bodyTitle.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Ligne décorative dorée uniforme
                    Container(
                      height: 4,
                      width: 35,
                      decoration: BoxDecoration(
                        color: BanTheme.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Corps variable de la page
                    Expanded(
                      child: body,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
