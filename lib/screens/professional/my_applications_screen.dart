import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Screen that lists all applications the professional has submitted.
class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Applications')),
        body: const Center(child: Text('Please sign in to view your applications.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('professionalId', isEqualTo: user.uid)
            .orderBy('appliedAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No applications found.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final jobId = data['jobId'] as String? ?? '';
              final status = data['status'] as String? ?? 'Pending';
              final appliedAt = (data['appliedAt'] as Timestamp?)?.toDate();

              return ListTile(
                title: Text('Job: $jobId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (appliedAt != null)
                      Text('Applied: ${appliedAt.month}/${appliedAt.day}/${appliedAt.year}'),
                    Text('Status: $status'),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  // TODO: navigate to application detail or job detail
                },
              );
            },
          );
        },
      ),
    );
  }
}