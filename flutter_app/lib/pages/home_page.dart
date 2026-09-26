import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/medication_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _scheduleRefreshTimer;

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    await Provider.of<AuthService>(context, listen: false).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _scheduleRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scheduleRefreshTimer?.cancel();
    super.dispose();
  }

  bool _isTakenForCurrentDose(Medication med) {
    if (med.lastTaken == null || med.doseTimes.isEmpty) return false;

    final currentDose = _currentScheduledDose(med.doseTimes);
    return currentDose != null && !med.lastTaken!.isBefore(currentDose);
  }

  bool _isMissedForCurrentDose(Medication med) {
    if (med.lastMissed == null || med.doseTimes.isEmpty) return false;

    final currentDose = _currentScheduledDose(med.doseTimes);
    return currentDose != null && !med.lastMissed!.isBefore(currentDose);
  }

  DateTime? _currentScheduledDose(List<String> doseTimes) {
    final now = DateTime.now();
    DateTime? currentDose;
    for (final timeString in doseTimes) {
      try {
        final parsedTime =
            DateFormat('hh:mm a').parse(timeString.trim().toUpperCase());
        final scheduledDose = DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );
        if (!scheduledDose.isAfter(now) &&
            (currentDose == null || scheduledDose.isAfter(currentDose))) {
          currentDose = scheduledDose;
        }
      } catch (_) {
        continue;
      }
    }

    return currentDose;
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
        if (diff <= 60) return true; // High alert if due within 1 hour
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
                  padding: const EdgeInsets.only(
                      left: 20, right: 16, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('MediTrack',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.blue)),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            color: AppColors.blue),
                        onPressed: _confirmLogout,
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: userId == null
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<List<Medication>>(
                          key: ValueKey(userId),
                          stream: dbService.getMedications(userId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return const Center(
                                  child: CircularProgressIndicator());

                            final medications = snapshot.data ?? [];
                            NotificationService.instance
                                .scheduleForMedications(medications);
                            final takenToday = medications
                                .where((m) => _isTakenForCurrentDose(m))
                                .length;
                            final total = medications.length;
                            final progress =
                                total == 0 ? 0.0 : takenToday / total;
                            final today = DateFormat('EEEE, MMM d')
                                .format(DateTime.now());

                            return ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildWelcomeCard(
                                    today, takenToday, total, progress),

                                // Inventory warnings
                                ...medications
                                    .where((m) =>
                                        m.totalQuantity <= m.refillAlertAt &&
                                        m.totalQuantity > 0)
                                    .map((m) => _buildInventoryAlert(m)),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text("Today's Schedule",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryText)),
                                ),

                                if (medications.isEmpty)
                                  _buildEmptyState()
                                else
                                  ...medications.map((med) =>
                                      _buildMedCard(context, med, dbService)),

                                const SizedBox(height: 100), // Bottom padding
                              ],
                            );
                          }),
                ),
              ],
            ),
            Positioned(
              bottom: 70,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(context, '/addMed'),
                backgroundColor: AppColors.blue,
                label: const Text('Add Med',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNav(activeTab: 'Home')),
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
          Icon(Icons.medication_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No medications added yet.",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const Text("Tap '+' to get started.",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
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
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFC53030), size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
                  'Refill soon: ${med.name} (${med.totalQuantity} left)',
                  style: const TextStyle(
                      color: Color(0xFFC53030),
                      fontWeight: FontWeight.bold,
                      fontSize: 12))),
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
        boxShadow: [
          BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Healthy Day!',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          Text(date,
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      strokeWidth: 6,
                      color: Colors.white),
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$taken of $total doses taken',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16)),
                  const Text('Real-time sync active',
                      style: TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedCard(
      BuildContext context, Medication med, DatabaseService db) {
    final isTakenForCurrentDose = _isTakenForCurrentDose(med);
    final isMissedForCurrentDose =
        !isTakenForCurrentDose && _isMissedForCurrentDose(med);
    final isNow = !isTakenForCurrentDose && _isDueNow(med.doseTimes);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isMissedForCurrentDose ? const Color(0xFFFFF5F5) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isMissedForCurrentDose
                ? Colors.redAccent
                : isNow
                    ? AppColors.blue
                    : AppColors.inputBorder,
            width: isMissedForCurrentDose || isNow ? 2 : 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Display local image if available, otherwise show emoji
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                    color: isMissedForCurrentDose
                        ? Colors.redAccent
                        : isNow
                            ? AppColors.blue
                            : AppColors.iconBg,
                    borderRadius: BorderRadius.circular(12)),
                child: (!kIsWeb &&
                        med.localImagePath != null &&
                        File(med.localImagePath!).existsSync())
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(med.localImagePath!),
                            fit: BoxFit.cover))
                    : Center(
                        child: Text(med.category == 'Pill' ? '💊' : '🧪',
                            style: TextStyle(
                                fontSize: 28,
                                color: isMissedForCurrentDose || isNow
                                    ? Colors.white
                                    : null))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isMissedForCurrentDose
                                ? Colors.red.shade900
                                : null,
                            decoration: isTakenForCurrentDose
                                ? TextDecoration.lineThrough
                                : null)),
                    Text('${med.dosage} • ${med.doseTimes.join(", ")}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.subText)),
                  ],
                ),
              ),
              if (isTakenForCurrentDose)
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 28),
              if (isMissedForCurrentDose)
                const Icon(Icons.warning_rounded,
                    color: Colors.redAccent, size: 28),
              if (isNow)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('NOW',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold))),
            ],
          ),
          if (!isTakenForCurrentDose)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => db.markAsTaken(med),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isNow ? AppColors.blue : Colors.grey.shade100,
                          foregroundColor:
                              isNow ? Colors.white : Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Mark as Taken',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => db.markAsMissed(med),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Mark as Missed',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
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
