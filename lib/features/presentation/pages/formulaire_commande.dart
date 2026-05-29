import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isLoading = true;

  // Palette de couleurs Super Designer
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color backgroundSand = Color(0xFFF9F7F2);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name, phone')
            .eq('id', user.id)
            .maybeSingle();
        
        if (data != null) {
          _nomCtrl.text = data['full_name'] ?? '';
          _telCtrl.text = data['phone'] ?? '';
        }
      } catch (e) {
        debugPrint("Erreur récupération profil: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSand,
      appBar: AppBar(
        title: const Text("Vos informations"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryGreen)) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CARTE RÉCAPITULATIVE (Design Premium) ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.shopping_bag_outlined, color: primaryGreen),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Produit", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          Text(widget.produit['nom_produit'] ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text("Informations de livraison", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 15),
                
                // --- FORMULAIRE MODERNISÉ ---
                _buildTextField(_nomCtrl, "Nom complet", Icons.person_outline),
                const SizedBox(height: 15),
                _buildTextField(_telCtrl, "Numéro de téléphone", Icons.phone_android, isPhone: true),
                const SizedBox(height: 15),
                _buildTextField(_qteCtrl, "Quantité souhaitée", Icons.add_circle_outline, isNumber: true),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaiementMobileScreen(
                      produit: widget.produit,
                      quantite: int.tryParse(_qteCtrl.text) ?? 1,
                      infoClient: {"nom": _nomCtrl.text, "telephone": _telCtrl.text},
                    ))),
                    child: const Text("CONTINUER VERS LE PAIEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
    );
  }

  // Widget personnalisé pour un design uniforme
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPhone = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : (isNumber ? TextInputType.number : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}