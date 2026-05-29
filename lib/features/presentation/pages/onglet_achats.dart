import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'paiement_mobile.dart'; // Assure-toi que le chemin d'import vers ton fichier est correct

class OngletAchats extends StatefulWidget {
  const OngletAchats({super.key});

  @override
  State<OngletAchats> createState() => _OngletAchatsState();
}

class _OngletAchatsState extends State<OngletAchats> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  final Color banGreen = const Color(0xFF1B5E20);
  final Color banEarth = const Color(0xFF795548);
  final Color banBorder = const Color(0xFFD1D9D1);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- BARRE DE RECHERCHE ---
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Rechercher un produit ou une référence...",
                prefixIcon: Icon(Icons.search, color: banGreen),
                suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildAgriBlock([
                _buildAgriRow(
                  Icons.shopping_basket_outlined, 
                  "Acheter", 
                  "Articles disponibles",
                  () => _ouvrirCatalogueDisponibles(context),
                ),
                const Divider(height: 1, indent: 55),
                _buildAgriRow(
                  Icons.receipt_long_outlined, 
                  "Historique d'achats", 
                  "Suivre mes commandes Mobile Money",
                  () => _ouvrirHistoriqueAchats(context),
                ),
              ], banBorder, banEarth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgriBlock(List<Widget> children, Color border, Color earth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border.all(color: border), 
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAgriRow(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: banEarth),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: sub.isNotEmpty ? Text(sub, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)) : null,
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // --- CATALOGUE DES PRODUITS DISPONIBLES ---
  void _ouvrirCatalogueDisponibles(BuildContext context) {
    final supabase = Supabase.instance.client;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text("Bourse Agricole : Articles en vente", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('produits').stream(primaryKey: ['id']).order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: banGreen));
              }
              final items = snapshot.data ?? [];
              
              // Filtrer si une recherche est active
              final filteredItems = items.where((item) {
                final nom = (item['nom_produit'] ?? '').toString().toLowerCase();
                return nom.contains(_searchQuery);
              }).toList();

              if (filteredItems.isEmpty) {
                return const Center(child: Text("Aucun article disponible pour le moment."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final p = filteredItems[index];
                  return Card(
                    // ✅ Correction syntaxe : EdgeInsets.only(bottom: 12)
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: banGreen.withOpacity(0.1),
                        child: Icon(Icons.compost_rounded, color: banGreen),
                      ),
                      title: Text(
                        (p['nom_produit'] ?? 'Produit').toString().toUpperCase(),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Padding(
                        // ✅ Correction syntaxe : EdgeInsets.only(top: 6)
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "Dépôt : ${p['entrepot'] ?? p['provenance'] ?? 'Général'}\nQuantité dispo : ${p['quantite']} ${p['unite_mesure'] ?? 'Kg'}",
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${p['prix_total'] ?? 0} \$",
                            style: GoogleFonts.poppins(color: banGreen, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Icon(Icons.shopping_cart_checkout_rounded, color: banEarth, size: 20),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaiementMobileScreen(produitAchete: p),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // --- HISTORIQUE PERSONNEL DES PAIEMENTS MOBILE MONEY ---
  void _ouvrirHistoriqueAchats(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text("Suivi de mes commandes", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('paiements')
                .stream(primaryKey: ['id'])
                .eq('client_id', user?.id ?? '')
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: banGreen));
              }
              final transactions = snapshot.data ?? [];

              // Filtrer l'historique par recherche
              final filteredTrans = transactions.where((t) {
                final prod = (t['nom_produit'] ?? '').toString().toLowerCase();
                final ref = (t['reference_transaction'] ?? '').toString().toLowerCase();
                return prod.contains(_searchQuery) || ref.contains(_searchQuery);
              }).toList();

              if (filteredTrans.isEmpty) {
                return const Center(child: Text("Vous n'avez pas encore effectué d'achats."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTrans.length,
                itemBuilder: (context, index) {
                  final t = filteredTrans[index];
                  final String statut = t['statut'] ?? 'En attente';
                  
                  Color statusColor = Colors.orange;
                  IconData statusIcon = Icons.hourglass_empty_rounded;
                  if (statut == 'Succès') {
                    statusColor = banGreen;
                    statusIcon = Icons.check_circle_rounded;
                  } else if (statut == 'Échoué') {
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel_rounded;
                  }

                  return Card(
                    // ✅ Correction syntaxe : EdgeInsets.only(bottom: 12)
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t['reference_transaction'] ?? 'Réf inconnue',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(statusIcon, color: statusColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      statut,
                                      style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              (t['nom_produit'] ?? 'Produit').toString().toUpperCase(),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              "Via ${t['operateur']} (${t['numero_telephone']})\nDate : ${t['created_at'].toString().substring(0, 10)}",
                              style: GoogleFonts.inter(fontSize: 12, height: 1.4),
                            ),
                            trailing: Text(
                              "${t['montant']} \$",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF2C3E50)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}