import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/listing_provider.dart';
import 'checkout_page.dart';

class BookingFormState {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  const BookingFormState({
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  int get totalDays {
    if (startDate == null) return 0;
    if (endDate == null) return 1;
    return endDate!.difference(startDate!).inDays + 1;
  }

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

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(const BookingFormState());

  void onDateSelected(DateTime selectedDate) {
    if (state.endDate != null && isSameDay(selectedDate, state.endDate)) {
      state = BookingFormState(startDate: state.startDate, endDate: null);
      return;
    }

    if (state.startDate != null && isSameDay(selectedDate, state.startDate)) {
      state = const BookingFormState();
      return;
    }

    if (state.startDate == null ||
        (state.startDate != null && state.endDate != null)) {
      state = BookingFormState(startDate: selectedDate, endDate: null);
    } else if (selectedDate.isBefore(state.startDate!)) {
      state = BookingFormState(startDate: selectedDate, endDate: null);
    } else {
      state =
          BookingFormState(startDate: state.startDate, endDate: selectedDate);
    }
  }
}

final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  return BookingFormNotifier();
});

class BookingPage extends ConsumerWidget {
  final String listingId;

  const BookingPage({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingForm = ref.watch(bookingFormProvider);
    final bookingFormNotifier = ref.read(bookingFormProvider.notifier);

    final listingsAsync = ref.watch(listingsProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return listingsAsync.when(
      loading: () => const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF123BCA)))),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $error'))),
      data: (items) {
        final listing = items.firstWhere(
          (l) => l.id.toString() == listingId,
          orElse: () => items.first,
        );

        final totalPrice = bookingForm.totalDays * listing.pricePerDay;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            title: const Text(
              'Pilih Tanggal Sewa',
              style: TextStyle(
                  color: Color(0xFF123BCA), fontWeight: FontWeight.bold),
            ),
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
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF123BCA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image_outlined,
                                  color: Color(0xFF123BCA)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${currencyFormat.format(listing.pricePerDay)}/hari',
                                    style: const TextStyle(
                                        color: Color(0xFF123BCA),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Pilih Rentang Tanggal',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF123BCA),
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 90)),
                          focusedDay: bookingForm.startDate ?? DateTime.now(),
                          currentDay: DateTime.now(),
                          rangeStartDay: bookingForm.startDate,
                          rangeEndDay: bookingForm.endDate,
                          calendarFormat: CalendarFormat.month,
                          rangeSelectionMode: RangeSelectionMode.enforced,
                          onDaySelected: (selectedDay, focusedDay) {
                            bookingFormNotifier.onDateSelected(selectedDay);
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: const CalendarStyle(
                            rangeHighlightColor: Color(0xFFD6E4FF),
                            rangeStartDecoration: BoxDecoration(
                                color: Color(0xFF123BCA),
                                shape: BoxShape.circle),
                            rangeEndDecoration: BoxDecoration(
                                color: Color(0xFF123BCA),
                                shape: BoxShape.circle),
                            todayDecoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle),
                            todayTextStyle: TextStyle(
                                color: Color(0xFF123BCA),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (bookingForm.isValid) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Mulai Sewa',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                    DateFormat('dd MMM yyyy', 'id_ID')
                                        .format(bookingForm.startDate!),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Selesai Sewa',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                    DateFormat('dd MMM yyyy', 'id_ID').format(
                                        bookingForm.endDate ??
                                            bookingForm.startDate!),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Durasi',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                    '${bookingForm.totalDays} Hari',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF123BCA)),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Sewa Barang',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                    currencyFormat.format(totalPrice),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              if (listing.deposit != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Deposit Jaminan (Wajib)',
                                        style: TextStyle(color: Colors.grey)),
                                    Text(
                                      currencyFormat.format(listing.deposit),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (bookingForm.isValid && bookingForm.totalDays > 7) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Durasi sewa melebihi batas maksimal yang ditentukan pemilik (Maksimal 7 hari).',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimasi Sewa:',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(
                            currencyFormat.format(totalPrice),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF123BCA)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Builder(builder: (context) {
                        final bool isDurationValid = bookingForm.totalDays <= 7;
                        final bool isFormValid =
                            bookingForm.isValid && isDurationValid;

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFormValid
                                ? const Color(0xFF123BCA)
                                : Colors.grey.withOpacity(0.5),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: isFormValid
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutPage(
                                        listing: listing,
                                        startDate: bookingForm.startDate!,
                                        endDate: bookingForm.endDate ??
                                            bookingForm.startDate!,
                                        totalDays: bookingForm.totalDays,
                                        totalPrice: totalPrice.toDouble(),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Text(
                            !bookingForm.isValid
                                ? 'Pilih Tanggal Terlebih Dahulu'
                                : !isDurationValid
                                    ? 'Durasi Melebihi Batas (Maks 7 Hari)'
                                    : 'Konfirmasi Pemesanan',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
