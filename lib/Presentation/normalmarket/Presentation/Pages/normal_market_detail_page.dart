import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/products_grid.dart';
import 'package:hanouty/hedera_api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../Core/Utils/secure_storage.dart';
import 'normal_market_form_page.dart';

class NormalMarketDetailsPage extends StatefulWidget {
  final String marketId;

  const NormalMarketDetailsPage({
    Key? key,
    required this.marketId,
  }) : super(key: key);

  @override
  State<NormalMarketDetailsPage> createState() =>
      _NormalMarketDetailsPageState();
}

class _NormalMarketDetailsPageState extends State<NormalMarketDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _ownershipDistribution;
  bool _loadingDistribution = false;
  String? _distributionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NormalMarketProvider>().loadMarketById(widget.marketId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final SecureStorageService _secureStorage = SecureStorageService();

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    // Get JWT token from secure storage instead of separate service
    final token = await _secureStorage.getAccessToken();

    if (token == null) {
      throw Exception('No authentication token found. Please login again.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchOwnershipDistribution(String? tokenId) async {
    if (tokenId == null || tokenId == "PENDING_FUNDING_NEEDED") return;
    setState(() {
      _loadingDistribution = true;
      _distributionError = null;
    });
    try {
      final api = HederaApiService();
      final data = await api.getTokenOwnership(tokenId);

      // Filter out any ownership entries with 0% share
      if (data != null && data['ownershipDistribution'] is List) {
        data['ownershipDistribution'] = (data['ownershipDistribution'] as List)
            .where((h) =>
        (h['percentage'] is num ? h['percentage'] : 0) > 0)
            .toList();
      }

      setState(() {
        _ownershipDistribution = data;
        _loadingDistribution = false;
      });
    } catch (e) {
      setState(() {
        _distributionError = 'Failed to load share distribution';
        _loadingDistribution = false;
      });
    }
  }

  String? _lastFetchedTokenId;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme
        .of(context)
        .brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(
          0xFFF9F7F3),
      body: Consumer<NormalMarketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingView(isDarkMode);
          } else if (provider.errorMessage.isNotEmpty) {
            return _buildErrorView(provider, isDarkMode);
          } else if (provider.selectedMarket == null) {
            return _buildEmptyView(isDarkMode);
          }
          final market = provider.selectedMarket!;
          final String? imagePath = (market as dynamic).marketImage;
          final String? nftAddress = (market as dynamic).fractionalNFTAddress;
          final bool hasValidNft =
              nftAddress != null && nftAddress != "PENDING_FUNDING_NEEDED";


          if (hasValidNft &&
              nftAddress != null &&
              nftAddress != _lastFetchedTokenId &&
              !_loadingDistribution) {
            _lastFetchedTokenId = nftAddress;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchOwnershipDistribution(nftAddress);
            });
          }
          // Get screen size for responsive design
          final screenSize = MediaQuery
              .of(context)
              .size;
          final isSmallScreen = screenSize.width < 360;

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(market, imagePath, hasValidNft, MediaQuery
                  .of(context)
                  .size
                  .width < 360, isDarkMode),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery
                          .of(context)
                          .size
                          .width < 360 ? 12.0 : 20.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .width < 360 ? 16 : 20),
                      _buildStatsCard(market, MediaQuery
                          .of(context)
                          .size
                          .width < 360, isDarkMode),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .width < 360 ? 20 : 24),
                      // CHANGED: Pass ownership distribution to blockchain details card
                      _buildDetailsCard(
                        market,
                        hasValidNft,
                        nftAddress,
                        MediaQuery
                            .of(context)
                            .size
                            .width < 360,
                        isDarkMode,
                        ownershipDistribution: _ownershipDistribution,
                        loadingDistribution: _loadingDistribution,
                        distributionError: _distributionError,
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .width < 360 ? 20 : 24),
                      _buildProductsCard(market, MediaQuery
                          .of(context)
                          .size
                          .width < 360, isDarkMode),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .width < 360 ? 24 : 30),
                      _buildActionButtons(market.id, hasValidNft, MediaQuery
                          .of(context)
                          .size
                          .width < 360, isDarkMode),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .width < 360 ? 30 : 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingView(bool isDarkMode) {
    final isSmallScreen = MediaQuery
        .of(context)
        .size
        .width < 360;
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'icons/loading_basket.png',
              height: isSmallScreen ? 80 : 120,
              width: isSmallScreen ? 80 : 120,
              color: isDarkMode ? Colors.white.withOpacity(0.7) : null,
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Text(
              'Loading market details...',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w500,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(NormalMarketProvider provider, bool isDarkMode) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isSmallScreen = screenSize.width < 360;
    final contentWidth = isSmallScreen
        ? screenSize.width - 40
        : screenSize.width > 600
        ? 500.0
        : screenSize.width - 40;

    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final errorColor = isDarkMode ? Colors.redAccent.shade200 : Colors.red[700];
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          child: Container(
            width: contentWidth,
            padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
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
                Image.asset(
                  'assets/images/empty_basket.png',
                  height: isSmallScreen ? 80 : 120,
                  width: isSmallScreen ? 80 : 120,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : null,
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Oops! Could not load market',
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
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 24 : 30),
                ElevatedButton.icon(
                  onPressed: () => provider.loadMarketById(widget.marketId),
                  icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 24),
                  label: Text(
                      'Try Again',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildEmptyView(bool isDarkMode) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isSmallScreen = screenSize.width < 360;
    final contentWidth = isSmallScreen
        ? screenSize.width - 40
        : screenSize.width > 600
        ? 500.0
        : screenSize.width - 40;

    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey[400] : const Color(
        0xFF555555);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('icons/fruits_pattern_light.gif'),
          opacity: isDarkMode ? 0.03 : 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          child: Container(
            width: contentWidth,
            padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
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
                Image.asset(
                  'assets/images/empty_basket.png',
                  height: isSmallScreen ? 80 : 120,
                  width: isSmallScreen ? 80 : 120,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : null,
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Market not found',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, size: isSmallScreen ? 18 : 24),
                  label: Text(
                      'Back to Markets',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildSliverAppBar(Markets market, String? imagePath, bool hasNft,
      bool isSmallScreen, bool isDarkMode) {
    final expandedHeight = isSmallScreen ? 200.0 : 240.0;
    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final appBarIconColor = isDarkMode ? Colors.white : const Color(0xFF4CAF50);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: appBarColor,
      elevation: 0,
      iconTheme: IconThemeData(color: appBarIconColor),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Market image
            _buildMarketBackgroundImage(imagePath, isSmallScreen, isDarkMode),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Market name and location
            Positioned(
              bottom: isSmallScreen ? 12 : 16,
              left: isSmallScreen ? 12 : 16,
              right: isSmallScreen ? 12 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (market as dynamic).marketName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasNft)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 10,
                            vertical: isSmallScreen ? 4 : 5,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF81C784)
                                : const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
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
                                  color: Colors.white,
                                  size: isSmallScreen ? 14 : 16
                              ),
                              SizedBox(width: isSmallScreen ? 4 : 6),
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
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        child: Text(
                          (market as dynamic).marketLocation,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 12 : 14,
                            shadows: [
                              const Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Positioned(
              top: MediaQuery
                  .of(context)
                  .padding
                  .top + (isSmallScreen ? 4 : 8),
              right: isSmallScreen ? 4 : 8,
              child: Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.edit_outlined,
                    color: Colors.white,
                    onPressed: () => _editMarket(context, market),
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  _buildCircleButton(
                    icon: Icons.delete_outline,
                    color: Colors.white,
                    onPressed: () =>
                        _deleteMarket(context, market.id, isDarkMode),
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
        onPressed: onPressed,
        constraints: BoxConstraints(
          minHeight: isSmallScreen ? 36 : 40,
          minWidth: isSmallScreen ? 36 : 40,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMarketBackgroundImage(String? imagePath, bool isSmallScreen,
      bool isDarkMode) {
    if (imagePath == null || imagePath.isEmpty ||
        imagePath == 'image_url_here') {
      return Container(
        color: isDarkMode
            ? const Color(0xFF1A2E1A) // Dark green background for dark mode
            : const Color(0xFFEEF7ED), // Light green background for light mode
        child: Center(
          child: Image.asset(
            'assets/images/vegetable_placeholder.png',
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            fit: BoxFit.contain,
            color: isDarkMode ? Colors.white.withOpacity(0.7) : null,
          ),
        ),
      );
    }

    // Fix backslashes in paths coming from server
    final String normalizedPath = imagePath.replaceAll('\\', '/');

    // Process the image URL correctly
    final String imageUrl = ApiConstants.getFullImageUrl(normalizedPath);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Placeholder color while loading
        Container(
          color: isDarkMode
              ? const Color(0xFF1A2E1A)
              : const Color(0xFFEEF7ED),
        ),

        // Actual image
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: isDarkMode
                  ? const Color(0xFF1A2E1A)
                  : const Color(0xFFEEF7ED),
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  size: isSmallScreen ? 40 : 50,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                color: isDarkMode
                    ? const Color(0xFF81C784)
                    : const Color(0xFF4CAF50),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: isSmallScreen ? 2.5 : 3.5,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsCard(Markets market, bool isSmallScreen, bool isDarkMode) {
    final double ownership = (market as dynamic).fractions.toDouble() / 100;
    final int productsCount = market.products.length;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final valueFontSize = isSmallScreen ? 18.0 : 20.0;
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;

    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey[300] : const Color(
        0xFF666666);
    final dividerColor = isDarkMode
        ? Colors.grey.shade800.withOpacity(0.5)
        : Colors.grey.withOpacity(0.2);

    // Define color schemes for each stat with dark mode support
    final ownershipColor = isDarkMode ? const Color(0xFF64B5F6) : const Color(
        0xFF2196F3);
    final productsColor = isDarkMode ? const Color(0xFFFFB74D) : const Color(
        0xFFFF9800);
    final contactColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);

    return Container(
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
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                _buildStatItem(
                  icon: Icons.pie_chart,
                  iconColor: ownershipColor,
                  bgColor: ownershipColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  value: '$ownership%',
                  label: 'Ownership',
                  isSmallScreen: isSmallScreen,
                  iconSize: iconSize,
                  valueFontSize: valueFontSize,
                  labelFontSize: labelFontSize,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                _buildStatDivider(isSmallScreen, dividerColor),
                _buildStatItem(
                  icon: Icons.shopping_basket,
                  iconColor: productsColor,
                  bgColor: productsColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  value: productsCount.toString(),
                  label: 'Products',
                  isSmallScreen: isSmallScreen,
                  iconSize: iconSize,
                  valueFontSize: valueFontSize,
                  labelFontSize: labelFontSize,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                if ((market as dynamic).marketPhone != null ||
                    (market as dynamic).marketEmail != null)
                  _buildStatDivider(isSmallScreen, dividerColor),
                if ((market as dynamic).marketPhone != null)
                  _buildContactItem(
                    icon: Icons.phone,
                    value: (market as dynamic).marketPhone!,
                    isSmallScreen: isSmallScreen,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    iconColor: contactColor,
                    iconSize: iconSize,
                    titleFontSize: valueFontSize,
                    valueFontSize: labelFontSize,
                    bgColor: contactColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  )
                else
                  if ((market as dynamic).marketEmail != null)
                    _buildContactItem(
                      icon: Icons.email,
                      value: (market as dynamic).marketEmail!,
                      isSmallScreen: isSmallScreen,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      iconColor: contactColor,
                      iconSize: iconSize,
                      titleFontSize: valueFontSize,
                      valueFontSize: labelFontSize,
                      bgColor: contactColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                    ),
              ],
            ),
          ),
        ],
      ),
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
    required double valueFontSize,
    required double labelFontSize,
    required Color textColor,
    required Color? subtitleColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
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
              fontSize: labelFontSize,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String value,
    required bool isSmallScreen,
    required Color textColor,
    required Color? subtitleColor,
    required Color iconColor,
    required double iconSize,
    required double titleFontSize,
    required double valueFontSize,
    required Color bgColor,
  }) {
    final maxLength = isSmallScreen ? 10 : 15;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Could add functionality to call or email
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
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
              icon == Icons.phone ? 'Call' : 'Email',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              _truncateText(value, maxLength),
              style: TextStyle(
                fontSize: valueFontSize,
                color: subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider(bool isSmallScreen, Color dividerColor) {
    return Container(
      height: isSmallScreen ? 40 : 50,
      width: 1,
      color: dividerColor,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildDetailsCard(Markets market,
      bool hasValidNft,
      String? nftAddress,
      bool isSmallScreen,
      bool isDarkMode, {
        Map<String, dynamic>? ownershipDistribution,
        bool loadingDistribution = false,
        String? distributionError,
      }) {
    final normalMarket = market as NormalMarket;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final headingFontSize = isSmallScreen ? 16.0 : 18.0;
    final labelFontSize = isSmallScreen ? 12.0 : 14.0;
    final valueFontSize = isSmallScreen ? 13.0 : 15.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;

    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey[400] : const Color(
        0xFF666666);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);
    final fieldBgColor = isDarkMode ? Colors.grey.shade900 : const Color(
        0xFFEEF7ED);
    final dividerColor = isDarkMode ? Colors.grey.shade800 : Colors.grey
        .shade200;
    final headingColor = isDarkMode ? Colors.white : const Color(0xFF2E7D32);

    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
                padding, padding, padding, isSmallScreen ? 4 : 6),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(
                        isSmallScreen ? 10 : 12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: accentColor,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                Expanded(
                  child: Text(
                    'Blockchain Details',
                    style: TextStyle(
                      fontSize: headingFontSize,
                      fontWeight: FontWeight.bold,
                      color: headingColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 24,
            thickness: 1,
            indent: padding,
            endIndent: padding,
            color: dividerColor,
          ),

          // Wallet address
          _buildCopyableInfoRow(
            label: 'Wallet Public Key',
            value: normalMarket.marketWalletPublicKey,
            icon: Icons.account_balance_wallet_outlined,
            isSmallScreen: isSmallScreen,
            padding: padding,
            labelFontSize: labelFontSize,
            valueFontSize: valueFontSize,
            iconSize: iconSize,
            isDarkMode: isDarkMode,
            fieldBgColor: fieldBgColor,
            accentColor: accentColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),

          // NFT address (if available)
          if (hasValidNft && nftAddress != null)
            _buildCopyableInfoRow(
              label: 'NFT Address',
              value: nftAddress,
              icon: Icons.token_outlined,
              isSmallScreen: isSmallScreen,
              padding: padding,
              labelFontSize: labelFontSize,
              valueFontSize: valueFontSize,
              iconSize: iconSize,
              isDarkMode: isDarkMode,
              fieldBgColor: fieldBgColor,
              accentColor: accentColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),

          if (hasValidNft) ...[
            Padding(
              padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  top: isSmallScreen ? 8 : 12,
                  bottom: isSmallScreen ? 8 : 12),
              child: Text(
                'Token Share Distribution',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 14 : 16,
                  color: subtitleColor,
                ),
              ),
            ),
            if (loadingDistribution)
              Padding(
                padding: EdgeInsets.only(left: padding,
                    right: padding,
                    bottom: isSmallScreen ? 8 : 12),
                child: Row(
                  children: [
                    SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: accentColor)),
                    SizedBox(width: 10),
                    Text('Loading distribution...', style: TextStyle(
                        fontSize: valueFontSize, color: subtitleColor)),
                  ],
                ),
              )
            else
              if (distributionError != null)
                Padding(
                  padding: EdgeInsets.only(
                      left: padding,
                      right: padding,
                      bottom: isSmallScreen ? 8 : 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.redAccent.withOpacity(0.22),
                          width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    child: Row(
                      children: [
                        Icon(Icons.error_rounded, color: Colors.redAccent,
                            size: isSmallScreen ? 22 : 26),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            distributionError!,
                            style: TextStyle(
                              color: Colors.redAccent.shade200,
                              fontSize: valueFontSize + 1,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                if (ownershipDistribution != null &&
                    ownershipDistribution!['ownershipDistribution'] != null &&
                    (ownershipDistribution!['ownershipDistribution'] as List)
                        .isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        left: padding,
                        right: padding,
                        bottom: isSmallScreen ? 8 : 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: fieldBgColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDarkMode
                                ? 0.08
                                : 0.03),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 14.0),
                            child: Row(
                              children: [
                                Icon(Icons.account_circle_rounded,
                                    color: accentColor,
                                    size: isSmallScreen ? 16 : 20),
                                SizedBox(width: 6),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Account ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: subtitleColor,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Share %',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: subtitleColor,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      letterSpacing: 0.2,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: dividerColor, thickness: 1),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: (ownershipDistribution!['ownershipDistribution'] as List)
                                .length,
                            separatorBuilder: (context, idx) =>
                                Divider(height: 1, color: dividerColor),
                            itemBuilder: (context, idx) {
                              final holder = ownershipDistribution!['ownershipDistribution'][idx];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 14.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        holder['accountId'] ?? '',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: isSmallScreen ? 12 : 14,
                                          color: textColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${holder['percentage']
                                            ?.toStringAsFixed(2) ?? '0'}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 12 : 14,
                                          color: accentColor,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  if (ownershipDistribution != null)
                    Padding(
                      padding: EdgeInsets.only(left: padding,
                          right: padding,
                          bottom: isSmallScreen ? 8 : 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: fieldBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: subtitleColor!.withOpacity(0.15)),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: subtitleColor,
                                size: isSmallScreen ? 20 : 24),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No share distribution data available.',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: valueFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ],
        ],
      ),
    );
  }

  Widget _buildCopyableInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isSmallScreen,
    required double padding,
    required double labelFontSize,
    required double valueFontSize,
    required double iconSize,
    required bool isDarkMode,
    required Color fieldBgColor,
    required Color accentColor,
    required Color textColor,
    required Color? subtitleColor,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 10 : 12
            ),
            decoration: BoxDecoration(
              color: fieldBgColor,
              borderRadius: BorderRadius.circular(12),
              border: isDarkMode ? Border.all(
                  color: Colors.grey.shade800, width: 1) : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: accentColor,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    _truncateKey(value, isSmallScreen),
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 0.5,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: accentColor,
                        content: Row(
                          children: [
                            Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: isSmallScreen ? 14 : 16
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            const Text(
                                'Copied to clipboard',
                                style: TextStyle(color: Colors.white)
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.copy,
                      color: accentColor,
                      size: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(Markets market, bool isSmallScreen,
      bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using the horizontal products list widget with responsiveness
          HorizontalProductsList(
            products: market.products,
            marketName: (market as dynamic).marketName,
            marketId: market.id, // Pass the market ID here
            onProductsUpdated: () =>
                context.read<NormalMarketProvider>().loadMarketById(
                    widget.marketId),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProductsView(bool isSmallScreen, bool isDarkMode) {
    final padding = isSmallScreen ? 16.0 : 20.0;
    final headingFontSize = isSmallScreen ? 16.0 : 18.0;
    final descFontSize = isSmallScreen ? 12.0 : 14.0;
    final buttonFontSize = isSmallScreen ? 12.0 : 14.0;
    final imageSize = isSmallScreen ? 80.0 : 100.0;

    final backgroundColor = isDarkMode ? const Color(0xFF252525) : const Color(
        0xFFEEF7ED);
    final borderColor = isDarkMode ? Colors.grey.shade800 : const Color(
        0xFF4CAF50).withOpacity(0.2);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey[400] : const Color(
        0xFF666666);

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 0, padding, padding),
      padding: EdgeInsets.symmetric(
          vertical: padding * 1.5, horizontal: padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: imageSize,
            color: isDarkMode ? Colors.white.withOpacity(0.2) : accentColor
                .withOpacity(0.3),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'No Products Yet',
            style: TextStyle(
              fontSize: headingFontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            'Start adding products to this market to track your inventory',
            style: TextStyle(
              fontSize: descFontSize,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ElevatedButton.icon(
            onPressed: () {
              // Add product functionality
            },
            icon: Icon(Icons.add, size: isSmallScreen ? 16 : 18),
            label: Text('Add First Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w600,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(String productId, bool isSmallScreen,
      bool isDarkMode) {
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 13.0 : 15.0;
    final subtitleFontSize = isSmallScreen ? 10.0 : 12.0;
    final actionIconSize = isSmallScreen ? 16.0 : 18.0;
    final arrowIconSize = isSmallScreen ? 14.0 : 16.0;
    final contentPadding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    final itemBgColor = isDarkMode ? const Color(0xFF252525) : const Color(
        0xFFF5FAF5);
    final borderColor = isDarkMode ? Colors.grey.shade800 : const Color(
        0xFFD8EBD8);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = isDarkMode ? Colors.grey[500] : const Color(
        0xFF777777);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);
    final iconBgColor = isDarkMode ? accentColor.withOpacity(0.2) : accentColor
        .withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: itemBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: contentPadding,
        leading: Container(
          width: isSmallScreen ? 40 : 50,
          height: isSmallScreen ? 40 : 50,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.shopping_basket,
            color: accentColor,
            size: iconSize,
          ),
        ),
        title: Text(
          'Product ID: ${_truncateKey(productId, isSmallScreen)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: titleFontSize,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
          child: Text(
            'Tap to view details',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: subtitleColor,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.copy,
                size: actionIconSize,
                color: accentColor,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: productId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: accentColor,
                    content: Text('Product ID copied',
                        style: TextStyle(color: Colors.white)),
                  ),
                );
              },
              splashRadius: isSmallScreen ? 20 : 24,
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 32 : 40,
                minHeight: isSmallScreen ? 32 : 40,
              ),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: arrowIconSize,
                color: isDarkMode ? Colors.grey.shade400 : const Color(
                    0xFF666666),
              ),
              onPressed: () {
                // Navigate to product details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: accentColor,
                    content: Text(
                        'Product details for ${_truncateKey(
                            productId, isSmallScreen)}'
                    ),
                  ),
                );
              },
              splashRadius: isSmallScreen ? 20 : 24,
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 32 : 40,
                minHeight: isSmallScreen ? 32 : 40,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        onTap: () {
          // Navigate to product details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: accentColor,
              content: Text(
                  'Opening product ${_truncateKey(productId, isSmallScreen)}'
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(String marketId, bool hasValidNft,
      bool isSmallScreen, bool isDarkMode) {
    final buttonHeight = isSmallScreen ? 48.0 : 56.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final iconSize = isSmallScreen ? 18.0 : 24.0;
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasValidNft)
        // Share NFT button
          Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            height: buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _showPutOnSaleDialog(context, marketId, isDarkMode),
              icon: Icon(Icons.share, size: iconSize),
              label: Text(
                'Put Some of your shares on sale',
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          )
        else
        // Create NFT button
          Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            height: buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () => _createNFT(context, marketId, isDarkMode),
              icon: Icon(Icons.token, size: iconSize),
              label: Text(
                'Create NFT for this Market',
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
      ],
    );
  }

  String _truncateKey(String key, bool isSmallScreen) {
    if (isSmallScreen) {
      if (key.length <= 10) return key;
      return '${key.substring(0, 5)}...${key.substring(key.length - 5)}';
    } else {
      if (key.length <= 12) return key;
      return '${key.substring(0, 6)}...${key.substring(key.length - 6)}';
    }
  }

  void reloadMarketWithDelay({required int seconds}) {
    Future.delayed(Duration(seconds: seconds), () {
      if (mounted) {
        context.read<NormalMarketProvider>().loadMarketById(widget.marketId);
        setState(() {}); // To trigger UI rebuild if needed
      }
    });
  }

  void _editMarket(BuildContext context, Markets market) {
    final provider = context.read<NormalMarketProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NormalMarketFormPage(normalMarket: market as NormalMarket?),
      ),
    ).then((_) {
      provider.loadMarketById(market.id);
    });
  }

  void _createNFT(BuildContext context, String marketId, bool isDarkMode) {
    final isSmallScreen = MediaQuery
        .of(context)
        .size
        .width < 360;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final textFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonPadding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    final backgroundColor = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(
        0xFF4CAF50);
    final infoBgColor = isDarkMode ? accentColor.withOpacity(0.2) : const Color(
        0xFFEEF7ED);
    final iconBgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            titlePadding: EdgeInsets.only(
                left: isSmallScreen ? 16 : 24,
                right: isSmallScreen ? 16 : 24,
                top: isSmallScreen ? 16 : 24,
                bottom: isSmallScreen ? 8 : 16
            ),
            title: Row(
              children: [
                Icon(Icons.token,
                    color: accentColor, size: iconSize),
                SizedBox(width: isSmallScreen ? 10 : 14),
                Text('Create NFT',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: infoBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: accentColor,
                          size: isSmallScreen ? 18 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Text(
                          'Creating an NFT will tokenize this market on the blockchain.',
                          style: TextStyle(
                            color: textColor,
                            fontSize: textFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Text(
                  'Are you sure you want to proceed?',
                  style: TextStyle(
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[300] : const Color(
                        0xFF555555),
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.only(
                left: isSmallScreen ? 16 : 24,
                right: isSmallScreen ? 16 : 24,
                bottom: isSmallScreen ? 16 : 24,
                top: isSmallScreen ? 8 : 16
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.grey[300] : const Color(
                      0xFF666666),
                  padding: buttonPadding,
                ),
                child: Text('Cancel',
                    style: TextStyle(fontSize: buttonFontSize)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final provider = context.read<NormalMarketProvider>();
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        AlertDialog(
                          backgroundColor: backgroundColor,
                          content: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: accentColor),
                              SizedBox(width: isSmallScreen ? 16 : 24),
                              Text('Creating NFT...',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: textFontSize)),
                            ],
                          ),
                        ),
                  );

                  try {
                    final success = await provider.createNFT(marketId);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (!context.mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: accentColor,
                          content: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.white,
                                  size: isSmallScreen ? 16 : 18
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 10),
                              Text(
                                'NFT created successfully',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: textFontSize),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'Error creating NFT: ${e.toString()}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: textFontSize),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Create NFT',
                    style: TextStyle(
                        fontSize: buttonFontSize, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }

  // Inside your _NormalMarketDetailsPageState class
  void _showPutOnSaleDialog(BuildContext context, String marketId, bool isDarkMode) {
    int sharesToSell = 100; // Default value
    double pricePerShare = 1.0; // Default value
    bool isLoading = false;

    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final backgroundColor = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              Icon(Icons.sell, color: accentColor, size: isSmallScreen ? 22 : 26),
              SizedBox(width: isSmallScreen ? 10 : 14),
              Expanded(
                child: Text(
                  'Put Shares On Sale',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 20,
                  ),
                ),
              ),
            ],
          ),
          content: isLoading
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: accentColor),
              SizedBox(height: isSmallScreen ? 16 : 24),
              Text(
                'Listing shares for sale...',
                style: TextStyle(color: textColor, fontSize: isSmallScreen ? 14 : 16),
              ),
            ],
          )
              : SizedBox(
            width: isSmallScreen ? 260 : 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount of shares
                Text(
                  'Number of Shares to Sell',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: sharesToSell.toDouble(),
                        min: 1,
                        max: 10000, // Adjust as per your max
                        divisions: 100,
                        label: sharesToSell.toString(),
                        onChanged: (value) {
                          setState(() {
                            sharesToSell = value.round();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        initialValue: sharesToSell.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          int? v = int.tryParse(val);
                          if (v != null) setState(() => sharesToSell = v);
                        },
                        decoration: InputDecoration(
                          hintText: 'Shares',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Price per share
                Text(
                  'Price Per Share',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: accentColor, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: pricePerShare.toStringAsFixed(2),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) {
                          double? v = double.tryParse(val);
                          if (v != null) setState(() => pricePerShare = v);
                        },
                        decoration: InputDecoration(
                          hintText: 'Price per share',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: isLoading
              ? []
              : [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate
                if (sharesToSell < 1 || pricePerShare <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Enter valid share amount and price.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                  return;
                }

                setState(() => isLoading = true);
                try {
                  final headers = await _getAuthHeaders();
                  final response = await http.post(
                    Uri.parse('http://192.168.128.4:3000/normal/$marketId/list-shares-for-sale'),
                    headers: headers,
                    body: jsonEncode({
                      "shares": sharesToSell,
                      "pricePerShare": pricePerShare,
                    }),
                  );

                  if (context.mounted) Navigator.pop(dialogContext);

                  final Map<String, dynamic> result = jsonDecode(response.body);

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    // Success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: accentColor,
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Shares listed for sale!',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          result['message'] ?? 'Failed to list shares.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Error: ${e.toString()}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: Text('Put On Sale'),
            ),
          ],
        ),
      ),
    );
  }
  void _deleteMarket(BuildContext context, String marketId, bool isDarkMode) {
    final isSmallScreen = MediaQuery
        .of(context)
        .size
        .width < 360;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final textFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final contentPadding = EdgeInsets.all(isSmallScreen ? 16 : 24);
    final buttonPadding = EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 10 : 12
    );

    final backgroundColor = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
    final warningColor = isDarkMode ? Colors.redAccent.shade200 : Colors
        .redAccent;
    final warningBgColor = isDarkMode
        ? warningColor.withOpacity(0.2)
        : warningColor.withOpacity(0.1);
    final warningBorderColor = isDarkMode
        ? warningColor.withOpacity(0.4)
        : warningColor.withOpacity(0.3);
    final subtitleColor = isDarkMode ? Colors.grey[300] : const Color(
        0xFF555555);
    final iconBgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final cancelButtonColor = isDarkMode ? Colors.grey[300] : const Color(
        0xFF666666);

    showDialog(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)
            ),
            contentPadding: contentPadding,
            titlePadding: EdgeInsets.only(
                left: isSmallScreen ? 16 : 24,
                right: isSmallScreen ? 16 : 24,
                top: isSmallScreen ? 16 : 24,
                bottom: isSmallScreen ? 8 : 16
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: warningColor, size: iconSize),
                SizedBox(width: isSmallScreen ? 10 : 14),
                Expanded(
                  child: Text('Delete Market',
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize
                      )
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: warningBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: warningBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: warningColor,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. All market data will be permanently deleted.',
                          style: TextStyle(
                            color: textColor,
                            fontSize: textFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Text(
                  'Are you sure you want to delete this market?',
                  style: TextStyle(
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.only(
                left: isSmallScreen ? 16 : 24,
                right: isSmallScreen ? 16 : 24,
                bottom: isSmallScreen ? 16 : 24,
                top: isSmallScreen ? 8 : 16
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: cancelButtonColor,
                  padding: buttonPadding,
                ),
                child: Text('Cancel',
                    style: TextStyle(fontSize: buttonFontSize)
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext)
                      .pop(); // Close confirmation dialog

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) =>
                        AlertDialog(
                          backgroundColor: backgroundColor,
                          content: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: warningColor,
                                strokeWidth: isSmallScreen ? 2.5 : 3,
                              ),
                              SizedBox(width: isSmallScreen ? 16 : 24),
                              Text('Deleting market...',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: textFontSize
                                  )
                              ),
                            ],
                          ),
                        ),
                  );

                  try {
                    final provider = context.read<NormalMarketProvider>();
                    final success = await provider.removeMarket(marketId);

                    if (mounted) Navigator.of(context, rootNavigator: true)
                        .pop(); // Close loading dialog

                    if (!mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: isDarkMode
                              ? const Color(0xFF81C784)
                              : const Color(0xFF4CAF50),
                          content: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.white,
                                  size: isSmallScreen ? 16 : 18
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 10),
                              Text(
                                'Market deleted successfully',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      // Go back to markets list after deletion
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text(
                            'Failed to delete market',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 16
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) Navigator.of(context, rootNavigator: true)
                        .pop();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'Error deleting market: ${e.toString()}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: warningColor,
                  foregroundColor: Colors.white,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                ),
                child: Text('Delete',
                    style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ],
          ),
    );
  }
}