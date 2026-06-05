// lib/features/borrower/presentation/widgets/listing_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/listing_entity.dart';

class ListingCard extends StatelessWidget {
  final ListingEntity listing;
  final VoidCallback onTap;

  const ListingCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: listing.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: listing.photos.first,
                      width: 110, height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 110, height: 110,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.image_outlined, color: AppColors.primary),
                      ),
                    )
                  : Container(
                      width: 110, height: 110,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 36),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    if (listing.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          listing.categoryName!,
                          style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 4),

                    Text(
                      listing.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Location
                    if (listing.location != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Text(listing.location!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyFormat.format(listing.pricePerDay),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const Text('/hari', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),

                        // Rating
                        if (listing.averageRating != null)
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                              const SizedBox(width: 2),
                              Text(
                                listing.averageRating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              Text(
                                ' (${listing.reviewCount})',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
