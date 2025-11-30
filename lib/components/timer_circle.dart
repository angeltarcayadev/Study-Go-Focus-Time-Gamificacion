import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TimerCircle extends StatefulWidget {
  final int totalMinutes;
  final int remainingSeconds;
  final bool isRunning;
  final bool isFreeMode;
  final Function(int)? onFreeTimeChanged;

  const TimerCircle({
    super.key,
    required this.totalMinutes,
    required this.remainingSeconds,
    required this.isRunning,
    required this.isFreeMode,
    this.onFreeTimeChanged,
  });

  @override
  State<TimerCircle> createState() => _TimerCircleState();
}

class _TimerCircleState extends State<TimerCircle> {
  late double knobAngle;
  bool isDragging = false;
  late int _currentSeconds;
  Timer? _timer;

  final Map<int, Offset> presetKnobCoordinates = {
    25: const Offset(96.62, -25.80),
    50: const Offset(50.08, 86.56),
    90: const Offset(-100.0, -0.17),
    120: const Offset(0, -100),
  };

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.remainingSeconds;
    _updateKnobAngle();
    if (widget.isRunning) _startTimer();
  }

  @override
  void didUpdateWidget(covariant TimerCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isDragging) {
      _currentSeconds = widget.remainingSeconds;
      _updateKnobAngle();
    }

    if (widget.isRunning && _timer == null) {
      _startTimer();
    } else if (!widget.isRunning && _timer != null) {
      _stopTimer();
    }
  }

  void _updateKnobAngle() {
    double startAngle = -pi / 2;

    if (widget.isFreeMode && widget.totalMinutes == 120) {
      double progress = _currentSeconds / (widget.totalMinutes * 60);
      knobAngle = startAngle + 2 * pi * progress;
    } else {
      Offset offset = presetKnobCoordinates[widget.totalMinutes] ?? const Offset(0, -100);
      double presetAngle = atan2(offset.dy, offset.dx);
      double progress = _currentSeconds / (widget.totalMinutes * 60);
      knobAngle = presetAngle * progress + startAngle * (1 - progress);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
          _updateKnobAngle();
        });
        widget.onFreeTimeChanged?.call(_currentSeconds);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int displayedSeconds = (widget.isFreeMode &&
        widget.totalMinutes == 120 &&
        _currentSeconds == 0)
        ? widget.totalMinutes * 60
        : _currentSeconds;

    final String formattedTime =
        '${(displayedSeconds ~/ 60).toString().padLeft(2, "0")}:${(displayedSeconds % 60).toString().padLeft(2, "0")}';

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth * 0.8;
      final double strokeWidth = 16;
      final double radius = (size / 2 * 0.8) - (strokeWidth / 2) + 1;

      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _ProgressArcPainter(knobAngle, radius),
            ),

            // contenido central (emoji + minutos)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🧠',
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _ProgressArcPainter extends CustomPainter {
  final double knobAngle;
  final double radius;

  _ProgressArcPainter(this.knobAngle, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4A90E2), Color(0xFF6BC1FF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;

    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -pi / 2;
    double sweepAngle = knobAngle - startAngle;
    if (sweepAngle < 0) sweepAngle += 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) =>
      oldDelegate.knobAngle != knobAngle;
}