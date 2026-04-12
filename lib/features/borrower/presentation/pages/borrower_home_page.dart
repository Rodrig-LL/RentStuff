// lib/features/borrower/presentation/pages/borrower_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../widgets/listing_card.dart';
import '../widgets/category_chip.dart';

final _categories = [
  {'id': null, 'name': 'Semua', 'icon': Icons.apps_rounded},
  {'id': 1, 'name': 'Kamera', 'icon': Icons.camera_alt_outlined},
  {'id': 2, 'name': 'Camping', 'icon': Icons.cabin_outlined},
  {'id': 3, 'name': 'Bayi', 'icon': Icons.child_care_outlined},
  {'id': 4, 'name': 'Olahraga', 'icon': Icons.sports_outlined},
  {'id': 5, 'name': 'Drone', 'icon': Icons.flight_outlined},
];

class BorrowerHomePage extends ConsumerStatefulWidget {
  const BorrowerHomePage({super.key});

  @override
  ConsumerState<BorrowerHomePage> createState() => _BorrowerHomePageState();
}

class _BorrowerHomePageState extends ConsumerState<BorrowerHomePage> {
  int _currentIndex = 0;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _OrdersTab(),
          _ChatTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), activeIcon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final filter = ref.watch(listingFilterProvider);
    final user = ref.watch(authStateProvider).value;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(listingsProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${user?.name.split(' ').first ?? 'User'}! 👋',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const Text('Mau sewa apa hari ini?', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 8, top: 8,
                              child: Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    TextField(
                      onChanged: (v) => ref.read(listingFilterProvider.notifier).updateQuery(v),
                      decoration: InputDecoration(
                        hintText: 'Cari kamera, tenda, drone...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                          onPressed: () => _showFilterSheet(context, ref),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    return CategoryChip(
                      label: cat['name'] as String,
                      icon: cat['icon'] as IconData,
                      isSelected: filter.categoryId == cat['id'],
                      onTap: () => ref.read(listingFilterProvider.notifier).updateCategory(cat['id'] as int?),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Barang Tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Listings Grid
            listings.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _ShimmerCard(),
                  ),
                  childCount: 4,
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 8),
                      Text(e.toString(), style: const TextStyle(color: AppColors.textSecondary)),
                      TextButton(onPressed: () => ref.read(listingsProvider.notifier).refresh(), child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              ),
              data: (items) => items.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint),
                              SizedBox(height: 16),
                              Text('Tidak ada barang ditemukan', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ListingCard(
                              listing: items[i],
                              onTap: () => context.go('/borrower/listing/${items[i].id}'),
                            ),
                          ),
                          childCount: items.length,
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {
                  ref.read(listingFilterProvider.notifier).reset();
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Rentang Harga (per hari)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Min', prefixText: 'Rp '),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Max', prefixText: 'Rp '),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terapkan Filter'),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// Placeholder tabs
class _OrdersTab extends StatelessWidget {
  const _OrdersTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Pesanan Saya'));
}

class _ChatTab extends StatelessWidget {
  const _ChatTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Chat'));
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () => ref.read(authStateProvider.notifier).logout(),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
        child: const Text('Keluar'),
      ),
    );
  }
}
