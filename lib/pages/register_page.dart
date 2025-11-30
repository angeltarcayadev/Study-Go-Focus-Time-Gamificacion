import 'package:flutter/material.dart';
import 'package:study_go/components/my_button.dart';
import 'package:study_go/services/auth_service.dart';
import 'package:study_go/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  final AuthService authService;
  final VoidCallback? onLoginTap;

  const RegisterPage({super.key, required this.authService, this.onLoginTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _showSnack("Completa todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user =
      await widget.authService.registerWithEmail(email, password, username);
      if (user != null) {
        _showSnack("Registro exitoso");
        Navigator.pop(context); // Volver al login
      }
    } catch (e) {
      _showSnack("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.grey,
      border:
      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "Crea tu cuenta",
                style: TextStyle(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "Regístrate para comenzar a estudiar",
                style: TextStyle(color: AppColors.lightText, fontSize: 16),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: _inputDecoration("Nombre de usuario"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration("Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: _inputDecoration("Password"),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : MyButton(
                onTap: _register,
                text: "Registrarse",
                color: AppColors.primary,
                isOutline: false,
              ),
              const SizedBox(height: 16),
              MyButton(
                onTap: widget.onLoginTap,
                text: "¿Ya tienes cuenta? Inicia sesión",
                color: AppColors.primary,
                isOutline: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

