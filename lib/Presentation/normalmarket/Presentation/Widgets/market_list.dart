// lib/Presentation/order/presentation/Page/widgets/market_list.dart

import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/MarketListItem.dart';

class MarketList extends StatelessWidget {
  final List<Markets> markets;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final double horizontalPadding;
  final bool isDarkMode;
  final Color cardColor;
  final Map<String, int> marketOrderCounts;
  final Map<String, double> marketRevenue;
  final Function(Markets) onTap;

  const MarketList({
    Key? key,
    required this.markets,
    required this.isSmallScreen,
    required this.isMediumScreen,
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
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 16),
            child: MarketListItem(
              market: markets[index],
              isSmallScreen: isSmallScreen,
              isMediumScreen: isMediumScreen,
              isDarkMode: isDarkMode,
              cardColor: cardColor,
              orderCount: marketOrderCounts[markets[index].id] ?? 0,
              revenue: marketRevenue[markets[index].id] ?? 0.0,
              onTap: () => onTap(markets[index]),
            ),
          ),
          childCount: markets.length,
        ),
      ),
    );
  }
}