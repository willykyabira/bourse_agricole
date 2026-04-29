import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EcranFinance extends StatefulWidget {
  const EcranFinance({super.key});

  @override
  State<EcranFinance> createState() => _EcranFinanceState();
}

class _EcranFinanceState extends State<EcranFinance> {
  // Palette de couleurs BAN (Bourse Agricole Numérique)
  final Color greenHeader = const Color(0xFF1B5E20);
  final Color greenAccent = const Color(0xFF2E7D32);
  final Color bgLight = const Color(0xFFF4F7F6);
  final Color surfaceWhite = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          // 1. BARRE DE NAVIGATION SUPÉRIEURE (HEADER)
          _buildTopHeader(),

          Expanded(
            child: Row(
              children: [
                // 2. MENU LATÉRAL (NAVIGATION RAIL)
                _buildSideNavigation(),

                // 3. CONTENU PRINCIPAL
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barre de recherche
                        _buildSearchBar(),
                        const SizedBox(height: 25),

                        // Rangée des indicateurs (KPI Cards)
                        _buildKpiRow(),
                        const SizedBox(height: 30),

                        // Section Tableau
                        _buildTableSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 4. FOOTER
          _buildFooter(),
        ],
      ),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  Widget _buildTopHeader() {
    return Container(
      height: 70,
      color: greenHeader,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Image.asset('assets/images/logo_ban.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.eco, color: Colors.white)),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("BAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Bourse Agricole Numérique", style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.notifications_active, color: Colors.white, size: 20),
          const SizedBox(width: 20),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Willy Kyabira", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text("Chargé de Ventes", style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 220,
      color: const Color(0xFF263238), // Fond sombre pour le menu
      child: Column(
        children: [
          const SizedBox(height: 10),
          _navMenuItem(Icons.dashboard, "Tableau de Bord", true),
          _navMenuItem(Icons.shopping_cart, "Ventes & Commandes", false),
          _navMenuItem(Icons.receipt_long, "Facturation", false, hasSub: true),
          _navMenuItem(Icons.bar_chart, "Rapports", false, hasSub: true),
        ],
      ),
    );
  }

  Widget _navMenuItem(IconData icon, String title, bool isSelected, {bool hasSub = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? greenAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 20),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 13)),
        trailing: hasSub ? Icon(Icons.arrow_drop_down, color: isSelected ? Colors.white : Colors.white60) : null,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: greenHeader,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.white70),
          hintText: "Rechercher une facture ou un client...",
          hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        _kpiCard("VENTES DU MOIS", "18 Ventes", Icons.shopping_cart_outlined, Colors.green),
        _kpiCard("CHIFFRE D'AFFAIRES", "6.2 Tonnes / 8,500 \$", Icons.payments_outlined, Colors.blue),
        _kpiCard("FACTURES IMPAYÉES", "3 Commandes", Icons.warning_amber_rounded, Colors.orange),
        _kpiCard("STOCK CRITIQUE (KG)", "500 Kg", Icons.warehouse_outlined, Colors.brown),
        _kpiCard("ACHETEURS ACTIFS", "14 Clients", Icons.group_outlined, Colors.purple),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                Icon(icon, size: 18, color: color.withOpacity(0.7)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text("NOUVELLE VENTE / FACTURE"),
              style: ElevatedButton.styleFrom(backgroundColor: greenAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
            ),
            const SizedBox(width: 20),
            const Text("SUIVI DES VENTES ET FACTURATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: surfaceWhite, borderRadius: BorderRadius.circular(12)),
          child: DataTable(
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            columns: const [
              DataColumn(label: Text("N°")),
              DataColumn(label: Text("CLIENT")),
              DataColumn(label: Text("PRODUIT")),
              DataColumn(label: Text("QUANTITÉ")),
              DataColumn(label: Text("PRIX TOTAL")),
              DataColumn(label: Text("STATUT")),
              DataColumn(label: Text("ACTIONS")),
            ],
            rows: [
              _buildDataRow("1", "Grossiste Bunia", "Manioc", "2.5 T", "3,125 \$", "Payé", Colors.green),
              _buildDataRow("2", "Coopérative Ituri", "Maïs", "1.0 T", "1,200 \$", "En attente", Colors.orange),
              _buildDataRow("3", "Alimentation Nord", "Manioc", "500 Kg", "625 \$", "Livré", Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(String id, String client, String prod, String qte, String total, String statut, Color color) {
    return DataRow(cells: [
      DataCell(Text(id)),
      DataCell(Text(client)),
      DataCell(Text(prod)),
      DataCell(Text(qte)),
      DataCell(Text(total)),
      DataCell(Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 5),
          Text(statut, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      )),
      DataCell(Row(
        children: [
          _actionIcon(Icons.picture_as_pdf, "Reçu"),
          _actionIcon(Icons.download, "Facture"),
          _actionIcon(Icons.settings, "Valider"),
        ],
      )),
    ]);
  }

  Widget _actionIcon(IconData icon, String tooltip) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Tooltip(message: tooltip, child: Icon(icon, size: 18, color: Colors.black54)),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 40,
      color: const Color(0xFF121212),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        children: [
          Text("© 2026 BAN PORTAL", style: TextStyle(color: Colors.white54, fontSize: 10)),
          SizedBox(width: 20),
          Text("Support", style: TextStyle(color: Colors.white54, fontSize: 10)),
          SizedBox(width: 20),
          Text("Documentation", style: TextStyle(color: Colors.white54, fontSize: 10)),
          Spacer(),
          Icon(Icons.verified_user, color: Colors.green, size: 12),
          SizedBox(width: 5),
          Text("SESSION SÉCURISÉE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
          SizedBox(width: 20),
          Text("v1.0.2", style: TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}