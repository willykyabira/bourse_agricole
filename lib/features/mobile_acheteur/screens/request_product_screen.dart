import 'package:flutter/material.dart';

class RequestProductScreen extends StatefulWidget {
  const RequestProductScreen({super.key});

  @override
  State<RequestProductScreen> createState() => _RequestProductScreenState();
}

class _RequestProductScreenState extends State<RequestProductScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Demande Spéciale")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Quel produit recherchez-vous ?"),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom du produit")),
            TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: "Précisions (quantité, variété)")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logique pour insérer dans la table special_requests
                Navigator.pop(context);
              },
              child: const Text("Envoyer la demande"),
            )
          ],
        ),
      ),
    );
  }
}
