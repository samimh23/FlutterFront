import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:hanouty/Presentation/order/presentation/pages/order_traking.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/app_colors.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> userOrders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });
    
    final secureStorageService = SecureStorageService();
    String? userId = await secureStorageService.getUserId();
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final orders = await orderProvider.findOrdersByUserId(userId);
    
    setState(() {
      userOrders = orders;
      isLoading = false;
    });
  }

  String _formatOrderDate(DateTime dateOrder) {
    return '${dateOrder.day}/${dateOrder.month}/${dateOrder.year}';
  }
  
  void _trackOrder(String orderId) {
  // Navigate to the order tracking screen
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => OrderTrackingScreen(orderId: orderId),
    ),
  );
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        elevation: 0,
        backgroundColor: AppColors.grey,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userOrders.isEmpty
              ? _buildEmptyOrdersView()
              : _buildOrdersList(),
    );
  }

  Widget _buildEmptyOrdersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No order history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Your orders will appear here once you make a purchase',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: userOrders.length,
      itemBuilder: (context, index) {
        final order = userOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ExpansionTile(
                leading: Icon(
                  order.isConfirmed! ? Icons.check_circle : Icons.pending,
                  color: order.isConfirmed! ? Colors.green : Colors.orange,
                ),
                title: Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Ordered on ${_formatOrderDate(order.dateOrder)}\n'
                  'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                ),
                children: [
                  ...order.products.map((product) => ListTile(
                    title: Text(product.name),
                  )).toList(),
                ],
              ),
              
              // Track and Confirm buttons at the bottom of each card
              if (!order.isConfirmed!)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Track Order button - only visible for pending orders
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.location_on_outlined),
                          label: const Text('Track Order'),
                          onPressed: () => _trackOrder(order.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Confirm Order button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await Provider.of<OrderProvider>(context, listen: false)
                                .confirmOrder(order.id);
                            await _loadOrders(); // Refresh the order list after confirmation
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order confirmed successfully')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Confirm Order'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}