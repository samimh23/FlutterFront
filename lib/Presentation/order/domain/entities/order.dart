import 'package:equatable/equatable.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';

class Order extends Equatable{
  final String id;
  final String normalMarket;
  final List<ProductModel> products;
  final String user;
  final DateTime dateOrder;
  final bool isConfirmed;

  Order({
    required this.id,
    required this.normalMarket,
    required this.products,
    required this.user,
    required this.dateOrder,
    required this.isConfirmed,
    });
    
      @override
      List<Object?> get props => [id, normalMarket, products, user, dateOrder, isConfirmed];
}
