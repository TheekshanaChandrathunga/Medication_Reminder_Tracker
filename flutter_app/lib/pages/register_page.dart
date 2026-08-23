import 'package:flutter/material.dart';
import '../constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _userType = 'Patient';
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Box
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: const Text('💼', style: TextStyle(fontSize: 30, color: AppColors.blue)),
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
                          'Create your account',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5A6A85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Card
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // I am a...
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 12),
                          child: Text(
                            'I am a...',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _buildToggleBtn('Patient'),
                              _buildToggleBtn('Caregiver'),
                            ],
                          ),
                        ),

                        // Full Name
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 12),
                          child: Text(
                            'Full Name',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                          ),
                        ),
                        _buildInput(controller: _nameCtrl, hint: 'e.g., John Doe'),

                        // Email Address
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 12),
                          child: Text(
                            'Email Address',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                          ),
                        ),
                        _buildInput(controller: _emailCtrl, hint: 'e.g., john@example.com', keyboardType: TextInputType.emailAddress),

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
                          hint: '••••••••',
                          obscureText: !_showPassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _showPassword = !_showPassword),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(_showPassword ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),

                        // Confirm Password
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 12),
                          child: Text(
                            'Confirm Password',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                          ),
                        ),
                        _buildInput(
                          controller: _confirmPassCtrl,
                          hint: '••••••••',
                          obscureText: !_showConfirmPassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(_showConfirmPassword ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),

                        // Create Account Button
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
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
                            child: const Text('Create Account →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
                            const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: Color(0xFF5A6A85))),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label) {
    bool isActive = _userType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _userType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.white : const Color(0xFF4A5568),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
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
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
