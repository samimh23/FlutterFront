import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: _buildProductImage(),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Text(
                    '${product.originalPrice.toStringAsFixed(0)} DT',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  if (product.isDiscounted && product.discountValue > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${(product.originalPrice + product.discountValue).toStringAsFixed(0)} DT',
                        style: const TextStyle(
                          fontSize: 10,
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
    // Check if the images array exists and has elements
    if (product.images.isEmpty || product.images[0].isEmpty) {
      return _buildPlaceholderImage();
    }

    // Original image URL
    String originalUrl = product.images[0];
    debugPrint('Original image URL: $originalUrl');

    // For Flutter Web: Use a CORS proxy service
    bool isWeb = identical(0, 0.0);
    String imageUrl = originalUrl;

    if (isWeb) {
      // Use a CORS proxy service
      imageUrl = 'https://corsproxy.io/?' + Uri.encodeComponent(originalUrl);
      debugPrint('Using proxied URL for web: $imageUrl');
    }

    // Using CachedNetworkImage for better performance and error handling
    return CachedNetworkImage(
      imageUrl: imageUrl,
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
        // When error, try with a different proxy as fallback
        if (isWeb && !url.contains('cors-anywhere')) {
          return _buildWebImageWithFallback(originalUrl);
        }
        return Container(
          height: 100,
          width: double.infinity,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(height: 4),
              Text(
                'Image Error',
                style: TextStyle(fontSize: 10, color: Colors.red[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebImageWithFallback(String originalUrl) {
    // Try a different CORS proxy as fallback
    String fallbackUrl = 'https://api.allorigins.win/raw?url=' + Uri.encodeComponent(originalUrl);
    debugPrint('Trying fallback URL: $fallbackUrl');

    return CachedNetworkImage(
      imageUrl: fallbackUrl,
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
        debugPrint('Fallback image also failed: $error');
        return _buildPlaceholderImage();
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