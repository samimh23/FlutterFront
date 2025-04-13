import 'dart:convert';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:hanouty/presentation/reservation/data/models/reservation_model.dart';
import 'package:hanouty/presentation/reservation/domain/entity/reservation.dart';
import 'package:http/http.dart' as http;

abstract class ReservationRemoteDataSource {
  Future<ReservationModel> createReservation(
      ReservationModel reservation, String userId);
  Future<ReservationModel> getReservationById(String id);
  Future<List<ReservationModel>> getAllReservations({String? status});
  Future<List<ReservationModel>> getReservationsByUserId(String userId,
      {String? status});
  Future<ReservationModel> updateReservationStatus(
      String reservationId, ReservationStatus status, String userId);
  Future<void> deleteReservation(String id);
}

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final http.Client client;

  ReservationRemoteDataSourceImpl({required this.client});
  final String baseUrl = 'http://127.0.0.1:3000/reservations';
  @override
  Future<ReservationModel> createReservation(
      ReservationModel reservation, String userId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        ...reservation.toJson(),
        'userId': userId,
      }),
    );

    if (response.statusCode == 201) {
      return ReservationModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException(
          message:
              _extractErrorMessage(response) ?? 'Failed to create reservation');
    }
  }

  @override
  Future<void> deleteReservation(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/reservations/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ServerException(
          message:
              _extractErrorMessage(response) ?? 'Failed to delete reservation');
    }
  }

  @override
  Future<List<ReservationModel>> getAllReservations({String? status}) async {
    final url = status != null
        ? '$baseUrl/reservations/all/status/$status'
        : '$baseUrl/reservations/all';

    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> reservationsJson = jsonResponse['data'] ?? [];

      return reservationsJson
          .map<ReservationModel>((json) => ReservationModel.fromJson(json))
          .toList();
    } else {
      throw ServerException(
          message:
              _extractErrorMessage(response) ?? 'Failed to fetch reservations');
    }
  }

  @override
  Future<ReservationModel> getReservationById(String id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/reservations/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ReservationModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException(
          message: _extractErrorMessage(response) ??
              'Failed to fetch reservation details');
    }
  }

  @override
  Future<List<ReservationModel>> getReservationsByUserId(String userId,
      {String? status}) async {
    final url = status != null
        ? '$baseUrl/reservations/user/$userId/status/$status'
        : '$baseUrl/reservations/user/$userId';

    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> reservationsJson = jsonResponse['data'] ?? [];

      return reservationsJson
          .map<ReservationModel>((json) => ReservationModel.fromJson(json))
          .toList();
    } else {
      throw ServerException(
          message: _extractErrorMessage(response) ??
              'Failed to fetch user reservations');
    }
  }

  @override
  Future<ReservationModel> updateReservationStatus(
      String reservationId, ReservationStatus status, String userId) async {
    final statusString =
        status.toString().split('.').last; // Convert enum to string

    final response = await client.patch(
      Uri.parse('$baseUrl/reservations/$reservationId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': statusString,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      return ReservationModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException(
          message: _extractErrorMessage(response) ??
              'Failed to update reservation status');
    }
  }

  // Helper method to extract error messages from API responses
  String? _extractErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic>) {
        return body['message'] ?? body['error'] ?? 'Unknown server error';
      }
      return 'Unexpected response format';
    } catch (_) {
      return 'Failed to parse error response: ${response.statusCode}';
    }
  }
}
