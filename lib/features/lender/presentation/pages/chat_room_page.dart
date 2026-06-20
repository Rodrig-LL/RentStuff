import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;

  const ChatRoomPage({
    super.key,
    required this.roomId,
  });

  @override
  State<ChatRoomPage> createState() =>
      _ChatRoomPageState();
}

class _ChatRoomPageState
    extends State<ChatRoomPage> {
  final controller =
      TextEditingController();

  Future<void> sendMessage() async {
    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    final uid =
        FirebaseAuth.instance
                .currentUser
                ?.uid ??
            '';

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'sender_id': uid,
      'text': text,
      'created_at':
          FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomId)
        .update({
      'last_message': text,
      'last_message_at':
          FieldValue.serverTimestamp(),
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance
                .currentUser
                ?.uid ??
            '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                StreamBuilder<
                    QuerySnapshot>(
              stream:
                  FirebaseFirestore
                      .instance
                      .collection(
                          'chat_rooms')
                      .doc(widget.roomId)
                      .collection(
                          'messages')
                      .orderBy(
                        'created_at',
                        descending:
                            false,
                      )
                      .snapshots(),
              builder:
                  (context, snapshot) {
                if (!snapshot
                    .hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot
                        .data!
                        .docs;

                return ListView.builder(
                  itemCount:
                      docs.length,
                  itemBuilder:
                      (_, index) {
                    final data =
                        docs[index]
                                .data()
                            as Map<
                                String,
                                dynamic>;

                    final isMe =
                        data['sender_id'] ==
                            uid;

                    return Align(
                      alignment:
                          isMe
                              ? Alignment
                                  .centerRight
                              : Alignment
                                  .centerLeft,
                      child:
                          Container(
                        margin:
                            const EdgeInsets.all(
                                8),
                        padding:
                            const EdgeInsets.all(
                                12),
                        decoration:
                            BoxDecoration(
                          color:
                              isMe
                                  ? Colors
                                      .blue
                                  : Colors
                                      .grey
                                      .shade300,
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        child: Text(
                          data['text'] ??
                              '',
                          style:
                              TextStyle(
                            color:
                                isMe
                                    ? Colors
                                        .white
                                    : Colors
                                        .black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                      8),
              child: Row(
                children: [
                  Expanded(
                    child:
                        TextField(
                      controller:
                          controller,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Tulis pesan...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                    ),
                    onPressed:
                        sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}