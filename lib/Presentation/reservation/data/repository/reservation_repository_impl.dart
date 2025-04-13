import 'package:dartz/dartz.dart';
import 'package:hanouty/Presentation/reservation/domain/repository/reservation_repsitoty.dart';
import 'package:hanouty/presentation/reservation/data/datasource/reservation_remote_data_source.dart';
import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';
import 'package:hanouty/presentation/reservation/data/models/reservation_model.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  ReservationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Reservation> createReservation(Reservation reservation, String userId) async {
    final reservationModel = ReservationModel(
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
      productDetails: reservation.productDetails
    );
    
    return await remoteDataSource.createReservation(reservationModel, userId);
  }

  @override
  Future<Unit> deleteReservation(String id) async {
    await remoteDataSource.deleteReservation(id);
    return unit;
  }

  @override
  Future<List<Reservation>> getAllReservations({String? status}) async {
    return await remoteDataSource.getAllReservations(status: status);
  }

  @override
  Future<Reservation> getReservationById(String id) async {
    return await remoteDataSource.getReservationById(id);
  }

  @override
  Future<List<Reservation>> getReservationsByUserId(String userId, {String? status}) async {
    return await remoteDataSource.getReservationsByUserId(userId, status: status);
  }

  @override
  Future<Reservation> updateReservationStatus(
    String reservationId, 
    ReservationStatus status, 
    String userId
  ) async {
    return await remoteDataSource.updateReservationStatus(
      reservationId,
      status,
      userId
    );
  }
}