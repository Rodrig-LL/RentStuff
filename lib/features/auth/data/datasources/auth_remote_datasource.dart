// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  });
  Future<void> logout();
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage;

  AuthRemoteDataSourceImpl(this._dioClient, this._storage);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final user = UserModel.fromJson(response.data['data']);
    await _storage.write(key: AppConstants.tokenKey, value: user.token);
    return user;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final response = await _dioClient.dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        if (phone != null) 'phone': phone,
      },
    );
    final user = UserModel.fromJson(response.data['data']);
    await _storage.write(key: AppConstants.tokenKey, value: user.token);
    return user;
  }

  @override
  Future<void> logout() async {
    await _dioClient.dio.post('/auth/logout');
    await _storage.delete(key: AppConstants.tokenKey);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _dioClient.dio.get('/auth/profile');
    return UserModel.fromJson(response.data['data']);
  }
}
