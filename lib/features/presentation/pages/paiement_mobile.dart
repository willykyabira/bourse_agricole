import 'package:flutter/material.dart';
import 'facture_proforma.dart';
import 'header_ban.dart';

class PaiementMobileScreen extends StatefulWidget {
  final Map<String, dynamic> produit;
  final int quantite;
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Column(
        children: [
          const HeaderBanIturi(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: Text("Paiement", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 30),
                    const Text("Choisissez votre opérateur", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 15),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _selectedOperator,
                          isExpanded: true,
                          decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF1B5E20))),
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
                        prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF1B5E20)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Bouton Valider
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (_phoneCtrl.text.isEmpty) {
                            _showError("Veuillez entrer le numéro de paiement.");
                            return;
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) => FactureProforma(
                            produit: widget.produit,
                            quantite: widget.quantite,
                            infoClient: widget.infoClient,
                            infoPaiement: {"mode": _selectedOperator, "numero": _phoneCtrl.text},
                          )));
                        },
                        child: const Text("GÉNÉRER LA FACTURE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Bouton Retour
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("RETOUR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}