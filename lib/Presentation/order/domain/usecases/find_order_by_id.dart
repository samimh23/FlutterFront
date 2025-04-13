import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../entities/order.dart';

class FindOrderById {
  final OrderRepository repository;

  FindOrderById(this.repository);

  Future<Order> call(String idUser) async {
    return await repository.findOrderById(idUser);
  }
}
