import 'package:hanouty/Presentation/reservation/domain/repository/reservation_repsitoty.dart';
import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';

class UpdateReservationStatusUsecase {
  final ReservationRepository repository;


  UpdateReservationStatusUsecase(this.repository);
  
  Future<Reservation> call(
    String reservationId, 
    ReservationStatus status, 
    String userId
  ) async {
    return await repository.updateReservationStatus(
      reservationId, 
      status, 
      userId,
    );
  }
}