import 'package:hanouty/Presentation/reservation/domain/repository/reservation_repsitoty.dart';
import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';

class GetAllReservationsUsecase {
  final ReservationRepository repository;

  GetAllReservationsUsecase(this.repository);
  
  Future<List<Reservation>> call({String? status}) async {
    return await repository.getAllReservations(status: status);
  }
}