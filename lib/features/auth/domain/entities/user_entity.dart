// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role; // 'borrower' | 'lender' | 'admin'
  final String? phone;
  final String? address;
  final String? avatar;
  final bool isVerified;
  final String? token;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.avatar,
    this.isVerified = false,
    this.token,
  });

  bool get isLender => role == 'lender';
  bool get isBorrower => role == 'borrower';
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, name, email, role, isVerified];
}
