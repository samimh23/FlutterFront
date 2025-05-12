import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_details_desctop_layout.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/market_details_mobile_tablet_layout.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/responsive/responsive_layout.dart';

import '../../../../Core/theme/AppColors.dart';

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
      backgroundColor: ClientColors.background, // Updated background color
      appBar: AppBar(
        title: Text(
          marketName,
          style: TextStyle(
            color: ClientColors.text, // Updated text color
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          ),
        ),
        backgroundColor: Colors.white, // Clean white app bar
        elevation: 0.5, // Subtle elevation
        shadowColor: ClientColors.primary.withOpacity(0.1), // Subtle shadow with primary color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ClientColors.primary), // Updated icon color
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: ClientColors.primary), // Updated icon color
            onPressed: () {},
          ),
        ],
      ),
      body: isDesktop
          ? MarketDetailsDesktopLayout(
        marketEmail: marketEmail,
        marketPhone: marketPhone,
        marketLocation: marketLocation,
        heroTag: heroTag,
        marketName: marketName,
        imageUrl: imageUrl,
        products: products,
      )
          : MarketDetailsMobileTabletLayout(
        marketEmail: marketEmail,
        marketPhone: marketPhone,
        marketLocation: marketLocation,
        heroTag: heroTag,
        marketName: marketName,
        imageUrl: imageUrl,
        products: products,
      ),
    );
  }
}