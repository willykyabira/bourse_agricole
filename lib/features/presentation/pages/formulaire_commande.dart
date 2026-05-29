import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormulaireCommandeWidget extends StatefulWidget {
  final Map<String, dynamic> produitAchete;
  final VoidCallback onCancel;
  final Function(double quantite, String telephone, String operateur) onSuccess;

  const FormulaireCommandeWidget({
    super.key,
    required this.produitAchete,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<FormulaireCommandeWidget> createState() => _FormulaireCommandeWidgetState();
}

class _FormulaireCommandeWidgetState extends State<FormulaireCommandeWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _qteCtrl = TextEditingController();
  String _selectedOperator = 'M-Pesa';

  final Color banGreen = const Color(0xFF1B5E20);
  final Color banEarth = const Color(0xFF795548);

  final List<Map<String, dynamic>> _operators = [
    {'name': 'M-Pesa', 'color': Colors.red.shade700},
    {'name': 'Airtel Money', 'color': Colors.red.shade900},
    {'name': 'Orange Money', 'color': Colors.orange.shade800},
  ];

  @override
  void initState() {
    super.initState();
    _qteCtrl.text = "100";
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _qteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double prixUnitaire = double.tryParse(widget.produitAchete['prix_unitaire'].toString()) ?? 2.0;
    final String nomProduit = (widget.produitAchete['nom_produit'] ?? 'PRODUIT').toString().toUpperCase();
    final double stockDispo = double.tryParse(widget.produitAchete['quantite'].toString()) ?? 500.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: widget.onCancel,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 12, color: banGreen),
                    const SizedBox(width: 4),
                    Text(
                      "Retour aux articles",
                      style: GoogleFonts.inter(color: banGreen, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            Text(
              "FINALISATION DE COMMANDE",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(width: 35, height: 3, color: Colors.amber.shade700, margin: const EdgeInsets.only(bottom: 25)),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: banGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: banGreen.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: banGreen,
                    child: const Icon(Icons.eco_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nomProduit, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: banGreen)),
                        const SizedBox(height: 2),
                        Text("Prix unitaire : $prixUnitaire \$ / Kg", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text("Disponible : $stockDispo Kg", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildFieldLabel("QUANTITÉ À ACHETER (Kg)"),
            TextFormField(
              controller: _qteCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              decoration: _inputStyle(Icons.shopping_basket_outlined, "Ex: 100"),
              validator: (v) {
                if (v == null || v.isEmpty) return "Saisissez une quantité";
                final val = double.tryParse(v);
                if (val == null || val <= 0) return "Quantité invalide";
                if (val > stockDispo) return "Stock insuffisant";
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildFieldLabel("OPÉRATEUR DE PAIEMENT"),
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
                        color: isSelected ? op['color'].withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? op['color'] : Colors.grey.shade300, width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.phone_android_rounded, color: isSelected ? op['color'] : Colors.grey, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            op['name'],
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? op['color'] : Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            _buildFieldLabel("NUMÉRO DE COMPTE MOBILE MONEY (RDC)"),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(letterSpacing: 1.5, fontWeight: FontWeight.w600),
              decoration: _inputStyle(Icons.phone_in_talk_rounded, "Ex: 08XXXXXXXX"),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Numéro requis";
                if (!RegExp(r'^0[89][0-9]{8}$').hasMatch(v.trim())) return "Format RDC invalide (10 chiffres)";
                return null;
              },
            ),
            const SizedBox(height: 35),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: banGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 1,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final double qte = double.parse(_qteCtrl.text);
                  final String phone = _phoneCtrl.text.trim();
                  widget.onSuccess(qte, phone, _selectedOperator);
                }
              },
              child: Text("GÉNÉRER MA FACTURE PROFORMA", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
    );
  }

  InputDecoration _inputStyle(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: banEarth, size: 20),
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: banGreen, width: 1.5)),
    );
  }
}