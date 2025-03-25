import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanouty/app_colors.dart';

class MarketHeader extends StatelessWidget {
  final String heroTag;
  final String marketName;
  final double rating;
  final String deliveryCost;
  final String deliveryTime;
  final String imageUrl;
  final bool isDesktop;

  const MarketHeader({
    super.key,
    required this.heroTag,
    required this.marketName,
    required this.rating,
    required this.deliveryCost,
    required this.deliveryTime,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        Text(
          marketName,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber.shade600, size: isDesktop ? 24 : 20),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.amber.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.delivery_dining, color: AppColors.primary, size: isDesktop ? 24 : 20),
            const SizedBox(width: 4),
            Text(
              deliveryCost,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.access_time, color: Colors.grey, size: isDesktop ? 24 : 20),
            const SizedBox(width: 4),
                        Text(
              deliveryTime,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}