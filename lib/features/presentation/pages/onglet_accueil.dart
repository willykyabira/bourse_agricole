import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OngletAccueil extends StatefulWidget {
  const OngletAccueil({super.key});

  @override
  State<OngletAccueil> createState() => _OngletAccueilState();
}

class _OngletAccueilState extends State<OngletAccueil> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Tous";

  final Color banGreen = const Color(0xFF1B5E20);
  final Color banGold = const Color(0xFFFBC02D);

  final List<Map<String, dynamic>> _categories = [
    {"name": "Tous", "icon": Icons.grid_view},
    {"name": "Tubercules", "icon": Icons.agriculture},
    {"name": "Céréales", "icon": Icons.bakery_dining},
    {"name": "Légumes", "icon": Icons.grass},
    {"name": "Fruits", "icon": Icons.apple},
    {"name": "Élevage", "icon": Icons.pets},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Column(
      children: [
        // 1. BARRE DE RECHERCHE DYNAMIQUE (Globale)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: "Rechercher un produit (Manioc, Maïs...)",
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: banGreen),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),

        // Corps de la page défilant
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 15),

              // 2. SECTION CATÉGORIES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Catégories",
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  if (_selectedCategory != "Tous" || _searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {
                          _selectedCategory = "Tous";
                          _searchQuery = "";
                        });
                      },
                      child: Text("Réinitialiser", style: TextStyle(color: banGold, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              
              SizedBox(
                height: 95,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final bool isSelected = _searchQuery.isEmpty && (_selectedCategory == cat['name']);
                    return _buildCategoryCircle(
                      cat['name'],
                      cat['icon'],
                      isSelected ? banGold : banGreen,
                      isSelected,
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // 3. OFFRES DU MARCHÉ EN TEMPS RÉEL
              Text(
                _searchQuery.isNotEmpty 
                    ? "Résultats pour : '$_searchQuery'"
                    : (_selectedCategory == "Tous" ? "Offres du Marché" : "Offres : $_selectedCategory"),
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('produits').stream(primaryKey: ['id']).order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: banGreen));
                  }
                  
                  final allProducts = snapshot.data ?? [];

                  // Filtrage intelligent
                  final filteredProducts = allProducts.where((p) {
                    final String nomProduit = (p['nom_produit'] ?? '').toString().toLowerCase();
                    final String catProduit = (p['categorie'] ?? '').toString().toLowerCase();
                    
                    if (_searchQuery.isNotEmpty) {
                      return nomProduit.contains(_searchQuery);
                    } else {
                      return _selectedCategory == "Tous" || catProduit == _selectedCategory.toLowerCase();
                    }
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.layers_clear_outlined, color: Colors.grey, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              "Aucun produit disponible.",
                              style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final p = filteredProducts[index];
                      
                      final String nom = (p['nom_produit'] ?? 'Produit').toString().toUpperCase();
                      final double qte = double.tryParse(p['quantite'].toString()) ?? 0.0;
                      final double pu = double.tryParse(p['prix_unitaire'].toString()) ?? 0.0;
                      final String entrepot = p['nom_entrepot'] ?? p['emplacement'] ?? 'Entrepôt central';
                      final String unite = p['unite_mesure'] ?? 'Kg';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildProductCard(
                          nom,
                          qte,
                          pu,
                          unite,
                          entrepot,
                          Icons.eco,
                          banGreen,
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCircle(String label, IconData icon, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchCtrl.clear();
          _searchQuery = "";
          _selectedCategory = label;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.2 : 0.1),
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: color, width: 2) : null,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String title, double quantite, double prixUnitaire, String unite, String entrepot, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.store_mall_directory_outlined, size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entrepot,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Stock dispo : $quantite $unite",
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${prixUnitaire.toStringAsFixed(2)} \$",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: banGreen, fontSize: 15),
              ),
              Text(
                "/ $unite",
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}