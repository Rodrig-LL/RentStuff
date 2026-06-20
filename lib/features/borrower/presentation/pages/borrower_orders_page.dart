import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import 'order_detail_page.dart';
import 'return_item_page.dart';
import 'add_review_page.dart';

class BorrowerOrdersPage extends ConsumerWidget {
  const BorrowerOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsyncValue = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Riwayat',
            style: TextStyle(
                color: Color(0xFF376BE0), fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: bookingsAsyncValue.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF376BE0))),
        error: (error, stack) => const Center(
            child: Text('Terjadi kesalahan data. Coba muat ulang.',
                style: TextStyle(color: Colors.grey))),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat pesanan.',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final isSelesai = booking.status.toLowerCase() == 'selesai';

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF376BE0).withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(11)),
                      ),
                      child: const Center(
                          child: Icon(Icons.image_outlined,
                              size: 40, color: Color(0xFF376BE0))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking.listingTitle,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF376BE0))),
                                const SizedBox(height: 4),
                                Text('${booking.durationDays} hari sewa',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text('Rp ${booking.totalPrice.toInt()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF376BE0))),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelesai
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  booking.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelesai
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF376BE0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  elevation: 0,
                                  minimumSize: const Size(0, 36),
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderDetailPage(booking: booking))),
                                child: const Text('Cek Item',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    if (isSelesai ||
                        booking.status.toLowerCase() == 'disetujui' ||
                        booking.status.toLowerCase() == 'aktif') ...[
                      Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: isSelesai
                            ? OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF376BE0)),
                                  minimumSize: const Size.fromHeight(40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              AddReviewPage(booking: booking)));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Membuka halaman form ulasan...'),
                                        backgroundColor: Color(0xFF376BE0)),
                                  );
                                },
                                icon: const Icon(Icons.star_outline,
                                    size: 18, color: Color(0xFF376BE0)),
                                label: const Text('Beri Ulasan',
                                    style: TextStyle(
                                        color: Color(0xFF376BE0),
                                        fontWeight: FontWeight.bold)),
                              )
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF376BE0),
                                  minimumSize: const Size.fromHeight(40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ReturnItemPage(booking: booking))),
                                icon: const Icon(Icons.local_shipping_outlined,
                                    size: 18, color: Colors.white),
                                label: const Text('Form Pengembalian',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                      )
                    ] else if (booking.status.toLowerCase() == 'menunggu') ...[
                      Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            minimumSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor:
                                    Theme.of(context).cardColor,
                                title: const Text('Batalkan Pesanan?'),
                                content: const Text(
                                    'Pesanan yang sudah dibatalkan tidak dapat dikembalikan. Lanjutkan?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Tidak',
                                        style:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      final success = await ref
                                          .read(bookingActionProvider)
                                          .cancelBooking(booking.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(success
                                                ? 'Pesanan dibatalkan'
                                                : 'Gagal membatalkan pesanan'),
                                            backgroundColor: success
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Ya, Batalkan',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Batalkan Pesanan',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
