import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';
import 'dart:async';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Set this to TRUE to show the app working without a real Firebase connection
  static const bool isSimulation = true;

  // Add Medication
  Future<void> addMedication(Medication medication) async {
    if (isSimulation) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await _db.collection('medications').add(medication.toMap());
  }

  // Get Medications
  Stream<List<Medication>> getMedications(String userId) {
    if (isSimulation) {
      return Stream.value([
        Medication(
          id: '1', userId: userId, name: 'Aspirin', dosage: '81mg', 
          category: 'Pill', frequency: 'Daily', doseTimes: ['08:00 AM'], 
          startDate: '2023-10-24', takeWith: 'With Food', totalQuantity: 30, refillAlertAt: 5
        ),
        Medication(
          id: '2', userId: userId, name: 'Metformin', dosage: '500mg', 
          category: 'Pill', frequency: 'Daily', doseTimes: ['07:00 PM'], 
          startDate: '2023-10-24', takeWith: 'After Meal', totalQuantity: 3, refillAlertAt: 10
        ),
      ]);
    }
    return _db.collection('medications').where('userId', isEqualTo: userId).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Medication.fromMap(doc.data(), doc.id)).toList());
  }

  // Get User Profile
  Stream<Map<String, dynamic>?> getUserProfile(String userId) {
    if (isSimulation) {
      return Stream.value({
        'name': 'Demo User',
        'email': 'demo@example.com',
        'role': 'Patient',
      });
    }
    return _db.collection('users').doc(userId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return snap.data() as Map<String, dynamic>?;
    });
  }

  // Mark as Taken
  Future<void> markAsTaken(Medication med) async {
    if (isSimulation) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    final medRef = _db.collection('medications').doc(med.id);
    return _db.runTransaction((transaction) async {
      DocumentSnapshot snap = await transaction.get(medRef);
      if (!snap.exists) return;
      int stock = int.tryParse(snap.get('totalQuantity').toString()) ?? 0;
      transaction.update(medRef, {
        'lastTaken': FieldValue.serverTimestamp(),
        'totalQuantity': stock > 0 ? stock - 1 : 0,
      });
    });
  }

  // Mark as Missed
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
    if (isSimulation) {
      return Stream.value([
        {
          'medicationName': 'Aspirin', 
          'takenAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))), 
          'status': 'taken'
        },
        {
          'medicationName': 'Metformin', 
          'takenAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))), 
          'status': 'missed'
        },
      ]);
    }
    return _db.collection('adherence_logs').where('userId', isEqualTo: userId).snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> refillMedication(String medId, int amount) async {
    if (isSimulation) return;
    await _db.collection('medications').doc(medId).update({'totalQuantity': FieldValue.increment(amount)});
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
    await _db.collection('users').doc(userId).update({'name': name, 'role': role});
  }
}
