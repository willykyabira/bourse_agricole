import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Historique des achats", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // On récupère les commandes de l'utilisateur connecté
        stream: _supabase
            .from('commandes')
            .stream(primaryKey: ['id'])
            .eq('user_id', _supabase.auth.currentUser!.id)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final commandes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              return _CommandeCard(item: commandes[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Aucun historique", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}

// Widget de la carte avec expansion pour les détails
class _CommandeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _CommandeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final prix = (item['prix_total'] as num?)?.toDouble() ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: const Icon(Icons.shopping_bag, color: Colors.blueAccent),
        ),
        title: Text(item['nom_produit'] ?? 'Produit inconnu', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${prix.toStringAsFixed(2)} \$ • ${item['statut'] ?? 'Payé'}"),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow("Client", item['nom_client'] ?? 'Non renseigné'),
                _buildDetailRow("Téléphone", item['tel'] ?? 'Non renseigné'),
                _buildDetailRow("Quantité", "${item['quantite'] ?? 0}"),
                _buildDetailRow("Mode de paiement", item['mode_paiement'] ?? 'N/A'),
                _buildDetailRow("Date", item['created_at'] != null 
                    ? item['created_at'].toString().substring(0, 10) 
                    : 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}