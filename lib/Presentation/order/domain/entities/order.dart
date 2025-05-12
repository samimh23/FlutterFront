import 'package:equatable/equatable.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';

enum OrderStatus {
  isReceived,
  isProcessing,
  Delivering,
}

class Order extends Equatable {
  final String id;
  final String normalMarket;
  final List<ProductModel> products;
  final String user;
  OrderStatus? orderStatus;
  final DateTime dateOrder;
  bool? isConfirmed;
  final int totalPrice;

  Order(
      {required this.id,
      required this.normalMarket,
      required this.products,
      required this.user,
      required this.orderStatus,
      required this.dateOrder,
      required this.isConfirmed,
      required this.totalPrice});

  @override
  List<Object?> get props => [
        id,
        normalMarket,
        products,
        user,
        dateOrder,
        orderStatus,
        isConfirmed,
        totalPrice
      ];
}
