import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';
import 'package:study_go/services/auth_service.dart';

class LeaderboardPage extends StatelessWidget {
  final AuthService authService;
  final String username;
  final List<Map<String, dynamic>> currentLeaderboard;
  final bool isLoading;

  const LeaderboardPage({
    super.key,
    required this.authService,
    required this.username,
    required this.currentLeaderboard,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text("Clasificación Global", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: currentLeaderboard.length,
        itemBuilder: (context, index) {
          final user = currentLeaderboard[index];
          return _buildLeaderboardRow(
            rank: user['rank'] ?? index + 1,
            name: user['username'] ?? "Desconocido",
            days: user['streak'] ?? 0,
            isUser: user['username'] == username,
            totalMinutes: user['totalMinutes'] ?? 0,
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardRow({
    required int rank,
    required String name,
    required int days,
    required bool isUser,
    required int totalMinutes,
  }) {
    IconData icon;
    Color iconColor;

    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        iconColor = const Color(0xFFFFD700);
        break;
      case 2:
        icon = Icons.star;
        iconColor = const Color(0xFFC0C0C0);
        break;
      case 3:
        icon = Icons.military_tech;
        iconColor = const Color(0xFFCD7F32);
        break;
      default:
        icon = Icons.circle;
        iconColor = AppColors.lightText.withOpacity(0.12);
    }

    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final String timeFormatted = "${(totalMinutes / 60).floor()}h ${totalMinutes % 60}m";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary.withOpacity(0.2) : AppColors.grey,
        borderRadius: BorderRadius.circular(14),
        border: isUser ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: rank <= 3
                ? Icon(icon, color: iconColor, size: 24)
                : Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.5), child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 16))),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: isUser ? Colors.white : AppColors.lightText, fontWeight: isUser ? FontWeight.bold : FontWeight.normal, fontSize: 16),
                ),
                Text(
                  "Tiempo total: $timeFormatted",
                  style: const TextStyle(color: AppColors.lightText, fontSize: 12),
                ),
              ],
            ),
          ),

          // Racha
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUser ? Colors.amber[800] : Colors.deepPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("$days days", style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}