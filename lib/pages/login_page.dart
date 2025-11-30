import 'package:flutter/material.dart';
import 'package:study_go/components/my_button.dart';
import 'package:study_go/pages/home_page.dart';
import 'package:study_go/pages/register_page.dart';
import 'package:study_go/services/auth_service.dart';
import 'package:study_go/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;

  const LoginPage({super.key, required this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loginEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack("Completa todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              username: user.displayName ?? "Usuario",
              authService: _authService,
            ),
          ),
        );
      } else {
        _showSnack("Error al iniciar sesión");
      }
    } catch (e) {
      _showSnack("Error al iniciar sesión: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterPage(authService: _authService)),
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
                "Bienvenido",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Inicia sesión para continuar",
                style: TextStyle(color: AppColors.lightText, fontSize: 16),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: AppColors.grey,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: AppColors.grey,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : MyButton(
                onTap: _loginEmail,
                text: "Iniciar sesión",
                color: AppColors.primary,
                isOutline: false,
              ),
              const SizedBox(height: 16),
              MyButton(
                onTap: _goToRegister,
                text: "¿No tienes cuenta? Regístrate",
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

