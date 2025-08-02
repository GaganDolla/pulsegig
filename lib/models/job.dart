

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a shift/job posted by a clinic.
class Job {
  final String id;
  final String clinicId;
  final String clinicName;
  final String description;
  final DateTime start;
  final DateTime end;
  final double rate;

  Job({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.description,
    required this.start,
    required this.end,
    required this.rate,
  });

  /// Converts Firestore document data into a Job instance.
  factory Job.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Job(
      id: doc.id,
      clinicId: data['clinicId'] as String,
      clinicName: data['clinicName'] as String,
      description: data['description'] as String,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
      rate: (data['rate'] as num).toDouble(),
    );
  }

  /// Converts this Job into a map suitable for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'clinicName': clinicName,
      'description': description,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'rate': rate,
    };
  }
}