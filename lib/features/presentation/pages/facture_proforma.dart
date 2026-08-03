import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

// Couleurs Officielles BAN
const Color kPrimaryGreen = Color(0xFF0F522B);
const Color kPrimaryBlue = Color(0xFF1565C0);

/// Widget de facture (écran + PDF).
///
/// Il est conçu pour être alimenté de deux façons :
///  - depuis le paiement (clés : reference_transaction, numero_facture,
///    lieu_livraison dans [infoClient], details_facture)
///  - depuis l'historique des commandes (clés : referenceFacture,
///    modePaiement, lieuLivraison, statutFinancier)
class FactureProforma extends StatelessWidget {
  final Map<String, dynamic> infoClient;
  final Map<String, dynamic> produit;
  final double quantite;
  final Map<String, dynamic> infoPaiement;

  const FactureProforma({
    super.key,
    required this.infoClient,
    required this.produit,
    required this.quantite,
    required this.infoPaiement,
  });

  // =======================
  // Helpers de récupération
  // =======================

  String _numeroFacture() =>
      (infoPaiement['numero_facture'] ?? infoPaiement['referenceFacture'])
          ?.toString() ??
      'N/A';

  String _referenceTransaction() {
    final ref = (infoPaiement['reference_transaction'] ?? infoPaiement['referenceFacture'])?.toString();
    if (ref == null) return 'N/A';
    // Si c'est une référence longue (ex: CMD-timestamp), on prend la fin
    if (ref.length > 10) {
      return "REF-${ref.substring(ref.length - 6)}";
    }
    return ref;
  }

  String _lieuLivraison() =>
      (infoClient['lieu_livraison'] ??
              infoPaiement['lieuLivraison'] ??
              infoPaiement['lieu_livraison'])
          ?.toString() ??
      'Non spécifié';

  /// Résout le nom de l'entrepôt (lieu) lié à la commande/produit.
  /// Requête Supabase si [infoPaiement['entrepot_id']] est fourni.
  Future<String> _nomEntrepot() async {
    final dynamic id = infoPaiement['entrepot_id'];
    if (id == null) return 'Non spécifié';
    try {
      final result = await Supabase.instance.client
          .from('entrepots')
          .select('nom_entrepot, territoire')
          .eq('id', id)
          .maybeSingle();
      if (result != null) {
        final nom = result['nom_entrepot']?.toString() ?? '';
        final terr = result['territoire']?.toString() ?? '';
        final libelle = terr.isNotEmpty ? '$nom ($terr)' : nom;
        return libelle.isNotEmpty ? libelle : 'Non spécifié';
      }
    } catch (_) {
      // ignore
    }
    return 'Non spécifié';
  }

  double _prixTotal() {
    final dynamic v =
        infoPaiement['prix_total'] ?? infoPaiement['montantTotalTtc'];
    return (v as num?)?.toDouble() ?? 0.0;
  }

  double _prixUnitaire() {
    final dynamic v = produit['prix_unitaire'];
    return (v as num?)?.toDouble() ?? 0.0;
  }

  String _formatMontant(double montant) =>
      '${(montant * 1.2).toInt()} CDF';

  /// Contenu encodé dans le QR code (référence + n° facture).
  String _qrData() =>
      'BAN ITURI | Facture: ${_numeroFacture()} | Réf: ${_referenceTransaction()}';

  // --- LOGIQUE DE GÉNÉRATION PDF avec polices Unicode (support français) ---
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Polices Unicode téléchargées — supporte les accents français
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    // Récupération sécurisée des données
    final Map<String, dynamic> details = infoPaiement['details_facture'] ?? {};

    // Fonction de sécurité pour convertir les nombres
    double getVal(dynamic val) => (val as num?)?.toDouble() ?? 0.0;

    // Détails financiers : on les prend s'ils existent, sinon on les
    // recalcule à partir de la base HT (prix unitaire × quantité).
    final double baseHt = details.isNotEmpty
        ? getVal(details['base_ht'])
        : (_prixUnitaire() * quantite);
    final double fraisTransport =
        details.isNotEmpty ? getVal(details['frais_transport']) : 0.05 * baseHt;
    final double fraisManutention = details.isNotEmpty
        ? getVal(details['frais_manutention'])
        : 0.02 * baseHt;
    final double fraisStockage =
        details.isNotEmpty ? getVal(details['frais_stockage']) : 0.01 * baseHt;
    final double commission =
        details.isNotEmpty ? getVal(details['commission']) : 0.036 * baseHt;
    final double tva = details.isNotEmpty ? getVal(details['tva']) : 0.16 * baseHt;

    final String qrData = _qrData();
    final double total = _prixTotal();
    final String lieu = _lieuLivraison();
    final String nomEntrepot = await _nomEntrepot();
    final String facture = _numeroFacture();
    final String reference = _referenceTransaction();
    final String client = infoClient['nom_client'] ?? 'Non défini';
    final String produitNom =
        produit['nom_produit'] ?? produit['nom'] ?? 'Produit';
    final String dateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "FACTURE - BAN ITURI",
                  style: pw.TextStyle(font: fontBold, fontSize: 22),
                ),
                pw.Container(
                  height: 70,
                  width: 70,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text("N° Facture: $facture",
                style: pw.TextStyle(font: fontBold, fontSize: 11)),
            pw.Text("Réf Transaction: $reference",
                style: pw.TextStyle(font: fontRegular, fontSize: 11)),
            pw.Text("Date: $dateStr",
                style: pw.TextStyle(font: fontRegular, fontSize: 11)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text("Client: $client",
                style: pw.TextStyle(font: fontRegular, fontSize: 12)),
            pw.Text("Lieu de livraison / retrait: $lieu",
                style: pw.TextStyle(font: fontRegular, fontSize: 12)),
            pw.Text("Entrepôt (lieu du produit): $nomEntrepot",
                style: pw.TextStyle(font: fontRegular, fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Désignation', 'Montant (CDF)'],
              headerStyle: pw.TextStyle(font: fontBold),
              cellStyle: pw.TextStyle(font: fontRegular),
              data: <List<String>>[
                ['Produit', produitNom],
                ['Quantité', quantite.toInt().toString()],
                ['Sous-total (Base HT)', (baseHt * 1.2).toInt().toString()],
                ['Transport (5%)', (fraisTransport * 1.2).toInt().toString()],
                ['Manutention (2%)', (fraisManutention * 1.2).toInt().toString()],
                ['Stockage (1%)', (fraisStockage * 1.2).toInt().toString()],
                ['Commission BAN (3.6%)', (commission * 1.2).toInt().toString()],
                ['TVA (16%)', (tva * 1.2).toInt().toString()],
                ['TOTAL TTC', (total * 1.2).toInt().toString()],
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 110,
                    width: 110,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: qrData,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    "Scannez ce QR code pour vérifier votre facture",
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final String reference = _referenceTransaction();
    final String facture = _numeroFacture();
    final String lieu = _lieuLivraison();
    final String totalFormate = _formatMontant(_prixTotal());
    final String produitNom =
        produit['nom_produit'] ?? produit['nom'] ?? "Produit";
    final double total = _prixTotal();
    final Map<String, dynamic> details = infoPaiement['details_facture'] ?? {};
    double dVal(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
    final double baseHt =
        details.isNotEmpty ? dVal(details['base_ht']) : (_prixUnitaire() * quantite);
    final double fraisTransport =
        details.isNotEmpty ? dVal(details['frais_transport']) : 0.05 * baseHt;
    final double fraisManutention = details.isNotEmpty
        ? dVal(details['frais_manutention'])
        : 0.02 * baseHt;
    final double fraisStockage =
        details.isNotEmpty ? dVal(details['frais_stockage']) : 0.01 * baseHt;
    final double commission =
        details.isNotEmpty ? dVal(details['commission']) : 0.036 * baseHt;
    final double tva = details.isNotEmpty ? dVal(details['tva']) : 0.16 * baseHt;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryGreen, kPrimaryBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.eco, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text("BAN ITURI",
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            color: kPrimaryGreen, size: 80),
                        const SizedBox(height: 15),
                        Text("Transaction Réussie !",
                            style: GoogleFonts.poppins(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            // ignore: deprecated_member_use
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow("N° Facture", facture),
                              _buildDetailRow("Réf Transaction", reference),
                              const Divider(height: 30),
                              _buildDetailRow("Produit", produitNom),
                              _buildDetailRow("Quantité",
                                  "${quantite.toInt()} ${produit['unite_mesure'] ?? ''}"),
                              _buildDetailRow("Lieu livraison", lieu),
                              FutureBuilder<String>(
                                future: _nomEntrepot(),
                                builder: (context, snap) {
                                  final nomLieu =
                                      snap.data ?? 'Chargement...';
                                  return _buildDetailRow(
                                      "Entrepôt (lieu)", nomLieu);
                                },
                              ),
                              const Divider(height: 30),
                              _buildDetailRow("Total Payé", totalFormate),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            // ignore: deprecated_member_use
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Récapitulatif financier",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              _buildMontantRow("Sous-total (Base HT)",
                                  "${(baseHt * 1.2).toInt()} CDF"),
                              _buildMontantRow("Transport (5%)",
                                  "${(fraisTransport * 1.2).toInt()} CDF"),
                              _buildMontantRow("Manutention (2%)",
                                  "${(fraisManutention * 1.2).toInt()} CDF"),
                              _buildMontantRow("Stockage (1%)",
                                  "${(fraisStockage * 1.2).toInt()} CDF"),
                              _buildMontantRow("Commission BAN (3.6%)",
                                  "${(commission * 1.2).toInt()} CDF"),
                              _buildMontantRow("TVA (16%)",
                                  "${(tva * 1.2).toInt()} CDF"),
                              const Divider(height: 16),
                              _buildMontantRow("TOTAL TTC",
                                  "${(total * 1.2).toInt()} CDF",
                                  bold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            // ignore: deprecated_member_use
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Column(
                            children: [
                              QrImageView(
                                data: _qrData(),
                                version: QrVersions.auto,
                                size: 140,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Scannez ce QR code pour vérifier votre facture",
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey.shade600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _generatePdf(context),
                            child: Text("IMPRIMER FACTURE",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ligne de détail sans overflow — label fixe à gauche, valeur flexible à droite
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Largeur fixe pour le label
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          // Valeur Expanded pour éviter l'overflow
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne du récapitulatif financier (libellé à gauche, montant à droite).
  Widget _buildMontantRow(String label, String montant, {bool bold = false}) {
    final TextStyle style = bold
        ? GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: kPrimaryGreen,
          )
        : GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(montant, style: style),
        ],
      ),
    );
  }
}
