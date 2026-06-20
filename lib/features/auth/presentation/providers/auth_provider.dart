// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, UserEntity?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity?> build() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      return await _mapFirebaseUserToEntity(currentUser);
    }
    return null;
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      final user = await dataSource.login(email: email, password: password);

      if (user != null) {
        final entity = await _mapFirebaseUserToEntity(user);
        state = AsyncData(entity);
      } else {
        state = const AsyncData(null);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      final user = await dataSource.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      if (user != null) {
        final entity = await _mapFirebaseUserToEntity(user);
        state = AsyncData(entity);
      } else {
        state = const AsyncData(null);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authRemoteDataSourceProvider);
      await dataSource.logout();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<UserEntity> _mapFirebaseUserToEntity(User firebaseUser) async {
    String role = 'borrower';

    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        role = doc.data()?['role'] ?? 'borrower';
      }
    } catch (_) {}

    return UserEntity(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Pengguna',
      email: firebaseUser.email ?? '',
      role: role,
      isVerified: firebaseUser.emailVerified,
    );
  }
}
