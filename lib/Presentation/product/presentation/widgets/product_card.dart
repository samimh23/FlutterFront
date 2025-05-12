import 'package:flutter/material.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/responsive/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'package:hanouty/app_colors.dart';

import '../../../../Core/theme/AppColors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Responsive adjustments
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final cardWidth = isDesktop ? 240.0 : (isTablet ? 180.0 : 160.0);
    final borderRadius = isDesktop ? 16.0 : 14.0;
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final priceFontSize = isDesktop ? 15.0 : (isTablet ? 14.0 : 13.0);
    final discountFontSize = isDesktop ? 13.0 : (isTablet ? 12.0 : 11.0);
    // Reduce image height and paddings to reduce card height
    final imageHeight = isDesktop ? 105.0 : (isTablet ? 90.0 : 80.0);
    final horizontalPadding = isDesktop ? 12.0 : (isTablet ? 8.0 : 8.0);

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
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: ClientColors.primary.withOpacity(0.08), // Updated shadow color
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: ClientColors.background.withOpacity(0.5), // Updated border color
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Discount badge + Stock badge
              Stack(
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius)),
                      child: _buildProductImage(imageHeight),
                    ),
                  ),
                  // Discount badge
                  if (product.isDiscounted && product.discountValue > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ClientColors.accent, // Updated accent color
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: ClientColors.accent.withOpacity(0.18), // Updated shadow color
                              blurRadius: 6,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-${product.discountValue.toStringAsFixed(0)} DT',
                          style: const TextStyle(
                            color: ClientColors.onAccent, // Updated text color
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  // Stock badge (corner)
                  if (product.stock != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? ClientColors.secondary.withOpacity(0.95) // Updated in-stock color
                              : Colors.red.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (product.stock > 0
                                  ? ClientColors.secondary
                                  : Colors.red)
                                  .withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          product.stock > 0 ? 'In Stock' : 'Out of Stock',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Product name
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 2),
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: ClientColors.text, // Updated text color
                    letterSpacing: 0.05,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Price Row
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 0),
                child: product.isDiscounted && product.discountValue > 0
                    ? Row(
                  children: [
                    Text(
                      '${product.originalPrice} DT',
                      style: TextStyle(
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.bold,
                        color: ClientColors.primary, // Updated price color
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(product.originalPrice + product.discountValue).toStringAsFixed(0)} DT',
                      style: TextStyle(
                        fontSize: discountFontSize,
                        decoration: TextDecoration.lineThrough,
                        color: ClientColors.textLight, // Updated strike-through color
                      ),
                    ),
                  ],
                )
                    : Text(
                  '${product.originalPrice} DT',
                  style: TextStyle(
                    fontSize: priceFontSize,
                    fontWeight: FontWeight.bold,
                    color: ClientColors.primary, // Updated price color
                  ),
                ),
              ),
              // Shop name and review row
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 1),
                child: Row(
                  children: [
                    Icon(Icons.storefront_rounded,
                        color: ClientColors.primary, size: 14), // Updated icon color
                    const SizedBox(width: 3),
                    Expanded(
                      child: FutureBuilder<NormalMarket?>(
                        future: Provider.of<NormalMarketProvider>(context,
                            listen: false)
                            .getNormalMarketById(product.shop),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 10,
                              width: 30,
                              child: LinearProgressIndicator(
                                minHeight: 2,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ClientColors.secondary, // Updated progress indicator color
                                ),
                              ),
                            );
                          }
                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data == null) {
                            return Text(
                              'Unknown',
                              style: TextStyle(
                                fontSize: 10,
                                color: ClientColors.primary, // Updated text color
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            );
                          }
                          return Text(
                            snapshot.data!.marketName ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              color: ClientColors.primary, // Updated text color
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          );
                        },
                      ),
                    ),
                    // Reviews
                    if (product.ratingsQuantity != null &&
                        product.ratingsAverage != null)
                      Row(
                        children: [
                          const SizedBox(width: 6),
                          Icon(Icons.star, color: ClientColors.accent, size: 12), // Updated star color
                          const SizedBox(width: 1),
                          Text(
                            product.ratingsAverage!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ClientColors.text, // Updated text color
                            ),
                          ),
                          Text(
                            ' (${product.ratingsQuantity})',
                            style: TextStyle(
                              fontSize: 9,
                              color: ClientColors.textLight, // Updated text color
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
      ),
    );
  }

  Widget _buildProductImage(double height) {
    if (product.image == null || product.image!.isEmpty) {
      return _buildPlaceholderImage(height);
    }
    final String fullImageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(product.image!)
        : ApiConstants.getFullImageUrl(product.image!);

    debugPrint('Loading product image: $fullImageUrl');

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: height,
        width: double.infinity,
        color: ClientColors.background.withOpacity(0.5), // Updated placeholder color
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(ClientColors.primary), // Updated progress indicator color
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Error loading image: $error');
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Image Error'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Failed to load image:'),
                      const SizedBox(height: 8),
                      Text(fullImageUrl, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 8),
                      Text('Original path: ${product.image}',
                          style: const TextStyle(fontSize: 12)),
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
                    child: Text('Close', style: TextStyle(color: ClientColors.primary)), // Updated button text color
                  ),
                ],
              ),
            );
          },
          child: _buildPlaceholderImage(height, isError: true),
        );
      },
    );
  }

  Widget _buildPlaceholderImage(double height, {bool isError = false}) {
    return Container(
      height: height,
      width: double.infinity,
      color: ClientColors.background.withOpacity(0.3), // Updated background color
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image : Icons.image,
            color: ClientColors.textLight, // Updated icon color
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            isError ? 'Image not found' : 'No Image',
            style: TextStyle(fontSize: 10, color: ClientColors.textLight), // Updated text color
          ),
          if (isError)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Tap for details',
                style: TextStyle(fontSize: 8.5, color: ClientColors.textLight), // Updated text color
              ),
            ),
        ],
      ),
    );
  }
}