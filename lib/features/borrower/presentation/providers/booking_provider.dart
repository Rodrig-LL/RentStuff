import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingEntity {
  final String id;
  final String listingTitle;
  final double totalPrice;
  final String status;
  final int durationDays;
  final String listingPhoto;

  BookingEntity({
    required this.id,
    required this.listingTitle,
    required this.totalPrice,
    required this.status,
    required this.durationDays,
    this.listingPhoto = '',
  });
}

class BookingNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createBooking({
    required String listingId,
    required String listingTitle,
    required double totalPrice,
    required double rentalPrice,
    required double shippingPrice,
    required double deposit,
    required int durationDays,
    required String lenderId,
    required DateTime startDate,
    required DateTime endDate,
    required String listingPhoto,
  }) async {
    try {
      final String userId = _auth.currentUser?.uid ?? 'user_demo_123';
      final double platformFee = rentalPrice * 0.10;
      final double lenderEarnings = rentalPrice * 0.90;

      final DocumentReference bookingRef =
          await _firestore.collection('bookings').add({
        'borrowerId': userId,
        'listingId': listingId,
        'listingTitle': listingTitle,
        'totalPrice': totalPrice,
        'rentalPrice': rentalPrice,
        'shippingPrice': shippingPrice,
        'deposit': deposit,
        'platformFee': platformFee,
        'lenderEarnings': lenderEarnings,
        'status': 'Menunggu',
        'durationDays': durationDays,
        'createdAt': Timestamp.now(),
        'lenderId': lenderId,
        'startDate': startDate,
        'endDate': endDate,
        'listingPhoto': listingPhoto,
      });

      await _firestore.collection('platform_revenues').add({
        'bookingId': bookingRef.id,
        'listingTitle': listingTitle,
        'amount': platformFee,
        'rentalPrice': rentalPrice,
        'borrowerId': userId,
        'lenderId': lenderId,
        'createdAt': Timestamp.now(),
        'status': 'Menunggu',
      });

      return true;
    } catch (e) {
      print("Error membuat pesanan: $e");
      return false;
    }
  }

  /// Membatalkan pesanan yang masih berstatus 'Menunggu'
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'Dibatalkan',
      });
      return true;
    } catch (e) {
      print("Error membatalkan pesanan: $e");
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
        listingTitle: data['listingTitle']?.toString() ?? 'Pesanan Tanpa Nama',
        totalPrice:
            double.tryParse(data['totalPrice']?.toString() ?? '0') ?? 0.0,
        status: data['status']?.toString() ?? 'Menunggu',
        durationDays:
            int.tryParse(data['durationDays']?.toString() ?? '1') ?? 1,
        listingPhoto: (data['listingPhoto']?.toString() ?? '').trim(),
      );
    }).toList();
  });
});
