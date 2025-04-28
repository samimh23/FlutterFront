// lib/Presentation/order/presentation/Page/widgets/market_grid.dart

import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'market_card.dart';

class MarketGrid extends StatelessWidget {
  final List<Markets> markets;
  final int crossAxisCount;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isLargeScreen;
  final double horizontalPadding;
  final bool isDarkMode;
  final Color cardColor;
  final Map<String, int> marketOrderCounts;
  final Map<String, double> marketRevenue;
  final Function(Markets) onTap;

  const MarketGrid({
    Key? key,
    required this.markets,
    required this.crossAxisCount,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isLargeScreen,
    required this.horizontalPadding,
    required this.isDarkMode,
    required this.cardColor,
    required this.marketOrderCounts,
    required this.marketRevenue,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isSmallScreen ? 10 : 16,
          mainAxisSpacing: isSmallScreen ? 10 : 16,
          childAspectRatio: isMediumScreen ? 0.7 : (isLargeScreen ? 0.85 : 0.8),
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => MarketCard(
            market: markets[index],
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
            isDarkMode: isDarkMode,
            cardColor: cardColor,
            orderCount: marketOrderCounts[markets[index].id] ?? 0,
            revenue: marketRevenue[markets[index].id] ?? 0.0,
            onTap: () => onTap(markets[index]),
          ),
          childCount: markets.length,
        ),
      ),
    );
  }
}