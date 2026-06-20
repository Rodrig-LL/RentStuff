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

final borrowerChatRoomsProvider =
    StreamProvider.autoDispose<List<ChatRoomModel>>((ref) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  if (currentUserId.isEmpty) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .where('participants', arrayContains: currentUserId)
      .snapshots()
      .map((snapshot) {
    final rooms = snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatRoomModel(
        id: doc.id,
        otherName: data['other_name'] ?? 'Pengguna',
        lastMessage: data['last_message'] ?? 'Mulai percakapan...',
        lastMessageAt:
            (data['last_message_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        unread: data['unread'] ?? 0,
      );
    }).toList();

    rooms.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return rooms;
  });
});

class BorrowerChatPage extends ConsumerWidget {
  const BorrowerChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(borrowerChatRoomsProvider);

    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
            ),
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 18),
            width: double.infinity,
            child: const Center(
              child: Text('Pesan',
                  style: TextStyle(
                      color: Color(0xFF376BE0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: chatRoomsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF376BE0))),
              error: (error, stack) =>
                  Center(child: Text('Terjadi kesalahan: $error')),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Belum ada pesan',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 72,
                      color: Colors.grey.withOpacity(0.2)),
                  itemBuilder: (_, i) {
                    final room = rooms[i];
                    final timeString =
                        '${room.lastMessageAt.hour.toString().padLeft(2, '0')}:${room.lastMessageAt.minute.toString().padLeft(2, '0')}';

                    return InkWell(
                      onTap: () => context.push('/chats/${room.id}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFECF1FF)),
                              child: Center(
                                child: Text(
                                  room.otherName.isNotEmpty
                                      ? room.otherName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF376BE0),
                                      fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(room.otherName,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(room.lastMessage,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(timeString,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 4),
                                if (room.unread > 0)
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        color: Color(0xFF376BE0),
                                        shape: BoxShape.circle),
                                    child: Text('${room.unread}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
