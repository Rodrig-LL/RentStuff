import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'payment_page.dart';
import 'help_page.dart';
import 'settings_page.dart';


class LenderProfilePage extends ConsumerWidget {
  const LenderProfilePage({super.key});

  Future<Map<String, dynamic>> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        'name': 'Lender',
        'rating': 0.0,
        'reviewCount': 0,
        'totalDisewakan': 0,
        'pendapatan': 0.0,
      };
    }

    // Ambil data user
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    // Ambil listing milik lender
    final listings = await FirebaseFirestore.instance
        .collection('listings')
        .where('lenderId', isEqualTo: user.uid)
        .get();

    double totalRating = 0;
    int totalReview = 0;

    for (final doc in listings.docs) {
      final data = doc.data();

      totalRating += (data['rating'] ?? 0).toDouble();
      totalReview += ((data['reviewCount'] ?? 0) as num).toInt();
    }

    final avgRating = listings.docs.isEmpty
        ? 0.0
        : totalRating / listings.docs.length;

    // Ambil booking selesai
    final bookings = await FirebaseFirestore.instance
    .collection('bookings')
    .where('lenderId', isEqualTo: user.uid)
    .get();

    double pendapatan = 0;

    for (final doc in bookings.docs) {
      final data = doc.data();

      pendapatan += (data['totalPrice'] ?? 0).toDouble();
    }

    return {
  'name': userData['name'] ??
      user.displayName ??
      user.email?.split('@').first ??
      'Lender',

  'rating': avgRating,
  'reviewCount': totalReview,

  // jumlah barang yang dimiliki lender
  'totalDisewakan': listings.docs.length,

  // total pendapatan
  'pendapatan': pendapatan,
};
  }

  Future<void> _logout(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref
      .read(authStateProvider.notifier)
      .logout();
}

  @override
Widget build(
  BuildContext context,
  WidgetRef ref,
) {
final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadProfileData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF376BE0),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: Color(0xFFE5E5E5),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          data['rating']
                              .toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        '(${data['reviewCount']} Rating)',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Disewakan',
                          value:
                              '${data['totalDisewakan']}',
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _StatCard(
                          title: 'Pendapatan',
                          value: formatter.format(
                            data['pendapatan'],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Akun & Pengaturan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    children: [
      ListTile(
        leading: const Icon(Icons.credit_card),
        title: const Text('Metode Pembayaran'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PaymentPage(),
            ),
          );
        },
      ),

      const Divider(height: 1),

      ListTile(
        leading: const Icon(Icons.help_outline),
        title: const Text('Pusat Bantuan'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HelpPage(),
            ),
          );
        },
      ),

      const Divider(height: 1),

      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Pengaturan'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SettingsPage(),
            ),
          );
        },
      ),
    ],
  ),
),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      onPressed: () => _logout(
  context,
  ref,
), 
                      child: const Text(
                        'Keluar Akun',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF376BE0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}