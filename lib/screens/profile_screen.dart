import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

/// Screen that displays and allows editing of the current user’s profile.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadProfile() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _loadProfile(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData || snap.data?.data() == null) {
            return Center(child: Text('Error loading profile: ${snap.error}'));
          }
          final data = snap.data!.data()!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name']}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Email: ${data['email']}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Role: ${data['role']}', style: Theme.of(context).textTheme.bodyMedium),
                if (data['role'] == 'professional' && data['credentials'] != null) ...[
                  const SizedBox(height: 8),
                  Text('Credentials: ${data['credentials']}', style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (data['role'] == 'office' && data['businessRegistration'] != null) ...[
                  const SizedBox(height: 8),
                  Text('Business Reg #: ${data['businessRegistration']}', style: Theme.of(context).textTheme.bodyMedium),
                ],
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: navigate to profile edit screen
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}