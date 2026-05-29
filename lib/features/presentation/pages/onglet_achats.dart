import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'formulaire_commande.dart';
import 'historique_commandes.dart';

class OngletAchats extends StatelessWidget {
  const OngletAchats({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    // Palette de couleurs Super Designer
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color backgroundSand = Color(0xFFF9F7F2);

    return Scaffold(
      backgroundColor: backgroundSand,
      appBar: AppBar(
        title: const Text("Bourse Agricole", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const HistoriquePage())
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('produits').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen));
          }
          final produits = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final p = produits[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FormulaireCommandePage(produit: p))),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.grass_rounded, color: primaryGreen),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['nom_produit'] ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Prix : ${p['prix_unitaire']} \$", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}