import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'dart:math' as Math;

import '../../../../Core/Utils/Api_EndPoints.dart';
import '../../../Sales/Domain_Layer/entities/sale.dart';
import '../../Domain_Layer/entity/farm.dart';

class FarmMarketRemoteDataSource {
  final String baseUrl = '${ApiEndpoints.baseUrl}/farm';
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
        print("⚠️ FarmMarketRemoteDataSource: No access token found!");
      } else {
        print("✅ FarmMarketRemoteDataSource: Token found");
      }

      final headers = {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      return headers;
    } catch (e, stackTrace) {
      print("⚠️ Error in _getHeaders: ${e.toString()}");
      print(stackTrace);
      return {"Content-Type": "application/json"};
    }
  }

  Future<List<Farm>> getAllFarmMarkets() async {
    try {
      print("📋 FarmMarketRemoteDataSource: Getting all farm markets");
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> farmMarketList = json.decode(response.body);
        print("✅ FarmMarketRemoteDataSource: Retrieved ${farmMarketList.length} farm markets");
        return farmMarketList.map((json) => Farm.fromJson(json)).toList();
      } else {
        print("❌ FarmMarketRemoteDataSource: Failed to fetch farm markets. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to fetch farm markets. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error getting farm markets: $e");
      throw ServerException(message: 'Failed to fetch farm markets: $e');
    }
  }

  Future<List<Farm>> getFarmsByOwner(String owner) async {
    try {
      print("🔍 FarmMarketRemoteDataSource: Getting farms for owner ID: $owner");
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/farmer/$owner'),
        headers: headers,
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> farmMarketList = json.decode(response.body);
        print("✅ FarmMarketRemoteDataSource: Retrieved ${farmMarketList.length} farms");
        return farmMarketList.map((json) => Farm.fromJson(json)).toList();
      } else {
        print("❌ FarmMarketRemoteDataSource: Failed to fetch farms by farmer ID. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to fetch farms by farmer ID. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error getting farms by owner: $e");
      throw ServerException(message: 'Failed to fetch farms by farmer ID: $e');
    }
  }

  Future<Farm> getFarmMarketById(String id) async {
    try {
      print("🔍 FarmMarketRemoteDataSource: Getting farm market ID: $id");
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final farmMarketJson = json.decode(response.body);
        print("✅ FarmMarketRemoteDataSource: Farm market found");
        return Farm.fromJson(farmMarketJson);
      } else {
        print("❌ FarmMarketRemoteDataSource: Failed to fetch farm market. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to fetch farm market. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error getting farm market: $e");
      throw ServerException(message: 'Failed to fetch farm market: $e');
    }
  }

  Future<void> addFarmMarket(Farm farmMarket) async {
    try {
      print("📡 FarmMarketRemoteDataSource: Adding new farm market");
      final headers = await _getHeaders();

      print("📤 Request body: ${json.encode(farmMarket.toJson())}");
      final response = await client.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(farmMarket.toJson()),
      );

      print("📢 Response Status: ${response.statusCode}");
      print("📢 Response Body: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        print("❌ FAILED TO ADD FARM MARKET. STATUS: ${response.statusCode}");
        throw ServerException(message: 'Failed to add farm market. Status: ${response.statusCode}, Response: ${response.body}');
      }

      print("✅ FARM MARKET ADDED SUCCESSFULLY");
    } catch (e, stackTrace) {
      print("🔥 CRITICAL ERROR ADDING FARM MARKET: ${e.toString()}");
      print("STACK TRACE:");
      print(stackTrace);
      throw ServerException(message: 'Failed to add farm market: $e');
    }
  }

  Future<void> updateFarmMarket(Farm farmMarket) async {
    try {
      if (farmMarket.id == null || farmMarket.id!.isEmpty) {
        throw ServerException(message: 'Cannot update farm market: ID is missing');
      }

      final headers = await _getHeaders();

      print("📡 FarmMarketRemoteDataSource: Sending PATCH request to $baseUrl/${farmMarket.id}");
      // Use forUpdate parameter to exclude _id from the request body
      final updateData = farmMarket.toJson(forUpdate: true);
      print("📤 Request body: ${json.encode(updateData)}");

      final response = await client.patch(
        Uri.parse('$baseUrl/${farmMarket.id}'),
        headers: headers,
        body: json.encode(updateData),
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");
      print("📢 FarmMarketRemoteDataSource: Response body: ${response.body}");

      if (response.statusCode != 200) {
        print("❌ FarmMarketRemoteDataSource: Failed to update farm market. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to update farm market. Status: ${response.statusCode}');
      }

      print("✅ FarmMarketRemoteDataSource: Farm market updated successfully");
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error updating farm market: $e");
      throw ServerException(message: 'Failed to update farm market: $e');
    }
  }

  Future<void> deleteFarmMarket(String id) async {
    try {
      print("🗑️ FarmMarketRemoteDataSource: Deleting farm market ID: $id");
      final headers = await _getHeaders();

      print("📡 FarmMarketRemoteDataSource: Sending DELETE request to $baseUrl/$id");
      final response = await client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("❌ FarmMarketRemoteDataSource: Failed to delete farm market. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to delete farm market. Status: ${response.statusCode}');
      }

      print("✅ FarmMarketRemoteDataSource: Farm market deleted successfully");
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error deleting farm market: $e");
      throw ServerException(message: 'Failed to delete farm market: $e');
    }
  }

  Future<List<Sale>> getSalesByFarmMarketId(String farmMarketId) async {
    try {
      print("🔍 FarmMarketRemoteDataSource: Getting sales for farm market ID: $farmMarketId");
      final headers = await _getHeaders();

      print("📡 FarmMarketRemoteDataSource: Sending GET request to $baseUrl/sales/farm/$farmMarketId");
      final response = await client.get(
        Uri.parse('$baseUrl/sales/farm/$farmMarketId'),
        headers: headers,
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonList = json.decode(response.body) as List;
        print("✅ FarmMarketRemoteDataSource: Retrieved ${jsonList.length} sales");
        return jsonList.map((json) => Sale.fromJson(json)).toList();
      } else {
        print("❌ FarmMarketRemoteDataSource: Failed to load sales. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to load sales: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error fetching sales: $e");
      throw ServerException(message: 'Error fetching sales: ${e.toString()}');
    }
  }

  void dispose() {
    client.close();
  }
}