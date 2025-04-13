import 'package:equatable/equatable.dart';

enum ReservationStatus {
  pending,
  completed,
  cancelled,
}

class Reservation extends Equatable {
  final String id;
  final String product; // Product ID
  final int quantity;
  final String user; // User ID
  final String customerName;
  final String customerPhone;
  final String? notes;
  final DateTime pickupDate;
  final String pickupTime;
  final DateTime createdAt;
  final ReservationStatus status;
  final Map<String, dynamic>?
      productDetails; // Populated product details from backend

  const Reservation({
    required this.id,
    required this.product,
    required this.quantity,
    required this.user,
    required this.customerName,
    required this.customerPhone,
    this.notes,
    required this.pickupDate,
    required this.pickupTime,
    required this.createdAt,
    required this.status,
    this.productDetails,
  });

  String get statusString {
    switch (status) {
      case ReservationStatus.completed:
        return 'Completed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.pending:
        return 'Pending';
    }
  }
  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
        user,
        customerName,
        customerPhone,
        notes,
        pickupDate,
        pickupTime,
        createdAt,
        status,
        productDetails,
      ];
}
