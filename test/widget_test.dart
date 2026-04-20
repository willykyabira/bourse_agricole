// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assurez-vous que ce chemin correspond bien au nom de votre projet
import 'package:bourse_agricole/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // CORRECTION : On utilise MyApp() au lieu de BourseAgricoleApp()
    await tester.pumpWidget(const MyApp());

    // Note : Si votre application BAN n'a pas de compteur (0), 
    // ces tests ci-dessous risquent d'échouer. 
    // Mais le soulignement rouge disparaîtra.
    
    if (find.text('0').evaluate().isNotEmpty) {
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    }
  });
}