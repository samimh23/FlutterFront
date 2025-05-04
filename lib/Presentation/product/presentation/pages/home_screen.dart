  import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/market_details_screen.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/categories_section.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/header.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/product_card.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/responsive/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../Core/Utils/Api_EndPoints.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NormalMarketProvider _normalMarketProvider;
  bool _isShimmer = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _normalMarketProvider =
          Provider.of<NormalMarketProvider>(context, listen: false);
      _normalMarketProvider.loadMarkets();
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isShimmer = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                  child: _isShimmer
                      ? _buildShimmerBox(height: 40, width: 220)
                      : TextField(
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle:
                                TextStyle(color: Colors.grey[600], fontSize: 14),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey[600], size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
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
                if (!isDesktop) ...[
                  _isShimmer
                      ? _buildShimmerBox(height: 60, width: double.infinity)
                      : const AnimatedHeader(),
                  const SizedBox(height: 24),
                ],
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
                      child: _isShimmer
                          ? _buildShimmerBox(height: 45, width: double.infinity)
                          : TextField(
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
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
                _isShimmer
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildShimmerBox(height: 35, width: 200),
                      )
                    : const SizedBox(height: 12),
                _isShimmer
                    ? _buildShimmerBox(height: 40, width: double.infinity)
                    : const CategoriesSection(),
                Padding(
                  padding: EdgeInsets.only(left: 24.0, top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _isShimmer
                          ? _buildShimmerBox(height: 28, width: 180)
                          : const Text(
                              'Products of the Month',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                      _isShimmer
                          ? _buildShimmerBox(height: 24, width: 70)
                          : TextButton(
                              onPressed: () {
                                // Handle see all products
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(width: 4),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _isShimmer
                    ? _buildShimmerProductList(isDesktop)
                    : _buildProductsSection(context),
                const SizedBox(height: 32),
                _isShimmer
                    ? _buildShimmerStoreSection(isDesktop)
                    : _buildStoresSection(context),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerBox({double height = 20, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildShimmerProductList(bool isDesktop) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isDesktop
          ? Padding(
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
                itemCount: 4,
                itemBuilder: (context, index) =>
                    _buildShimmerBox(height: 240, width: 200),
              ),
            )
          : SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildShimmerBox(height: 200, width: 140),
                ),
              ),
            ),
    );
  }

  Widget _buildShimmerStoreSection(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 16.0,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: _buildShimmerBox(height: 28, width: 180),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: isDesktop
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) =>
                        _buildShimmerBox(height: 140, width: 260),
                  )
                : SizedBox(
                    height: isDesktop ? 200.0 : 180.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildShimmerBox(
                            height: isDesktop ? 200 : 180, width: 200),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildShimmerProductList(ResponsiveLayout.isDesktop(context));
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

        return ResponsiveLayout.builder(
          context: context,
          mobile: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ProductCard(product: provider.products[index]),
                );
              },
            ),
          ),
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
                return ProductCard(product: provider.products[index]);
              },
            ),
          ),
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
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 1.0,
                  curve: Curves.easeInOut,
                  child: ProductCard(product: provider.products[index]),
                );
              },
            ),
          ),
        );
      },
    );
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
                child: const Row(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<NormalMarketProvider>(
            builder: (context, provider, child) {
              if (_isShimmer || provider.isLoading) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: SizedBox(
                    height: storeHeight,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildShimmerBox(
                            height: storeHeight, width: 200),
                      ),
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

              return ResponsiveLayout.builder(
                context: context,
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
                      provider.markets.length ,
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
    final String name = market.marketName ?? 'Unknown Shop';
    final String marketLocation = market.marketLocation ?? 'Unknown Location';
    final String marketPhone = market.marketPhone ?? 'Unknown Phone';
    final String marketEmail = market.marketEmail ?? 'Unknown Email';
    final String? imagePath = market.marketImage;
    final String imageUrl = '${ApiEndpoints.baseUrl}/$imagePath';
    final List<String> products = market.products;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarketDetailsScreen(
              heroTag: 'market_${market.id}',
              marketName: name,
              marketLocation: marketLocation,
              marketPhone: marketPhone,
              marketEmail: marketEmail,
              imageUrl: imageUrl,
              products: products,
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                            '2.1',
                            style: const TextStyle(
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
                          '2.5',
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
                          '20 min',
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