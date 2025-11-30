import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';

class MyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Color color;
  final bool isOutline;

  const MyButton({
    super.key,
    required this.onTap,
    this.text = 'Sign In',
    this.color = AppColors.primary,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(12),
          border: isOutline ? Border.all(color: color, width: 2) : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isOutline ? color : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}