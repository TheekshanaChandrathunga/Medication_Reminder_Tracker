import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/medication_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  bool _isTakenToday(Medication med) {
    if (med.lastTaken == null) return false;
    final now = DateTime.now();
    return med.lastTaken!.year == now.year &&
           med.lastTaken!.month == now.month &&
           med.lastTaken!.day == now.day;
  }

  bool _isDueNow(List<String> doseTimes) {
    if (doseTimes.isEmpty) return false;
    final now = DateTime.now();
    final currentTimeStr = DateFormat('hh:mm a').format(now);
    
    for (var timeStr in doseTimes) {
      try {
        final cleanTime = timeStr.trim().toUpperCase();
        final doseTime = DateFormat('hh:mm a').parse(cleanTime);
        final nowTime = DateFormat('hh:mm a').parse(currentTimeStr);
        
        final diff = nowTime.difference(doseTime).inMinutes.abs();
        if (diff <= 60) return true; 
      } catch (e) {
        continue;
      }
    }
    return false;
  }

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
                // Header
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('MediTrack', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue)),
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.blue),
                        onPressed: () async {
                          await authService.signOut();
                          if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                        },
                      )
                    ],
                  ),
                ),
                
                Expanded(
                  child: userId == null 
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<Medication>>(
                    stream: dbService.getMedications(userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final medications = snapshot.data ?? [];
                      final takenToday = medications.where((m) => _isTakenToday(m)).length;
                      final total = medications.length;
                      final progress = total == 0 ? 0.0 : takenToday / total;
                      final today = DateFormat('EEEE, MMM d').format(DateTime.now());

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildWelcomeCard(today, takenToday, total, progress),
                          
                          // Inventory warnings
                          ...medications.where((m) => m.totalQuantity <= m.refillAlertAt && m.totalQuantity > 0).map((m) => 
                            _buildInventoryAlert(m)
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          ),
                          
                          if (medications.isEmpty)
                            _buildEmptyState()
                          else
                            ...medications.map((med) => _buildMedCard(context, med, dbService)),
                          
                          const SizedBox(height: 100),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.medication_liquid_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No meds found. Tap '+' to start.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInventoryAlert(Medication med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFF5F5), border: Border.all(color: const Color(0xFFFEB2B2)), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC53030), size: 20),
          const SizedBox(width: 10),
          Text('Refill soon: ${med.name} (${med.totalQuantity} left)', style: const TextStyle(color: Color(0xFFC53030), fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String date, int taken, int total, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFFEDF4FF), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Healthy Day!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(date, style: const TextStyle(fontSize: 13, color: AppColors.subText)),
          const SizedBox(height: 14),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: progress, backgroundColor: Colors.white, strokeWidth: 5, color: AppColors.blue),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$taken of $total doses taken', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Automatic health sync active', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedCard(BuildContext context, Medication med, DatabaseService db) {
    final isTakenToday = _isTakenToday(med);
    final isNow = !isTakenToday && _isDueNow(med.doseTimes);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isNow ? AppColors.blue : AppColors.inputBorder, width: isNow ? 2 : 1),
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
                      onPressed: () => db.markAsMissed(med),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Missed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => db.markAsTaken(med),
                      style: ElevatedButton.styleFrom(backgroundColor: isNow ? AppColors.blue : Colors.grey.shade200, foregroundColor: isNow ? Colors.white : Colors.black87),
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
