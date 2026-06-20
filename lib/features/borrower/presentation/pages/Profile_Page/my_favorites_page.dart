import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentstuff/features/borrower/presentation/providers/wishlist_provider.dart';
import 'package:rentstuff/features/borrower/presentation/providers/listing_provider.dart';
import 'package:rentstuff/features/borrower/domain/entities/listing_entity.dart';

class MyFavoritesPage extends ConsumerWidget {
  const MyFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);
    final listingsAsync = ref.watch(listingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Favorit Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: wishlistAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF376BE0)),
        ),
        error: (error, _) => Center(
          child: Text('Terjadi kesalahan: $error'),
        ),
        data: (wishlistIds) {
          if (wishlistIds.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada barang favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Barang yang Anda sukai akan muncul di sini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return listingsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF376BE0)),
            ),
            error: (error, _) => Center(
              child: Text('Terjadi kesalahan: $error'),
            ),
            data: (listings) {
              final favoriteListings = listings
                  .where((item) => wishlistIds.contains(item.id))
                  .toList();

              if (favoriteListings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada barang favorit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Barang yang Anda sukai akan muncul di sini.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteListings.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final item = favoriteListings[index];
                  return _FavoriteListingCard(listing: item);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteListingCard extends StatelessWidget {
  final ListingEntity listing;
  const _FavoriteListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/borrower/listing/${listing.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
                child: listing.photos.isNotEmpty
                    ? Image.network(
                        listing.photos.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          color: const Color(0xFF376BE0).withOpacity(0.1),
                          child: const Icon(
                            Icons.broken_image,
                            size: 36,
                            color: Color(0xFF376BE0),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        color: const Color(0xFF376BE0).withOpacity(0.1),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: Color(0xFF376BE0),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${listing.pricePerDay.toStringAsFixed(0)}/hari',
                    style: const TextStyle(
                      color: Color(0xFF376BE0),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Color(0xFFFACC15),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${listing.averageRating?.toStringAsFixed(1) ?? '0.0'} (${listing.reviewCount})',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
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
  }
}
