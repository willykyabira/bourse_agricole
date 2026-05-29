import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FactureProforma extends StatefulWidget {
  final Map<String, dynamic> infoClient;
  final Map<String, dynamic> produit;
  final int quantite;
  final Map<String, dynamic> infoPaiement;

  const FactureProforma({
    super.key,
    required this.infoClient,
    required this.produit,
    required this.quantite,
    required this.infoPaiement,
  });

  @override
  State<FactureProforma> createState() => _FactureProformaState();
}

class _FactureProformaState extends State<FactureProforma> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isProcessing = false;

  Future<void> _validerCommande() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);

    try {
      final total = (widget.produit['prix'] as num).toDouble() * widget.quantite;

      // Insertion avec le user_id corrigé
      await _supabase.from('commandes').insert({
        'user_id': user.id,
        'nom_client': widget.infoClient['nom'],
        'tel': widget.infoClient['telephone'],
        'nom_produit': widget.produit['nom_produit'],
        'quantite': widget.quantite,
        'prix_total': total,
        'mode_paiement': widget.infoPaiement['mode'],
        'statut': 'paye',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Commande validée avec succès !"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Récapitulatif")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Détails de la commande", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(title: Text(widget.produit['nom_produit']), subtitle: const Text("Produit")),
                    ListTile(title: Text("${widget.quantite}"), subtitle: const Text("Quantité")),
                    const Divider(),
                    ListTile(
  title: Text("${(widget.produit['prix'] as num) * widget.quantite} \$"), 
  subtitle: const Text("Total"),
),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isProcessing ? null : _validerCommande,
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CONFIRMER LE PAIEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}