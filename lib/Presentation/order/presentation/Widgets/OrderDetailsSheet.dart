// lib/Presentation/order/presentation/Page/widgets/order_details_sheet.dart

import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrderDetailsSheet extends StatelessWidget {
  final Order order;
  final VoidCallback? onOrderUpdated;  // Add this callback

  const OrderDetailsSheet({
    Key? key,
    required this.order,
    this.onOrderUpdated,  // Make it optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Order info
            ListTile(
              leading: const Icon(Icons.receipt, color: Color(0xFF4CAF50)),
              title: const Text('Order ID'),
              subtitle: Text(order.id),
              contentPadding: EdgeInsets.zero,
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
              title: const Text('Order Date'),
              subtitle: Text(formattedDate),
              contentPadding: EdgeInsets.zero,
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF4CAF50)),
              title: const Text('Customer ID'),
              subtitle: Text(order.user),
              contentPadding: EdgeInsets.zero,
            ),

            ListTile(
              leading: const Icon(Icons.payments, color: Color(0xFF4CAF50)),
              title: const Text('Total Amount'),
              subtitle: Text('TD ${order.totalPrice.toStringAsFixed(2)}'),
              contentPadding: EdgeInsets.zero,
            ),

            ListTile(
              leading: Icon(
                isConfirmed ? Icons.check_circle : Icons.pending,
                color: isConfirmed ? const Color(0xFF4CAF50) : const Color(0xFFFFA000),
              ),
              title: const Text('Status'),
              subtitle: Text(
                isConfirmed ? 'Confirmed' : 'Waiting for confirmation',
                style: TextStyle(
                  color: isConfirmed ? const Color(0xFF4CAF50) : const Color(0xFFFFA000),
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),

            // Products list
            const SizedBox(height: 8),
            const Text(
              'Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),

            // Products list
            Expanded(
              child: ListView.builder(
                itemCount: order.products.length,
                itemBuilder: (context, index) {
                  final product = order.products[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_cart,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      'Product #${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text('Check order details'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}