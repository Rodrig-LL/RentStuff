// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(email: email, password: password);
      return Right(user.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure('Email atau password salah'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
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
        name: name, email: email, password: password, role: role, phone: phone,
      );
      return Right(user.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        return Left(ValidationFailure(errors?.toString() ?? 'Validasi gagal'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
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
      final user = await _remoteDataSource.getProfile();
      return Right(user.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return const Left(AuthFailure());
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }
}
