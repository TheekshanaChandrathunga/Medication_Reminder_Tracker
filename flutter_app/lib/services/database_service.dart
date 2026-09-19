import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> markAsTaken(Medication med) async {
    _ensureFirebaseAvailable();
    if (med.id == null) throw StateError('Medication has no document id');
    final medRef = _db.collection('medications').doc(med.id);
    final logRef = _db.collection('adherence_logs').doc();

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(medRef);
      if (!snapshot.exists) return;

      int currentStock =
          int.tryParse(snapshot.get('totalQuantity').toString()) ?? 0;

      transaction.update(medRef, {
        'lastTaken': FieldValue.serverTimestamp(),
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
    await _db.collection('adherence_logs').add({
      'userId': med.userId,
      'medicationId': med.id,
      'medicationName': med.name,
      'takenAt': FieldValue.serverTimestamp(),
      'status': 'missed',
    });
  }

  // Get Adherence Logs
  Stream<List<Map<String, dynamic>>> getAdherenceLogs(String userId) {
    if (isSimulation) return Stream.value([]);
    return _db
        .collection('adherence_logs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs.map((doc) => doc.data()).toList();
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
    if (medication.id == null)
      throw StateError('Medication has no document id');
    await _db
        .collection('medications')
        .doc(medication.id)
        .update(medication.toMap());
  }

  // --- USER PROFILE ---

  Future<void> updateProfile(String userId, String name, String role) async {
    _ensureFirebaseAvailable();
    await _db.collection('users').doc(userId).set({
      'name': name,
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getUserProfile(String userId) {
    if (isSimulation)
      return Stream.value({'name': 'Demo User', 'role': 'Patient'});
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.data() as Map<String, dynamic>?);
  }

  void _ensureFirebaseAvailable() {
    if (isSimulation) {
      throw StateError(
          'Firebase is not initialized. Check the Firebase configuration.');
    }
  }
}
