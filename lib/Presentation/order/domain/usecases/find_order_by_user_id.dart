import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../entities/order.dart';

class FindOrderByUserId {
  final OrderRepository repository;

  FindOrderByUserId(this.repository);

  Future<List<Order>> execute(String idUser) async {
    return await repository.findOrdersByUserId(idUser);
  }
}
