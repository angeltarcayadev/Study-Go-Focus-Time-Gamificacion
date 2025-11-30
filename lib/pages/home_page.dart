import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_go/components/timer_circle.dart';
import 'package:study_go/pages/estadisticas_page.dart';
import 'package:study_go/pages/profile_dashboard_page.dart';
import 'package:study_go/pages/examenes_page.dart';
import 'package:study_go/services/auth_service.dart';
import 'package:study_go/theme/app_colors.dart';
import 'package:study_go/components/edge_panel.dart';

// ======================
// HomePage (optimizado)
// ======================
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.username, required this.authService});

  final String username;
  final AuthService authService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  final List<String> _titles = [
    "Study",
    "Track",
    "Focus Time",
    "Cube",
    "Perfil",
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inyectamos authService y username en FocusTimeScreen y EstadisticasPage
    _screens = [
      ExamenesPage(onBackToFocus: () => setState(() => _selectedIndex = 2)),
      EstadisticasPage(
        onBackToFocus: () => setState(() => _selectedIndex = 2),
        //authService: widget.authService,
        //username: widget.username,
      ),
      FocusTimeScreen(
        authService: widget.authService,
        username: widget.username,
      ),
      const GamesScreen(),
      ProfileDashboardPage(
        onBackToFocus: () => setState(() => _selectedIndex = 2),
        username: widget.username,
        authService: widget.authService,
      ),
    ];
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: _selectedIndex == 2
          ? null
          : AppBar(
        elevation: 0,
        backgroundColor: AppColors.bgDark,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _bottomNavBar(width),
    );
  }

  Widget _bottomNavBar(double width) {
    const List<Map<String, dynamic>> navItems = [
      {"icon": Icons.bar_chart_rounded, "label": "Study"},
      {"icon": Icons.history_rounded, "label": "Track"},
      {"icon": Icons.timer_rounded, "label": "Focus Time"},
      {"icon": Icons.videogame_asset_rounded, "label": "Cube"},
      {"icon": Icons.person_rounded, "label": "Perfil"},
    ];

    final horizontalPadding = width * 0.03;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          bool isActive = _selectedIndex == idx;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _onNavTap(idx);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item["icon"],
                  color: isActive ? AppColors.primary : AppColors.lightText,
                  size: isActive ? 28 : 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item["label"],
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.lightText,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ====================
// FocusTimeScreen (FUNCIONAL Y SINCRONIZADO)
// ====================
class FocusTimeScreen extends StatefulWidget {
  final AuthService authService;
  final String username;

  const FocusTimeScreen({
    super.key,
    required this.authService,
    required this.username,
  });

  @override
  State<FocusTimeScreen> createState() => _FocusTimeScreenState();
}

class _FocusTimeScreenState extends State<FocusTimeScreen>
    with AutomaticKeepAliveClientMixin {
  // Timer State
  late Timer _timer;
  int totalMinutes = 25;
  int remainingSeconds = 25 * 60;
  bool isRunning = false;
  String selectedMode = "Pomodoro";
  String selectedSubject = "Ninguna";

  // User Data State
  int cubesEarned = 11;
  int streakDays = 7;
  int totalMinutesStudied = 0; // Sincronizado desde AuthService

  // Recompensa State
  final int nextRewardHours = 5; // Horas necesarias para el siguiente cubo (Simulación)

  // UI State
  bool _panelOpen = false;
  double _dragStartX = 0;

  // Lista de Asignaturas (Simulación local)
  List<String> subjects = ["Matemáticas", "Física", "Programación", "Química"];

  @override
  bool get wantKeepAlive => true;

  get _simulateAppBlocking => null;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _handleTick);
    // Carga inicial de datos totales para el progreso
    _loadInitialStats();
  }

  Future<void> _loadInitialStats() async {
    final leaderboard = await widget.authService.getLeaderboard();
    final currentUserData = leaderboard.firstWhere(
          (user) => user['username'] == widget.username,
      orElse: () => {"streak": 0, "totalMinutes": 0, "cubes": 0},
    );
    setState(() {
      totalMinutesStudied = currentUserData['totalMinutes'] ?? 0;
      streakDays = currentUserData['streak'] ?? 0;
      // Esto es una simulación; en una app real, los "cubos" serían parte de la BD
      cubesEarned = (totalMinutesStudied ~/ 300); // 1 cubo por cada 5 horas (300 min)
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Lógica del Timer
  void _handleTick(Timer timer) {
    if (isRunning && remainingSeconds > 0) {
      setState(() {
        remainingSeconds--;
      });
      if (remainingSeconds == 0) {
        _sessionCompleted();
      }
    }
  }

  // Finaliza la sesión y registra la actividad
  void _sessionCompleted() {
    pauseTimer();

    final sessionDurationMinutes = totalMinutes;

    // 1. REGISTRAR ACTIVIDAD CON AUTHSERVICE (Sincronización)
    widget.authService.logActivity(
      widget.username,
      selectedSubject,
      sessionDurationMinutes,
    );

    // 2. ACTUALIZAR ESTADO LOCAL Y RECOMPENSAS (Sincronización Visual)
    int rewardCubes = selectedMode == "Pomodoro" ? 1 : 2;
    setState(() {
      cubesEarned += rewardCubes; // Actualiza visualmente
      totalMinutesStudied += sessionDurationMinutes; // Importante para la barra de progreso
    });

    // 3. Mostrar Notificación de Éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Sesión de $selectedMode ($totalMinutes min) completada! Ganaste $rewardCubes Cubes. Datos sincronizados.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 5),
      ),
    );

    resetTimer();
  }


  void startTimer() => setState(() => isRunning = true);
  void pauseTimer() => setState(() => isRunning = false);
  void resetTimer() {
    if (isRunning) {
      final elapsedTimeMinutes = (totalMinutes * 60 - remainingSeconds) ~/ 60;
      if (elapsedTimeMinutes > 0) {
        widget.authService.logActivity(widget.username, selectedSubject, elapsedTimeMinutes);
        // Actualiza el total estudiado con el tiempo parcial
        setState(() {
          totalMinutesStudied += elapsedTimeMinutes;
        });
      }
    }

    setState(() {
      isRunning = false;
      remainingSeconds = totalMinutes * 60;
    });
  }

  bool _isPresetUnlocked(String label) {
    if (label == "Pomodoro") return true;
    if (label == "Sprint" && cubesEarned >= 5) return true;
    if (label == "Deep Work" && cubesEarned >= 10) return true;
    if (label == "Free" && cubesEarned >= 15) return true;
    return false;
  }

  void _handleDrag(details) {
    if (details.globalPosition.dx < 20) {
      setState(() => _panelOpen = true);
    }
  }

  // Modal para mostrar el progreso de desbloqueo (al hacer clic en el ícono del cubo)
  void _showRewardProgressModal() {
    final int hoursStudied = totalMinutesStudied ~/ 60;
    final int minutesNeeded = nextRewardHours * 60 - totalMinutesStudied;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Camino de Logros", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¡Estudia más para desbloquear todos los cubos!",
                style: TextStyle(color: AppColors.lightText, fontSize: 14),
              ),
              const SizedBox(height: 15),

              // Muestra el progreso actual y la meta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Estudiado: ${hoursStudied}h", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Meta: ${nextRewardHours}h", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),

              // Barra de progreso detallada
              LinearProgressIndicator(
                value: hoursStudied / nextRewardHours,
                backgroundColor: AppColors.bgDark,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                minHeight: 10,
              ),
              const SizedBox(height: 15),

              if (minutesNeeded > 0)
                Text(
                  "Te faltan ${(minutesNeeded / 60).toStringAsFixed(1)} horas de estudio para el siguiente Cubo (Plata).",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                )
              else
                const Text(
                  "¡Felicidades! Has desbloqueado el siguiente Cubo.",
                  style: TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: AppColors.primary)),
            )
          ],
        );
      },
    );
  }

  // ... (otros métodos se mantienen igual)
  // Llama al modal para seleccionar asignatura
  void _showSubjectSelectionModal() {
    // ... (modal de selección de asignaturas)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalTitle("Seleccionar Asignatura"),

              // Lista de asignaturas disponibles
              ...subjects.map((subject) => ListTile(
                leading: Icon(
                  selectedSubject == subject ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selectedSubject == subject ? AppColors.primary : AppColors.lightText,
                ),
                title: Text(subject, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => selectedSubject = subject);
                  Navigator.pop(context);
                },
              )),

              // Opción para agregar nueva asignatura
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
                title: const Text("Agregar Nueva Asignatura", style: TextStyle(color: AppColors.secondary)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddNewSubjectDialog();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Diálogo para agregar una nueva asignatura
  void _showAddNewSubjectDialog() {
    final TextEditingController subjectController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.grey,
          title: const Text("Nueva Asignatura", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: subjectController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Nombre de la asignatura",
              hintStyle: TextStyle(color: AppColors.lightText),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.secondary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: AppColors.lightText)),
            ),
            TextButton(
              onPressed: () {
                if (subjectController.text.isNotEmpty) {
                  setState(() {
                    subjects.add(subjectController.text);
                    selectedSubject = subjectController.text;
                  });
                  // Opcional: Sincronizar esta lista con AuthService
                }
                Navigator.pop(context);
              },
              child: const Text("Agregar", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _edgeHandle() {
    return Positioned(
      left: 0,
      top: MediaQuery.of(context).size.height * 0.26,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (d) => _dragStartX = d.globalPosition.dx,
        onHorizontalDragUpdate: _handleDrag,
        child: Container(
          width: 28,
          height: 70,
          alignment: Alignment.centerLeft,
          child: Container(
            width: 5,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidePreset(String label, int minutes) {
    final bool unlocked = _isPresetUnlocked(label);
    final bool selected = selectedMode == label;

    return GestureDetector(
      onTap: unlocked
          ? () {
        setState(() {
          selectedMode = label;
          totalMinutes = minutes;
          remainingSeconds = minutes * 60;
          _panelOpen = false;
        });
      }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.9)
              : unlocked
              ? AppColors.grey.withOpacity(0.8)
              : Colors.black38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: unlocked ? Colors.white : AppColors.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (!unlocked)
              const Icon(Icons.lock, size: 18, color: AppColors.lightText),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Usamos tamaños más seguros para evitar overflow
    final double timerSize = math.min(width * 0.95, height * 0.40);
    final double largeGap = height * 0.02;
    final double mediumGap = height * 0.01;
    final double smallGap = height * 0.01;
    final double horizontalPadding = width * 0.04;
    final titleFontSize = math.min(width * 0.09, 40.0);

    // Cálculo del progreso para la barra horizontal
    final int hoursStudied = totalMinutesStudied ~/ 60;
    final double progressFraction = math.min(1.0, hoursStudied / nextRewardHours);


    return Stack(
      children: [
        // Fondo + contenido original
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F111A), Color(0xFF1C1E26)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            // Utilizamos SingleChildScrollView para prevenir el overflow del RenderFlex
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top bar
                  Padding(
                    padding: EdgeInsets.only(top: smallGap, bottom: smallGap),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Focus Time",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: math.min(width * 0.07, 28),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        // Cubes and Streak Boxes
                        Row(
                          children: [
                            _streakBox(
                              icon: Icons.local_fire_department_rounded,
                              value: "$streakDays",
                              color: Colors.orangeAccent,
                              width: width,
                            ),
                            SizedBox(width: width * 0.02),
                            _streakBox(
                              icon: Icons.ac_unit_rounded,
                              value: "$cubesEarned",
                              color: Colors.lightBlueAccent,
                              width: width,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: largeGap * 0.5),

                  Text(
                    selectedMode, // Muestra el modo seleccionado
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: titleFontSize * 0.6,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1.5),
                          blurRadius: 4,
                          color: AppColors.secondary.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Focus Timer",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1.5),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: mediumGap),

                  // Asignatura Actual
                  Text(
                    "Asignatura: $selectedSubject",
                    style: const TextStyle(color: AppColors.lightText, fontSize: 16),
                  ),

                  SizedBox(height: largeGap * 0.75),

                  // --- BARRA DE PROGRESO DE RECOMPENSA Y CUBE (NUEVO DISEÑO) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Barra de Progreso
                      Expanded(
                        child: Container(
                          height: height * 0.01,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressFraction, // Usa el progreso calculado
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                // Efecto de brillo
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.03),

                      // ÍCONO INTERACTIVO DEL CUBO
                      GestureDetector(
                        onTap: _showRewardProgressModal, // Abre el modal de progreso
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.secondary, width: 2),
                          ),
                          child: const Icon(Icons.ac_unit_rounded, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                  // FIN BARRA DE PROGRESO DE RECOMPENSA

                  SizedBox(height: largeGap * 0.75),

                  // Círculo del Temporizador (Elemento grande)
                  SizedBox(
                    width: timerSize,
                    height: timerSize,
                    child: Center(
                      child: TimerCircle(
                        totalMinutes: totalMinutes,
                        remainingSeconds: remainingSeconds,
                        isRunning: isRunning,
                        isFreeMode: selectedMode == "Free",
                        onFreeTimeChanged: (newSeconds) {
                          // Solo permitimos cambiar el tiempo si está pausado y en modo Free
                          if (!isRunning && selectedMode == "Free") {
                            setState(() => remainingSeconds = newSeconds);
                          }
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: mediumGap),

                  // Botón Bloquear Aplicaciones
                  SizedBox(
                    width: math.min(width * 0.7, 360),
                    child: ElevatedButton.icon(
                      onPressed: isRunning ? _simulateAppBlocking : null, // Solo bloquea si está corriendo
                      icon: const Icon(Icons.lock_clock_rounded,
                          color: Colors.white),
                      label: const Text("Bloquear Aplicaciones"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: height * 0.018),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Botones Empezar/Pausar y Reiniciar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _actionButton(
                          isRunning ? "Pausar" : "Empezar",
                          isRunning ? AppColors.grey : AppColors.primary,
                          isRunning ? pauseTimer : startTimer,
                          height,
                          width,
                        ),
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: _actionButton("Reiniciar", AppColors.red,
                            resetTimer, height, width),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Botón Seleccionar Asignatura
                  SizedBox(
                    width: math.min(width * 0.7, 360),
                    child: ElevatedButton.icon(
                      onPressed: _showSubjectSelectionModal, // Llama al modal de asignaturas
                      icon: const Icon(Icons.menu_book_rounded,
                          color: Colors.white),
                      label: const Text("Seleccionar Asignatura"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey,
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: height * 0.015),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ),

                  // Margen final
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ),
        ),

        // 🔥 La rayita del borde (abre el panel)
        _edgeHandle(),

        // 🔥 El panel lateral (Presets)
        EdgePanel(
          isOpen: _panelOpen,
          onClose: () => setState(() => _panelOpen = false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalTitle("Presets"),
              const SizedBox(height: 20),
              _sidePreset("Pomodoro", 25),
              _sidePreset("Sprint", 50),
              _sidePreset("Deep Work", 90),
              _sidePreset("Free", 120),
            ],
          ),
        ),
      ],
    );
  }

  Widget _streakBox({
    required IconData icon,
    required String value,
    required Color color,
    required double width,
  }) {
    final double boxWidth = math.min(width * 0.18, 84);
    return Container(
      width: boxWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(5), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      String label, Color color, VoidCallback onPressed, double height, double width) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.04, vertical: height * 0.016),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 6,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ====================
// GamesScreen
// ====================
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey, // Usamos AppColors.grey
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          "Sección de Juegos en desarrollo",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.lightText, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}