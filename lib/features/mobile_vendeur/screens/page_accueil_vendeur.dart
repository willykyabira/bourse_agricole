import 'package:flutter/material.dart';
import '../../auth/screens/ecran_connexion.dart'; // Import de l'écran de connexion

class PageAccueilVendeur extends StatefulWidget {
  const PageAccueilVendeur({super.key});

  @override
  State<PageAccueilVendeur> createState() => _PageAccueilVendeurState();
}

class _PageAccueilVendeurState extends State<PageAccueilVendeur> {
  int _currentIndex = 0;

  // Palette BAN Premium
  final Color darkGreenBg = const Color(0xFF1B5E20); 
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color surfaceWhite = const Color(0xFFFFFFFF);
  final Color lightGrey = const Color(0xFFF5F7F8);

  // Fonction de déconnexion avec confirmation
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter de votre compte BAN ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // On nettoie la pile et on retourne à la connexion
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const EcranConnexion()),
                (route) => false,
              );
            },
            child: const Text("SE DÉCONNECTER", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec BAN + Bouton Déconnexion
            _buildTopBar(),

            // Corps principal blanc encadré
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: surfaceWhite,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildHomeTab(),
                      _buildDepotsTab(),
                      _buildProfileTab(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer avec Navigation
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texte BAN à gauche
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("BAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
              Text("Bourse Agricole", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
          // Bouton Déconnexion stylisé à droite
          IconButton(
            onPressed: _handleLogout,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.power_settings_new_rounded, color: Color(0xFFFBC02D), size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // --- ONGLET 1 : ACCUEIL ---
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bienvenue Mr Vendeur,", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const Text("Willy Kyabira", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          _buildBalanceCard(),
          const SizedBox(height: 35),
          const Text("SUIVI DES VENTES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54, letterSpacing: 1)),
          const SizedBox(height: 15),
          _buildSimpleStatusTile("Manioc", "Vendu & Payé", "480\$", true),
          _buildSimpleStatusTile("Haricots", "En cours de vente", "250\$", false),
          _buildSimpleStatusTile("Riz", "En cours de vente", "100\$", false),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: const Column(
        children: [
          Text("ARGENT TOTAL PERÇU", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("480,00 \$", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // --- ONGLET 2 : DÉPÔTS ---
  Widget _buildDepotsTab() {
    final List<Map<String, dynamic>> produitsStock = [
      {
        "nom": "Manioc Séché",
        "poids": "1,200 Kg",
        "prix_unitaire": "0.40 \$ / Kg",
        "lieu": "Dépôt Bunia",
        "total": "480 \$",
        "gestionnaire": "Drajiro Roland",
        "date": "20/04/2026"
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: produitsStock.length,
      itemBuilder: (context, index) {
        final p = produitsStock[index];
        return GestureDetector(
          onTap: () => _showProductDetails(p),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: lightGrey, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: primaryGreen),
                const SizedBox(width: 15),
                Expanded(child: Text(p['nom'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductDetails(Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(p['nom'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            _infoLine("Prix Unitaire", p['prix_unitaire']),
            _infoLine("Poids", p['poids']),
            _infoLine("Lieu", p['lieu']),
            _infoLine("Valeur totale", p['total']),
            _infoLine("Date dépôt", p['date']),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, minimumSize: const Size(double.infinity, 50)),
              onPressed: () => Navigator.pop(context),
              child: const Text("FERMER", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- ONGLET 3 : PROFIL ---
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(radius: 50, backgroundColor: lightGrey, child: Icon(Icons.person, size: 50, color: Colors.grey[400])),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildInputField("Nom", "Kyabira"),
          _buildInputField("Post-nom", "Kyabira"),
          _buildInputField("Prénom", "Willy"),
          _buildInputField("Adresse", "Bunia, Ituri"),
          _buildInputField("Téléphone", "+243 ..."),
          _buildInputField("Email", "willy@example.com"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {},
              child: const Text("ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          // Option de déconnexion secondaire dans le profil
          TextButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Se déconnecter", style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGETS DE NAVIGATION ET STYLE ---
  Widget _buildInputField(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true, fillColor: lightGrey,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: darkGreenBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, "Accueil", 0),
          _navItem(Icons.assignment_rounded, "Dépôts", 1),
          _navItem(Icons.person_pin_rounded, "Profil", 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool sel = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: sel ? const Color(0xFFFBC02D) : Colors.white54, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: sel ? Colors.white : Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSimpleStatusTile(String t, String s, String p, bool v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: surfaceWhite, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(v ? Icons.check_circle_rounded : Icons.access_time_filled_rounded, color: v ? Colors.green : Colors.orange, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), Text(s, style: TextStyle(color: v ? Colors.green : Colors.grey, fontSize: 12))])),
          Text(p, style: TextStyle(fontWeight: FontWeight.w900, color: darkGreenBg, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.black54)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
  }
}