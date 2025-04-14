import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel orderModel);
  Future<OrderModel> confirmOrder(String id);
  Future<OrderModel> cancelOrder(String id);
  Future<OrderModel> updateOrder(String id, OrderModel orderModel);
  Future<List<OrderModel>> findOrdersByUserId(String idUser);
  Future<List<OrderModel>> findOrdersByShopId(String idShopId);
  Future<OrderModel> sendPackage(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final http.Client client;

  OrderRemoteDataSourceImpl({required this.client});

  final String baseUrl = 'http://127.0.0.1:3000/order';

  @override
  Future<OrderModel> createOrder(OrderModel orderModel) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(orderModel.toJson()),
    );
    print('Create order response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print(jsonEncode(orderModel.toJson()));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create order: ${response.statusCode}');
    }
  }

  @override
  Future<OrderModel> confirmOrder(String id) async {
    final response = await client.patch(Uri.parse('$baseUrl/confirm/$id'));
    if (response.statusCode == 200) {
      return OrderModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to confirm order');
    }
  }

  @override
  Future<OrderModel> cancelOrder(String id) async {
    final response = await client.patch(Uri.parse('$baseUrl/cancel/$id'));
    if (response.statusCode == 200) {
      return OrderModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to cancel order');
    }
  }

  @override
  Future<OrderModel> updateOrder(String id, OrderModel orderModel) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/update/$id'),
      body: orderModel.toJson(),
    );
    if (response.statusCode == 200) {
      return OrderModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update order');
    }
  }

  @override
  Future<List<OrderModel>> findOrdersByShopId(String shopId) async {
    try {
      print('Fetching orders for shop ID: $shopId');

      final Uri url = Uri.parse('$baseUrl/shop/$shopId');
      print('Request URL: $url');

      final response = await client.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print('Find orders by shop ID response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Try to decode the response body
          final dynamic decodedBody = json.decode(response.body);

          print('Decoded body type: ${decodedBody.runtimeType}');

          List<OrderModel> orders = [];

          // Handle the different possible response structures
          if (decodedBody is List) {
            // Response is already a list of orders
            print('Response is a List with ${decodedBody.length} items');
            orders = decodedBody.map<OrderModel>((json) => OrderModel.fromJson(json)).toList();
          } else if (decodedBody is Map<String, dynamic>) {
            // Response is an object that may contain an orders array
            print('Response is a Map with keys: ${decodedBody.keys.toList()}');
            if (decodedBody.containsKey('orders') && decodedBody['orders'] is List) {
              final List<dynamic> ordersJson = decodedBody['orders'];
              print('Found orders array with ${ordersJson.length} items');
              orders = ordersJson.map<OrderModel>((json) => OrderModel.fromJson(json)).toList();
            } else if (decodedBody.containsKey('_id')) {
              // This might be a single order object
              print('Response appears to be a single order object');
              orders = [OrderModel.fromJson(decodedBody)];
            }
          }

          print('Found ${orders.length} orders for shop ID: $shopId');
          return orders;
        } catch (parseError) {
          print('Error parsing response for shop $shopId: $parseError');
          print('Response that failed to parse: ${response.body}');
          return [];
        }
      } else {
        print('Failed response for shop $shopId: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch orders for shop. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders by shop ID $shopId: $e');
      throw Exception('Failed to fetch orders for shop: $e');
    }
  }

  @override
  Future<List<OrderModel>> findOrdersByUserId(String idUser) async {
    final response = await client.get(Uri.parse('$baseUrl/$idUser'));
    if (response.statusCode == 200) {
      List<dynamic> ordersJson = json.decode(response.body);
      return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch orders for user');
    }
  }
  @override
  Future<OrderModel> sendPackage(String id) async {
    final response = await client.patch(Uri.parse('$baseUrl/updateStatus/$id'));
    if (response.statusCode == 200) {
      return OrderModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send package');
    }
  }
}