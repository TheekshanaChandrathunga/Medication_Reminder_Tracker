import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/medication_model.dart';

class MedicationReport {
  MedicationReport({
    required this.startDate,
    required this.endDate,
    required this.medications,
    required this.logs,
    required this.csvBytes,
    required this.pdfBytes,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<Medication> medications;
  final List<Map<String, dynamic>> logs;
  final Uint8List csvBytes;
  final Uint8List pdfBytes;

  int get takenCount => logs.where((log) => log['status'] == 'taken').length;
  int get missedCount => logs.where((log) => log['status'] == 'missed').length;
  int get totalDoses => takenCount + missedCount;

  int get adherencePercentage =>
      totalDoses == 0 ? 0 : ((takenCount / totalDoses) * 100).round();
}

class ReportService {
  ReportService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  Future<MedicationReport> generateMedicationReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _validateRange(userId, startDate, endDate);
    _ensureFirebaseAvailable();

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    final results = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      _firestore
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .get(),
      _firestore
          .collection('adherence_logs')
          .where('userId', isEqualTo: userId)
          .get(),
    ]);

    final medications = results[0]
        .docs
        .map((doc) => Medication.fromMap(doc.data(), doc.id))
        .toList();
    final logs = results[1].docs.map((doc) => doc.data()).where((log) {
      final date = _logDate(log);
      return date != null && !date.isBefore(start) && !date.isAfter(end);
    }).toList()
      ..sort((a, b) =>
          (_logDate(b) ?? DateTime(0)).compareTo(_logDate(a) ?? DateTime(0)));

    final csvBytes =
        Uint8List.fromList(utf8.encode(_buildCsv(medications, logs)));
    final report = MedicationReport(
      startDate: start,
      endDate: end,
      medications: medications,
      logs: logs,
      csvBytes: csvBytes,
      pdfBytes: Uint8List(0),
    );

    return MedicationReport(
      startDate: report.startDate,
      endDate: report.endDate,
      medications: report.medications,
      logs: report.logs,
      csvBytes: report.csvBytes,
      pdfBytes: await _buildPdf(report),
    );
  }

  Future<String> uploadPdf({
    required String userId,
    required MedicationReport report,
  }) async {
    _ensureFirebaseAvailable();
    final reportId =
        '${report.startDate.millisecondsSinceEpoch}-${report.endDate.millisecondsSinceEpoch}';
    final reference = _storage.ref('reports/$userId/$reportId.pdf');

    await reference.putData(
      report.pdfBytes,
      SettableMetadata(contentType: 'application/pdf'),
    );

    final downloadUrl = await reference.getDownloadURL();
    await _firestore.collection('reports').doc('$userId-$reportId').set({
      'userId': userId,
      'startDate': Timestamp.fromDate(report.startDate),
      'endDate': Timestamp.fromDate(report.endDate),
      'takenCount': report.takenCount,
      'missedCount': report.missedCount,
      'adherencePercentage': report.adherencePercentage,
      'fileUrl': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  Future<void> savePdfToDevice({
    required MedicationReport report,
  }) async {
    final fileName =
        'medication_report_${_formatDate(report.startDate)}_${_formatDate(report.endDate)}';

    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: report.pdfBytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  DateTime? _logDate(Map<String, dynamic> log) {
    final value = log['takenAt'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _buildCsv(
    List<Medication> medications,
    List<Map<String, dynamic>> logs,
  ) {
    final medicationNames = {
      for (final medication in medications) medication.id: medication.name,
    };
    final rows = <List<String>>[
      ['Medication', 'Status', 'Recorded At'],
      ...logs.map((log) => [
            medicationNames[log['medicationId']] ??
                log['medicationName']?.toString() ??
                'Unknown',
            log['status']?.toString() ?? 'Unknown',
            _logDate(log)?.toIso8601String() ?? '',
          ]),
    ];

    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<Uint8List> _buildPdf(MedicationReport report) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Medication Adherence Report')),
          pw.Text(
              'Period: ${_formatDate(report.startDate)} - ${_formatDate(report.endDate)}'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Metric', 'Value'],
            data: [
              ['Doses taken', '${report.takenCount}'],
              ['Doses missed', '${report.missedCount}'],
              ['Adherence', '${report.adherencePercentage}%'],
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text('Medication events',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Medication', 'Status', 'Recorded at'],
            data: report.logs
                .map((log) => [
                      log['medicationName']?.toString() ?? 'Unknown',
                      log['status']?.toString() ?? 'Unknown',
                      _logDate(log)?.toIso8601String() ?? 'Unknown',
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return document.save();
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _validateRange(String userId, DateTime startDate, DateTime endDate) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('A user id is required');
    }
    if (endDate.isBefore(startDate)) {
      throw ArgumentError(
          'The report end date must not be before its start date');
    }
  }

  void _ensureFirebaseAvailable() {
    if (!isFirebaseAvailable) {
      throw StateError(
          'Firebase is not initialized. Check the Firebase configuration.');
    }
  }
}
