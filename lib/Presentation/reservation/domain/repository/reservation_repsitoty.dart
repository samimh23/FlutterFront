import 'package:dartz/dartz.dart';

import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';

abstract class ReservationRepository {
  /// Create a new reservation
  Future<Reservation> createReservation(Reservation reservation, String userId);
  
  /// Get a reservation by ID
  Future<Reservation> getReservationById(String id);
  
  /// Get all reservations (admin only)
  Future<List<Reservation>> getAllReservations({String? status});
  
  /// Get reservations for a specific user
  Future<List<Reservation>> getReservationsByUserId(String userId, {String? status});
  
  /// Update reservation status
  Future<Reservation> updateReservationStatus(
    String reservationId, 
    ReservationStatus status, 
    String userId
  );
  
  /// Delete a reservation (admin only)
  Future<Unit> deleteReservation(String id);
}