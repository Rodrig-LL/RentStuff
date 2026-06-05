// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Providers
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    ref.watch(dioClientProvider),
    ref.watch(flutterSecureStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Auth State
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, UserEntity?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    // Check if token exists on app start
    final storage = ref.read(flutterSecureStorageProvider);
    final token = await storage.read(key: AppConstants.tokenKey);
    if (token == null) return null;

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getProfile();
    return result.fold((_) => null, (user) => user);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    final role = email.contains('lender') ? 'lender' : 'borrower';
    state = AsyncData(UserEntity(
      id: 1,
      name: 'User Demo',
      email: email,
      role: role,
      isVerified: true,
    ));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    state = AsyncData(UserEntity(
      id: 1,
      name: name,
      email: email,
      role: role,
      phone: phone,
      isVerified: false,
    ));
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}
