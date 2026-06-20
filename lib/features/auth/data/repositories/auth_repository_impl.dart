import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepositoryImpl(this._remoteDataSource);

  Future<UserEntity> _mapFirebaseUser(User user) async {
    String role = 'borrower';
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        role = doc.data()?['role'] ?? 'borrower';
      }
    } catch (_) {}

    return UserEntity(
      id: user.uid,
      name: user.displayName ?? 'Pengguna',
      email: user.email ?? '',
      role: role,
      isVerified: user.emailVerified,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _remoteDataSource.login(email: email, password: password);
      if (user == null) return const Left(AuthFailure('Gagal login'));

      return Right(await _mapFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Email atau password salah'));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      if (user == null) return const Left(AuthFailure('Gagal mendaftar'));

      return Right(await _mapFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Gagal mendaftar'));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final user = _remoteDataSource.getCurrentUser();
      if (user != null) {
        return Right(await _mapFirebaseUser(user));
      }
      return const Left(AuthFailure('Sesi telah berakhir'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }
}
