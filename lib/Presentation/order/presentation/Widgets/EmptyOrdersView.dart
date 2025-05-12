import 'package:flutter/material.dart';
import 'package:hanouty/Core/theme/AppColors.dart'; // Add this import for MarketOwnerColors

class EmptyOrdersView extends StatelessWidget {
  const EmptyOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: MarketOwnerColors.primary.withOpacity(0.5), // Use primary color with opacity
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MarketOwnerColors.text, // Use text color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no orders for this time period',
            style: TextStyle(
              fontSize: 16,
              color: MarketOwnerColors.textLight, // Use lighter text color
            ),
          ),
        ],
      ),
    );
  }
}