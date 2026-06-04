import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'header_ban.dart';
import 'paiement_mobile.dart';

class FormulaireCommandePage extends StatefulWidget {
  final Map<String, dynamic> produit;
  const FormulaireCommandePage({super.key, required this.produit});

  @override
  State<FormulaireCommandePage> createState() => _FormulaireCommandePageState();
}

class _FormulaireCommandePageState extends State<FormulaireCommandePage> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _qteCtrl = TextEditingController();

  // Fonction pour afficher des messages d'erreur propres à l'utilisateur
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfileQuietly();
  }

  Future<void> _loadProfileQuietly() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name, phone')
            .eq('id', user.id)
            .maybeSingle();
        if (data != null && mounted) {
          setState(() {
            _nomCtrl.text = data['full_name']?.toString() ?? '';
            _telCtrl.text = data['phone']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur profil : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nom = widget.produit['nom_produit']?.toString() ?? "Non spécifié";
    final String prix = widget.produit['prix_unitaire']?.toString() ?? "0";
    final String stock = widget.produit['quantite']?.toString() ?? "0";

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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: Text("Commande", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          _buildInfoRow("Produit", nom),
                          const Divider(height: 15),
                          _buildInfoRow("Prix", "$prix \$"),
                          const Divider(height: 15),
                          _buildInfoRow("Stock", "$stock kg"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildTextField(_nomCtrl, "Nom complet", Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField(_telCtrl, "Téléphone", Icons.phone_android, isPhone: true),
                    const SizedBox(height: 15),
                    _buildTextField(_qteCtrl, "Quantité (kg)", Icons.add_circle_outline, isNumber: true),
                    const SizedBox(height: 30),
                    
                    // Bouton Payer
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          // Validation
                          if (_nomCtrl.text.isEmpty || _qteCtrl.text.isEmpty) {
                            _showError("Veuillez remplir tous les champs.");
                            return;
                          }
                          final qte = int.tryParse(_qteCtrl.text);
                          if (qte == null || qte <= 0) {
                            _showError("Veuillez entrer une quantité valide (chiffres seulement).");
                            return;
                          }

                          Navigator.push(context, MaterialPageRoute(builder: (_) => PaiementMobileScreen(
                            produit: widget.produit,
                            quantite: qte,
                            infoClient: {"nom": _nomCtrl.text, "telephone": _telCtrl.text},
                          )));
                        },
                        child: const Text("PAYER MAINTENANT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Bouton Retour
                    SizedBox(
                      width: double.infinity,
                      height: 50,
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

  // CES MÉTHODES DOIVENT ÊTRE DANS LA CLASSE
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPhone = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : (isNumber ? TextInputType.number : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}