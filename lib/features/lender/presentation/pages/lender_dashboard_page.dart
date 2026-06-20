// lib/features/lender/presentation/pages/lender_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'lender_listings_page.dart';
import 'lender_chat_page.dart';
import 'lender_profile_page.dart';
import '../providers/lender_dashboard_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LenderDashboardPage extends ConsumerStatefulWidget {
  const LenderDashboardPage({super.key});

  @override
  ConsumerState<LenderDashboardPage> createState() =>
      _LenderDashboardPageState();
}

class _LenderDashboardPageState extends ConsumerState<LenderDashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          LenderListingsPage(),
          LenderChatPage(),
          LenderProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: const Color(0xFF376BE0),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Barang'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil'),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final dashboard = ref.watch(lenderDashboardProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${user?.name.split(' ').first ?? 'Pemilik'}! 👋',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const Text('Kelola barang sewaan Anda',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF376BE0)),
                    onPressed: () {}),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards
            dashboard.when(
              data: (stats) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Pendapatan Bulan Ini',
                          value: fmt.format(stats['income']),
                          icon: Icons.account_balance_wallet_outlined,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Total Penyewaan',
                          value: '${stats['totalRentals']}x',
                          icon: Icons.handshake_outlined,
                          color: const Color(0xFF376BE0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Barang Aktif',
                          value: '${stats['activeItems']}',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Permintaan Baru',
                          value: '${stats['newRequests']}',
                          icon: Icons.mark_email_unread_outlined,
                          color: const Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(e.toString()),
            ),

            // Quick Actions
            const Text('Aksi Cepat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    label: 'Tambah Barang',
                    icon: Icons.add_box_outlined,
                    color: const Color(0xFF376BE0),
                    onTap: () => context.go('/lender/add-listing'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    label: 'Lihat Chat',
                    icon: Icons.chat,
                    color: const Color(0xFF10B981),
                    onTap: () => context.go('/lender/chat'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/lender/bookings'),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Color(0xFF376BE0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final bookings = snapshot.data!.docs;

                if (bookings.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Belum ada pesanan.',
                    ),
                  );
                }

                return Column(
                  children: bookings.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: _RecentBookingItem(
                        itemName: data['listingTitle'] ?? '-',
                        borrowerName: data['borrowerName'] ?? 'Borrower',
                        dates: '${data['durationDays'] ?? 0} hari',
                        status: data['status'] ?? '',
                        price: fmt.format(
                          data['totalPrice'] ?? 0,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(
                child: Text(label,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, color: color))),
          ],
        ),
      ),
    );
  }
}

class _RecentBookingItem extends StatelessWidget {
  final String itemName;
  final String borrowerName;
  final String dates;
  final String status;
  final String price;

  const _RecentBookingItem({
    required this.itemName,
    required this.borrowerName,
    required this.dates,
    required this.status,
    required this.price,
  });

  Color get _color {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFFF97316);

      case 'disetujui':
        return const Color(0xFF376BE0);

      default:
        return const Color(0xFFFF97316);
    }
  }

  String get _label => status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('$borrowerName • $dates',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF376BE0),
                      fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: _color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(_label,
                    style: TextStyle(
                        color: _color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Placeholder tabs
class _MyListingsTab extends ConsumerWidget {
  const _MyListingsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go('/lender/add-listing'),
          ),
        ],
      ),
      body: const Center(child: Text('Daftar barang Anda akan tampil di sini')),
    );
  }
}

class _BookingRequestsTab extends ConsumerWidget {
  const _BookingRequestsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Permintaan Booking')),
        body: const Center(
            child: Text('Permintaan booking masuk akan tampil di sini')),
      );
}

class _LenderProfileTab extends ConsumerWidget {
  const _LenderProfileTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () => ref.read(authStateProvider.notifier).logout(),
        style:
            ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE73232)),
        child: const Text('Keluar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
