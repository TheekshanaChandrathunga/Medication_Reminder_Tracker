import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/medication_model.dart';
import 'dart:async';

class DatabaseService {
  // Set to FALSE to use your live Firebase configuration
  static bool get isSimulation => Firebase.apps.isEmpty;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // --- MEDICATION OPERATIONS ---

  Future<void> addMedication(Medication medication) async {
    if (isSimulation) return;
    await _db.collection('medications').add(medication.toMap());
  }

  Stream<List<Medication>> getMedications(String userId) {
    if (isSimulation) {
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
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mark as Taken (Atomic Stock Management)
  Future<void> markAsTaken(Medication med) async {
    if (isSimulation || med.id == null) return;
    final medRef = _db.collection('medications').doc(med.id);
    final logRef = _db.collection('adherence_logs').doc();

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(medRef);
      int currentStock = int.tryParse(snapshot.get('totalQuantity').toString()) ?? 0;
      
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
    if (isSimulation) return;
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
    return _db.collection('adherence_logs')
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
    if (isSimulation) return;
    await _db.collection('medications').doc(medId).update({
      'totalQuantity': FieldValue.increment(amount),
    });
  }

  Future<void> deleteMedication(String medId) async {
    if (isSimulation) return;
    await _db.collection('medications').doc(medId).delete();
  }

  Future<void> updateMedication(Medication medication) async {
    if (isSimulation || medication.id == null) return;
    await _db.collection('medications').doc(medication.id).update(medication.toMap());
  }

  Future<void> updateProfile(String userId, String name, String role) async {
    if (isSimulation) return;
    await _db.collection('users').doc(userId).set({
      'name': name,
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> uploadProfileImage(String userId, Uint8List imageBytes) async {
    _ensureFirebaseAvailable();
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$userId.jpg');
    await imageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    final photoUrl = await imageRef.getDownloadURL();
    await _db.collection('users').doc(userId).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getUserProfile(String userId) {
    if (isSimulation) return Stream.value({'name': 'Demo User', 'role': 'Patient'});
    return _db.collection('users').doc(userId).snapshots().map((snap) => snap.data() as Map<String, dynamic>?);
<<<<<<< Updated upstream
=======
  }

  void _ensureFirebaseAvailable() {
    if (isSimulation) {
      throw StateError('Firebase is not initialized. Check the Firebase configuration.');
    }
>>>>>>> Stashed changes
  }
}
