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
    final imageHeight = isDesktop ? 160.0 : (isTablet ? 130.0 : 110.0);
    final horizontalPadding = isDesktop ? 14.0 : (isTablet ? 10.0 : 10.0);

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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.11),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image + Discount badge + Stock badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius)),
                      child: _buildProductImage(imageHeight),
                    ),
                    // Discount badge
                    if (product.isDiscounted && product.discountValue > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.18),
                                blurRadius: 6,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '-${product.discountValue.toStringAsFixed(0)} DT',
                            style: const TextStyle(
                              color: Colors.white,
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: product.stock! > 0
                                ? Colors.green.withOpacity(0.95)
                                : Colors.red.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (product.stock! > 0
                                    ? Colors.green
                                    : Colors.red)
                                    .withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            product.stock! > 0 ? 'In Stock' : 'Out of Stock',
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.05,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Price Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2),
                  child: product.isDiscounted && product.discountValue > 0
                      ? Row(
                    children: [
                      Text(
                        '${product.originalPrice} DT',
                        style: TextStyle(
                          fontSize: priceFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(product.originalPrice + product.discountValue).toStringAsFixed(0)} DT',
                        style: TextStyle(
                          fontSize: discountFontSize,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    '${product.originalPrice} DT',
                    style: TextStyle(
                      fontSize: priceFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                // Shop name and review row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.storefront_rounded, color: Colors.deepOrange, size: 14),
                      const SizedBox(width: 3),
                      Expanded(
                        child: FutureBuilder<NormalMarket?>(
                          future: Provider.of<NormalMarketProvider>(context, listen: false)
                              .getNormalMarketById(product.shop),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 12,
                                width: 35,
                                child: LinearProgressIndicator(
                                  minHeight: 2,
                                  backgroundColor: Colors.transparent,
                                ),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                              return const Text(
                                'Unknown',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              );
                            }
                            return Text(
                              snapshot.data!.marketName ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.deepOrange[700],
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            );
                          },
                        ),
                      ),
                      // Reviews
                      if (product.ratingsQuantity != null && product.ratingsAverage != null)
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(Icons.star, color: Colors.amber, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              product.ratingsAverage!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              ' (${product.ratingsQuantity})',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Remove stock badge from here, now shown in badge corner
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2),
                  child: Row(
                    children: [
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
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
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
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
          child: _buildPlaceholderImage(height, isError: true),
        );
      },
    );
  }

  Widget _buildPlaceholderImage(double height, {bool isError = false}) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image : Icons.image,
            color: Colors.grey[400],
            size: 28,
          ),
          const SizedBox(height: 5),
          Text(
            isError ? 'Image not found' : 'No Image',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (isError)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Tap for details',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}