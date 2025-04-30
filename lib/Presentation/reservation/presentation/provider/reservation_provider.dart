import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/reservation/domain/entity/reservation.dart';
import 'package:hanouty/Presentation/reservation/domain/usecases/create_reservation_usecase.dart';

class ReservationProvider extends ChangeNotifier {
  final CreateReservationUsecase createReservationUseCase;
  
  // State variables
  bool _isLoading = false;
  String? _error;
  List<Reservation> _reservations = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Reservation> get reservations => _reservations;
  
  // Constructor
  ReservationProvider({
    required this.createReservationUseCase,
  });

  // Create reservation method
  Future<void> createReservation(dynamic reservationData, String userId) async {
    if (_isLoading) return;
    _setLoading(true);
    _error = null;

    try {
      print("ReservationProvider: Creating reservation with data: $reservationData");
      print("ReservationProvider: Using user ID: $userId");
      
      final createdReservation = await createReservationUseCase.call(reservationData, userId);
      
      _reservations.add(createdReservation as Reservation);
      print('Reservation created successfully: ${createdReservation.id}');
    } catch (e) {
      _error = e.toString();
      print('Error creating reservation: $_error');
      throw Exception('Failed to create reservation: $_error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}