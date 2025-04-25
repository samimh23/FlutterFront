import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required String id,
    required String product,
    required int quantity,
    required String user,
    required String customerName,
    required String customerPhone,
    String? notes,
    required DateTime pickupDate,
    required String pickupTime,
    required DateTime createdAt,
    required ReservationStatus status,
    Map<String, dynamic>? productDetails,
  }) : super(
          id: id,
          product: product,
          quantity: quantity,
          user: user,
          customerName: customerName,
          customerPhone: customerPhone,
          notes: notes,
          pickupDate: pickupDate,
          pickupTime: pickupTime,
          createdAt: createdAt,
          status: status,
          productDetails: productDetails,
        );

  // Factory to create a ReservationModel from JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['_id'] ?? '',
      product: json['product'] is Map ? json['product']['_id'] : json['product'] ?? '',
      quantity: json['quantity'] ?? 1,
      user: json['user'] is Map ? json['user']['_id'] : json['user'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      notes: json['notes'],
      pickupDate: json['pickupDate'] != null 
        ? DateTime.parse(json['pickupDate']) 
        : DateTime.now(),
      pickupTime: json['pickupTime'] ?? '12:00',
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
      status: _mapStatus(json['status']),
      productDetails: json['product'] is Map ? json['product'] : null,
    );
  }

  // Convert ReservationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'quantity': quantity,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'notes': notes,
      'pickupDate': pickupDate.toIso8601String(),
      'pickupTime': pickupTime,
      'status': status.toString().split('.').last,
    };
  }

  // Helper method to map string status to enum
  static ReservationStatus _mapStatus(String? status) {
    switch (status) {
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'pending':
      default:
        return ReservationStatus.pending;
    }
  }

  // Create a new instance with updated fields
  ReservationModel copyWith({
    String? id,
    String? product,
    int? quantity,
    String? user,
    String? customerName,
    String? customerPhone,
    String? notes,
    DateTime? pickupDate,
    String? pickupTime,
    DateTime? createdAt,
    ReservationStatus? status,
    Map<String, dynamic>? productDetails,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      user: user ?? this.user,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      productDetails: productDetails ?? this.productDetails,
    );
  }

  // Convert domain entity to data model
  factory ReservationModel.fromEntity(Reservation reservation) {
    return ReservationModel(
      id: reservation.id,
      product: reservation.product,
      quantity: reservation.quantity,
      user: reservation.user,
      customerName: reservation.customerName,
      customerPhone: reservation.customerPhone,
      notes: reservation.notes,
      pickupDate: reservation.pickupDate,
      pickupTime: reservation.pickupTime,
      createdAt: reservation.createdAt,
      status: reservation.status,
      productDetails: reservation.productDetails,
    );
  }
}