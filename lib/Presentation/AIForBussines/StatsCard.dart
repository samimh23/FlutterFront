import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsCard({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final numberFormat = NumberFormat.compact();

    if (stats.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No statistics available'),
        ),
      );
    }

    Map<String, dynamic> statsData = stats['stats'] ?? {};

    // Get screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebLayout = screenWidth > 600;

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(isWebLayout ? 8 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'User: ${statsData['username'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const Divider(height: 24),

            // Responsive grid layout - adjust crossAxisCount based on screen width
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getGridCrossAxisCount(context),
              childAspectRatio: _getChildAspectRatio(context),
              children: [
                _StatTile(
                  title: 'Total Sales',
                  value: formatter.format(statsData['total_sales'] ?? 0),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                _StatTile(
                  title: 'Avg Purchase',
                  value: formatter.format(statsData['avg_purchase'] ?? 0),
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                ),
                _StatTile(
                  title: 'Total Orders',
                  value: numberFormat.format(statsData['total_orders'] ?? 0),
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                ),
                _StatTile(
                  title: 'Unique Customers',
                  value: numberFormat.format(statsData['unique_customers'] ?? 0),
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.update, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${statsData['last_updated'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Determine grid columns based on screen width
  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) return 4;     // Large desktop: 4 columns
    if (width > 900) return 4;      // Desktop: 4 columns
    if (width > 600) return 2;      // Tablet: 2 columns
    return 1;                       // Phone: 1 column (stacked)
  }

  // Adjust aspect ratio based on screen width
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) return 1.8;   // Large desktop
    if (width > 900) return 1.6;    // Desktop
    if (width > 600) return 1.5;    // Tablet
    return 2.2;                     // Phone (more height than width)
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive font sizes
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
    final titleSize = isLargeScreen ? 14.0 : 12.0;
    final valueSize = isLargeScreen ? 22.0 : 18.0;
    final iconSize = isLargeScreen ? 20.0 : 18.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: iconSize),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: titleSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}