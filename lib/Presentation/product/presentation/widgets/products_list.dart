import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ProductsList extends StatelessWidget {
  final List<String> products;

  const ProductsList({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final productId = products[index];
        return FutureBuilder<Product?>(
          future: Provider.of<ProductProvider>(context, listen: false)
              .fetchProductById(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox(
                width: 160,
                child: Center(child: Text('Failed to load product')),
              );
            } else {
              final product = snapshot.data!;
              final List<String> imageList = _extractImageList(product.image);
              final String? imageUrl = imageList.isNotEmpty ? imageList.first : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: _buildProductImage(context, imageUrl),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.originalPrice.toStringAsFixed(2)} DT",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  static List<String> _extractImageList(dynamic imageData) {
    if (imageData is String && imageData.isNotEmpty) {
      return [imageData];
    } else if (imageData is List) {
      return imageData.whereType<String>().toList();
    }
    return [];
  }

  Widget _buildProductImage(BuildContext context, String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return _buildPlaceholderImage();
  }

  // Concatenate with API base if image is just a path (e.g. '/uploads/image.jpg')
  final String imageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(imagePath)
        : ApiConstants.getFullImageUrl(imagePath);

  

  return CachedNetworkImage(
    imageUrl: imageUrl,
    width: 160,
    height: 120,
    fit: BoxFit.cover,
    placeholder: (context, url) => Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
    errorWidget: (context, url, error) {
      debugPrint('Image error: $error');
      return _buildPlaceholderImage();
    },
  );
}
  Widget _buildWebImageWithFallback(BuildContext context, String originalUrl) {
    final fallbackUrl =
        'https://api.allorigins.win/raw?url=' + Uri.encodeComponent(originalUrl);
    debugPrint('Trying fallback image URL: $fallbackUrl');

    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      width: 160,
      height: 120,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Fallback image failed: $error');
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 160,
      height: 120,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image, color: Colors.grey, size: 30),
          SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
