import 'package:flutter/material.dart';
import 'package:study_go/pages/premium_page.dart';

class PlanPage extends StatelessWidget {
  final String titulo;
  final String materia;
  final int diasRestantes;
  final String dificultad;

  const PlanPage({
    super.key,
    required this.titulo,
    required this.materia,
    required this.diasRestantes,
    required this.dificultad,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F12),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _header(),

            const SizedBox(height: 28),

            _sectionTitle("Plan Básico"),
            const SizedBox(height: 10),
            _planGratis(),

            const SizedBox(height: 32),

            _sectionTitle("Plan Inteligente con Cube IA"),
            const SizedBox(height: 10),
            _planPremium(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // TITULO DE SECCIÓN
  // ----------------------------------------------------------------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ----------------------------------------------------------------------
  // ENCABEZADO — INFO DEL EXAMEN
  // ----------------------------------------------------------------------
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerText("Materia:", materia),
          const SizedBox(height: 6),
          _headerText("Dificultad:", dificultad),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text("Días restantes: ",
                  style: TextStyle(color: Colors.white70)),
              Text(
                "$diasRestantes",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerText(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // PLAN GRATIS
  // ----------------------------------------------------------------------
  Widget _planGratis() {
    return Column(
      children: [
        _freeCard("Día 1 – Introducción y conceptos clave"),
        _freeCard("Día 2 – Ejercicios nivel básico"),
        _freeCard("Día 3 – Ejercicios nivel medio"),
      ],
    );
  }

  Widget _freeCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // PLAN PREMIUM — BLOQUEADO
  // ----------------------------------------------------------------------
  Widget _planPremium(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF282A36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Disponible con Cube IA",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 16),

          const Text(
            "• Distribución óptima según tu rendimiento\n"
                "• Replanificación automática si fallas un día\n"
                "• Detección de temas débiles\n"
                "• Calendario inteligente adaptativo\n"
                "• Ajuste diario según tu avance",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Desbloquear con Cube IA",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}