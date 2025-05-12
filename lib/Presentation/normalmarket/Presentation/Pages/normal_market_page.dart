import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_detail_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_form_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../Core/theme/AppColors.dart';
// Import our market owner colors


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
  String? _filterCategory;

  final Tween<double> _fadeInTween = Tween<double>(begin: 0.0, end: 1.0);

  // Rest of your variables and methods remain the same...

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
    final theme = Theme.of(context);

    // Use Market Owner Colors
    final primaryColor = MarketOwnerColors.primary;
    final secondaryColor = MarketOwnerColors.secondary;
    final accentColor = MarketOwnerColors.accent;
    final backgroundColor = MarketOwnerColors.background;
    final surfaceColor = MarketOwnerColors.surface;
    final textColor = MarketOwnerColors.text;
    final textLightColor = MarketOwnerColors.textLight;
    final iconColor = MarketOwnerColors.icon;

    // For backwards compatibility
    final colorScheme = theme.colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;
    final merchantAccent = secondaryColor; // Use our secondary color

    if (isSmallScreen && _isGridView) _isGridView = false;

    final crossAxisCount = screenSize.width > 1200
        ? 4
        : screenSize.width > 900
        ? 3
        : screenSize.width > 600
        ? 2
        : 1;

    return Scaffold(
      backgroundColor: backgroundColor, // Use market owner background
      body: FadeTransition(
        opacity: _fadeInTween.animate(_animationController),
        child: Consumer<NormalMarketProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingMyMarkets) {
              return _buildLoadingView(
                  isSmallScreen, primaryColor, colorScheme, theme);
            } else if (provider.errorMessage.isNotEmpty) {
              return _buildErrorView(
                  provider, isSmallScreen, isMediumScreen, isDarkMode);
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
              isDarkMode,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Creating new market...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: MarketOwnerColors.onPrimary, // Update text color
                ),
              ),
              backgroundColor: primaryColor, // Use primary color for snackbar
              duration: const Duration(milliseconds: 600),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const NormalMarketFormPage()),
          );
          _reloadMarkets();
        },
        backgroundColor: primaryColor, // Use market owner primary
        foregroundColor: MarketOwnerColors.onPrimary, // Use on primary for text
        icon: const Icon(Icons.add),
        label: Text(
          'New Market',
          style: theme.textTheme.labelLarge?.copyWith(
            color: MarketOwnerColors.onPrimary, // Update text color
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // --- PART 2: Market Filtering Logic ---
  List<Markets> _filterMarkets(List<Markets> markets) {
    if (_searchQuery.isEmpty && _filterCategory == null) {
      return markets;
    }
    return markets.where((market) {
      bool matchesSearch = true;
      bool matchesFilter = true;
      if (_searchQuery.isNotEmpty) {
        final name = (market as dynamic).marketName.toString().toLowerCase();
        final location = (market as dynamic).marketLocation.toString()
            .toLowerCase();
        matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
            location.contains(_searchQuery.toLowerCase());
      }
      if (_filterCategory != null) {
        if (_filterCategory == 'tokenized') {
          matchesFilter = (market as dynamic).fractionalNFTAddress != null &&
              (market as dynamic).fractionalNFTAddress !=
                  "PENDING_FUNDING_NEEDED";
        } else if (_filterCategory == 'non-tokenized') {
          matchesFilter = (market as dynamic).fractionalNFTAddress == null ||
              (market as dynamic).fractionalNFTAddress ==
                  "PENDING_FUNDING_NEEDED";
        }
      }
      return matchesSearch && matchesFilter;
    }).toList();
  }

  // --- PART 3: Loading, Error, and Empty States using Theme Colors ---
  Widget _buildLoadingView(bool isSmallScreen, Color primaryColor,
      ColorScheme colorScheme, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: MarketOwnerColors.background, // Use market owner background
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: colorScheme.brightness == Brightness.dark ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value as double,
                  child: Text(
                    'Loading markets...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: MarketOwnerColors.primary, // Use primary color for text
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: isSmallScreen ? 100 : 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: MarketOwnerColors.background.withOpacity(0.5), // Lighter background
                  valueColor: AlwaysStoppedAnimation<Color>(MarketOwnerColors.primary), // Primary color for progress
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(NormalMarketProvider provider, bool isSmallScreen,
      bool isMediumScreen, bool isDarkMode) {
    final theme = Theme.of(context);
    final contentWidth = isSmallScreen
        ? double.infinity
        : isMediumScreen
        ? 400.0
        : 500.0;
    final padding = isSmallScreen ? 16.0 : 30.0;
    final cardColor = MarketOwnerColors.surface; // Use surface color
    final errorColor = Color(0xFFD32F2F); // Keep error red for clarity
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color

    return Container(
      decoration: BoxDecoration(
        color: MarketOwnerColors.background, // Use market owner background
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  provider.errorMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                ElevatedButton.icon(
                  onPressed: () => provider.loadMyMarkets(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarketOwnerColors.primary, // Use primary color
                    foregroundColor: MarketOwnerColors.onPrimary, // Use on primary for text
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          isSmallScreen ? 10 : 12),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 24),
                  label: Text(
                    'Try Again',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: MarketOwnerColors.onPrimary, // Use on primary for text
                      fontSize: isSmallScreen ? 14 : 16,
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

  Widget _buildEmptyView(bool isSmallScreen, bool isMediumScreen, bool isDarkMode) {
    final theme = Theme.of(context);
    final contentWidth = isSmallScreen
        ? double.infinity
        : isMediumScreen
        ? 450.0
        : 550.0;
    final padding = isSmallScreen ? 20.0 : 30.0;
    final cardColor = MarketOwnerColors.surface; // Use surface color
    final accentColor = MarketOwnerColors.primary; // Use primary color
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color

    return Container(
      decoration: BoxDecoration(
        color: MarketOwnerColors.background, // Use market owner background
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 22 : 28,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Create your first market to start selling tokenized fresh produce',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    fontSize: isSmallScreen ? 15 : 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 30 : 40),
                ElevatedButton(
                  onPressed: () => _navigateToAddMarket(),
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
                      Icon(Icons.add, size: isSmallScreen ? 18 : 24),
                      SizedBox(width: isSmallScreen ? 8 : 10),
                      Text(
                        'Create Market',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: MarketOwnerColors.onPrimary, // Use on primary for text
                          fontSize: isSmallScreen ? 15 : 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: MarketOwnerColors.surface, // Use surface color
                        title: Text('Need Help?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: MarketOwnerColors.text, // Use text color
                            )),
                        content: Text(
                            'Learn how to create and manage markets with our tutorial guide.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: MarketOwnerColors.textLight, // Use lighter text color
                            )),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                                'Close',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: MarketOwnerColors.textLight, // Use lighter text color
                                )),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('View Tutorial',
                                style: theme.textTheme.labelLarge?.copyWith(
                                    color: MarketOwnerColors.primary)), // Use primary color
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Learn More',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: MarketOwnerColors.primary, // Use primary color
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

  // --- PART 4: Marketplace Main View (search, filter, stats, toggle) ---
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
    final theme = Theme.of(context);
    final accentColor = MarketOwnerColors.primary; // Use primary color
    final cardColor = MarketOwnerColors.surface; // Use surface color

    final marketsCount = provider.myMarkets.length;
    final filteredCount = filteredMarkets.length;
    final hasNftCount = provider.myMarkets
        .where((m) =>
    (m as dynamic).fractionalNFTAddress != null &&
        (m as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED")
        .length;
    double averageOwnership = 0;
    if (marketsCount > 0) {
      averageOwnership = provider.myMarkets.fold(
          0.0, (sum, m) => sum + (m as dynamic).fractions / 100) /
          marketsCount;
    }

    final horizontalPadding = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 24.0;

    final dividerColor = MarketOwnerColors.secondary.withOpacity(0.3); // Use secondary with opacity
    final backgroundOverlayOpacity = isDarkMode ? 0.03 : 0.05;
    final searchBgColor = MarketOwnerColors.surface; // Use surface color
    final searchBorderColor = MarketOwnerColors.secondary.withOpacity(0.3); // Use secondary with opacity
    final hintTextColor = MarketOwnerColors.textLight; // Use lighter text color

    return Container(
      decoration: BoxDecoration(
        color: MarketOwnerColors.background, // Use background color
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: backgroundOverlayOpacity,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: RefreshIndicator(
        color: MarketOwnerColors.primary, // Use primary color
        backgroundColor: cardColor,
        strokeWidth: 3,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await provider.loadMyMarkets();
        },
        // Rest of code remains unchanged...
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
                    color: MarketOwnerColors.background, // Fixe
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Fresh Market',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: MarketOwnerColors.primary,
                            ),
                          ),
                        ),
                        if (filteredCount != marketsCount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: MarketOwnerColors.primary.withOpacity(0.15), // Fixed
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Filtered: $filteredCount',
                              style: TextStyle(
                                color: MarketOwnerColors.primary, // Fixed
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
                  margin: EdgeInsets.fromLTRB(
                      horizontalPadding, 0, horizontalPadding, 16),
                  child: _buildSearchBar(
                      isSmallScreen, isDarkMode, searchBgColor,
                      searchBorderColor, hintTextColor, accentColor),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      horizontalPadding, 0, horizontalPadding,
                      isSmallScreen ? 16 : 24),
                  child: _buildStatsRow(
                      marketsCount,
                      hasNftCount,
                      averageOwnership,
                      isSmallScreen,
                      isDarkMode,
                      cardColor,
                      accentColor,
                      dividerColor),
                ),
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      horizontalPadding, 0, horizontalPadding,
                      isSmallScreen ? 12 : 16),
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(
                        label: 'All Markets',
                        isSelected: _filterCategory == null,
                        onTap: () => setState(() => _filterCategory = null),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Tokenized',
                        isSelected: _filterCategory == 'tokenized',
                        onTap: () =>
                            setState(() => _filterCategory = 'tokenized'),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Non-Tokenized',
                        isSelected: _filterCategory == 'non-tokenized',
                        onTap: () =>
                            setState(() => _filterCategory = 'non-tokenized'),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),

              // View Toggle and Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      horizontalPadding, 0, horizontalPadding,
                      isSmallScreen ? 12 : 16),
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
                          color: accentColor,
                        ),
                      ),
                      Row(
                        children: [
// Inside _buildMarketplaceView method, for the view toggle container:
                          if (!isSmallScreen)
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(isMediumScreen ? 10 : 12),
                                border: Border.all(color: MarketOwnerColors.secondary.withOpacity(0.3)), // Fix: Use MarketOwnerColors
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
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                              border: Border.all(color: MarketOwnerColors.secondary.withOpacity(0.3)), // Fix: Use MarketOwnerColors
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.sort),
                              color: accentColor,
                              iconSize: isSmallScreen ? 18 : 24,
                              onPressed: () {
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
                child: _buildNoResultsView(
                    isSmallScreen, isDarkMode, cardColor),
              )
                  : _isGridView && !isSmallScreen
                  ? _buildMarketsGrid(
                  filteredMarkets,
                  crossAxisCount,
                  isSmallScreen,
                  isMediumScreen,
                  isLargeScreen,
                  horizontalPadding,
                  isDarkMode,
                  cardColor)
                  : _buildMarketsList(
                  filteredMarkets, isSmallScreen, isMediumScreen,
                  horizontalPadding, isDarkMode, cardColor),

              SliverToBoxAdapter(
                  child: SizedBox(height: isSmallScreen ? 80 : 100)),
            ],
          ),
        ),
      ),
    );
  }

  // --- PART 5: Search Bar, Stats Row, Filter Chip, View Toggle, No Results ---

  Widget _buildSearchBar(
      bool isSmallScreen,
      bool isDarkMode,
      Color bgColor,
      Color borderColor,
      Color hintColor,
      Color accentColor,
      ) {
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
            color: _isSearching ? MarketOwnerColors.primary : MarketOwnerColors.textLight, // Use primary if searching, light text otherwise
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
                  color: MarketOwnerColors.textLight, // Use lighter text color
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: MarketOwnerColors.text, // Use text color
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
              color: MarketOwnerColors.textLight, // Use lighter text color
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
              color: MarketOwnerColors.secondary.withOpacity(0.3), // Use secondary with opacity
              margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
            ),
          if (!_isSearching)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: MarketOwnerColors.primary.withOpacity(0.1), // Use primary with opacity
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: isSmallScreen ? 14 : 16,
                    color: MarketOwnerColors.primary, // Use primary color
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: MarketOwnerColors.primary, // Use primary color
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
    final textColor = MarketOwnerColors.text; // Use text color
    final subtitleColor = MarketOwnerColors.textLight; // Use lighter text color

    final marketsColor = MarketOwnerColors.primary; // Use primary color
    final tokenColor = MarketOwnerColors.secondary; // Use secondary color
    final ownershipColor = MarketOwnerColors.accent; // Use accent color

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: MarketOwnerColors.surface, // Use surface color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDarkMode
            ? Border.all(color: MarketOwnerColors.secondary.withOpacity(0.3), width: 1) // Use secondary with opacity
            : null,
      ),
      // Rest of stats row implementation remains the same...
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
    final accentColor = MarketOwnerColors.primary; // Use primary color
    final backgroundColor = isSelected
        ? accentColor
        : (MarketOwnerColors.surface); // Use surface color
    final textColor = isSelected
        ? MarketOwnerColors.onPrimary // Use on primary for text
        : (MarketOwnerColors.text); // Use text color
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
    final primaryColor = MarketOwnerColors.primary;
    final selectedColor = isSelected ? primaryColor : MarketOwnerColors.textLight;
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

  Widget _buildNoResultsView(bool isSmallScreen, bool isDarkMode,
      Color cardColor) {
    final primaryColor = MarketOwnerColors.primary;
    final textColor = MarketOwnerColors.text;
    final subtitleColor = MarketOwnerColors.textLight;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        color: MarketOwnerColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MarketOwnerColors.secondary.withOpacity(0.3), // Fixed
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: isSmallScreen ? 48 : 64,
            color: primaryColor.withOpacity(0.7),
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
            label: Text(
              'Clear filters',
              style: TextStyle(
                color: primaryColor, // Fix: Use primaryColor
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
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

  // --- PART 6: Market Grid, List, Cards, List Items, Market Image, Navigation, Sort Options ---

  Widget _buildMarketsGrid(List<Markets> markets,
      int crossAxisCount,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isLargeScreen,
      double horizontalPadding,
      bool isDarkMode,
      Color cardColor,) {
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
              (context, index) =>
              _buildMarketCard(
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

  Widget _buildMarketsList(List<Markets> markets,
      bool isSmallScreen,
      bool isMediumScreen,
      double horizontalPadding,
      bool isDarkMode,
      Color cardColor,) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) =>
              Padding(
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

  Widget _buildMarketCard(
      Markets market,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isDarkMode,
      Color cardColor,
      ) {
    final String? imagePath = (market as dynamic).marketImage;
    final bool hasNft = (market as dynamic).fractionalNFTAddress != null &&
        (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";
    final double ownership = ((market as dynamic).fractions.toDouble() / 100);

    // Use Market Owner color palette consistently
    final primaryColor = MarketOwnerColors.primary;
    final onPrimaryColor = MarketOwnerColors.onPrimary;
    final secondaryColor = MarketOwnerColors.secondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: MarketOwnerColors.surface, // Use surface color instead of passed cardColor
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
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
          onTap: () => _navigateToMarketDetails(market.id),
          splashColor: primaryColor.withOpacity(0.07), // Use primaryColor instead of accentColor
          highlightColor: primaryColor.withOpacity(0.04), // Use primaryColor instead of accentColor
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'market_image_${market.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: SizedBox(
                        height: isMediumScreen ? 120 : 140,
                        width: double.infinity,
                        child: _buildMarketImage(
                            imagePath, isSmallScreen, isDarkMode),
                      ),
                    ),
                  ),
                  if (hasNft)
                    Positioned(
                      top: isSmallScreen ? 8 : 12,
                      right: isSmallScreen ? 8 : 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 10,
                          vertical: isSmallScreen ? 4 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
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
                            Icon(Icons.token, size: isSmallScreen ? 12 : 14,
                                color: onPrimaryColor),
                            SizedBox(width: isSmallScreen ? 2 : 4),
                            Text(
                              'Tokenized',
                              style: TextStyle(
                                color: onPrimaryColor,
                                fontSize: isSmallScreen ? 10 : 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (market as dynamic).marketName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: MarketOwnerColors.text, // Use text color from MarketOwnerColors
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.14), // Use primaryColor instead of accentColor
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pie_chart,
                              size: isSmallScreen ? 12 : 14,
                              color: primaryColor, // Use primaryColor instead of accentColor
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${ownership.toStringAsFixed(1)}% Ownership',
                                  style: TextStyle(
                                    color: MarketOwnerColors.textLight, // Use textLight color
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(
                                      begin: 0.0, end: ownership / 100),
                                  builder: (context, value, _) =>
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: primaryColor
                                              .withOpacity(0.15), // Use primaryColor instead of accentColor
                                          valueColor: AlwaysStoppedAnimation<
                                              Color>(primaryColor), // Use primaryColor
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateToMarketDetails(market.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, // Use primaryColor instead of accentColor
                            foregroundColor: onPrimaryColor, // Use onPrimaryColor instead of onAccent
                            padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 8 : 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 8 : 10),
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

  Widget _buildMarketListItem(Markets market,
      bool isSmallScreen,
      bool isMediumScreen,
      bool isDarkMode,
      Color cardColor,) {
    final String? imagePath = (market as dynamic).marketImage;
    final bool hasNft = (market as dynamic).fractionalNFTAddress != null &&
        (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";
    final double ownership = ((market as dynamic).fractions.toDouble() / 100);

    final primaryColor = MarketOwnerColors.primary;
    final onPrimaryColor = MarketOwnerColors.onPrimary;
    final secondaryColor = MarketOwnerColors.secondary;
    final textColor = MarketOwnerColors.text;
    final textLightColor = MarketOwnerColors.textLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: MarketOwnerColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
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
          onTap: () => _navigateToMarketDetails(market.id),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'market_image_${market.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: isSmallScreen ? 60.0 : 80.0,
                      height: isSmallScreen ? 60.0 : 80.0,
                      child: _buildMarketImage(
                          imagePath, isSmallScreen, isDarkMode),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child:Text(
                              (market as dynamic).marketName,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: textColor, // Fix: Use text color
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasNft)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 3 : 4),
                              margin: EdgeInsets.only(
                                  left: isSmallScreen ? 6 : 8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.token,
                                      size: isSmallScreen ? 12 : 14,
                                      color: primaryColor),
                                  SizedBox(width: isSmallScreen ? 2 : 4),
                                  Text(
                                    'Tokenized',
                                    style: TextStyle(
                                      color: primaryColor,
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
                      Row(
                        children: [
                          Icon(Icons.location_on, size: isSmallScreen
                              ? 14.0
                              : 16.0, color: primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (market as dynamic).marketLocation,
                              style: TextStyle(
                                color: textLightColor, // Fix: Use textLightColor
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pie_chart,
                              size: isSmallScreen ? 12 : 14,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${ownership.toStringAsFixed(1)}% Ownership',
                                    style: TextStyle(
                                      color: textLightColor, // Fix: Use textLightColor
                                      fontSize: 12,
                                    ),),
                                const SizedBox(height: 4),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(
                                      begin: 0.0, end: ownership / 100),
                                  builder: (context, value, _) =>
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: primaryColor
                                              .withOpacity(0.15),
                                          valueColor: AlwaysStoppedAnimation<
                                              Color>(primaryColor),
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
                Container(
                  margin: EdgeInsets.only(left: isSmallScreen ? 8 : 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToMarketDetails(market.id),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.13),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _navigateToMarketDetails(market.id),
                          icon: Icon(Icons.arrow_forward_ios,
                              size: isSmallScreen ? 16 : 20),
                          color: primaryColor,
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
    // Fix: Use blue colors that match MarketOwnerColors
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

    final String normalizedPath = imagePath.replaceAll('\\', '/');
    final String imageUrl = ApiConstants.getFullImageUrl(normalizedPath);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: placeholderColor),
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
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NormalMarketDetailsPage(marketId: marketId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));
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
    final primaryColor = MarketOwnerColors.primary;
    final surfaceColor = MarketOwnerColors.surface;
    final textColor = MarketOwnerColors.text;


    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
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
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MarketOwnerColors.secondary.withOpacity(0.3), // Fixed
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: primaryColor),
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
                  _buildSortOption(
                    icon: Icons.sort_by_alpha,
                    title: 'Market Name (A-Z)',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Implement sorting if needed
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    icon: Icons.calendar_today,
                    title: 'Date Added (Newest)',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Implement sorting if needed
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    icon: Icons.pie_chart,
                    title: 'Ownership (Highest)',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Implement sorting if needed
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    icon: Icons.shopping_basket,
                    title: 'Products Count',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Implement sorting if needed
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
    final primaryColor = MarketOwnerColors.primary;
    final textColor = MarketOwnerColors.text;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 22),
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
// --- PART 7: SliverAppBarDelegate, ShimmerLoadingImage, Gradient Helper ---

// SliverPersistentHeaderDelegate for main page header
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

// Shimmer loading effect for images (uses theme colors)
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
                      const Color(0xFF0D2D4A),  // Dark blue
                      const Color(0xFF164677),  // Medium blue
                      const Color(0xFF0D2D4A),
                    ]
                        : [
                      const Color(0xFFE3F2FD),  // Very light blue
                      const Color(0xFFBBDEFB),  // Light blue
                      const Color(0xFFE3F2FD),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: SlidingGradientTransform(
                        _shimmerController.value * 2 - 1),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: widget.isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                    size: widget.isSmallScreen ? 24 : 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
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
              if (_isLoading) {
                setState(() => _isLoading = false);
              }
              return child;
            }
            return child;
          },
        ),
      ],
    );
  }
}

// Helper for shimmer gradient sliding
class SlidingGradientTransform extends GradientTransform {
  final double slidePercentage;

  const SlidingGradientTransform(this.slidePercentage);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercentage, 0, 0);
  }
}