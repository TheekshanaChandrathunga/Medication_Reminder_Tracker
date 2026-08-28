import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Medication
  Future<void> addMedication(Medication medication) async {
    try {
      await _db.collection('medications').add(medication.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get Medications for user
  Stream<List<Medication>> getMedications(String userId) {
    return _db
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get User Profile with explicit type
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // Mark as Taken with Stock Management (Atomic Transaction)
  Future<void> markAsTaken(Medication med) async {
    if (med.id == null) return;
    
    final medRef = _db.collection('medications').doc(med.id);
    final logRef = _db.collection('adherence_logs').doc();

    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(medRef);
      if (!snapshot.exists) throw Exception("Medication does not exist!");

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

  // Mark as Missed
  Future<void> markAsMissed(Medication med) async {
    try {
      await _db.collection('adherence_logs').add({
        'userId': med.userId,
        'medicationId': med.id,
        'medicationName': med.name,
        'takenAt': FieldValue.serverTimestamp(),
        'status': 'missed',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get Adherence Logs
  Stream<List<Map<String, dynamic>>> getAdherenceLogs(String userId) {
    return _db
        .collection('adherence_logs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final logs = snapshot.docs.map((doc) => doc.data()).toList();
          logs.sort((a, b) {
            Timestamp tA = a['takenAt'] as Timestamp;
            Timestamp tB = b['takenAt'] as Timestamp;
            return tB.compareTo(tA);
          });
          return logs;
        });
  }

  // Refill Stock
  Future<void> refillMedication(String medId, int amount) async {
    try {
      await _db.collection('medications').doc(medId).update({
        'totalQuantity': FieldValue.increment(amount),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete Medication
  Future<void> deleteMedication(String medId) async {
    try {
      await _db.collection('medications').doc(medId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Update Medication Details
  Future<void> updateMedication(Medication medication) async {
    if (medication.id == null) return;
    try {
      await _db.collection('medications').doc(medication.id).update(medication.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update Profile
  Future<void> updateProfile(String userId, String name, String role) async {
    try {
      await _db.collection('users').doc(userId).update({
        'name': name,
        'role': role,
      });
    } catch (e) {
      rethrow;
    }
  }
}
