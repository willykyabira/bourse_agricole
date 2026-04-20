import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  const SearchBarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Rechercher un produit agricole...",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            icon: Icon(Icons.search, color: Color(0xFF1B5E20)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}