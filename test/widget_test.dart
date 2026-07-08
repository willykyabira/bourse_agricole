import 'package:flutter_test/flutter_test.dart';

// Importez votre véritable fichier main.dart
import 'package:bourse_agricole/main.dart';

/// ======================================================================
/// TEST DU DÉMARRAGE DE L'APPLICATION BAN
/// ----------------------------------------------------------------------
/// Ce test vérifie que l'application démarre correctement
/// et que son interface principale est bien affichée.
/// ======================================================================
void main() {
  testWidgets(
    "L'application BAN démarre correctement",
    (WidgetTester tester) async {
      // --------------------------------------------------------------
      // Lancement de l'application
      // --------------------------------------------------------------
      await tester.pumpWidget(const MyApp());

      // Attendre le chargement complet des widgets
      await tester.pumpAndSettle();

      // --------------------------------------------------------------
      // Vérification qu'un texte contenant "BAN" est présent.
      // --------------------------------------------------------------
      expect(find.textContaining("BAN"), findsWidgets);
    },
  );
}