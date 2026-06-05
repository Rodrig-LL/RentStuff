// lib/features/borrower/presentation/pages/borrower_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentstuff/features/borrower/domain/entities/listing_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import 'borrower_orders_page.dart';
import 'borrower_chat_page.dart';
import 'borrower_profile_page.dart';
import 'all_listings_page.dart';

final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class BorrowerHomePage extends ConsumerWidget {
  const BorrowerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    final pages = [
      const _HomeTab(),
      const BorrowerOrdersPage(),
      const BorrowerChatPage(),
      const BorrowerProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: pages[currentIndex],
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(homeTabIndexProvider.notifier).state = i,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Riwayat'},
      {'icon': Icons.chat_bubble_rounded, 'label': 'Pesan'},
      {'icon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            const Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF376BE0).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(items[i]['icon'] as IconData,
                      color: isSelected ? const Color(0xFF376BE0) : Colors.grey,
                      size: 24),
                  const SizedBox(height: 2),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF376BE0) : Colors.grey,
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  static const _categories = [
    {'icon': Icons.camera_alt_outlined, 'label': 'Kamera'},
    {'icon': Icons.cabin_outlined, 'label': 'Camping'},
    {'icon': Icons.sports_outlined, 'label': 'Olahraga'},
    {'icon': Icons.child_care_outlined, 'label': 'Bayi'},
    {'icon': Icons.flight_outlined, 'label': 'Drone'},
    {'icon': Icons.more_horiz_rounded, 'label': 'Lainnya'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final filter = ref.watch(listingFilterProvider);
    final user = ref.watch(authStateProvider).value;

    final isSearching = (filter.query != null && filter.query!.isNotEmpty) ||
        filter.categoryId != null;

    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFF376BE0),
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top App Bar ──
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RentStuff',
                        style: TextStyle(
                            color: Color(0xFF376BE0),
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text('Halo, ${user?.name.split(' ').first ?? 'User'}!',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              barrierDismissible: true,
                              barrierLabel: 'Notifikasi',
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 60, right: 18),
                                    child: Material(
                                      elevation: 6,
                                      shadowColor: Colors.black26,
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context)
                                          .cardColor, // Mengikuti tema
                                      child: SizedBox(
                                        width: 300,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Text('Notifikasi Terbaru',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2)),
                                            ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              leading: CircleAvatar(
                                                  backgroundColor:
                                                      const Color(0xFF376BE0)
                                                          .withOpacity(0.1),
                                                  child: const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Color(0xFF376BE0),
                                                      size: 20)),
                                              title: const Text(
                                                  'Pesanan Dikonfirmasi',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              subtitle: const Text(
                                                  'Pemilik telah menyetujui pesanan Anda.',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey)),
                                              onTap: () =>
                                                  Navigator.pop(context),
                                            ),
                                            ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 4),
                                              leading: CircleAvatar(
                                                  backgroundColor:
                                                      const Color(0xFFFACC15)
                                                          .withOpacity(0.1),
                                                  child: const Icon(
                                                      Icons
                                                          .local_offer_outlined,
                                                      color: Color(0xFFFACC15),
                                                      size: 20)),
                                              title: const Text(
                                                  'Promo Spesial!',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              subtitle: const Text(
                                                  'Diskon 20% untuk sewa tenda camping.',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey)),
                                              onTap: () =>
                                                  Navigator.pop(context),
                                            ),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2)),
                                            InkWell(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Center(
                                                    child: Text('Tutup',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFF376BE0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.notifications_outlined,
                              color: Color(0xFF376BE0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Search Input Box ──
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).cardColor, // Mengikuti tema
                    border: Border.all(color: Colors.grey.withOpacity(0.3))),
                padding: const EdgeInsets.only(
                    left: 13, right: 8, top: 4, bottom: 4),
                margin: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => ref
                            .read(listingFilterProvider.notifier)
                            .updateQuery(v),
                        decoration: const InputDecoration(
                          hintText: 'Cari barang pinjaman...',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFFACC15)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 11),
                      child: const Text('Cari',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),

              if (!isSearching) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 8, 18, 16),
                  child: Text('Temukan apapun\nyang ingin dipinjami',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('KATEGORI PILIHAN',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AllListingsPage(
                                    title: 'Semua Kategori'))),
                        child: const Text('Lihat Semua',
                            style: TextStyle(
                                color: Color(0xFF355ADC),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = filter.categoryId == i + 1;
                      return GestureDetector(
                        onTap: () => ref
                            .read(listingFilterProvider.notifier)
                            .updateCategory(isSelected ? null : i + 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? const Color(0xFF376BE0)
                                : Theme.of(context).cardColor,
                            border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF376BE0)
                                    : Colors.grey.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(cat['icon'] as IconData,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF376BE0)),
                              const SizedBox(width: 6),
                              Text(cat['label'] as String,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : null)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BARANG TERBARU',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AllListingsPage(
                                    title: 'Barang Terbaru'))),
                        child: const Text('Lihat Semua',
                            style: TextStyle(
                                color: Color(0xFF355ADC),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        filter.query != null && filter.query!.isNotEmpty
                            ? 'Hasil dari: "${filter.query}"'
                            : 'Hasil Filter Kategori',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.close,
                            size: 14, color: Colors.red),
                        label: const Text('Reset',
                            style: TextStyle(fontSize: 11, color: Colors.red)),
                        onPressed: () =>
                            ref.read(listingFilterProvider.notifier).reset(),
                        backgroundColor: Colors.red.withOpacity(0.1),
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // ── Grid Hasil Barang ──
              listings.when(
                loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF376BE0)))),
                error: (e, _) => Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(e.toString()))),
                data: (items) {
                  final filteredItems = items.where((item) {
                    if (filter.categoryId != null &&
                        item.categoryId != filter.categoryId) return false;
                    if (filter.query != null &&
                        !item.title
                            .toLowerCase()
                            .contains(filter.query!.toLowerCase()))
                      return false;
                    return true;
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('Barang tidak ditemukan.',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (_, i) => _ListingCard(
                        listing: filteredItems[i],
                        onTap: () => context
                            .go('/borrower/listing/${filteredItems[i].id}'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AutoDisposeStreamProvider<List<ListingEntity>> {
  ProviderListenable<dynamic>? get notifier => null;
}

class AllListingsPage extends StatelessWidget {
  final String title;
  const AllListingsPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(title), backgroundColor: const Color(0xFF376BE0)),
      body: const Center(
          child: Text('Daftar lengkap barang akan ditampilkan di sini')),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final dynamic listing;
  final VoidCallback onTap;
  const _ListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          color: Theme.of(context).cardColor, // Mengikuti tema
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF376BE0).withOpacity(
                      0.1), // Transparan agar cantik di mode gelap/terang
                  child: const Icon(Icons.image_outlined,
                      size: 36, color: Color(0xFF376BE0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                      'Rp ${(listing.pricePerDay as double).toStringAsFixed(0)}/hari',
                      style: const TextStyle(
                          color: Color(0xFF376BE0),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: Color(0xFFFACC15)),
                      const SizedBox(width: 2),
                      Text(
                          '${listing.averageRating?.toStringAsFixed(1) ?? '0.0'} (${listing.reviewCount})',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
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
