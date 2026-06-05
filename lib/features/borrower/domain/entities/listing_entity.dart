// lib/features/borrower/domain/entities/listing_entity.dart
import 'package:equatable/equatable.dart';

class ListingEntity extends Equatable {
  final String id;
  final int lenderId;
  final int categoryId;
  final String title;
  final String description;
  final double pricePerDay;
  final double? deposit;
  final String condition; // 'new' | 'good' | 'fair'
  final String status; // 'available' | 'rented' | 'unavailable'
  final String? lenderName;
  final String? lenderAvatar;
  final double? lenderRating;
  final String? categoryName;
  final List<String> photos;
  final double? averageRating;
  final int reviewCount;
  final String? location;

  const ListingEntity({
    required this.id,
    required this.lenderId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.pricePerDay,
    this.deposit,
    required this.condition,
    required this.status,
    this.lenderName,
    this.lenderAvatar,
    this.lenderRating,
    this.categoryName,
    this.photos = const [],
    this.averageRating,
    this.reviewCount = 0,
    this.location,
  });

  bool get isAvailable => status == 'available';

  String get conditionLabel {
    switch (condition) {
      case 'new':
        return 'Baru';
      case 'good':
        return 'Baik';
      case 'fair':
        return 'Cukup Baik';
      default:
        return condition;
    }
  }

  @override
  List<Object?> get props => [id, title, pricePerDay, status];
}

// lib/features/borrower/domain/entities/booking_entity.dart
class BookingEntity extends Equatable {
  final int id;
  final int borrowerId;
  final int listingId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;
  final String status;
  final String? notes;
  final String? listingTitle;
  final String? listingPhoto;
  final String? lenderName;
  final String? borrowerName;
  final String? borrowerAddress;
  final String? paymentMethod;

  const BookingEntity({
    required this.id,
    required this.borrowerId,
    required this.listingId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.listingTitle,
    this.listingPhoto,
    this.lenderName,
    this.borrowerName,
    this.borrowerAddress,
    this.paymentMethod,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';

  @override
  List<Object?> get props => [id, status, startDate, endDate];
}
