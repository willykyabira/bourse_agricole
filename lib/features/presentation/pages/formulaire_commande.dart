import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'paiement_pawapay.dart';

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
  final TextEditingController _quantiteController = TextEditingController(text: "5");

  double get prixUnitaire => (widget.produit["prix_unitaire"] as num?)?.toDouble() ?? 0.0;

  @override
  void dispose() {
    _quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double quantite = double.tryParse(_quantiteController.text) ?? 5.0;
    final double totalTtc = quantite * prixUnitaire * 1.276;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B5E34), Color(0xFF1E6AA8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.eco, color: Color(0xFF0B5E34), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "BAN ITURI",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Finaliser la Commande", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(widget.produit["nom"] ?? "", style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("Prix unitaire : ${prixUnitaire.toStringAsFixed(2)} \$", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text("Informations de livraison & Logistique", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 15),
                  
                  // Carte des infos (Nettoyée)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      // ignore: deprecated_member_use
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.person_outline, "Destinataire", widget.profilClient["nom_complet"] ?? ""),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.phone_outlined, "Numéro de contact", widget.profilClient["telephone"] ?? ""),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.store_outlined, "Point de retrait", widget.profilClient["nom_entrepot"] ?? ""),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text("Quantité souhaitée (Kg)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _quantiteController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0B5E34)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Expanded(child: Text("Total net à payer TTC", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                        Text("${totalTtc.toStringAsFixed(2)} \$", style: GoogleFonts.poppins(color: const Color(0xFF0B5E34), fontWeight: FontWeight.bold, fontSize: 24)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Bouton Paiement
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B5E34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaiementPage(
                                infoClient: {
                                  "nom_client": widget.profilClient["nom_complet"],
                                  "telephone": widget.profilClient["telephone"],
                                  "lieu_livraison": widget.profilClient["nom_entrepot"],
                                },
                                produit: widget.produit,
                                quantite: quantite,
                                montantTotalTtc: totalTtc,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text("ALLER AU PAIEMENT SÉCURISÉ", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // Bouton Retour
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0B5E34), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("RETOUR", style: GoogleFonts.poppins(color: const Color(0xFF0B5E34), fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
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
          decoration: BoxDecoration(color: const Color(0xFF0B5E34).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF0B5E34), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(valeur, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}