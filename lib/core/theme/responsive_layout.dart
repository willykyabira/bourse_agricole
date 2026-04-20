import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget webBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.webBody,
  });

  // Fonction utilitaire pour vérifier si on est sur mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  // Fonction utilitaire pour vérifier si on est sur web/tablette
  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return mobileBody; // Affiche la version pour smartphone
        } else {
          return webBody;    // Affiche la version pour ordinateur (Gestion/Finance)
        }
      },
    );
  }
}