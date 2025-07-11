

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';

class ClinicShiftsScreen extends StatelessWidget {
  const ClinicShiftsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Shifts')),
      body: StreamBuilder<List<Job>>(
        stream: JobService().streamJobsForClinic(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, '/clinic-post-job'
                ),
                child: const Text('No shifts yet. Post your first shift'),
              ),
            );
          }
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final start = job.start;
              final end = job.end;
              final dateRange =
                  '${start.month}/${start.day}/${start.year} - ${end.month}/${end.day}/${end.year}';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(job.description),
                  subtitle: Text('$dateRange\n\$${job.rate.toStringAsFixed(2)}/hr'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: navigate to edit shift screen
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