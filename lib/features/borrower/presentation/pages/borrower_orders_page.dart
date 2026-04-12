// lib/features/borrower/presentation/pages/borrower_orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/listing_entity.dart';

// Mock orders provider
final borrowerOrdersProvider = Provider<List<BookingEntity>>((ref) {
  return [
    BookingEntity(
      id: 1, borrowerId: 1, listingId: 1,
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      totalDays: 3, totalPrice: 750000, status: 'pending',
      listingTitle: 'Sony A7III + Lensa 24-70mm',
      lenderName: 'Budi Santoso',
    ),
    BookingEntity(
      id: 2, borrowerId: 1, listingId: 2,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 8)),
      totalDays: 3, totalPrice: 225000, status: 'completed',
      listingTitle: 'Tenda Camping 4 Orang Coleman',
      lenderName: 'Rina Wijaya',
    ),
  ];
});

class BorrowerOrdersPage extends ConsumerWidget {
  const BorrowerOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(borrowerOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('Belum ada pesanan', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(order: orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BookingEntity order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'pending': return AppColors.warning;
      case 'approved': return AppColors.primary;
      case 'ongoing': return AppColors.secondary;
      case 'completed': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'cancelled': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case 'pending': return 'Menunggu Persetujuan';
      case 'approved': return 'Disetujui';
      case 'ongoing': return 'Sedang Berjalan';
      case 'completed': return 'Selesai';
      case 'rejected': return 'Ditolak';
      case 'cancelled': return 'Dibatalkan';
      default: return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');

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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan #${order.id}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.listingTitle ?? '',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Pemilik: ${order.lenderName}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFmt.format(order.startDate)} – ${dateFmt.format(order.endDate)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Text(
                fmt.format(order.totalPrice),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          if (order.status == 'completed') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {/* TODO: open review dialog */},
                icon: const Icon(Icons.star_outline_rounded, size: 16),
                label: const Text('Beri Ulasan'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
