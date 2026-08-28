import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String? id;
  final String userId;
  final String name;
  final String dosage;
  final String category;
  final String frequency;
  final List<String> doseTimes;
  final String startDate;
  final String? endDate;
  final String takeWith;
  final String? instructions;
  final int totalQuantity;
  final int refillAlertAt;
  final DateTime? lastTaken;

  Medication({
    this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.category,
    required this.frequency,
    required this.doseTimes,
    required this.startDate,
    this.endDate,
    required this.takeWith,
    this.instructions,
    required this.totalQuantity,
    required this.refillAlertAt,
    this.lastTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'category': category,
      'frequency': frequency,
      'doseTimes': doseTimes,
      'startDate': startDate,
      'endDate': endDate,
      'takeWith': takeWith,
      'instructions': instructions,
      'totalQuantity': totalQuantity,
      'refillAlertAt': refillAlertAt,
      'lastTaken': lastTaken != null ? Timestamp.fromDate(lastTaken!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map, String documentId) {
    // Robust parsing to prevent crashes if Firestore data is inconsistent
    return Medication(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown',
      dosage: map['dosage']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Pill',
      frequency: map['frequency']?.toString() ?? 'Daily',
      doseTimes: map['doseTimes'] != null ? List<String>.from(map['doseTimes']) : [],
      startDate: map['startDate']?.toString() ?? '',
      endDate: map['endDate']?.toString(),
      takeWith: map['takeWith']?.toString() ?? 'Before Meal',
      instructions: map['instructions']?.toString(),
      totalQuantity: int.tryParse(map['totalQuantity']?.toString() ?? '0') ?? 0,
      refillAlertAt: int.tryParse(map['refillAlertAt']?.toString() ?? '0') ?? 0,
      lastTaken: map['lastTaken'] is Timestamp ? (map['lastTaken'] as Timestamp).toDate() : null,
    );
  }
}
