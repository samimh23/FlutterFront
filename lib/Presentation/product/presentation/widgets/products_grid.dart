import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:hanouty/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Core/network/apiconastant.dart';

import '../../../../Core/theme/AppColors.dart';

class ProductsGrid extends StatelessWidget {
  final List<String> products; // Product IDs
  final int crossAxisCount;

  const ProductsGrid({
    super.key,
    required this.products,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(), // Smoother scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final productId = products[index];
        return FutureBuilder<Product?>(
          future: Provider.of<ProductProvider>(context, listen: false)
              .fetchProductById(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            } else if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorCard();
            } else {
              final product = snapshot.data!;
              return _buildProductCard(context, product);
            }
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
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
        elevation: 2, // Slightly reduced elevation
        shadowColor: ClientColors.primary.withOpacity(0.1), // Updated shadow color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: _buildProductImage(product.image),
                  ),
                ),
                // Product details
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ClientColors.text, // Updated text color
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "${product.originalPrice.toStringAsFixed(2)} DT",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ClientColors.primary, // Updated price color
                              ),
                            ),
                            if (product.isDiscounted && product.discountValue > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                "${(product.originalPrice + product.discountValue).toStringAsFixed(2)} DT",
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: ClientColors.textLight, // Updated strike-through color
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
            // Discount badge
            if (product.isDiscounted && product.discountValue > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ClientColors.accent, // Updated badge color
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ClientColors.accent.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '-${product.discountValue.toStringAsFixed(0)} DT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ClientColors.onAccent, // Updated text color
                    ),
                  ),
                ),
              ),
            // Stock badge (if out of stock)
            if (product.stock != null && product.stock! <= 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OUT OF STOCK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 1,
      shadowColor: ClientColors.primary.withOpacity(0.05), // Updated shadow color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer effect for image
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: ClientColors.background.withOpacity(0.3), // Updated placeholder color
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              width: double.infinity,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ClientColors.primary), // Updated loader color
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          // Shimmer effect for text
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ClientColors.background.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: ClientColors.background.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 1,
      shadowColor: ClientColors.primary.withOpacity(0.05), // Updated shadow color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: ClientColors.textLight, // Updated icon color
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 12,
              color: ClientColors.textLight, // Updated text color
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _buildPlaceholderImage();
    }

    final String imageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(imagePath)
        : ApiConstants.getFullImageUrl(imagePath);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: ClientColors.background.withOpacity(0.3), // Updated placeholder color
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ClientColors.primary), // Updated loader color
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: ClientColors.background.withOpacity(0.3), // Updated background color
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, color: ClientColors.textLight, size: 30), // Updated icon color
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 12, color: ClientColors.textLight), // Updated text color
          ),
        ],
      ),
    );
  }
}