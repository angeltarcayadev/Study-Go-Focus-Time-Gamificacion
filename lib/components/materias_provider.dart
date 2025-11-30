import 'package:flutter/material.dart';

class MateriasProvider extends ChangeNotifier {
  final List<String> _materias = [];

  List<String> get materias => _materias;

  void agregarMateria(String materia) {
    _materias.add(materia);
    notifyListeners();
  }
}