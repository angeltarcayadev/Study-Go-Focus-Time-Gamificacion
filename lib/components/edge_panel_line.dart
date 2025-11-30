import 'package:flutter/material.dart';

class EdgePanelLine extends StatelessWidget {
  final double heightFactor; // porcentaje de altura: 0.30 = 30%

  const EdgePanelLine({
    super.key,
    this.heightFactor = 0.30,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lineHeight = constraints.maxHeight * heightFactor;

        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 4,                    // grosor de la raya
            height: lineHeight,         // altura responsive
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}