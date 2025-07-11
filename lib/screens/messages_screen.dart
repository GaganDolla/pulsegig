import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A placeholder screen showing the current user's message threads.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: Center(child: const Text('You must be signed in to view messages.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user.uid)
            .orderBy('lastTimestamp', descending: true)
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
            return Center(child: Text('No messages yet.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final chatId = docs[index].id;
              final title = data['title'] as String? ?? 'Chat';
              final lastMessage = data['lastMessage'] as String? ?? '';
              final timestamp = data['lastTimestamp'] as Timestamp?;
              return ListTile(
                title: Text(title),
                subtitle: Text(lastMessage),
                trailing: timestamp != null
                    ? Text(
                        TimeOfDay.fromDateTime(timestamp.toDate())
                            .format(context),
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                onTap: () {
                  // TODO: navigate to detailed chat view
                  // Navigator.pushNamed(context, '/chat-detail', arguments: chatId);
                },
              );
            },
          );
        },
      ),
    );
  }
}