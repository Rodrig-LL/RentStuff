import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/listing_entity.dart';
import '../providers/listing_provider.dart';
import '../providers/wishlist_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListingDetailPage extends ConsumerWidget {
  final String listingId;

  const ListingDetailPage({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final wishlist = ref.watch(wishlistProvider).value ?? {};
    final wishlistAction = ref.read(wishlistActionProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return listings.when(
      loading: () => const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF376BE0)))),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (items) {
        final listing = items.firstWhere(
          (l) => l.id.toString() == listingId,
          orElse: () => items.first,
        );
        return _buildDetail(context, listing, currencyFormat, wishlist, wishlistAction);
      },
    );
  }

  Widget _buildDetail(
    BuildContext context,
    ListingEntity listing,
    NumberFormat currencyFormat,
    Set<String> wishlist,
    WishlistNotifier wishlistAction,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).cardColor.withOpacity(0.8),
                child: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        size: 18, color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      context.pop('/');
                    }),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor.withOpacity(0.8),
                  child: IconButton(
                    icon: Icon(
                      wishlist.contains(listing.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: wishlist.contains(listing.id)
                          ? Colors.red
                          : Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () async {
                      final success = await wishlistAction.toggleWishlist(listing.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? (wishlist.contains(listing.id)
                                    ? 'Dihapus dari favorit'
                                    : 'Ditambahkan ke favorit')
                                : 'Gagal memperbarui favorit'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
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
                      color: const Color(0xFF376BE0).withOpacity(0.1),
                      child: const Icon(Icons.image_outlined,
                          size: 64, color: Color(0xFF376BE0)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (listing.categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF376BE0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing.categoryName!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF376BE0),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: listing.isAvailable
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            color: listing.isAvailable
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    listing.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (listing.averageRating != null) ...[
                        RatingBarIndicator(
                          rating: listing.averageRating!,
                          itemSize: 16,
                          itemBuilder: (_, __) => const Icon(Icons.star_rounded,
                              color: Color(0xFFFACC15)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.averageRating!.toStringAsFixed(1)} (${listing.reviewCount} ulasan)',
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (listing.location != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey),
                            Text(listing.location!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga Sewa',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(
                              '${currencyFormat.format(listing.pricePerDay)}/hari',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF376BE0)),
                            ),
                          ],
                        ),
                        if (listing.deposit != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Deposit',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Text(
                                currencyFormat.format(listing.deposit),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Kondisi: ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.conditionLabel,
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Deskripsi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(listing.description,
                      style: const TextStyle(color: Colors.grey, height: 1.6)),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('Tentang Pemilik',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            const Color(0xFF376BE0).withOpacity(0.1),
                        child: Text(
                          (listing.lenderName ?? 'U')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF376BE0),
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.lenderName ?? 'Pemilik',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (listing.lenderRating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14, color: Color(0xFFFACC15)),
                                  const SizedBox(width: 2),
                                  Text(
                                    listing.lenderRating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                  const Text(' rating pemilik',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Menyiapkan obrolan...'),
                                duration: Duration(seconds: 1)),
                          );

                          final currentUser = FirebaseAuth.instance.currentUser;
                          final borrowerId =
                              currentUser?.uid ?? 'user_demo_123';

                          final borrowerName =
                              currentUser?.displayName ?? 'Pengguna';

                          final newRoom = await FirebaseFirestore.instance
                              .collection('chat_rooms')
                              .add({
                            'borrower_id': borrowerId,
                            'borrower_name': borrowerName,
                            'lender_id': listing.lenderId.toString(),
                            'lender_name': listing.lenderName ?? 'Pemilik',
                            'listing_id': listing.id,
                            'last_message':
                                'Halo, saya tertarik dengan ${listing.title}',
                            'last_message_at': Timestamp.now(),
                            'unread': 0,
                            'participants': [borrowerId, listing.lenderId.toString()],
                          });

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          context.push('/chats/${newRoom.id}');
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 16),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(80, 36)),
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
      bottomNavigationBar: listing.isAvailable
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF376BE0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => context.go('/borrower/booking/$listingId'),
                child: const Text('Pesan Sekarang',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tidak Tersedia',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
    );
  }
}
