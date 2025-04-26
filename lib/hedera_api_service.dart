import 'dart:convert';
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Core/Utils/secure_storage.dart';

class HederaApiService {
  // Update this with your actual NestJS backend URL
  final String baseUrl = 'http://192.168.251.19:3000';
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
      // Print current date and time for logging
      final now = DateTime.now().toUtc();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      print('Current Date and Time (UTC): $formattedDate');

      // Get auth headers
      final headers = await _getAuthHeaders();
      print('Attempting to fetch balance from backend...');

      // Make the request to your NestJS backend
      final response = await http.get(
        Uri.parse('$baseUrl/hedera/balance'),
        headers: headers,
      ).timeout(Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Balance retrieved successfully');
        return result;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load balance: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching balance: $e');

      // More specific error handling
      if (e is http.ClientException) {
        print('Network error: ${e.message}');
      } else if (e is FormatException) {
        print('Error parsing response data');
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> transferTokens({
    required String receiverAccountId,
    required String amount,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      print('Initiating token transfer of $amount to $receiverAccountId');

      final response = await http.post(
        Uri.parse('$baseUrl/hedera/transfer'),
        headers: headers,
        body: jsonEncode({
          'receiverAccountId': receiverAccountId,
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 30));

      print('Transfer response status: ${response.statusCode}');

      // Accept any 2xx status code as success (200, 201, 204, etc.)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body);
        print('Transfer completed successfully');
        return result is Map<String, dynamic>
            ? result
            : {'message': 'Transfer successful', 'data': result};
      } else {
        print('Transfer error response: ${response.body}');
        throw Exception('Transfer failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error transferring tokens: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> traceTransactions({String? accountId}) async {
    try {
      final headers = await _getAuthHeaders();

      print('Attempting to trace Hedera transactions...');

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

      print('Trace response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body);
        print('Transaction trace retrieved successfully');
        return result;
      } else {
        print('Trace error response: ${response.body}');
        throw Exception('Failed to retrieve transaction history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error tracing transactions: $e');

      // More specific error handling like in your getBalance method
      if (e is http.ClientException) {
        print('Network error: ${e.message}');
      } else if (e is FormatException) {
        print('Error parsing trace response data');
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> lockTokens({
    required String amount,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      print('Initiating token lock of $amount');

      final response = await http.post(
        Uri.parse('$baseUrl/hedera/lock'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 30));

      print('Lock response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Lock completed successfully');
        return result;
      } else {
        print('Lock error response: ${response.body}');
        throw Exception('Lock failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error locking tokens: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> unlockTokens({
    required String amount,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      print('Initiating token unlock of $amount');

      final response = await http.post(
        Uri.parse('$baseUrl/hedera/unlock'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 30));

      print('Unlock response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Unlock completed successfully');
        return result;
      } else {
        print('Unlock error response: ${response.body}');
        throw Exception('Unlock failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error unlocking tokens: $e');
      rethrow;
    }
  }
}