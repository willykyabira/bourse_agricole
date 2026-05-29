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
  
  // Variables d'état explicites pour éviter les blocages de boucle
  List<Map<String, dynamic>> _mesProduits = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _userId = supabase.auth.currentUser?.id;
    
    // Écouteur de session intelligent (ne s'active que si l'UID change réellement)
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        final String? newUid = data.session?.user.id;
        if (newUid != _userId) {
          setState(() {
            _userId = newUid;
          });
          _chargerDonnees();
        }
      }
    });

    // Lancement du premier chargement de données
    _chargerDonnees();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Fonction asynchrone directe avec try/catch et TIMEOUT de sécurité
  Future<void> _chargerDonnees() async {
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
      // Le .timeout() empêche le spinner de tourner indéfiniment si le réseau est coupé
      final data = await supabase
          .from('produits')
          .select()
          .eq('client_id', _userId!)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          _mesProduits = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Impossible de joindre le serveur. Vérifiez votre connexion internet.\nDétail : $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color banGreen = Color(0xFF1B5E20);
    const Color textDark = Color(0xFF2C3E50);

    // 1. ÉCRAN SI PAS DE SESSION UTILISATEUR DETECTÉE
    if (_userId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "Authentification requise",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 8),
              Text(
                "Veuillez vous connecter à votre compte pour synchroniser l'état de vos entrepôts.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // 2. INTERFACE PRINCIPALE
    return RefreshIndicator(
      onRefresh: _chargerDonnees,
      color: banGreen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // BANNIÈRE INFORMATIVE
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: banGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: banGreen.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: banGreen, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Voici l'état des stocks que vous avez physiquement déposés dans nos hangars partenaires.",
                    style: GoogleFonts.inter(color: banGreen, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          Text(
            "Mes dépôts en entrepôts", 
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)
          ),
          
          const SizedBox(height: 15),

          // GESTION DU CORPS DE PAGE SELON L'ÉTAT DES VARIABLES
          _buildCorpsPage(banGreen, textDark),
        ],
      ),
    );
  }

  Widget _buildCorpsPage(Color banGreen, Color textDark) {
    // Cas 1 : C'est en train de charger
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: banGreen),
        ),
      );
    }

    // Cas 2 : Une erreur réseau ou de timeout est survenue
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, size: 50, color: Colors.redAccent),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(color: Colors.red.shade700, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _chargerDonnees,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Réessayer"),
                style: ElevatedButton.styleFrom(backgroundColor: banGreen, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    // Cas 3 : Chargement réussi mais aucune ligne trouvée pour cet UID
    if (_mesProduits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text(
                "Aucun dépôt trouvé pour l'identifiant connecté.",
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Cas 4 : Tout est OK, on affiche la liste des cartes
    return Column(
      children: _mesProduits.map((item) => _buildProductCard(item, banGreen, textDark)).toList(),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, Color primaryColor, Color textDark) {
    final String nomProduit = item['nom_produit'] ?? 'Produit Inconnu';
    final String entrepot = item['entrepot'] ?? 'Hangar Principal (Bunia)';
    final double quantite = (item['quantite'] as num?)?.toDouble() ?? 0.0;
    final String unite = item['unite_mesure'] ?? 'Kg';
    final String statut = (item['est_publie'] == true) ? 'En vente' : 'En stock';
    
    final String dateDepot = item['created_at'] != null 
        ? item['created_at'].toString().substring(0, 10) 
        : '--/--/----';
    
    final double prixEstime = (item['prix_unitaire'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nomProduit.toUpperCase(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statut,
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  entrepot,
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("QUANTITÉ STOCKÉE", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      "$quantite $unite",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                    ),
                  ],
                ),
                if (prixEstime > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("PRIX UNITAIRE", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        "$prixEstime \$",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
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
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }
}