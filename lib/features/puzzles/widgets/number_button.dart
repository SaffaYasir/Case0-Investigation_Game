import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onPressed;
  final double size;
  final bool isActive;

  const NumberButton({
    super.key,
    required this.number,
    required this.onPressed,
    this.size = 70,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onPressed : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.darkGray : AppColors.darkGray.withOpacity(0.5),
          border: Border.all(
            color: isActive ? AppColors.neonRed : AppColors.neonRed.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: AppColors.neonRed.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ]
              : [],
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.neonRed : AppColors.neonRed.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}