import 'package:flutter/material.dart';
import 'facture_proforma.dart';

class PaiementMobileScreen extends StatefulWidget {
  final Map<String, dynamic> produit;
  final int quantite; // Correction : Type int
  final Map<String, String> infoClient;

  const PaiementMobileScreen({
    super.key, 
    required this.produit, 
    required this.quantite, 
    required this.infoClient
  });

  @override
  State<PaiementMobileScreen> createState() => _PaiementMobileScreenState();
}

class _PaiementMobileScreenState extends State<PaiementMobileScreen> {
  String _selectedOperator = 'M-Pesa';
  final _phoneCtrl = TextEditingController();

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color backgroundSand = Color(0xFFF9F7F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSand,
      appBar: AppBar(
        title: const Text("Paiement Mobile"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choisissez votre opérateur", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedOperator,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none, 
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: primaryGreen)
                  ),
                  items: ['M-Pesa', 'Airtel Money', 'Orange Money'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _selectedOperator = v!),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Numéro de paiement",
                prefixIcon: const Icon(Icons.phone_android, color: primaryGreen),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FactureProforma(
                    produit: widget.produit,
                    quantite: widget.quantite,
                    infoClient: widget.infoClient,
                    infoPaiement: {"mode": _selectedOperator, "numero": _phoneCtrl.text},
                  )));
                },
                child: const Text("GÉNÉRER LA FACTURE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}