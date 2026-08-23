import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/meds_page.dart';
import 'pages/add_medication_page.dart';
import 'pages/profile_page.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Standard initialization: On Android, this uses google-services.json automatically
  await Firebase.initializeApp();

  runApp(const MediTrackApp());
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
