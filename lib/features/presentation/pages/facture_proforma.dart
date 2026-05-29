import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FactureProformaView extends StatefulWidget {
  final Map<String, dynamic> produit;
  final double quantiteCommandee;

  const FactureProformaView({
    super.key,
    required this.produit,
    required this.quantiteCommandee,
  });

  @override
  State<FactureProformaView> createState() => _FactureProformaViewState();
}

class _FactureProformaViewState extends State<FactureProformaView> {
  bool _estEnTrainDePayer = false;
  bool _estPaye = false;
  String _codeRetrait = "";

  final Color banGreen = const Color(0xFF1B5E20);
  final Color banGold = const Color(0xFFFBC02D);

  @override
  Widget build(BuildContext context) {
    final double prixUnitaire = double.tryParse(widget.produit['prix_unitaire'].toString()) ?? 0.0;
    final double montantTotal = prixUnitaire * widget.quantiteCommandee;
    final String nomProduit = (widget.produit['nom_produit'] ?? 'Produit').toString().toUpperCase();
    final String unite = widget.produit['unite_mesure'] ?? 'Kg';
    final String entrepot = widget.produit['nom_entrepot'] ?? widget.produit['emplacement'] ?? 'Entrepôt Central';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _estPaye ? "Votre Commande" : "Facture Proforma",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur d'étape visuel
            _buildStepProgress(),
            const SizedBox(height: 25),

            // --- CORPS DE LA FACTURE ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  // En-tête Facture
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _estPaye ? banGreen : banGreen.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _estPaye ? "FACTURE DÉFINITIVE" : "FACTURE PROFORMA",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: _estPaye ? Colors.white : banGreen,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _estPaye ? "PAYÉE" : "EN ATTENTE",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            color: _estPaye ? banGold : Colors.orange.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Détails des articles
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFactureRow("Produit", nomProduit, estGras: true),
                        _buildFactureRow("Lieu de retrait", entrepot),
                        _buildFactureRow("Quantité", "${widget.quantiteCommandee} $unite"),
                        _buildFactureRow("Prix Unitaire", "${prixUnitaire.toStringAsFixed(2)} \$ / $unite"),
                        const Divider(height: 30),
                        _buildFactureRow(
                          "Montant Total", 
                          "${montantTotal.toStringAsFixed(2)} \$", 
                          estGras: true, 
                          taille: 18, 
                          couleurTexte: banGreen
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- ZONE DYNAMIQUE : CODE QR OU BOUTON PAIEMENT ---
            if (_estPaye) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      "Présentez ce code à l'entrepôt pour le retrait :",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 15),
                    // Simulation du Code QR de validation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: banGreen, width: 2),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_2, size: 180, color: banGreen),
                          const SizedBox(height: 8),
                          Text(
                            "RÉSERVATION : $_codeRetrait",
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Le stock a été bloqué avec succès à l'entrepôt.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Instructions de paiement mobile / banque
              Text(
                "Sélectionnez un mode de règlement ou validez pour simuler le dépôt sur le compte séquestre BAN.",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: banGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _estEnTrainDePayer ? null : _traiterPaiementEtReservation,
                  child: _estEnTrainDePayer
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Confirmer et Payer \$${montantTotal.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFactureRow(String label, String valeur, {bool estGras = false, double taille = 14, Color? couleurTexte}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              valeur,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: taille,
                fontWeight: estGras ? FontWeight.bold : FontWeight.w500,
                color: couleurTexte ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle("1", "Proforma", active: true, complete: _estPaye),
        _buildLine(complete: _estPaye),
        _buildStepCircle("2", "Paiement / QR", active: _estPaye, complete: _estPaye),
        _buildLine(complete: false),
        _buildStepCircle("3", "Livraison", active: false, complete: false),
      ],
    );
  }

  Widget _buildStepCircle(String step, String label, {required bool active, required bool complete}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: complete ? banGreen : (active ? banGold : Colors.grey.shade300),
          child: complete 
              ? const Icon(Icons.check, size: 16, color: Colors.white) 
              : Text(step, style: TextStyle(color: active ? Colors.black87 : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: active || complete ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildLine({required bool complete}) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
      color: complete ? banGreen : Colors.grey.shade300,
    );
  }

  // Action de simulation du passage Proforma ➔ Paiement ➔ Réservation Stock
  void _traiterPaiementEtReservation() async {
    setState(() => _estEnTrainDePayer = true);

    // Simulation d'une latence réseau de 2 secondes
    await Future.delayed(const Duration(seconds: 2));

    // Génération d'un code de retrait fictif basé sur le timestamp
    final String tokenRetrait = "BAN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      // Insertion de la transaction finalisée dans Supabase
      await supabase.from('commandes').insert({
        'acheteur_id': user?.id,
        'produit_id': widget.produit['id'],
        'quantite': widget.quantiteCommandee,
        'prix_total': (double.parse(widget.produit['prix_unitaire'].toString()) * widget.quantiteCommandee),
        'code_qr_validation': tokenRetrait,
        'statut': 'paye', // Statut passé à PAYÉ
      });

      setState(() {
        _estEnTrainDePayer = false;
        _estPaye = true;
        _codeRetrait = tokenRetrait;
      });
    } catch (e) {
      setState(() => _estEnTrainDePayer = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la validation : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}