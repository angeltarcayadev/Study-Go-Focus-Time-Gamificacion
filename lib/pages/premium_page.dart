import 'package:flutter/material.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Cube IA Premium",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- HEADER ----------------
            _header(),

            const SizedBox(height: 20),

            // ---------------- COMPARACIÓN FREE / PREMIUM ----------------
            _comparisonCard(),

            const SizedBox(height: 20),

            // ---------------- BENEFICIOS PREMIUM ----------------
            _title("Beneficios Premium"),
            const SizedBox(height: 12),
            _benefit(Icons.auto_awesome, "Planificación Inteligente IA"),
            _benefit(Icons.timeline_rounded, "Reorganización automática de horarios"),
            _benefit(Icons.menu_book, "Planes de estudio personalizados"),
            _benefit(Icons.stacked_bar_chart, "Análisis de progreso avanzado"),
            _benefit(Icons.lock_open, "Acceso ilimitado a todas las funciones"),

            const SizedBox(height: 28),

            // ---------------- PLANES ----------------
            _title("Elige tu Plan"),
            const SizedBox(height: 12),
            _planCard(
              titulo: "Mensual",
              precio: "\$2.200 ARS",
              descripcion: "Acceso completo por 30 días",
            ),
            const SizedBox(height: 14),
            _planCard(
              titulo: "Semestral",
              precio: "\$10.500 ARS",
              descripcion: "Ahorra un 20%",
              destacado: true,
            ),
            const SizedBox(height: 14),
            _planCard(
              titulo: "Anual",
              precio: "\$19.900 ARS",
              descripcion: "Mejor precio — Ahorra un 35%",
            ),

            const SizedBox(height: 34),

            // ---------------- BOTÓN FINAL ----------------
            _buyButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B4A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 38),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Desbloquea el poder de Cube IA",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  // COMPARACIÓN FREE VS PREMIUM
  // ============================================================
  Widget _comparisonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Comparación"),
          const SizedBox(height: 14),
          _comparisonRow("Planificación manual", true, false),
          _comparisonRow("Recordatorios", true, true),
          _comparisonRow("Planificación IA", false, true),
          _comparisonRow("Optimización completa", false, true),
          _comparisonRow("Estadísticas avanzadas", false, true),
        ],
      ),
    );
  }

  Widget _comparisonRow(String text, bool free, bool premium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.white70, fontSize: 14))),
          Icon(
            free ? Icons.check_circle : Icons.cancel,
            color: free ? Colors.greenAccent : Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 18),
          Icon(
            premium ? Icons.check_circle : Icons.cancel,
            color: premium ? Colors.greenAccent : Colors.redAccent,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO SECCIÓN
  // ============================================================
  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // BENEFICIO INDIVIDUAL
  // ============================================================
  Widget _benefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7F7FF3), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA DE PLAN
  // ============================================================
  Widget _planCard({
    required String titulo,
    required String precio,
    required String descripcion,
    bool destacado = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: destacado ? const Color(0xFF2B2B4A) : const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(18),
        border: destacado
            ? Border.all(color: const Color(0xFF6D6DFF), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            precio,
            style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  // ============================================================
  // BOTÓN DE COMPRA
  // ============================================================
  Widget _buyButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0DB663),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Text(
        "Comprar Premium",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}