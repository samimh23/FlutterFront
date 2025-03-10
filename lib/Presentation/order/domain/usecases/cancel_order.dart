import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../entities/order.dart';

class CancelOrder {
  final OrderRepository repository;

  CancelOrder(this.repository);

  Future<Order> execute(String id) async {
    return await repository.cancelOrder(id);
  }
}
