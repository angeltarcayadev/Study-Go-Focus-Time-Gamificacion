import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';
import 'dart:math' as math;

// Convertimos a StatefulWidget para manejar el offset de arrastre.
class EpicStudyCardPage extends StatefulWidget {
  final String userName;
  final int currentStreak;
  final int totalMinutes;
  final String cardLevel;

  const EpicStudyCardPage({
    super.key,
    required this.userName,
    required this.currentStreak,
    required this.totalMinutes,
    this.cardLevel = 'LEGENDARY',
  });

  @override
  State<EpicStudyCardPage> createState() => _EpicStudyCardPageState();
}

class _EpicStudyCardPageState extends State<EpicStudyCardPage> {
  // Estado para manejar la rotación 3D
  double _rotationX = 0; // Rotación alrededor del eje X (inclinación vertical)
  double _rotationY = 0; // Rotación alrededor del eje Y (inclinación horizontal)

  // Limite máximo de rotación (en radianes)
  static const double _maxRotation = 0.3; // Aproximadamente 17 grados

  // Helper para formato de horas
  String get totalHoursFormatted {
    final hours = widget.totalMinutes ~/ 60;
    final minutes = widget.totalMinutes % 60;
    return "${hours}h ${minutes}m";
  }

  static const List<Color> _holographicGradient = [
    Color(0xFFff60a4), // Pink
    Color(0xFFffc39d), // Peach
    Color(0xFFb38cff), // Violet
    Color(0xFF9dfffe), // Cyan
    Color(0xFF63ff9e), // Green
    Color(0xFFffdd58), // Yellow
  ];

  // Función que calcula la rotación basada en la posición del puntero
  void _handlePanUpdate(DragUpdateDetails details, Size cardSize) {
    // Rotación X (vertical) es controlada por el movimiento Y
    double deltaY = details.delta.dy;
    // Rotación Y (horizontal) es controlada por el movimiento X
    double deltaX = details.delta.dx;

    // Ajustamos la sensibilidad de rotación
    const double sensitivity = 0.005;

    setState(() {
      // Movimiento vertical (deltaY) causa rotación horizontal (_rotationX).
      // Lo invertimos para simular el efecto de la mano levantando el borde.
      _rotationX = (_rotationX - deltaY * sensitivity).clamp(-_maxRotation, _maxRotation);

      // Movimiento horizontal (deltaX) causa rotación vertical (_rotationY).
      _rotationY = (_rotationY + deltaX * sensitivity).clamp(-_maxRotation, _maxRotation);
    });
  }

  // Regresa la tarjeta a su estado original con una animación
  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _rotationX = 0;
      _rotationY = 0;
    });
  }

  // Widget para el cuerpo de la tarjeta
  Widget _buildCardBody(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: _holographicGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _holographicGradient.last.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title, level, and name
          Column(
            children: [
              const Text(
                "EPIC STUDY CARD",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              // Level (LEGENDARY)
              Text(
                widget.cardLevel.toUpperCase(),
                style: TextStyle(
                  color: Colors.yellow[700],
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // User name
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Stats (Streak and Hours)
          Column(
            children: [
              _statRow(
                iconColor: Colors.orange,
                label: "Current Streak",
                value: "${widget.currentStreak}",
                unit: "days",
              ),
              const SizedBox(height: 30),
              _statRow(
                iconColor: Colors.green,
                label: "Total Hours",
                value: totalHoursFormatted,
                unit: "m",
              ),
            ],
          ),

          // Graphic placeholder
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.star, color: Colors.yellow[700], size: 30),
          )
        ],
      ),
    );
  }

  Widget _statRow({
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Stat Icon Circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: iconColor, width: 2),
            color: Colors.white.withOpacity(0.2),
          ),
          child: Center(
            child: Icon(
              label.contains('Streak') ? Icons.local_fire_department : Icons.access_time_filled,
              color: iconColor,
              size: 28,
            ),
          ),
        ),

        // Stat Text
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (unit == 'days')
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el tamaño de la tarjeta para usarlo en el cálculo de PanUpdate
    final cardSize = Size(
      MediaQuery.of(context).size.width * 0.85,
      MediaQuery.of(context).size.height * 0.65,
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Tarjeta Rotable (envuelta en Center)
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1), // Animación de duración
              duration: const Duration(milliseconds: 150), // Suaviza la transición al centro
              builder: (context, value, child) {
                // Aplicamos las rotaciones 3D
                return Transform(
                  // Perspectiva para la ilusión 3D
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                  // Rotación vertical (alrededor de X)
                    ..rotateX(_rotationX * value)
                  // Rotación horizontal (alrededor de Y)
                    ..rotateY(_rotationY * value),
                  alignment: FractionalOffset.center,
                  child: child!,
                );
              },
              // El niño del TweenAnimationBuilder es el GestureDetector
              child: GestureDetector(
                onPanUpdate: (details) => _handlePanUpdate(details, cardSize),
                onPanEnd: _handlePanEnd,
                child: _buildCardBody(context),
              ),
            ),
          ),

          // Botón de cerrar/navegación superior
          Positioned(
            top: 40,
            left: 10,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cerrar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}