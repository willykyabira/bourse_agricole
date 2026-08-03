import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OngletVentes extends StatefulWidget {
  const OngletVentes({super.key});

  @override
  State<OngletVentes> createState() => _OngletVentesState();
}

class _OngletVentesState extends State<OngletVentes> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Liste des produits de l'utilisateur connecté.
  List<Map<String, dynamic>> _mesProduits = [];

  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;

  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();

    // Récupère l'utilisateur connecté.
    _userId = supabase.auth.currentUser?.id;

    // Recharge les données si la session change.
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final String? newUid = data.session?.user.id;

      if (newUid != _userId) {
        setState(() => _userId = newUid);
        _chargerDonnees();
      }
    });

    _chargerDonnees();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Map<String, String> _entrepotsMap = {};

  /// Charge les produits de l'utilisateur.
  Future<void> _chargerDonnees() async {
    // Aucun utilisateur connecté.
    if (_userId == null) {
      setState(() {
        _isLoading = false;
        _mesProduits = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les entrepôts
      final entrepotsData = await supabase.from('entrepots').select('id, nom_entrepot');
      _entrepotsMap = {
        for (var item in entrepotsData as List)
          item['id'].toString(): item['nom_entrepot'].toString()
      };

      // Charger les produits
      final data = await supabase
          .from('produits')
          .select()
          .eq('client_id', _userId!)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      setState(() {
        _mesProduits = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            "Impossible de joindre le serveur. "
            "Vérifiez votre connexion internet.\n"
            "Détail : $e";

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color banGreen = Color(0xFF1B5E20);
    const Color textDark = Color(0xFF2C3E50);

    // Aucun utilisateur connecté.
    if (_userId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Colors.grey[400],
              ),

              const SizedBox(height: 16),

              Text(
                "Authentification requise",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Veuillez vous connecter à votre compte "
                "pour synchroniser l'état de vos entrepôts.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Interface principale.
    return RefreshIndicator(
      onRefresh: _chargerDonnees,
      color: banGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Bannière d'information.
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: banGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                // ignore: deprecated_member_use
                color: banGreen.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: banGreen,
                  size: 24,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Voici l'état des stocks que vous "
                    "avez physiquement déposés dans nos "
                    "hangars partenaires.",
                    style: GoogleFonts.inter(
                      color: banGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            "Mes dépôts en entrepôts",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textDark,
            ),
          ),

          const SizedBox(height: 15),

          // Affiche le contenu selon l'état de la page.
          _buildCorpsPage(banGreen, textDark),
        ],
      ),
    );
  }

  /// Affiche le contenu selon l'état actuel de la page.
  Widget _buildCorpsPage(Color banGreen, Color textDark) {
    // Chargement en cours.
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(color: banGreen),
        ),
      );
    }

    // Une erreur est survenue.
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 50,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 10),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.red.shade700,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: _chargerDonnees,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Réessayer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: banGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Aucun produit disponible.
    if (_mesProduits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Icon(
                Icons.layers_clear_outlined,
                size: 60,
                color: Colors.grey[300],
              ),

              const SizedBox(height: 10),

              Text(
                "Aucun dépôt trouvé pour l'identifiant connecté.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Affiche tous les produits.
    return Column(
      children: _mesProduits
          .map((item) => _buildProductCard(item, banGreen, textDark))
          .toList(),
    );
  }

  /// Carte affichant un produit stocké.
  Widget _buildProductCard(
    Map<String, dynamic> item,
    Color primaryColor,
    Color textDark,
  ) {
    // Informations du produit.
    final String nomProduit = item['nom_produit'] ?? 'Produit Inconnu';

    final String? entrepotId = item['entrepot_id']?.toString();
    final String entrepot = (entrepotId != null && _entrepotsMap.containsKey(entrepotId))
        ? _entrepotsMap[entrepotId]!
        : (item['entrepot'] ?? 'Hangar Principal (Bunia)');

    final double quantite = (item['quantite'] as num?)?.toDouble() ?? 0.0;

    final String unite = item['unite_mesure'] ?? 'Kg';

    final bool estDisponible = quantite > 0;
    final String statut = estDisponible
        ? (item['est_publie'] == true ? 'En vente' : 'En stock')
        : 'Rupture de stock';
    final Color statutColor = estDisponible
        ? (item['est_publie'] == true ? Colors.green.shade700 : Colors.blue.shade900)
        : Colors.red.shade700;
    final Color statutBgColor = estDisponible
        ? (item['est_publie'] == true ? Colors.green.shade50 : Colors.blue.shade50)
        : Colors.red.shade50;

    final String dateDepot = item['created_at'] != null
        ? item['created_at'].toString().substring(0, 10)
        : '--/--/----';

    final double prixEstime =
        (item['prix_unitaire'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom du produit et son statut.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nomProduit.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textDark,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statutBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statut,
                    style: TextStyle(
                      color: statutColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // Nom de l'entrepôt.
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Text(
                    entrepot,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),

            // Quantité et prix.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "QUANTITÉ STOCKÉE",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      "$quantite $unite",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textDark,
                      ),
                    ),
                  ],
                ),

                if (prixEstime > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "PRIX UNITAIRE",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "${(prixEstime * 1.2).toInt()} CDF",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Mis en dépôt le $dateDepot",
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
