import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

final myReviewsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .snapshots()
      .map((snapshot) {
    final allBookings = snapshot.docs.map((doc) => doc.data()).toList();

    print("DEBUG: TOTAL DOKUMEN DI KOLEKSI BOOKINGS: ${allBookings.length}");

    for (var b in allBookings) {
      print("DEBUG: Dokumen ada dengan borrowerId: ${b['borrowerId']}");
    }

    return allBookings
        .where((booking) => booking['isReviewed'] == true)
        .toList();
  });
});

class MyReviewsPage extends ConsumerWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(myReviewsProvider);
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Ulasan Saya',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              size: 18, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: reviewsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF123BCA))),
        error: (error, _) => Center(child: Text('Terjadi kesalahan: $error')),
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(
              child: Text('Anda belum memberikan ulasan apa pun.',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final review = reviews[index];

              final dateObj =
                  (review['endDate'] as Timestamp?)?.toDate() ?? DateTime.now();
              final dateString = dateFormat.format(dateObj);

              final rating = (review['reviewRating'] ?? 0).toDouble();
              final reviewText =
                  review['reviewText'] ?? 'Tidak ada teks ulasan.';
              final title = review['listingTitle'] ?? 'Barang Sewaan';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF123BCA)),
                          ),
                        ),
                        Text(dateString,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingBarIndicator(
                      rating: rating,
                      itemSize: 16,
                      itemBuilder: (_, __) => const Icon(Icons.star_rounded,
                          color: Color(0xFFFACC15)),
                    ),
                    const SizedBox(height: 12),
                    Text(reviewText,
                        style: const TextStyle(fontSize: 13, height: 1.5)),
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
