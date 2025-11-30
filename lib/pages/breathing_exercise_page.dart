import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';
import 'package:study_go/services/auth_service.dart'; // Importamos el AuthService

class BreathingExercisePage extends StatefulWidget {
  final AuthService authService;
  final String userId;

  const BreathingExercisePage({
    super.key,
    required this.authService,
    required this.userId,
  });

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String _instruction = "Presiona para comenzar";
  int _cyclesCompleted = 0;
  DateTime? _startTime;

  static const Duration _cycleDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _cycleDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
        _cyclesCompleted++;
      }
      _updateInstruction();
    });
  }

  // Detiene la animación y pone la instrucción de inicio
  void _resetExercise() {
    _registerActivity();

    _controller.stop();
    _controller.reset();
    setState(() {
      _instruction = "Presiona para comenzar";
    });
  }

  void _startStopExercise() {
    // Si la animación está corriendo o terminada, la reseteamos y registramos
    if (_controller.isAnimating || _controller.status == AnimationStatus.completed) {
      _resetExercise();
    } else {
      // Si está detenida, la iniciamos
      _startTime = DateTime.now();
      _cyclesCompleted = 0;
      _controller.forward();
      _updateInstruction();
    }
  }

  void _updateInstruction() {
    String newInstruction;
    // Verificamos el estado para saber si va IN (forward) o OUT (reverse)
    if (_controller.isAnimating) {
      if (_controller.status == AnimationStatus.forward) {
        newInstruction = "Inhala (2s)";
      } else {
        newInstruction = "Exhala (2s)";
      }
    } else {
      newInstruction = "Presiona para comenzar";
    }
    setState(() {
      _instruction = newInstruction;
    });
  }

  // Lógica de registro con AuthService
  void _registerActivity() {
    if (_startTime != null && _cyclesCompleted > 0) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);

      // Llamada al AuthService REAL
      // Asumimos que AuthService tiene un método logActivity
      widget.authService.logActivity(
        widget.userId,
        'Relajación',
        duration.inMinutes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesión de ${duration.inSeconds}s registrada y sincronizada.'),
          backgroundColor: AppColors.primary,
        ),
      );

      _startTime = null;
      _cyclesCompleted = 0;
    }
  }


  @override
  void dispose() {
    if (_controller.isAnimating) {
      _registerActivity();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8A2BE2), Color(0xFFff60a4), AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    _registerActivity();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Respira",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Vamos a respirar juntos para relajarnos",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _startStopExercise,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.air, color: Colors.white, size: 80),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Text(
                  _instruction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}