import 'dart:math';
import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';
import 'package:study_go/components/add_reason_modal.dart';
import 'package:study_go/pages/breathing_exercise_page.dart';
import 'package:study_go/pages/epic_study_card_page.dart';
import 'package:study_go/services/auth_service.dart';
import 'package:study_go/pages/settings_page.dart';
// Importación de la nueva página de Leaderboard (creada en el paso 3)
import 'package:study_go/pages/leaderboard_page.dart';

class ProfileDashboardPage extends StatefulWidget {
  final VoidCallback? onBackToFocus;
  final String username;
  final AuthService authService;
  final Map<String, dynamic>? initialData;

  const ProfileDashboardPage({
    super.key,
    required this.username,
    required this.authService,
    this.onBackToFocus,
    this.initialData,
  });

  @override
  State<ProfileDashboardPage> createState() => _ProfileDashboardPageState();
}

class _ProfileDashboardPageState extends State<ProfileDashboardPage> {
  // Datos de Perfil (cargados del login)
  String profilePictureUrl = "";
  late int currentStreak;
  late int totalHours;
  late int totalMinutes;
  late List<String> studyReasons;
  late String memberSince;

  // Leaderboard
  List<Map<String, dynamic>> leaderboard = [];
  bool _isLoadingLeaderboard = true;

  // Control de la pestaña de Actividad de Estudio
  int _selectedActivityTab = 1;


  @override
  void initState() {
    super.initState();
    _initializeDynamicData();
    _fetchLeaderboard();
  }

  void _initializeDynamicData() {
    final data = widget.initialData ?? {};

    memberSince = data['memberSince'] ?? "01/01/2023";
    currentStreak = data['currentStreak'] ?? 1;
    totalHours = data['totalHours'] ?? 1;
    totalMinutes = data['totalMinutes'] ?? 60;
    studyReasons = List<String>.from(data['studyReasons'] ?? ["¡Configura tu motivación!"]);
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final results = await widget.authService.getLeaderboard();

      final updatedResults = results.map((user) {
        if (user['username'] == widget.username) {
          user['isUser'] = true;
        }
        return user;
      }).toList();

      setState(() {
        leaderboard = updatedResults;
        _isLoadingLeaderboard = false;
        final currentUserData = updatedResults.firstWhere(
              (user) => user['username'] == widget.username,
          orElse: () => {"streak": currentStreak, "totalMinutes": totalMinutes},
        );
        currentStreak = currentUserData['streak'] ?? currentStreak;
        totalMinutes = currentUserData['totalMinutes'] ?? totalMinutes;
      });
    } catch (e) {
      debugPrint("Error fetching leaderboard: $e");
      setState(() {
        _isLoadingLeaderboard = false;
        leaderboard = [
          {"name": widget.username, "days": currentStreak, "rank": 1, "isUser": true, "streak": currentStreak},
        ];
      });
    }
  }

  // ============== NUEVA LÓGICA DE NAVEGACIÓN Y MODAL ==============

  void _openPage(String pageName) {
    debugPrint("Navegando a: $pageName");

    if (pageName == "Función Respirar") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BreathingExercisePage(
            authService: widget.authService,
            userId: widget.username,
          ),
        ),
      );
    } else if (pageName == "Agregar Razón") {
      _showAddReasonModal();
    }
    else if (pageName == "Tarjeta Épica") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EpicStudyCardPage(
            userName: widget.username,
            currentStreak: currentStreak,
            totalMinutes: totalMinutes,
            cardLevel: 'LEGENDARY',
          ),
        ),
      );
    } else if (pageName == "Ajustes") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsPage(
            authService: widget.authService,
          ),
        ),
      );
    } else if (pageName == "Cambiar Foto") {
      // Muestra el modal con las opciones de foto
      _showPhotoOptionsModal();
    } else if (pageName == "Ver Leaderboard Completo") {
      // Implementación de la navegación al Leaderboard completo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderboardPage(
            authService: widget.authService,
            username: widget.username,
            currentLeaderboard: leaderboard, // Pasamos el leaderboard actual
            isLoading: _isLoadingLeaderboard,
          ),
        ),
      );
    }
  }

  // Modal para cambiar la foto (image_5a0d76.jpg)
  void _showPhotoOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Título (ej: Leo en la imagen)
              Text(
                widget.username,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Divider(color: AppColors.lightText),

              // Opción 1: Cambiar foto de perfil
              _buildModalOption(
                title: 'Cambiar foto de perfil',
                icon: Icons.person_outline,
                onTap: () => debugPrint("Abriendo selector de foto/galería"),
              ),

              // Opción 2: Tomar foto (Cámara)
              _buildModalOption(
                title: 'Tomar foto',
                icon: Icons.camera_alt_outlined,
                onTap: () => debugPrint("Abriendo la cámara (Acceso requerido)"),
              ),

              // Opción 3: Eliminar foto
              _buildModalOption(
                title: 'Eliminar foto',
                icon: Icons.delete_outline,
                color: AppColors.red,
                onTap: () => debugPrint("Eliminando foto de perfil"),
              ),

              const SizedBox(height: 15),
              // Botón Cancelar
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.lightText, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontSize: 16),
      ),
      onTap: () {
        onTap();
        Navigator.pop(context); // Cierra el modal al seleccionar
      },
    );
  }
  // ========================================================

  Future<void> _showAddReasonModal() async {
    final newReason = await showDialog<String>(
      context: context,
      builder: (context) => const AddReasonModal(),
    );

    if (newReason != null && newReason.isNotEmpty) {
      setState(() {
        studyReasons.add(newReason);
      });
      widget.authService.updateProfileData(
        widget.username,
        {'studyReasons': studyReasons},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Motivación añadida: "$newReason" y sincronizada.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  // ================== WIDGETS DE CONSTRUCCIÓN ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildLeaderboardCard(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildReasonsAndOverloadedSection(),
              const SizedBox(height: 24),
              _buildStudyActivitySection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final displayUsername = widget.username.isNotEmpty ? widget.username : "Usuario";
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Perfil",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmark_outline, color: AppColors.lightText),
                  onPressed: () => debugPrint("Navegando a Guardados"),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.lightText),
                  onPressed: () => _openPage("Ajustes"),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _openPage("Cambiar Foto"), // Llama al modal de opciones
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.grey,
                  backgroundImage: profilePictureUrl.isNotEmpty ? NetworkImage(profilePictureUrl) : null,
                  child: profilePictureUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 40)
                      : null,
                ),
              ),
              // Botón de lápiz
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgDark, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayUsername,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Miembro desde $memberSince",
          style: const TextStyle(color: AppColors.lightText, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard() {
    return _customCard(
      title: "Leaderboard",
      titleColor: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tú eres el #1",
                style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () => _openPage("Ver Leaderboard Completo"), // Llama a la navegación de Leaderboard
                child: const Text("Ver más >", style: TextStyle(color: AppColors.primary, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _isLoadingLeaderboard
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : Column(
            children: leaderboard.map((user) => _buildLeaderboardRow(
              user['rank'],
              user['username'],
              user['streak'],
              user['isUser'] ?? false,
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ... (El resto de los widgets se mantienen igual)

  Widget _buildLeaderboardRow(int rank, String name, int days, bool isUser) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: rank <= 3
                ? Icon(icon, color: iconColor, size: 24)
                : Text('$rank', style: const TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: isUser ? Colors.white : AppColors.lightText, fontWeight: isUser ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isUser ? Colors.amber[800] : Colors.deepPurple, borderRadius: BorderRadius.circular(8)),
            child: Text("$days days", style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tus Estadísticas", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statsInfoCard(icon: Icons.local_fire_department, iconColor: Colors.orange, label: "Racha Diaria", value: "$currentStreak", unit: "días")),
            const SizedBox(width: 16),
            Expanded(
                child: _statsInfoCard(
                    icon: Icons.access_time_filled,
                    iconColor: Colors.lightGreenAccent,
                    label: "Tiempo Total",
                    value: "${(totalMinutes / 60).floor()}h ${totalMinutes % 60}m")),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _openPage("Tarjeta Épica"),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary.withOpacity(0.8), Colors.purple.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_half, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ver Tarjeta Épica", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        Text("Tu carta holográfica personal", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsInfoCard({required IconData icon, required Color iconColor, required String label, required String value, String unit = ''}) {
    return _customCard(
      titleColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.lightText, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          if (unit.isNotEmpty) Text(unit, style: const TextStyle(color: AppColors.lightText, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildReasonsAndOverloadedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientCard(
          title: "Razones para estudiar",
          icon: Icons.lightbulb_outline,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...studyReasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.lightText),
                    const SizedBox(width: 8),
                    Expanded(child: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 16))),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _openPage("Agregar Razón"),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Nueva Razón", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _openPage("Función Respirar"),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("¿Te sientes sobrecargado?", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      Text("Tómate un respiro y reconecta contigo", style: TextStyle(color: AppColors.lightText, fontSize: 14)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudyActivitySection() {
    final List<String> labels = const ["Semana", "Mes", "Toda la vida"];
    String timeValue;
    String subtitle;
    int chartBars;

    switch (_selectedActivityTab) {
      case 0:
        timeValue = "${(totalMinutes / 60 / 7).toStringAsFixed(1)}h";
        subtitle = "Promedio Semanal";
        chartBars = 7;
        break;
      case 1:
        timeValue = "${(totalMinutes / 60 / 30).toStringAsFixed(1)}h";
        subtitle = "Promedio Mensual";
        chartBars = 4;
        break;
      case 2:
        timeValue = "${(totalMinutes / 60).floor()}h ${totalMinutes % 60}m";
        subtitle = "Tiempo Total Acumulado";
        chartBars = 12;
        break;
      default:
        timeValue = "0h 0m";
        subtitle = "Sin datos";
        chartBars = 7;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Actividad de Estudio", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _customCard(
          title: "Tiempo de Estudio Promedio",
          titleColor: Colors.white,
          child: Column(
            children: [
              _tabs(
                index: _selectedActivityTab,
                labels: labels,
                onChanged: (i) {
                  setState(() {
                    _selectedActivityTab = i;
                  });
                  debugPrint("Cambiar Actividad a: ${labels[i]}");
                },
              ),
              const SizedBox(height: 16),
              Text(
                  timeValue,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
              ),
              Text(subtitle, style: const TextStyle(color: AppColors.lightText)),
              const SizedBox(height: 12),
              _fakeBarChart(bars: chartBars, minHeight: 40, maxHeight: 100, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customCard({Widget? child, String? title, Color titleColor = AppColors.primary}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 12, spreadRadius: 1)],
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) Text(title, style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.w700)),
          if (title != null) const SizedBox(height: 10),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _tabs({required int index, required List<String> labels, required Function(int) onChanged}) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: AppColors.bgDark, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: List.generate(labels.length, (i) {
          final bool isSelected = index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text(labels[i], style: TextStyle(color: isSelected ? Colors.white : AppColors.lightText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _fakeBarChart({int bars = 7, double minHeight = 40, double maxHeight = 100, Color color = AppColors.primary}) {
    final random = Random();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(bars, (index) {
        double height = minHeight + random.nextInt((maxHeight - minHeight).toInt()).toDouble();
        return Container(width: 16, height: height, decoration: BoxDecoration(color: color.withOpacity(0.8), borderRadius: BorderRadius.circular(6)));
      }),
    );
  }

  Widget _buildGradientCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.secondary.withOpacity(0.2), Colors.purple.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: _customCard(titleColor: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: Colors.white, size: 24), const SizedBox(width: 8), Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 12),
        content,
      ])),
    );
  }
}