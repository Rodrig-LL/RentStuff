import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'Profile_Page/edit_profile_page.dart';
import 'Profile_Page/my_reviews_page.dart';
import 'Profile_Page/help_center_page.dart';
import 'Profile_Page/settings_page.dart';

final profileStatsProvider =
    StreamProvider.autoDispose<Map<String, int>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value({'total': 0, 'active': 0});
  return FirebaseFirestore.instance
      .collection('bookings')
      .where('borrowerId', isEqualTo: user.id.toString())
      .snapshots()
      .map((snapshot) {
    int total = snapshot.docs.length;
    int active = snapshot.docs.where((doc) {
      final status = (doc.data()['status'] ?? '').toString().toLowerCase();
      return status != 'selesai' && status != 'dibatalkan';
    }).length;
    return {'total': total, 'active': active};
  });
});

class BorrowerProfilePage extends ConsumerWidget {
  const BorrowerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final statsAsync = ref.watch(profileStatsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 18),
              width: double.infinity,
              child: const Center(
                  child: Text('Profil',
                      style: TextStyle(
                          color: Color(0xFF376BE0),
                          fontSize: 24,
                          fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFECF1FF)),
              child: Center(
                child: Text(
                    (user?.name.isNotEmpty == true)
                        ? user!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123BCA))),
              ),
            ),
            const SizedBox(height: 12),
            // HAPUS Colors.black, biarkan menyesuaikan tema otomatis
            Text(user?.name ?? 'Pengguna',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user?.email ?? 'Belum ada email',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFFDC612)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  child: const Row(children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.black),
                    SizedBox(width: 4),
                    Text('4.7',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
                const SizedBox(width: 8),
                const Text('(46 Rating)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) =>
                    const Center(child: Text('Gagal memuat statistik')),
                data: (stats) => Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            label: 'Total Pinjam',
                            value: stats['total'].toString())),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _StatCard(
                            label: 'Sedang Dipinjam',
                            value: stats['active'].toString())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                // GUNAKAN cardColor dari tema, bukan Colors.white
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).cardColor),
                child: Column(
                  children: [
                    _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profil',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfilePage()))),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                    _MenuItem(
                        icon: Icons.star_outline_rounded,
                        label: 'Ulasan Saya',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyReviewsPage()))),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                    _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Pusat Bantuan',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HelpCenterPage()))),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                    _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Pengaturan',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsPage()))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => ref.read(authStateProvider.notifier).logout(),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFE73232)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  width: double.infinity,
                  child: const Center(
                      child: Text('Keluar Akun',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      // Border warna abu transparan agar cocok di mode gelap maupun terang
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold)), // Dihapus Colors.black
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF376BE0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold)), // Diubah agar biru lebih pas
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Future.delayed(const Duration(milliseconds: 50), onTap),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: const Color(0xFF376BE0)),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 15))
            ]), // Dihapus Colors.black
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
