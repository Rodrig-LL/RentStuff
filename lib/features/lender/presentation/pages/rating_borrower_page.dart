import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingBorrowerPage extends StatefulWidget {
  final String borrowerId;
  final String borrowerName;

  const RatingBorrowerPage({
    super.key,
    required this.borrowerId,
    required this.borrowerName,
  });

  @override
  State<RatingBorrowerPage> createState() =>
      _RatingBorrowerPageState();
}

class _RatingBorrowerPageState
    extends State<RatingBorrowerPage> {
  final reviewController =
      TextEditingController();

  double rating = 5;

  bool isLoading = false;

  Future<void> submitRating() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('borrower_reviews')
          .add({
        'borrowerId': widget.borrowerId,
        'borrowerName': widget.borrowerName,
        'rating': rating,
        'review': reviewController.text.trim(),
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('Rating berhasil dikirim'),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Beri Rating Borrower'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person),
            ),

            const SizedBox(height: 16),

            Text(
              widget.borrowerName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              itemCount: 5,
              itemBuilder: (_, __) =>
                  const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                rating = value;
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: reviewController,
              maxLines: 5,
              decoration:
                  const InputDecoration(
                hintText: 'Tulis ulasan',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : submitRating,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Kirim Rating',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}