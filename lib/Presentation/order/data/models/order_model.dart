import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import '../../domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.normalMarket,
    required super.products,
    required super.user,
    required super.orderStatus,
    required super.dateOrder,
    required super.isConfirmed,
    required super.totalPrice
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] as String,
      normalMarket: json['normalMarket'] as String? ?? '',
      products: (json['products'] as List<dynamic>)
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      user: json['user'] as String? ?? '',
      orderStatus: _parseOrderStatus(json['orderStatus']),
      dateOrder: DateTime.parse(json['dateOrder'] as String),
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      totalPrice: json['totalPrice'] as int
    );
  }

  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status is int && status >= 0 && status < OrderStatus.values.length) {
      return OrderStatus.values[status];
    } else if (status is String) {
      return orderStatusFromString(status);
    }
    return OrderStatus.isReceived; // Default value
  }

  static OrderStatus orderStatusFromString(String value) =>
    OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.isProcessing, 
    );

  static String orderStatusToString(OrderStatus status) =>
    status.toString().split('.').last;

  Map<String, dynamic> toJson() {
    return {
      'normalMarket': normalMarket,
      'products': products.map((p) => {
            'productId': p.id,
            'stock': p.stock,
          }).toList(),
      'user': user,
      'orderStatus': orderStatusToString(orderStatus!), // Convert enum to string
      'dateOrder': dateOrder.toIso8601String(),
      'isConfirmed': isConfirmed,
      'totalPrice': totalPrice,
    };
  }
}