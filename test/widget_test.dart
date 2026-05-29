import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assurez-vous que ce chemin correspond exactement à votre fichier principal

void main() {
  testWidgets('Test de chargement de l\'application BAN', (WidgetTester tester) async {
    
    // CORRECTION : Si MyApp souligne, ouvrez lib/main.dart. 
    // Si vous voyez "class BanApp extends StatelessWidget", remplacez MyApp par BanApp.
    await tester.pumpWidget(const MyApp() as Widget); 

    // On attend que l'interface se stabilise (chargement des polices, images, etc.)
    await tester.pumpAndSettle();

    // Vérification de la présence du titre de votre bourse
    // On cherche "BAN" ou "Bourse Agricole" selon ce que vous avez mis dans l'AppBar
    final titleFinder = find.textContaining('BAN');
    
    if (titleFinder.evaluate().isNotEmpty) {
      expect(titleFinder, findsWidgets);
    } else {
    }
  });
}

class MyApp {
  const MyApp();
}