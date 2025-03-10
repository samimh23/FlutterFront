//Data_Layer/datasources/farm_crop_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Domain_Layer/entities/farm_crop.dart';

class FarmCropRemoteDataSource {
  final String baseUrl = 'http://localhost:3000/farm-crops'; 
  final http.Client client;

  FarmCropRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  Future<List<FarmCrop>> getAllCrops() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> cropList = json.decode(response.body);
        return cropList.map((json) => FarmCrop.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch crops. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch crops: $e');
    }
  }

  Future<FarmCrop> getCropById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final cropJson = json.decode(response.body);
        return FarmCrop.fromJson(cropJson);
      } else {
        throw Exception('Failed to fetch crop. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch crop: $e');
    }
  }

  Future<void> addCrop(FarmCrop crop) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(crop.toJson()),
      );
      print("Request Payload: ${json.encode(crop.toJson())}");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add crop. Status: ${response.statusCode}, Response: ${response.body}'
        );      }
    } catch (e) {
      print("Exception in addCrop: $e");
      throw Exception('Failed to add crop: $e');
    }
  }

  Future<void> updateCrop(FarmCrop crop) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/${crop.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(crop.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update crop. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update crop: $e');
    }
  }

  Future<void> deleteCrop(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete crop. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete crop: $e');
    }
  }

  void dispose() {
    client.close();
  }
}