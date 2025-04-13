import 'package:flutter/material.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
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
              child: _buildProductImage(),
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

  Widget _buildProductImage() {
    // Check if the image exists and is not empty
    if (product.image == null || product.image!.isEmpty) {
      return _buildPlaceholderImage();
    }
    final String fullImageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(product.image!)
        : ApiConstants.getFullImageUrl(product.image!);

    debugPrint('Loading product image: $fullImageUrl');

    // For Flutter Web: Use a CORS proxy service
    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 100,
        width: double.infinity,
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Error loading image: $error');
        return GestureDetector(
          onTap: () {
            // Show image URL in dialog for debugging
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Image Error'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Failed to load image:'),
                      const SizedBox(height: 8),
                      Text(fullImageUrl, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('Original path: ${product.image}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),
                      const Text('Check that:'),
                      const Text('• Backend server is running'),
                      const Text('• File exists on server'),
                      const Text('• Path is correct'),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey[400], size: 24),
                const SizedBox(height: 4),
                const Text(
                  'Image not found',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Tap for details',
                  style: TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

   Widget _buildPlaceholderImage() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image, color: Colors.grey, size: 24),
          SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  
}
