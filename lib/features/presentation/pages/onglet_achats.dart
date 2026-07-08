import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'formulaire_commande.dart';
import 'historique_commandes.dart';

/// Premier onglet du flux d'achat : Affiche le catalogue des offres en temps réel
/// et prépare la transition vers le formulaire de commande sécurisé.
class OngletAchats extends StatefulWidget {
  const OngletAchats({super.key});

  @override
  State<OngletAchats> createState() => _OngletAchatsState();
}

class _OngletAchatsState extends State<OngletAchats> {
  // Couleur identitaire de la plateforme BAN
  final Color banGreen = const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Nos offres",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: banGreen,
        elevation: 0.5,
        actions: [
          // Bouton d'accès direct à l'historique et aux factures de l'utilisateur
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoriquePage(),
                ),
              );
            },
            icon: Icon(
              Icons.receipt_long_rounded,
              color: banGreen,
              size: 20,
            ),
            label: Text(
              "Mes factures",
              style: GoogleFonts.poppins(
                color: banGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SECTION NOTE D'INFORMATION (Exigence 1 : Transparence sur l'identité)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  "Sélectionnez un produit pour lancer votre commande. Votre identité et votre contact seront récupérés automatiquement depuis votre profil sécurisé.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // BANDEAU DES PARTENAIRES DE PAIEMENT (Exigence 2 : Réalisme Passerelle)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "Paiement Mobile Sécurisé : ",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Sunbox • PowerPay",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // LISTE DES PRODUITS VIA STREAM DYNAMIQUE
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('produits').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: banGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erreur de synchronisation des offres",
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  );
                }

                final produits = snapshot.data ?? [];

                if (produits.isEmpty) {
                  return Center(
                    child: Text(
                      "Aucune offre disponible pour le moment.",
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: produits.length,
                  itemBuilder: (context, index) {
                    final produit = produits[index];

                    // Extraction et typage sécurisé des attributs de la table
                    final String nom = (produit['nom_produit'] ?? 'Produit').toString().toUpperCase();
                    final double quantite = double.tryParse(produit['quantite'].toString()) ?? 0.0;
                    final double prix = double.tryParse(produit['prix_unitaire'].toString()) ?? 0.0;
                    final String entrepot = produit['nom_entrepot'] ?? produit['emplacement'] ?? 'Entrepôt central';
                    final String unite = produit['unite_mesure'] ?? 'Kg';

                    // Détermination de l'état du stock (Exigence 4)
                    final bool estDisponible = quantite > 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: estDisponible
                            ? () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Récupération de votre profil sécurisé..."),
                                    duration: Duration(milliseconds: 800),
                                  ),
                                );

                                Map<String, dynamic> profilCharge = {};
                                
                                try {
                                  final user = supabase.auth.currentUser;
                                  if (user != null) {
                                    final data = await supabase
                                        .from('profiles') 
                                        .select()
                                        .eq('id', user.id)
                                        .single();
                                    profilCharge = data;
                                  }
                                } catch (e) {
                                  // Repli sécurisé (Fallback metadata)
                                  profilCharge = {
                                    'nom_complet': supabase.auth.currentUser?.userMetadata?['full_name'] ?? 'Utilisateur BAN',
                                    'telephone': supabase.auth.currentUser?.userMetadata?['phone'] ?? 'Non renseigné',
                                    'nom_entrepot': entrepot,
                                  };
                                }

                                if (!context.mounted) return;

                                // Redirection claire et synchronisée
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormulaireCommandePage(
                                      produit: produit,
                                      paiementsDisponibles: const ["Sunbox", "PowerPay"],
                                      profilClient: profilCharge,
                                    ),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Ce produit est temporairement en rupture de stock."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              },
                        child: _buildProductCard(
                          nom,
                          quantite,
                          prix,
                          unite,
                          entrepot,
                          Icons.eco_rounded,
                          banGreen,
                          estDisponible,
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

  /// Widget Composant : Carte descriptive du produit agricole mis en marché
  Widget _buildProductCard(
    String title,
    double quantite,
    double prixUnitaire,
    String unite,
    String entrepot,
    IconData icon,
    Color color,
    bool estDisponible,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: estDisponible ? Colors.grey[200]! : Colors.red.shade100,
          width: estDisponible ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: estDisponible ? color.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: estDisponible ? color : Colors.grey,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: estDisponible ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 3),

                Row(
                  children: [
                    Icon(
                      Icons.store_mall_directory_outlined,
                      size: 13,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entrepot,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: estDisponible ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estDisponible ? "🟢 Disponible (Stock: ${quantite.toStringAsFixed(0)} $unite)" : "🔴 Rupture de stock",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: estDisponible ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${prixUnitaire.toStringAsFixed(2)}\$",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  color: estDisponible ? color : Colors.grey,
                  fontSize: 15,
                ),
              ),
              Text(
                "/ $unite",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.credit_card_rounded, size: 10, color: Colors.blueGrey),
                  const SizedBox(width: 2),
                  Text(
                    "Sunbox/PowerPay",
                    style: GoogleFonts.inter(fontSize: 9, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}