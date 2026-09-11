import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 16, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('MediTrack', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.blue)),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: AppColors.blue),
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
                      if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      
                      final medications = snapshot.data ?? [];
                      final takenToday = medications.where((m) => _isTakenToday(m)).length;
                      final total = medications.length;
                      final progress = total == 0 ? 0.0 : takenToday / total;
                      final today = DateFormat('EEEE, MMM d').format(DateTime.now());

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildWelcomeCard(today, takenToday, total, progress),
                          
                          ...medications.where((m) => m.totalQuantity <= m.refillAlertAt && m.totalQuantity > 0).map((m) => 
                            _buildInventoryAlert(m)
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
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
                backgroundColor: AppColors.blue,
                label: const Text('Add Med', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                icon: const Icon(Icons.add, color: Colors.white),
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
          Icon(Icons.medication_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No medications added yet.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const Text("Tap '+' to get started.", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInventoryAlert(Medication med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5), 
        border: Border.all(color: const Color(0xFFFEB2B2)), 
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC53030), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Refill soon: ${med.name} (${med.totalQuantity} left)', style: const TextStyle(color: Color(0xFFC53030), fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String date, int taken, int total, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Healthy Day!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(date, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: progress, backgroundColor: Colors.white24, strokeWidth: 6, color: Colors.white),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$taken of $total doses taken', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  const Text('Real-time adherence sync', style: TextStyle(fontSize: 12, color: Colors.white60)),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNow ? AppColors.blue : AppColors.inputBorder, width: isNow ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 55, height: 55,
                decoration: BoxDecoration(color: isNow ? AppColors.blue : AppColors.iconBg, borderRadius: BorderRadius.circular(12)),
                child: (!kIsWeb && med.localImagePath != null && File(med.localImagePath!).existsSync())
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(med.localImagePath!), fit: BoxFit.cover))
                    : Center(child: Text(med.category == 'Pill' ? '💊' : '🧪', style: TextStyle(fontSize: 28, color: isNow ? Colors.white : null))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, decoration: isTakenToday ? TextDecoration.lineThrough : null)),
                    Text('${med.dosage} • ${med.doseTimes.join(", ")}', style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                  ],
                ),
              ),
              if (isTakenToday) const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              if (isNow) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(6)), child: const Text('NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          if (!isTakenToday)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => db.markAsMissed(med),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                      child: const Text('Missed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => db.markAsTaken(med),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNow ? AppColors.blue : Colors.grey.shade100,
                        foregroundColor: isNow ? Colors.white : Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Mark as Taken', style: TextStyle(fontWeight: FontWeight.bold)),
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
