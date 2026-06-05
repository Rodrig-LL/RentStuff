// lib/features/borrower/presentation/pages/my_reviews_page.dart
import 'package:flutter/material.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy daftar ulasan yang pernah diberikan borrower
    final List<Map<String, dynamic>> reviews = [
      {
        'title': 'Sony A7III + Lensa 24-70mm',
        'date': '12 Mei 2026',
        'rating': 5,
        'comment':
            'Kondisi kamera sangat prima, lensa bersih bebas jamur. Owner ramah banget pas COD!'
      },
      {
        'title': 'Tenda Camping 4 Orang Coleman',
        'date': '24 April 2026',
        'rating': 4,
        'comment':
            'Tenda berfungsi dengan baik, waterproof aman. Sedikit kotor di lipatan bawah tapi overall memuaskan.'
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Ulasan Saya',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: reviews.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline_rounded,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('Belum ada ulasan yang Anda berikan',
                      style: TextStyle(color: Colors.black45)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final rev = reviews[i];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              rev['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF123BCA)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(rev['date'],
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black45)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Baris Bintang Rating
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: index < rev['rating']
                                ? const Color(0xFFFACC15)
                                : Colors.black12,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rev['comment'],
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87, height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
