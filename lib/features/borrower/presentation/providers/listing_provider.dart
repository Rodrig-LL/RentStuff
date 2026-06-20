import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/listing_entity.dart';

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

final listingsProvider = StreamProvider.autoDispose<List<ListingEntity>>((ref) {
  final collection = FirebaseFirestore.instance.collection('listings');

  return collection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      List<String> safePhotos = [];
      if (data['photos'] is List) {
        safePhotos = List<String>.from(data['photos']);
      } else if (data['photos'] is String &&
          data['photos'].toString().isNotEmpty) {
        safePhotos = [data['photos'].toString()];
      }

      return ListingEntity(
        id: doc.id,
        lenderId: int.tryParse(data['lenderId']?.toString() ?? '0') ?? 0,
        categoryId: int.tryParse(data['categoryId']?.toString() ?? '6') ?? 6,
        title: data['title']?.toString() ?? 'Barang Tanpa Nama',
        description: data['description']?.toString() ?? 'Tidak ada deskripsi',
        pricePerDay:
            double.tryParse(data['pricePerDay']?.toString() ?? '0') ?? 0.0,
        deposit: double.tryParse(data['deposit']?.toString() ?? '0') ?? 0.0,
        condition: data['condition']?.toString() ?? 'good',
        status: (data['status']?.toString() ?? 'unavailable').toLowerCase(),
        lenderName: data['lenderName']?.toString() ?? 'Anonim',
        lenderAvatar: data['lenderAvatar']?.toString(),
        lenderRating:
            double.tryParse(data['lenderRating']?.toString() ?? '0') ?? 0.0,
        categoryName: data['categoryName']?.toString(),
        photos: safePhotos,
        averageRating:
            double.tryParse(data['averageRating']?.toString() ?? '0') ?? 0.0,
        reviewCount: int.tryParse(data['reviewCount']?.toString() ?? '0') ?? 0,
        location: data['location']?.toString(),
      );
    }).toList();
  });
});

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
    return List.generate(
      10,
      (i) => ListingEntity(
        id: 'listing_$i',
        lenderId: i,
        categoryId: i % 5 + 1,
        title: 'Barang ${i + 1}',
        description: 'Deskripsi untuk Barang ${i + 1}',
        pricePerDay: (i + 1) * 10.0,
        condition: ['new', 'good', 'fair'][i % 3],
        status: 'available',
        lenderName: 'Penyewa ${i + 1}',
        averageRating: (i % 5) + 1.0,
        reviewCount: i * 2,
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}
