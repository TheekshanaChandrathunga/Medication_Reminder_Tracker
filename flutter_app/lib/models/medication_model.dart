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
  final DateTime? lastTaken; // Track last adherence

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
    return Medication(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      category: map['category'] ?? '',
      frequency: map['frequency'] ?? '',
      doseTimes: List<String>.from(map['doseTimes'] ?? []),
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'],
      takeWith: map['takeWith'] ?? '',
      instructions: map['instructions'],
      totalQuantity: map['totalQuantity'] ?? 0,
      refillAlertAt: map['refillAlertAt'] ?? 0,
      lastTaken: map['lastTaken'] != null ? (map['lastTaken'] as Timestamp).toDate() : null,
    );
  }
}
