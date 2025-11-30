import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  // Añadidos campos para coherencia con LoginPage moderna
  final IconData? icon;
  final TextInputType keyboardType;

  const MyTextField ({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.icon, // Opcional
    this.keyboardType = TextInputType.text, required bool e, required bool enabled, required bool enablednabled, // Por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType, // Uso del keyboardType
        style: const TextStyle(color: Colors.white), // Texto escrito en blanco
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            // Fondo de campo en gris oscuro
            borderSide: BorderSide(color: AppColors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            // Borde enfocado en el color primario
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: AppColors.grey, // Fondo del campo en gris oscuro
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.lightText),
          // Uso del icono
          prefixIcon: icon != null ? Icon(icon, color: AppColors.lightText) : null,
          // Añadimos el icono de ojo si es un campo de contraseña
          suffixIcon: obscureText
              ? IconButton(
            icon: const Icon(Icons.remove_red_eye, color: AppColors.lightText),
            onPressed: () {
              // Nota: Para cambiar el estado de obscureText se necesitaría un StatefulWidget.
              // Aquí solo indicamos la intención visual.
            },
          )
              : null,
        ),
      ),
    );
  }
}