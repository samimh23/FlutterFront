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
    body: jsonEncode(orderModel.toJson()), // encode the map into a JSON string
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
  Future<List<OrderModel>> findOrdersByShopId(String idShopId) {
    // TODO: implement findOrdersByShopId
    throw UnimplementedError();
  }
  
  @override
  Future<List<OrderModel>> findOrdersByUserId(String idUser) {
    // TODO: implement findOrdersByUserId
    throw UnimplementedError();
  }
}
