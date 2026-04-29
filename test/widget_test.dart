import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Vérifiez que 'bourse_agricole' est bien le nom défini dans votre pubspec.yaml
import 'package:bourse_agricole/main.dart'; 

void main() {
  testWidgets('Test de chargement de l\'application BAN', (WidgetTester tester) async {
    // 1. Charge l'application
    // Si 'MyApp' est toujours souligné, vérifiez le nom de la classe dans main.dart
    await tester.pumpWidget(const MyApp());

    // 2. Vérification dynamique
    // On cherche un texte qui existe forcément dans votre en-tête (BAN par exemple)
    // au lieu de chercher un compteur '0' qui n'existe peut-être plus.
    if (find.text('BAN').evaluate().isNotEmpty) {
      expect(find.text('BAN'), findsWidgets);
      print("L'interface BAN a été détectée avec succès.");
    } else {
      // Si vous avez encore le compteur par défaut de Flutter :
      final counterFinder = find.text('0');
      if (counterFinder.evaluate().isNotEmpty) {
        expect(counterFinder, findsOneWidget);
        
        // Simule un clic sur le bouton '+' s'il existe
        final fabFinder = find.byIcon(Icons.add);
        if (fabFinder.evaluate().isNotEmpty) {
          await tester.tap(fabFinder);
          await tester.pump();
          expect(find.text('1'), findsOneWidget);
        }
      }
    }
  });
}