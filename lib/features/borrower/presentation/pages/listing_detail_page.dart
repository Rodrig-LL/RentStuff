// lib/features/borrower/presentation/pages/listing_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/listing_entity.dart';
import '../providers/listing_provider.dart';

class ListingDetailPage extends ConsumerWidget {
  final String listingId;

  const ListingDetailPage({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
    );

    return listings.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (items) {
        final listing = items.firstWhere(
          (l) => l.id.toString() == listingId,
          orElse: () => items.first,
        );
        return _buildDetail(context, listing, currencyFormat);
      },
    );
  }

  Widget _buildDetail(
    BuildContext context,
    ListingEntity listing,
    NumberFormat currencyFormat,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Photo Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.bgCard,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border_rounded, size: 18),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: listing.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: listing.photos.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.image_outlined, size: 64, color: AppColors.primary),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Status
                  Row(
                    children: [
                      if (listing.categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing.categoryName!,
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: listing.isAvailable ? AppColors.secondaryLight : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            color: listing.isAvailable ? AppColors.secondary : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    listing.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),

                  // Rating & Location
                  Row(
                    children: [
                      if (listing.averageRating != null) ...[
                        RatingBarIndicator(
                          rating: listing.averageRating!,
                          itemSize: 16,
                          itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.accent),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.averageRating!.toStringAsFixed(1)} (${listing.reviewCount} ulasan)',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (listing.location != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            Text(listing.location!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price & Deposit
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga Sewa', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              '${currencyFormat.format(listing.pricePerDay)}/hari',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                        if (listing.deposit != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Deposit', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(
                                currencyFormat.format(listing.deposit),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Condition
                  Row(
                    children: [
                      const Text('Kondisi: ', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.conditionLabel,
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(listing.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                  const SizedBox(height: 20),

                  // Lender Info
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  const Text('Tentang Pemilik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          (listing.lenderName ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.lenderName ?? 'Pemilik',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            if (listing.lenderRating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                                  const SizedBox(width: 2),
                                  Text(
                                    listing.lenderRating!.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                  const Text(' rating pemilik', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/chats/new?lenderId=${listing.lenderId}'),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(80, 36)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action
      bottomNavigationBar: listing.isAvailable
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
              ),
              child: ElevatedButton(
                onPressed: () => context.go('/borrower/booking/$listingId'),
                child: const Text('Pesan Sekarang'),
              ),
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(color: AppColors.bgCard),
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.divider),
                child: const Text('Tidak Tersedia'),
              ),
            ),
    );
  }
}
