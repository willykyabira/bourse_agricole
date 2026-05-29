import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaiementMobileScreen extends StatefulWidget {
  final Map<String, dynamic> produitAchete; // Reçoit l'id, le nom, le prix_unitaire initial, la quantité

  const PaiementMobileScreen({super.key, required this.produitAchete});

  @override
  State<PaiementMobileScreen> createState() => _PaiementMobileScreenState();
}

class _PaiementMobileScreenState extends State<PaiementMobileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneCtrl = TextEditingController();
  
  String _selectedOperator = 'M-Pesa';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _operators = [
    {'name': 'M-Pesa', 'color': Colors.red.shade700},
    {'name': 'Airtel Money', 'color': Colors.red.shade900},
    {'name': 'Orange Money', 'color': Colors.orange.shade800},
  ];

  String _generateProformaRef() {
    final random = Random();
    return "PROF-${DateTime.now().year}-${10000 + random.nextInt(90000)}";
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- ALGORITHME DE CALCUL AUTOMATIQUE EXIGÉ ---
    final double prixBaseUnitaire = double.tryParse(widget.produitAchete['prix_unitaire'].toString()) ?? 0.0;
    final double quantite = double.tryParse(widget.produitAchete['quantite'].toString()) ?? 1.0;
    
    final double montantBaseTotal = prixBaseUnitaire * quantite;
    
    // Frais accessoires calculés sur le prix de base
    final double fraisTransport = montantBaseTotal * 0.03;
    final double fraisManutention = montantBaseTotal * 0.01;
    final double fraisStockage = montantBaseTotal * 0.01;
    final double commission = montantBaseTotal * 0.05;
    
    // Total Hors Taxes (Base Imposable)
    final double totalHT = montantBaseTotal + fraisTransport + fraisManutention + fraisStockage + commission;
    
    // Taxe sur la Valeur Ajoutée (16% en RDC)
    final double tva = totalHT * 0.16;
    
    // Prix final TTC à payer
    final double totalTTC = totalHT + tva;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Facturation Proforma RDC", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isProcessing 
          ? _buildProcessingView() 
          : _buildInvoiceFormView(montantBaseTotal, fraisTransport, fraisManutention, fraisStockage, commission, totalHT, tva, totalTTC, quantite),
    );
  }

  Widget _buildInvoiceFormView(double base, double trans, double manu, double stock, double comm, double ht, double tva, double ttc, double quantiteDouble) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- EN-TÊTE AUX NORMES COMMERCIALES RDC ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("BOURSE AGRICOLE NUMÉRIQUE", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1B5E20))),
                      Text("FACTURE PROFORMA", style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.blueGrey)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("Province Éducationnelle de l'Ituri 1, Bunia, RDC", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  Text("N° Impôt : A2601945M • ID. NAT : 01-83-N47201J • RCCM : CD/BIA/RCCM/26-B-048", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                  const Divider(height: 20, thickness: 1),
                  Text("Client : ${Supabase.instance.client.auth.currentUser?.userMetadata?['nom_complet'] ?? 'Acheteur BAN'}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("Article : ${widget.produitAchete['nom_produit'].toString().toUpperCase()} ($quantiteDouble ${widget.produitAchete['unite_mesure'] ?? 'Kg'})", style: GoogleFonts.inter(fontSize: 12)),
                ],
              ),
            ),

            // --- CORPS DE LA FACTURE (DÉTAIL DU CALCUL AUTOMATIQUE) ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    _buildInvoiceLine("Prix de base marchandise", "${base.toStringAsFixed(2)} \$"),
                    _buildInvoiceLine("Frais de transport (3%)", "+ ${trans.toStringAsFixed(2)} \$"),
                    _buildInvoiceLine("Manutention dépôt (1%)", "+ ${manu.toStringAsFixed(2)} \$"),
                    _buildInvoiceLine("Frais de stockage / dépôt (1%)", "+ ${stock.toStringAsFixed(2)} \$"),
                    _buildInvoiceLine("Commission plateforme (5%)", "+ ${comm.toStringAsFixed(2)} \$"),
                    const Divider(height: 15),
                    _buildInvoiceLine("BASE IMPOSABLE (TOTAL HT)", "${ht.toStringAsFixed(2)} \$", isBold: true),
                    _buildInvoiceLine("TVA Provinciale (16%)", "+ ${tva.toStringAsFixed(2)} \$", color: Colors.red.shade700),
                  ],
                ),
              ),
            ),

            // --- TOTAL NET À PAYER ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF795548), 
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("NET À PAYER (TTC) :", style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("${ttc.toStringAsFixed(2)} \$", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- TUNNEL DE PAIEMENT MOBILE MONEY ---
            Text("MODE DE RÈGLEMENT MOBILE MONEY", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
            const SizedBox(height: 10),
            Row(
              children: _operators.map((op) {
                bool isSelected = _selectedOperator == op['name'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedOperator = op['name']),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? op['color'].withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? op['color'] : Colors.grey.shade300, width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.phone_android_rounded, color: isSelected ? op['color'] : Colors.grey, size: 20),
                          const SizedBox(height: 4),
                          // ✅ Correction effectuée ici : '重新' supprimé définitivement
                          Text(
                            op['name'], 
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, 
                              fontSize: 11, 
                              color: isSelected ? op['color'] : Colors.black87
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(fontSize: 15, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: "Ex: 08XXXXXXXX",
                hintStyle: const TextStyle(letterSpacing: 1),
                prefixIcon: const Icon(Icons.phone, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Numéro requis";
                if (!RegExp(r'^0[89][0-9]{7}$').hasMatch(v.trim())) return "Format RDC non valide";
                return null;
              },
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () {
                // ✅ Correction effectuée ici : passation explicite de la quantité extraite localement
                _soumettreCommandeBeForward(ttc, quantiteDouble);
              },
              child: Text("ACCEPTER LA PROFORMA & PAYER", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceLine(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: isBold ? Colors.black : Colors.grey.shade700, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color ?? Colors.black)),
        ],
      ),
    );
  }

  Future<void> _soumettreCommandeBeForward(double totalTTC, double qte) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final String reference = _generateProformaRef();

    try {
      await supabase.from('commandes').insert({
        'reference_proforma': reference,
        'client_id': user?.id,
        'nom_client': user?.userMetadata?['nom_complet'] ?? 'Acheteur BAN',
        'produit_id': widget.produitAchete['id'].toString(),
        'nom_produit': widget.produitAchete['nom_produit'],
        'quantite_commandee': qte,
        'montant_total': totalTTC, 
        'entrepot_depart': widget.produitAchete['entrepot'] ?? widget.produitAchete['provenance'] ?? 'Dépôt Central',
        'statut': 'Paiement Envoyé', 
        'operateur_paiement': _selectedOperator,
        'telephone_paiement': _phoneCtrl.text.trim(),
      });

      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
            title: Text("Paiement Transmis", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Text(
              "La facture proforma $reference a été convertie en ordre d'achat.\n\nStatut : En attente de validation financière.\n\nL'équipe de la Direction des Finances va valider l'écriture pour émettre votre reçu officiel sous peu.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: const Text("Fermer"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur d'enregistrement : $e")));
    }
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF1B5E20)),
          const SizedBox(height: 20),
          Text("Génération de la pièce comptable civile...", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}