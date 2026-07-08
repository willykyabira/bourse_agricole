import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'facture_proforma.dart';

class PaiementPage extends StatefulWidget {
  final Map<String, dynamic> infoClient;
  final Map<String, dynamic> produit;
  final double quantite;
  final double montantTotalTtc;

  const PaiementPage({
    super.key,
    required this.infoClient,
    required this.produit,
    required this.quantite,
    required this.montantTotalTtc,
  });

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String _operateur = "ORANGE";
  bool _isLoading = false;

  // Couleurs officielles BAN
  final Color banPrimary = const Color(0xFF0B5E34); 

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.infoClient["telephone"] ?? "";
  }

  void _payer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FactureProforma(
            infoClient: widget.infoClient,
            produit: widget.produit,
            quantite: widget.quantite,
            infoPaiement: {
              "operateur": _operateur,
              "montant": widget.montantTotalTtc,
              "devise": "USD"
            },
          ),
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond propre
      appBar: AppBar(
        title: Text("Paiement BAN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: banPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Montant en évidence
                Center(
                  child: Column(
                    children: [
                      Text("Montant à payer", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                      Text("${widget.montantTotalTtc.toStringAsFixed(2)} USD", style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: banPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Téléphone
                Text("Numéro de téléphone", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF0B5E34)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: banPrimary, width: 2), borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 25),

                // Opérateurs
                Text("Sélectionnez l'opérateur", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildOperatorCard("Orange", "ORANGE"),
                    const SizedBox(width: 10),
                    _buildOperatorCard("Vodacom", "VODACOM"),
                    const SizedBox(width: 10),
                    _buildOperatorCard("Airtel", "AIRTEL"),
                  ],
                ),
                const SizedBox(height: 50),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: banPrimary), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text("Annuler", style: TextStyle(color: banPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _payer,
                        style: ElevatedButton.styleFrom(backgroundColor: banPrimary, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Payer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorCard(String label, String value) {
    final bool isSelected = _operateur == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _operateur = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: isSelected ? banPrimary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? banPrimary : Colors.grey.shade300, width: isSelected ? 2 : 1),
          ),
          child: Center(child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isSelected ? banPrimary : Colors.black))),
        ),
      ),
    );
  }
}