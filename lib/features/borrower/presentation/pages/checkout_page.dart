import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/listing_entity.dart';
import '../providers/booking_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final ListingEntity listing;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;

  const CheckoutPage({
    super.key,
    required this.listing,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
  });

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPayment = 'Transfer Bank BCA';
  String _selectedShipping = 'Standard';
  double _shippingPrice = 15000;

  final Map<String, double> _shippingRates = {
    'Standard': 15000,
    'Ekonomi': 10000,
    'Kargo': 40000,
    'Instan': 30000,
  };

  void _updateShipping(String method) {
    setState(() {
      _selectedShipping = method;
      _shippingPrice = _shippingRates[method] ?? 15000;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double itemDeposit = widget.listing.deposit?.toDouble() ?? 0.0;

    double discount = 0.0;
    if (widget.totalDays >= 7) {
      discount = widget.totalPrice * 0.10;
    }

    double finalGrandTotal =
        (widget.totalPrice - discount) + _shippingPrice + itemDeposit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Checkout Penyewaan',
            style: TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data Pengirim & Penyewa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nama Lengkap Penerima',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Alamat Lengkap Pengiriman',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Catatan Tambahan (opsional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              const Text('Pilihan Opsi Pengiriman (Ongkir)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedShipping,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _shippingRates.keys.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(
                        '$method (${currencyFormat.format(_shippingRates[method])})'),
                  );
                }).toList(),
                onChanged: (val) => _updateShipping(val!),
              ),
              const SizedBox(height: 24),
              const Text('Metode Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedPayment,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  'Transfer Bank BCA',
                  'Transfer Bank Mandiri',
                  'E-Wallet (Dana/OVO)'
                ]
                    .map((label) =>
                        DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPayment = val!),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider()),
              const Text('Detailing Rincian Biaya Keseluruhan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (widget.totalDays >= 7) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Diskon Sewa (7+ Hari -10%)',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          Text('- ${currencyFormat.format(discount)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.listing.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Durasi: ${widget.totalDays} Hari',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(currencyFormat.format(widget.totalPrice),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkos Kirim ($_selectedShipping)',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        Text(currencyFormat.format(_shippingPrice),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Deposit Jaminan (Refundable)',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(currencyFormat.format(itemDeposit),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                            height: 1, color: Colors.grey.withOpacity(0.2))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Keseluruhan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          currencyFormat.format(finalGrandTotal),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF376BE0),
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF123BCA)),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Memproses pesanan...')));
                      final success =
                          await ref.read(bookingActionProvider).createBooking(
                                listingId: widget.listing.id,
                                listingTitle: widget.listing.title,
                                lenderId: widget.listing.lenderId.toString(),
                                startDate: widget.startDate,
                                endDate: widget.endDate,
                                totalPrice: finalGrandTotal,
                                durationDays: widget.totalDays,
                                listingPhoto: widget.listing.photos.isNotEmpty
                                    ? widget.listing.photos.first
                                    : '',
                              );
                      if (success) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Pesanan berhasil dibuat!'),
                              backgroundColor: Colors.green),
                        );
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Gagal membuat pesanan'),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('Buat Pesanan Sekarang',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
