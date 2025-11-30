import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';

class AddReasonModal extends StatefulWidget {
  const AddReasonModal({super.key});

  @override
  State<AddReasonModal> createState() => _AddReasonModalState();
}

class _AddReasonModalState extends State<AddReasonModal> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          // Fondo degradado para coincidir con la captura (púrpura/rosa/azul)
          gradient: LinearGradient(
            colors: [Colors.purple.withOpacity(0.8), AppColors.primary.withOpacity(0.6)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¿Por qué estudias?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Escribe una motivación personal que te inspire",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campo de texto (usando un diseño simple que simule MyTextField oscuro)
            TextField(
              controller: _textController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              maxLength: 60,
              decoration: InputDecoration(
                hintText: "Ej: Para conseguir el trabajo de mis sueños...",
                hintStyle: const TextStyle(color: AppColors.lightText),
                filled: true,
                fillColor: AppColors.grey.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Botón Agregar Razón
            ElevatedButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  // Devuelve la razón ingresada al Dashboard
                  Navigator.of(context).pop(_textController.text.trim());
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                "Agregar Razón",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}