import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 8),
                        child: const Text('📋', style: TextStyle(fontSize: 16)),
                      ),
                      const Text('Adherence History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue)),
                    ],
                  ),
                ),

                // Logs List
                Expanded(
                  child: userId == null
                      ? const Center(child: Text("Please login to see history"))
                      : StreamBuilder<List<Map<String, dynamic>>>(
                          stream: dbService.getAdherenceLogs(userId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            final logs = snapshot.data ?? [];
                            
                            if (logs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    const Text("No history recorded yet.", style: TextStyle(color: AppColors.subText)),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                final dynamic rawTimestamp = log['takenAt'];
                                
                                String dateStr = 'Unknown date';
                                String timeStr = '';
                                
                                if (rawTimestamp is Timestamp) {
                                  final DateTime takenAt = rawTimestamp.toDate();
                                  dateStr = DateFormat('MMM dd, yyyy').format(takenAt);
                                  timeStr = DateFormat('hh:mm a').format(takenAt);
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.inputBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Color(0xFF38A169), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log['medicationName'] ?? 'Unknown Medication',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            Text(
                                              'Taken on $dateStr at $timeStr',
                                              style: const TextStyle(color: AppColors.subText, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(activeTab: 'History')),
          ],
        ),
      ),
    );
  }
}
