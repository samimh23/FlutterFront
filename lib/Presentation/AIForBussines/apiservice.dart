import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Helper method to build URI with optional market_id parameter
  Uri _buildUri(String endpoint, String? marketId) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (marketId != null) {
      return uri.replace(queryParameters: {'market_id': marketId});
    }
    return uri;
  }

  // Get available markets
  Future<List<String>> fetchAvailableMarkets() async {
    final response = await http.get(Uri.parse('$baseUrl/api/available_markets'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['available_markets'] ?? []);
    } else {
      throw Exception('Failed to load available markets: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchStats({String? marketId}) async {
    final uri = _buildUri('/api/stats', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchCategories({String? marketId}) async {
    final uri = _buildUri('/api/categories', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchLocations({String? marketId}) async {
    final uri = _buildUri('/api/locations', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load locations: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchTimeAnalysis({String? marketId}) async {
    final uri = _buildUri('/api/time_analysis', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load time analysis: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchDemographics({String? marketId}) async {
    final uri = _buildUri('/api/demographics', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load demographics: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchCategorySalesChart({String? marketId}) async {
    final uri = _buildUri('/api/charts/category_sales', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load category sales chart data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchLocationSalesChart({String? marketId}) async {
    final uri = _buildUri('/api/charts/location_sales', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load location sales chart data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchGenderDistributionChart({String? marketId}) async {
    final uri = _buildUri('/api/charts/gender_distribution', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load gender distribution chart data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchSeasonalSalesChart({String? marketId}) async {
    final uri = _buildUri('/api/charts/seasonal_sales', marketId);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load seasonal sales chart data: ${response.statusCode}');
    }
  }
}