import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order> createOrder(Order order);
  Future<Order> findOrderById(String id);
  Future<Order> confirmOrder(String id);
  Future<Order> cancelOrder(String id);
  Future<Order> updateOrder(String id, Order order);
  Future<List<Order>> findOrdersByUserId(String idUser);
  Future<List<Order>> findOrdersByShopId(String idShopId);
  Future<Order> sendPackage(String id);

}
