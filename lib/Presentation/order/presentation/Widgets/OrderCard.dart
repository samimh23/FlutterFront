import 'package:flutter/material.dart';
import 'package:hanouty/Core/theme/AppColors.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
        color: MarketOwnerColors.surface, // Use surface color
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
                  ? MarketOwnerColors.primary.withOpacity(0.1)  // Primary blue for confirmed
                  : MarketOwnerColors.secondary.withOpacity(0.1), // Secondary for pending
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
                      ? MarketOwnerColors.primary  // Primary blue for confirmed
                      : MarketOwnerColors.secondary, // Secondary for pending
                ),
                const SizedBox(width: 8),
                Expanded(  // Added Expanded to prevent overflow
                  child: Text(
                    'Order #${order.id.substring(0, min(8, order.id.length)).toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: MarketOwnerColors.text, // Use text color
                    ),
                    overflow: TextOverflow.ellipsis,  // Add ellipsis for overflow
                  ),
                ),
                const SizedBox(width: 8), // Add space between title and status
                Text(
                  isConfirmed ? 'Completed' : 'Pending',
                  style: TextStyle(
                    color: isConfirmed
                        ? MarketOwnerColors.primary  // Primary blue for confirmed
                        : MarketOwnerColors.secondary, // Secondary for pending
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
                // Date and items count - Fix overflow with Flexible widgets
                Wrap(  // Replace Row with Wrap to prevent overflow
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,  // Don't take more space than needed
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: MarketOwnerColors.textLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: MarketOwnerColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,  // Don't take more space than needed
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: MarketOwnerColors.textLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$totalItems items',
                          style: TextStyle(
                            color: MarketOwnerColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price
                Row(
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: MarketOwnerColors.text, // Use text color
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TD ${order.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MarketOwnerColors.primary, // Use primary color
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons - Fix overflow with proper layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    // If in large screen or confirmed order (one button)
                    if (constraints.maxWidth > 320 || isConfirmed) {
                      return Row(
                        mainAxisAlignment: !isConfirmed
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                            onPressed: onViewDetails,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MarketOwnerColors.primary,
                              side: BorderSide(color: MarketOwnerColors.primary),
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
                                backgroundColor: MarketOwnerColors.primary,
                                foregroundColor: MarketOwnerColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      );
                    } else {
                      // In small screen with two buttons, stack them vertically
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                            onPressed: onViewDetails,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MarketOwnerColors.primary,
                              side: BorderSide(color: MarketOwnerColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.local_shipping),
                            label: const Text('Send Package'),
                            onPressed: () => _sendPackage(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MarketOwnerColors.primary,
                              foregroundColor: MarketOwnerColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
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
        backgroundColor: MarketOwnerColors.surface, // Use surface color
        title: Text('Send Package',
          style: TextStyle(color: MarketOwnerColors.text), // Use text color
        ),
        content: Text(
          'Are you sure you want to mark this order as sent? The client will be notified to confirm receipt.',
          style: TextStyle(color: MarketOwnerColors.textLight), // Use lighter text color
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: MarketOwnerColors.textLight, // Use lighter text color
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: MarketOwnerColors.primary, // Use primary color
              foregroundColor: MarketOwnerColors.onPrimary, // Use on primary color
            ),
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
          SnackBar(
            content: const Text('Package marked as sent. Awaiting client confirmation.'),
            backgroundColor: MarketOwnerColors.primary, // Use primary color
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: ${e.toString()}'),
            backgroundColor: Colors.red, // Keep red for errors
          ),
        );
      }
    }
  }
}