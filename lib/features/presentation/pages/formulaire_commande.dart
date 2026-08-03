import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'paiement_pawapay.dart';
import '../widgets/ban_layout_scaffold.dart';

class FormulaireCommandePage extends StatefulWidget {
  final Map<String, dynamic> produit;
  final List<String> paiementsDisponibles;
  final Map<String, dynamic> profilClient;

  // ignore: use_super_parameters
  const FormulaireCommandePage({
    Key? key,
    required this.produit,
    required this.paiementsDisponibles,
    required this.profilClient,
  }) : super(key: key);

  @override
  State<FormulaireCommandePage> createState() => _FormulaireCommandePageState();
}

class _FormulaireCommandePageState extends State<FormulaireCommandePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantiteController = TextEditingController(
    text: "5",
  );

  double get prixUnitaire =>
      (widget.produit["prix_unitaire"] as num?)?.toDouble() ?? 0.0;

  @override
  void dispose() {
    _quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double quantite = double.tryParse(_quantiteController.text) ?? 5.0;
    final double totalTtc = quantite * prixUnitaire * 1.276;

    return BanLayoutScaffold(
      bodyTitle: "Finaliser la Commande",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (widget.produit["nom_produit"] ?? widget.produit["nom"] ?? "").toString().toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Prix unitaire : ${(prixUnitaire * 1.2).toInt()} CDF",
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 20),
                Text(
                  "Informations de livraison & Logistique",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Section des infos supprimée pour simplifier le flux de commande.
                  const SizedBox(height: 25),
                  Text(
                    "Quantité souhaitée (Kg)",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _quantiteController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF0B5E34),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Total net à payer TTC",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          "${(totalTtc * 1.2).toInt()} CDF",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0B5E34),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bouton Paiement
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B5E34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaiementPage(
                                infoClient: {
                                  "nom_client":
                                      widget.profilClient["nom_complet"],
                                  "telephone": widget.profilClient["telephone"],
                                  "lieu_livraison":
                                      widget.profilClient["nom_entrepot"],
                                },
                                produit: widget.produit,
                                quantite: quantite,
                                montantTotalTtc: totalTtc,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "ALLER AU PAIEMENT SÉCURISÉ",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Bouton Retour
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF0B5E34),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "RETOUR",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0B5E34),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildInfoRow(IconData icon, String titre, String valeur) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          // ignore: deprecated_member_use
          decoration: BoxDecoration(
            color: const Color(0xFF0B5E34).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0B5E34), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valeur,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
