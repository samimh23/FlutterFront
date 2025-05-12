import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:hanouty/Presentation/order/presentation/pages/order_traking.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../Core/theme/AppColors.dart';

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
        SnackBar(
          content: const Text('User ID not found'),
          backgroundColor: ClientColors.accent, // Updated SnackBar color
        ),
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
      backgroundColor: ClientColors.background, // Updated background color
      appBar: AppBar(
        title: const Text('Order History'),
        elevation: 0,
        backgroundColor: ClientColors.primary, // Updated AppBar color
        foregroundColor: ClientColors.onPrimary, // Updated text color
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            color: ClientColors.onPrimary, // Updated icon color
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ClientColors.primary), // Updated loading indicator color
        ),
      )
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
            color: ClientColors.textLight, // Updated icon color
          ),
          const SizedBox(height: 20),
          Text(
            'No order history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ClientColors.text, // Updated text color
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Your orders will appear here once you make a purchase',
            style: TextStyle(fontSize: 16, color: ClientColors.textLight), // Updated text color
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // Return to shopping
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ClientColors.primary, // Updated button color
              foregroundColor: ClientColors.onPrimary, // Updated text color
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
            borderRadius: BorderRadius.circular(12), // Slightly more rounded corners
          ),
          elevation: 3, // Slightly increased elevation for more depth
          shadowColor: ClientColors.primary.withOpacity(0.1), // Updated shadow color
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ClientColors.primary.withOpacity(0.05), // Subtle header background
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ExpansionTile(
                  leading: Icon(
                    order.isConfirmed! ? Icons.check_circle : Icons.pending,
                    color: order.isConfirmed!
                        ? ClientColors.secondary // Updated confirmed color
                        : ClientColors.accent, // Updated pending color
                    size: 28, // Slightly larger icon
                  ),
                  title: Text(
                    'Order #${order.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ClientColors.text, // Updated text color
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ordered on ${_formatOrderDate(order.dateOrder)}',
                          style: TextStyle(
                            color: ClientColors.textLight, // Updated text color
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ClientColors.primary, // Updated price color
                          ),
                        ),
                      ],
                    ),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Order Items:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Divider(),
                    ...order.products.map((product) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: ClientColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                color: ClientColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    const Divider(),
                  ],
                ),
              ),

              // Track and Confirm buttons at the bottom of each card
              if (!order.isConfirmed!)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Track Order button - only visible for pending orders
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.location_on_outlined),
                          label: const Text('Track Order'),
                          onPressed: () => _trackOrder(order.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ClientColors.secondary, // Updated button color
                            foregroundColor: ClientColors.onSecondary, // Updated text color
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm Order button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await Provider.of<OrderProvider>(context, listen: false)
                                .confirmOrder(order.id);
                            await _loadOrders(); // Refresh the order list after confirmation

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Order confirmed successfully'),
                                backgroundColor: ClientColors.primary, // Updated SnackBar color
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ClientColors.primary, // Updated button color
                            foregroundColor: ClientColors.onPrimary, // Updated text color
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Confirm Order'),
                        ),
                      ),
                    ],
                  ),
                ),

              // For confirmed orders, show a confirmation message
              if (order.isConfirmed!)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: ClientColors.secondary, // Updated icon color
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Order confirmed',
                        style: TextStyle(
                          color: ClientColors.secondary, // Updated text color
                          fontWeight: FontWeight.w600,
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