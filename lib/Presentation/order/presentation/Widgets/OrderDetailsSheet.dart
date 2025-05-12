import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:hanouty/Core/theme/AppColors.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrderDetailsSheet extends StatelessWidget {
  final Order order;
  final VoidCallback? onOrderUpdated;

  const OrderDetailsSheet({
    Key? key,
    required this.order,
    this.onOrderUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Create safely formatted date
    String formattedDate;
    try {
      DateTime orderDate;
      if (order.dateOrder is DateTime) {
        orderDate = order.dateOrder as DateTime;
      } else if (order.dateOrder is String) {
        orderDate = DateTime.parse(order.dateOrder as String);
      } else {
        orderDate = DateTime.now();
      }
      formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(orderDate);
    } catch (e) {
      formattedDate = "Unknown date";
      print('Error formatting date in details: $e');
    }

    // Safely handle nullable isConfirmed value
    final bool isConfirmed = order.isConfirmed ?? false;

    // Safely handle orderStatus
    String orderStatus = "Processing";
    try {
      if (order.orderStatus != null) {
        orderStatus = order.orderStatus.toString();
      }
    } catch (e) {
      print('Error accessing orderStatus: $e');
    }

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: MarketOwnerColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MarketOwnerColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header with status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MarketOwnerColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Order ID subtitle
                      Text(
                        'ID: ${order.id}',
                        style: TextStyle(
                          fontSize: 14,
                          color: MarketOwnerColors.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConfirmed
                        ? MarketOwnerColors.primary.withOpacity(0.1)
                        : MarketOwnerColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isConfirmed
                          ? MarketOwnerColors.primary
                          : MarketOwnerColors.secondary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(orderStatus, isConfirmed),
                        size: 16,
                        color: isConfirmed
                            ? MarketOwnerColors.primary
                            : MarketOwnerColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        orderStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: isConfirmed
                              ? MarketOwnerColors.primary
                              : MarketOwnerColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: MarketOwnerColors.textLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(color: MarketOwnerColors.textLight.withOpacity(0.2)),
            const SizedBox(height: 8),

            // Order summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MarketOwnerColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MarketOwnerColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Date row
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'Order Date',
                    value: formattedDate,
                    iconColor: MarketOwnerColors.primary,
                  ),
                  const SizedBox(height: 12),

                  // Customer row
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    title: 'Customer ID',
                    value: order.user,
                    iconColor: MarketOwnerColors.primary,
                  ),
                  const SizedBox(height: 12),

                  // Amount row with highlighted price
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MarketOwnerColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.payment_outlined,
                          color: MarketOwnerColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 14,
                              color: MarketOwnerColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'TD ${order.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: MarketOwnerColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products header with count
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MarketOwnerColors.text,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: MarketOwnerColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${order.products.length} items',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: MarketOwnerColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Products list
            Expanded(
              child: order.products.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 48,
                      color: MarketOwnerColors.textLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products in this order',
                      style: TextStyle(
                        color: MarketOwnerColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: order.products.length,
                separatorBuilder: (context, index) => Divider(
                  color: MarketOwnerColors.textLight.withOpacity(0.1),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final product = order.products[index];
                  return _buildProductCard(product, index);
                },
              ),
            ),

            // Bottom actions - only show for orders that are not confirmed
            if (!isConfirmed && onOrderUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.message),
                        label: const Text('Contact Customer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: MarketOwnerColors.primary,
                          side: BorderSide(color: MarketOwnerColors.primary),
                        ),
                        onPressed: () {
                          // Handle customer contact
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Contact feature coming soon'),
                              backgroundColor: MarketOwnerColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Send Package'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: MarketOwnerColors.primary,
                          foregroundColor: MarketOwnerColors.onPrimary,
                        ),
                        onPressed: onOrderUpdated,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status, bool isConfirmed) {
    if (isConfirmed) {
      return Icons.check_circle;
    }

    switch (status.toLowerCase()) {
      case 'delivering':
        return Icons.local_shipping;
      case 'isprocessing':
        return Icons.hourglass_bottom;
      default:
        return Icons.pending;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(  // Added Expanded to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: MarketOwnerColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: MarketOwnerColors.text,
                ),
                overflow: TextOverflow.ellipsis,  // Add ellipsis for long text
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fixed product card to handle map access safely
  Widget _buildProductCard(dynamic product, int index) {
    // Safely access productId and quantity
    String productId = '';
    int quantity = 1;

    try {
      // Access as map if it's a map
      if (product is Map) {
        productId = product['productId']?.toString() ?? '';
        quantity = int.tryParse(product['quantity']?.toString() ?? '1') ?? 1;
      } else {
        // Try dynamic property access if it's not a map
        try {
          productId = product.productId?.toString() ?? '';
        } catch (e) {
          print('Error accessing productId: $e');
        }

        try {
          quantity = int.tryParse(product.quantity?.toString() ?? '1') ?? 1;
        } catch (e) {
          print('Error accessing quantity: $e');
        }
      }
    } catch (e) {
      print('Error in _buildProductCard: $e');
    }

    // Truncate productId if it's too long
    String displayId = '';
    if (productId.isNotEmpty) {
      final maxLength = Math.min(12, productId.length);
      displayId = productId.substring(0, maxLength);
      if (productId.length > 12) displayId += '...';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Handle product details tap if needed
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              // Product image or icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: MarketOwnerColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: MarketOwnerColors.accent,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayId.isEmpty ? 'Product #${index + 1}' : 'Product ID: $displayId',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: MarketOwnerColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: MarketOwnerColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Qty: $quantity',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: MarketOwnerColors.secondary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Item #${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: MarketOwnerColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}