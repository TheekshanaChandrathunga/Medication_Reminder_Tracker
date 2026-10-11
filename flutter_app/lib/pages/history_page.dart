import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.caregiverMode = false});

  final bool caregiverMode;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? _selectedPatientId;

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
                      left: 20, right: 20, top: 16, bottom: 10),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 8),
                        child: const Icon(Icons.history_rounded,
                            size: 18, color: AppColors.blue),
                      ),
                      const Text('Adherence History',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.blue)),
                    ],
                  ),
                ),

                // Logs List
                Expanded(
                  child: userId == null
                      ? const Center(child: Text("Please login to see history"))
                      : widget.caregiverMode
                          ? _buildCaregiverHistory(context, dbService, userId)
                          : _buildHistoryLogs(dbService, userId),
                ),
              ],
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNav(
                  activeTab: 'History',
                  caregiverMode: widget.caregiverMode,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCaregiverHistory(
    BuildContext context,
    DatabaseService dbService,
    String caregiverId,
  ) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: dbService.getCaregiverPatients(caregiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final patients = snapshot.data ?? [];
        if (patients.isEmpty) {
          return const Center(child: Text('No patients linked yet.'));
        }
        final selected = patients.firstWhere(
          (patient) => patient['id'] == _selectedPatientId,
          orElse: () => patients.first,
        );
        final patientId = selected['id'] as String;
        if (_selectedPatientId != patientId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedPatientId = patientId);
          });
        }

        return Column(
          children: [
            _patientSelector(patients, patientId),
            Expanded(child: _buildHistoryLogs(dbService, patientId)),
          ],
        );
      },
    );
  }

  Widget _patientSelector(
    List<Map<String, dynamic>> patients,
    String selectedPatientId,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedPatientId,
            isExpanded: true,
            icon: const Icon(Icons.expand_more, color: AppColors.blue),
            onChanged: (value) {
              if (value != null) setState(() => _selectedPatientId = value);
            },
            items: patients.map((patient) {
              return DropdownMenuItem<String>(
                value: patient['id'] as String,
                child: Text((patient['name'] ?? 'Patient').toString()),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryLogs(DatabaseService dbService, String patientId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: dbService.getAdherenceLogs(patientId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final logs = snapshot.data ?? [];

                            if (logs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history,
                                        size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    const Text("No history recorded yet.",
                                        style: TextStyle(
                                            color: AppColors.subText)),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                final dynamic rawTimestamp = log['takenAt'];
                                final String status = log['status'] ?? 'taken';
                                final bool isTaken = status == 'taken';

                                String dateStr = 'Unknown date';
                                String timeStr = '';

                                if (rawTimestamp is Timestamp) {
                                  final DateTime takenAt =
                                      rawTimestamp.toDate();
                                  dateStr = DateFormat('MMM dd, yyyy')
                                      .format(takenAt);
                                  timeStr =
                                      DateFormat('hh:mm a').format(takenAt);
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.inputBorder),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.02),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                          isTaken
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: isTaken
                                              ? const Color(0xFF38A169)
                                              : Colors.redAccent,
                                          size: 28),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log['medicationName'] ??
                                                  'Unknown Medication',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                            Text(
                                              '${isTaken ? 'Taken' : 'Missed'} on $dateStr at $timeStr',
                                              style: const TextStyle(
                                                  color: AppColors.subText,
                                                  fontSize: 12),
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
                        );
  }
}
