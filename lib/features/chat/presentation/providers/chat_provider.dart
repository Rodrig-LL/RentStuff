import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomsProvider =
    StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .orderBy(
        'last_message_at',
        descending: true,
      )
      .snapshots();
});

final chatMessagesProvider =
    StreamProvider.family<QuerySnapshot, String>(
  (ref, roomId) {
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('created_at')
        .snapshots();
  },
);