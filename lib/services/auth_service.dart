import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Necesario para debugPrint y Map

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ====================================================
  // 1. BASE DE DATOS SIMULADA PARA ESTADÍSTICAS GLOBALES
  //    (Reemplazar con Firestore real en producción)
  // ====================================================
  final Map<String, Map<String, dynamic>> _globalUsers = {
    'leo': {'username': 'Leo', 'streak': 5, 'totalMinutes': 480, 'studyReasons': ["Quiero ganar más dinero"]},
    'luis': {'username': 'Luis', 'streak': 3, 'totalMinutes': 300, 'studyReasons': ["Aprender Flutter"]},
    'santi': {'username': 'Santi', 'streak': 1, 'totalMinutes': 120, 'studyReasons': ["Subir de nivel"]},
    'guest': {'username': 'Guest', 'streak': 0, 'totalMinutes': 0, 'studyReasons': []},
  };

  // =========================
  // 2. AUTENTICACIÓN FIREBASE
  // =========================

  // LOGIN EMAIL / PASSWORD
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      developer.log('Email SignIn error: ${e.message}');
      rethrow;
    }
  }

  // REGISTRO EMAIL / PASSWORD
  Future<User?> registerWithEmail(String email, String password, String username) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user?.updateDisplayName(username.trim());
      await userCredential.user?.reload(); // Refrescar para asegurar displayName

      // Inicializa el usuario en la base de datos simulada al registrar
      _initializeNewUser(userCredential.user!.uid, username.trim());

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      developer.log('Email Register error: ${e.message}');
      rethrow;
    }
  }

  // CERRAR SESIÓN
  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // =========================
  // 3. MÉTODOS DE DATOS (SIMULADOS)
  // =========================

  // Inicializa el nuevo usuario en el mapa global (usando UID de Firebase)
  void _initializeNewUser(String uid, String username) {
    if (!_globalUsers.containsKey(uid)) {
      _globalUsers[uid] = {
        'username': username,
        'streak': 0,
        'totalMinutes': 0,
        'studyReasons': ["¡Recuerda agregar tu primera razón!"],
      };
      developer.log('New user initialized in global data: $username ($uid)');
    }
  }

  // Obtener Leaderboard completo
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final list = _globalUsers.values.toList()
      ..sort((a, b) => b['streak'].compareTo(a['streak']));

    // Asigna el ranking y marca al usuario actual
    final currentUserId = _auth.currentUser?.uid;

    for (int i = 0; i < list.length; i++) {
      list[i]['rank'] = i + 1;
      // Marca si este registro coincide con el usuario autenticado (si está loggeado)
      list[i]['isUser'] = (currentUserId != null && _globalUsers.containsKey(currentUserId) && _globalUsers[currentUserId]?['username'] == list[i]['username']);
    }
    return list;
  }

  // Actualizar datos del perfil (e.g., Razones de Estudio, Imagen)
  void updateProfileData(String userId, Map<String, dynamic> data) {
    // Busca la clave en _globalUsers que corresponde al userId (username)
    final key = _globalUsers.keys.firstWhere((k) => _globalUsers[k]?['username'] == userId, orElse: () => userId);

    if (_globalUsers.containsKey(key)) {
      _globalUsers[key]?.addAll(data);
      debugPrint("AuthService: Datos de $userId actualizados: $data");
    }
  }

  // Registrar actividad (usado por Focus Time o Breathing Exercise)
  void logActivity(String userId, String activityType, int durationMinutes) {
    final key = _globalUsers.keys.firstWhere((k) => _globalUsers[k]?['username'] == userId, orElse: () => userId);

    if (_globalUsers.containsKey(key)) {
      _globalUsers[key]?['totalMinutes'] += durationMinutes;
      // Lógica para actualizar la racha si es necesario.
      debugPrint("AuthService: $userId registró $durationMinutes min de $activityType.");
    }
  }
}