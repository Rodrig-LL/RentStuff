import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';

class ListingRemoteDataSource {
  final DioClient dioClient;

  ListingRemoteDataSource(this.dioClient);

  Future<void> createListing({
    required String title,
    required String description,
    required int categoryId,
    required double pricePerDay,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/lender/listings',
        data: {
          'title': title,
          'description': description,
          'category_id': categoryId,
          'price_per_day': pricePerDay,
          'condition': 'good',
        },
      );

      print(response.data);
    } on DioException catch (e) {
      print('STATUS : ${e.response?.statusCode}');
      print('ERROR  : ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<dynamic>> getMyListings() async {
    final response = await dioClient.dio.get(
      '/lender/listings',
    );

    return response.data['data'] ?? [];
  }

  Future<void> deleteListing(int id) async {
    await dioClient.dio.delete(
      '/lender/listings/$id',
    );
  }

  Future<void> updateListing({
    required int id,
    required String title,
    required String description,
    required int categoryId,
    required double pricePerDay,
  }) async {
    await dioClient.dio.put(
      '/lender/listings/$id',
      data: {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'price_per_day': pricePerDay,
        'condition': 'good',
      },
    );
  }
}