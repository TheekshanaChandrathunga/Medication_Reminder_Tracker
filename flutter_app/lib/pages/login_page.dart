import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;
  bool _isLoading = false;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.loginWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      // Navigation is handled by AuthWrapper in main.dart
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPassword() {
    final emailController = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: 'Email address'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<AuthService>(context, listen: false)
                    .resetPassword(emailController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset link sent! Check your email.')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const Text('💊', style: TextStyle(fontSize: 32)),
                  ),
                  const Text('MediTrack', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.blue)),
                  const SizedBox(height: 30),
                  _buildInput(controller: _emailCtrl, hint: 'Email', iconLeft: '✉️'),
                  _buildInput(
                    controller: _passCtrl,
                    hint: 'Password',
                    iconLeft: '🔒',
                    obscureText: !_showPassword,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _showPassword = !_showPassword),
                      child: Text(_showPassword ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPassword,
                      child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text("Register Here", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B8282), decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required String iconLeft, bool obscureText = false, Widget? suffixIcon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.inputBg, border: Border.all(color: AppColors.inputBorder), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Container(width: 40, alignment: Alignment.center, child: Text(iconLeft, style: const TextStyle(fontSize: 16))),
          suffixIcon: suffixIcon != null ? Container(width: 40, alignment: Alignment.center, child: suffixIcon) : null,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
