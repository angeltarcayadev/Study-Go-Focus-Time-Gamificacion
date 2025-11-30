import 'package:flutter/material.dart';

class EdgePanel extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Widget child;

  const EdgePanel({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Altura responsive del panel
    final double panelHeight = size.height * 0.88;
    final double panelTop = (size.height - panelHeight) / 2;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      left: isOpen ? 0 : -260,
      top: panelTop,
      height: panelHeight,
      width: 260,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF11131B),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(35),
                blurRadius: 25,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 🔥 Raya del panel con control total
              Positioned(
                left: 0,

                // Ajustá libremente:
                top: panelHeight * 0.2,  // mueve hacia abajo (0.0 a 1.0)
                //bottom: 40,            // si querés bajarla más
                //top: 0, bottom: 0,     // si querés que quede centrada

                child: Container(
                  width: 5,
                  height: panelHeight * 0.30,  // controla la altura de la rayita
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Contenido scrollable del panel
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 18,
                ),
                child: child,
              ),

              // Botón cerrar
              Positioned(
                right: 0,
                top: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70,
                  ),
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}