import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bourse_agricole/features/data/services/pawapay_service.dart';
import 'package:bourse_agricole/features/data/datasources/supabase_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:bourse_agricole/core/services/toast_service.dart';
import 'facture_proforma.dart';
import '../widgets/ban_layout_scaffold.dart';

// ─────────────────────────────────────────
// États internes du flux de paiement
// ─────────────────────────────────────────
enum _EtatPaiement {
  initial, // Prêt à payer
  chargement, // Création de la session PawaPay en cours
  attente, // URL ouverte, en attente de retour utilisateur
  verification, // Vérification du statut du paiement
  succes, // Paiement confirmé
  echec, // Paiement échoué
}

class PaiementPage extends StatefulWidget {
  final Map<String, dynamic> infoClient;
  final Map<String, dynamic> produit;
  final double quantite;
  final double montantTotalTtc;

  const PaiementPage({
    super.key,
    required this.infoClient,
    required this.produit,
    required this.quantite,
    required this.montantTotalTtc,
  });

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage>
    with TickerProviderStateMixin {
  // ─── État ───────────────────────────────────────────────────────
  _EtatPaiement _etat = _EtatPaiement.initial;
  String? _depositId;
  String? _messageErreur;

  // ─── Animation ───────────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ─── Couleurs BAN ────────────────────────────────────────────────
  final Color _banPrimary = const Color(0xFF0B5E34);
  final Color _banAccent = const Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // ÉTAPE 1 : Créer la session et ouvrir l'URL PawaPay
  // ─────────────────────────────────────────────────────────────────
  Future<void> _lancerPaiement() async {
    setState(() {
      _etat = _EtatPaiement.chargement;
      _messageErreur = null;
    });

    try {
      final pawaPayService = PawaPayService();
      final referenceCommande = 'CMD-${DateTime.now().millisecondsSinceEpoch}';

      // Raison affichée sur la page PawaPay
      final nomProduit =
          widget.produit['nom_produit'] ?? widget.produit['nom'] ?? 'Produit';
      final raison = 'BAN - $nomProduit';

      // Appel à l'Edge Function pawa-payment-page
      final session = await pawaPayService.creerPaymentPage(
        montant: widget.montantTotalTtc,
        referenceCommande: referenceCommande,
        raison: raison,
      );

      final String? redirectUrl = session['redirectUrl'] as String?;
      final String? depositId = session['depositId'] as String?;

      if (redirectUrl == null || depositId == null) {
        throw Exception('Réponse invalide : redirectUrl ou depositId manquant');
      }

      _depositId = depositId;

      // Ouvrir l'URL PawaPay dans le navigateur externe
      final uri = Uri.parse(redirectUrl);
      final peutOuvrir = await canLaunchUrl(uri);

      if (!peutOuvrir) {
        throw Exception('Impossible d\'ouvrir la page de paiement');
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (mounted) {
        setState(() => _etat = _EtatPaiement.attente);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _etat = _EtatPaiement.echec;
          _messageErreur = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // ÉTAPE 2 : Vérifier le statut après retour de l'utilisateur
  // ─────────────────────────────────────────────────────────────────
  Future<void> _verifierStatut() async {
    if (_depositId == null) return;

    setState(() {
      _etat = _EtatPaiement.verification;
      _messageErreur = null;
    });

    try {
      final pawaPayService = PawaPayService();
      final statut = await pawaPayService.verifierStatutPaiement(
        depositId: _depositId!,
      );

      final String status = (statut['status'] as String?) ?? 'UNKNOWN';

      if (status == 'COMPLETED') {
        await _enregistrerCommande(statut);
      } else if (status == 'FAILED' ||
          status == 'REJECTED' ||
          status == 'TIMED_OUT') {
        if (mounted) {
          setState(() {
            _etat = _EtatPaiement.echec;
            _messageErreur =
                'Le paiement a échoué (statut : $status). Veuillez réessayer.';
          });
        }
      } else {
        // PENDING / AWAITING_CONFIRMATION / DUPLICATE_IGNORED
        if (mounted) {
          setState(() {
            _etat = _EtatPaiement.attente;
            _messageErreur =
                'Paiement en cours (statut : $status). Veuillez patienter et réessayer.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _etat = _EtatPaiement.echec;
          _messageErreur =
              'Erreur lors de la vérification : ${e.toString().replaceFirst("Exception: ", "")}';
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // ÉTAPE 3 : Enregistrer la commande dans Supabase après confirmation
  // ─────────────────────────────────────────────────────────────────
  Future<void> _enregistrerCommande(Map<String, dynamic> statutPaiement) async {
    try {
      final String numeroFacture =
          'FACT-${DateTime.now().millisecondsSinceEpoch}';

      // Calcul des détails financiers
      final double baseHt =
          widget.quantite *
          ((widget.produit['prix_unitaire'] as num?)?.toDouble() ?? 0.0);
      final double fraisTransport = 0.05 * baseHt;
      final double fraisManutention = 0.02 * baseHt;
      final double fraisStockage = 0.01 * baseHt;
      final double commission = 0.036 * baseHt;
      final double tva = 0.16 * baseHt;

      // Résolution de l'entrepôt
      String? resolvedEntrepotId =
          widget.produit['entrepot_id']?.toString() ??
          widget.infoClient['entrepot_id']?.toString();
      String resolvedLieuLivraison = 'Non spécifié';

      if (resolvedEntrepotId != null) {
        try {
          final res = await Supabase.instance.client
              .from('entrepots')
              .select('nom_entrepot')
              .eq('id', resolvedEntrepotId)
              .maybeSingle();
          if (res != null && res['nom_entrepot'] != null) {
            resolvedLieuLivraison = res['nom_entrepot'].toString();
          }
        } catch (_) {}
      }

      if (resolvedLieuLivraison == 'Non spécifié') {
        try {
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            final pRes = await Supabase.instance.client
                .from('profiles')
                .select('entrepot_id')
                .eq('id', user.id)
                .maybeSingle();
            if (pRes != null && pRes['entrepot_id'] != null) {
              resolvedEntrepotId = pRes['entrepot_id'].toString();
              final eRes = await Supabase.instance.client
                  .from('entrepots')
                  .select('nom_entrepot')
                  .eq('id', resolvedEntrepotId)
                  .maybeSingle();
              if (eRes != null && eRes['nom_entrepot'] != null) {
                resolvedLieuLivraison = eRes['nom_entrepot'].toString();
              }
            }
          }
        } catch (_) {}
      }

      if (resolvedLieuLivraison == 'Non spécifié') {
        try {
          final firstEntrepot = await Supabase.instance.client
              .from('entrepots')
              .select('id, nom_entrepot')
              .limit(1)
              .maybeSingle();
          if (firstEntrepot != null) {
            resolvedEntrepotId ??= firstEntrepot['id']?.toString();
            resolvedLieuLivraison =
                firstEntrepot['nom_entrepot']?.toString() ?? 'Non spécifié';
          }
        } catch (_) {}
      }

      // Enregistrement en base de données
      final datasource = SupabaseDatasourceImpl(GetIt.I<SupabaseClient>());
      await datasource.creerCommande({
        'reference_facture': numeroFacture,
        'prix_total': widget.montantTotalTtc,
        'mode_paiement': 'PawaPay Payment Page',
        'nom_produit':
            widget.produit['nom_produit'] ?? widget.produit['nom'] ?? 'Produit',
        'nom_client': widget.infoClient['nom_client'] ?? 'Client',
        'telephone_client': widget.infoClient['telephone'] ?? '',
        'lieu_livraison': resolvedLieuLivraison,
        'quantite': widget.quantite,
        'produit_id': widget.produit['id'],
        'entrepot_id': resolvedEntrepotId,
      });

      ToastService().showSuccess(
        'Paiement confirmé ! Commande $numeroFacture enregistrée.',
      );

      if (mounted) {
        setState(() => _etat = _EtatPaiement.succes);

        // Navigation vers la facture
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FactureProforma(
              infoClient: {
                ...widget.infoClient,
                'lieu_livraison': resolvedLieuLivraison,
              },
              produit: widget.produit,
              quantite: widget.quantite,
              infoPaiement: {
                'operateur': 'PawaPay',
                'numero_facture': numeroFacture,
                'prix_total': widget.montantTotalTtc,
                'montantTotalTtc': widget.montantTotalTtc,
                'devise': statutPaiement['currency'] ?? 'FC',
                'reference_transaction': _depositId ?? 'N/A',
                'entrepot_id': resolvedEntrepotId,
                'details_facture': {
                  'base_ht': baseHt,
                  'frais_transport': fraisTransport,
                  'frais_manutention': fraisManutention,
                  'frais_stockage': fraisStockage,
                  'commission': commission,
                  'tva': tva,
                },
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _etat = _EtatPaiement.echec;
          _messageErreur =
              'Paiement reçu mais erreur d\'enregistrement : ${e.toString().replaceFirst("Exception: ", "")}';
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BanLayoutScaffold(
      bodyTitle: 'Paiement Sécurisé',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Carte montant ──────────────────────────────────
              _buildMontantCard(),
              const SizedBox(height: 28),

              // ── Carte produit ──────────────────────────────────
              _buildProduitCard(),
              const SizedBox(height: 28),

              // ── Zone de statut / action ────────────────────────
              _buildActionZone(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Carte montant ────────────────────────────────────────────────
  Widget _buildMontantCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_banPrimary, _banAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _banPrimary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Montant à payer',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(widget.montantTotalTtc * 1.2).toInt()} CDF',
            style: GoogleFonts.poppins(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Paiement sécurisé par PawaPay',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Carte produit ────────────────────────────────────────────────
  Widget _buildProduitCard() {
    final nomProduit =
        widget.produit['nom_produit'] ?? widget.produit['nom'] ?? 'Produit';
    final nomClient = widget.infoClient['nom_client'] ?? 'Client';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de la commande',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const Divider(height: 20),
          _infoRow(Icons.shopping_basket_outlined, 'Produit', nomProduit),
          const SizedBox(height: 10),
          _infoRow(
            Icons.scale_outlined,
            'Quantité',
            '${widget.quantite.toInt()} ${widget.produit['unite_mesure'] ?? ''}',
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.person_outline, 'Client', nomClient),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _banPrimary),
        const SizedBox(width: 10),
        Text(
          '$label : ',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─── Zone d'action selon l'état ──────────────────────────────────
  Widget _buildActionZone() {
    switch (_etat) {
      case _EtatPaiement.initial:
        return _buildEtatInitial();
      case _EtatPaiement.chargement:
        return _buildEtatChargement('Création de la session de paiement…');
      case _EtatPaiement.attente:
        return _buildEtatAttente();
      case _EtatPaiement.verification:
        return _buildEtatChargement('Vérification du paiement…');
      case _EtatPaiement.succes:
        return _buildEtatSucces();
      case _EtatPaiement.echec:
        return _buildEtatEchec();
    }
  }

  // ─── État : Initial ───────────────────────────────────────────────
  Widget _buildEtatInitial() {
    return Column(
      children: [
        // Explication du nouveau flux
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _banPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _banPrimary.withValues(alpha: 0.18)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: _banPrimary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'En cliquant sur "Payer", vous serez redirigé vers la page de paiement sécurisée PawaPay où vous choisirez votre opérateur mobile (Orange, Airtel, Vodacom…) et saisirez votre numéro.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _banPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Boutons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _banPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.poppins(
                    color: _banPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _lancerPaiement,
                icon: const Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Payer avec PawaPay',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _banPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── État : Chargement ────────────────────────────────────────────
  Widget _buildEtatChargement(String message) {
    return Column(
      children: [
        const SizedBox(height: 20),
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _banPrimary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: _banPrimary,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── État : Attente (URL ouverte) ─────────────────────────────────
  Widget _buildEtatAttente() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Indicateur visuel
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.open_in_browser,
                color: Colors.amber.shade700,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'Page PawaPay ouverte',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.amber.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complétez votre paiement dans le navigateur, puis revenez ici pour confirmer.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.amber.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        if (_messageErreur != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              _messageErreur!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.orange.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Bouton principal — Vérifier le paiement
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _verifierStatut,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: Text(
              'J\'ai effectué le paiement',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _banPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Bouton secondaire — Rouvrir la page PawaPay
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _lancerPaiement,
            icon: Icon(Icons.refresh, color: _banPrimary, size: 18),
            label: Text(
              'Rouvrir la page de paiement',
              style: GoogleFonts.poppins(
                color: _banPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _banPrimary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Annuler
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ─── État : Succès ────────────────────────────────────────────────
  Widget _buildEtatSucces() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 12),
          Text(
            'Paiement confirmé !',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre commande a été enregistrée avec succès.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.green.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── État : Échec ─────────────────────────────────────────────────
  Widget _buildEtatEchec() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Paiement non abouti',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
              ),
              if (_messageErreur != null) ...[
                const SizedBox(height: 8),
                Text(
                  _messageErreur!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Réessayer
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() {
              _etat = _EtatPaiement.initial;
              _messageErreur = null;
              _depositId = null;
            }),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Réessayer',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _banPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Retour',
            style: GoogleFonts.inter(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}
