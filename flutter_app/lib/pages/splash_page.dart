import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFF5EA),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(), // spacer
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1118),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: const Text('💊', style: TextStyle(fontSize: 60)),
                  ),
                  const Text(
                    'MediTrack',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A5B80),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Never miss a dose.',
                    style: TextStyle(fontSize: 18, color: Color(0xFF557A8B)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(true),
                  const SizedBox(width: 10),
                  _dot(false),
                  const SizedBox(width: 10),
                  _dot(false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: active ? 12 : 10,
      height: active ? 12 : 10,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0A5B80) : const Color(0xFF86C5BE),
        borderRadius: BorderRadius.circular(active ? 6 : 5),
      ),
    );
  }
}
