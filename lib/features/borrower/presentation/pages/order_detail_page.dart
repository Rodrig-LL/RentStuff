// lib/features/borrower/presentation/pages/order_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/booking_provider.dart';

class OrderDetailPage extends StatelessWidget {
  final BookingEntity booking;

  const OrderDetailPage({super.key, required this.booking});

  // Fungsi untuk update status ke Firebase
  Future<void> _kembalikanBarang(BuildContext context) async {
    try {
      // Menampilkan loading indikator (opsional tapi bagus untuk UX)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF376BE0))),
      );

      // Update data di Firebase
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.id)
          .update({
        'status': 'Menunggu Konfirmasi Pengembalian',
      });

      // Tutup loading
      Navigator.pop(context);

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan pengembalian terkirim ke pemilik!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman Riwayat
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context); // Tutup loading jika error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah pesanan sedang aktif (bisa dikembalikan)
    final bool bisaDikembalikan = booking.status.toLowerCase() == 'disetujui' ||
        booking.status.toLowerCase() == 'aktif';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Detail Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARD STATUS PESANAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Pesanan',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(booking.status,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // Warna dinamis berdasarkan status
                          color: booking.status.toLowerCase() == 'selesai'
                              ? Colors.green
                              : booking.status.toLowerCase() ==
                                      'menunggu konfirmasi pengembalian'
                                  ? Colors.blue
                                  : Colors.orange)),
                  Divider(height: 24, color: Colors.grey.withOpacity(0.2)),
                  const Text('ID Pesanan',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(booking.id,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. CARD INFO BARANG
            const Text('Barang yang Disewa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2))),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: const Color(0xFF376BE0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.image_outlined,
                        color: Color(0xFF376BE0)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.listingTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Durasi: ${booking.durationDays} hari',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. CARD RINCIAN PEMBAYARAN
            const Text('Rincian Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Harga', style: TextStyle(fontSize: 14)),
                  Text('Rp ${booking.totalPrice.toInt()}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF376BE0))),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── BOTTOM NAV BAR UNTUK TOMBOL KEMBALIKAN BARANG ──
      bottomNavigationBar: bisaDikembalikan
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF376BE0),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Tampilkan dialog konfirmasi sebelum mengeksekusi
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Theme.of(context).cardColor,
                      title: const Text('Kembalikan Barang?'),
                      content: const Text(
                          'Pastikan Anda sudah mengembalikan fisik barang ke pemilik sebelum menekan tombol ini.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal',
                                style: TextStyle(color: Colors.grey))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF376BE0)),
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog konfirmasi
                            _kembalikanBarang(
                                context); // Panggil fungsi Firebase
                          },
                          child: const Text('Ya, Sudah Dikembalikan',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Kembalikan Barang',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null, // Jika status tidak "Disetujui/Aktif", sembunyikan tombol
    );
  }
}
