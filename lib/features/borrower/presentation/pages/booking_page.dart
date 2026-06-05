// lib/features/borrower/presentation/pages/booking_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/listing_provider.dart';
import 'checkout_page.dart'; // Pastikan import ke checkout_page

class BookingFormState {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  const BookingFormState({
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  // LOGIKA BARU: Jika baru pilih 1 tanggal (endDate null), durasi otomatis dihitung 1 hari (hari yang sama)
  int get totalDays {
    if (startDate == null) return 0;
    if (endDate == null) return 1;
    return endDate!.difference(startDate!).inDays + 1;
  }

  // Cukup pastikan startDate sudah dipilih, maka pemesanan sudah dianggap valid
  bool get isValid => startDate != null;

  BookingFormState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
  }) {
    return BookingFormState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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

  void selectRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
    );
  }
}

class BookingPage extends ConsumerWidget {
  final String listingId;
  const BookingPage({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);
    final bookingForm = ref.watch(bookingFormProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return listings.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (items) {
        final listing = items.firstWhere(
          (l) => l.id.toString() == listingId,
          orElse: () => items.first,
        );

        // Hitung total harga
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                                maxLines: 2),
                            Text(
                              '${currencyFormat.format(listing.pricePerDay)}/hari',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar (Hanya menggunakan onRangeSelected agar mulus sekali klik)
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
                    onRangeSelected: (start, end, _) {
                      ref
                          .read(bookingFormProvider.notifier)
                          .selectRange(start, end);
                    },
                    calendarStyle: const CalendarStyle(
                      rangeHighlightColor: AppColors.primaryLight,
                      rangeStartDecoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      rangeEndDecoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle),
                      todayTextStyle: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                      selectedDecoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),

                // Date Summary
                if (bookingForm.startDate != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
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
                            const Text('Mulai',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            Text(
                              dateFormat.format(bookingForm.startDate!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.primary),
                        Column(
                          children: [
                            const Text('Selesai',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            Text(
                              // Jika endDate null, tampilkan tanggal yang sama dengan startDate
                              dateFormat.format(bookingForm.endDate ??
                                  bookingForm.startDate!),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Durasi',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            Text(
                              '${bookingForm.totalDays} hari',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom bar dengan Total Harga
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4))
              ],
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
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123BCA),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: bookingForm.isValid
                      ? () {
                          // Pindah ke halaman checkout membawa data tanggal yang sah
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                listing: listing,
                                startDate: bookingForm.startDate!,
                                endDate: bookingForm.endDate ??
                                    bookingForm
                                        .startDate!, // Amankan hari yang sama
                                totalDays: bookingForm.totalDays,
                                totalPrice: totalPrice.toDouble(),
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text(bookingForm.isValid
                      ? 'Konfirmasi Pemesanan'
                      : 'Pilih Tanggal Terlebih Dahulu'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
