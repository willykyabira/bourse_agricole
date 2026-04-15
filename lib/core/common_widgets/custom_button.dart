import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const CustomButton({
    super.key, 
    required this.label, 
    required this.onPressed, 
    this.isPrimary = true
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primaryGreen : Colors.white,
          side: const BorderSide(color: AppColors.primaryGreen),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: isPrimary ? Colors.white : AppColors.primaryGreen),
        ),
      ),
    );
  }
}
