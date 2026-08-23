import 'package:flutter/material.dart';
import '../constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

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
              child: Container(
                margin: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Box
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColors.dark,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: const Text('💊', style: TextStyle(fontSize: 32)),
                        ),
                        const Text(
                          'MediTrack',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Welcome back. Please log in to\nmanage your health schedule.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5A6A85),
                            height: 1.38, // approx 18 line-height
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Email Address
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 12),
                      child: Text(
                        'Email Address',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                      ),
                    ),
                    _buildInput(
                      controller: _emailCtrl,
                      hint: 'e.g. john@example.com',
                      iconLeft: '✉️',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    // Password
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 12),
                      child: Text(
                        'Password',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                      ),
                    ),
                    _buildInput(
                      controller: _passCtrl,
                      hint: 'Enter your password',
                      iconLeft: '🔒',
                      obscureText: !_showPassword,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _showPassword = !_showPassword),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          color: Colors.transparent,
                          child: Text(_showPassword ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.blue),
                          ),
                        ),
                      ),
                    ),

                    // Login Button
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Log In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.inputBorder, height: 1),
                    ),

                    // Footer Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account? ', style: TextStyle(fontSize: 13, color: Color(0xFF5A6A85))),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: const Text(
                            'Register Here',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B8282),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required String iconLeft,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(iconLeft, style: const TextStyle(fontSize: 16)),
          ),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 38, right: 14, top: 12, bottom: 12),
              isDense: true,
            ),
          ),
          if (suffixIcon != null)
            Positioned(
              right: 12,
              child: suffixIcon,
            ),
        ],
      ),
    );
  }
}
