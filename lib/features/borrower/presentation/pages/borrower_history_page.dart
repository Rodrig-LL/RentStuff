import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/booking_provider.dart';

final listingPhotoProvider =
    FutureProvider.family<String, String>((ref, listingId) async {
  if (listingId.isEmpty) return '';

  final doc = await FirebaseFirestore.instance
      .collection('listings')
      .doc(listingId)
      .get();

  if (!doc.exists) return '';

  final data = doc.data();
  final photos = data?['photos'];

  if (photos is List && photos.isNotEmpty) {
    return photos[0].toString();
  }
  return '';
});

class BorrowerHistoryPage extends ConsumerWidget {
  const BorrowerHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryBlue = Color(0xFF1D4ED8);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
        title: const Text(
          'Riwayat',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: bookingsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1D4ED8))),
        error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
        data: (historyOrders) {
          if (historyOrders.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat pesanan.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyOrders.length,
            itemBuilder: (context, index) {
              final order = historyOrders[index];
              return _OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final BookingEntity order;
  static const primaryBlue = Color(0xFF1D4ED8);

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(listingPhotoProvider(order.listingId));

    Color badgeBgColor = const Color(0xFFFEF3C7);
    Color badgeTextColor = const Color(0xFFD97706);

    if (order.status == 'Selesai') {
      badgeBgColor = const Color(0xFFDEF7EC);
      badgeTextColor = const Color(0xFF03543F);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photoAsync.when(
              loading: () => _buildLoadingPlaceholder(),
              error: (_, __) => _buildPlaceholder(),
              data: (photoUrl) {
                if (photoUrl.isEmpty) return _buildPlaceholder();

                return CachedNetworkImage(
                  imageUrl: photoUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _buildLoadingPlaceholder(),
                  errorWidget: (_, __, ___) => _buildPlaceholder(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.listingTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.durationDays} hari sewa',
                      style: const TextStyle(
                          color: Color(0xFF4B5563), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${order.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Cek Item',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (order.status == 'Selesai') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.star_border, size: 18),
                label: const Text(
                  'Beri Ulasan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: const Color(0xFFEFF6FF),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: const Color(0xFFEFF6FF),
      child: const Icon(
        Icons.image_outlined,
        size: 48,
        color: Color(0xFF3B82F6),
      ),
    );
  }
}
