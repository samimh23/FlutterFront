// lib/Presentation/order/presentation/Page/widgets/no_results_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoResultsView extends StatelessWidget {
  final bool isSmallScreen;
  final bool isDarkMode;
  final Color cardColor;
  final VoidCallback onClearFilters;

  const NoResultsView({
    Key? key,
    required this.isSmallScreen,
    required this.isDarkMode,
    required this.cardColor,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: isSmallScreen ? 48 : 64,
            color: accentColor.withOpacity(0.7),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'No markets found',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 20 : 32),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onClearFilters();
            },
            icon: Icon(Icons.refresh_outlined, size: isSmallScreen ? 16 : 20),
            label: const Text('Clear filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 10 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}