import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_user_id.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/create_order.dart';

class OrderProvider extends ChangeNotifier {
  final CreateOrder createOrderUseCase;
  final ConfirmOrder confirmOrderUseCase;
  final CancelOrder cancelOrderUseCase;
  final FindOrderByUserId findOrderByUserIdUseCase;

  OrderProvider({
    required this.createOrderUseCase,
    required this.confirmOrderUseCase,
    required this.cancelOrderUseCase,
    required this.findOrderByUserIdUseCase,
  });

  List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  /// Optional fields if you need them.
  Order? _selectedOrder;
  List<Order> _userOrders = [];

  List<Order> get orders => _orders;
  List<Order> get userOrders => _userOrders;
  Order? get selectedOrder => _selectedOrder;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  

  /// Create a new order.
  Future<void> createNewOrder(Order order) async {
  if (_isLoading) return;
  _setLoading(true);

  try {
    final createdOrder = await createOrderUseCase.execute(order);
    _orders.add(createdOrder);
    print('Order created successfully: ${createdOrder.id}');
  } catch (e) {
    _errorMessage = e.toString();
    print('Error creating order: $_errorMessage');
    // Optionally, you can notify the UI or show a snackbar via your widget.
  }

  _setLoading(false);
}


  /// Confirm an order by ID.
  Future<void> confirmOrder(String orderId) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final confirmedOrder = await confirmOrderUseCase.execute(orderId);
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
  Future<void> findOrdersByUserId(String userId) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final orders = await findOrderByUserIdUseCase.execute(userId);
      _userOrders = orders;
    } catch (e) {
      _errorMessage = e.toString();
      _userOrders = [];
    }

    _setLoading(false);
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
  }

  // Helper to set loading and clear error if starting a new operation
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = '';
    notifyListeners();
  }
}
