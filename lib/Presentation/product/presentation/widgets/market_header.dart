import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanouty/app_colors.dart';

import '../../../../Core/theme/AppColors.dart';

class MarketHeader extends StatelessWidget {
  final String heroTag;
  final String marketName;
  final String imageUrl;
  final bool isDesktop;

  const MarketHeader({
    super.key,
    required this.heroTag,
    required this.marketName,
    required this.imageUrl,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = isDesktop ? 28.0 : 22.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          Hero(
            tag: heroTag,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: ClientColors.background.withOpacity(0.3), // Updated placeholder color
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ClientColors.primary), // Updated loader color
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: ClientColors.background.withOpacity(0.3), // Updated error background color
                      child: Center(
                        child: Icon(Icons.error, size: 50, color: ClientColors.textLight), // Updated error icon color
                      ),
                    ),
                  ),
                ),
                // Gradient overlay for better visibility of any potential overlaid elements
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Market verification badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ClientColors.primary, // Updated badge color
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: ClientColors.onPrimary, // Updated icon color
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: ClientColors.onPrimary, // Updated text color
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(
              child: Text(
                marketName,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: ClientColors.text, // Updated text color
                ),
              ),
            ),
            if (!isDesktop)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ClientColors.primary.withOpacity(0.1), // Subtle badge background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: ClientColors.primary, // Updated icon color
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: ClientColors.primary, // Updated text color
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Market stats with client theme colors
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ClientColors.background.withOpacity(0.2), // Subtle background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: ClientColors.accent, // Updated star color
                size: isDesktop ? 22 : 18,
              ),
              const SizedBox(width: 4),
              Text(
                '4.2',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: ClientColors.accent, // Updated rating color
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.delivery_dining,
                color: ClientColors.primary, // Using primary client color
                size: isDesktop ? 22 : 18,
              ),
              const SizedBox(width: 4),
              Text(
                '2.2 DT',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: ClientColors.primary, // Using primary client color
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                color: ClientColors.textLight, // Updated clock icon color
                size: isDesktop ? 22 : 18,
              ),
              const SizedBox(width: 4),
              Text(
                '25 min',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: ClientColors.textLight, // Updated text color
                ),
              ),
            ],
          ),
        ),

        // Market open status indicator
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ClientColors.secondary.withOpacity(0.1), // Subtle background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ClientColors.secondary, // Updated border color
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ClientColors.secondary, // Updated indicator color
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Open Now • Closes at 9:00 PM',
                style: TextStyle(
                  color: ClientColors.secondary, // Updated text color
                  fontWeight: FontWeight.w500,
                  fontSize: isDesktop ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}