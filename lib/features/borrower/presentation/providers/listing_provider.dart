// lib/features/borrower/presentation/providers/listing_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/listing_entity.dart';

// Filter State
class ListingFilter {
  final String? query;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? location;
  final int page;

  const ListingFilter({
    this.query,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.location,
    this.page = 1,
  });

  ListingFilter copyWith({
    String? query,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    int? page,
  }) {
    return ListingFilter(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      location: location ?? this.location,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (query != null && query!.isNotEmpty) 'search': query,
      if (categoryId != null) 'category_id': categoryId,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (minRating != null) 'min_rating': minRating,
      if (location != null) 'location': location,
      'page': page,
      'per_page': 10,
    };
  }
}

final listingFilterProvider =
    StateNotifierProvider<ListingFilterNotifier, ListingFilter>(
  (_) => ListingFilterNotifier(),
);

class ListingFilterNotifier extends StateNotifier<ListingFilter> {
  ListingFilterNotifier() : super(const ListingFilter());

  void updateQuery(String query) {
    state = state.copyWith(query: query, page: 1);
  }

  void updateCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId, page: 1);
  }

  void updatePriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max, page: 1);
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void reset() {
    state = const ListingFilter();
  }
}

// Listings provider - fetches listings based on current filter
final listingsProvider =
    AsyncNotifierProvider.autoDispose<ListingsNotifier, List<ListingEntity>>(
  ListingsNotifier.new,
);

class ListingsNotifier extends AutoDisposeAsyncNotifier<List<ListingEntity>> {
  @override
  Future<List<ListingEntity>> build() async {
    // TODO: Replace with real API call
    // final filter = ref.watch(listingFilterProvider);
    // final repo = ref.read(listingRepositoryProvider);
    // final result = await repo.getListings(filter.toQueryParams());
    // return result.fold((f) => throw f, (l) => l);

    // Mock data untuk development
    await Future.delayed(const Duration(seconds: 1));
    return _mockListings;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

// Mock data
final _mockListings = [
  const ListingEntity(
    id: 1, lenderId: 1, categoryId: 1,
    title: 'Sony A7III + Lensa 24-70mm',
    description: 'Kamera mirrorless full-frame profesional dengan lensa kit. Cocok untuk portrait dan landscape.',
    pricePerDay: 250000, deposit: 2000000, condition: 'good',
    status: 'available', categoryName: 'Kamera',
    photos: ['https://picsum.photos/400/300?random=1'],
    averageRating: 4.8, reviewCount: 12, location: 'Bandung',
    lenderName: 'Budi Santoso', lenderRating: 4.9,
  ),
  const ListingEntity(
    id: 2, lenderId: 2, categoryId: 2,
    title: 'Tenda Camping 4 Orang Coleman',
    description: 'Tenda berkualitas untuk 4 orang, waterproof, mudah dipasang.',
    pricePerDay: 75000, deposit: 500000, condition: 'good',
    status: 'available', categoryName: 'Camping',
    photos: ['https://picsum.photos/400/300?random=2'],
    averageRating: 4.6, reviewCount: 8, location: 'Bandung',
    lenderName: 'Rina Wijaya', lenderRating: 4.7,
  ),
  const ListingEntity(
    id: 3, lenderId: 3, categoryId: 1,
    title: 'DJI Mini 3 Pro Drone',
    description: 'Drone compact dengan kamera 4K, aman dan mudah dioperasikan pemula.',
    pricePerDay: 300000, deposit: 3000000, condition: 'new',
    status: 'available', categoryName: 'Drone',
    photos: ['https://picsum.photos/400/300?random=3'],
    averageRating: 4.9, reviewCount: 5, location: 'Bandung',
    lenderName: 'Ahmad Fauzi', lenderRating: 5.0,
  ),
];
