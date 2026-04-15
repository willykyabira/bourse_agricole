import 'package:flutter/material.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/models/product_model.dart';

class AddProductPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un produit (Manioc...)")),
      body: Center(
        child: Container(
          width: 500, // Format Web
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom")),
              TextField(controller: _qtyController, decoration: const InputDecoration(labelText: "Quantité")),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Prix Unitaire")),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Logique ProductRepository().addProduct(...)
                },
                child: const Text("Enregistrer dans le stock"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
