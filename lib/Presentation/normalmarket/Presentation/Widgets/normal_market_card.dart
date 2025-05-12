import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';

class MarketCard extends StatelessWidget {
  final Markets market;
  final VoidCallback onTap;

  const MarketCard({
    Key? key,
    required this.market,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Merchant theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = colorScheme.surface;
    final borderColor = colorScheme.secondary.withOpacity(0.18);
    final titleColor = colorScheme.primary;
    final subtitleColor = colorScheme.onSurface.withOpacity(0.7);

    final String? imagePath = (market as dynamic).marketImage;
    final String heroTag = 'market_image_${market.id}';

    return Card(
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: colorScheme.secondary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Hero animation
            SizedBox(
              height: 140,
              width: double.infinity,
              child: _buildMarketImage(imagePath, heroTag, colorScheme),
            ),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (market as dynamic).marketName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: colorScheme.secondary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (market as dynamic).marketLocation,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build market image with hero tag
  Widget _buildMarketImage(String? imagePath, String heroTag, ColorScheme colorScheme) {
    final Widget imageContent = imagePath != null && imagePath.isNotEmpty
        ? _buildNetworkImage(imagePath, colorScheme)
        : _buildPlaceholderImage(colorScheme);

    return Hero(
      tag: heroTag,
      child: imageContent,
    );
  }

  Widget _buildNetworkImage(String imagePath, ColorScheme colorScheme) {
    return Image.network(
      ApiConstants.getFullImageUrl(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage(colorScheme);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: colorScheme.secondary.withOpacity(0.07),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
              strokeWidth: 2.2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.secondary.withOpacity(0.05),
      child: Center(
        child: Icon(Icons.store, size: 40, color: colorScheme.secondary.withOpacity(0.2)),
      ),
    );
  }
}