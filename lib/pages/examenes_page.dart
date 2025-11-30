import 'package:flutter/material.dart';
import 'package:study_go/pages/plan_page.dart';
import 'package:study_go/pages/premium_page.dart';

class ExamenesPage extends StatefulWidget {
  const ExamenesPage({super.key, onBackToFocus});

  @override
  State<ExamenesPage> createState() => _ExamenesPageState();
}

class _ExamenesPageState extends State<ExamenesPage> {
  final List<Map<String, dynamic>> examenes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F12),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Planificador de Exámenes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0DB663),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
        onPressed: () => _showAddExamModal(context),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IaCard(),
            const SizedBox(height: 22),

            const _SectionTitle("Próximos Exámenes"),
            const SizedBox(height: 10),

            examenes.isEmpty
                ? const _EmptyCard()
                : const SizedBox.shrink(),

            const SizedBox(height: 25),
            _HeaderWithBadge(title: "Mis Exámenes", number: examenes.length.toString()),
            const SizedBox(height: 14),

            if (examenes.isEmpty)
              const _WarningCard(),

            const SizedBox(height: 16),

            ...examenes.map((ex) => _ExamCard(
              titulo: ex["titulo"],
              materia: ex["materia"],
              diasRestantes: ex["dias"],
              dificultad: ex["dificultad"],
            )),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MODAL PARA AGREGAR EXAMEN
  // ============================================================

  void _showAddExamModal(BuildContext context) {
    String titulo = "";
    String materia = "";
    DateTime? fecha;
    String dificultad = "Media";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            minChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1C22),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(Icons.horizontal_rule,
                            color: Colors.white24, size: 32),
                      ),

                      const Text(
                        "Agregar Examen",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _modalInput(
                        "Título del examen",
                        Icons.book,
                        onChanged: (v) => titulo = v,
                      ),

                      const SizedBox(height: 14),

                      _modalInput(
                        "Materia",
                        Icons.school,
                        onChanged: (v) => materia = v,
                      ),

                      const SizedBox(height: 14),

                      // FECHA CON DATE PICKER
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF0DB663),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            setModalState(() => fecha = picked);
                          }
                        },
                        child: _modalInputStatic(
                          fecha == null
                              ? "Elegir fecha"
                              : "${fecha!.day}/${fecha!.month}/${fecha!.year}",
                          Icons.calendar_today,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // DROPDOWN DIFICULTAD
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E0F12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.white54),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: const Color(0xFF1A1C22),
                                  value: dificultad,
                                  icon:
                                  const Icon(Icons.arrow_drop_down, color: Colors.white70),
                                  style: const TextStyle(color: Colors.white),
                                  onChanged: (v) =>
                                      setModalState(() => dificultad = v!),
                                  items: const [
                                    DropdownMenuItem(
                                        value: "Fácil",
                                        child: Text("Fácil",
                                            style: TextStyle(color: Colors.white))),
                                    DropdownMenuItem(
                                        value: "Media",
                                        child: Text("Media",
                                            style: TextStyle(color: Colors.white))),
                                    DropdownMenuItem(
                                        value: "Difícil",
                                        child: Text("Difícil",
                                            style: TextStyle(color: Colors.white))),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      GestureDetector(
                        onTap: () {
                          if (titulo.isEmpty || materia.isEmpty || fecha == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text("Completa todos los campos."),
                              ),
                            );
                            return;
                          }

                          final diasRestantes =
                              fecha!.difference(DateTime.now()).inDays;

                          setState(() {
                            examenes.add({
                              "titulo": titulo,
                              "materia": materia,
                              "fecha": fecha,
                              "dias": diasRestantes,
                              "dificultad": dificultad,
                            });
                          });

                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0DB663),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Guardar Examen",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  //
  // --------------- INPUTS DEL MODAL -----------------
  //

  Widget _modalInput(String label, IconData icon,
      {required Function(String) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _modalInputStatic(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ============================================================
// WIDGETS DE LA PÁGINA PRINCIPAL
// ============================================================
//

class _IaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1D29),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Planificador con Cube IA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Optimización avanzada con planificación inteligente.",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5959E8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HeaderWithBadge extends StatelessWidget {
  final String title;
  final String number;

  const _HeaderWithBadge({required this.title, required this.number});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(title)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0DB663),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        )
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_month, color: Colors.white70, size: 34),
          SizedBox(height: 12),
          Text(
            "No hay exámenes registrados",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            "Agrega un examen para comenzar.",
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8A73E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.black87),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Replanificación Completa\n\n"
                  "Si usas Cube IA, tu planificación actual se reiniciará "
                  "para generar un nuevo calendario optimizado.",
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String titulo;
  final String materia;
  final int diasRestantes;
  final String dificultad;

  const _ExamCard({
    required this.titulo,
    required this.materia,
    required this.diasRestantes,
    required this.dificultad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "$diasRestantes días",
                style: const TextStyle(
                    color: Colors.greenAccent, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            materia,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.sentiment_neutral,
                  color: Colors.orange, size: 22),
              const SizedBox(width: 8),
              Text(
                "No he empezado",
                style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 18),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlanPage(
                    titulo: titulo,
                    materia: materia,
                    diasRestantes: diasRestantes,
                    dificultad: dificultad,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0DB663),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Ver Plan",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
