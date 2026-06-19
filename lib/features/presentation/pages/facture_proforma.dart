import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'header_ban.dart';
import 'calcul_automatique.dart';

class FactureProforma extends StatefulWidget {
  final Map<String, dynamic> infoClient;
  final Map<String, dynamic> produit; 
  final int quantite;
  final Map<String, dynamic> infoPaiement;

  const FactureProforma({
    super.key,
    required this.infoClient,
    required this.produit,
    required this.quantite,
    required this.infoPaiement,
  });

  @override
  State<FactureProforma> createState() => _FactureProformaState();
}

class _FactureProformaState extends State<FactureProforma> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isProcessing = false;
  late FactureCalculator _calc;
  
  final String _dateFacture = DateTime.now().toString().substring(0, 10);
  final String _numFacture = "FAC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

  @override
  void initState() {
    super.initState();
    _calc = FactureCalculator(
      prixUnitaire: _extrairePrixSafe(widget.produit),
      quantite: widget.quantite,
    );
  }

  double _extrairePrixSafe(Map<String, dynamic> data) {
    final cles = ['prix_unitaire', 'prix', 'montant', 'value', 'price'];
    for (var cle in cles) {
      if (data.containsKey(cle) && data[cle] != null) {
        final val = data[cle];
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      }
    }
    return 0.0;
  }

  Future<void> _sauvegarder() async {
    setState(() => _isProcessing = true);
    try {
      // Insertion complète pour correspondre aux contraintes BDD et aux besoins du Dashboard
      await _supabase.from('commandes').insert({
        'nom_client': widget.infoClient['nom'] ?? 'Client Anonyme',
        'nom_produit': widget.produit['nom_produit'] ?? 'Produit',
        'quantite': widget.quantite, // Correction ici
        'prix_total': _calc.totalTtc,
        'statut': 'proforma', // Statut par défaut
        
        // Champs nécessaires pour vos calculs financiers dans le dashboard
        'frais_transport': _calc.fraisTransport,
        'frais_manutention': _calc.manutention,
        'frais_stockage': _calc.stockage,
        'commission': _calc.commission,
        'montant_tva': _calc.tva,
        
        'created_at': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Commande enregistrée !"), backgroundColor: Colors.green)
        );
        Navigator.pop(context); // Retour arrière après succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur BDD: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _genererPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("FACTURE PROFORMA", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.Text("Facture N°: $_numFacture | Date: $_dateFacture"),
          pw.Text("Client: ${widget.infoClient['nom'] ?? 'N/A'}"),
          pw.SizedBox(height: 20),
          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            headers: ["Désignation", "Qté", "P.U", "Total"],
            data: [[widget.produit['nom_produit'] ?? 'Produit', widget.quantite.toString(), _calc.prixUnitaire.toStringAsFixed(2), _calc.prixBase.toStringAsFixed(2)]],
          ),
          pw.SizedBox(height: 20),
          _buildPdfRow("Transport (3%)", _calc.fraisTransport),
          _buildPdfRow("Manutention (1%)", _calc.manutention),
          _buildPdfRow("Stockage (1%)", _calc.stockage),
          _buildPdfRow("Commission (5%)", _calc.commission),
          pw.Divider(),
          _buildPdfRow("TOTAL HT", _calc.totalHt),
          _buildPdfRow("TVA (16%)", _calc.tva),
          pw.Divider(),
          _buildPdfRow("NET À PAYER (TTC)", _calc.totalTtc, isBold: true),
        ],
      ),
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildPdfRow(String label, double value, {bool isBold = false}) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      pw.Text("${value.toStringAsFixed(2)} \$"),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Column(
        children: [
          const HeaderBanIturi(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text("Détail Facturation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Divider(),
                            _buildRow("Produit", widget.produit['nom_produit'] ?? 'N/A', isCurrency: false),
                            _buildRow("Prix Unitaire", _calc.prixUnitaire),
                            const Divider(),
                            _buildRow("Transport (3%)", _calc.fraisTransport),
                            _buildRow("Manutention (1%)", _calc.manutention),
                            _buildRow("Stockage (1%)", _calc.stockage),
                            _buildRow("Commission (5%)", _calc.commission),
                            const Divider(),
                            _buildRow("TOTAL HT", _calc.totalHt),
                            _buildRow("TVA (16%)", _calc.tva),
                            const SizedBox(height: 10),
                            _buildRow("NET À PAYER", _calc.totalTtc, isBold: true, isLarge: true),
                            const SizedBox(height: 20),
                            QrImageView(data: "CMD-$_numFacture", size: 100),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER"))),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: _isProcessing ? null : _sauvegarder, child: const Text("SAUVEGARDER", style: TextStyle(color: Colors.white)))),
                      ],
                    ),
                    TextButton(onPressed: _genererPdf, child: const Text("Générer PDF / Imprimer"))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, dynamic value, {bool isBold = false, bool isLarge = false, bool isCurrency = true}) {
    String textValue = isCurrency 
      ? "${(value as double).toStringAsFixed(2)} \$" 
      : value.toString();
      
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
          Text(textValue, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isLarge ? 18 : 14,
            color: isLarge ? Colors.green.shade800 : Colors.black
          )),
        ],
      ),
    );
  }
}