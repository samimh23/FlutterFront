
import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/presentation/pages/market_details_screen.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/categories_section.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/header.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/product_card.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/shop_card.dart';
import 'package:hanouty/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AnimatedHeader(),
            const SizedBox(height: 20),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: AppColors.black),
                  prefixIcon: const Icon(Icons.search, color: AppColors.white),
                  filled: true,
                  fillColor: AppColors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
                onChanged: (value) {
                  // Handle search logic here
                },
              ),
            ),

            const SizedBox(height: 20),
            CategoriesSection(),
            const SizedBox(height: 25),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Products of the Month',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),

            // Your product list (no Expanded)
            _buildBody(context),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Open Stores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle see all restaurants
                        },
                        child: Row(
                          children: const [
                            Text(
                              'See All ',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ShopCard(
                          heroTag: 'aziza_market_1',
                          name: 'AZIZA Market',
                          categories: 'Vegetable - Chicken - Sweets',
                          rating: 4.7,
                          deliveryCost: 'Free',
                          deliveryTime: '20 min',
                          imageUrl: 'https://play-lh.googleusercontent.com/Z40dsT2XLSLnC-hMZB1CYXiHVy2eWBJnibc_k0bbzpQJ5EDY1abD-SEUUSHnmg6Zk3o',
                          onTap: () {
                            final productProvider = Provider.of<ProductProvider>(context, listen: false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MarketDetailsScreen(
                                      heroTag: 'aziza_market_1',
                                      marketName: 'AZIZA Market',
                                      rating: 4.7,
                                      deliveryCost: 'Free',
                                      deliveryTime: '20 min',
                                      description:
                                          'Premium market with fresh products...',
                                      imageUrl:
                                          'https://play-lh.googleusercontent.com/Z40dsT2XLSLnC-hMZB1CYXiHVy2eWBJnibc_k0bbzpQJ5EDY1abD-SEUUSHnmg6Zk3o',
                                      products: productProvider.products,
                                    ),
                              ),
                            );
                          },
                        ),
                        ShopCard(
                          heroTag: 'Carrefour',
                          name: 'Carrefour Market',
                          categories: 'Vegetable - Chicken - Sweets',
                          rating: 4.7,
                          deliveryCost: 'fees',
                          deliveryTime: '20 min',
                          imageUrl: 'https://play-lh.googleusercontent.com/Z40dsT2XLSLnC-hMZB1CYXiHVy2eWBJnibc_k0bbzpQJ5EDY1abD-SEUUSHnmg6Zk3o',
                          onTap: () {
                            final productProvider = Provider.of<ProductProvider>(context, listen: false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MarketDetailsScreen(
                                      heroTag: 'Carrefour',
                                      marketName: 'AZIZA Market',
                                      rating: 4.7,
                                      deliveryCost: 'fees',
                                      deliveryTime: '20 min',
                                      description:
                                          'Premium market with fresh products...',
                                      imageUrl:
                                          'https://play-lh.googleusercontent.com/Z40dsT2XLSLnC-hMZB1CYXiHVy2eWBJnibc_k0bbzpQJ5EDY1abD-SEUUSHnmg6Zk3o',
                                    products: productProvider.products,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                provider.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (provider.products.isEmpty) {
            return const Center(
              child: Text(
                'No products available.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          return SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ProductCard(product: provider.products[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
