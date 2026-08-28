import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
                  child: const Row(
                    children: [
                      Text('Adherence Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue)),
                    ],
                  ),
                ),

                Expanded(
                  child: userId == null
                      ? const Center(child: Text("Please login to see reports"))
                      : StreamBuilder<List<Map<String, dynamic>>>(
                          stream: dbService.getAdherenceLogs(userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            final logs = snapshot.data ?? [];
                            final takenCount = logs.where((l) => l['status'] == 'taken').length;
                            final missedCount = logs.where((l) => l['status'] == 'missed').length;
                            final total = takenCount + missedCount;
                            final percentage = total == 0 ? 0 : (takenCount / total * 100).toInt();

                            return ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildSummaryCard(takenCount, missedCount, percentage),
                                const SizedBox(height: 24),
                                const Text('Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                _buildInsightTile(
                                  icon: Icons.trending_up,
                                  color: Colors.green,
                                  title: 'Consistency',
                                  subtitle: percentage > 80 ? 'Excellent! You are staying on track.' : 'Try to improve your daily routine.',
                                ),
                                _buildInsightTile(
                                  icon: Icons.inventory_2_outlined,
                                  color: AppColors.blue,
                                  title: 'Stock Management',
                                  subtitle: 'Keep your inventory updated for better tracking.',
                                ),
                                const SizedBox(height: 100),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(activeTab: 'Reports')),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int taken, int missed, int percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Overall Adherence', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text('$percentage%', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Taken', taken.toString(), Colors.greenAccent),
              _buildStatColumn('Missed', missed.toString(), Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildInsightTile({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
