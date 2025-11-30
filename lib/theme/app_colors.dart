import 'package:flutter/material.dart';

class AppColors {
  // Fondo principal oscuro
  static const Color bgDark = Color(0xFF121212);

  // Azul principal (equivalente a tu #4a90e2)
  static const Color blue = Color(0xFF4A90E2);

  // Alias ampliamente usados en UI
  static const Color primary = blue;
  static const Color secondary = Color(0xFF73C0F7);

  // Blanco tenue para textos secundarios
  static const Color lightText = Color(0xFFBDBDBD);

  // Gris para contenedores o bordes
  static const Color grey = Color(0xFF2C2C2C);

  // Rojo para botones de reinicio o alertas
  static const Color red = Color(0xFFE53935);

  static Color? get bgSecondary => null;
}
