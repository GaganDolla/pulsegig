import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/job.dart';

/// Screen that lists all available shifts for professionals.
class AvailableShiftsScreen extends StatelessWidget {
  const AvailableShiftsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Available Shifts')),
        body: const Center(child: Text('Please sign in to view shifts.')),
      );
    }

    // Stream all future jobs (where end time is after now)
    return Scaffold(
      appBar: AppBar(title: const Text('Available Shifts')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('end', isGreaterThan: Timestamp.fromDate(DateTime.now()))
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error loading shifts: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No available shifts at the moment.'));
          }
          final jobs = docs
              .map((d) => Job.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
              .toList();
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (ctx, index) {
              final job = jobs[index];
              final dateRange =
                  '${job.start.month}/${job.start.day}/${job.start.year} - '
                  '${job.end.month}/${job.end.day}/${job.end.year}';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(job.description),
                  subtitle: Text('$dateRange\n\$${job.rate.toStringAsFixed(2)}/hr'),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    child: const Text('Apply'),
                    onPressed: () {
                      // TODO: implement application logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Application feature coming soon!')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}