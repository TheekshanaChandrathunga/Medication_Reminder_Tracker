import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/report_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? _selectedAction;
  String _selectedPeriod = 'This Week';
  DateTimeRange? _customRange;
  bool _isGeneratingPdf = false;

  DateTimeRange _getReportRange() {
    final now = DateTime.now();

    if (_selectedPeriod == 'This Month') {
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      );
    }

    if (_selectedPeriod == 'Custom' && _customRange != null) {
      return _customRange!;
    }

    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 6)),
      end: now,
    );
  }

  Future<void> _generatePdf(String userId) async {
    if (_isGeneratingPdf) return;

    setState(() {
      _selectedAction = 'Generate PDF';
      _isGeneratingPdf = true;
    });

    try {
      final reportService = Provider.of<ReportService>(context, listen: false);
      final range = _getReportRange();
      final report = await reportService.generateMedicationReport(
        userId: userId,
        startDate: range.start,
        endDate: range.end,
      );
      await reportService.savePdfToDevice(report: report);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF report downloaded successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download PDF: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  DateTime? _logDate(Map<String, dynamic> log) {
    final value = log['takenAt'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  List<Map<String, dynamic>> _filterLogs(List<Map<String, dynamic>> logs) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    if (_selectedPeriod == 'This Month') {
      start = DateTime(now.year, now.month, 1);
    } else if (_selectedPeriod == 'Custom' && _customRange != null) {
      start = DateTime(
        _customRange!.start.year,
        _customRange!.start.month,
        _customRange!.start.day,
      );
      end = DateTime(
        _customRange!.end.year,
        _customRange!.end.month,
        _customRange!.end.day,
        23,
        59,
        59,
      );
    } else {
      start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 6));
    }

    return logs.where((log) {
      final date = _logDate(log);
      return date != null && !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  Future<void> _selectPeriod(String period) async {
    if (period == 'Custom') {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: _customRange,
      );
      if (range == null || !mounted) return;
      setState(() {
        _customRange = range;
        _selectedPeriod = period;
      });
      return;
    }

    setState(() {
      _selectedPeriod = period;
    });
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
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back,
                          size: 20, color: AppColors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Adherence Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: userId == null
                      ? const Center(child: Text('Please login to see reports'))
                      : StreamBuilder<List<Map<String, dynamic>>>(
                          stream: dbService.getAdherenceLogs(userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final logs = _filterLogs(snapshot.data ?? []);
                            final takenCount = logs
                                .where((l) => l['status'] == 'taken')
                                .length;
                            final missedCount = logs
                                .where((l) => l['status'] == 'missed')
                                .length;
                            final total = takenCount + missedCount;
                            final percentage = total == 0
                                ? 0
                                : ((takenCount / total) * 100).round();

                            return ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              children: [
                                _buildReportTabs(),
                                const SizedBox(height: 18),
                                _buildSummaryCard(
                                    takenCount, missedCount, percentage),
                                const SizedBox(height: 18),
                                _buildSectionTitle('Daily Adherence'),
                                const SizedBox(height: 10),
                                _buildWeekStrip(),
                                const SizedBox(height: 18),
                                _buildActionButton(
                                  'Generate PDF',
                                  Icons.picture_as_pdf_rounded,
                                  onTap: () => _generatePdf(userId),
                                  isLoading: _isGeneratingPdf,
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                    'Email Caregiver', Icons.email_outlined),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                    'Export CSV', Icons.file_download_outlined),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
            const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNav(activeTab: 'Reports')),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodTab('This Week'),
          _buildPeriodTab('This Month'),
          _buildPeriodTab('Custom'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _selectPeriod(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              period,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int taken, int missed, int percentage) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Adherence',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF9F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF1F9D68), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  '+2% this week',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1F9D68),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox('Doses Taken', '$taken', true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox('Doses Missed', '$missed', false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, bool taken) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: taken ? const Color(0xFFEAF7F1) : const Color(0xFFFCECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: taken ? const Color(0xFF1F9D68) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText),
        ),
        const Icon(Icons.more_vert, size: 18, color: AppColors.secondaryText),
      ],
    );
  }

  Widget _buildWeekStrip() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final statuses = [true, true, false, true, false, false, true];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(days.length, (index) {
          final isDone = statuses[index];
          return Column(
            children: [
              Text(
                days[index],
                style: const TextStyle(
                    fontSize: 11, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 10),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF1F9D68)
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isDone ? Icons.check : Icons.close,
                    size: 14,
                    color: isDone ? Colors.white : AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final isSelected = _selectedAction == label;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.blue : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLoading
            ? null
            : onTap ??
                () {
                  setState(() {
                    _selectedAction = label;
                  });
                },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isSelected ? Colors.white : AppColors.primaryText,
                ),
              )
            else
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primaryText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
