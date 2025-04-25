// lib/Presentation/order/presentation/Page/widgets/loading_view.dart

import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final bool isSmallScreen;
  final bool isDarkMode;

  const LoadingView({
    Key? key,
    required this.isSmallScreen,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + 0.2 * (value as double),
                  child: Opacity(
                    opacity: value,
                    child: Image.asset(
                      'icons/loading_basket.png',
                      height: isSmallScreen ? 80 : 120,
                      width: isSmallScreen ? 80 : 120,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            // Loading text with shimmer effect
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value as double,
                  child: Text(
                    'Loading market orders...',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Progress indicator
            SizedBox(
              width: isSmallScreen ? 100 : 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}