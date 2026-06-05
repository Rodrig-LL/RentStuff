// lib/features/borrower/presentation/providers/listing_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/listing_entity.dart';

class BookingEntity {
  final String id;
  final int borrowerId;
  final String listingId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;
  String status;
  final String? listingTitle;
  final String? lenderName;
  final String? borrowerName;
  final String? borrowerAddress;
  final String? paymentMethod;
  final String? notes;

  BookingEntity({
    required this.id,
    required this.borrowerId,
    required this.listingId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    required this.status,
    this.listingTitle,
    this.lenderName,
    this.borrowerName,
    this.borrowerAddress,
    this.paymentMethod,
    this.notes,
  });
}

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
final listingsProvider = StreamProvider.autoDispose<List<ListingEntity>>((ref) {
  // Memanggil koleksi 'listings' dari Firebase
  final collection = FirebaseFirestore.instance.collection('listings');

  // Mengubah aliran data Firebase menjadi List<ListingEntity> untuk aplikasi kita
  return collection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return ListingEntity(
        id: doc.id,
        lenderId: data['lenderId'] ?? 0,
        categoryId: data['categoryId'] ?? 6,
        title: data['title'] ?? 'Barang Tanpa Nama',
        description: data['description'] ?? 'Tidak ada deskripsi',
        pricePerDay: (data['pricePerDay'] ?? 0).toDouble(),
        deposit: (data['deposit'] ?? 0).toDouble(),
        condition: data['condition'] ?? 'good',
        status: (data['status'] ?? 'unavailable').toString().toLowerCase(),
        lenderName: data['lenderName'] ?? 'Anonim',
        lenderAvatar: data['lenderAvatar'],
        lenderRating: (data['lenderRating'] ?? 0.0).toDouble(),
        categoryName: data['categoryName'],
        photos: List<String>.from(data['photos'] ?? []),
        averageRating: (data['averageRating'] ?? 0.0).toDouble(),
        reviewCount: data['reviewCount'] ?? 0,
        location: data['location'],
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
