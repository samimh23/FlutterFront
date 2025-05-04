import 'dart:convert';
import 'package:hanouty/Core/Utils/Api_EndPoints.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../Core/Utils/secure_storage.dart';
import '../../../../Core/api/api_exceptions.dart';

class SubscriptionService {
  final SecureStorageService _secureStorageService;
  final String _baseUrl;

  SubscriptionService({
    String? baseUrl,
    SecureStorageService? secureStorageService,
  }) :
        _baseUrl = ApiEndpoints.baseUrl,
        _secureStorageService = secureStorageService ?? SecureStorageService();

  String _getSubscriptionTypeString(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.farmer:
        return 'Farmer';
      case SubscriptionType.merchant:
        return 'Merchant';
      default:
        throw ApiException('Invalid subscription type');
    }
  }

  // For web
  Future<CheckoutSessionResponse> createCheckoutSession(SubscriptionType subscriptionType) async {
    final token = await _secureStorageService.getAccessToken();

    if (token == null) {
      throw ApiException('Authentication required');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/create-checkout-session'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subscriptionType': _getSubscriptionTypeString(subscriptionType),
        }),
      );

      print('Checkout Session API Response Code: ${response.statusCode}');
      print('Checkout Session API Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CheckoutSessionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw ApiException('Authentication failed');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to create checkout session: ${response.statusCode}');
      }
    } catch (e) {
      print('Create checkout session error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // For mobile
  Future<String?> createPaymentIntent(SubscriptionType subscriptionType) async {
    final token = await _secureStorageService.getAccessToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/create-intent'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subscriptionType': _getSubscriptionTypeString(subscriptionType),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['clientSecret'];
    }
    throw Exception('Failed to create PaymentIntent: ${response.body}');
  }

  Future<void> payWithCard(String clientSecret) async {
    await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: clientSecret,
      data: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );
  }
}

enum SubscriptionType {
  farmer,
  merchant,
}

class CheckoutSessionResponse {
  final String sessionId;
  final String? paymentIntentId;
  final String url;

  CheckoutSessionResponse({
    required this.sessionId,
    this.paymentIntentId,
    required this.url,
  });

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionResponse(
      sessionId: json['sessionId'],
      paymentIntentId: json['paymentIntentId'],
      url: json['url'],
    );
  }
}