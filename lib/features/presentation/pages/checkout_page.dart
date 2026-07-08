import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final double montant;
  final String commandeId;

  const CheckoutPage({super.key, required this.montant, required this.commandeId});

  @override
  // ignore: library_private_types_in_public_api
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _phoneController = TextEditingController();
  String _selectedOperator = 'AIRTEL_DRC'; // Valeur par défaut
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'initier-paiement',
        body: {
          'montant': widget.montant,
          'telephone': _phoneController.text,
          'reseau': _selectedOperator,
          'commandeId': widget.commandeId,
        },
      );

      if (response.status == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paiement initié avec succès !")),
        );
        // Ici, vous pouvez rediriger l'utilisateur vers une page de confirmation
      } else {
        throw Exception("Erreur PawaPay: ${response.data}");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Montant à payer : ${widget.montant} CDF"),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Numéro de téléphone"),
              keyboardType: TextInputType.phone,
            ),
            DropdownButton<String>(
              value: _selectedOperator,
              items: const [
                DropdownMenuItem(value: 'AIRTEL_DRC', child: Text('Airtel')),
                DropdownMenuItem(value: 'VODACOM_DRC', child: Text('Vodacom')),
                DropdownMenuItem(value: 'ORANGE_DRC', child: Text('Orange')),
              ],
              onChanged: (val) => setState(() => _selectedOperator = val!),
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _processPayment,
                  child: const Text("Valider le paiement"),
                ),
          ],
        ),
      ),
    );
  }
}