import 'dart:convert';
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';
import 'package:http/http.dart' as http;
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:math' as Math;

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

  Future<List<dynamic>> getFarmProducts(String farmId) async {
    try {
      print("🔍 FarmMarketRemoteDataSource: Getting products for farm ID: $farmId");
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/$farmId/products'),
        headers: headers,
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> productsList = json.decode(response.body);
        print("✅ FarmMarketRemoteDataSource: Retrieved ${productsList.length} products");
        return productsList;
      } else {
        print("❌ FarmMarketRemoteDataSource: Failed to fetch farm products. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to fetch farm products. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error getting farm products: $e");
      throw ServerException(message: 'Failed to fetch farm products: $e');
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

  Future<String> uploadFarmImage(String farmId, String imagePath) async {
    try {
      print("📸 FarmMarketRemoteDataSource: Uploading image for farm ID: $farmId");
      final headers = await _getHeaders();

      // Create multipart request
      final uri = Uri.parse('$baseUrl/$farmId/upload-image');
      final request = http.MultipartRequest('POST', uri);

      // Add headers (excluding Content-Type for multipart)
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add file with the correct field name 'farmImage'
      final file = await http.MultipartFile.fromPath(
        'farmImage',  // This must match the backend's expected field name
        imagePath,
        // Add content type detection
        contentType: MediaType(
          'image',
          imagePath.split('.').last.toLowerCase(),
        ),
      );
      request.files.add(file);

      print("📤 FarmMarketRemoteDataSource: Sending request to ${request.url}");
      print("📤 FarmMarketRemoteDataSource: Headers: ${request.headers}");
      print("📤 FarmMarketRemoteDataSource: File name: ${file.filename}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");
      print("📢 FarmMarketRemoteDataSource: Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['farm'] != null && responseData['farm']['farmImage'] != null) {
          final imagePath = responseData['farm']['farmImage'];
          // Use the API_BASE_URL from your environment if available
          final baseApiUrl = ApiEndpoints.baseUrl;
          final imageUrl = '$baseApiUrl/farm/image/$imagePath';
          print("✅ FarmMarketRemoteDataSource: Image uploaded successfully: $imageUrl");
          return imageUrl;
        } else {
          print("❌ FarmMarketRemoteDataSource: Invalid response format");
          throw ServerException(
              message: 'Invalid response format from server',
              statusCode: response.statusCode
          );
        }
      } else {
        print("❌ FarmMarketRemoteDataSource: Upload failed with status ${response.statusCode}");
        final errorMessage = _parseErrorMessage(response);
        throw ServerException(
            message: 'Failed to upload image: $errorMessage',
            statusCode: response.statusCode
        );
      }
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error uploading image: $e");
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
          message: 'Failed to upload image: ${e.toString()}',
          statusCode: 500
      );
    }
  }

  Future<List<String>> getFarmImages(String farmId) async {
    try {
      print("🖼️ FarmMarketRemoteDataSource: Getting images for farm ID: $farmId");
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/$farmId'),
        headers: headers,
      );

      print("📢 FarmMarketRemoteDataSource: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final farmData = json.decode(response.body);
        final farmImage = farmData['farmImage'];

        if (farmImage != null && farmImage.isNotEmpty) {
          // Use the API_BASE_URL from your environment
          final baseApiUrl = ApiEndpoints.baseUrl;
          final imageUrl = '$baseApiUrl/farm/image/$farmImage';
          print("✅ FarmMarketRemoteDataSource: Retrieved farm image: $imageUrl");
          return [imageUrl];
        }

        print("ℹ️ FarmMarketRemoteDataSource: No images found for farm");
        return [];
      } else {
        print("❌ FarmMarketRemoteDataSource: Failed to fetch farm images. Status: ${response.statusCode}");
        final errorMessage = _parseErrorMessage(response);
        throw ServerException(
            message: 'Failed to fetch farm images: $errorMessage',
            statusCode: response.statusCode
        );
      }
    } catch (e) {
      print("🔥 FarmMarketRemoteDataSource: Error getting farm images: $e");
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
          message: 'Failed to fetch farm images: ${e.toString()}',
          statusCode: 500
      );
    }
  }

// Add this helper method to parse error messages
  String _parseErrorMessage(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      return errorData['message'] ?? response.body;
    } catch (e) {
      return response.body;
    }
  }

  void dispose() {
    client.close();
  }
}