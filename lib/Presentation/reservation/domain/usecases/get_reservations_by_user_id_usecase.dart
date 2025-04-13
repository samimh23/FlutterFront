
import 'package:hanouty/Presentation/reservation/domain/repository/reservation_repsitoty.dart';
import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';

class GetReservationsByUserIdUsecase {
  final ReservationRepository repository;

  GetReservationsByUserIdUsecase(this.repository);
  
  Future<List<Reservation>> call(String userId, {String? status}) async {
    return await repository.getReservationsByUserId(userId, status: status);
  }
}