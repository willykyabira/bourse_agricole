import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';

import 'package:barcode_widget/barcode_widget.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        title: const Text(
          "Mon Historique",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        elevation: 1,
      ),

      body: user == null
          ? const Center(
              child: Text("Veuillez vous connecter pour voir vos achats."),
            )
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('commandes')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', user.id)
                  .order('created_at', ascending: false),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError)
                  return Center(child: Text("Erreur : ${snapshot.error}"));

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Aucun achat trouvé sur ce compte."),
                  );
                }

                final commandes = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: commandes.length,

                  itemBuilder: (context, index) =>
                      _CommandeCard(item: commandes[index]),
                );
              },
            ),
    );
  }
}

class _CommandeCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CommandeCard({required this.item});

  Future<void> _printFacture() async {
    // --- DÉBOGAGE : AFFICHE LES DONNÉES RÉELLES DANS LA CONSOLE ---

    debugPrint("DEBUG - Contenu complet de l'objet item : $item");

    final pdf = pw.Document();

    final supabase = Supabase.instance.client;

    String telephone = "Non disponible";

    final String? lieu = item['lieu_retrait'];

    if (lieu != null && lieu.isNotEmpty) {
      try {
        final data = await supabase
            .from('entrepots')
            .select('telephone')
            .eq('nom', lieu)
            .maybeSingle();

        if (data != null && data['telephone'] != null) {
          telephone = data['telephone'];
        }
      } catch (e) {
        debugPrint("Erreur récupération téléphone : $e");
      }
    }

    final double totalTtc = (item['prix_total'] as num?)?.toDouble() ?? 0.0;

    final int qty = (item['quantite'] as num?)?.toInt() ?? 1;

    final double unitPrice = qty > 0 ? (totalTtc / qty) : 0.0;

    final double tva = (item['montant_tva'] as num?)?.toDouble() ?? 0.0;

    final double transport =
        (item['frais_transport'] as num?)?.toDouble() ?? 0.0;

    final double manutention =
        (item['frais_manutention'] as num?)?.toDouble() ?? 0.0;

    final double commission = (item['commission'] as num?)?.toDouble() ?? 0.0;

    final double totalHt =
        totalTtc - tva - transport - manutention - commission;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,

        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "BAN ITURI",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.Text(
                        "RCCM : CD/GOM/RCCM/XX-XXXX",
                        style: const pw.TextStyle(fontSize: 9),
                      ),

                      pw.Text(
                        "ID NAT : X-XX-XXXXX-X",
                        style: const pw.TextStyle(fontSize: 9),
                      ),

                      pw.Text(
                        "NIF : AXXXXXXXXX",
                        style: const pw.TextStyle(fontSize: 9),
                      ),

                      pw.Text(
                        "Adresse : Goma, Nord-Kivu, RDC",
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Divider(),

              pw.Text(
                "FACTURE PROFORMA",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Text(
                "Facture N°: FAC-${item['id']?.toString().substring(0, 8) ?? 'XXXX'}",
              ),

              pw.Text(
                "Date: ${item['created_at']?.toString().substring(0, 10) ?? 'N/A'}",
              ),

              pw.Text("Client: ${item['nom_client'] ?? 'N/A'}"),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: ["Désignation", "Qté", "P.U", "Total"],

                data: [
                  [
                    item['nom_produit'] ?? 'Produit',

                    qty.toString(),

                    "${unitPrice.toStringAsFixed(2)} \$",

                    "${totalTtc.toStringAsFixed(2)} \$",
                  ],
                ],

                border: pw.TableBorder.all(),

                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 20),

              _buildPdfRow("Transport (3%)", transport),

              _buildPdfRow("Manutention (1%)", manutention),

              _buildPdfRow("Commission (5%)", commission),

              pw.Divider(),

              _buildPdfRow("TOTAL HT", totalHt),

              _buildPdfRow("TVA (16%)", tva),

              pw.Divider(),

              _buildPdfRow("NET À PAYER (TTC)", totalTtc, isBold: true),

              pw.SizedBox(height: 20),

              pw.Divider(),

              pw.Text(
                "Lieu de retrait: ${item['lieu_retrait'] ?? 'Non spécifié'}",
              ),

              pw.Text("Téléphone de l'entrepôt: $telephone"),

              pw.Text(
                "Échéance de retrait: ${item['echeance_retrait'] ?? 'Non spécifiée'}",
              ),

              pw.Spacer(),

              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),

                  data: "CMD-${item['id']}",

                  width: 80,

                  height: 80,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _buildPdfRow(String label, double value, {bool isBold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),

        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),

            pw.Text("${value.toStringAsFixed(2)} \$"),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: ExpansionTile(
        title: Text(
          item['nom_produit'] ?? 'Produit',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          "${item['prix_total'] ?? 0} \$ - ${item['statut'] ?? 'Payé'}",
        ),

        trailing: IconButton(
          icon: const Icon(Icons.print, color: Colors.blue),

          onPressed: _printFacture,

          tooltip: "Imprimer la facture",
        ),

        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              children: [
                ListTile(title: Text("Client: ${item['nom_client'] ?? 'N/A'}")),

                ListTile(title: Text("Lieu: ${item['lieu_retrait'] ?? 'N/A'}")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
