import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';

class MarketListItem extends StatelessWidget {
  final Markets market;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isDarkMode;
  final Color cardColor;
  final int orderCount;
  final double revenue;
  final VoidCallback onTap;

  const MarketListItem({
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
    final padding = isSmallScreen ? 12.0 : 16.0;
    final imageSize = isSmallScreen ? 60.0 : 80.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;

    // Merchant/market theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isDarkMode ? Colors.white : colorScheme.primary;
    final subtitleColor = isDarkMode
        ? Colors.grey.shade400
        : colorScheme.onSurface.withOpacity(0.8);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final borderColor = isDarkMode
        ? Colors.grey.shade800.withOpacity(0.5)
        : colorScheme.secondary.withOpacity(0.09);
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
          splashColor: accentColor.withOpacity(0.09),
          highlightColor: accentColor.withOpacity(0.04),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Market Image with hero animation
                Hero(
                  tag: 'market_image_${market.id}_orders',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: _buildMarketImage(imagePath, placeholderColor, accentColor),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),

                // Market Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Market Name
                          Expanded(
                            child: Text(
                              (market as dynamic).marketName ?? '',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Order Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 6 : 8,
                              vertical: isSmallScreen ? 3 : 4,
                            ),
                            margin: EdgeInsets.only(left: isSmallScreen ? 6 : 8),
                            decoration: BoxDecoration(
                              color: orderCount > 0
                                  ? accentColor
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  orderCount > 0 ? Icons.receipt : Icons.hourglass_empty,
                                  size: iconSize - 2,
                                  color: Colors.white,
                                ),
                                SizedBox(width: isSmallScreen ? 2 : 3),
                                Text(
                                  orderCount > 0 ? '$orderCount' : '0',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 10 : 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 4 : 6),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: iconSize - 2,
                            color: subtitleColor,
                          ),
                          SizedBox(width: isSmallScreen ? 2 : 4),
                          Expanded(
                            child: Text(
                              (market as dynamic).marketLocation ?? '',
                              style: TextStyle(
                                fontSize: smallFontSize - 1,
                                color: subtitleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 8 : 10),

                      // Revenue info
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: iconSize,
                            color: isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
                          ),
                          SizedBox(width: isSmallScreen ? 2 : 4),
                          Text(
                            'Revenue: TD${revenue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: smallFontSize,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  size: isSmallScreen ? 20 : 24,
                  color: subtitleColor,
                ),
              ],
            ),
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
            size: 30,
            color: accentColor,
          ),
        ),
      );
    }

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
                size: 20,
              ),
            );
          },
        ),
      ],
    );
  }
}