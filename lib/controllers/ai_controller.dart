import 'package:flutter/material.dart';

class AIController extends ChangeNotifier {
  bool _isPremium = false; // Cambiar a true para pruebas

  bool get isPremium => _isPremium;

  void activatePremium() {
    _isPremium = true;
    notifyListeners();
  }

  void deactivatePremium() {
    _isPremium = false;
    notifyListeners();
  }

  // Ejemplo de función IA a futuro
  Future<String> generateExam(String topic) async {
    if (!_isPremium) {
      return "Función disponible solo para usuarios Premium.";
    }

    await Future.delayed(const Duration(seconds: 1));

    return "Examen generado con IA para el tema: $topic";
  }
}