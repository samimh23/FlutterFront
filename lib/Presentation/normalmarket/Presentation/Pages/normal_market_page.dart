import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_detail_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_form_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NormalMarketsPage extends StatefulWidget {
  const NormalMarketsPage({Key? key}) : super(key: key);

  @override
  State<NormalMarketsPage> createState() => _NormalMarketsPageState();
}

class _NormalMarketsPageState extends State<NormalMarketsPage> {
  late NormalMarketProvider _provider;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<NormalMarketProvider>(context, listen: false);
      _provider.loadMyMarkets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final crossAxisCount = screenSize.width > 1200
        ? 4
        : screenSize.width > 900
        ? 3
        : screenSize.width > 600
        ? 2
        : 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3), // Light cream background
      body: Consumer<NormalMarketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingMyMarkets) {
            return _buildLoadingView();
          } else if (provider.errorMessage.isNotEmpty) {
            return _buildErrorView(provider);
          } else if (provider.markets.isEmpty) {
            return _buildEmptyView();
          }

          return _buildMarketplaceView(provider, screenSize, crossAxisCount);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMarket(),
        backgroundColor: const Color(0xFF4CAF50), // Fresh green
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'), // Add a light pattern background
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'icons/loading_basket.png', // Add a basket loading animation
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading markets...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(NormalMarketProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          width: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'icons/loading_basket.png', // Add an empty basket image
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Could not load markets',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => provider.loadMyMarkets(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          width: 550,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'icons/plant_growth.png', // Add a plant growth image
                height: 160,
                width: 160,
              ),
              const SizedBox(height: 30),
              const Text(
                'Start Your Market',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create your first market to start selling tokenized fresh produce',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _navigateToAddMarket(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: StadiumBorder(),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 10),
                    Text('Create Market', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceView(NormalMarketProvider provider, Size screenSize, int crossAxisCount) {
    final marketsCount = provider.myMarkets.length;
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

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: RefreshIndicator(
        color: const Color(0xFF4CAF50),
        onRefresh: () => provider.loadMyMarkets(),
        child: CustomScrollView(
          slivers: [
            // Marketplace Header
            SliverToBoxAdapter(
              child: _buildMarketHeader(),
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildStatsRow(marketsCount, hasNftCount, averageOwnership),
              ),
            ),

            // View Toggle and Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Markets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Row(
                      children: [
                        // View Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              _buildViewToggleButton(
                                isSelected: _isGridView,
                                icon: Icons.grid_view_rounded,
                                onPressed: () => setState(() => _isGridView = true),
                              ),
                              _buildViewToggleButton(
                                isSelected: !_isGridView,
                                icon: Icons.view_list_rounded,
                                onPressed: () => setState(() => _isGridView = false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Filter Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.filter_list),
                            color: const Color(0xFF4CAF50),
                            onPressed: () {
                              // Filter functionality could be added here
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Market Items
            _isGridView
                ? _buildMarketsGrid(provider, crossAxisCount)
                : _buildMarketsList(provider),

            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 30, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fresh Market',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tokenized marketplace Tokenized Prodcut',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF888888)),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search markets...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 16,
                        color: Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int marketsCount, int hasNftCount, double averageOwnership) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.store,
              iconColor: const Color(0xFF4CAF50),
              bgColor: const Color(0xFF4CAF50).withOpacity(0.1),
              value: '$marketsCount',
              label: 'Markets',
            ),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.token,
              iconColor: const Color(0xFFFF9800),
              bgColor: const Color(0xFFFF9800).withOpacity(0.1),
              value: '$hasNftCount',
              label: 'Tokenized',
            ),
          ),
          _buildStatDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.pie_chart,
              iconColor: const Color(0xFF2196F3),
              bgColor: const Color(0xFF2196F3).withOpacity(0.1),
              value: '${averageOwnership.toStringAsFixed(1)}%',
              label: 'Avg Ownership',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleButton({
    required bool isSelected,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildMarketsGrid(NormalMarketProvider provider, int crossAxisCount) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMarketCard(provider.myMarkets[index]),
          childCount: provider.myMarkets.length,
        ),
      ),
    );
  }

  Widget _buildMarketsList(NormalMarketProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMarketListItem(provider.myMarkets[index]),
          ),
          childCount: provider.myMarkets.length,
        ),
      ),
    );
  }

  Widget _buildMarketCard(Markets market) {
    final String? imagePath = (market as dynamic).marketImage;
    final bool hasNft = (market as dynamic).fractionalNFTAddress != null &&
        (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";
    final double ownership = (market as dynamic).fractions.toDouble() / 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToMarketDetails(market.id),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with rounded corners just on top
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Market Image
                    _buildMarketImage(imagePath),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),

                    // Token Badge
                    if (hasNft)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.token,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tokenized',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Location Badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (market as dynamic).marketLocation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
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

            // Market Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Market Name
                  Text(
                    (market as dynamic).marketName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Ownership Info
                  Row(
                    children: [
                      // Ownership Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pie_chart,
                          size: 14,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Ownership Text
                      Expanded(
                        child: Text(
                          '$ownership% Ownership',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToMarketDetails(market.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Manage'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketListItem(Markets market) {
    final String? imagePath = (market as dynamic).marketImage;
    final bool hasNft = (market as dynamic).fractionalNFTAddress != null &&
        (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";
    final double ownership = (market as dynamic).fractions.toDouble() / 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToMarketDetails(market.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Market Image - Square with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _buildMarketImage(imagePath),
                ),
              ),
              const SizedBox(width: 16),

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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // NFT Badge
                        if (hasNft)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.token,
                                  size: 14,
                                  color: Color(0xFF4CAF50),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tokenized',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            (market as dynamic).marketLocation,
                            style: const TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Ownership info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pie_chart,
                            size: 14,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$ownership% Ownership',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button
              Container(
                margin: const EdgeInsets.only(left: 16),
                child: IconButton(
                  onPressed: () => _navigateToMarketDetails(market.id),
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  color: const Color(0xFF4CAF50),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'image_url_here') {
      return Container(
        color: const Color(0xFFEEF7ED), // Light green background
        child: Center(
          child: Image.asset(
            'icons/loading_basket.png', // Replace with a vegetable/fruit basket placeholder
            width: 50,
            height: 50,
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
        Container(color: const Color(0xFFEEF7ED)),

        // Actual image
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            return Center(
              child: Image.asset(
                'icons/loading_basket.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF4CAF50),
                strokeWidth: 2,
              ),
            );
          },
        ),
      ],
    );
  }

  void _navigateToMarketDetails(String marketId) {
    final provider = _provider;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NormalMarketDetailsPage(marketId: marketId),
      ),
    ).then((_) {
      if (mounted) {
        provider.loadMarkets();
      }
    });
  }

  void _navigateToAddMarket() {
    final provider = _provider;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NormalMarketFormPage(),
      ),
    ).then((_) {
      if (mounted) {
        provider.loadMarkets();
      }
    });
  }
}