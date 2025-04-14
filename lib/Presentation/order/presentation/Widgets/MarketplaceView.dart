// lib/Presentation/order/presentation/Page/widgets/marketplace_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/FilterChipWidget.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/MarketGrid.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/NoResultsView.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/SearchBarWidget.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/SliverAppBarDelegate.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/StatsRow.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/ViewToggleButton.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/market_list.dart';



class MarketplaceView extends StatelessWidget {
  final NormalMarketProvider provider;
  final List<Markets> markets;
  final Size screenSize;
  final int crossAxisCount;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isLargeScreen;
  final bool isWebPlatform;
  final bool isDarkMode;
  final bool isGridView;
  final TextEditingController searchController;
  final String searchQuery;
  final bool isSearching;
  final String? filterCategory;
  final Map<String, int> marketOrderCounts;
  final Map<String, double> marketRevenue;
  final ScrollController scrollController;
  final Function(bool) onUpdateGridView;
  final Function(String) onUpdateSearch;
  final VoidCallback onClearSearch;
  final Function(String?) onUpdateFilter;
  final VoidCallback onShowSortDialog;
  final Function(String) onSortMarkets;
  final Future<void> Function() onRefresh;
  final Function(Markets) onNavigateToMarket;

  const MarketplaceView({
    Key? key,
    required this.provider,
    required this.markets,
    required this.screenSize,
    required this.crossAxisCount,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isLargeScreen,
    required this.isWebPlatform,
    required this.isDarkMode,
    required this.isGridView,
    required this.searchController,
    required this.searchQuery,
    required this.isSearching,
    required this.filterCategory,
    required this.marketOrderCounts,
    required this.marketRevenue,
    required this.scrollController,
    required this.onUpdateGridView,
    required this.onUpdateSearch,
    required this.onClearSearch,
    required this.onUpdateFilter,
    required this.onShowSortDialog,
    required this.onSortMarkets,
    required this.onRefresh,
    required this.onNavigateToMarket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketsCount = provider.myMarkets.length;
    final filteredCount = markets.length;

    // Calculate total orders and revenue
    int totalOrders = 0;
    double totalRevenue = 0.0;

    marketOrderCounts.forEach((key, value) {
      totalOrders += value;
    });

    marketRevenue.forEach((key, value) {
      totalRevenue += value;
    });

    // Determine horizontal padding based on screen size
    final horizontalPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 16.0
        : 24.0;

    // Color theme adjustments based on dark mode
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final dividerColor = isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2);
    final backgroundOverlayOpacity = isDarkMode ? 0.03 : 0.05;
    final searchBgColor = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final searchBorderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final hintTextColor = isDarkMode ? Colors.grey.shade500 : const Color(0xFFAAAAAA);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F7F3),
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: backgroundOverlayOpacity,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: RefreshIndicator(
        color: accentColor,
        backgroundColor: cardColor,
        strokeWidth: 3,
        onRefresh: onRefresh,
        child: Scrollbar(
          controller: scrollController,
          thickness: isWebPlatform ? 10.0 : 6.0,
          radius: const Radius.circular(8.0),
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  minHeight: isSmallScreen ? 60 : 70,
                  maxHeight: isSmallScreen ? 60 : 70,
                  child: Container(
                    color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F7F3),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Market Orders',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (filteredCount != marketsCount)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Filtered: $filteredCount',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                  child: SearchBarWidget(
                    isSmallScreen: isSmallScreen,
                    isDarkMode: isDarkMode,
                    bgColor: searchBgColor,
                    borderColor: searchBorderColor,
                    hintColor: hintTextColor,
                    accentColor: accentColor,
                    isSearching: isSearching,
                    searchController: searchController,
                    onChanged: onUpdateSearch,
                    onClear: onClearSearch,
                  ),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, isSmallScreen ? 16 : 24),
                  child: StatsRow(
                    totalOrders: totalOrders,
                    marketsCount: markets.length,
                    totalRevenue: totalRevenue,
                    isSmallScreen: isSmallScreen,
                    isDarkMode: isDarkMode,
                    cardColor: cardColor,
                    accentColor: accentColor,
                    dividerColor: dividerColor,
                  ),
                ),
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, isSmallScreen ? 12 : 16),
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChipWidget(
                        label: 'All Markets',
                        isSelected: filterCategory == null,
                        onTap: () => onUpdateFilter(null),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: 'With Orders',
                        isSelected: filterCategory == 'with-orders',
                        onTap: () => onUpdateFilter('with-orders'),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: 'No Orders',
                        isSelected: filterCategory == 'no-orders',
                        onTap: () => onUpdateFilter('no-orders'),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),

              // View Toggle and Count
              SliverToBoxAdapter(
                child: _buildViewControlsHeader(horizontalPadding, accentColor, cardColor),
              ),

              // Market Items or Empty State
              markets.isEmpty
                  ? SliverToBoxAdapter(
                child: NoResultsView(
                  isSmallScreen: isSmallScreen,
                  isDarkMode: isDarkMode,
                  cardColor: cardColor,
                  onClearFilters: () {
                    onUpdateFilter(null);
                    onClearSearch();
                  },
                ),
              )
                  : isGridView && !isSmallScreen
                  ? MarketGrid(
                markets: markets,
                crossAxisCount: crossAxisCount,
                isSmallScreen: isSmallScreen,
                isMediumScreen: isMediumScreen,
                isLargeScreen: isLargeScreen,
                horizontalPadding: horizontalPadding,
                isDarkMode: isDarkMode,
                cardColor: cardColor,
                marketOrderCounts: marketOrderCounts,
                marketRevenue: marketRevenue,
                onTap: onNavigateToMarket,
              )
                  : MarketList(
                markets: markets,
                isSmallScreen: isSmallScreen,
                isMediumScreen: isMediumScreen,
                horizontalPadding: horizontalPadding,
                isDarkMode: isDarkMode,
                cardColor: cardColor,
                marketOrderCounts: marketOrderCounts,
                marketRevenue: marketRevenue,
                onTap: onNavigateToMarket,
              ),

              // Bottom Padding
              SliverToBoxAdapter(
                child: SizedBox(height: isSmallScreen ? 80 : 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewControlsHeader(double horizontalPadding, Color accentColor, Color cardColor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, isSmallScreen ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            markets.isEmpty
                ? 'No markets found'
                : markets.length == 1
                ? '1 Market'
                : '${markets.length} Markets',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF2E7D32),
            ),
          ),
          Row(
            children: [
              // View Toggle - hide on very small screens
              if (!isSmallScreen)
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(isMediumScreen ? 10 : 12),
                    border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      ViewToggleButton(
                        isSelected: isGridView,
                        icon: Icons.grid_view_rounded,
                        onPressed: () => onUpdateGridView(true),
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                        isDarkMode: isDarkMode,
                      ),
                      ViewToggleButton(
                        isSelected: !isGridView,
                        icon: Icons.view_list_rounded,
                        onPressed: () => onUpdateGridView(false),
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              // Sort Button
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                  border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sort),
                  color: accentColor,
                  iconSize: isSmallScreen ? 18 : 24,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onShowSortDialog();
                  },
                  constraints: BoxConstraints(
                    minWidth: isSmallScreen ? 36 : 48,
                    minHeight: isSmallScreen ? 36 : 48,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}