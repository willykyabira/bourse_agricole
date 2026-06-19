import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assure-toi que ces fichiers existent dans ton projet
import 'onglet_accueil.dart';
import 'onglet_achats.dart';
import 'onglet_ventes.dart';
import 'onglet_profil.dart';

class PageAccueilClient extends StatefulWidget {
  const PageAccueilClient({super.key, required String role});

  @override
  State<PageAccueilClient> createState() => _PageAccueilClientState();
}

class _PageAccueilClientState extends State<PageAccueilClient> {
  int _currentIndex = 0;

  // Couleurs Officielles BAN Bunia
  final Color banGreenTop = const Color(0xFF1B5E20);
  final Color banBlueBottom = const Color(0xFF3F51B5);
  final Color banGold = const Color(0xFFFBC02D);

  late final List<Widget> _sections = [
    const OngletAccueil(),
    const OngletAchats(),
    const OngletVentes(),
    const OngletProfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ==========================================
          // 1. HEADER AGRANDI (Style Premium)
          // ==========================================
          Container(
            width: double.infinity,
            height: 200, // Hauteur augmentée pour le prestige
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [banGreenTop, banBlueBottom],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    // LOGO À GAUCHE (Cercle blanc sans texte)
                    Container(
                      width: 75,
                      height: 75,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                      child: Center(
                        // Ici, on met l'icône seule pour la clarté
                        child: Icon(
                          Icons.eco_rounded, 
                          color: banGreenTop, 
                          size: 45
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // TITRE À CÔTÉ DU LOGO
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BAN ITURI",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "Bourse Agricole Numérique",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. CONTENU DANS LA CAPSULE BLANCHE (Effet Remontée)
          // ==========================================
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -45), // L'effet de chevauchement
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45), // Arrondi style capture Safari
                    topRight: Radius.circular(45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Titre de l'onglet actif
                    Text(
                      _getSectionTitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Barre décorative dorée
                    Container(
                      height: 4,
                      width: 35,
                      decoration: BoxDecoration(
                        color: banGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // L'espace où vos contenus s'affichent
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _sections,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // ==========================================
      // 3. FOOTER CLARIFIÉ (Navigation Basse)
      // ==========================================
      bottomNavigationBar: _buildBanBottomNav(),
    );
  }

  String _getSectionTitle() {
    switch (_currentIndex) {
      case 0: return "ACCUEIL";
      case 1: return "BOUTIQUE";
      case 2: return "MES ARTICLES";
      case 3: return "MON PROFIL";
      default: return "";
    }
  }

  Widget _buildBanBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: banGreenTop,
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag_rounded),
            label: "Achats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront_rounded),
            label: "Ventes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}