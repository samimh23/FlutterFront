
import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../entities/order.dart';

class ConfirmOrder {
  final OrderRepository repository;

  ConfirmOrder(this.repository);

  Future<Order> execute(String id) async {
    return await repository.confirmOrder(id);
  }
}
