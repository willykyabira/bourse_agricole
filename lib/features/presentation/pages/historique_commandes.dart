import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

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
      backgroundColor: const Color(0xFF0D47A1), 
      body: Column(
        children: [
          // En-tête avec bouton retour, logo et dégradé BAN ITURI
          Container(
            padding: const EdgeInsets.only(top: 50, left: 10, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // BOUTON RETOUR AJOUTÉ ICI
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.eco, color: Color(0xFF1B5E20), size: 30),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("BAN ITURI", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Bourse Agricole Numérique", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                  ],
                )
              ],
            ),
          ),

          // Corps de page blanc
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // TITRE CENTRÉ
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                      child: Text(
                        "Mon Historique",
                        style: GoogleFonts.poppins(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black87
                        ),
                      ),
                    ),
                  ),
                  
                  // LISTE DES COMMANDES
                  Expanded(
                    child: user == null
                        ? Center(child: Text("Veuillez vous connecter.", style: GoogleFonts.inter()))
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
                              if (snapshot.hasError) return Center(child: Text("Erreur : ${snapshot.error}"));
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text("Aucun achat trouvé."));
                              }

                              final commandes = snapshot.data!;
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: commandes.length,
                                itemBuilder: (context, index) => _CommandeCard(item: commandes[index]),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASSE COMMANDE CARD ---
class _CommandeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _CommandeCard({required this.item});

  // --- STRICTEMENT AUCUNE MODIFICATION DANS CETTE MÉTHODE ---
  Future<void> _printFacture() async {
    final pdf = pw.Document();
    final supabase = Supabase.instance.client;

    String telephone = "Non disponible";
    final String? lieu = item['lieu_retrait'];

    if (lieu != null && lieu.isNotEmpty) {
      try {
        final data = await supabase.from('entrepots').select('telephone').eq('nom', lieu).maybeSingle();
        if (data != null && data['telephone'] != null) telephone = data['telephone'];
      } catch (e) { debugPrint("Erreur récupération téléphone : $e"); }
    }

    final double totalTtc = (item['prix_total'] as num?)?.toDouble() ?? 0.0;
    final int qty = (item['quantite'] as num?)?.toInt() ?? 1;
    final double unitPrice = qty > 0 ? (totalTtc / qty) : 0.0;
    final double tva = (item['montant_tva'] as num?)?.toDouble() ?? 0.0;
    final double transport = (item['frais_transport'] as num?)?.toDouble() ?? 0.0;
    final double manutention = (item['frais_manutention'] as num?)?.toDouble() ?? 0.0;
    final double commission = (item['commission'] as num?)?.toDouble() ?? 0.0;
    final double totalHt = totalTtc - tva - transport - manutention - commission;

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
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text("BAN ITURI", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text("RCCM : CD/GOM/RCCM/XX-XXXX", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("ID NAT : X-XX-XXXXX-X", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("NIF : AXXXXXXXXX", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("Adresse : Bunia, Ituri, RDC", style: const pw.TextStyle(fontSize: 9)),
                  ]),
                ],
              ),
              pw.Divider(),
              pw.Text("FACTURE", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text("Facture N°: FAC-${item['id']?.toString().substring(0, 8) ?? 'XXXX'}"),
              pw.Text("Date: ${item['created_at']?.toString().substring(0, 10) ?? 'N/A'}"),
              pw.Text("Client: ${item['nom_client'] ?? 'N/A'}"),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: ["Désignation", "Qté", "P.U", "Total"],
                data: [[item['nom_produit'] ?? 'Produit', qty.toString(), "${unitPrice.toStringAsFixed(2)} \$", "${totalTtc.toStringAsFixed(2)} \$"]],
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
              pw.Text("Lieu de retrait: ${item['lieu_retrait'] ?? 'Non spécifié'}"),
              pw.Text("Téléphone de l'entrepôt: $telephone"),
              pw.Text("Échéance de retrait: ${item['echeance_retrait'] ?? 'Non spécifiée'}"),
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

  pw.Widget _buildPdfRow(String label, double value, {bool isBold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text("${value.toStringAsFixed(2)} \$"),
      ],
    ),
  );
  // --- FIN ZONE INTANGIBLE ---

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ExpansionTile(
        title: Text(item['nom_produit'] ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item['prix_total'] ?? 0} \$ - ${item['statut'] ?? 'Payé'}"),
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