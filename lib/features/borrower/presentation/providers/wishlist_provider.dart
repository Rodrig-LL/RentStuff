import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Memantau daftar listingId yang di-wishlist oleh user saat ini.
/// Mengembalikan Set<String> untuk pengecekan cepat.
final wishlistProvider = StreamProvider.autoDispose<Set<String>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (userId.isEmpty) return Stream.value({});

  return FirebaseFirestore.instance
      .collection('wishlists')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()['listingId'] as String).toSet());
});

/// Action provider untuk toggle wishlist (tambah/hapus).
final wishlistActionProvider = Provider<WishlistNotifier>((ref) {
  return WishlistNotifier();
});

class WishlistNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Toggle wishlist: jika sudah ada, hapus; jika belum, tambah.
  Future<bool> toggleWishlist(String listingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      // Cari dokumen wishlist spesifik user + listing
      final existing = await _firestore
          .collection('wishlists')
          .where('userId', isEqualTo: userId)
          .where('listingId', isEqualTo: listingId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Sudah ada → hapus
        await _firestore
            .collection('wishlists')
            .doc(existing.docs.first.id)
            .delete();
      } else {
        // Belum ada → tambah
        await _firestore.collection('wishlists').add({
          'userId': userId,
          'listingId': listingId,
          'createdAt': Timestamp.now(),
        });
      }
      return true;
    } catch (e) {
      print('Error toggling wishlist: $e');
      return false;
    }
  }
}
