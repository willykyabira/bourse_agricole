import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../widgets/revenue_chart.dart';

class FinanceReportWeb extends StatelessWidget {
  const FinanceReportWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rapports Financiers & Revenus")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Aperçu des revenus", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const RevenueChart(), // Widget graphique
            const SizedBox(height: 40),
            Card(
              child: ListTile(
                leading: const Icon(Icons.file_download, color: AppColors.primaryGreen),
                title: const Text("Exporter le rapport mensuel"),
                subtitle: const Text("Format PDF ou Excel"),
                onTap: () {
                  // Logique d'exportation
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
