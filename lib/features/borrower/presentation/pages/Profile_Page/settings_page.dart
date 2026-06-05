// lib/features/borrower/presentation/pages/Profile_Page/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Status notifikasi tetap pakai state lokal
  bool _isNotifEnabled = true;

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Baca status saklar dari Riverpod
    final currentTheme = ref.watch(themeModeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;

    return Scaffold(
      // 2. Gunakan warna bawaan Theme agar otomatis gelap/terang
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: const Text('Pengaturan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Notifikasi & Sistem'.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Mengikuti tema
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifikasi Push',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Terima pembaruan berkala status sewa',
                      style: TextStyle(fontSize: 11)),
                  value: _isNotifEnabled,
                  activeColor: const Color(0xFF123BCA),
                  onChanged: (v) {
                    setState(() => _isNotifEnabled = v);
                    _showFeedback(
                        v ? 'Notifikasi dihidupkan' : 'Notifikasi dimatikan');
                  },
                ),
                Divider(
                    height: 1, indent: 16, color: Colors.grey.withOpacity(0.2)),
                SwitchListTile(
                  title: const Text('Mode Gelap (Dark Mode)',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  value: isDarkMode, // Terhubung ke saklar
                  activeColor: const Color(0xFF123BCA),
                  onChanged: (bool value) {
                    // 3. UBAH SAKLAR UTAMA RIVERPOD SAAT DITEKAN
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                    _showFeedback(value
                        ? 'Tema gelap diaktifkan'
                        : 'Tema terang diaktifkan');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Informasi Legal Aplikasi'.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildListTile('Bahasa Utama', 'Bahasa Indonesia (ID)', () {
                  _showFeedback('Pengaturan bahasa akan segera tersedia.');
                }),
                Divider(
                    height: 1, indent: 16, color: Colors.grey.withOpacity(0.2)),
                _buildListTile('Kebijakan Privasi Ketentuan', '', () {
                  _showFeedback('Membuka dokumen Kebijakan Privasi...');
                }),
                Divider(
                    height: 1, indent: 16, color: Colors.grey.withOpacity(0.2)),
                _buildListTile('Tentang Aplikasi RentStuff', 'v1.0.0 Stable',
                    () {
                  _showFeedback(
                      'Sistem operasi RentStuff versi 1.0.0 sudah mutakhir.');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Komponen untuk List Tile agar lebih ringkas
  Widget _buildListTile(String title, String trailingText, VoidCallback onTap) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText.isNotEmpty)
            Text(trailingText,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}
