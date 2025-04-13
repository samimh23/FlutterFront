
import 'package:hanouty/Presentation/reservation/domain/repository/reservation_repsitoty.dart';
import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';

class CreateReservationUsecase {
  final ReservationRepository repository;

  CreateReservationUsecase(this.repository);
  
  Future<Reservation> call(Reservation reservation, String userId) async {
    return await repository.createReservation(reservation, userId);
  }
}