import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_description.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/products_grid.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/products_list.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/simplified_contact_info.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/responsive/responsive_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../Core/theme/AppColors.dart';

class MarketDetailsMobileTabletLayout extends StatelessWidget {
  final String heroTag;
  final String marketName;
  final String marketEmail;
  final String marketPhone;
  final String marketLocation;
  final String imageUrl;
  final List<String> products;

  const MarketDetailsMobileTabletLayout({
    super.key,
    required this.heroTag,
    required this.marketName,
    required this.marketEmail,
    required this.marketPhone,
    required this.marketLocation,
    required this.imageUrl,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final padding = isTablet ? 20.0 : 16.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Smoother scrolling experience
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Image with hero animation
          Hero(
            tag: heroTag,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: isTablet ? 250 : 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: ClientColors.background.withOpacity(0.3), // Updated placeholder color
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ClientColors.primary), // Updated loader color
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: ClientColors.background.withOpacity(0.3), // Updated error background color
                      child: Center(
                        child: Icon(Icons.error, size: 50, color: ClientColors.textLight), // Updated error icon color
                      ),
                    ),
                  ),
                ),
                // Add subtle gradient overlay at bottom for better text readability if shown over image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Market name and rating
                Text(
                  marketName,
                  style: TextStyle(
                    fontSize: isTablet ? 24.0 : 22.0,
                    fontWeight: FontWeight.bold,
                    color: ClientColors.text, // Updated text color
                  ),
                ),
                const SizedBox(height: 8),

                // Rating and delivery info
                Row(
                  children: [
                    Icon(Icons.star, color: ClientColors.accent, size: 20), // Updated star color
                    const SizedBox(width: 4),
                    Text(
                      '2.2',
                      style: TextStyle(
                        fontSize: 16,
                        color: ClientColors.accent, // Updated rating color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.delivery_dining, color: ClientColors.primary, size: 20), // Updated delivery icon color
                    const SizedBox(width: 4),
                    Text(
                      '2.5',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ClientColors.primary, // Using primary client color
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, color: ClientColors.textLight, size: 20), // Updated clock icon color
                    const SizedBox(width: 4),
                    Text(
                      '20 min',
                      style: TextStyle(
                        fontSize: 16,
                        color: ClientColors.textLight, // Updated text color
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20), // Slightly increased spacing

                // Category tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Fruits & Vegetables'),
                      _buildCategoryChip('Groceries'),
                      _buildCategoryChip('Local Market'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // About section
                MarketDescription(
                  isDesktop: false,
                ),

                const SizedBox(height: 24),

                // Contact information
                SimplifiedContactInfo(marketName: marketName, marketEmail: marketEmail, marketPhone: marketPhone, marketLocation: marketLocation),

                const SizedBox(height: 24),

                // Available Products section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Available Products",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ClientColors.text, // Updated text color
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // View all products action
                      },
                      icon: Icon(Icons.grid_view, size: 18, color: ClientColors.primary),
                      label: Text(
                        'View All',
                        style: TextStyle(color: ClientColors.primary),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Products list for mobile/tablet
                isTablet
                    ? SizedBox(
                  height: 400,
                  child: ProductsGrid(
                    products: products,
                    crossAxisCount: 3,
                  ),
                )
                    : SizedBox(
                  height: 220,
                  child: ProductsList(products: products),
                ),
              ],
            ),
          ),

          // Adding a contact action button at the bottom
          Padding(
            padding: EdgeInsets.all(padding),
            child: ElevatedButton.icon(
              onPressed: () {
                // Contact market action
              },
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Contact Market'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ClientColors.primary, // Updated button color
                foregroundColor: ClientColors.onPrimary, // Updated text color
                minimumSize: const Size(double.infinity, 48), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ClientColors.primary.withOpacity(0.1), // Subtle background color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ClientColors.primary.withOpacity(0.2), // Subtle border
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ClientColors.primary, // Primary color for text
        ),
      ),
    );
  }
}