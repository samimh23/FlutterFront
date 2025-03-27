import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_description.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_header.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/products_grid.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/simplified_contact_info.dart';
import 'package:hanouty/app_colors.dart';

class MarketDetailsDesktopLayout extends StatelessWidget {
  final String heroTag;
  final String marketName;
  final double rating;
  final String deliveryCost;
  final String marketEmail;
  final String deliveryTime;
  final String marketPhone;
  final String marketLocation;
  final String description;
  final String imageUrl;
  final List<Product> products;

  const MarketDetailsDesktopLayout({
    super.key,
    required this.heroTag,
    required this.marketName,
    required this.rating,
    required this.deliveryCost,
    required this.deliveryTime,
    required this.marketEmail,
    required this.description,
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
                  rating: rating,
                  deliveryCost: deliveryCost,
                  deliveryTime: deliveryTime,
                  imageUrl: imageUrl,
                  isDesktop: true,
                ),
                const SizedBox(height: 24),
                MarketDescription(
                  description: description,
                  isDesktop: true,
                ),
                const SizedBox(height: 24),
                SimplifiedContactInfo(
                  marketName: marketName,
                  marketEmail: marketEmail,
                  marketPhone: marketPhone,
                  marketLocation: marketLocation,
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right side - Products
          Expanded(
            flex: 8,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Available Products",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ProductsGrid(
                        products: products,
                        crossAxisCount: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
