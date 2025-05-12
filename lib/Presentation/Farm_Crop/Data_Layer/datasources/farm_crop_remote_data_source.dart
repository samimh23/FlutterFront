import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/errors/exceptions.dart';
import 'dart:math' as Math;
import '../../../../Core/Utils/Api_EndPoints.dart';
import '../../Domain_Layer/entities/farm_crop.dart';
import 'package:http_parser/http_parser.dart';

class FarmCropRemoteDataSource {
  final String baseUrl = '${ApiEndpoints.baseUrl}/farm-crops';
  final http.Client client;
  final SecureStorageService authService;

  FarmCropRemoteDataSource({
    http.Client? client,
    required this.authService,
  }) : client = client ?? http.Client();

  // Helper method to get authentication headers
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    try {
      final token = await authService.getAccessToken();
      print("🔑 FarmCropRemoteDataSource: Access token retrieved");
      if (token == null || token.isEmpty) {
        print("⚠️ FarmCropRemoteDataSource: No access token found!");
      } else {
        print("✅ FarmCropRemoteDataSource: Token found [${token.substring(0, Math.min(10, token.length))}...]");
      }

      final headers = {
        if (!isMultipart) "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      print("🔍 FarmCropRemoteDataSource: Headers: ${headers.toString()}");
      return headers;
    } catch (e, stackTrace) {
      print("⚠️ ERROR in _getHeaders: ${e.toString()}");
      print(stackTrace);
      return isMultipart ? {} : {"Content-Type": "application/json"};
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

  // New methods for farm crop conversion
  Future<Map<String, dynamic>> convertToProduct(String cropId) async {
    try {
      final headers = await _getHeaders();

      print("📡 FarmCropRemoteDataSource: Sending POST request to $baseUrl/$cropId/convert-to-product");
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

  // New method for uploading crop images
  Future<Map<String, dynamic>> uploadCropImage(String cropId, File imageFile) async {
    try {
      print("📸 FarmCropRemoteDataSource: Uploading image for crop ID: $cropId");

      final headers = await _getHeaders(isMultipart: true);

      // Create multipart request
      final uri = Uri.parse('$baseUrl/$cropId/upload-picture');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      headers.forEach((key, value) {
        request.headers[key] = value;
      });

      // Add the file
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      print("📤 FarmCropRemoteDataSource: Adding file $fileName with mime type $mimeType");

      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: fileName,
        contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
      );

      request.files.add(multipartFile);

      print("📡 FarmCropRemoteDataSource: Sending multipart request to $uri");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📢 FarmCropRemoteDataSource: Response status: ${response.statusCode}");
      print("📢 FarmCropRemoteDataSource: Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resultJson = json.decode(response.body);
        print("✅ FarmCropRemoteDataSource: Image uploaded successfully");
        return resultJson;
      } else {
        print("❌ FarmCropRemoteDataSource: Failed to upload image. Status: ${response.statusCode}");
        throw ServerException(message: 'Failed to upload image. Status: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      print("🔥 FarmCropRemoteDataSource: Error uploading image: $e");
      throw ServerException(message: 'Failed to upload image: $e');
    }
  }

  // Helper method to determine MIME type based on file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg'; // Default to JPEG if unknown
    }
  }

  // Get the full image URL for a crop
  String getCropImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return '${ApiEndpoints.baseUrl}/farm-crops/image/$imagePath';
  }

  void dispose() {
    client.close();
  }
}