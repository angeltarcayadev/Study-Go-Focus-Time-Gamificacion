import 'package:flutter/material.dart';
import 'package:study_go/pages/habit_tracker_grid_page.dart';
import 'dart:math';

class EstadisticasPage extends StatefulWidget {
  final VoidCallback? onBackToFocus;

  const EstadisticasPage({super.key, this.onBackToFocus});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  int productividadPage = 0; // 0 o 1
  int horasTab = 1; // 0 día, 1 semana, 2 mes
  int historialTab = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text(
          "Estadísticas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PRODUCTIVIDAD
            _statsCard(
              title: "Productividad",
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _fakeGrid(
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14171F),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGrid(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Paginador
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            productividadPage = 0;
                          });
                        },
                      ),
                      Text(
                        "${productividadPage + 1}/2",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            productividadPage = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // RACHA ACTUAL
            _statsCard(
              title: "Racha actual",
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    "0 días de racha",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // HORAS POR MATERIA
            _statsCard(
              title: "Horas por materia",
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _tabs(
                    index: horasTab,
                    labels: const ["Día", "Semana", "Mes"],
                    onChanged: (i) {
                      setState(() => horasTab = i);
                    },
                  ),
                  const SizedBox(height: 16),
                  _fakeBarChart(),
                  const SizedBox(height: 14),
                  const Text(
                    "No hay datos de materias",
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // HISTORIAL SESIONES
            _statsCard(
              title: "Historial de sesiones",
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _tabs(
                    index: historialTab,
                    labels: const ["Día", "Semana", "Mes"],
                    onChanged: (i) {
                      setState(() => historialTab = i);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.access_time_filled_rounded,
                      color: Colors.amber, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "No se encontraron sesiones de estudio",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Completa una sesión para ver tu historial",
                    style: TextStyle(color: Colors.white38),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // CARD BASE
  Widget _statsCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF11131B),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withValues(alpha: 0.05),
              blurRadius: 12,
              spreadRadius: 1),
        ],
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4AAEFF),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // TABS
  Widget _tabs({
    required int index,
    required List<String> labels,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1118),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(
          labels.length,
              (i) {
            final bool isSelected = i == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A8CFF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid() {
    Map<DateTime, int> commits = {};
    final random = Random();
    final today = DateTime.now();

    for (int i = 0; i <= 365; i++) {
      commits[today.subtract(Duration(days: i))] = random.nextInt(15);
    }

    // Pasamos productividadPage al gráfico
    return GitHubContributionGraph(
      contributions: commits,
      pageIndex: productividadPage, // 0 o 1 según el botón
    );
  }

  // BAR CHART FAKE
  Widget _fakeBarChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (_) {
        return Container(
          width: 16,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  Widget _fakeGrid(Widget child) => child;
}