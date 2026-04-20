import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

// Vérifiez que le nom est bien RevenueChart
class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppColors.primaryGreen)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppColors.primaryGreen)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: AppColors.primaryGreen)]),
          ],
        ),
      ),
    );
  }
}