import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Domain_Layer/entities/sale.dart';

class SaleRemoteDataSource {
  final String apiUrl = 'http://192.168.100.12:3000/farm-sales';

  // Mock data for development (remove in production)
  final List<Sale> _mockSales = [];

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Error handling helpers
  Exception _handleErrorResponse(http.Response response) {
    try {
      final errorBody = json.decode(response.body);
      return Exception(errorBody['message'] ?? 'Server error: ${response.statusCode}');
    } catch (e) {
      return Exception('Server error: ${response.statusCode}');
    }
  }

  Exception _handleException(String message, dynamic error) {
    print('API Error: $message - $error');
    if (error is Exception) {
      return error;
    }
    return Exception('$message: ${error.toString()}');
  }

  Future<List<Sale>> getAllSales() async {
    try {
      final Uri uri = Uri.parse(apiUrl);

      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> salesJson = json.decode(response.body);
        print('Received sales JSON: $salesJson');
        return salesJson.map((json) {
          try {
            return Sale.fromJson(json);
          } catch (e) {
            print('Error parsing sale: $json');
            print('Error details: $e');
            // Handle the error or skip this item
            throw e; // Re-throw to be handled by the outer catch
          }
        }).toList();
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw _handleException('Failed to load sales', e);
    }
  }

  // Get sale by ID
  Future<Sale> getSaleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Sale.fromJson(json.decode(response.body));
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw _handleException('Failed to load sale with ID: $id', e);
    }
  }

  Future<Sale> addSale(Sale sale) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: _headers,
        body: json.encode(sale.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return Sale.fromJson(json.decode(response.body));
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw _handleException('Failed to create sale', e);
    }
  }

  Future<void> updateSale(Sale sale) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${sale.id}'),
        headers: _headers,
        body: json.encode(sale.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw _handleException('Failed to update sale', e);
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw _handleException('Failed to delete sale', e);
    }
  }

  Future<List<Sale>> getSalesByCropId(String cropId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?farmCropId=$cropId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> salesJson = json.decode(response.body);
        return salesJson.map((json) => Sale.fromJson(json)).toList();
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw _handleException('Failed to load sales for crop ID: $cropId', e);
    }
  }


  Future<List<Sale>> getSalesByFarmMarket(String farmMarketId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/sales/farm/$farmMarketId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
        },
      );

      if (response.statusCode == 200) {
        final jsonList = json.decode(response.body) as List;
        return jsonList.map((json) => Sale.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load sales: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
         'Error fetching sales: ${e.toString()}',
      );
    }
  }


}