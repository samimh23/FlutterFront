// lib/Presentation/order/presentation/Widgets/OrderCard.dart

import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' show min;

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onViewDetails;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    // Handle dateOrder which could be DateTime or String
    late DateTime orderDate;
    try {
      if (order.dateOrder is DateTime) {
        orderDate = order.dateOrder as DateTime;
      } else if (order.dateOrder is String) {
        orderDate = DateTime.parse(order.dateOrder as String);
      } else {
        print('Warning: Unexpected dateOrder type: ${order.dateOrder.runtimeType}');
        orderDate = DateTime.now(); // Fallback
      }
    } catch (e) {
      print('Error parsing date: $e');
      orderDate = DateTime.now(); // Fallback
    }

    final formattedDate = dateFormat.format(orderDate);

    // Safe handling of nullable isConfirmed
    final bool isConfirmed = order.isConfirmed ?? false;

    // Calculate total items
    int totalItems = 0;
    for (var product in order.products) {
      totalItems += 1;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? const Color(0xFF4CAF50).withOpacity(0.1)  // Green for confirmed
                  : const Color(0xFFFFA000).withOpacity(0.1), // Orange for pending
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isConfirmed ? Icons.check_circle : Icons.pending,
                  size: 20,
                  color: isConfirmed
                      ? const Color(0xFF4CAF50)  // Green for confirmed
                      : const Color(0xFFFFA000), // Orange for pending
                ),
                const SizedBox(width: 8),
                Text(
                  'Order #${order.id.substring(0, min(8, order.id.length)).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  isConfirmed ? 'Completed' : 'Pending',
                  style: TextStyle(
                    color: isConfirmed
                        ? const Color(0xFF4CAF50)  // Green for confirmed
                        : const Color(0xFFFFA000), // Orange for pending
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Order details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and items count
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$totalItems items',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price
                Row(
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TD ${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: !isConfirmed
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                      onPressed: onViewDetails,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Show Send Package button only for pending orders
                    if (!isConfirmed)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Send Package'),
                        onPressed: () => _sendPackage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Handle sending package - using the existing provider method
  void _sendPackage(BuildContext context) async {
    // Show confirmation dialog
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Package'),
        content: const Text('Are you sure you want to mark this order as sent? The client will be notified to confirm receipt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Send'),
          ),
        ],
      ),
    ) ?? false;

    if (shouldSend) {
      try {
        // Use the existing sendPackage method in the provider
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        await orderProvider.sendPackage(order.id);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Package marked as sent. Awaiting client confirmation.'),
            backgroundColor: Color(0xFF2196F3),
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}