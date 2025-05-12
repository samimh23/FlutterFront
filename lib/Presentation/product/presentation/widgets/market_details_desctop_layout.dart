import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_description.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_header.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/products_grid.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/simplified_contact_info.dart';
import 'package:hanouty/app_colors.dart';

import '../../../../Core/theme/AppColors.dart';

class MarketDetailsDesktopLayout extends StatelessWidget {
  final String heroTag;
  final String marketName;
  final String marketEmail;
  final String marketPhone;
  final String marketLocation;
  final String imageUrl;
  final List<String> products;

  const MarketDetailsDesktopLayout({
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Market info
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarketHeader(
                  heroTag: heroTag,
                  marketName: marketName,
                  imageUrl: imageUrl,
                  isDesktop: true,
                ),
                const SizedBox(height: 24),
                // Market stats cards
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.star,
                      value: '2.2',
                      label: 'Rating',
                      iconColor: ClientColors.accent,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.delivery_dining,
                      value: '2.5',
                      label: 'Delivery',
                      iconColor: ClientColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.access_time,
                      value: '20 min',
                      label: 'Time',
                      iconColor: ClientColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                MarketDescription(
                  isDesktop: true,
                ),
                const SizedBox(height: 24),
                SimplifiedContactInfo(
                  marketName: marketName,
                  marketEmail: marketEmail,
                  marketPhone: marketPhone,
                  marketLocation: marketLocation,
                ),
                const SizedBox(height: 32),
                // Call-to-action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Contact action
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ClientColors.primary, // Updated button color
                          foregroundColor: ClientColors.onPrimary, // Updated text color
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Directions action
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ClientColors.primary, // Updated text color
                          side: BorderSide(color: ClientColors.primary), // Updated border color
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right side - Products
          Expanded(
            flex: 8,
            child: Card(
              elevation: 2, // Slightly reduced elevation for subtlety
              shadowColor: ClientColors.primary.withOpacity(0.1), // Updated shadow color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product header section with search and filters
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ClientColors.background.withOpacity(0.3), // Subtle header background
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Available Products",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ClientColors.text, // Updated text color
                              ),
                            ),
                            Container(
                              width: 240,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ClientColors.primary.withOpacity(0.2), // Updated border color
                                ),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  hintStyle: TextStyle(
                                    color: ClientColors.textLight, // Updated hint color
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: ClientColors.primary, // Updated icon color
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Category filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All', isSelected: true),
                              _buildFilterChip('Fruits'),
                              _buildFilterChip('Vegetables'),
                              _buildFilterChip('Dairy'),
                              _buildFilterChip('Bakery'),
                              _buildFilterChip('Meat'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Products grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ProductsGrid(
                        products: products,
                        crossAxisCount: 4,
                      ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ClientColors.primary.withOpacity(0.05), // Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ClientColors.text, // Updated text color
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: ClientColors.textLight, // Updated text color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // Filter selection logic
        },
        backgroundColor: Colors.white,
        selectedColor: ClientColors.primary.withOpacity(0.1), // Updated selection color
        labelStyle: TextStyle(
          color: isSelected ? ClientColors.primary : ClientColors.text, // Updated text colors
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected
              ? ClientColors.primary
              : ClientColors.textLight.withOpacity(0.3), // Updated border color
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}