import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lenderDashboardProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {

  final firestore = FirebaseFirestore.instance;

  final listingsSnapshot =
      await firestore.collection('listings').get();

  final bookingsSnapshot =
      await firestore.collection('bookings').get();

  int activeItems = 0;
  int newRequests = 0;
  int totalRentals = 0;
  double income = 0;

  for (final doc in listingsSnapshot.docs) {
    final data = doc.data();

    if (data['status'] == 'Available') {
      activeItems++;
    }
  }

  for (final doc in bookingsSnapshot.docs) {
    final data = doc.data();

    if (data['status'] == 'Menunggu') {
      newRequests++;
    }

    if (data['status'] == 'Selesai') {
      totalRentals++;

      final double orderEarnings = (data['lenderEarnings'] ??
              ((data['totalPrice'] ?? 0).toDouble() * 0.90))
          .toDouble();
      income += orderEarnings;
    }
  }

  return {
    'income': income,
    'activeItems': activeItems,
    'newRequests': newRequests,
    'totalRentals': totalRentals,
  };
});