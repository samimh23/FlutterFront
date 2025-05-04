//Data_Layer/datasources/farm_crop_remote_data_source.dart
import 'dart:convert';
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';
import 'package:http/http.dart' as http;
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'dart:math' as Math;
import '../../Domain_Layer/entities/farm_crop.dart';

class FarmCropRemoteDataSource {
  final String baseUrl = '${ApiEndpoints.baseUrl}/farm-crops';
  final http.Client client;
  final SecureStorageService authService;

  FarmCropRemoteDataSource({
    http.Client? client,
    required this.authService,
  }) : client = client ?? http.Client();

  // Helper method to get authentication headers
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await authService.getAccessToken();
      print("🔑 FarmCropRemoteDataSource: Access token retrieved");
      if (token == null || token.isEmpty) {
        print("⚠️ FarmCropRemoteDataSource: No access token found!");
      } else {
        print("✅ FarmCropRemoteDataSource: Token found [${token.substring(0, Math.min(10, token.length))}...]");
      }

      final headers = {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      print("🔍 FarmCropRemoteDataSource: Headers: ${headers.toString()}");
      return headers;
    } catch (e, stackTrace) {
      print("⚠️ ERROR in _getHeaders: ${e.toString()}");
      print(stackTrace);
      return {"Content-Type": "application/json"};
    }
  }

  Future<List<FarmCrop>> getAllCrops() async {
    try {
      print("📋 FarmCropRemoteDataSource: Getting all crops");
      final headers = await _getHeaders();

      print("📡 FarmCropRemoteDataSource: Sending GET request to $baseUrl");
      final response = await client.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      print("📢 FarmCropRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> cropList = json.decode(response.body);
        print("✅ FarmCropRemoteDataSource: Retrieved ${cropList.length} crops");
        return cropList.map((json) => FarmCrop.fromJson(json)).toList();
      } else {
        print("❌ FarmCropRemoteDataSource: Failed to fetch crops. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to fetch crops. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 FarmCropRemoteDataSource: Error getting crops: $e");
      throw ServerException(message: 'Failed to fetch crops: $e');
    }
  }

  Future<FarmCrop> getCropById(String id) async {
    try {
      print("🔍 FarmCropRemoteDataSource: Getting crop ID: $id");
      final headers = await _getHeaders();

      print("📡 FarmCropRemoteDataSource: Sending GET request to $baseUrl/$id");
      final response = await client.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print("📢 FarmCropRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final cropJson = json.decode(response.body);
        print("✅ FarmCropRemoteDataSource: Crop found");
        return FarmCrop.fromJson(cropJson);
      } else {
        print("❌ FarmCropRemoteDataSource: Failed to fetch crop. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to fetch crop. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 FarmCropRemoteDataSource: Error getting crop: $e");
      throw ServerException(message: 'Failed to fetch crop: $e');
    }
  }

  Future<List<FarmCrop>> getCropsByFarmMarketId(String farmMarketId) async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/farm/$farmMarketId'),
        headers: headers,
      );


      if (response.statusCode == 200) {
        final List<dynamic> cropList = json.decode(response.body);
        return cropList.map((json) => FarmCrop.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch crops for farm market ID: $farmMarketId. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crops by farm market ID: $e');
    }
  }

  Future<void> addCrop(FarmCrop crop) async {
    try {
      final headers = await _getHeaders();

      print("📡 FarmCropRemoteDataSource: Sending POST request to $baseUrl");
      print("📤 Request body: ${json.encode(crop.toJson())}");

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(crop.toJson()),
      );

      print("📢 Response Status: ${response.statusCode}");
      print("📢 Response Body: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        print("❌ FAILED TO ADD CROP. STATUS: ${response.statusCode}");
        print("====== ADDING CROP - FAILED ======\n");
        throw ServerException(message: 'Failed to add crop. Status: ${response.statusCode}, Response: ${response.body}');
      }

      print("✅ CROP ADDED SUCCESSFULLY");
      print("====== ADDING CROP - SUCCESS ======\n");
    } catch (e, stackTrace) {
      print("🔥 CRITICAL ERROR ADDING CROP: ${e.toString()}");
      print("STACK TRACE:");
      print(stackTrace);
      print("====== ADDING CROP - ERROR ======\n");
      throw ServerException(message: 'Failed to add crop: $e');
    }
  }

  Future<void> updateCrop(FarmCrop crop) async {
    try {
      if (crop.id == null || crop.id!.isEmpty) {
        throw ServerException(message: 'Cannot update crop: ID is missing');
      }

      final headers = await _getHeaders();

      print("📡 FarmCropRemoteDataSource: Sending PUT request to $baseUrl/${crop.id}");
      // Use forUpdate parameter to exclude _id from the request body
      final updateData = crop.toJson(forUpdate: true);
      print("📤 Request body: ${json.encode(updateData)}");

      final response = await client.put(
        Uri.parse('$baseUrl/${crop.id}'),
        headers: headers,
        body: json.encode(updateData),
      );

      print("📢 FarmCropRemoteDataSource: Response status: ${response.statusCode}");
      print("📢 FarmCropRemoteDataSource: Response body: ${response.body}");

      if (response.statusCode != 200) {
        print("❌ FarmCropRemoteDataSource: Failed to update crop. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to update crop. Status: ${response.statusCode}');
      }

      print("✅ FarmCropRemoteDataSource: Crop updated successfully");
    } catch (e) {
      print("🔥 FarmCropRemoteDataSource: Error updating crop: $e");
      throw ServerException(message: 'Failed to update crop: $e');
    }
  }

  Future<void> deleteCrop(String id) async {
    try {
      print("🗑️ FarmCropRemoteDataSource: Deleting crop ID: $id");
      final headers = await _getHeaders();

      print("📡 FarmCropRemoteDataSource: Sending DELETE request to $baseUrl/$id");
      final response = await client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      print("📢 FarmCropRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("❌ FarmCropRemoteDataSource: Failed to delete crop. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to delete crop. Status: ${response.statusCode}');
      }

      print("✅ FarmCropRemoteDataSource: Crop deleted successfully");
    } catch (e) {
      print("🔥 FarmCropRemoteDataSource: Error deleting crop: $e");
      throw ServerException(message: 'Failed to delete crop: $e');
    }
  }

  void dispose() {
    client.close();
  }
}