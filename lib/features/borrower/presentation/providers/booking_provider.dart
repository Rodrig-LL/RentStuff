import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Jika menggunakan Firebase Auth

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

// 2. Class untuk fungsi Insert/Create ke Firebase
class BookingNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createBooking({
    required String listingId,
    required String listingTitle,
    required double totalPrice,
    required int durationDays,
  }) async {
    try {
      // Ambil UID user yang sedang login (Atau gunakan 'user_demo' jika belum ada Auth)
      final String userId = _auth.currentUser?.uid ?? 'user_demo_123';

      await _firestore.collection('bookings').add({
        'borrowerId': userId,
        'listingId': listingId,
        'listingTitle': listingTitle, // Disimpan agar mudah dibaca di riwayat
        'totalPrice': totalPrice,
        'status': 'Menunggu', // Default status awal
        'durationDays': durationDays,
        'createdAt': Timestamp.now(),
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
