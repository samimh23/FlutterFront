import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';

class MarketCard extends StatelessWidget {
  final Markets market;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isDarkMode;
  final Color cardColor;
  final int orderCount;
  final double revenue;
  final VoidCallback onTap;

  const MarketCard({
    Key? key,
    required this.market,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isDarkMode,
    required this.cardColor,
    required this.orderCount,
    required this.revenue,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? imagePath = (market as dynamic).marketImage;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 12.0 : 14.0;
    final padding = isSmallScreen ? 12.0 : 16.0;

    // Colors based on theme, merchant/market version
    final textColor = isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary;
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : Theme.of(context).colorScheme.onSurface.withOpacity(0.8);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final borderColor = isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.withOpacity(0.09);
    final placeholderColor = isDarkMode ? const Color(0xFF1A2E1A) : const Color(0xFFEEF7ED);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          splashColor: accentColor.withOpacity(0.1),
          highlightColor: accentColor.withOpacity(0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container with hero animation for smooth transitions
              Hero(
                tag: 'market_image_${market.id}_orders',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: isMediumScreen ? 120 : 140,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Market Image
                        _buildMarketImage(imagePath, placeholderColor, accentColor),

                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),

                        // Order Badge with animation
                        Positioned(
                          top: isSmallScreen ? 8 : 12,
                          right: isSmallScreen ? 8 : 12,
                          child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value as double,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 8 : 10,
                                      vertical: isSmallScreen ? 4 : 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: orderCount > 0 ? accentColor : Colors.orange,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.26),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          orderCount > 0 ? Icons.receipt : Icons.hourglass_empty,
                                          size: iconSize,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: isSmallScreen ? 2 : 4),
                                        Text(
                                          orderCount > 0 ? '$orderCount Orders' : 'No Orders',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 10 : 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),

                        // Location Badge
                        Positioned(
                          bottom: isSmallScreen ? 8 : 12,
                          left: isSmallScreen ? 8 : 12,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: iconSize,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (market as dynamic).marketLocation ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Market Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Market Name
                      Text(
                        (market as dynamic).marketName ?? '',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),

                      // Revenue Info with animated progress bar
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(isDarkMode ? 0.22 : 0.11),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.attach_money,
                              size: iconSize,
                              color: isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Revenue: TD${revenue.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: smallFontSize,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Progress bar for order visualization
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0.0, end: orderCount > 0 ? 1.0 : 0.0),
                                  builder: (context, value, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.grey.withOpacity(isDarkMode ? 0.3 : 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        orderCount > 0
                                            ? accentColor
                                            : Colors.orange,
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('View Orders'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketImage(String? imagePath, Color placeholderColor, Color accentColor) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'image_url_here') {
      return Container(
        color: placeholderColor,
        child: Center(
          child: Icon(
            Icons.storefront,
            size: 50,
            color: accentColor,
          ),
        ),
      );
    }

    // Process the image URL using ApiConstants
    final String imageUrl = ApiConstants.getFullImageUrl(imagePath);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base placeholder
        Container(color: placeholderColor),

        // Actual image
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.red.withOpacity(0.7),
                size: 40,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                strokeWidth: 2,
              ),
            );
          },
        ),
      ],
    );
  }
}