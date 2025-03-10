import 'package:hanouty/Presentation/product/data/models/product_model.dart';

import '../../domain/entities/order.dart';


class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.normalMarket,
    required super.products,
    required super.user,
    required super.dateOrder,
    required super.isConfirmed,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] as String,
      normalMarket: json['normalMarket'] as String? ?? '',
      products: (json['products'] as List<dynamic>)
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      user: json['user'] as String? ?? '',
      dateOrder: DateTime.parse(json['dateOrder'] as String),
      isConfirmed: json['isConfirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'normalMarket': normalMarket,
      // Map each product with its proper quantity.
      'products': products.map((p) => {
            'productId': p.id,
            // If your ProductModel has a quantity field, use it.
            // Otherwise, default to 1.
            'stock': (p.stock ?? 1),
          }).toList(),
      'user': user,
      'dateOrder': dateOrder.toIso8601String(),
      'isConfirmed': isConfirmed,
    };
  }
}
