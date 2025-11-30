import 'dart:math';
import 'package:flutter/material.dart';

class TimerKnob extends StatefulWidget {
  final double progress;
  final bool isDraggable;
  final ValueChanged<double>? onChanged;
  final double startAngle; // Ángulo inicial del preset

  const TimerKnob({
    super.key,
    required this.progress,
    this.isDraggable = false,
    this.onChanged,
    this.startAngle = -pi / 2,
  });

  @override
  State<TimerKnob> createState() => _TimerKnobState();
}

class _TimerKnobState extends State<TimerKnob>
    with SingleTickerProviderStateMixin {
  late double _progress;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TimerKnob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isDraggable) {
      _progress = widget.progress;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Offset _calculateKnobPosition(Size size, double radius) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Aquí el knob empieza desde startAngle
    final angle = widget.startAngle + 2 * pi * _progress;
    final x = cx + radius * cos(angle);
    final y = cy + radius * sin(angle);
    return Offset(x, y);
  }

  void _onPanUpdate(DragUpdateDetails details, Size size, double radius) {
    if (!widget.isDraggable) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final touchX = details.localPosition.dx;
    final touchY = details.localPosition.dy;

    double angle = atan2(touchY - cy, touchX - cx);
    if (angle < 0) angle += 2 * pi;

    // Convertimos ángulo en progreso relativo al startAngle
    double relativeAngle = (angle - widget.startAngle) % (2 * pi);
    setState(() => _progress = relativeAngle / (2 * pi));
    widget.onChanged?.call(_progress);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final double radius = size.shortestSide * 0.44;
        final knobPos = _calculateKnobPosition(size, radius);

        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, size, radius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size.shortestSide, size.shortestSide),
                painter: _CircularProgressPainter(
                  _progress,
                  radius,
                  startAngle: widget.startAngle, // ← importante
                ),
              ),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final scale = 1 + 0.05 * sin(_pulseController.value * 2 * pi);
                  return Positioned(
                    left: knobPos.dx - 20,
                    top: knobPos.dy - 20,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double startAngle;

  _CircularProgressPainter(this.progress, this.radius, {this.startAngle = -pi / 2});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4A90E2), Color(0xFF6BC1FF)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);

    final sweepAngle = 2 * pi * progress;
    // ← el arco ahora empieza desde startAngle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.startAngle != startAngle;
}
