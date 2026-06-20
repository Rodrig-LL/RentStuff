import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class LenderBookingsPage extends ConsumerStatefulWidget {
  const LenderBookingsPage({super.key});

  @override
  ConsumerState<LenderBookingsPage> createState() => _LenderBookingsPageState();
}

class _LenderBookingsPageState extends ConsumerState<LenderBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Booking'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Disetujui'),
            Tab(text: 'Berjalan'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingList(status: 'pending'),
          _BookingList(status: 'approved'),
          _BookingList(status: 'ongoing'),
          _BookingList(status: 'completed'),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final String status;
  const _BookingList({required this.status});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA SEMENTARA (Agar UI Tab aman dari error)
    // Nanti kita sambungkan ulang ke Firebase pelan-pelan
    final mockBookings = [
      if (status == 'pending') ...[
        _MockBooking(
          id: 1,
          borrowerName: 'Andi Permana',
          itemName: 'Sony A7III',
          startDate: DateTime.now().add(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 4)),
          totalPrice: 750000,
          status: 'pending',
        ),
        _MockBooking(
          id: 2,
          borrowerName: 'Sari Kusuma',
          itemName: 'DJI Mini 3 Pro',
          startDate: DateTime.now().add(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 7)),
          totalPrice: 900000,
          status: 'pending',
        ),
      ],
      if (status == 'approved') ...[
        _MockBooking(
          id: 3,
          borrowerName: 'Dika Pratama',
          itemName: 'Tenda Camping',
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 3)),
          totalPrice: 225000,
          status: 'approved',
        ),
      ],
    ];

    if (mockBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('Tidak ada pesanan $status',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: mockBookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _LenderBookingCard(booking: mockBookings[i]),
    );
  }
}

class _MockBooking {
  final int id;
  final String borrowerName;
  final String itemName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;

  _MockBooking({
    required this.id,
    required this.borrowerName,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });
}

class _LenderBookingCard extends StatefulWidget {
  final _MockBooking booking;
  const _LenderBookingCard({required this.booking});

  @override
  State<_LenderBookingCard> createState() => _LenderBookingCardState();
}

class _LenderBookingCardState extends State<_LenderBookingCard> {
  bool _isProcessing = false;

  Future<void> _handleAction(bool approve) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Pesanan disetujui!' : 'Pesanan ditolak'),
          backgroundColor: approve ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM', 'id_ID');
    final b = widget.booking;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: Text(b.borrowerName[0],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.borrowerName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Ingin menyewa: ${b.itemName}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggal Sewa',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  Text(
                      '${dateFmt.format(b.startDate)} – ${dateFmt.format(b.endDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  Text(fmt.format(b.totalPrice),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ],
          ),
          if (b.status == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isProcessing ? null : () => _handleAction(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleAction(true),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44)),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
