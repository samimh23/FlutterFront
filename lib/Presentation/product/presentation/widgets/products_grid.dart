import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:hanouty/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';

class ProductsGrid extends StatelessWidget {
  final List<String> products; // Updated to List<String>
  final int crossAxisCount;

  const ProductsGrid({
    super.key,
    required this.products,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final productId = products[index]; // Treat each item as a product ID
        return FutureBuilder<Product?>(
          future: Provider.of<ProductProvider>(context, listen: false)
              .fetchProductById(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                child: Text('Failed to load product data'),
              );
            } else {
              final product = snapshot.data!;
              final List<String> images =
                  product.images is List<String> ? product.images : [];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: _buildProductImage(context, images),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "${product.originalPrice.toStringAsFixed(2)} DT",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (product.isDiscounted &&
                                      product.discountValue > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      "${(product.originalPrice + product.discountValue).toStringAsFixed(2)} DT",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildProductImage(BuildContext context, List<String> images) {
    // Check if the images array exists and has elements
    if (images.isEmpty || images[0].isEmpty) {
      return _buildPlaceholderImage(context);
    }

    // Original image URL
    String originalUrl = images[0];
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
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Error loading image: $error');
        // When error, try with a different proxy as fallback
        if (kIsWeb && !url.contains('cors-anywhere')) {
          return _buildWebImageWithFallback(context, originalUrl);
        }
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 30),
              const SizedBox(height: 4),
              Text(
                'Image Error',
                style: TextStyle(fontSize: 12, color: Colors.red[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebImageWithFallback(BuildContext context, String originalUrl) {
    // Try a different CORS proxy as fallback
    String fallbackUrl = 'https://api.allorigins.win/raw?url=' +
        Uri.encodeComponent(originalUrl);
    debugPrint('Trying fallback URL: $fallbackUrl');

    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Fallback image also failed: $error');
        return _buildPlaceholderImage(context);
      },
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, color: Colors.grey, size: 30),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
