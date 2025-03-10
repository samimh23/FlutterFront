import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/app_colors.dart';


class ShopCard extends StatelessWidget {
  final String heroTag;
  final String name;
  final String categories;
  final double rating;
  final String deliveryCost;
  final String deliveryTime;
  final String imageUrl;
  final VoidCallback onTap;

  // List of known problematic URLs
  static final Set<String> _problematicUrls = {
    'https://www.entreprises-magazine.com/wp-content/uploads/2020/03/Carrefour-Coronavirus.png',
  };

  const ShopCard({
    super.key,
    required this.heroTag,
    required this.name,
    required this.categories,
    required this.rating,
    required this.deliveryCost,
    required this.deliveryTime,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero with safe image
            Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _isProblematicUrl() ? _buildSimpleFallback() : _buildImage(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categories,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              deliveryCost,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deliveryTime,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  // Check if the URL is in our problematic list
  bool _isProblematicUrl() {
    return _problematicUrls.contains(imageUrl);
  }

Widget _buildImage() {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    width: 100,
    height: 100,
    fit: BoxFit.cover,
    placeholder: (context, url) => _buildLoadingIndicator(),
    errorWidget: (context, url, error) => _buildSimpleFallback(),
  );
}


  Widget _buildLoadingIndicator() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSimpleFallback() {
    Color backgroundColor = _getMarketColor();
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          _getMarketInitials(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
  
  Color _getMarketColor() {
    if (name.toLowerCase().contains('aziza')) {
      return Colors.green.shade700;
    } else if (name.toLowerCase().contains('carrefour')) {
      return Colors.blue.shade700;
    }
    return AppColors.primary;
  }
  
  String _getMarketInitials() {
    List<String> words = name.split(' ');
    String initials = '';
    for (var word in words) {
      if (word.isNotEmpty) {
        initials += word[0].toUpperCase();
      }
    }
    return initials;
  }
}