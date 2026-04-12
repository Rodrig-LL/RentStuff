// lib/features/auth/data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? avatar;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  final String? token;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        phone: json['phone'],
        address: json['address'],
        avatar: json['avatar'],
        isVerified: json['is_verified'] ?? false,
        token: json['token'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'address': address,
        'avatar': avatar,
        'is_verified': isVerified,
        'token': token,
      };

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      phone: phone,
      address: address,
      avatar: avatar,
      isVerified: isVerified,
    );
  }
}
