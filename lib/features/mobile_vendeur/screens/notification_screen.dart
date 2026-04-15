import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationVendeurScreen extends StatelessWidget {
  const NotificationVendeurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Produits (Vendeur)")),
      body: StreamBuilder(
        stream: Supabase.instance.client
            .from('products')
            .stream(primaryKey: ['id'])
            .eq('vendeur_id', userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return ListTile(
                leading: const Icon(Icons.inventory, color: Colors.green),
                title: Text("${item['nom']} enregistré"),
                subtitle: Text("Quantité: ${item['quantite']} ${item['unite']}"),
                trailing: Text(item['statut_publication'] ? "Publié" : "En attente"),
              );
            },
          );
        },
      ),
    );
  }
}
