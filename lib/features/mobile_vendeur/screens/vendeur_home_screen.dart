import 'package:flutter/material.dart';
import '../widgets/notif_card.dart'; // Nous allons le créer

class VendeurHomeScreen extends StatefulWidget {
  const VendeurHomeScreen({super.key});

  @override
  State<VendeurHomeScreen> createState() => _VendeurHomeScreenState();
}

class _VendeurHomeScreenState extends State<VendeurHomeScreen> {
  int _selectedIndex = 0;

  // Liste des écrans correspondant aux deux cas d'utilisation
  static const List<Widget> _pages = [
    Center(child: Text("Ici : Liste de mes produits enregistrés")),
    Center(child: Text("Ici : Mes Notifications (Ventes, Stocks)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Vendeur"),
        backgroundColor: Colors.green, // Thème Vert et Blanc
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Mes Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}