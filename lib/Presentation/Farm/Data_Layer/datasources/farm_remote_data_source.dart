import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'dart:math' as Math;

import '../../../Sales/Domain_Layer/entities/sale.dart';
import '../../Domain_Layer/entity/farm.dart';

class FarmMarketRemoteDataSource {
  final String baseUrl = 'http://localhost:3000/farm';
  final http.Client client;
  final SecureStorageService authService;

  FarmMarketRemoteDataSource({
    http.Client? client,
    required this.authService,
  }) : client = client ?? http.Client();

  // Helper method to get authentication headers
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await authService.getAccessToken();
      if (token == null || token.isEmpty) {
      } else {
      }

      final headers = {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      return headers;
    } catch (e, stackTrace) {

      return {"Content-Type": "application/json"};
    }
  }

  Future<List<Farm>> getAllFarmMarkets() async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse(baseUrl),
        headers: headers,
      );


      if (response.statusCode == 200) {
        final List<dynamic> farmMarketList = json.decode(response.body);
        return farmMarketList.map((json) => Farm.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch farm markets. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch farm markets: $e');
    }
  }

  Future<List<Farm>> getFarmsByOwner(String owner) async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/farmer/$owner'),
        headers: headers,
      );


      if (response.statusCode == 200) {
        final List<dynamic> farmMarketList = json.decode(response.body);
        return farmMarketList.map((json) => Farm.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch farms by farmer ID. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch farms by farmer ID: $e');
    }
  }

  Future<Farm> getFarmMarketById(String id) async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final farmMarketJson = json.decode(response.body);
        return Farm.fromJson(farmMarketJson);
      } else {
        throw ServerException(message: 'Failed to fetch farm market. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch farm market: $e');
    }
  }

  Future<void> addFarmMarket(Farm farmMarket) async {
    try {
      final headers = await _getHeaders();

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(farmMarket.toJson()),
      );


      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(message: 'Failed to add farm market. Status: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to add farm market: $e');
    }
  }

  Future<void> updateFarmMarket(Farm farmMarket) async {
    try {
      if (farmMarket.id == null || farmMarket.id!.isEmpty) {
        throw ServerException(message: 'Cannot update farm market: ID is missing');
      }

      final headers = await _getHeaders();

      // Use forUpdate parameter to exclude _id from the request body
      final updateData = farmMarket.toJson(forUpdate: true);

      final response = await client.patch(
        Uri.parse('$baseUrl/${farmMarket.id}'),
        headers: headers,
        body: json.encode(updateData),
      );


      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update farm market. Status: ${response.statusCode}');
      }

    } catch (e) {
      throw ServerException(message: 'Failed to update farm market: $e');
    }
  }

  Future<List<dynamic>> getFarmProducts(String farmId) async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/$farmId/products'),
        headers: headers,
      );


      if (response.statusCode == 200) {
        final List<dynamic> productsList = json.decode(response.body);
        return productsList;
      } else {
        throw ServerException(message: 'Failed to fetch farm products. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch farm products: $e');
    }
  }

  Future<void> deleteFarmMarket(String id) async {
    try {
      final headers = await _getHeaders();

      final response = await client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to delete farm market. Status: ${response.statusCode}');
      }

    } catch (e) {
      throw ServerException(message: 'Failed to delete farm market: $e');
    }
  }

  Future<List<Sale>> getSalesByFarmMarketId(String farmMarketId) async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/sales/farm/$farmMarketId'),
        headers: headers,
      );


      if (response.statusCode == 200) {
        final jsonList = json.decode(response.body) as List;
        return jsonList.map((json) => Sale.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to load sales: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Error fetching sales: ${e.toString()}');
    }
  }

  void dispose() {
    client.close();
  }
}