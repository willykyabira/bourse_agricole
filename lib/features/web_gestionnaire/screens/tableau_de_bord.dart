import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ajouter_produit.dart';

class TableauDeBord extends StatefulWidget {
  const TableauDeBord({super.key});

  @override
  State<TableauDeBord> createState() => _TableauDeBordState();
}

class _TableauDeBordState extends State<TableauDeBord> {
  final _supabase = Supabase.instance.client;
  
  // Charte graphique BAN
  final Color primaryGreen = const Color(0xFF1B5E20); 
  final Color bgGrey = const Color(0xFFF4F7F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: _buildHeaderNavigation(),
      body: Column(
        children: [
          _buildSecondaryActions(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatGrid(),
                  const SizedBox(height: 35),
                  _buildSectionHeader(),
                  const SizedBox(height: 25),
                  _buildProductTable(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // --- 1. HEADER NAVIGATION (POLICE UNIFORMISÉE À 14) ---
  PreferredSizeWidget _buildHeaderNavigation() {
    return AppBar(
      backgroundColor: primaryGreen,
      elevation: 4,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset('assets/images/logo_ban.png', 
                    errorBuilder: (context, error, stack) => Icon(Icons.agriculture, color: primaryGreen, size: 28)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("BAN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 0.8)),
                Text("Gestion des Stocks", style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 50),
            _navItem("Tableau de Bord", Icons.grid_view_rounded, active: true),
            _navMenu("Mouvements", ["Réceptions", "Sorties", "Livraisons"]),
            _navMenu("Inventaire", ["Stock Réel", "Alertes Seuil"]),
            _navMenu("Rapports", ["Journaliers", "Hebdomadaire", "Mensuel", "Annuel"]),
          ],
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 22),
          child: VerticalDivider(color: Colors.white24, thickness: 1),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Willy Kyabira", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Gestionnaire de Stock", style: TextStyle(fontSize: 10, color: Colors.white60)),
          ],
        ),
        const SizedBox(width: 15),
        const CircleAvatar(radius: 18, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 18)),
        const SizedBox(width: 40),
      ],
    );
  }

  // Widget pour les items simples
  Widget _navItem(String label, IconData icon, {bool active = false}) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: active ? Colors.white : Colors.white60, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.white60,
          fontSize: 14, // Taille de police fixée
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  // Widget pour les menus déroulants (Police alignée à 14)
  Widget _navMenu(String title, List<String> options) {
    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20)
          ],
        ),
      ),
      itemBuilder: (ctx) => options.map((o) => PopupMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
    );
  }

  // --- 2. STATISTIQUES (NOUVEAUX BLOCS) ---
  Widget _buildStatGrid() {
    return Row(
      children: [
        _statCard("PRODUITS REÇUS", "24", Icons.inventory_2, Colors.green),
        _statCard("QUANTITÉ REÇUE", "4.5 Tonnes", Icons.add_business, Colors.blue),
        _statCard("QUANTITÉ SORTIE", "1.2 Tonnes", Icons.outbox, Colors.orange),
        _statCard("DISPONIBLE (KG)", "3,300", Icons.warehouse, Colors.brown),
        _statCard("VENDEURS", "12", Icons.people, Colors.purple),
      ],
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color col) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: col, width: 6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Icon(icon, color: col, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. TABLEAU DES PRODUITS (BORDURES + ACTIONS) ---
  Widget _buildProductTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase.from('produits').stream(primaryKey: ['id']).order('created_at'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()));
          final data = snapshot.data!;

          return DataTable(
            headingRowColor: WidgetStateProperty.all(bgGrey),
            horizontalMargin: 20,
            columns: const [
              DataColumn(label: Text("N°")),
              DataColumn(label: Text("NOM PRODUIT")),
              DataColumn(label: Text("CATÉGORIE")),
              DataColumn(label: Text("QUANTITÉ")),
              DataColumn(label: Text("UNITÉ")),
              DataColumn(label: Text("PRIX UNIT.")),
              DataColumn(label: Text("PRIX TOTAL")),
              DataColumn(label: Text("ACTIONS")),
            ],
            rows: List<DataRow>.generate(data.length, (index) {
              final p = data[index];
              return DataRow(cells: [
                DataCell(Text("${index + 1}")),
                DataCell(Text(p['nom_produit'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(p['categorie'] ?? '-')),
                DataCell(Text("${p['quantite']}")),
                DataCell(Text(p['unite_mesure'] ?? '')),
                DataCell(Text("${p['prix_unitaire'] ?? 0} \$")),
                DataCell(Text("${p['prix_total'] ?? 0} \$", style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                      onPressed: () => _showEditProductDialog(p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _confirmDeletion(p['id'], p['nom_produit']),
                    ),
                  ],
                )),
              ]);
            }),
          );
        },
      ),
    );
  }

  // --- 4. FOOTER (NORMES BAN) ---
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1C1E),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text("© 2026 BAN PORTAL", style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 30),
              _footerLink("Support"),
              _footerLink("Documentation"),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.green, size: 14),
              const SizedBox(width: 8),
              const Text("SESSION SÉCURISÉE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
              const SizedBox(width: 30),
              Text("v1.4.2", style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // --- LOGIQUE & DIALOGUES ---
  void _confirmDeletion(int id, String nom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer"),
        content: Text("Supprimer $nom du stock ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _supabase.from('produits').delete().match({'id': id});
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const Dialog(child: AjouterProduit(isDialog: true)));
  }

  void _showEditProductDialog(Map<String, dynamic> p) {
    showDialog(context: context, builder: (context) => Dialog(child: AjouterProduit(isDialog: true, productToEdit: p)));
  }

  Widget _buildSecondaryActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: "Rechercher un produit...",
          prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: bgGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddProductDialog(context),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("NOUVELLE RÉCEPTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.all(20)),
        ),
        const SizedBox(width: 25),
        const Text("LISTE DES PRODUITS EN STOCK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ],
    );
  }

  Widget _footerLink(String label) {
    return Padding(padding: const EdgeInsets.only(right: 20), child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)));
  }
}