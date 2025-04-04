import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/responsive/responsive_layout.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Get responsive dimensions based on device type
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Adjust card width based on device type
    final cardWidth = isDesktop ? 220.0 : (isTablet ? 180.0 : 120.0);
    final borderRadius = isDesktop ? 12.0 : 8.0;
    final fontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);
    final priceFontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);
    final discountFontSize = isDesktop ? 12.0 : (isTablet ? 11.0 : 10.0);
    final imageHeight = isDesktop ? 140.0 : (isTablet ? 120.0 : 100.0);
    final horizontalPadding = isDesktop ? 10.0 : (isTablet ? 8.0 : 6.0);

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(borderRadius)),
              child: _buildProductImage(context, imageHeight),
            ),
            SizedBox(height: isDesktop ? 10 : 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                product.name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${product.originalPrice} DT',
                    style: TextStyle(
                      fontSize: priceFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  if (product.isDiscounted && product.discountValue > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${(product.originalPrice + product.discountValue).toStringAsFixed(0)} DT',
                        style: TextStyle(
                          fontSize: discountFontSize,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, double imageHeight) {
    // Check if the images array exists and has elements
    if (product.images.isEmpty || product.images[0].isEmpty) {
      return _buildPlaceholderImage(context, imageHeight);
    }
    print('fdsfdsfsd*************fdsfsdfdsfds $product');
    // Original image URL
    String originalUrl = product.images[0];
    debugPrint('Original image URL: $originalUrl');

    // For Flutter Web: Use a CORS proxy service
    String imageUrl = originalUrl;

    if (kIsWeb) {
      // Use a CORS proxy service
      imageUrl = 'https://corsproxy.io/?' + Uri.encodeComponent(originalUrl);
      debugPrint('Using proxied URL for web: $imageUrl');
    }

    // Using CachedNetworkImage for better performance and error handling
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: imageHeight,
        width: double.infinity,
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Error loading image: $error');
        // When error, try with a different proxy as fallback
        if (kIsWeb && !url.contains('cors-anywhere')) {
          return _buildWebImageWithFallback(context, originalUrl, imageHeight);
        }
        return Container(
          height: imageHeight,
          width: double.infinity,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.red,
                  size: ResponsiveLayout.isDesktop(context) ? 32 : 24),
              const SizedBox(height: 4),
              Text(
                'Image Error',
                style: TextStyle(
                    fontSize: ResponsiveLayout.isDesktop(context) ? 12 : 10,
                    color: Colors.red[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebImageWithFallback(
      BuildContext context, String originalUrl, double imageHeight) {
    // Try a different CORS proxy as fallback
    String fallbackUrl = 'https://api.allorigins.win/raw?url=' +
        Uri.encodeComponent(originalUrl);
    debugPrint('Trying fallback URL: $fallbackUrl');

    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      height: imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: imageHeight,
        width: double.infinity,
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Fallback image also failed: $error');
        return _buildPlaceholderImage(context, imageHeight);
      },
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, double imageHeight) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      height: imageHeight,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, color: Colors.grey, size: isDesktop ? 32 : 24),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: isDesktop ? 12 : 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
