import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/market_details_screen.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/categories_section.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/header.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/product_card.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/shop_card.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/responsive/responsive_layout.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NormalMarketProvider _normalMarketProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _normalMarketProvider =
          Provider.of<NormalMarketProvider>(context, listen: false);
      _normalMarketProvider.loadMarkets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Only show app bar on desktop if we're using the side navigation
      appBar: isDesktop
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              title: const Text(
                'El Hanout',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                Container(
                  width: 240,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle:
                          TextStyle(color: Colors.grey[600], fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey[600], size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined,
                      color: AppColors.black),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
              ],
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = isDesktop ? 64.0 : 16.0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only show animated header on mobile/tablet
                if (!isDesktop) ...[
                  const AnimatedHeader(),
                  const SizedBox(height: 24),
                ],

                // Search bar - only show on mobile/tablet (desktop has it in app bar)
                if (!isDesktop)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey[600], size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                        onChanged: (value) {
                          // Handle search logic here
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Categories section with title

                const SizedBox(height: 12),
                const CategoriesSection(),

                // Featured banner

                // Products section with title and see all button
                Padding(
                  padding: EdgeInsets.only(left: 24.0, top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Products of the Month',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle see all products
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'See All',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Products section
                _buildProductsSection(context),
                const SizedBox(height: 32),

                // Stores section
                _buildStoresSection(context),

                // Extra space at bottom for navigation bar
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          );
        }

        if (provider.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage,
                    style: TextStyle(color: Colors.red[400], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchProducts(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.shopping_basket_outlined,
                      color: Colors.grey[400], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No products available at the moment.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Use ResponsiveLayout builder for different layouts
        return ResponsiveLayout.builder(
          context: context,
          // Mobile layout - horizontal scrolling list with improved cards
          mobile: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildEnhancedProductCard(provider.products[index]),
                );
              },
            ),
          ),
          // Tablet layout - 2 column grid with larger cards
          tablet: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount:
                  provider.products.length > 6 ? 6 : provider.products.length,
              itemBuilder: (context, index) {
                return _buildEnhancedProductCard(provider.products[index]);
              },
            ),
          ),
          // Desktop layout - 4 column grid with animation effects
          desktop: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.75,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount:
                  provider.products.length > 8 ? 8 : provider.products.length,
              itemBuilder: (context, index) {
                // Add a subtle animation delay based on index
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 1.0,
                  curve: Curves.easeInOut,
                  child: _buildEnhancedProductCard(provider.products[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // This is a placeholder - you would need to modify your ProductCard or create a new enhanced version
  Widget _buildEnhancedProductCard(dynamic product) {
    // For now, we'll just use the existing ProductCard
    return ProductCard(product: product);
  }

  Widget _buildStoresSection(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.isDesktop(context) ? 64.0 : 16.0;
    final storeHeight = ResponsiveLayout.isDesktop(context) ? 200.0 : 180.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Popular Stores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all stores page
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Replace static store list with Consumer for ShopProvider
          Consumer<NormalMarketProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                );
              }

              if (provider.errorMessage.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[400], size: 48),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage,
                          style:
                              TextStyle(color: Colors.red[400], fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadMarkets(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.markets.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined,
                            color: Colors.grey[400], size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'No stores available at the moment.',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Use ResponsiveLayout builder for different layouts
              return ResponsiveLayout.builder(
                context: context,
                // Mobile layout - horizontal scrolling list
                mobile: SizedBox(
                  height: storeHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.markets.length > 3
                        ? 3
                        : provider.markets.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildStoreCard(provider.markets[index]),
                      );
                    },
                  ),
                ),
                // Tablet layout - 2 column grid
                tablet: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount:
                      provider.markets.length > 4 ? 4 : provider.markets.length,
                  itemBuilder: (context, index) {
                    return _buildStoreCard(provider.markets[index]);
                  },
                ),
                // Desktop layout - 3 column grid
                desktop: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount:
                      provider.markets.length > 6 ? 6 : provider.markets.length,
                  itemBuilder: (context, index) {
                    return _buildStoreCard(provider.markets[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(dynamic market) {
    // Extract shop data from the shop object
    final String name = market.marketName ?? 'Unknown Shop';
    final double rating = market.rating ?? 4.5;
    final String marketLocation = market.marketLocation ?? 'Unknown Location';
    final String marketPhone = market.marketPhone ?? 'Unknown Phone';
    final String marketEmail = market.marketEmail ?? 'Unknown Email';
    final String deliveryCost = market.deliveryCost ?? 'Free';
    final String deliveryTime = market.deliveryTime ?? '15-20 min';
    final String? imagePath = market.marketImage;
    final String imageUrl = 'http://localhost:3000/$imagePath';
    final List<String> products =
        market.products; // Assuming products is a list
    print(products);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarketDetailsScreen(
              heroTag: 'market_${market.id}',
              marketName: name,
              rating: rating,
              deliveryCost: deliveryCost,
              marketLocation: marketLocation,
              marketPhone: marketPhone,
              marketEmail: marketEmail,
              deliveryTime: deliveryTime,
              description: market.description ??
                  'A great local market offering fresh products',
              imageUrl: imageUrl,
              products: products, // Pass the actual products list
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Store image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.store, size: 40, color: Colors.grey[500]),
                  );
                },
              ),
            ),

            // Store details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Store name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              // Removed 'const' keyword
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Delivery info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Delivery: $deliveryCost',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          deliveryTime,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}
