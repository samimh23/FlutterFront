// lib/Presentation/order/presentation/Page/widgets/empty_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmptyView extends StatelessWidget {
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isDarkMode;

  const EmptyView({
    Key? key,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentWidth = isSmallScreen
        ? double.infinity
        : isMediumScreen
        ? 450.0
        : 550.0;

    final padding = isSmallScreen ? 20.0 : 30.0;

    // Color theme adjustments based on dark mode
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final subtitleColor = isDarkMode ? Colors.grey[400] : const Color(0xFF555555);

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: contentWidth,
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 20),
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
                // Receipt icon with bounce animation
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 1),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + 0.2 * (value as double),
                      child: Opacity(
                        opacity: value,
                        child: Icon(
                          Icons.receipt_long,
                          size: isSmallScreen ? 100 : 140,
                          color: accentColor.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                Text(
                  'No Markets Found',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Create your first market to start viewing orders and sales data',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 18,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 30 : 40),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 30,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    shape: const StadiumBorder(),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard, size: isSmallScreen ? 18 : 24),
                      SizedBox(width: isSmallScreen ? 8 : 10),
                      Text(
                        'Go to Dashboard',
                        style: TextStyle(fontSize: isSmallScreen ? 15 : 18),
                      ),
                    ],
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