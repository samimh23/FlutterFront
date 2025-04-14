import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_user_id.dart';
import 'package:hanouty/Presentation/order/domain/usecases/send_package.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/FindOrderByShopId.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/create_order.dart';

class OrderProvider extends ChangeNotifier {
  final CreateOrder createOrderUseCase;
  final ConfirmOrder confirmOrderUseCase;
  final CancelOrder cancelOrderUseCase;
  final FindOrderByUserId findOrderByUserIdUseCase;
  final FindOrderByShopId findOrderByShopIdUseCase;
  final SendPackage sendPackageUseCase; // Add this field

  // Add this field

  OrderProvider({
    required this.createOrderUseCase,
    required this.confirmOrderUseCase,
    required this.cancelOrderUseCase,
    required this.findOrderByUserIdUseCase,
    required this.findOrderByShopIdUseCase,
    required this.sendPackageUseCase, // Add this parameter
  });

  List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  /// Optional fields if you need them.
  Order? _selectedOrder;
  List<Order> _userOrders = [];
  List<Order> _shopOrders = []; // Add shop orders list

  List<Order> get orders => _orders;
  List<Order> get userOrders => _userOrders;
  List<Order> get shopOrders => _shopOrders; // Add getter
  Order? get selectedOrder => _selectedOrder;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Create a new order.
  Future<void> createNewOrder(Order order) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final createdOrder = await createOrderUseCase.call(order);
      _orders.add(createdOrder);
      print('Order created successfully: ${createdOrder.id}');
    } catch (e) {
      _errorMessage = e.toString();
      // Optionally, you can notify the UI or show a snackbar via your widget.
    }

    _setLoading(false);
  }

  /// Confirm an order by ID.
  Future<void> confirmOrder(String orderId) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final confirmedOrder = await confirmOrderUseCase.call(orderId);
      _updateOrderInList(confirmedOrder);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  /// Cancel an order by ID.
  Future<void> cancelOrder(String orderId) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final canceledOrder = await cancelOrderUseCase.execute(orderId);
      _updateOrderInList(canceledOrder);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  /// Find orders by user ID (optional).
  Future<List<Order>> findOrdersByUserId(String userId) async {
    if (_isLoading) return _userOrders;
    _setLoading(true);

    try {
      final orders = await findOrderByUserIdUseCase.call(userId);
      _userOrders = orders;
      return _userOrders;
    } catch (e) {
      _errorMessage = e.toString();
      _userOrders = [];
      return _userOrders;
    } finally {
      _setLoading(false);
    }
  }

  /// Find orders by shop ID
  Future<List<Order>> findOrdersByShopId(String shopId) async {
    if (_isLoading) return _shopOrders;
    _setLoading(true);

    try {
      print('Fetching orders for shop ID: $shopId');
      final orders = await findOrderByShopIdUseCase.call(shopId);
      _shopOrders = orders;
      print('Found ${orders.length} orders for shop ID: $shopId');
      return _shopOrders;
    } catch (e) {
      _errorMessage = 'Failed to fetch shop orders: ${e.toString()}';
      print('Error fetching shop orders: $_errorMessage');
      _shopOrders = [];
      return _shopOrders;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear the current error message.
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Helper method to update an order in the list
  void _updateOrderInList(Order updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }

    // Also update in shop orders list if present
    final shopIndex = _shopOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (shopIndex != -1) {
      _shopOrders[shopIndex] = updatedOrder;
    }

    // Also update in user orders list if present
    final userIndex = _userOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (userIndex != -1) {
      _userOrders[userIndex] = updatedOrder;
    }
  }

  // Helper to set loading and clear error if starting a new operation
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = '';
    notifyListeners();
  }

  /// Mark an order as pending by ID.
  Future<void> markOrderAsPending(String orderId) async {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex].isConfirmed = false; // Assuming isConfirmed is used to check if an order is pending
      notifyListeners();
    }
  }
  Future<void> sendPackage(String orderId) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final updatedOrder = await sendPackageUseCase.call(orderId);
      _updateOrderInList(updatedOrder);

      // Update _selectedOrder if it's the same order
      if (_selectedOrder != null && _selectedOrder!.id == orderId) {
        _selectedOrder = updatedOrder;
      }

      // Also update in user orders list if present
      _updateOrderInUserOrdersList(updatedOrder);

    } catch (e) {
      _errorMessage = e.toString();
      print('Error sending package: $e');
    }

    _setLoading(false);
  }
  void _updateOrderInUserOrdersList(Order updatedOrder) {
    final index = _userOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _userOrders[index] = updatedOrder;
    }
  }
}