import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FAQ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            Text('• Bagaimana cara menambah barang?'),
            SizedBox(height: 10),

            Text('• Bagaimana menerima penyewaan?'),
            SizedBox(height: 10),

            Text('• Bagaimana menghubungi penyewa?'),
            SizedBox(height: 10),

            Text('• Bagaimana melihat jadwal barang?'),
          ],
        ),
      ),
    );
  }
}