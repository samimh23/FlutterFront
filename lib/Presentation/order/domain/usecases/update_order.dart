
import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../entities/order.dart';

class UpdateOrder {
  final OrderRepository repository;

  UpdateOrder(this.repository);

  Future<Order> execute(String id, Order order) async {
    return await repository.updateOrder(id, order);
  }
}
