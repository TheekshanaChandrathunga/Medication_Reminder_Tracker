import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Medication
  Future<void> addMedication(Medication medication) async {
    try {
      await _db.collection('medications').add(medication.toMap());
    } catch (e) {
      print("Error adding medication: $e");
      rethrow;
    }
  }

  // Get Medications for a specific user
  Stream<List<Medication>> getMedications(String userId) {
    return _db
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mark medication as taken
  Future<void> markAsTaken(String medId) async {
    try {
      await _db.collection('medications').doc(medId).update({
        'lastTaken': FieldValue.serverTimestamp(),
      });
      
      // Log this in an adherence history collection
      await _db.collection('adherence_logs').add({
        'medicationId': medId,
        'takenAt': FieldValue.serverTimestamp(),
        'status': 'taken',
      });
    } catch (e) {
      print("Error marking as taken: $e");
      rethrow;
    }
  }

  // Update Medication
  Future<void> updateMedication(Medication medication) async {
    if (medication.id == null) return;
    try {
      await _db
          .collection('medications')
          .doc(medication.id)
          .update(medication.toMap());
    } catch (e) {
      print("Error updating medication: $e");
      rethrow;
    }
  }

  // Delete Medication
  Future<void> deleteMedication(String medId) async {
    try {
      await _db.collection('medications').doc(medId).delete();
    } catch (e) {
      print("Error deleting medication: $e");
      rethrow;
    }
  }
}
