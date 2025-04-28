// lib/Presentation/order/presentation/Page/widgets/error_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';

class ErrorView extends StatelessWidget {
  final NormalMarketProvider provider;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isDarkMode;
  final VoidCallback onRetry;

  const ErrorView({
    Key? key,
    required this.provider,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isDarkMode,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentWidth = isSmallScreen
        ? double.infinity
        : isMediumScreen
        ? 400.0
        : 500.0;

    final padding = isSmallScreen ? 16.0 : 30.0;

    // Color theme adjustments based on dark mode
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final errorColor = isDarkMode ? Colors.redAccent.shade200 : Colors.red[700];
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F7F3),
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          child: Container(
            width: contentWidth,
            margin: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 20),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error icon with animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0.7, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value as double,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: errorColor?.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: errorColor,
                          size: isSmallScreen ? 50 : 70,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Oops! Could not load markets',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  provider.errorMessage,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 24),
                  label: Text(
                    'Try Again',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}