import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hanouty/Core/theme/AppColors.dart'; // Import MarketOwnerColors

class StatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool compactMode;

  const StatsCard({
    Key? key,
    required this.stats,
    this.compactMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'TD ', decimalDigits: 2); // Using TD for Tunisia
    final numberFormat = NumberFormat.compact();

    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;
    final isSmallMobile = size.width < 360;

    if (stats.isEmpty) {
      return Card(
        margin: EdgeInsets.all(isMobile ? 8 : 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: MarketOwnerColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_outlined,
                    color: MarketOwnerColors.textLight.withOpacity(0.5),
                    size: 40),
                const SizedBox(height: 12),
                Text(
                  'No statistics available',
                  style: TextStyle(color: MarketOwnerColors.textLight),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Map<String, dynamic> statsData = stats['stats'] ?? {};

    return Card(
      elevation: isMobile ? 2 : 4,
      margin: EdgeInsets.all(isMobile ? 0 : 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: MarketOwnerColors.surface,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Responsive layout for mobile
            if (isMobile && compactMode)
            // Compact header for very small mobile screens
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MarketOwnerColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User: ${statsData['username'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: MarketOwnerColors.textLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            else
            // Standard header with row layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: MarketOwnerColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isSmallMobile || !compactMode)
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: MarketOwnerColors.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

            // Divider with adjusted spacing for mobile
            Divider(
              height: isMobile ? 16 : 24,
              thickness: 1,
              color: MarketOwnerColors.textLight.withOpacity(0.1),
            ),

            // Grid layout with mobile optimization
            _buildStatsGrid(context, statsData, formatter, numberFormat),

            // Footer with last updated info - better visibility for mobile
            Divider(
              height: isMobile ? 16 : 24,
              thickness: 1,
              color: MarketOwnerColors.textLight.withOpacity(0.1),
            ),

            // Last updated row - better contrast and size for mobile
            _buildLastUpdatedRow(context, statsData, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> statsData,
      NumberFormat formatter, NumberFormat numberFormat) {

    final isMobile = MediaQuery.of(context).size.width <= 600;
    final isSmallMobile = MediaQuery.of(context).size.width < 360;

    // For very small mobile screens in compact mode, use a more space-efficient layout
    if (isSmallMobile && compactMode) {
      return Column(
        children: [
          // Two-column layout for first row stats
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  title: 'Total Sales',
                  value: formatter.format(statsData['total_sales'] ?? 0),
                  icon: Icons.attach_money,
                  color: MarketOwnerColors.primary,
                  isCompact: true,
                ),
              ),
              Expanded(
                child: _StatTile(
                  title: 'Avg Purchase',
                  value: formatter.format(statsData['avg_purchase'] ?? 0),
                  icon: Icons.shopping_cart,
                  color: MarketOwnerColors.secondary,
                  isCompact: true,
                ),
              ),
            ],
          ),
          // Two-column layout for second row stats
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  title: 'Orders',
                  value: numberFormat.format(statsData['total_orders'] ?? 0),
                  icon: Icons.receipt_long,
                  color: MarketOwnerColors.accent,
                  isCompact: true,
                ),
              ),
              Expanded(
                child: _StatTile(
                  title: 'Customers',
                  value: numberFormat.format(statsData['unique_customers'] ?? 0),
                  icon: Icons.people,
                  color: Colors.purple, // Keep this color for contrast
                  isCompact: true,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Standard responsive grid for other screen sizes
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _getGridCrossAxisCount(context),
      childAspectRatio: _getChildAspectRatio(context),
      crossAxisSpacing: isMobile ? 8 : 12,
      mainAxisSpacing: isMobile ? 8 : 12,
      children: [
        _StatTile(
          title: 'Total Sales',
          value: formatter.format(statsData['total_sales'] ?? 0),
          icon: Icons.attach_money,
          color: MarketOwnerColors.primary,
        ),
        _StatTile(
          title: 'Avg Purchase',
          value: formatter.format(statsData['avg_purchase'] ?? 0),
          icon: Icons.shopping_cart,
          color: MarketOwnerColors.secondary,
        ),
        _StatTile(
          title: isMobile && compactMode ? 'Orders' : 'Total Orders',
          value: numberFormat.format(statsData['total_orders'] ?? 0),
          icon: Icons.receipt_long,
          color: MarketOwnerColors.accent,
        ),
        _StatTile(
          title: isMobile && compactMode ? 'Customers' : 'Unique Customers',
          value: numberFormat.format(statsData['unique_customers'] ?? 0),
          icon: Icons.people,
          color: Colors.purple, // Keep this color for contrast
        ),
      ],
    );
  }

  Widget _buildLastUpdatedRow(BuildContext context, Map<String, dynamic> statsData, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.update,
          size: isMobile ? 14 : 16,
          color: MarketOwnerColors.textLight.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          'Last updated: ${statsData['last_updated'] ?? 'Unknown'}',
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: MarketOwnerColors.textLight.withOpacity(0.7),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Determine grid columns based on screen width
  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // For compact mode on mobile, always use 2 columns
    if (width <= 600 && compactMode) return 2;

    if (width > 1200) return 4;     // Large desktop: 4 columns
    if (width > 900) return 4;      // Desktop: 4 columns
    if (width > 600) return 2;      // Tablet: 2 columns
    return width > 380 ? 2 : 1;     // Phone: 2 columns if enough width, else 1
  }

  // Adjust aspect ratio based on screen width
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // For compact mode, make tiles more horizontally oriented
    if (width <= 600 && compactMode) return 1.8;

    if (width > 1200) return 1.8;   // Large desktop
    if (width > 900) return 1.6;    // Desktop
    if (width > 600) return 1.5;    // Tablet
    return width > 380 ? 1.3 : 2.5; // Phone: different ratios based on layout
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCompact;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Enhanced responsive sizing
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;
    final isSmallMobile = size.width < 360;

    // Adjust sizes based on device and compact mode
    final titleSize = isCompact ? 10.0 :
    (isSmallMobile ? 11.0 :
    (isMobile ? 12.0 : 14.0));

    final valueSize = isCompact ? 16.0 :
    (isSmallMobile ? 16.0 :
    (isMobile ? 18.0 : 22.0));

    final iconSize = isCompact ? 16.0 :
    (isSmallMobile ? 18.0 :
    (isMobile ? 20.0 : 22.0));

    // For very compact mode, use a horizontal layout
    if (isCompact) {
      return Card(
        elevation: 1,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: MarketOwnerColors.textLight,
                        fontSize: titleSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
            ],
          ),
        ),
      );
    }

    // Standard card design with enhanced mobile styling
    return Card(
      elevation: isMobile ? 1 : 2,
      margin: EdgeInsets.all(isMobile ? 4 : 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: iconSize),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: MarketOwnerColors.textLight,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w500,
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