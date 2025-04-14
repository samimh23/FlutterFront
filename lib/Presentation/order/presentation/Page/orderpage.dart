// lib/Presentation/order/presentation/Page/OrdersPage.dart

import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/EmptyView.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/ErrorView.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/LoadingView.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/MarketSorter.dart';
import 'package:hanouty/Presentation/order/presentation/Widgets/MarketplaceView.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'MarketOrdersPage.dart';


class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late NormalMarketProvider _marketProvider;
  late OrderProvider _orderProvider;
  bool _isGridView = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String? _filterCategory;

  // Animation for screen transitions
  final Tween<double> _fadeInTween = Tween<double>(begin: 0.0, end: 1.0);

  // Market order counts map
  Map<String, int> _marketOrderCounts = {};
  Map<String, double> _marketRevenue = {};
  bool _isLoadingOrderCounts = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marketProvider = Provider.of<NormalMarketProvider>(context, listen: false);
      _orderProvider = Provider.of<OrderProvider>(context, listen: false);
      _marketProvider.loadMyMarkets();
      _animationController.forward();
      _loadMarketOrderCounts();
    });

    // Set preferred orientation for better experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketOrderCounts() async {
    if (_marketProvider.myMarkets.isEmpty) return;

    setState(() {
      _isLoadingOrderCounts = true;
    });

    try {
      for (var market in _marketProvider.myMarkets) {
        final orders = await _orderProvider.findOrdersByShopId(market.id);

        // Calculate order count and total revenue for this market
        final count = orders.length;
        final revenue = orders.fold<double>(
            0, (sum, order) => sum + order.totalPrice
        );

        setState(() {
          _marketOrderCounts[market.id] = count;
          _marketRevenue[market.id] = revenue;
        });
      }
    } catch (e) {
      // Handle error
      print('Error loading order counts: $e');
    } finally {
      setState(() {
        _isLoadingOrderCounts = false;
      });
    }
  }

  List<Markets> _filterMarkets(List<Markets> markets) {
    if (_searchQuery.isEmpty && _filterCategory == null) {
      return markets;
    }

    return markets.where((market) {
      bool matchesSearch = true;
      bool matchesFilter = true;

      if (_searchQuery.isNotEmpty) {
        final name = (market as dynamic).marketName?.toString().toLowerCase() ?? '';
        final location = (market as dynamic).marketLocation?.toString().toLowerCase() ?? '';
        matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
            location.contains(_searchQuery.toLowerCase());
      }

      if (_filterCategory != null) {
        if (_filterCategory == 'with-orders') {
          matchesFilter = _marketOrderCounts[market.id] != null && _marketOrderCounts[market.id]! > 0;
        } else if (_filterCategory == 'no-orders') {
          matchesFilter = _marketOrderCounts[market.id] == null || _marketOrderCounts[market.id] == 0;
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _sortMarkets(String sortOption) {
    MarketSorter.sortMarkets(_marketProvider.myMarkets, sortOption, _marketOrderCounts, _marketRevenue);
    setState(() {}); // Refresh UI
  }

  void _updateGridView(bool isGrid) {
    setState(() {
      _isGridView = isGrid;
    });
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void _updateFilter(String? category) {
    setState(() {
      _filterCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 600;
    final isLargeScreen = screenSize.width >= 900;
    final isWebPlatform = kIsWeb;

    // Use appropriate theme data based on platform
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // Automatically switch to list view on very small screens
    if (isSmallScreen && _isGridView) {
      _isGridView = false;
    }

    // Dynamic grid layout based on screen size
    final crossAxisCount = screenSize.width > 1200
        ? 4
        : screenSize.width > 900
        ? 3
        : screenSize.width > 600
        ? 2
        : 1;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F7F3),
      body: FadeTransition(
        opacity: _fadeInTween.animate(_animationController),
        child: Consumer<NormalMarketProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingMyMarkets) {
              return LoadingView(isSmallScreen: isSmallScreen, isDarkMode: isDarkMode);
            } else if (provider.errorMessage.isNotEmpty) {
              return ErrorView(
                provider: provider,
                isSmallScreen: isSmallScreen,
                isMediumScreen: isMediumScreen,
                isDarkMode: isDarkMode,
                onRetry: () {
                  HapticFeedback.lightImpact();
                  provider.loadMyMarkets();
                  _loadMarketOrderCounts();
                },
              );
            } else if (provider.myMarkets.isEmpty) {
              return EmptyView(
                isSmallScreen: isSmallScreen,
                isMediumScreen: isMediumScreen,
                isDarkMode: isDarkMode,
              );
            }

            // Filter markets if search or filter is active
            final filteredMarkets = _filterMarkets(provider.myMarkets);

            return MarketplaceView(
              provider: provider,
              markets: filteredMarkets,
              screenSize: screenSize,
              crossAxisCount: crossAxisCount,
              isSmallScreen: isSmallScreen,
              isMediumScreen: isMediumScreen,
              isLargeScreen: isLargeScreen,
              isWebPlatform: isWebPlatform,
              isDarkMode: isDarkMode,
              isGridView: _isGridView,
              searchController: _searchController,
              searchQuery: _searchQuery,
              isSearching: _isSearching,
              filterCategory: _filterCategory,
              marketOrderCounts: _marketOrderCounts,
              marketRevenue: _marketRevenue,
              scrollController: _scrollController,
              onUpdateGridView: _updateGridView,
              onUpdateSearch: _updateSearch,
              onClearSearch: _clearSearch,
              onUpdateFilter: _updateFilter,
              onShowSortDialog: () => _showSortOptions(context, isDarkMode),
              onSortMarkets: _sortMarkets,
              onRefresh: () async {
                await provider.loadMyMarkets();
                await _loadMarketOrderCounts();
              },
              onNavigateToMarket: (market) => _navigateToMarketOrders(market),
            );
          },
        ),
      ),
    );
  }

  void _navigateToMarketOrders(Markets market) {
    if (market is NormalMarket) {
      // If the market is already a NormalMarket, use it directly
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarketOrdersPage(market: market),
        ),
      );
    } else {
      // If the market is not a NormalMarket, convert it
      final normalMarket = NormalMarket(
        id: market.id,
        marketName: (market as dynamic).marketName ?? '',
        marketLocation: (market as dynamic).marketLocation ?? '',
        marketPhone: (market as dynamic).marketPhone ?? '',
        marketEmail: (market as dynamic).marketEmail ?? '',
        products: [], // Empty products list
        marketWalletPublicKey: (market as dynamic).marketWalletPublicKey ?? '',
        marketWalletSecretKey: (market as dynamic).marketWalletSecretKey ?? '',
        marketImage: (market as dynamic).marketImage,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarketOrdersPage(market: normalMarket),
        ),
      );
    }
  }

  void _showSortOptions(BuildContext context, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final dividerColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sort Markets',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption(
              title: 'Market Name (A-Z)',
              icon: Icons.sort_by_alpha,
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              textColor: textColor,
              onTap: () {
                _sortMarkets('name_asc');
                Navigator.pop(context);
              },
            ),
            Divider(color: dividerColor),
            _buildSortOption(
              title: 'Market Name (Z-A)',
              icon: Icons.sort_by_alpha,
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              textColor: textColor,
              onTap: () {
                _sortMarkets('name_desc');
                Navigator.pop(context);
              },
            ),
            Divider(color: dividerColor),
            _buildSortOption(
              title: 'Most Orders',
              icon: Icons.receipt_long,
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              textColor: textColor,
              onTap: () {
                _sortMarkets('orders_desc');
                Navigator.pop(context);
              },
            ),
            Divider(color: dividerColor),
            _buildSortOption(
              title: 'Highest Revenue',
              icon: Icons.attach_money,
              isDarkMode: isDarkMode,
              accentColor: accentColor,
              textColor: textColor,
              onTap: () {
                _sortMarkets('revenue_desc');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required IconData icon,
    required bool isDarkMode,
    required Color accentColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}