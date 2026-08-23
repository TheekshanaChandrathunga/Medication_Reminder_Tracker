import 'package:flutter/material.dart';

import 'constants.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/meds_page.dart';
import 'pages/add_medication_page.dart';
import 'pages/profile_page.dart';

void main() => runApp(const MediTrackApp());

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.pageBg,
        primaryColor: AppColors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/meds': (context) => const MedsPage(),
        '/addMed': (context) => const AddMedicationPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
