import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../Utils/secure_storage.dart';
import '../api/api_exceptions.dart';

class UploadService {
  final SecureStorageService _secureStorageService;
  final String _baseUrl;

  UploadService({
    String? baseUrl,
    SecureStorageService? secureStorageService,
  }) :
        _baseUrl = baseUrl ?? 'http://localhost:3000',
        _secureStorageService = secureStorageService ?? SecureStorageService();

  // Upload for mobile platforms using File
  Future<String> uploadProfilePicture(File imageFile) async {
    final token = await _secureStorageService.getAccessToken();

    if (token == null) {
      throw ApiException('Authentication required');
    }

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/users/upload-profile-picture'),
      );

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Get file name and extension
      final fileName = path.basename(imageFile.path);
      final fileExtension = path.extension(fileName).toLowerCase();

      // Set the content type based on file extension
      final contentType = fileExtension == '.png'
          ? 'image/png'
          : fileExtension == '.jpg' || fileExtension == '.jpeg'
          ? 'image/jpeg'
          : 'application/octet-stream';

      // Add the file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture',  // Make sure this matches your API's expected field name
          imageFile.path,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['profilePicture'] ?? '';  // Adjust based on your API response
      } else if (response.statusCode == 404 && response.body.contains('User not found')) {
        throw ApiException('User not found. Please check your authentication.');
      } else {
        throw ApiException('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Upload failed: ${e.toString()}');
    }
  }

  // Upload for web platforms using Uint8List
  Future<String> uploadProfilePictureWeb(Uint8List imageBytes, String fileName) async {
    final token = await _secureStorageService.getAccessToken();

    if (token == null) {
      throw ApiException('Authentication required');
    }

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/users/upload-profile-picture'),
      );

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Get file extension
      final fileExtension = path.extension(fileName).toLowerCase();

      // Set the content type based on file extension
      final contentType = fileExtension == '.png'
          ? 'image/png'
          : fileExtension == '.jpg' || fileExtension == '.jpeg'
          ? 'image/jpeg'
          : 'application/octet-stream';

      // Add the file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'profilePicture', // Make sure this matches your API's expected field name
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['profilePicture'] ?? '';  // Adjust based on your API response
      } else if (response.statusCode == 404 && response.body.contains('User not found')) {
        throw ApiException('User not found. Please check your authentication.');
      } else {
        throw ApiException('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Upload failed: ${e.toString()}');
    }
  }
}