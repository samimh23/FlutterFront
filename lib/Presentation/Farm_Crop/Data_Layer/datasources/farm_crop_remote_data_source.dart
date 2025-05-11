//Data_Layer/datasources/farm_crop_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'dart:math' as Math;
import '../../Domain_Layer/entities/farm_crop.dart';

class FarmCropRemoteDataSource {
  final String baseUrl = 'http://localhost:3000/farm-crops';
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
      if (token == null || token.isEmpty) {
      } else {
      }

      final headers = {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      return headers;
    } catch (e, stackTrace) {
      print(stackTrace);
      return {"Content-Type": "application/json"};
    }
  }

  Future<List<FarmCrop>> getAllCrops() async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse(baseUrl),
        headers: headers,
      );


      if (response.statusCode == 200) {
        final List<dynamic> cropList = json.decode(response.body);
        return cropList.map((json) => FarmCrop.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to fetch crops. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crops: $e');
    }
  }

  Future<FarmCrop> getCropById(String id) async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final cropJson = json.decode(response.body);
        return FarmCrop.fromJson(cropJson);
      } else {
        throw ServerException(message: 'Failed to fetch crop. Status: ${response.statusCode}');
      }
    } catch (e) {
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

      
      final response = await client.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(crop.toJson()),
      );


      if (response.statusCode != 201 && response.statusCode != 200) {

        throw ServerException(message: 'Failed to add crop. Status: ${response.statusCode}, Response: ${response.body}');
      }

    } catch (e) {
      throw ServerException(message: 'Failed to add crop: $e');
    }
  }

  Future<void> updateCrop(FarmCrop crop) async {
    try {
      if (crop.id == null || crop.id!.isEmpty) {
        throw ServerException(message: 'Cannot update crop: ID is missing');
      }

      final headers = await _getHeaders();

      // Use forUpdate parameter to exclude _id from the request body
      final updateData = crop.toJson(forUpdate: true);

      final response = await client.put(
        Uri.parse('$baseUrl/${crop.id}'),
        headers: headers,
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update crop. Status: ${response.statusCode}');
      }

    } catch (e) {
      throw ServerException(message: 'Failed to update crop: $e');
    }
  }

  Future<void> deleteCrop(String id) async {
    try {
      final headers = await _getHeaders();

      final response = await client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );


      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to delete crop. Status: ${response.statusCode}');
      }
      
    } catch (e) {
      throw ServerException(message: 'Failed to delete crop: $e');
    }
  }

  // New methods for farm crop conversion
  Future<Map<String, dynamic>> convertToProduct(String cropId) async {
    try {
      final headers = await _getHeaders();

      final response = await client.post(
        Uri.parse('$baseUrl/$cropId/convert-to-product'),
        headers: headers,
      );



      if (response.statusCode == 200 || response.statusCode == 201) {
        final resultJson = json.decode(response.body);
        return resultJson;
      } else {
        throw ServerException(message: 'Failed to convert crop to product. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to convert crop to product: $e');
    }
  }

  Future<Map<String, dynamic>> confirmAndConvert(String cropId, String auditReport) async {
    try {
      final headers = await _getHeaders();

      final requestBody = json.encode({'auditReport': auditReport});

      final response = await client.post(
        Uri.parse('$baseUrl/$cropId/confirm-and-convert'),
        headers: headers,
        body: requestBody,
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final resultJson = json.decode(response.body);
        return resultJson;
      } else {
        throw ServerException(message: 'Failed to confirm and convert crop. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to confirm and convert crop: $e');
    }
  }

  Future<Map<String, dynamic>> processAllConfirmed() async {
    try {
      final headers = await _getHeaders();

      final response = await client.post(
        Uri.parse('$baseUrl/process-confirmed'),
        headers: headers,
      );



      if (response.statusCode == 200 || response.statusCode == 201) {
        final resultJson = json.decode(response.body);
        return resultJson;
      } else {
        throw ServerException(message: 'Failed to process confirmed crops. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(message: 'Failed to process confirmed crops: $e');
    }
  }

  void dispose() {
    client.close();
  }
}