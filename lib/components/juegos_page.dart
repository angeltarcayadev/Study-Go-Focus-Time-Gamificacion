import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';
import 'dart:math' as math;

// Widget que dibuja la línea punteada para la línea de tiempo
Widget buildDottedLine(Color color) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate((constraints.maxHeight / 5).floor(), (_) {
          return const SizedBox(
            width: 2,
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          );
        }),
      );
    },
  );
}

// Widget que construye la tarjeta de recompensa individual
Widget buildRewardCard({
  required Map<String, dynamic> reward,
  required bool isUnlocked,
  required bool isCurrentReward,
  required int hoursToNext,
  required double currentProgress,
  required double progressFraction,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.grey.withOpacity(isUnlocked ? 1.0 : 0.6),
      borderRadius: BorderRadius.circular(16),
      border: isUnlocked ? Border.all(color: reward['color'], width: 1.5) : null,
    ),
    child: Row(
      children: [
        // Ícono del Cubo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isUnlocked ? reward['color'].withOpacity(0.8) : Colors.black54,
                blurRadius: isUnlocked ? 10 : 3,
              )
            ],
          ),
          child: Center(
            child: Icon(
              isUnlocked ? Icons.ac_unit_rounded : Icons.lock_outline,
              color: isUnlocked ? reward['color'] : AppColors.lightText,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 15),

        // Texto y Progreso
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reward['name'],
                style: TextStyle(
                  color: isUnlocked ? Colors.white : AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                reward['description'],
                style: TextStyle(color: AppColors.lightText, fontSize: 13),
              ),
              const SizedBox(height: 8),

              // BARRA DE PROGRESO INLINE
              if (isCurrentReward)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${currentProgress.toInt()}h / ${hoursToNext}h para el siguiente nivel",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        backgroundColor: AppColors.bgDark,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  isUnlocked ? "¡Desbloqueado!" : "${reward['hours']}h requeridas",
                  style: TextStyle(
                    color: isUnlocked ? Colors.greenAccent : AppColors.lightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}