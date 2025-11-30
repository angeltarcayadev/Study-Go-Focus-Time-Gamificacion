import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';
import 'dart:async';
import 'dart:math' as math; // Importar para math.pi
import 'package:study_go/pages/login_page.dart';
import 'package:study_go/services/auth_service.dart';

// CLASE PARA DIBUJAR EL LOGO REDISEÑADO
class StudyGoLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double animationValue;

  StudyGoLogoPainter(this.primaryColor, this.accentColor, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.2);

    // Escala general para un efecto de pulso o respiración
    final double scale = 0.8 + 0.1 * math.sin(animationValue * math.pi); // Pulso más suave
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    // --- Libro Abierto Estilizado ---
    final bookHeight = size.height * 0.4;
    final bookWidth = size.width * 0.7;

    final bookBaseY = center.dy + bookHeight * 0.3;

    // Lomo del libro
    paint.color = primaryColor.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, bookBaseY), width: bookWidth * 0.8, height: bookHeight * 0.2),
        const Radius.circular(5),
      ),
      paint,
    );

    // Páginas izquierda
    final pathLeftPage = Path()
      ..moveTo(center.dx - bookWidth * 0.4, bookBaseY)
      ..lineTo(center.dx - bookWidth * 0.1, bookBaseY - bookHeight * 0.3)
      ..lineTo(center.dx, bookBaseY - bookHeight * 0.4) // Pico central
      ..lineTo(center.dx - bookWidth * 0.1, bookBaseY + bookHeight * 0.1) // Parte inferior
      ..close();
    paint.color = primaryColor;
    canvas.drawPath(pathLeftPage, paint);

    // Páginas derecha
    final pathRightPage = Path()
      ..moveTo(center.dx + bookWidth * 0.4, bookBaseY)
      ..lineTo(center.dx + bookWidth * 0.1, bookBaseY - bookHeight * 0.3)
      ..lineTo(center.dx, bookBaseY - bookHeight * 0.4) // Pico central
      ..lineTo(center.dx + bookWidth * 0.1, bookBaseY + bookHeight * 0.1) // Parte inferior
      ..close();
    paint.color = primaryColor.withOpacity(0.95);
    canvas.drawPath(pathRightPage, paint);

    // --- Elementos de Progreso / Diamantes Ascendentes ---
    final double diamondSize = size.width * 0.1;
    final double initialY = bookBaseY - bookHeight * 0.3;

    // Primer diamante (base, brillando)
    paint.color = accentColor;
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * animationValue + 5); // Efecto glow dinámico
    _drawDiamond(canvas, center.dx, initialY - diamondSize * 0.5, diamondSize, paint);

    // Segundo diamante
    paint.color = accentColor.withOpacity(0.8);
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * (1 - animationValue) + 3);
    _drawDiamond(canvas, center.dx + diamondSize * 0.8, initialY - diamondSize * 1.8, diamondSize * 0.8, paint);

    // Tercer diamante (más pequeño, más arriba)
    paint.color = accentColor.withOpacity(0.6);
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * animationValue + 2);
    _drawDiamond(canvas, center.dx + diamondSize * 1.6, initialY - diamondSize * 3.0, diamondSize * 0.6, paint);


    // --- Onda de Progreso (Swoosh) ---
    paint.color = accentColor.withOpacity(0.8);
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 12);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;

    final pathSwoosh = Path();
    pathSwoosh.moveTo(center.dx - bookWidth * 0.2, bookBaseY - bookHeight * 0.1);
    pathSwoosh.quadraticBezierTo(
      center.dx + bookWidth * 0.2, bookBaseY - bookHeight * 0.7, // Punto de control
      center.dx + bookWidth * 0.7, bookBaseY - bookHeight * 0.9, // Punto final
    );
    canvas.drawPath(pathSwoosh, paint);

    canvas.restore();
  }

  // Función auxiliar para dibujar un diamante
  void _drawDiamond(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path()
      ..moveTo(x, y - size / 2) // Top point
      ..lineTo(x + size / 2, y) // Right point
      ..lineTo(x, y + size / 2) // Bottom point
      ..lineTo(x - size / 2, y) // Left point
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Redibujar si el valor de la animación ha cambiado para efectos dinámicos
    return true;
  }
}


class SplashScreen extends StatefulWidget {
  final AuthService authService;

  const SplashScreen({super.key, required this.authService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _logoAnimation; // Para el pulso y glow del logo

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000), // Duración total de la animación de entrada
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Animación de logo para pulso y brillo, se repite para el efecto continuo
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut), // Se anima durante toda la duración
      ),
    );

    _controller.repeat(reverse: true); // Para que el logo pulse continuamente

    // Navegar después de 3.5 segundos (tiempo para ver la animación)
    Timer(const Duration(milliseconds: 5000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(authService: widget.authService),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: AnimatedBuilder(
          animation: _logoAnimation, // Escucha la animación del logo
          builder: (context, child) {
            return FadeTransition(
              opacity: _opacityAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nuevo Logo Dibujado
                  SizedBox(
                    width: 200, // Tamaño más grande para el nuevo logo
                    height: 200,
                    child: CustomPaint(
                      painter: StudyGoLogoPainter(
                        AppColors.primary,
                        AppColors.secondary,
                        _logoAnimation.value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nombre de la App
                  const Text(
                    'STUDY GO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40, // Fuente un poco más grande
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8, // Más espaciado para impacto
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtítulo
                  Text(
                    'Focus. Achieve. Unlock.',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 20, // Fuente un poco más grande
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}