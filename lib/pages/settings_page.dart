import 'package:flutter/material.dart';
import 'package:study_go/theme/app_colors.dart';
import 'package:study_go/services/auth_service.dart';
import 'package:study_go/pages/login_page.dart';

class SettingsPage extends StatelessWidget {
  final AuthService authService;

  const SettingsPage({super.key, required this.authService});

  // Función para manejar el cierre de sesión
  void _handleSignOut(BuildContext context) async {
    try {
      await authService.signOut();

      // Navegamos de vuelta a la pantalla de Login y limpiamos el stack
      // CORRECCIÓN: Pasar authService al LoginPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage(authService: authService)),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text("Ajustes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Cuenta
            const Text("Cuenta", style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSettingTile(
              title: "Cambiar Contraseña",
              icon: Icons.vpn_key_rounded,
              onTap: () => debugPrint("Navegar a Cambiar Contraseña"),
            ),
            _buildSettingTile(
              title: "Actualizar Información Personal",
              icon: Icons.person_outline,
              onTap: () => debugPrint("Navegar a Info Personal"),
            ),

            const SizedBox(height: 30),

            // Sección de Datos y Privacidad
            const Text("Datos y Privacidad", style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSettingTile(
              title: "Política de Privacidad",
              icon: Icons.lock_outline,
              onTap: () => debugPrint("Abrir Política de Privacidad"),
            ),
            _buildSettingTile(
              title: "Exportar Datos",
              icon: Icons.cloud_download_outlined,
              onTap: () => debugPrint("Exportar datos del usuario"),
            ),

            const SizedBox(height: 30),

            // Opción de Cerrar Sesión (El botón principal de la tuerca)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout_rounded, color: AppColors.red),
              title: const Text("Cerrar Sesión", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.red, size: 16),
              onTap: () => _handleSignOut(context), // Llama al método de cierre de sesión
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({required String title, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.lightText, size: 16),
        onTap: onTap,
      ),
    );
  }
}