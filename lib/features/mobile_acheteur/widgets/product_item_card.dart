import 'package:flutter/material.dart';

class ProductItemCard extends StatelessWidget {
  const ProductItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo_ban.png'), // Placeholder
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Manioc Local", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Text("Ituri - Ituri 1", style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("12.5 \$", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}