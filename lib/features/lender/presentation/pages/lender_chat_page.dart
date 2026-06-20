import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LenderChatPage extends ConsumerWidget {
  const LenderChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final String currentUserId = user?.id ?? 'lender_demo_123';

    print("Mencari chat dengan lender_id: $currentUserId");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Masuk (Pemilik)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .orderBy(
              'last_message_at',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final rooms = snapshot.data!.docs;

          if (rooms.isEmpty) {
            return const Center(
              child: Text('Belum ada pesan masuk dari penyewa.'),
            );
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (_, index) {
              final room = rooms[index];
              final data = room.data() as Map<String, dynamic>;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF123BCA),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  data['borrower_name'] ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data['last_message'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  context.push(
                    '/chats/${room.id}',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
