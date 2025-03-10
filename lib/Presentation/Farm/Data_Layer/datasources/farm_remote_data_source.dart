import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Domain_Layer/entity/farm.dart';

class FarmMarketRemoteDataSource {
  final String baseUrl = 'http://localhost:3000/farm';
  final http.Client client;

  FarmMarketRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  Future<List<Farm>> getAllFarmMarkets() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> farmMarketList = json.decode(response.body);
        return farmMarketList.map((json) => Farm.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch farm markets. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch farm markets: $e');
    }
  }

  Future<Farm> getFarmMarketById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final farmMarketJson = json.decode(response.body);
        return Farm.fromJson(farmMarketJson);
      } else {
        throw Exception('Failed to fetch farm market. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch farm market: $e');
    }
  }

  Future<void> addFarmMarket(Farm farmMarket) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(farmMarket.toJson()),
      );
      print("Request Payload: ${json.encode(farmMarket.toJson())}");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            'Failed to add farm market. Status: ${response.statusCode}, Response: ${response.body}'
        );
      }
    } catch (e) {
      print("Exception in addFarmMarket: $e");
      throw Exception('Failed to add farm market: $e');
    }
  }

  Future<void> updateFarmMarket(Farm farmMarket) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/${farmMarket.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(farmMarket.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update farm market. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update farm market: $e');
    }
  }

  Future<void> deleteFarmMarket(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete farm market. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete farm market: $e');
    }
  }


  void dispose() {
    client.close();
  }
}