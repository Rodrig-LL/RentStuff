import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LenderListingsPage extends StatefulWidget {
  const LenderListingsPage({super.key});

  @override
  State<LenderListingsPage> createState() =>
      _LenderListingsPageState();
}

class _LenderListingsPageState
    extends State<LenderListingsPage> {
  String searchQuery = '';
  String selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Saya'),
      ),

      body: Column(
        children: [

          // SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon:
                    const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // FILTER
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('aktif'),
                _buildFilterChip('menunggu'),
                _buildFilterChip('nonaktif'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error
                          .toString(),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs
                        .isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada barang',
                    ),
                  );
                }

                final listings =
                    snapshot.data!.docs;

                final filteredListings =
                    listings.where((doc) {
                  final data =
                      doc.data()
                          as Map<String,
                              dynamic>;

                  final title =
                      (data['title'] ?? '')
                          .toString()
                          .toLowerCase();

                  final status =
                      (data['status'] ?? '')
                          .toString()
                          .toLowerCase();

                  final matchSearch =
                      title.contains(
                    searchQuery
                        .toLowerCase(),
                  );

                  bool matchStatus = true;

if (selectedFilter == 'aktif') {
  matchStatus =
      status == 'available' ||
      status == 'aktif';
} else if (selectedFilter == 'menunggu') {
  matchStatus = status == 'pending';
} else if (selectedFilter == 'nonaktif') {
  matchStatus = status == 'unavailable';
}

                  return matchSearch &&
                      matchStatus;
                }).toList();

                return ListView.builder(
                  itemCount:
                      filteredListings.length,
                  itemBuilder:
                      (context, index) {
                    final doc =
                        filteredListings[
                            index];

                    final data =
                        doc.data()
                            as Map<String,
                                dynamic>;

                    final status =
    (data['status'] ?? '')
        .toString()
        .toLowerCase();

Color statusColor = Colors.green;

if (status == 'pending') {
  statusColor = Colors.orange;
}

if (status == 'unavailable') {
  statusColor = Colors.grey;
}

String statusLabel = 'Aktif';

if (status == 'pending') {
  statusLabel = 'Menunggu';
}

if (status == 'unavailable') {
  statusLabel = 'Nonaktif';
}

                    return Container(
                      margin:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                                    0.05),
                            blurRadius:
                                6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          // FOTO
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius
                                        .vertical(
                                  top: Radius
                                      .circular(
                                          16),
                                ),
                                child:
                                    Image.network(
                                  data['photos'] !=
                                              null &&
                                          (data['photos']
                                                  as List)
                                              .isNotEmpty
                                      ? data['photos']
                                          [0]
                                      : '',
                                  height: 180,
                                  width: double
                                      .infinity,
                                  fit: BoxFit
                                      .cover,
                                  errorBuilder:
                                      (
                                    _,
                                    __,
                                    ___,
                                  ) =>
                                          Container(
                                    height:
                                        180,
                                    color: Colors
                                        .grey
                                        .shade300,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 10,
                                right: 10,
                                child:
                                    Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        10,
                                    vertical:
                                        4,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        statusColor,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      20,
                                    ),
                                  ),
                                  child: Text(
  statusLabel,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.bold,
  ),
),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding:
                                const EdgeInsets
                                    .all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [

                                Text(
                                  data['title'] ??
                                      '',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        6),

                                Text(
                                  "Kondisi: ${data['condition'] ?? '-'}",
                                ),

                                const SizedBox(
                                    height:
                                        6),

                                Text(
  NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(
    data['pricePerDay'] ?? 0,
  ),
  style: const TextStyle(
    color: Color(0xFF1F4ACC),
    fontWeight: FontWeight.bold,
    fontSize: 18,
  ),
),

const SizedBox(height: 8),

Row(
  children: [
    const Icon(
      Icons.star,
      color: Colors.amber,
      size: 18,
    ),
    const SizedBox(width: 4),

    Text(
      '${(data['rating'] ?? 0).toDouble()}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(width: 6),

    Text(
      '(${data['reviewCount'] ?? 0} ulasan)',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    ),
  ],
),

const SizedBox(height: 12),

                                const SizedBox(
                                    height:
                                        12),

                                Row(
  children: [
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F4ACC),
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          context.push(
            '/lender/edit-listing/${doc.id}',
          );
        },
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 18),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Edit',
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(width: 8),

    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F4ACC),
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          context.push(
            '/lender/schedule/${doc.id}',
          );
        },
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 18,
            ),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Jadwal',
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(width: 8),

    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          await FirebaseFirestore
              .instance
              .collection('listings')
              .doc(doc.id)
              .delete();
        },
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, size: 18),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Hapus',
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
)
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          context.push(
            '/lender/add-listing',
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(
    String status,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(status),
        selected:
            selectedFilter == status,
        onSelected: (_) {
          setState(() {
            selectedFilter = status;
          });
        },
      ),
    );
  }
}