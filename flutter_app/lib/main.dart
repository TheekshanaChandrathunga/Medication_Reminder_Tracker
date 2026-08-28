import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'constants.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/meds_page.dart';
import 'pages/add_medication_page.dart';
import 'pages/profile_page.dart';
import 'pages/history_page.dart';
import 'pages/reports_page.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to initialize Firebase, but don't crash if it fails (allows simulation mode)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed, switching to Simulation Mode: $e");
  }
  
  await initializeDateFormatting('en_US', null);
  runApp(const MediTrackApp());
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({super.key});

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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        ),
        home: const AuthWrapper(),
        routes: {
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/meds': (context) => const MedsPage(),
          '/addMed': (context) => const AddMedicationPage(),
          '/profile': (context) => const ProfilePage(),
          '/history': (context) => const HistoryPage(),
          '/reports': (context) => const ReportsPage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // In Simulation Mode, skip the Auth check and go to Home
    if (DatabaseService.isSimulation) {
      return const HomePage();
    }

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashPage();
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
