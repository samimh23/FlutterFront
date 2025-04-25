import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../entities/order.dart';

class FindOrderByShopId {
  final OrderRepository repository;

  FindOrderByShopId(this.repository);

  Future<List<Order>> call(String shopId) async {
    return await repository.findOrdersByShopId(shopId);
  }
}