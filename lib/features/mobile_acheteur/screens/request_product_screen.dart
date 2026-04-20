import 'package:flutter/material.dart';

class RequestProductScreen extends StatefulWidget {
  const RequestProductScreen({super.key});

  @override
  State<RequestProductScreen> createState() => _RequestProductScreenState();
}

class _RequestProductScreenState extends State<RequestProductScreen> {
  // Ajout des contrôleurs pour récupérer les données
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final Color primaryGreen = const Color(0xFF1B5E20);

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    // Logique d'envoi (Supabase ou Email) à ajouter ici
    if (_productNameController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande envoyée avec succès !")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Besoin d'un produit ?", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quel produit recherchez-vous ?", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            const Text(
              "Nous contacterons les producteurs pour vous satisfaire dans les plus brefs délais.", 
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 40),
            
            // Champ Nom du Produit
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: "Nom du produit",
                hintText: "Ex: Pommes de terre, Huile de palme...",
                prefixIcon: Icon(Icons.inventory_2_outlined, color: primaryGreen),
                filled: true,
                fillColor: const Color(0xFFF4F7F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Champ Quantité
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantité souhaitée",
                hintText: "Ex: 500 KG, 2 Tonnes...",
                prefixIcon: Icon(Icons.scale_outlined, color: primaryGreen),
                filled: true,
                fillColor: const Color(0xFFF4F7F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const Spacer(),
            
            // Bouton d'envoi stylisé
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text(
                  "ENVOYER LA DEMANDE", 
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}