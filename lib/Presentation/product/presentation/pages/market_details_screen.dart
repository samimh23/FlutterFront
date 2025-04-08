import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_details_desctop_layout.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_details_mobile_tablet_layout.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/responsive/responsive_layout.dart';

class MarketDetailsScreen extends StatelessWidget {
  final String heroTag;
  final String marketName;
  final String marketLocation;
  final String marketPhone;
  final String marketEmail;

  final String imageUrl;
  final List<String> products;

  const MarketDetailsScreen({
    super.key,
    required this.heroTag,
    required this.marketName,
    required this.marketLocation,
    required this.marketPhone,
    required this.marketEmail,

    required this.imageUrl,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          marketName,
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isDesktop
          ? MarketDetailsDesktopLayout(
              marketEmail: marketEmail,
              marketPhone: marketPhone, // Add appropriate phone
              marketLocation: marketLocation, // Add appropriate location
              heroTag: heroTag,
              marketName: marketName,

              imageUrl: imageUrl,
              products: products,
            )
          : MarketDetailsMobileTabletLayout(
              marketEmail: marketEmail, // Add appropriate email
              marketPhone: marketPhone, // Add appropriate phone
              marketLocation: marketLocation, // Add appropriate location
              heroTag: heroTag,
              marketName: marketName,

              imageUrl: imageUrl,
              products: products,
            ),
    );
  }
}