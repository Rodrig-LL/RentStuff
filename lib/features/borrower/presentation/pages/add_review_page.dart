// lib/features/borrower/presentation/pages/add_review_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddReviewPage extends StatefulWidget {
  // 1. UBAH VARIABEL: Kita passing data 'booking' utuh agar bisa update Firebase
  final dynamic booking;

  const AddReviewPage({super.key, required this.booking});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int _selectedRating = 0;
  final _reviewController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // 2. FUNGSI FIREBASE: Mengirim ulasan ke database
  Future<void> _submitReview() async {
    setState(() => _isLoading = true);

    print("Mencoba update dokumen ID: ${widget.booking.id}");

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.booking.id.toString())
          .update({
        'isReviewed': true,
        'reviewRating': _selectedRating,
        'reviewText': _reviewController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context); // Kembali ke Riwayat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Terima kasih! Ulasan Anda berhasil dikirim.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mengirim ulasan: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. TEMA GELAP: Mengubah background statis menjadi dinamis
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Beri Ulasan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              size: 18, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Card Info Barang
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: const Color(0xFF123BCA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.image_outlined,
                        size: 40, color: Color(0xFF123BCA)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.booking.listingTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Rating Bintang Interaktif
            const Text('Bagaimana kualitas barang ini?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    index < _selectedRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: index < _selectedRating
                        ? const Color(0xFFFACC15)
                        : Colors.grey.withOpacity(0.4),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),

            // Kolom Ulasan
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Tulis Ulasan Anda (Opsional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Bagikan pengalaman Anda menggunakan barang ini...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.withOpacity(0.2))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF123BCA))),
                fillColor: Theme.of(context).cardColor,
                filled: true,
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF123BCA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed:
                    _selectedRating == 0 || _isLoading ? null : _submitReview,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Kirim Ulasan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
