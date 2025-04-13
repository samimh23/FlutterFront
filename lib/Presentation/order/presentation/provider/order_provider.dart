import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_id.dart';
import 'package:hanouty/Presentation/order/domain/usecases/find_order_by_user_id.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/create_order.dart';

class OrderProvider extends ChangeNotifier {
  final CreateOrder createOrderUseCase;
  final ConfirmOrder confirmOrderUseCase;
  final CancelOrder cancelOrderUseCase;
  final FindOrderById findOrderByIdUseCase;
  final FindOrderByUserId findOrderByUserIdUseCase;

  OrderProvider({
    required this.createOrderUseCase,
    required this.confirmOrderUseCase,
    required this.findOrderByIdUseCase,
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
      final createdOrder = await createOrderUseCase.call(order);
      _orders.add(createdOrder);
      print('Order created successfully: ${createdOrder.id}');
    } catch (e) {
      _errorMessage = e.toString();
      // Optionally, you can notify the UI or show a snackbar via your widget.
    }

    _setLoading(false);
  }

  /// Get an order by ID.
  Future<Order?> getOrderById(String id) async {
    if (_isLoading) return null;
    _setLoading(true);
    
    try {
      // Use findOrderByIdUseCase to get the order
      final order = await findOrderByIdUseCase.call(id);
      _selectedOrder = order;
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching order by ID: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Confirm an order by ID.
  Future<void> confirmOrder(String orderId) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final confirmedOrder = await confirmOrderUseCase.call(orderId);
      _updateOrderInList(confirmedOrder);
      
      // Update _selectedOrder if it's the same order
      if (_selectedOrder != null && _selectedOrder!.id == orderId) {
        _selectedOrder = confirmedOrder;
      }
      
      // Also update in user orders list if present
      _updateOrderInUserOrdersList(confirmedOrder);
      
    } catch (e) {
      _errorMessage = e.toString();
      print('Error confirming order: $e');
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
      
      // Update _selectedOrder if it's the same order
      if (_selectedOrder != null && _selectedOrder!.id == orderId) {
        _selectedOrder = canceledOrder;
      }
      
      // Also update in user orders list if present
      _updateOrderInUserOrdersList(canceledOrder);
      
    } catch (e) {
      _errorMessage = e.toString();
      print('Error canceling order: $e');
    }

    _setLoading(false);
  }

  /// Find orders by user ID.
  Future<List<Order>> findOrdersByUserId(String userId) async {
    if (_isLoading) return _userOrders;
    _setLoading(true);

    try {
      final orders = await findOrderByUserIdUseCase.call(userId);
      _userOrders = orders;
      return _userOrders;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error finding orders by user ID: $e');
      _userOrders = [];
      return _userOrders;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if an order is in delivery state
  bool isOrderInDelivery(String orderId) {
    final order = _findOrderInLists(orderId);
    return order != null && order.orderStatus == OrderStatus.Delivering;
  }

  /// Check if an order is received
  bool isOrderReceived(String orderId) {
    final order = _findOrderInLists(orderId);
    return order != null && order.orderStatus == OrderStatus.isReceived;
  }

  /// Get the current status of an order as a string
  String getOrderStatusString(String orderId) {
    final order = _findOrderInLists(orderId);
    if (order == null) return "unknown";
    
    switch (order.orderStatus) {
      case OrderStatus.isReceived:
        return "received";
      case OrderStatus.isProcessing:
        return "processing";
      case OrderStatus.Delivering:
        return "delivering";
      default:
        return "pending";
    }
  }

  // Helper method to find an order in any of our lists
  Order? _findOrderInLists(String orderId) {
    // Check selected order first
    if (_selectedOrder != null && _selectedOrder!.id == orderId) {
      return _selectedOrder;
    }
    
    // Check in main orders list
    final mainOrderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (mainOrderIndex != -1) return _orders[mainOrderIndex];
    
    // Check in user orders list
    final userOrderIndex = _userOrders.indexWhere((o) => o.id == orderId);
    if (userOrderIndex != -1) return _userOrders[userOrderIndex];
    
    return null;
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
  
  // Helper method to update an order in the user orders list
  void _updateOrderInUserOrdersList(Order updatedOrder) {
    final index = _userOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _userOrders[index] = updatedOrder;
    }
  }

  // Helper to set loading and clear error if starting a new operation
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = '';
    notifyListeners();
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    // This would need a corresponding use case
    // For now, we'll just update the local state
    final order = _findOrderInLists(orderId);
    if (order != null) {
      order.orderStatus = status;
      notifyListeners();
    }
  }
}