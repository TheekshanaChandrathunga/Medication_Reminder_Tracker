import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/medication_model.dart';
import 'dart:async';

class DatabaseService {
  // Firebase is initialized once in main.dart before providers are created.
  static bool get isSimulation => Firebase.apps.isEmpty;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // --- MEDICATION OPERATIONS ---

  Future<void> addMedication(Medication medication) async {
    _ensureFirebaseAvailable();
    final medicationRef = _db.collection('medications').doc();
    await medicationRef.set(medication.toMap(includeCreatedAt: true));
  }

  Stream<List<Medication>> getMedications(String userId) {
    if (isSimulation) {
      if (userId == 'sim_patient_1') {
        return Stream.value([
          Medication(id: 'sim_metformin', userId: userId, name: 'Metformin', dosage: '500mg', category: 'Pill', frequency: 'Daily', doseTimes: ['8:00 AM'], startDate: '2023-10-24', takeWith: 'Take with food', totalQuantity: 30, refillAlertAt: 5),
          Medication(id: 'sim_lisinopril', userId: userId, name: 'Lisinopril', dosage: '10mg', category: 'Pill', frequency: 'Daily', doseTimes: ['12:00 PM'], startDate: '2023-10-24', takeWith: 'After lunch', totalQuantity: 24, refillAlertAt: 5),
          Medication(id: 'sim_atorvastatin', userId: userId, name: 'Atorvastatin', dosage: '20mg', category: 'Pill', frequency: 'Daily', doseTimes: ['6:00 PM'], startDate: '2023-10-24', takeWith: 'Before bed', totalQuantity: 24, refillAlertAt: 5),
        ]);
      }
      return Stream.value([
        Medication(
          id: 'sim_1', userId: userId, name: 'Aspirin', dosage: '81mg',
          category: 'Pill', frequency: 'Daily', doseTimes: ['08:00 AM'],
          startDate: '2023-10-24', takeWith: 'With Food', totalQuantity: 24, refillAlertAt: 5
        ),
      ]);
    }

    return _db
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Medication.fromMap(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  Future<void> markAsTaken(Medication med) async {
    _ensureFirebaseAvailable();

    if (med.id == null) {
      throw StateError('Medication has no document id');
    }

    final medRef = _db.collection('medications').doc(med.id);
    final logRef = _db.collection('adherence_logs').doc();

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(medRef);

      if (!snapshot.exists) return;

      int currentStock =
          int.tryParse(snapshot.get('totalQuantity').toString()) ?? 0;

      transaction.update(medRef, {
        'lastTaken': FieldValue.serverTimestamp(),
        'lastMissed': null,
        'totalQuantity': currentStock > 0 ? currentStock - 1 : 0,
      });

      transaction.set(logRef, {
        'userId': med.userId,
        'medicationId': med.id,
        'medicationName': med.name,
        'takenAt': FieldValue.serverTimestamp(),
        'status': 'taken',
      });
    });
  }

  Future<void> markAsMissed(Medication med) async {
    _ensureFirebaseAvailable();

    if (med.id == null) {
      throw StateError('Medication has no document id');
    }

    final medicationRef = _db.collection('medications').doc(med.id);
    final logRef = _db.collection('adherence_logs').doc();
    final batch = _db.batch();

    batch.update(
      medicationRef,
      {
        'lastMissed': FieldValue.serverTimestamp(),
      },
    );

    batch.set(
      logRef,
      {
        'userId': med.userId,
        'medicationId': med.id,
        'medicationName': med.name,
        'takenAt': FieldValue.serverTimestamp(),
        'status': 'missed',
      },
    );

    await batch.commit();
  }

  // Get Adherence Logs
  Stream<List<Map<String, dynamic>>> getAdherenceLogs(String userId) {
    if (isSimulation) {
      if (userId == 'sim_patient_1') {
        return Stream.value([
          for (var index = 0; index < 10; index++)
            {'id': 'sim_taken_$index', 'userId': userId, 'medicationName': 'Medication', 'status': 'taken'},
          {'id': 'sim_missed_1', 'userId': userId, 'medicationName': 'Metformin', 'status': 'missed'},
        ]);
      }
      return Stream.value([]);
    }
    return _db.collection('adherence_logs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final logs = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
          logs.sort((a, b) {
            final tA = a['takenAt'] as Timestamp?;
            final tB = b['takenAt'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tB.compareTo(tA);
          });
          return logs;
        });
  }

  Future<void> refillMedication(String medId, int amount) async {
    _ensureFirebaseAvailable();

    await _db.collection('medications').doc(medId).update({
      'totalQuantity': FieldValue.increment(amount),
    });
  }

  Future<void> deleteMedication(String medId) async {
    _ensureFirebaseAvailable();

    await _db.collection('medications').doc(medId).delete();
  }

  Future<void> updateMedication(Medication medication) async {
    _ensureFirebaseAvailable();

    if (medication.id == null) {
      throw StateError('Medication has no document id');
    }

    await _db
        .collection('medications')
        .doc(medication.id)
        .update(medication.toMap());
  }

  // --- USER PROFILE ---

  Future<void> updateProfile(
    String userId,
    String name,
    String role,
  ) async {
    _ensureFirebaseAvailable();

    await _db.collection('users').doc(userId).set(
      {
        'name': name,
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> uploadProfileImage(
    String userId,
    Uint8List imageBytes,
  ) async {
    _ensureFirebaseAvailable();

    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'A user id is required to upload a profile image',
      );
    }

    if (imageBytes.isEmpty) {
      throw ArgumentError(
        'The profile image is empty',
      );
    }

    final uploadId = DateTime.now().microsecondsSinceEpoch;

    final imageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(userId)
        .child('$uploadId.jpg');

    await imageRef.putData(
      imageBytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'no-cache, max-age=0',
      ),
    );

    final photoUrl = await imageRef.getDownloadURL();

    await _db.collection('users').doc(userId).set(
      {
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<Map<String, dynamic>?> getUserProfile(String userId) {
    if (isSimulation) return Stream.value({'name': 'Demo User', 'role': 'Caregiver'});
    return _db.collection('users').doc(userId).snapshots().map((snap) => snap.data());
  }

  Stream<List<Map<String, dynamic>>> getCaregiverPatients(String caregiverId) {
    if (isSimulation) {
      return Stream.value([
        {'id': 'sim_patient_1', 'name': 'Kamala Perera', 'age': 'Age 72', 'relationship': 'Mother', 'adherence': 92, 'monitoringSince': 'Monitoring since Aug 2023', 'phone': '+94771234567'},
        {'id': 'sim_patient_2', 'name': 'Saman Kumara', 'age': 'Age 65', 'relationship': 'Uncle', 'adherence': 86},
      ]);
    }
    return _db.collection('caregiver_relationships')
        .where('caregiver_id', isEqualTo: caregiverId)
        .snapshots()
        .asyncMap((snapshot) async {
          final patients = await Future.wait(snapshot.docs.map((relationship) async {
            final patientId = relationship.data()['patient_id']?.toString();
            if (patientId == null || patientId.isEmpty) return null;
            final patient = await _db.collection('users').doc(patientId).get();
            final data = patient.data();
            if (!patient.exists || data == null) return null;
            final details = relationship.data()['patient_details'];
            return <String, dynamic>{
              ...data,
              if (details is Map) ...Map<String, dynamic>.from(details),
              'id': patientId,
              'relationship': relationship.data()['relationship'] ?? 'Patient',
            };
          }));
          return patients.whereType<Map<String, dynamic>>().toList();
        });
  }

  Future<void> linkCaregiverPatient(
    String caregiverId,
    String patientId,
    String relationship, {
    Map<String, dynamic> patientDetails = const {},
  }) async {
    if (isSimulation) return;
    await _db.collection('caregiver_relationships').doc('${caregiverId}_$patientId').set({
      'caregiver_id': caregiverId,
      'patient_id': patientId,
      'relationship': relationship,
      'patient_details': patientDetails,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getCaregiverNotes(String patientId) {
    if (isSimulation) {
      return Stream.value([
        {'text': 'Felt slightly dizzy after morning medication yesterday. Will monitor today.', 'created_at': DateTime.now()},
      ]);
    }
    return _db.collection('caregiver_notes')
        .where('patient_id', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addCaregiverNote(String patientId, String caregiverId, String text) async {
    if (isSimulation) return;
    await _db.collection('caregiver_notes').add({
      'patient_id': patientId,
      'caregiver_id': caregiverId,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acknowledgeMissedDose(String logId) async {
    if (isSimulation) return;
    await _db.collection('adherence_logs').doc(logId).update({
      'acknowledged': true,
      'acknowledgedAt': FieldValue.serverTimestamp(),
    });
  }

  void _ensureFirebaseAvailable() {
    if (isSimulation) {
      throw StateError(
        'Firebase is not initialized. Check the Firebase configuration.',
      );
    }
  }
}