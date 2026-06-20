import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/listing_provider.dart';

class AllListingsPage extends ConsumerWidget {
  final String title;

  const AllListingsPage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: listings.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF123BCA))),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => context.go('/borrower/listing/${item.id}'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFECF1FF),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(11)),
                          ),
                          child: const Icon(Icons.image_outlined,
                              size: 36, color: Color(0xFF123BCA)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Rp ${(item.pricePerDay).toStringAsFixed(0)}/hari',
                              style: const TextStyle(
                                  color: Color(0xFF123BCA),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 12, color: Color(0xFFFACC15)),
                                const SizedBox(width: 2),
                                Text(
                                  '${item.averageRating?.toStringAsFixed(1) ?? '0.0'} (${item.reviewCount} ulasan)',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black45),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
