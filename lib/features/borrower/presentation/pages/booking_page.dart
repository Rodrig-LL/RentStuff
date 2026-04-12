// lib/features/borrower/presentation/pages/booking_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/listing_provider.dart';

// Booking state
class BookingFormState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String notes;
  final bool isLoading;

  const BookingFormState({
    this.startDate,
    this.endDate,
    this.notes = '',
    this.isLoading = false,
  });

  int get totalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  bool get isValid => startDate != null && endDate != null;

  BookingFormState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isLoading,
  }) {
    return BookingFormState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final bookingFormProvider =
    StateNotifierProvider.autoDispose<BookingFormNotifier, BookingFormState>(
  (_) => BookingFormNotifier(),
);

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(const BookingFormState());

  void selectDay(DateTime day) {
    if (state.startDate == null || (state.startDate != null && state.endDate != null)) {
      // Start new selection
      state = state.copyWith(startDate: day, endDate: null);
    } else {
      // Set end date
      if (day.isBefore(state.startDate!)) {
        state = state.copyWith(startDate: day, endDate: null);
      } else {
        state = state.copyWith(endDate: day);
      }
    }
  }

  void updateNotes(String notes) => state = state.copyWith(notes: notes);
}

class BookingPage extends ConsumerWidget {
  final String listingId;
  const BookingPage({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final bookingForm = ref.watch(bookingFormProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return listings.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (items) {
        final listing = items.firstWhere(
          (l) => l.id.toString() == listingId,
          orElse: () => items.first,
        );
        final totalPrice = bookingForm.totalDays * listing.pricePerDay;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pilih Tanggal Sewa'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing Summary
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2),
                            Text(
                              '${currencyFormat.format(listing.pricePerDay)}/hari',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: bookingForm.startDate ?? DateTime.now(),
                    calendarFormat: CalendarFormat.month,
                    rangeStartDay: bookingForm.startDate,
                    rangeEndDay: bookingForm.endDate,
                    rangeSelectionMode: RangeSelectionMode.enforced,
                    onDaySelected: (selected, _) =>
                        ref.read(bookingFormProvider.notifier).selectDay(selected),
                    onRangeSelected: (start, end, _) {
                      if (start != null) ref.read(bookingFormProvider.notifier).selectDay(start);
                      if (end != null) ref.read(bookingFormProvider.notifier).selectDay(end);
                    },
                    calendarStyle: const CalendarStyle(
                      rangeHighlightColor: AppColors.primaryLight,
                      rangeStartDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      rangeEndDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),

                // Date Summary
                if (bookingForm.startDate != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Mulai', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              dateFormat.format(bookingForm.startDate!),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                        Column(
                          children: [
                            const Text('Selesai', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              bookingForm.endDate != null
                                  ? dateFormat.format(bookingForm.endDate!)
                                  : '- pilih -',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: bookingForm.endDate != null ? AppColors.primary : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Durasi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              '${bookingForm.totalDays} hari',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Notes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Catatan (opsional)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        maxLines: 3,
                        onChanged: ref.read(bookingFormProvider.notifier).updateNotes,
                        decoration: const InputDecoration(
                          hintText: 'Tambahkan catatan untuk pemilik barang...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom bar with total
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bookingForm.isValid) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currencyFormat.format(listing.pricePerDay)} × ${bookingForm.totalDays} hari',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        currencyFormat.format(totalPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: bookingForm.isValid ? () => _showConfirmDialog(context, ref, totalPrice, currencyFormat) : null,
                  child: Text(bookingForm.isValid ? 'Konfirmasi Pemesanan' : 'Pilih Tanggal Terlebih Dahulu'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    double totalPrice,
    NumberFormat fmt,
  ) {
    final form = ref.read(bookingFormProvider);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Pesanan', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow('Tanggal Mulai', dateFormat.format(form.startDate!)),
            _InfoRow('Tanggal Selesai', dateFormat.format(form.endDate!)),
            _InfoRow('Durasi', '${form.totalDays} hari'),
            const Divider(),
            _InfoRow('Total Harga', fmt.format(totalPrice), isBold: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: submit booking API call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil dikirim! Menunggu persetujuan pemilik.'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/borrower/orders');
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('Pesan'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _InfoRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
