// lib/features/chat/presentation/pages/chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Stream from Firebase Firestore
    final mockChats = [
      _MockChat(id: 'chat1', otherName: 'Budi Santoso', lastMessage: 'Oke siap, bisa diambil jam 9 pagi', unread: 2, time: '10:30'),
      _MockChat(id: 'chat2', otherName: 'Rina Wijaya', lastMessage: 'Terima kasih sudah menyewa!', unread: 0, time: 'Kemarin'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pesan')),
      body: mockChats.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('Belum ada pesan', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: mockChats.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider, indent: 72),
              itemBuilder: (_, i) => _ChatTile(
                chat: mockChats[i],
                onTap: () => context.go('/chats/${mockChats[i].id}'),
              ),
            ),
    );
  }
}

class _MockChat {
  final String id, otherName, lastMessage, time;
  final int unread;
  _MockChat({required this.id, required this.otherName, required this.lastMessage, required this.unread, required this.time});
}

class _ChatTile extends StatelessWidget {
  final _MockChat chat;
  final VoidCallback onTap;
  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primaryLight,
        child: Text(chat.otherName[0], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 18)),
      ),
      title: Text(chat.otherName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(chat.time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          if (chat.unread > 0)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Text('${chat.unread}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
