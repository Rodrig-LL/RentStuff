import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatRoomModel {
  final String id;
  final String otherName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unread;

  ChatRoomModel({
    required this.id,
    required this.otherName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unread,
  });
}

final chatRoomsProvider =
    StreamProvider.autoDispose<List<ChatRoomModel>>((ref) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .orderBy('last_message_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      String opponentName = 'Pengguna';
      if (data['borrower_id'] == currentUserId) {
        opponentName = data['lender_name'] ?? 'Pemilik Barang';
      } else {
        opponentName = data['borrower_name'] ?? 'Penyewa';
      }

      return ChatRoomModel(
        id: doc.id,
        otherName: opponentName,
        lastMessage: data['last_message'] ?? 'Mulai percakapan...',
        lastMessageAt:
            (data['last_message_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        unread: data['unread'] ?? 0,
      );
    }).toList();
  });
});

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Pesan',
            style: TextStyle(
                color: Color(0xFF123BCA), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black12, height: 1),
        ),
      ),
      body: chatRoomsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF123BCA))),
        error: (error, stack) =>
            Center(child: Text('Terjadi kesalahan: $error')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('Belum ada pesan',
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Colors.black12, indent: 72),
            itemBuilder: (_, i) {
              final room = rooms[i];
              return _ChatTile(
                chat: room,
                onTap: () {
                  context.push('/chats/${room.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatRoomModel chat;
  final VoidCallback onTap;

  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${chat.lastMessageAt.hour.toString().padLeft(2, '0')}:${chat.lastMessageAt.minute.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFFECF1FF),
        child: Text(
            chat.otherName.isNotEmpty ? chat.otherName[0].toUpperCase() : 'U',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF123BCA),
                fontSize: 18)),
      ),
      title: Text(chat.otherName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, fontSize: 13)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeString,
              style: const TextStyle(fontSize: 11, color: Colors.black45)),
          const SizedBox(height: 4),
          if (chat.unread > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Color(0xFF123BCA), shape: BoxShape.circle),
              child: Text('${chat.unread}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
