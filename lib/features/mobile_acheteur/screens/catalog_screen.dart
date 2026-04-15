import 'package:flutter/material.dart';

class CatalogAcheteurScreen extends StatelessWidget {
  const CatalogAcheteurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepo = ProductRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Marché Agricole"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: productRepo.getAvailableProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            itemBuilder: (context, index) => ProductItemCard(
              productData: products[index],
              onTap: () {
                // Naviguer vers le détail pour commander
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        onPressed: () => Navigator.pushNamed(context, '/request-product'),
        label: const Text("Produit absent ?"),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
