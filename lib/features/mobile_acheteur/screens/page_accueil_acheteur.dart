import 'package:flutter/material.dart';
import '../../auth/screens/ecran_connexion.dart';

class PageAccueilAcheteur extends StatefulWidget {
  const PageAccueilAcheteur({super.key});

  @override
  State<PageAccueilAcheteur> createState() => _PageAccueilAcheteurState();
}

class _PageAccueilAcheteurState extends State<PageAccueilAcheteur> {
  int _currentIndex = 0;

  // Palette BAN
  final Color darkGreenBg = const Color(0xFF1B5E20);
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color surfaceWhite = const Color(0xFFFFFFFF);
  final Color lightGrey = const Color(0xFFF5F7F8);
  final Color accentGold = const Color(0xFFFBC02D);

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _qteController = TextEditingController();
  final TextEditingController _lieuController = TextEditingController();

  final List<Map<String, dynamic>> produitsBAN = [
    {"nom": "Manioc de Mahagi", "prix": 0.50},
    {"nom": "Haricot Jaune", "prix": 1.20},
    {"nom": "Maïs en grain", "prix": 0.80},
    {"nom": "Riz de Bunia", "prix": 1.10},
    {"nom": "Soja", "prix": 1.50},
    {"nom": "Huile de Palme", "prix": 2.00},
  ];

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const EcranConnexion()),
                (route) => false,
              );
            },
            child: const Text("DÉCONNEXION", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
            // --- HEADER IDENTIQUE AU VENDEUR ---
            _buildTopBar(),

            // Corps principal
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
                      _buildAccueilTab(),
                      _buildCommandesTab(),
                      _buildLivraisonTab(),
                      _buildDemandeSpecialeTab(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // LA BARRE SUPÉRIEURE HARMONISÉE
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("BAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
              Text("ESPACE ACHETEUR", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.power_settings_new_rounded, color: accentGold, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // --- LE RESTE DES ONGLETS (ACCUEIL, CATALOGUE, ETC.) ---
  Widget _buildAccueilTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Rechercher un produit...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: lightGrey,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.75,
            ),
            itemCount: produitsBAN.length,
            itemBuilder: (context, index) {
              return _buildProductCard(
                produitsBAN[index]["nom"], 
                produitsBAN[index]["prix"].toString(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String nom, String prix) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: lightGrey, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
              child: Icon(Icons.eco, color: primaryGreen, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$prix\$ / Kg", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w900)),
                    GestureDetector(
                      onTap: () => _showOrderForm(nom, double.parse(prix)),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 16),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderForm(String produit, double prixUnitaire) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Commander : $produit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            _buildInput("Votre Nom Complet", Icons.person_outline, _nomController),
            _buildInput("Téléphone", Icons.phone_android, _telController),
            _buildInput("Quantité (Kg)", Icons.scale_outlined, _qteController),
            _buildInput("Lieu de livraison", Icons.location_on_outlined, _lieuController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () {
                  double qteSaisie = double.tryParse(_qteController.text) ?? 0.0;
                  Navigator.pop(context);
                  _showInvoiceRDC(produit, prixUnitaire, qteSaisie);
                },
                child: const Text("GÉNÉRER LA FACTURE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showInvoiceRDC(String produit, double prixUnitaire, double qte) {
    double totalHT = prixUnitaire * qte;
    double tva = totalHT * 0.16;
    double totalTTC = totalHT + tva;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("BOURSE AGRICOLE NUMÉRIQUE (BAN)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
              const Divider(height: 25),
              _invoiceRow("Désignation", produit),
              _invoiceRow("Quantité", "$qte Kg"),
              _invoiceRow("Prix Unitaire HT", "${prixUnitaire.toStringAsFixed(2)} \$"),
              const Divider(),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: _invoiceRow("TOTAL TTC", "${totalTTC.toStringAsFixed(2)} \$", isBold: true),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("FERMER")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemandeSpecialeTab() => const Center(child: Text("Demandes Spéciales"));
  Widget _buildCommandesTab() => const Center(child: Text("Historique de vos factures"));
  Widget _buildLivraisonTab() => const Center(child: Text("Suivi de livraison"));

  Widget _buildInput(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryGreen, size: 20),
          labelText: label,
          filled: true, fillColor: lightGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _invoiceRow(String l, String v, {bool isBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(v, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))]),
  );

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Accueil", 0),
          _navItem(Icons.receipt_long_outlined, "Commandes", 1),
          _navItem(Icons.local_shipping_outlined, "Livraison", 2),
          _navItem(Icons.help_outline, "Spécial", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool sel = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: sel ? accentGold : Colors.white54, size: 26),
        Text(label, style: TextStyle(color: sel ? Colors.white : Colors.white54, fontSize: 10)),
      ]),
    );
  }
}