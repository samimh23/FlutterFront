import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/hedera_api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../Core/theme/AppColors.dart';
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

  // Initialize HederaApiService
  final HederaApiService _hederaApiService = HederaApiService();

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
      _loadMarketBalances(); // Load market balances from Hedera
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

  // Load market balances from Hedera API
  Future<void> _loadMarketBalances() async {
    if (_marketProvider.myMarkets.isEmpty) return;

    setState(() {
      _isLoadingOrderCounts = true;
    });

    try {
      for (var market in _marketProvider.myMarkets) {
        try {
          print('Fetching balance for market: ${market.id}');

          // Call the getBalancebyMarket method from HederaApiService
          final balanceResponse = await _hederaApiService.getBalancebyMarket(market.id);

          // Initialize token balance
          double hcTokenBalance = 0.0;

          if (balanceResponse.isNotEmpty) {
            print('Balance response for ${market.id}: ${balanceResponse.keys}');

            // Check if the response has the expected structure with balance field
            if (balanceResponse.containsKey('balance')) {
              var balanceValue = balanceResponse['balance'];
              print('Raw balance data: $balanceValue');

              // Parse the balance value
              if (balanceValue is Map) {
                // If it's a nested map
                if (balanceValue.containsKey('tokenBalances')) {
                  // Look for HC token in tokenBalances
                  final tokenBalances = balanceValue['tokenBalances'] as List?;
                  if (tokenBalances != null) {
                    for (var token in tokenBalances) {
                      if (token is Map &&
                          token.containsKey('tokenId') &&
                          token['tokenId'] == '0.0.5883473') {
                        hcTokenBalance = double.tryParse(token['balance']?.toString() ?? '0') ?? 0.0;
                        break;
                      }
                    }
                  }
                } else {
                  // If it's a direct balance value in a map
                  hcTokenBalance = double.tryParse(balanceValue.toString()) ?? 0.0;
                }
              } else {
                // If it's a direct primitive value
                hcTokenBalance = double.tryParse(balanceValue.toString()) ?? 0.0;
              }
            }
          }

          print('Market ${market.id} HC token balance loaded: $hcTokenBalance');

          setState(() {
            _marketRevenue[market.id] = hcTokenBalance;
          });
        } catch (e) {
          print('Error loading HC token balance for market ${market.id}: $e');
          // Keep existing revenue value or set to 0
          if (!_marketRevenue.containsKey(market.id)) {
            _marketRevenue[market.id] = 0.0;
          }
        }
      }
    } catch (e) {
      print('Error in market HC token balances batch loading: $e');
    } finally {
      setState(() {
        _isLoadingOrderCounts = false;
      });
    }
  }

  Future<void> _loadMarketOrderCounts() async {
    if (_marketProvider.myMarkets.isEmpty) return;

    setState(() {
      _isLoadingOrderCounts = true;
    });

    try {
      for (var market in _marketProvider.myMarkets) {
        final orders = await _orderProvider.findOrdersByShopId(market.id);

        // Calculate order count for this market
        final count = orders.length;

        setState(() {
          _marketOrderCounts[market.id] = count;
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

    // Background color based on theme mode - use MarketOwnerColors
    final backgroundColor = isDarkMode
        ? Color(0xFF0D2D4A) // Dark blue for dark mode
        : MarketOwnerColors.background;

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
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _fadeInTween.animate(_animationController),
        child: Consumer<NormalMarketProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingMyMarkets) {
              return _buildLoadingView(isSmallScreen, isDarkMode);
            } else if (provider.errorMessage.isNotEmpty) {
              return _buildErrorView(provider, isSmallScreen, isMediumScreen, isDarkMode);
            } else if (provider.myMarkets.isEmpty) {
              return _buildEmptyView(isSmallScreen, isMediumScreen, isDarkMode);
            }

            // Filter markets if search or filter is active
            final markets = _filterMarkets(provider.myMarkets);

            return _buildMarketplaceView(
                provider,
                markets,
                screenSize,
                crossAxisCount,
                isSmallScreen,
                isMediumScreen,
                isLargeScreen,
                isWebPlatform,
                isDarkMode
            );
          },
        ),
      ),
    );
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


  Widget _buildLoadingView(bool isSmallScreen, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF0D2D4A) : MarketOwnerColors.background, // Use MarketOwnerColors
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + 0.2 * (value as double),
                  child: Opacity(
                    opacity: value,
                    child: Image.asset(
                      'icons/loading_basket.png',
                      height: isSmallScreen ? 80 : 120,
                      width: isSmallScreen ? 80 : 120,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            // Loading text with shimmer effect
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value as double,
                  child: Text(
                    'Loading market orders...',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.w500,
                      color: MarketOwnerColors.primary, // Use MarketOwnerColors primary
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Progress indicator
            SizedBox(
              width: isSmallScreen ? 100 : 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: MarketOwnerColors.background.withOpacity(0.5), // Use lighter background
                  valueColor: AlwaysStoppedAnimation<Color>(MarketOwnerColors.primary), // Use primary color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildErrorView(NormalMarketProvider provider, bool isSmallScreen, bool isMediumScreen, bool isDarkMode) {
    final contentWidth = isSmallScreen
        ? double.infinity
        : isMediumScreen
        ? 400.0
        : 500.0;

    final padding = isSmallScreen ? 16.0 : 30.0;

    // Color theme adjustments using MarketOwnerColors
    final cardColor = MarketOwnerColors.surface; // Use surface color
    final textColor = MarketOwnerColors.text; // Use text color
    final errorColor = Color(0xFFD32F2F); // Keep error red for clarity
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF0D2D4A) : MarketOwnerColors.background, // Use background color
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          child: Container(
            width: contentWidth,
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 20),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error icon with animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0.7, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value as double,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: errorColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: errorColor,
                          size: isSmallScreen ? 50 : 70,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Oops! Could not load markets',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  provider.errorMessage,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    provider.loadMyMarkets();
                    _loadMarketOrderCounts();
                    _loadMarketBalances();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarketOwnerColors.primary, // Use primary color
                    foregroundColor: MarketOwnerColors.onPrimary, // Use on primary color
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 24),
                  label: Text(
                    'Try Again',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyView(bool isSmallScreen, bool isMediumScreen, bool isDarkMode) {
    final contentWidth = isSmallScreen
        ? double.infinity
        : isMediumScreen
        ? 450.0
        : 550.0;

    final padding = isSmallScreen ? 20.0 : 30.0;

    // Color theme adjustments using MarketOwnerColors
    final cardColor = MarketOwnerColors.surface; // Use surface color
    final textColor = MarketOwnerColors.text; // Use text color
    final primaryColor = MarketOwnerColors.primary; // Use primary color
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF0D2D4A) : MarketOwnerColors.background, // Use background color
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: contentWidth,
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 20),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Receipt icon with bounce animation
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 1),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + 0.2 * (value as double),
                      child: Opacity(
                        opacity: value,
                        child: Icon(
                          Icons.receipt_long,
                          size: isSmallScreen ? 100 : 140,
                          color: primaryColor.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                Text(
                  'No Markets Found',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Create your first market to start viewing orders and sales data',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 18,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 30 : 40),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarketOwnerColors.primary, // Use primary color
                    foregroundColor: MarketOwnerColors.onPrimary, // Use on primary for text
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 30,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    shape: const StadiumBorder(),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard, size: isSmallScreen ? 18 : 24),
                      SizedBox(width: isSmallScreen ? 8 : 10),
                      Text(
                        'Go to Dashboard',
                        style: TextStyle(fontSize: isSmallScreen ? 15 : 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceView(
      NormalMarketProvider provider,
      List<Markets> filteredMarkets,
      Size screenSize,
      int crossAxisCount,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isLargeScreen,
      bool isWebPlatform,
      bool isDarkMode,
      ) {
    final marketsCount = provider.myMarkets.length;
    final filteredCount = filteredMarkets.length;

    // Calculate total orders and revenue
    int totalOrders = 0;
    double totalRevenue = 0.0;

    _marketOrderCounts.forEach((key, value) {
      totalOrders += value;
    });

    _marketRevenue.forEach((key, value) {
      totalRevenue += value;
    });

    // Determine horizontal padding based on screen size
    final horizontalPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 16.0
        : 24.0;

    // Color theme adjustments using MarketOwnerColors
    final cardColor = MarketOwnerColors.surface; // Use surface color
    final textColor = MarketOwnerColors.text; // Use text color
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color
    final primaryColor = MarketOwnerColors.primary; // Use primary color
    final secondaryColor = MarketOwnerColors.secondary; // Use secondary color
    final dividerColor = secondaryColor.withOpacity(0.3); // Use secondary with opacity
    final backgroundOverlayOpacity = isDarkMode ? 0.03 : 0.05;
    final searchBgColor = MarketOwnerColors.surface; // Use surface color
    final searchBorderColor = secondaryColor.withOpacity(0.3); // Use secondary with opacity
    final hintTextColor = MarketOwnerColors.textLight; // Use lighter text color

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF0D2D4A) : MarketOwnerColors.background, // Use background color
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: backgroundOverlayOpacity,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: RefreshIndicator(
        color: primaryColor, // Use primary color
        backgroundColor: cardColor,
        strokeWidth: 3,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await provider.loadMyMarkets();
          await _loadMarketOrderCounts();
          await _loadMarketBalances();
        },
        child: Scrollbar(
          controller: _scrollController,
          thickness: isWebPlatform ? 10.0 : 6.0,
          radius: const Radius.circular(8.0),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: isSmallScreen ? 60 : 70,
                  maxHeight: isSmallScreen ? 60 : 70,
                  child: Container(
                    color: MarketOwnerColors.background, // Use background color
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
                                  color: primaryColor, // Use primary color
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (filteredCount != marketsCount)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15), // Use primary color with opacity
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Filtered: $filteredCount',
                              style: TextStyle(
                                color: primaryColor, // Use primary color
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
                  child: _buildSearchBar(isSmallScreen, isDarkMode, searchBgColor, searchBorderColor, hintTextColor, primaryColor),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, isSmallScreen ? 16 : 24),
                  child: _buildStatsRow(totalOrders, filteredMarkets.length, totalRevenue, isSmallScreen, isDarkMode, cardColor, primaryColor, dividerColor),
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
                      _buildFilterChip(
                        label: 'All Markets',
                        isSelected: _filterCategory == null,
                        onTap: () {
                          setState(() {
                            _filterCategory = null;
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'With Orders',
                        isSelected: _filterCategory == 'with-orders',
                        onTap: () {
                          setState(() {
                            _filterCategory = 'with-orders';
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'No Orders',
                        isSelected: _filterCategory == 'no-orders',
                        onTap: () {
                          setState(() {
                            _filterCategory = 'no-orders';
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),

              // View Toggle and Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, isSmallScreen ? 12 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        filteredMarkets.isEmpty
                            ? 'No markets found'
                            : filteredMarkets.length == 1
                            ? '1 Market'
                            : '${filteredMarkets.length} Markets',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: MarketOwnerColors.primary, // Use primary color instead of green
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
                                border: Border.all(color: MarketOwnerColors.secondary.withOpacity(0.3)), // Use secondary with opacity
                              ),
                              child: Row(
                                children: [
                                  _buildViewToggleButton(
                                    isSelected: _isGridView,
                                    icon: Icons.grid_view_rounded,
                                    onPressed: () => setState(() => _isGridView = true),
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    isDarkMode: isDarkMode,
                                  ),
                                  _buildViewToggleButton(
                                    isSelected: !_isGridView,
                                    icon: Icons.view_list_rounded,
                                    onPressed: () => setState(() => _isGridView = false),
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
                              border: Border.all(color: MarketOwnerColors.secondary.withOpacity(0.3)), // Use secondary with opacity
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.sort),
                              color: primaryColor,
                              iconSize: isSmallScreen ? 18 : 24,
                              onPressed: () {
                                // Sort functionality
                                HapticFeedback.selectionClick();
                                _showSortOptions(context, isDarkMode);
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
                ),
              ),

              // Market Items or Empty State
              filteredMarkets.isEmpty
                  ? SliverToBoxAdapter(
                child: _buildNoResultsView(isSmallScreen, isDarkMode, cardColor),
              )
                  : _isGridView && !isSmallScreen
                  ? _buildMarketsGrid(filteredMarkets, crossAxisCount, isSmallScreen, isMediumScreen, isLargeScreen, horizontalPadding, isDarkMode, cardColor)
                  : _buildMarketsList(filteredMarkets, isSmallScreen, isMediumScreen, horizontalPadding, isDarkMode, cardColor),

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

  Widget _buildSearchBar(bool isSmallScreen, bool isDarkMode, Color bgColor, Color borderColor, Color hintColor, Color accentColor) {
    final primaryColor = MarketOwnerColors.primary;
    final textColor = MarketOwnerColors.text;
    final textLightColor = MarketOwnerColors.textLight;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: MarketOwnerColors.surface, // Use surface color
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: MarketOwnerColors.secondary.withOpacity(0.3), width: 1), // Use secondary with opacity
      ),
      child: Row(
        children: [
          Icon(
            _isSearching ? Icons.search : Icons.search_outlined,
            color: _isSearching ? primaryColor : textLightColor, // Use primary if searching, textLight otherwise
            size: isSmallScreen ? 18 : 24,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search markets...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: textLightColor, // Use textLight color
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: textColor, // Use text color
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _isSearching = value.isNotEmpty;
                });
              },
              onTap: () {
                setState(() {
                  _isSearching = true;
                });
              },
              onSubmitted: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                });
              },
            ),
          ),
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.close, size: isSmallScreen ? 18 : 20),
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 32 : 40,
                minHeight: isSmallScreen ? 32 : 40,
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _isSearching = false;
                });
              },
            )
          else
            Container(
              height: isSmallScreen ? 24 : 30,
              width: 1,
              color: borderColor,
              margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
            ),
          if (!_isSearching)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: isSmallScreen ? 14 : 16,
                    color: primaryColor,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      int totalOrders,
      int marketsCount,
      double totalRevenue,
      bool isSmallScreen,
      bool isDarkMode,
      Color cardColor,
      Color accentColor,
      Color dividerColor,
      ) {
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final valueFontSize = isSmallScreen ? 18.0 : 20.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final padding = isSmallScreen ? 16.0 : 20.0;

    // Use colors based on dark mode
    final textColor = MarketOwnerColors.text;
    final subtitleColor = MarketOwnerColors.textLight;

    // Define color schemes for each stat
    final ordersColor = MarketOwnerColors.primary; // Primary blue
    final marketsColor = MarketOwnerColors.secondary; // Secondary blue
    final revenueColor = MarketOwnerColors.accent; // Accent color

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color:MarketOwnerColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDarkMode ? Border.all(color: Colors.grey.shade800, width: 1) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.receipt_long,
              iconColor: ordersColor,
              bgColor: ordersColor.withOpacity(0.1),
              value: '$totalOrders',
              label: 'Orders',
              isSmallScreen: isSmallScreen,
              iconSize: iconSize,
              fontSize: fontSize,
              valueFontSize: valueFontSize,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ),
          _buildStatDivider(isSmallScreen, dividerColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.store,
              iconColor: marketsColor,
              bgColor: marketsColor.withOpacity(0.1),
              value: '$marketsCount',
              label: 'Markets',
              isSmallScreen: isSmallScreen,
              iconSize: iconSize,
              fontSize: fontSize,
              valueFontSize: valueFontSize,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ),
          _buildStatDivider(isSmallScreen, dividerColor),
          Expanded(
            child: _buildStatItem(
              icon: Icons.attach_money,
              iconColor: revenueColor,
              bgColor: revenueColor.withOpacity(0.1),
              value: 'HC ${totalRevenue.toStringAsFixed(2)}',
              label: 'HC Tokens',
              isSmallScreen: isSmallScreen,
              iconSize: iconSize,
              fontSize: fontSize,
              valueFontSize: valueFontSize,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isSmallScreen, Color dividerColor) {
    return Container(
      height: isSmallScreen ? 30 : 40,
      width: 1,
      color: dividerColor,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
    required bool isSmallScreen,
    required double iconSize,
    required double fontSize,
    required double valueFontSize,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final primaryColor = MarketOwnerColors.primary; // Use primary color
    final backgroundColor = isSelected
        ? primaryColor
        : MarketOwnerColors.surface; // Use surface color
    final textColor = isSelected
        ? MarketOwnerColors.onPrimary // Use on primary color
        : MarketOwnerColors.text; // Use text color
    final borderColor = MarketOwnerColors.secondary.withOpacity(0.3); // Use secondary with opacity

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor  : borderColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton({
    required bool isSelected,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isDarkMode,
  }) {
    final primaryColor = MarketOwnerColors.primary; // Use primary color
    final selectedColor = isSelected ? primaryColor : MarketOwnerColors.textLight; // Use textLight color
    final selectedBgColor = isSelected
        ? primaryColor.withOpacity(0.1)
        : Colors.transparent;

    return Material(
      color: selectedBgColor,
      borderRadius: BorderRadius.circular(isMediumScreen ? 6 : 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        borderRadius: BorderRadius.circular(isMediumScreen ? 6 : 8),
        child: Padding(
          padding: EdgeInsets.all(isMediumScreen ? 6 : 8),
          child: Icon(
            icon,
            color: selectedColor,
            size: isMediumScreen ? 18 : 22,
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsView(bool isSmallScreen, bool isDarkMode, Color cardColor) {
    final primaryColor = MarketOwnerColors.primary;
    final textColor = MarketOwnerColors.text;
    final textLightColor = MarketOwnerColors.textLight;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        color: MarketOwnerColors.surface, // Use surface color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MarketOwnerColors.secondary.withOpacity(0.3), // Use secondary with opacity
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: isSmallScreen ? 48 : 64,
            color: primaryColor.withOpacity(0.7), // Use primary color
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'No markets found',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: textColor, // Use text color
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: textLightColor, // Use textLight color
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 20 : 32),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _isSearching = false;
                _filterCategory = null;
              });
            },
            icon: Icon(Icons.refresh_outlined, size: isSmallScreen ? 16 : 20),
            label: Text('Clear filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor, // Use primary color
              side: BorderSide(color: primaryColor), // Use primary color
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 10 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketsGrid(
      List<Markets> markets,
      int crossAxisCount,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isLargeScreen,
      double horizontalPadding,
      bool isDarkMode,
      Color cardColor,
      ) {
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
              (context, index) => _buildMarketOrderCard(
            markets[index],
            isSmallScreen,
            isMediumScreen,
            isDarkMode,
            cardColor,
          ),
          childCount: markets.length,
        ),
      ),
    );
  }

  Widget _buildMarketsList(
      List<Markets> markets,
      bool isSmallScreen,
      bool isMediumScreen,
      double horizontalPadding,
      bool isDarkMode,
      Color cardColor,
      ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 16),
            child: _buildMarketOrderListItem(
              markets[index],
              isSmallScreen,
              isMediumScreen,
              isDarkMode,
              cardColor,
            ),
          ),
          childCount: markets.length,
        ),
      ),
    );
  }

  Widget _buildMarketOrderCard(Markets market, bool isSmallScreen, bool isMediumScreen, bool isDarkMode, Color cardColor) {
    final String? imagePath = (market as dynamic).marketImage;
    final int orderCount = _marketOrderCounts[market.id] ?? 0;
    final double revenue = _marketRevenue[market.id] ?? 0.0;

    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 12.0 : 14.0;
    final padding = isSmallScreen ? 12.0 : 16.0;

    // Colors based on theme
    // Use MarketOwnerColors
    final textColor = MarketOwnerColors.text; // Use text color
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color
    final primaryColor = MarketOwnerColors.primary; // Use primary color
    final secondaryColor = MarketOwnerColors.secondary; // Use secondary color


    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _navigateToMarketOrders(market);
          },
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container with hero animation for smooth transitions
              Hero(
                tag: 'market_image_${market.id}_orders',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: isMediumScreen ? 120 : 140,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Market Image
                        _buildMarketImage(imagePath, isSmallScreen, isDarkMode),

                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),

                        // Order Badge with animation
                        Positioned(
                          top: isSmallScreen ? 8 : 12,
                          right: isSmallScreen ? 8 : 12,
                          child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value as double,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 8 : 10,
                                      vertical: isSmallScreen ? 4 : 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: orderCount > 0 ? const Color(0xFF4CAF50) : Colors.orange,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          orderCount > 0 ? Icons.receipt : Icons.hourglass_empty,
                                          size: iconSize,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: isSmallScreen ? 2 : 4),
                                        Text(
                                          orderCount > 0 ? '$orderCount Orders' : 'No Orders',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 10 : 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),

                        // Location Badge
                        Positioned(
                          bottom: isSmallScreen ? 8 : 12,
                          left: isSmallScreen ? 8 : 12,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: iconSize,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (market as dynamic).marketLocation ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Market Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Market Name
                      Text(
                        (market as dynamic).marketName ?? '',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),

                      // HC Token Balance with animated progress bar
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(isDarkMode ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.attach_money,
                              size: iconSize,
                              color: isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HC Tokens: ${revenue.toStringAsFixed(2)}', // Changed to HC Token balance
                                  style: TextStyle(
                                    fontSize: smallFontSize,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Progress bar for order visualization
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0.0, end: orderCount > 0 ? 1.0 : 0.0),
                                  builder: (context, value, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.grey.withOpacity(isDarkMode ? 0.3 : 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        orderCount > 0
                                            ? (isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50))
                                            : Colors.orange,
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _navigateToMarketOrders(market);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('View Orders'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketOrderListItem(Markets market, bool isSmallScreen, bool isMediumScreen, bool isDarkMode, Color cardColor) {
    final String? imagePath = (market as dynamic).marketImage;
    final int orderCount = _marketOrderCounts[market.id] ?? 0;
    final double revenue = _marketRevenue[market.id] ?? 0.0;

    final padding = isSmallScreen ? 12.0 : 16.0;
    final imageSize = isSmallScreen ? 60.0 : 80.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;

    // Colors based on theme
    final textColor = MarketOwnerColors.text; // Use text color
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color
    final primaryColor = MarketOwnerColors.primary; // Use primary color
    final borderColor = isDarkMode ? MarketOwnerColors.secondary.withOpacity(0.3) : Colors.transparent;

    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderColor),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
    onTap: () {
    HapticFeedback.mediumImpact();
    _navigateToMarketOrders(market);
    },
    splashColor: primaryColor.withOpacity(0.1),
    highlightColor: primaryColor.withOpacity(0.05),
    child: Padding(
    padding: EdgeInsets.all(padding),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    //
      // Market Image with hero animation
      Hero(
        tag: 'market_image_${market.id}_orders',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: imageSize,
            height: imageSize,
            child: _buildMarketImage(imagePath, isSmallScreen, isDarkMode),
          ),
        ),
      ),
      SizedBox(width: isSmallScreen ? 12 : 16),

      // Market Info
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Market Name
                Expanded(
                  child: Text(
                    (market as dynamic).marketName ?? '',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Order Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 3 : 4,
                  ),
                  margin: EdgeInsets.only(left: isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: orderCount > 0
                        ? MarketOwnerColors.primary
                        : MarketOwnerColors.secondary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        orderCount > 0 ? Icons.receipt : Icons.hourglass_empty,
                        size: iconSize - 2,
                        color: subtitleColor,
                      ),
                      SizedBox(width: isSmallScreen ? 2 : 3),
                      Text(
                        orderCount > 0 ? '$orderCount' : '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 4 : 6),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: iconSize - 2,
                  color: subtitleColor,
                ),
                SizedBox(width: isSmallScreen ? 2 : 4),
                Expanded(
                  child: Text(
                    (market as dynamic).marketLocation ?? '',
                    style: TextStyle(
                      fontSize: smallFontSize - 1,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 8 : 10),

            // HC Token Balance info
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: iconSize,
                  color:  MarketOwnerColors.accent,
                ),
                SizedBox(width: isSmallScreen ? 2 : 4),
                Text(
                  'HC Tokens: ${revenue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: MarketOwnerColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Arrow icon
      Icon(
        Icons.chevron_right,
        size: isSmallScreen ? 20 : 24,
        color: subtitleColor,
      ),
    ],
    ),
    ),
    ),
    ),
    );
  }

  Widget _buildMarketImage(String? imagePath, bool isSmallScreen, bool isDarkMode) {
    // Fix blue placeholder colors for Market Owner
    final placeholderColor = isDarkMode
        ? const Color(0xFF0D2D4A)  // Dark blue for dark mode
        : const Color(0xFFE3F2FD); // Light blue for light mode
    final errorIconColor = MarketOwnerColors.secondary; // Use secondary color

    if (imagePath == null || imagePath.isEmpty || imagePath == 'image_url_here') {
      return Container(
        color: placeholderColor,
        child: Center(
          child: Image.asset(
            'icons/loading_basket.png',
            width: isSmallScreen ? 40 : 50,
            height: isSmallScreen ? 40 : 50,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // Fix backslashes in paths coming from server
    final String normalizedPath = imagePath.replaceAll('\\', '/');

    // Process the image URL using ApiConstants
    final String imageUrl = ApiConstants.getFullImageUrl(normalizedPath);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base placeholder
        Container(color: placeholderColor),

        // Actual image with shimmer loading effect
        ShimmerLoadingImage(
          imageUrl: imageUrl,
          isSmallScreen: isSmallScreen,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage(bool isSmallScreen, bool isDarkMode) {
    return Container(
      color: isDarkMode ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
      child: Center(
        child: Icon(
          Icons.storefront,
          size: isSmallScreen ? 30 : 40,
          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildLoadingImage(bool isSmallScreen, bool isDarkMode, ImageChunkEvent loadingProgress) {
    return Container(
      color: isDarkMode ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
          ),
          strokeWidth: 2,
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
    // Use MarketOwnerColors
    final cardColor = MarketOwnerColors.surface; // Use surface color
    final textColor = MarketOwnerColors.text; // Use text color
    final dividerColor = MarketOwnerColors.secondary.withOpacity(0.3); // Use secondary

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
              onTap: () {
                _sortMarkets('orders_desc');
                Navigator.pop(context);
              },
            ),
            Divider(color: dividerColor),
            _buildSortOption(
              title: 'Highest HC Token Balance',
              icon: Icons.attach_money,
              isDarkMode: isDarkMode,
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
    required VoidCallback onTap,
  }) {
    final textColor = MarketOwnerColors.text;
    final accentColor = MarketOwnerColors.primary;

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

  void _sortMarkets(String sortOption) {
    if (_marketProvider.myMarkets.isEmpty) return;

    setState(() {
      switch (sortOption) {
        case 'name_asc':
          _marketProvider.myMarkets.sort((a, b) {
            final aName = (a as dynamic).marketName?.toString().toLowerCase() ?? '';
            final bName = (b as dynamic).marketName?.toString().toLowerCase() ?? '';
            return aName.compareTo(bName);
          });
          break;
        case 'name_desc':
          _marketProvider.myMarkets.sort((a, b) {
            final aName = (a as dynamic).marketName?.toString().toLowerCase() ?? '';
            final bName = (b as dynamic).marketName?.toString().toLowerCase() ?? '';
            return bName.compareTo(aName);
          });
          break;
        case 'orders_desc':
          _marketProvider.myMarkets.sort((a, b) {
            final aOrders = _marketOrderCounts[a.id] ?? 0;
            final bOrders = _marketOrderCounts[b.id] ?? 0;
            return bOrders.compareTo(aOrders);
          });
          break;
        case 'revenue_desc':
          _marketProvider.myMarkets.sort((a, b) {
            final aRevenue = _marketRevenue[a.id] ?? 0.0;
            final bRevenue = _marketRevenue[b.id] ?? 0.0;
            return bRevenue.compareTo(aRevenue);
          });
          break;
        default:
          break;
      }
    });
  }
}

// SliverAppBarDelegate for persistent header
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SliverAppBarDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// ShimmerLoadingImage for image loading with shimmer effect
class ShimmerLoadingImage extends StatefulWidget {
  final String imageUrl;
  final bool isSmallScreen;
  final bool isDarkMode;

  const ShimmerLoadingImage({
    Key? key,
    required this.imageUrl,
    required this.isSmallScreen,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ShimmerLoadingImage> createState() => _ShimmerLoadingImageState();
}

class _ShimmerLoadingImageState extends State<ShimmerLoadingImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Shimmer effect for loading - using blue colors
        if (!_isLoaded)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.isDarkMode
                          ? const Color(0xFF0D2D4A)  // Dark blue
                          : const Color(0xFFE3F2FD),  // Light blue
                      widget.isDarkMode
                          ? const Color(0xFF164677)  // Medium blue
                          : const Color(0xFFBBDEFB),  // Medium light blue
                      widget.isDarkMode
                          ? const Color(0xFF0D2D4A)  // Dark blue
                          : const Color(0xFFE3F2FD),  // Light blue
                    ],
                    stops: [
                      0.0,
                      _animation.value,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

        // Actual image
        Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              // Image loaded
              if (!_isLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _isLoaded = true;
                    });
                  }
                });
              }
              return child;
            }
            return Container();
          },
          errorBuilder: (context, error, stackTrace) {
            // Error loading image
            if (!_isLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isLoaded = true;
                  });
                }
              });
            }
            return Container(
              color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: widget.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  size: widget.isSmallScreen ? 30 : 40,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}