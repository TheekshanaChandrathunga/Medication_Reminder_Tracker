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
      return Stream.value(const <Medication>[]);
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
      return Stream.value([]);
    }

    return _db
        .collection('adherence_logs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

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

  Stream<List<Map<String, dynamic>>> getCaregiverPatients(String caregiverId) {
    if (isSimulation) {
      return Stream.value(const <Map<String, dynamic>>[]);
    }

    return _db
        .collection('caregiver_relationships')
        .where('caregiverId', isEqualTo: caregiverId)
        .snapshots()
        .asyncMap((snapshot) async {
      final patients = await Future.wait(snapshot.docs.map((doc) async {
        final relationship = doc.data();
        final patientId = relationship['patientId']?.toString() ?? '';
        if (patientId.isEmpty) return <String, dynamic>{};

        final profile = await _db.collection('users').doc(patientId).get();
        return {
          ...relationship,
          ...?profile.data(),
          'id': patientId,
        };
      }));

      return patients
          .where((patient) => (patient['id'] as String?)?.isNotEmpty == true)
          .toList();
    });
  }

  Future<void> linkCaregiverPatient(
    String caregiverId,
    String patientId,
    String relationship, {
    Map<String, dynamic>? patientDetails,
  }) async {
    _ensureFirebaseAvailable();

    final patient = await _db.collection('users').doc(patientId).get();
    if (!patient.exists) {
      throw StateError('No patient account exists for this ID');
    }

    final linkId = '${caregiverId}_$patientId';
    await _db.collection('caregiver_relationships').doc(linkId).set({
      'caregiverId': caregiverId,
      'patientId': patientId,
      'relationship': relationship,
      ...?patient.data(),
      ...?patientDetails,
      'monitoringSince': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> getCaregiverNotes(String patientId) {
    if (isSimulation) {
      return Stream.value(const <Map<String, dynamic>>[]);
    }

    return _db
        .collection('caregiver_notes')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  Future<void> addCaregiverNote(
    String patientId,
    String caregiverId,
    String text,
  ) async {
    _ensureFirebaseAvailable();

    await _db.collection('caregiver_notes').add({
      'patientId': patientId,
      'caregiverId': caregiverId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acknowledgeMissedDose(String logId) async {
    _ensureFirebaseAvailable();

    await _db.collection('adherence_logs').doc(logId).update({
      'acknowledged': true,
      'acknowledgedAt': FieldValue.serverTimestamp(),
    });
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
  ) async {
    _ensureFirebaseAvailable();

    await _db.collection('users').doc(userId).set(
      {
        'name': name,
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
    if (isSimulation) {
      return Stream.value({
        'name': 'Demo User',
        'role': 'Patient',
      });
    }

    return _db.collection('users').doc(userId).snapshots().map(
          (snap) => snap.data(),
        );
  }

  void _ensureFirebaseAvailable() {
    if (isSimulation) {
      throw StateError(
        'Firebase is not initialized. Check the Firebase configuration.',
      );
    }
  }
}
