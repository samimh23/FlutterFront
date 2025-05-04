import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';
import 'package:hanouty/presentation/reservation/domain/repository/reservation_repsitoty.dart';

class CreateReservationUsecase {
  final ReservationRepository repository;

  CreateReservationUsecase(this.repository);

  // Change parameter type to Map<String, dynamic>
  Future<Reservation> call(Map<String, dynamic> reservationData, String userId) async {
    try {
      print("CreateReservationUsecase: Processing reservation data: $reservationData");
      
      // Create a properly formatted Reservation object from the map data
      final reservation = Reservation(
        id: '', // ID will be assigned by the backend
        product: reservationData['productId'] ?? '',
        quantity: reservationData['quantity'] ?? 1,
        user: userId,
        customerName: reservationData['customerName'] ?? '',
        customerPhone: reservationData['customerPhone'] ?? '',
        notes: reservationData['notes'],
        pickupDate: reservationData['pickupDate'] ?? '',
        pickupTime: reservationData['pickupTime'] ?? '',
        createdAt: reservationData['createdAt'] != null 
            ? DateTime.parse(reservationData['createdAt']) 
            : DateTime.now(),
        status: ReservationStatus.pending,
        productDetails: {'name': reservationData['productName']}
      );
      
      print("CreateReservationUsecase: Created reservation object: $reservation");
      return await repository.createReservation(reservation, userId);
    } catch (e) {
      print("CreateReservationUsecase: Error: $e");
      throw Exception('Failed to create reservation: $e');
    }
  }
}