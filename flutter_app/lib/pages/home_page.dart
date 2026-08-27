import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Ensure this is at the top
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
    final now = DateTime.now();
    final currentTime = DateFormat('hh:mm a').format(now);
    
    for (var timeStr in doseTimes) {
      try {
        final doseTime = DateFormat('hh:mm a').parse(timeStr);
        final nowTime = DateFormat('hh:mm a').parse(currentTime);
        final difference = nowTime.difference(doseTime).inMinutes.abs();
        if (difference <= 60) return true; 
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
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: userId == null 
                  ? const Center(child: Text("Please login to see your schedule"))
                  : StreamBuilder<List<Medication>>(
                    stream: dbService.getMedications(userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      
                      final medications = snapshot.data ?? [];
                      final takenCount = medications.where((m) => _isTakenToday(m)).length;
                      final totalCount = medications.length;
                      final pendingCount = totalCount - takenCount;
                      final progress = totalCount == 0 ? 0.0 : takenCount / totalCount;
                      final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

                      return ListView(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 100),
                        children: [
                          _buildWelcomeCard(today, takenCount, pendingCount, progress),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                          ),
                          if (medications.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No medications added yet.")))
                          else
                            ...medications.map((med) => _buildMedCard(context, med, dbService)),
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

  Widget _buildWelcomeCard(String date, int taken, int pending, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
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
                  const Text('Healthy Day!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryText)),
                  Text('Today, $date', style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                ],
              ),
              const Text('👋', style: TextStyle(fontSize: 36)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              _buildBadge('⏰ Pending: $pending', const Color(0xFFFEFCBF), const Color(0xFFB7791F)),
              _buildBadge('✓ Taken: $taken', const Color(0xFFC6F6D5), const Color(0xFF276749)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE2EDFF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.blue, width: 3)),
                  alignment: Alignment.center,
                  child: Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.blue)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('$taken of ${taken + pending} doses completed', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: fg)),
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
        border: isNow 
            ? Border.all(color: AppColors.blue, width: 1.5)
            : Border.all(color: isTakenToday ? const Color(0xFFC6F6D5) : AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isNow ? AppColors.blue : AppColors.iconBg, 
                  shape: BoxShape.circle
                ),
                alignment: Alignment.center,
                child: Text(
                  med.category == 'Pill' ? '💊' : '🧪', 
                  style: TextStyle(fontSize: 18, color: isNow ? Colors.white : null)
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(med.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, decoration: isTakenToday ? TextDecoration.lineThrough : null)),
                        if (isNow)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(4)),
                            child: const Text('NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                    Text('${med.dosage} • ${med.doseTimes.join(", ")}', style: const TextStyle(fontSize: 12, color: AppColors.subText)),
                  ],
                ),
              ),
              if (isTakenToday) const Icon(Icons.check_circle, color: Color(0xFF38A169)),
            ],
          ),
          if (!isTakenToday)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  _buildActionBtn('⏰ Snooze', () {}, isNow),
                  const SizedBox(width: 8),
                  _buildActionBtn('✕ Missed', () {}, isNow, isDanger: true),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: med.id == null ? null : () => db.markAsTaken(med.id!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNow ? AppColors.blue : const Color(0xFFEDF2F7),
                        foregroundColor: isNow ? Colors.white : const Color(0xFFA0AEC0),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('✓ Taken', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap, bool isActive, {bool isDanger = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: isActive ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              color: !isActive 
                  ? const Color(0xFFA0AEC0) 
                  : (isDanger ? const Color(0xFFE53E3E) : AppColors.secondaryText)
            ),
          ),
        ),
      ),
    );
  }
}
