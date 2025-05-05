import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_detail_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_form_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class NormalMarketsPage extends StatefulWidget {

  const NormalMarketsPage({Key? key}) : super(key: key);

  @override
  State<NormalMarketsPage> createState() => _NormalMarketsPageState();
}

class _NormalMarketsPageState extends State<NormalMarketsPage> with SingleTickerProviderStateMixin {
  late NormalMarketProvider _provider;
  bool _isGridView = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isFiltering = false;
  String? _filterCategory;

  // Animation for screen transitions
  final Tween<double> _fadeInTween = Tween<double>(begin: 0.0, end: 1.0);

  static void reloadMarkets(BuildContext context) {
    final state = context.findAncestorStateOfType<_NormalMarketsPageState>();
    state?._reloadMarkets();
  }

  void _reloadMarkets() {
    setState(() {});
    _provider.loadMyMarkets();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<NormalMarketProvider>(context, listen: false);
      _provider.loadMyMarkets();
      _animationController.forward();
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<NormalMarketProvider>(context, listen: false);
    // don't double reload every dependency change, just rely on initState for initial load
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 600;
    final isLargeScreen = screenSize.width >= 900;
    final isWebPlatform = kIsWeb;

    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F7F3);

    if (isSmallScreen && _isGridView) {
      _isGridView = false;
    }

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
            } else if (provider.markets.isEmpty) {
              return _buildEmptyView(isSmallScreen, isMediumScreen, isDarkMode);
            }
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
      floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Creating new market...'),
                    backgroundColor: const Color(0xFF4CAF50),
                    duration: const Duration(milliseconds: 600),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 300));
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NormalMarketFormPage()),
                );
                // After returning from form, force reload
                _reloadMarkets();
              },
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Market'),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }
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
        final name = (market as dynamic).marketName.toString().toLowerCase();
        final location = (market as dynamic).marketLocation.toString().toLowerCase();
        matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
            location.contains(_searchQuery.toLowerCase());
      }

      if (_filterCategory != null) {
        if (_filterCategory == 'tokenized') {
          matchesFilter = (market as dynamic).fractionalNFTAddress != null &&
              (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";
        } else if (_filterCategory == 'non-tokenized') {
          matchesFilter = (market as dynamic).fractionalNFTAddress == null ||
              (market as dynamic).fractionalNFTAddress == "PENDING_FUNDING_NEEDED";
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildLoadingView(bool isSmallScreen, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
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
                    'Loading markets...',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
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
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
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

    // Color theme adjustments based on dark mode
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final errorColor = isDarkMode ? Colors.redAccent.shade200 : Colors.red[700];
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F7F3),
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
            margin: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 20),
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
                          color: errorColor?.withOpacity(0.1),
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
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

    // Color theme adjustments based on dark mode
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final subtitleColor = isDarkMode ? Colors.grey[400] : const Color(0xFF555555);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F7F3),
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
                // Plant growth image with bounce animation
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 1),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + 0.2 * (value as double),
                      child: Opacity(
                        opacity: value,
                        child: Image.asset(
                          'icons/plant_growth.png',
                          height: isSmallScreen ? 120 : 160,
                          width: isSmallScreen ? 120 : 160,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                Text(
                  'Start Your Market',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Create your first market to start selling tokenized fresh produce',
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
                    _navigateToAddMarket();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
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
                      Icon(Icons.add, size: isSmallScreen ? 18 : 24),
                      SizedBox(width: isSmallScreen ? 8 : 10),
                      Text(
                        'Create Market',
                        style: TextStyle(fontSize: isSmallScreen ? 15 : 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Need Help?'),
                        content: const Text('Learn how to create and manage markets with our tutorial guide.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to help page or show tutorial
                            },
                            child: const Text('View Tutorial'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Learn More',
                    style: TextStyle(
                      color: accentColor,
                      decoration: TextDecoration.underline,
                    ),
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
    final hasNftCount = provider.myMarkets
        .where((m) =>
    (m as dynamic).fractionalNFTAddress != null &&
        (m as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED")
        .length;

    // Calculate average ownership
    double averageOwnership = 0;
    if (marketsCount > 0) {
      averageOwnership = provider.myMarkets.fold(
          0.0, (sum, m) => sum + (m as dynamic).fractions / 100) /
          marketsCount;
    }

    // Determine horizontal padding based on screen size
    final horizontalPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 16.0
        : 24.0;

    // Color theme adjustments based on dark mode
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey[400] : const Color(0xFF666666);
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
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await provider.loadMyMarkets();
        },
        child: Scrollbar(
          controller: _scrollController,
          thickness: isWebPlatform ? 10.0 : 6.0,
          radius: const Radius.circular(8.0),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Marketplace Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
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
                                'Fresh Market',
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
                  child: _buildSearchBar(isSmallScreen, isDarkMode, searchBgColor, searchBorderColor, hintTextColor, accentColor),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, isSmallScreen ? 16 : 24),
                  child: _buildStatsRow(marketsCount, hasNftCount, averageOwnership, isSmallScreen, isDarkMode, cardColor, accentColor, dividerColor),
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
                        label: 'Tokenized',
                        isSelected: _filterCategory == 'tokenized',
                        onTap: () {
                          setState(() {
                            _filterCategory = 'tokenized';
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Non-Tokenized',
                        isSelected: _filterCategory == 'non-tokenized',
                        onTap: () {
                          setState(() {
                            _filterCategory = 'non-tokenized';
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
                              border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.sort),
                              color: accentColor,
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _isSearching ? Icons.search : Icons.search_outlined,
            color: _isSearching ? accentColor : (isDarkMode ? Colors.grey.shade500 : const Color(0xFF888888)),
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
                  color: hintColor,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: isDarkMode ? Colors.white : Colors.black87,
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
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: isSmallScreen ? 14 : 16,
                    color: accentColor,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: accentColor,
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
      int marketsCount,
      int hasNftCount,
      double averageOwnership,
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
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey.shade500 : const Color(0xFF666666);

    // Define color schemes for each stat
    final marketsColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final tokenColor = isDarkMode ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
    final ownershipColor = isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
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
              icon: Icons.token,
              iconColor: tokenColor,
              bgColor: tokenColor.withOpacity(0.1),
              value: '$hasNftCount',
              label: 'Tokenized',
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
              icon: Icons.pie_chart,
              iconColor: ownershipColor,
              bgColor: ownershipColor.withOpacity(0.1),
              value: '${averageOwnership.toStringAsFixed(1)}%',
              label: 'Avg Ownership',
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
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final backgroundColor = isSelected
        ? accentColor
        : (isDarkMode ? const Color(0xFF252525) : Colors.white);
    final textColor = isSelected
        ? Colors.white
        : (isDarkMode ? Colors.white : Colors.black87);
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

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
            color: isSelected ? accentColor : borderColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
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
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final selectedColor = isSelected ? accentColor : (isDarkMode ? Colors.grey.shade600 : Colors.grey);
    final selectedBgColor = isSelected
        ? accentColor.withOpacity(0.1)
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
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: isSmallScreen ? 48 : 64,
            color: accentColor.withOpacity(0.7),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'No markets found',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: subtitleColor,
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
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor),
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
              (context, index) => _buildMarketCard(
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
            child: _buildMarketListItem(
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

  Widget _buildMarketCard(Markets market, bool isSmallScreen, bool isMediumScreen, bool isDarkMode, Color cardColor) {
    final String? imagePath = (market as dynamic).marketImage;
    final bool hasNft = (market as dynamic).fractionalNFTAddress != null &&
        (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";
    final double ownership = (market as dynamic).fractions.toDouble() / 100;

    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 12.0 : 14.0;
    final padding = isSmallScreen ? 12.0 : 16.0;

    // Colors based on theme
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey.shade500 : const Color(0xFF666666);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final borderColor = isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.transparent;

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
            _navigateToMarketDetails(market.id);
          },
          splashColor: accentColor.withOpacity(0.1),
          highlightColor: accentColor.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container with hero animation for smooth transitions
              Hero(
                tag: 'market_image_${market.id}',
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

                        // Token Badge with animation
                        if (hasNft)
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
                                        color: const Color(0xFF4CAF50),
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
                                            Icons.token,
                                            size: iconSize,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: isSmallScreen ? 2 : 4),
                                          Text(
                                            'Tokenized',
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
                                (market as dynamic).marketLocation,
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
                        (market as dynamic).marketName,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),

                      // Ownership Info with animated progress bar
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(isDarkMode ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pie_chart,
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
                                  '$ownership% Ownership',
                                  style: TextStyle(
                                    fontSize: smallFontSize,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Progress bar for ownership visualization
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0.0, end: ownership / 100),
                                  builder: (context, value, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.grey.withOpacity(isDarkMode ? 0.3 : 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
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
                            _navigateToMarketDetails(market.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Manage'),
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

  Widget _buildMarketListItem(Markets market, bool isSmallScreen, bool isMediumScreen, bool isDarkMode, Color cardColor) {
    final String? imagePath = (market as dynamic).marketImage;
    final bool hasNft = (market as dynamic).fractionalNFTAddress != null &&
        (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";
    final double ownership = (market as dynamic).fractions.toDouble() / 100;

    final padding = isSmallScreen ? 12.0 : 16.0;
    final imageSize = isSmallScreen ? 60.0 : 80.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;

    // Colors based on theme
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey.shade500 : const Color(0xFF666666);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final borderColor = isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.transparent;

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
            _navigateToMarketDetails(market.id);
          },
          splashColor: accentColor.withOpacity(0.1),
          highlightColor: accentColor.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Market Image with hero animation
                Hero(
                  tag: 'market_image_${market.id}',
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
                              (market as dynamic).marketName,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // NFT Badge
                          if (hasNft)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8,
                                vertical: isSmallScreen ? 3 : 4,
                              ),
                              margin: EdgeInsets.only(left: isSmallScreen ? 6 : 8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.token,
                                    size: isSmallScreen ? 12 : 14,
                                    color: accentColor,
                                  ),
                                  SizedBox(width: isSmallScreen ? 2 : 4),
                                  Text(
                                    'Tokenized',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: isSmallScreen ? 10 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: iconSize,
                            color: isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (market as dynamic).marketLocation,
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575),
                                fontSize: smallFontSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),

                      // Ownership info with animated progress bar
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(isDarkMode ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pie_chart,
                              size: isSmallScreen ? 12 : 14,
                              color: isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$ownership% Ownership',
                                  style: TextStyle(
                                    fontSize: smallFontSize,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Progress bar for ownership visualization
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0.0, end: ownership / 100),
                                  builder: (context, value, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.grey.withOpacity(isDarkMode ? 0.3 : 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Button - using an animated container for feedback
                Container(
                  margin: EdgeInsets.only(left: isSmallScreen ? 8 : 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _navigateToMarketDetails(market.id);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _navigateToMarketDetails(market.id),
                          icon: Icon(
                              Icons.arrow_forward_ios,
                              size: isSmallScreen ? 16 : 20
                          ),
                          color: accentColor,
                          tooltip: 'Manage Market',
                          constraints: BoxConstraints(
                            minWidth: isSmallScreen ? 36 : 40,
                            minHeight: isSmallScreen ? 36 : 40,
                          ),
                          padding: EdgeInsets.zero,
                          splashRadius: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketImage(String? imagePath, bool isSmallScreen, bool isDarkMode) {
    final placeholderColor = isDarkMode ? const Color(0xFF1A2E1A) : const Color(0xFFEEF7ED);
    final errorIconColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);

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

  void _navigateToMarketDetails(String marketId) {
    final provider = _provider;

    // Add page transition animation for better UX
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NormalMarketDetailsPage(marketId: marketId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      if (mounted) {
        provider.loadMarkets();
      }
    });
  }

  void _navigateToAddMarket() {
    final provider = _provider;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const NormalMarketFormPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      if (mounted) {
        provider.loadMarkets();
      }
    });
  }

  void _showSortOptions(BuildContext context, bool isDarkMode) {
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final backgroundColor = isDarkMode ? const Color(0xFF202020) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.sort, color: accentColor),
                    const SizedBox(width: 12),
                    Text(
                      'Sort Markets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sort options
              _buildSortOption(
                icon: Icons.sort_by_alpha,
                title: 'Market Name (A-Z)',
                isDarkMode: isDarkMode,
                onTap: () {
                  // Implement sorting
                  Navigator.pop(context);
                },
              ),

              _buildSortOption(
                icon: Icons.calendar_today,
                title: 'Date Added (Newest)',
                isDarkMode: isDarkMode,
                onTap: () {
                  // Implement sorting
                  Navigator.pop(context);
                },
              ),

              _buildSortOption(
                icon: Icons.pie_chart,
                title: 'Ownership (Highest)',
                isDarkMode: isDarkMode,
                onTap: () {
                  // Implement sorting
                  Navigator.pop(context);
                },
              ),

              _buildSortOption(
                icon: Icons.shopping_basket,
                title: 'Products Count',
                isDarkMode: isDarkMode,
                onTap: () {
                  // Implement sorting
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for the sliver app bar
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
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// Shimmer loading effect for images
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

class _ShimmerLoadingImageState extends State<ShimmerLoadingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Shimmer effect while loading
        if (_isLoading)
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isDarkMode
                        ? [
                      const Color(0xFF1A2E1A),
                      const Color(0xFF253D25),
                      const Color(0xFF1A2E1A),
                    ]
                        : [
                      const Color(0xFFEEF7ED),
                      const Color(0xFFF5FAF5),
                      const Color(0xFFEEF7ED),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: SlidingGradientTransform(
                        _shimmerController.value * 2 - 1
                    ),
                  ),
                ),
              );
            },
          ),

        // Actual image
        Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            _hasError = true;
            _isLoading = false;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                    size: widget.isSmallScreen ? 24 : 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontSize: widget.isSmallScreen ? 10 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              _isLoading = false;
              return child;
            }
            return child;
          },
        ),
      ],
    );
  }
}

// Helper class for sliding gradient
class SlidingGradientTransform extends GradientTransform {
  final double slidePercentage;

  const SlidingGradientTransform(this.slidePercentage);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercentage, 0, 0);
  }
}