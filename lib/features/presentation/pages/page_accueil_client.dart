import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'onglet_accueil.dart';
import 'onglet_achats.dart';
import 'onglet_ventes.dart';
import 'onglet_profil.dart';
import '../widgets/app_header_ban.dart';
import '../../../core/services/notification_center.dart';

class PageAccueilClient extends StatefulWidget {
  const PageAccueilClient({super.key, required String role});

  @override
  State<PageAccueilClient> createState() => _PageAccueilClientState();
}

class _PageAccueilClientState extends State<PageAccueilClient> {
  int _currentIndex = 0;

  late final List<Widget> _sections = [
    const OngletAccueil(),
    const OngletAchats(),
    const OngletVentes(),
    const OngletProfil(),
  ];

  final NotificationCenter _notificationCenter = NotificationCenter();

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _notificationCenter.startListening(userId);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          const AppHeaderBan(),

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

                    Container(
                      height: 4,
                      width: 35,
                      decoration: BoxDecoration(
                        color: BanTheme.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 15),

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

      bottomNavigationBar: _buildBanBottomNav(),
    );
  }

  String _getSectionTitle() {
    switch (_currentIndex) {
      case 0:
        return "ACCUEIL";
      case 1:
        return "BOUTIQUE";
      case 2:
        return "MES ARTICLES";
      case 3:
        return "MON PROFIL";
      default:
        return "";
    }
  }

  Widget _buildBanBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: BanTheme.greenTop,
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
