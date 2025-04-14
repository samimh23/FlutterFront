import 'package:hanouty/Presentation/order/domain/repositories/order_repositories.dart';

import '../../domain/entities/order.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Order> createOrder(Order order) async {
    final orderModel = OrderModel(
      id: order.id,
      normalMarket: order.normalMarket,
      products: order.products,
      user: order.user,
      orderStatus: order.orderStatus,
      dateOrder: order.dateOrder,
      isConfirmed: order.isConfirmed,
      totalPrice: order.totalPrice
    );
    return await remoteDataSource.createOrder(orderModel);
  }

  @override
  Future<Order> confirmOrder(String id) async {
    return await remoteDataSource.confirmOrder(id);
  }

  @override
  Future<Order> cancelOrder(String id) async {
    return await remoteDataSource.cancelOrder(id);
  }

  @override
  Future<Order> updateOrder(String id, Order order) async {
    final orderModel = OrderModel(
      id: order.id,
      normalMarket: order.normalMarket,
      products: order.products,
      user: order.user,
      orderStatus: order.orderStatus,
      dateOrder: order.dateOrder,
      isConfirmed: order.isConfirmed,
      totalPrice: order.totalPrice
    );
    return await remoteDataSource.updateOrder(id, orderModel);
  }

  @override
  Future<List<Order>> findOrdersByShopId(String idShopId) {
    // TODO: implement findOrdersByShopId
    throw UnimplementedError();
  }

  @override
  Future<List<Order>> findOrdersByUserId(String idUser) async {
    return await remoteDataSource.findOrdersByUserId(idUser);
  }
  
  @override
  Future<Order> findOrderById(String id) async{
return await remoteDataSource.findOrderById(id);
  }

  @override
  Future<Order> sendPackage(String id) async {
    return await remoteDataSource.sendPackage(id);
  }
}