import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../../Core/Utils/Api_EndPoints.dart';
import '../../Core/Utils/secure_storage.dart';
import 'market.dart';

class MarketService {
  final String baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  MarketService({this.baseUrl = '${ApiEndpoints.baseUrl}'}); // Replace with your actual IP




  // Get token from secure storage instead of hardcoding
  Future<String?> _getToken() async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        developer.log('Retrieved auth token from secure storage (first 10 chars): ${token.substring(0, 10)}...');
        return token;
      } else {
        developer.log('No auth token found in secure storage');
        return null;
      }
    } catch (e) {
      developer.log('Error retrieving token: $e');
      return null;
    }
  }

  // Get markets owned by authenticated user
  Future<List<Market>> getMyMarkets() async {
    developer.log('Getting user markets from: ${baseUrl}/normal/my-markets');

    final token = await _getToken();
    if (token == null) {
      developer.log('No authentication token found, using demo markets');
      return createDemoMarkets();
    }

    try {
      final url = Uri.parse('${baseUrl}/normal/my-markets');
      developer.log('Requesting markets from: $url');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      developer.log('Sending request with headers: $headers');

      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      developer.log('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          developer.log('Successfully decoded JSON with ${data.length} markets');

          if (data.isEmpty) {
            developer.log('No markets returned from API');
            return createDemoMarkets();
          }

          final markets = <Market>[];
          for (var item in data) {
            try {
              final market = Market.fromJson(item);
              markets.add(market);
              developer.log('Parsed market: ${market.name}');
            } catch (e) {
              developer.log('Error parsing market: $e');
            }
          }

          return markets;
        } catch (e) {
          developer.log('JSON parsing error: $e');
          return createDemoMarkets();
        }
      } else if (response.statusCode == 401) {
        // Token might be expired
        developer.log('Authentication failed (401). Token may be expired.');
        return createDemoMarkets();
      } else {
        developer.log('API returned error status ${response.statusCode}');
        return createDemoMarkets();
      }
    } catch (e) {
      developer.log('Network request error: $e');
      return createDemoMarkets();
    }
  }

  // Create some demo markets for testing and fallback
  List<Market> createDemoMarkets() {
    developer.log('Creating demo markets');
    return [
      Market(
          id: '1',
          name: 'Demo Market 1',
          marketLocation: 'New York',
          owner: 'samimh23'
      ),
      Market(
          id: '2',
          name: 'Demo Market 2',
          marketLocation: 'San Francisco',
          owner: 'samimh23'
      ),
      Market(
          id: '3',
          name: 'Demo Market 3',
          marketLocation: 'Chicago',
          owner: 'samimh23'
      ),
    ];
  }

  // Get specific market by ID
  Future<Market> getMarketById(String id) async {
    developer.log('Getting market by id: $id');
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/normal/$id'),
        headers: {
          'Authorization': token != null ? 'Bearer $token' : '',
          'Content-Type': 'application/json',
        },
      );

      developer.log('Market by ID response: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          return Market.fromJson(json.decode(response.body));
        } catch (e) {
          developer.log('Error parsing market: $e', error: e);
          throw Exception('Failed to parse market data: $e');
        }
      } else {
        developer.log('Error response: ${response.body}');
        throw Exception('Failed to load market: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Network error: $e', error: e);
      throw Exception('Network error: $e');
    }
  }
}