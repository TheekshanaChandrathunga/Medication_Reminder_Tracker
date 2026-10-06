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
    required this.allLogs,
    required this.patientProfile,
    required this.csvBytes,
    required this.pdfBytes,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<Medication> medications;
  final List<Map<String, dynamic>> logs;
  final List<Map<String, dynamic>> allLogs;
  final Map<String, dynamic> patientProfile;
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
    final allLogs = results[1]
        .docs
        .map((doc) => {
              ...doc.data(),
              'id': doc.id,
            })
        .toList()
      ..sort((a, b) =>
          (_logDate(b) ?? DateTime(0)).compareTo(_logDate(a) ?? DateTime(0)));
    final logs = allLogs.where((log) {
      final date = _logDate(log);
      return date != null && !date.isBefore(start) && !date.isAfter(end);
    }).toList();
    final patientProfile =
        (await _firestore.collection('users').doc(userId).get()).data() ?? {};

    final csvBytes =
        Uint8List.fromList(utf8.encode(_buildCsv(medications, logs)));
    final report = MedicationReport(
      startDate: start,
      endDate: end,
      medications: medications,
      logs: logs,
      allLogs: allLogs,
      patientProfile: patientProfile,
      csvBytes: csvBytes,
      pdfBytes: Uint8List(0),
    );

    return MedicationReport(
      startDate: report.startDate,
      endDate: report.endDate,
      medications: report.medications,
      logs: report.logs,
      allLogs: report.allLogs,
      patientProfile: report.patientProfile,
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
          pw.Text('Patient information',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Field', 'Value'],
            data: _patientProfileRows(report.patientProfile),
          ),
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
            data: report.logs.isEmpty
                ? [
                    ['No events in selected period', '', '']
                  ]
                : report.logs
                    .map((log) => [
                          log['medicationName']?.toString() ?? 'Unknown',
                          log['status']?.toString() ?? 'Unknown',
                          _logDate(log)?.toIso8601String() ?? 'Unknown',
                        ])
                    .toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Text('Complete medication history',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Medication', 'Status', 'Recorded at'],
            data: report.allLogs.isEmpty
                ? [
                    ['No medication history available', '', '']
                  ]
                : report.allLogs
                    .map((log) => [
                          log['medicationName']?.toString() ?? 'Unknown',
                          log['status']?.toString() ?? 'Unknown',
                          _logDate(log)?.toIso8601String() ?? 'Unknown',
                        ])
                    .toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Text('Current medications',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Medication', 'Dosage', 'Frequency', 'Schedule'],
            data: report.medications.isEmpty
                ? [
                    ['No current medications', '', '', '']
                  ]
                : report.medications
                    .map((medication) => [
                          medication.name,
                          medication.dosage,
                          medication.frequency,
                          medication.doseTimes.join(', '),
                        ])
                    .toList(),
          ),
        ],
      ),
    );
    return document.save();
  }

  List<List<String>> _patientProfileRows(Map<String, dynamic> profile) {
    const fields = [
      ('name', 'Name'),
      ('email', 'Email'),
      ('phone', 'Phone'),
      ('age', 'Age'),
      ('gender', 'Gender'),
      ('address', 'Address'),
      ('medicalConditions', 'Medical conditions'),
      ('allergies', 'Allergies'),
      ('emergencyContactName', 'Emergency contact'),
      ('emergencyContactPhone', 'Emergency phone'),
    ];

    final rows = fields
        .where(
            (field) => profile[field.$1]?.toString().trim().isNotEmpty == true)
        .map((field) => [field.$2, profile[field.$1].toString()])
        .toList();
    return rows.isEmpty
        ? [
            ['No patient information available', '']
          ]
        : rows;
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
