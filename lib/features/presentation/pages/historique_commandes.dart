import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'facture_proforma.dart'; // Pour permettre la réimpression si besoin
import '../widgets/ban_layout_scaffold.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  Map<String, String> _entrepotsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerEntrepots();
  }

  Future<void> _chargerEntrepots() async {
    final supabase = Supabase.instance.client;
    final entrepotsData = await supabase.from('entrepots').select('id, nom_entrepot');
    if (!mounted) return;
    setState(() {
      _entrepotsMap = {
        for (var item in entrepotsData as List)
          item['id'].toString(): item['nom_entrepot'].toString()
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final Color banGreen = const Color(0xFF1B5E20);

    if (user == null) {
      return BanLayoutScaffold(
        bodyTitle: "Mes Factures & Achats",
        body: Center(
          child: Text("Veuillez vous connecter pour voir vos factures.", style: GoogleFonts.inter()),
        ),
      );
    }
    
    if (_isLoading) {
      return BanLayoutScaffold(
        bodyTitle: "Mes Factures & Achats",
        body: Center(child: CircularProgressIndicator(color: banGreen)),
      );
    }

    return BanLayoutScaffold(
      bodyTitle: "Mes Factures & Achats",
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('commandes')
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: banGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement de l'historique", style: GoogleFonts.inter(color: Colors.red)));
          }

          final commandes = snapshot.data ?? [];

          if (commandes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Aucune facture trouvée.", style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final cmd = commandes[index];
              
              final String? entrepotId = cmd['entrepot_id']?.toString();
              final String lieuLivraison = (entrepotId != null && _entrepotsMap.containsKey(entrepotId))
                  ? _entrepotsMap[entrepotId]!
                  : (cmd['lieu_livraison'] ?? 'NON SPECIFIÉ');
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cmd['reference_facture'] ?? 'Réf inconnue',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: banGreen),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cmd['statut'] ?? 'Validé',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        (cmd['nom_produit'] ?? 'Produit').toString().toUpperCase(),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Quantité : ${cmd['quantite']} | Via ${cmd['mode_paiement']}",
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          Text(
                            "${(((cmd['prix_total'] as num?)?.toDouble() ?? 0.0) * 1.2).toInt()} CDF",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: banGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FactureProforma(
                                  infoClient: {
                                    'nom_client': cmd['nom_client'],
                                    'telephone': cmd['telephone_client'],
                                  },
                                  produit: {
                                    'nom_produit': cmd['nom_produit'],
                                    'prix_unitaire': ((cmd['prix_total'] as num).toDouble() / (cmd['quantite'] as num).toDouble()), 
                                  },
                                  quantite: (cmd['quantite'] as num).toDouble(),
                                  infoPaiement: {
                                    'referenceFacture': cmd['reference_facture'],
                                    'modePaiement': cmd['mode_paiement'],
                                    'lieuLivraison': lieuLivraison,
                                    'statutFinancier': cmd['statut'],
                                    'prix_total': cmd['prix_total'],
                                  },
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.print_outlined, size: 16, color: banGreen),
                          label: Text("Afficher / Réimprimer", style: GoogleFonts.poppins(color: banGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      )
                    ],
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