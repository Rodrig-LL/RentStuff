import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ListingSchedulePage extends StatefulWidget {
final String listingId;

const ListingSchedulePage({
super.key,
required this.listingId,
});

@override
State<ListingSchedulePage> createState() =>
_ListingSchedulePageState();
}

class _ListingSchedulePageState
extends State<ListingSchedulePage> {

DateTime _focusedDay = DateTime.now();

Set<DateTime> unavailableDates = {};

@override
void initState() {
super.initState();
loadSchedule();
}

Future<void> loadSchedule() async {

final doc =
    await FirebaseFirestore.instance
        .collection('listings')
        .doc(widget.listingId)
        .get();

final data = doc.data();

if (data != null &&
    data['unavailableDates'] != null) {

  unavailableDates =
      (data['unavailableDates'] as List)
          .map(
            (e) => DateTime.parse(e),
          )
          .toSet();

  setState(() {});
}


}

Future<void> saveSchedule() async {

await FirebaseFirestore.instance
    .collection('listings')
    .doc(widget.listingId)
    .update({

  'unavailableDates':
      unavailableDates
          .map(
            (e) =>
                e.toIso8601String(),
          )
          .toList(),
});

if (mounted) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content:
          Text('Jadwal berhasil disimpan'),
    ),
  );
}


}

@override
Widget build(BuildContext context) {


return Scaffold(
  appBar: AppBar(
    title: const Text('Jadwal Barang'),
  ),

  body: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [

        TableCalendar(
          firstDay:
              DateTime.utc(2025, 1, 1),
          lastDay:
              DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,

          selectedDayPredicate:
              (day) {

            return unavailableDates.any(
              (d) =>
                  d.year == day.year &&
                  d.month ==
                      day.month &&
                  d.day == day.day,
            );
          },

          onDaySelected:
              (selectedDay,
                  focusedDay) {

            setState(() {

              final exists =
                  unavailableDates.any(
                (d) =>
                    d.year ==
                        selectedDay.year &&
                    d.month ==
                        selectedDay.month &&
                    d.day ==
                        selectedDay.day,
              );

              if (exists) {

                unavailableDates
                    .removeWhere(
                  (d) =>
                      d.year ==
                          selectedDay.year &&
                      d.month ==
                          selectedDay.month &&
                      d.day ==
                          selectedDay.day,
                );
              } else {

                unavailableDates
                    .add(selectedDay);
              }

              _focusedDay =
                  focusedDay;
            });
          },
        ),

        const SizedBox(
          height: 20,
        ),

        ElevatedButton(
          onPressed: saveSchedule,
          child: const Text(
            'Simpan Jadwal',
          ),
        ),
      ],
    ),
  ),
);

}
}
