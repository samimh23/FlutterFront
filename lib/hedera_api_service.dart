import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Core/Utils/secure_storage.dart';

class HederaApiService {
  // Update this with your actual NestJS backend URL
  final String baseUrl = ApiEndpoints.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    // Get JWT token from secure storage instead of separate service
    final token = await _secureStorage.getAccessToken();

    if (token == null) {
      throw Exception('No authentication token found. Please login again.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getBalance() async {
    try {
      // // current date and time for logging
      final now = DateTime.now().toUtc();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      //('Current Date and Time (UTC): $formattedDate');

      // Get auth headers
      final headers = await _getAuthHeaders();
      //('Attempting to fetch balance from backend...');

      // Make the request to your NestJS backend
      final response = await http.get(
        Uri.parse('$baseUrl/hedera/balance'),
        headers: headers,
      ).timeout(Duration(seconds: 30));

      //('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        //('Balance retrieved successfully');
        return result;
      } else {
        //('Error response: ${response.body}');
        throw Exception('Failed to load balance: ${response.statusCode}');
      }
    } catch (e) {
      //('Error fetching balance: $e');

      // More specific error handling
      if (e is http.ClientException) {
        //('Network error: ${e.message}');
      } else if (e is FormatException) {
        //('Error parsing response data');
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBalancebyMarket(String marketId) async {
    try {
      final headers = await _getAuthHeaders();

      final uri = Uri.parse('$baseUrl/hedera/balance/bymarket')
          .replace(queryParameters: {'marketid': marketId});

      //('Requesting balance for market ID: $marketId at ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(Duration(seconds: 30));

      //('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Check if response body is not empty before parsing
        if (response.body.isNotEmpty) {
          try {
            final result = jsonDecode(response.body);
            //('Balance retrieved successfully');
            return result;
          } catch (parseError) {
            //('Error parsing JSON response: $parseError');
            //('Response body length: ${response.body.length}');
            if (response.body.length < 100) {
              //('Raw response: ${response.body}');
            }
            // Return empty map instead of throwing error
            return {};
          }
        } else {
          //('Response body is empty');
          return {};
        }
      } else {
        //('Error status: ${response.statusCode}, response: ${response.body}');
        return {}; // Return empty map instead of throwing
      }
    } catch (e) {
      //('Error fetching balance: $e');
      // Return empty map instead of rethrowing for better resilience
      return {};
    }
  }


  Future<Map<String, dynamic>> transferTokens({
    required String receiverAccountId,
    required String amount,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      //('Initiating token transfer of $amount to $receiverAccountId');

      final response = await http.post(
        Uri.parse('$baseUrl/hedera/transfer'),
        headers: headers,
        body: jsonEncode({
          'receiverAccountId': receiverAccountId,
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 30));

      //('Transfer response status: ${response.statusCode}');

      // Accept any 2xx status code as success (200, 201, 204, etc.)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body);
        //('Transfer completed successfully');
        return result is Map<String, dynamic>
            ? result
            : {'message': 'Transfer successful', 'data': result};
      } else {
        //('Transfer error response: ${response.body}');
        throw Exception('Transfer failed: ${response.statusCode}');
      }
    } catch (e) {
      //('Error transferring tokens: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> traceTransactions({String? accountId}) async {
    try {
      final headers = await _getAuthHeaders();

      //('Attempting to trace Hedera transactions...');

      // Use either the provided accountId or just use the user's own transactions
      final Uri uri = Uri.parse('$baseUrl/hedera/trace');

      // Build request based on whether accountId was provided
      final response = accountId != null
          ? await http.post(
        uri,
        headers: headers,
        body: jsonEncode({'accountId': accountId}),
      ).timeout(Duration(seconds: 30))
          : await http.get(
        Uri.parse('$baseUrl/hedera/trace/my-transactions'),
        headers: headers,
      ).timeout(Duration(seconds: 30));

      //('Trace response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body);
        //('Transaction trace retrieved successfully');
        return result;
      } else {
        //('Trace error response: ${response.body}');
        throw Exception('Failed to retrieve transaction history: ${response.statusCode}');
      }
    } catch (e) {
      //('Error tracing transactions: $e');

      // More specific error handling like in your getBalance method
      if (e is http.ClientException) {
        //('Network error: ${e.message}');
      } else if (e is FormatException) {
        //('Error parsing trace response data');
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> lockTokens({
    required String amount,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      //('Initiating token lock of $amount');

      final response = await http.post(
        Uri.parse('$baseUrl/hedera/lock'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 30));

      //('Lock response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        //('Lock completed successfully');
        return result;
      } else {
        //('Lock error response: ${response.body}');
        throw Exception('Lock failed: ${response.statusCode}');
      }
    } catch (e) {
      //('Error locking tokens: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> unlockTokens({
    required String amount,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      //('Initiating token unlock of $amount');

      final response = await http.post(
        Uri.parse('$baseUrl/hedera/unlock'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 30));

      //('Unlock response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        //('Unlock completed successfully');
        return result;
      } else {
        //('Unlock error response: ${response.body}');
        throw Exception('Unlock failed: ${response.statusCode}');
      }
    } catch (e) {
      //('Error unlocking tokens: $e');
      rethrow;
    }
  }
  Future<Map<String, dynamic>> getTokenOwnership(String tokenId) async {
    try {
      print('[getTokenOwnership] Called with tokenId: $tokenId');

      final headers = await _getAuthHeaders();
      print('[getTokenOwnership] Got headers: $headers');

      final uri = Uri.parse('$baseUrl/hedera/check-all')
          .replace(queryParameters: {'tokenId': tokenId});
      print('[getTokenOwnership] Built URI: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(Duration(seconds: 30));

      print('[getTokenOwnership] HTTP status: ${response.statusCode}');
      print('[getTokenOwnership] HTTP body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          print('[getTokenOwnership] Decoded response: $decoded');
          return decoded;
        } else {
          print('[getTokenOwnership] Empty response body.');
          return {};
        }
      } else {
        print('[getTokenOwnership] Non-200 status code: ${response.statusCode}');
        throw Exception(
            'Failed to fetch token ownership: ${response.statusCode}');
      }
    } catch (e, stack) {
      print('[getTokenOwnership] Error fetching token ownership: $e');
      print('[getTokenOwnership] Stacktrace: $stack');
      rethrow;
    }
  }
}