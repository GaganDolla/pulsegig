import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

/// Service to manage Job (shift) creation and queries.
class JobService {
  final CollectionReference<Map<String, dynamic>> _jobsCol =
      FirebaseFirestore.instance.collection('jobs');

  /// Creates a new job document under the authenticated clinic ID.
  Future<void> createJob(Job job) async {
    await _jobsCol.add(job.toMap());
  }

  /// Streams all jobs for a given clinic (by clinicId).
  Stream<List<Job>> streamJobsForClinic(String clinicId) {
    return _jobsCol
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }
}