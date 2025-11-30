import 'package:flutter/material.dart';
import 'package:study_go/services/auth_service.dart';
import 'package:study_go/theme/app_colors.dart';
import 'package:study_go/components/juegos_page.dart'; // Importamos los widgets auxiliares

// Definición de las recompensas (Mantenido aquí por simplicidad)
const List<Map<String, dynamic>> rewardsList = [
  {"name": "Cubo Cobre", "hours": 0, "color": Color(0xFFCD7F32), "description": "Has comenzado tu viaje hacia la excelencia."},
  {"name": "Cubo Plata", "hours": 5, "color": Color(0xFFC0C0C0), "description": "Tu concentración está mejorando constante..."},
  {"name": "Cubo Oro", "hours": 15, "color": Color(0xFFFFD700), "description": "Eres un maestro del enfoque."},
  {"name": "Cubo Diamante", "hours": 40, "color": Color(0xFF1ABC9C), "description": "Concentración de élite. ¡Imparable!"},
];


class GamesScreen extends StatelessWidget {
  final AuthService authService;
  final String username;

  const GamesScreen({
    super.key,
    required this.authService,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return CaminoDeLogrosScreen(
      authService: authService,
      username: username,
      rewards: rewardsList,
    );
  }
}

// ====================
// CaminoDeLogrosScreen (Implementación real de la UI)
// ====================
class CaminoDeLogrosScreen extends StatefulWidget {
  final AuthService authService;
  final String username;
  final List<Map<String, dynamic>> rewards;

  const CaminoDeLogrosScreen({
    super.key,
    required this.authService,
    required this.username,
    required this.rewards,
  });

  @override
  State<CaminoDeLogrosScreen> createState() => _CaminoDeLogrosScreenState();
}

class _CaminoDeLogrosScreenState extends State<CaminoDeLogrosScreen> {
  bool _isLoading = true;
  int totalHoursStudied = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final leaderboard = await widget.authService.getLeaderboard();
      final currentUserData = leaderboard.firstWhere(
            (user) => user['username'] == widget.username,
        orElse: () => {"totalMinutes": 0},
      );

      setState(() {
        // Obtenemos las horas totales del AuthService
        totalHoursStudied = (currentUserData['totalMinutes'] ?? 0) ~/ 60;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading cube stats: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text("Camino de Logros", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.bgDark,
              pinned: true,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(30.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "¡Estudia más para desbloquear todos los cubos! (Total: ${totalHoursStudied}h)",
                    style: TextStyle(color: AppColors.lightText, fontSize: 16),
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final reward = widget.rewards[index];
                  final bool isUnlocked = totalHoursStudied >= reward['hours'];
                  final bool isCurrentReward = !isUnlocked && index > 0 && totalHoursStudied < reward['hours'];

                  return _buildRewardStep(
                    index: index,
                    reward: reward,
                    isUnlocked: isUnlocked,
                    isCurrentReward: isCurrentReward,
                    isLast: index == widget.rewards.length - 1,
                  );
                },
                childCount: widget.rewards.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardStep({
    required int index,
    required Map<String, dynamic> reward,
    required bool isUnlocked,
    required bool isCurrentReward,
    required bool isLast,
  }) {
    final Color lineColor = isUnlocked ? AppColors.primary : AppColors.grey;
    final Color dotColor = isUnlocked ? AppColors.primary : AppColors.lightText;

    final int previousHours = index > 0 ? widget.rewards[index - 1]['hours'] : 0;
    final int hoursToNext = reward['hours'] - previousHours;
    final double currentProgress = (totalHoursStudied - previousHours).clamp(0, hoursToNext).toDouble();
    final double progressFraction = hoursToNext > 0 ? currentProgress / hoursToNext : 1.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LÍNEA DE TIEMPO VERTICAL Y DOT
          SizedBox(
            width: 80,
            child: Column(
              children: [
                // Línea superior (si no es el primer elemento)
                Expanded(
                  child: index == 0 ? Container() : buildDottedLine(lineColor), // Usando auxiliar
                ),

                // DOT / Indicador
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.bgDark,
                      width: 4,
                    ),
                    boxShadow: [
                      if (isUnlocked)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 5,
                        )
                    ],
                  ),
                ),

                // Línea inferior (si no es el último elemento)
                Expanded(
                  child: isLast ? Container() : buildDottedLine(lineColor), // Usando auxiliar
                ),
              ],
            ),
          ),

          // CONTENIDO DEL CUBO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, right: 16),
              child: buildRewardCard( // Usando auxiliar
                reward: reward,
                isUnlocked: isUnlocked,
                isCurrentReward: isCurrentReward,
                hoursToNext: hoursToNext,
                currentProgress: currentProgress,
                progressFraction: progressFraction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}