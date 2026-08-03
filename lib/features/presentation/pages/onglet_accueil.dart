import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OngletAccueil extends StatefulWidget {
  const OngletAccueil({super.key});

  @override
  State<OngletAccueil> createState() => _OngletAccueilState();
}

class _OngletAccueilState extends State<OngletAccueil> {
  // Contrôleur de la barre de recherche
  final TextEditingController _searchCtrl = TextEditingController();

  String _searchQuery = "";
  String _selectedCategory = "Tous";

  // Couleurs principales de l'application
  final Color banGreen = const Color(0xFF1B5E20);
  final Color banGold = const Color(0xFFFBC02D);

  // Map des entrepôts (id -> nom) pour afficher le lieu lié au produit
  Map<String, String> _entrepots = {};

  // Liste des catégories disponibles
  final List<Map<String, dynamic>> _categories = [
    {"name": "Tous", "icon": Icons.grid_view},
    {"name": "Tubercules", "icon": Icons.agriculture},
    {"name": "Céréales", "icon": Icons.bakery_dining},
    {"name": "Légumes", "icon": Icons.grass},
    {"name": "Fruits", "icon": Icons.apple},
    {"name": "Élevage", "icon": Icons.pets},
  ];

  @override
  void initState() {
    super.initState();
    _chargerEntrepots();
  }

  /// Charge la liste des entrepôts pour faire correspondre
  /// entrepot_id -> nom_entrepot (lieu du produit).
  Future<void> _chargerEntrepots() async {
    try {
      final result = await Supabase.instance.client
          .from('entrepots')
          .select('id, nom_entrepot');
      final map = <String, String>{};
      for (final e in (result as List)) {
        final id = e['id']?.toString();
        final nom = e['nom_entrepot']?.toString();
        if (id != null && nom != null) map[id] = nom;
      }
      if (mounted) setState(() => _entrepots = map);
    } catch (_) {
      // En cas d'erreur, on garde la map vide (affichage par défaut)
    }
  }

  /// Retourne le nom du lieu (entrepôt) lié au produit.
  String _lieuProduit(Map<String, dynamic> produit) {
    final dynamic id = produit['entrepot_id'];
    
    // Si on a un ID, on cherche dans la map chargée.
    if (id != null && _entrepots.containsKey(id.toString())) {
      return _entrepots[id.toString()]!;
    }
    
    // Sinon, on essaie de voir si le champ entrepot contient une info directe (legacy)
    final dynamic nomDirect = produit['entrepot'];
    if (nomDirect != null && nomDirect.toString().isNotEmpty) {
      return nomDirect.toString();
    }
    
    return 'Non spécifié';
  }

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
        // Barre de recherche
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Rechercher un produit (Manioc, Maïs...)",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey,
                ),
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

        // Contenu principal
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 15),

              // Catégories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Catégories",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
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
                      child: Text(
                        "Réinitialiser",
                        style: TextStyle(
                          color: banGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    final categorie = _categories[index];

                    final bool isSelected =
                        _searchQuery.isEmpty &&
                        _selectedCategory == categorie['name'];

                    return _buildCategoryCircle(
                      categorie['name'],
                      categorie['icon'],
                      isSelected ? banGold : banGreen,
                      isSelected,
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // Titre de la liste
              Text(
                _searchQuery.isNotEmpty
                    ? "Résultats pour : '$_searchQuery'"
                    : (_selectedCategory == "Tous"
                          ? "Offres du Marché"
                          : "Offres : $_selectedCategory"),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Chargement des produits depuis Supabase
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('produits')
                    .stream(primaryKey: ['id'])
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: banGreen),
                    );
                  }

                  final allProducts = snapshot.data ?? [];

                  // Application des filtres
                  final filteredProducts = allProducts.where((produit) {
                    final nomProduit = (produit['nom_produit'] ?? '')
                        .toString()
                        .toLowerCase();

                    final catProduit = (produit['nom_categorie'] ?? '')
                        .toString()
                        .trim()
                        .toLowerCase();

                    final catSelectionnee = _selectedCategory
                        .trim()
                        .toLowerCase();

                    if (_searchQuery.isNotEmpty) {
                      return nomProduit.contains(_searchQuery);
                    }

                    if (_selectedCategory == "Tous") {
                      return true;
                    }

                    return catProduit == catSelectionnee;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text("Aucun produit disponible.")),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final produit = filteredProducts[index];

                      // Informations du produit
                      final String nom = (produit['nom_produit'] ?? 'Produit')
                          .toString()
                          .toUpperCase();

                      final double quantite =
                          double.tryParse(produit['quantite'].toString()) ?? 0;

                      final double prix =
                          double.tryParse(
                            produit['prix_unitaire'].toString(),
                          ) ??
                          0;

                      final String entrepot = _lieuProduit(produit);

                      final String unite = produit['unite_mesure'] ?? 'Kg';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildProductCard(
                          nom,
                          quantite,
                          prix,
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
            ],
          ),
        ),
      ],
    );
  }

  // Widget représentant une catégorie
  Widget _buildCategoryCircle(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        _searchCtrl.clear();

        setState(() {
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
                // ignore: deprecated_member_use
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

  // Carte affichant un produit
  Widget _buildProductCard(
    String title,
    double quantite,
    double prixUnitaire,
    String unite,
    String entrepot,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Icône du produit
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),

          const SizedBox(width: 14),

          // Informations du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Lieu : $entrepot",
                        style:
                            GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),

                Text(
                  "Stock : $quantite $unite",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Prix du produit
          Text(
            "${(prixUnitaire * 1.2).toInt()} CDF",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: banGreen,
            ),
          ),
        ],
      ),
    );
  }
}
