import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'formulaire_commande.dart';
import 'historique_commandes.dart';

class OngletAchats extends StatefulWidget {
  const OngletAchats({super.key});

  @override
  State<OngletAchats> createState() => _OngletAchatsState();
}

class _OngletAchatsState extends State<OngletAchats> {
  final Color banGreen = const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Nos offres", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: banGreen,
        elevation: 0.5,
        actions: [
          // L'historique reste ici, c'est l'endroit le plus intuitif
          TextButton.icon(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HistoriquePage())),
            icon: Icon(Icons.receipt_long_rounded, color: banGreen, size: 20),
            label: Text("Mes factures", style: GoogleFonts.poppins(color: banGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instruction pour l'utilisateur
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Text(
              "Cliquer sur un produit pour passer votre commander et payer en toute sécurité",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13, 
                color: Colors.grey.shade600, 
                fontStyle: FontStyle.italic
              ),
            ),
          ),
          
          // Liste des produits
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('produits').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: banGreen));
                }
                final produits = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: produits.length,
                  itemBuilder: (context, index) {
                    final p = produits[index];
                    final String nom = (p['nom_produit'] ?? 'Produit').toString().toUpperCase();
                    final double qte = double.tryParse(p['quantite'].toString()) ?? 0.0;
                    final double pu = double.tryParse(p['prix_unitaire'].toString()) ?? 0.0;
                    final String entrepot = p['nom_entrepot'] ?? p['emplacement'] ?? 'Entrepôt central';
                    final String unite = p['unite_mesure'] ?? 'Kg';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FormulaireCommandePage(produit: p))),
                        child: _buildProductCard(
                          nom, qte, pu, unite, entrepot, Icons.eco, banGreen
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, double quantite, double prixUnitaire, String unite, String entrepot, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            // ignore: deprecated_member_use
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.store_mall_directory_outlined, size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entrepot,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Stock dispo : $quantite $unite",
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${prixUnitaire.toStringAsFixed(2)}\$",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: color, fontSize: 15),
              ),
              Text(
                "/ $unite",
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}