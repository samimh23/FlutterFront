import 'package:hanouty/Presentation/reservation/domain/repository/reservation_repsitoty.dart';
import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';

class GetReservationByIdUsecase {
  final ReservationRepository repository;

  GetReservationByIdUsecase(this.repository);
  
  Future<Reservation> call(String id) async {
    return await repository.getReservationById(id);
  }
}