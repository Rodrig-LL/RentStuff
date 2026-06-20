import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'q': 'Bagaimana cara melakukan penyewaan barang?',
        'a':
            'Pilih barang yang ingin Anda sewa di beranda, tentukan rentang tanggal, lalu isi formulir pengiriman dan metode pembayaran di halaman checkout.'
      },
      {
        'q': 'Apakah dana jaminan (deposit) akan dikembalikan?',
        'a':
            'Ya, dana jaminan (deposit) bersifat aman dan refundable. Dana akan dikembalikan maksimal 1x24 jam setelah pemilik barang mengonfirmasi kondisi barang.'
      },
      {
        'q': 'Bisa sewa di hari yang sama?',
        'a':
            'Tentu saja bisa! Kami mendukung same-day rental di mana barang dapat diambil dan dikembalikan pada hari yang sama.'
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Pusat Bantuan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black12, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pertanyaan Populer (FAQ)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
                color: Colors.white,
              ),
              child: Column(
                children: faqs.asMap().entries.map((entry) {
                  int index = entry.key;
                  var faq = entry.value;
                  return Column(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          key: ValueKey(index),
                          title: Text(faq['q']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          expandedAlignment: Alignment.topLeft,
                          children: [
                            Text(faq['a']!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                      if (index < faqs.length - 1)
                        const Divider(height: 1, color: Colors.black12),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFECF1FF),
                border:
                    Border.all(color: const Color(0xFF123BCA).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic_outlined,
                      color: Color(0xFF123BCA), size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Butuh Bantuan Lain?',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('Hubungi Customer Service kami',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF123BCA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Membuka layanan chat Customer Service...')),
                      );
                    },
                    child: const Text('Chat CS',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
