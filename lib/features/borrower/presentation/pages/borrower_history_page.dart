import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model data tiruan (Mock Model) sesuai skema database proposal RentStuff
class BookingItem {
  final String id;
  final String title;
  final String condition;
  final int totalDays;
  final int totalPrice;
  final String status; // 'Menunggu' atau 'Selesai'

  BookingItem({
    required this.id,
    required this.title,
    required this.condition,
    required this.totalDays,
    required this.totalPrice,
    required this.status,
  });
}

// Halaman utama Riwayat menggunakan ConsumerWidget (Riverpod)
class BorrowerHistoryPage extends ConsumerWidget {
  const BorrowerHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data dummy berdasarkan gambar UI kamu
    final List<BookingItem> historyOrders = [
      BookingItem(
        id: '1',
        title: 'Sony A7III + Lensa 24-70mm',
        condition: 'Sangat Baik',
        totalDays: 3,
        totalPrice: 750000,
        status: 'Menunggu',
      ),
      BookingItem(
        id: '2',
        title: 'Kamera Canon G7X',
        condition: 'Sangat Baik',
        totalDays: 3,
        totalPrice: 225000,
        status: 'Selesai',
      ),
    ];

    // Warna utama aplikasi (RentStuff Blue)
    const primaryBlue = Color(0xFF1D4ED8);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
        title: const Text(
          'Riwayat',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyOrders.length,
        itemBuilder: (context, index) {
          final order = historyOrders[index];
          return _buildOrderCard(context, order, primaryBlue);
        },
      ),
      // Bottom Navigation Bar sesuai dengan screenshot UI
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Menu Riwayat aktif
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: primaryBlue,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment),
            ),
            label: 'Riwayat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outlined),
            label: 'Pesan',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // Widget pembangun kartu pesanan (Order Card)
  Widget _buildOrderCard(BuildContext context, BookingItem order, Color primaryColor) {
    // Pengaturan warna badge status dinamis sesuai proposal
    Color badgeBgColor = const Color(0xFFFEF3C7); // Default Menunggu (Kuning/Orange)
    Color badgeTextColor = const Color(0xFFD97706);

    if (order.status == 'Selesai') {
      badgeBgColor = const Color(0xFFDEF7EC); // Selesai (Hijau)
      badgeTextColor = const Color(0xFF03543F);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        children: [
          // 1. Placeholder Gambar Barang (Garis Biru Tipis)
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 48,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Baris Informasi & Tombol Utama
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sisi Kiri: Detail Informasi Barang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kondisi: ${order.condition}',
                      style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
                    ),
                    Text(
                      '${order.totalDays} hari sewa',
                      style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${order.totalPrice}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),

              // Sisi Kanan: Badge Status & Tombol Cek Item
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Badge Status (Menunggu / Selesai)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol Cek Item
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Aksi navigasi detail deskripsi barang & pesanan
                        // context.push('/order-detail/${order.id}');
                      },
                      child: const Text(
                        'Cek Item',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 3. Tombol Khusus "Beri Ulasan" jika status sudah Selesai (Fase 4 Finalisasi)
          if (order.status == 'Selesai') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Navigasi ke Form Ulasan
                },
                icon: const Icon(Icons.star_border, size: 18),
                label: const Text(
                  'Beri Ulasan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}