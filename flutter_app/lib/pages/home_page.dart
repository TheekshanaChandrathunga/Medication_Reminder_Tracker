import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/medication_model.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final userId = authService.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 8),
                            child: const Text('💊', style: TextStyle(fontSize: 16)),
                          ),
                          const Text('MediTrack', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.blue),
                        onPressed: () async {
                          await authService.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: userId == null 
                  ? const Center(child: Text("Please login"))
                  : StreamBuilder<List<Medication>>(
                    stream: dbService.getMedications(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      
                      final medications = snapshot.data ?? [];
                      final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

                      return ListView(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 100),
                        children: [
                          _buildWelcomeCard(medications.length, today),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                          ),
                          if (medications.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No meds added yet.")))
                          else
                            ...medications.map((med) => _buildMedCard(context, med, dbService)).toList(),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 70, right: 20,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(context, '/addMed'),
                backgroundColor: const Color(0xFF006A60),
                label: const Text('Add Medication', style: TextStyle(fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add),
              ),
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(activeTab: 'Home')),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(int count, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEDF4FF), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Healthy Day!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(date, style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                ],
              ),
              const Text('👋', style: TextStyle(fontSize: 36)),
            ],
          ),
          const SizedBox(height: 12),
          Text('You have $count medications scheduled for today.', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.blue)),
        ],
      ),
    );
  }

  Widget _buildMedCard(BuildContext context, Medication med, DatabaseService db) {
    bool isTakenToday = med.lastTaken != null && 
                       DateFormat('yyyy-MM-dd').format(med.lastTaken!) == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isTakenToday ? Colors.green.shade200 : AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(med.category == 'Pill' ? '💊' : '🧪', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: isTakenToday ? TextDecoration.lineThrough : null)),
                    Text('${med.dosage} • ${med.doseTimes.join(", ")}', style: const TextStyle(fontSize: 12, color: AppColors.subText)),
                  ],
                ),
              ),
              if (isTakenToday) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          if (!isTakenToday)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => db.markAsTaken(med.id!),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.blue, side: const BorderSide(color: AppColors.blue)),
                      child: const Text('Mark as Taken'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
