import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

// Couleurs Officielles BAN
const Color kPrimaryGreen = Color(0xFF0F522B);
const Color kPrimaryBlue = Color(0xFF1565C0);

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

  // --- LOGIQUE DE GÉNÉRATION PDF (CORRIGÉE) ---
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    
    // Récupération sécurisée des données
    final Map<String, dynamic> details = infoPaiement['details_facture'] ?? {};
    
    // Fonction de sécurité pour convertir les nombres
    double getVal(dynamic val) => (val as num?)?.toDouble() ?? 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("FACTURE PROFORMA - BAN ITURI", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text("Réf Transaction: ${infoPaiement['reference_transaction'] ?? 'N/A'}"),
            pw.Text("N° Facture: ${infoPaiement['numero_facture'] ?? 'N/A'}"),
            pw.Text("Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}"),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text("Client: ${infoClient['nom_client'] ?? 'Non défini'}"),
            pw.Text("Lieu de livraison: ${infoClient['lieu_livraison'] ?? 'Non spécifié'}"),
            pw.SizedBox(height: 20),
            
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              context: context,
              headers: ['Désignation', 'Montant (\$)'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              data: <List<String>>[
                ['Sous-total (Base HT)', getVal(details['base_ht']).toStringAsFixed(2)],
                ['Transport', getVal(details['frais_transport']).toStringAsFixed(2)],
                ['Manutention', getVal(details['frais_manutention']).toStringAsFixed(2)],
                ['Stockage', getVal(details['frais_stockage']).toStringAsFixed(2)],
                ['Commission BAN', getVal(details['commission']).toStringAsFixed(2)],
                ['TVA (16%)', getVal(details['tva']).toStringAsFixed(2)],
                ['TOTAL TTC', getVal(infoPaiement['prix_total']).toStringAsFixed(2)],
              ],
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final String reference = infoPaiement['reference_transaction']?.toString() ?? "Non disponible";

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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.eco, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text("BAN ITURI", style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: kPrimaryGreen, size: 80),
                        const SizedBox(height: 15),
                        Text("Transaction Réussie !", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            // ignore: deprecated_member_use
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow("Réf", reference),
                              _buildDetailRow("N° Facture", infoPaiement['numero_facture'] ?? "N/A"),
                              const Divider(height: 30),
                              _buildDetailRow("Produit", produit['nom_produit'] ?? "Produit"),
                              _buildDetailRow("Quantité", "$quantite ${produit['unite_mesure'] ?? ''}"),
                              _buildDetailRow("Lieu livraison", infoClient['lieu_livraison'] ?? "Non spécifié"),
                              const Divider(height: 30),
                              _buildDetailRow("Total Payé", "${infoPaiement['prix_total'] ?? '0.00'} \$"),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _generatePdf(context),
                            child: Text("IMPRIMER FACTURE", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}