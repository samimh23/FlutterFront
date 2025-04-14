
import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../entities/order.dart';

class SendPackage {
  final OrderRepository repository;

  SendPackage(this.repository);

  Future<Order> call(String id) async {
    return await repository.sendPackage(id);
  }
}
