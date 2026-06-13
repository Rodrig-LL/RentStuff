import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentstuff/features/auth/presentation/providers/auth_provider.dart'; // Jika menggunakan Firebase Auth

// 1. Model Entitas Pesanan
class BookingEntity {
  final String id;
  final String listingTitle;
  final double totalPrice;
  final String status; // 'Menunggu', 'Diproses', 'Selesai'
  final int durationDays;

  BookingEntity({
    required this.id,
    required this.listingTitle,
    required this.totalPrice,
    required this.status,
    required this.durationDays,
  });
}

class BookingNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createBooking({
    required String listingId,
    required String listingTitle,
    required double totalPrice,
    required int durationDays,
    required String lenderId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String userId = _auth.currentUser?.uid ?? 'user_demo_123';

      await _firestore.collection('bookings').add({
        'borrowerId': userId,
        'listingId': listingId,
        'listingTitle': listingTitle,
        'totalPrice': totalPrice,
        'status': 'Menunggu',
        'durationDays': durationDays,
        'createdAt': Timestamp.now(),
        'lenderId': lenderId,
        'startDate': startDate,
        'endDate': endDate,
      });
      return true;
    } catch (e) {
      print("Error membuat pesanan: $e");
      return false;
    }
  }
}

final bookingActionProvider = Provider((ref) => BookingNotifier());

final myBookingsProvider =
    StreamProvider.autoDispose<List<BookingEntity>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'user_demo_123';

  return FirebaseFirestore.instance
      .collection('bookings')
      .where('borrowerId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return BookingEntity(
        id: doc.id,
        // Gunakan ?.toString() dan tryParse agar aman dari null dan salah tipe data
        listingTitle: data['listingTitle']?.toString() ?? 'Pesanan Tanpa Nama',
        totalPrice:
            double.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0.0,
        status: data['status']?.toString() ?? 'Menunggu',
        durationDays:
            int.tryParse(data['durationDays']?.toString() ?? '1') ?? 1,
      );
    }).toList();
  });
});

final borrowerStatsProvider =
    StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null)
    return Stream.value({'totalBookings': 0, 'averageRating': 0.0});

  return FirebaseFirestore.instance
      .collection('bookings')
      .where('borrowerId', isEqualTo: user.id.toString())
      .snapshots()
      .map((snapshot) {
    final docs = snapshot.docs;
    if (docs.isEmpty) {
      return {'totalBookings': 0, 'averageRating': 0.0};
    }

    int totalBookings = docs.length;
    double totalRating = 0;
    int reviewedCount = 0;

    for (var doc in docs) {
      final data = doc.data();
      if (data['isReviewed'] == true && data['reviewRating'] != null) {
        totalRating += (data['reviewRating'] as num).toDouble();
        reviewedCount++;
      }
    }

    // Hitung rata-rata rating ulasan yang diberikan oleh user ini
    double avgRating = reviewedCount > 0 ? totalRating / reviewedCount : 0.0;

    return {
      'totalBookings': totalBookings,
      'averageRating': avgRating,
    };
  });
});
