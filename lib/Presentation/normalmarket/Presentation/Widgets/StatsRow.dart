// lib/Presentation/order/presentation/Page/widgets/stats_row.dart

import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final int totalOrders;
  final int marketsCount;
  final double totalRevenue;
  final bool isSmallScreen;
  final bool isDarkMode;
  final Color cardColor;
  final Color accentColor;
  final Color dividerColor;

  const StatsRow({
    Key? key,
    required this.totalOrders,
    required this.marketsCount,
    required this.totalRevenue,
    required this.isSmallScreen,
    required this.isDarkMode,
    required this.cardColor,
    required this.accentColor,
    required this.dividerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final valueFontSize = isSmallScreen ? 18.0 : 20.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final padding = isSmallScreen ? 16.0 : 20.0;

    // Use colors based on dark mode
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey.shade500 : const Color(0xFF666666);

    // Define color schemes for each stat
    final ordersColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final marketsColor = isDarkMode ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
    final revenueColor = isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDarkMode ? Border.all(color: Colors.grey.shade800, width: 1) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.receipt_long,
              iconColor: ordersColor,
              bgColor: ordersColor.withOpacity(0.1),
              value: '$totalOrders',
              label: 'Orders',
              isSmallScreen: isSmallScreen,
              iconSize: iconSize,
              fontSize: fontSize,
              valueFontSize: valueFontSize,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ),
          _buildStatDivider(isSmallScreen, dividerColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.store,
              iconColor: marketsColor,
              bgColor: marketsColor.withOpacity(0.1),
              value: '$marketsCount',
              label: 'Markets',
              isSmallScreen: isSmallScreen,
              iconSize: iconSize,
              fontSize: fontSize,
              valueFontSize: valueFontSize,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ),
          _buildStatDivider(isSmallScreen, dividerColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.attach_money,
              iconColor: revenueColor,
              bgColor: revenueColor.withOpacity(0.1),
              value: 'TD ${totalRevenue.toStringAsFixed(2)}',
              label: 'Revenue',
              isSmallScreen: isSmallScreen,
              iconSize: iconSize,
              fontSize: fontSize,
              valueFontSize: valueFontSize,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isSmallScreen, Color dividerColor) {
    return Container(
      height: isSmallScreen ? 30 : 40,
      width: 1,
      color: dividerColor,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
    required bool isSmallScreen,
    required double iconSize,
    required double fontSize,
    required double valueFontSize,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}