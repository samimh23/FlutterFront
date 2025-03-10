import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_detail_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/normal_market_form_page.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:provider/provider.dart';

class NormalMarketsPage extends StatefulWidget {
  const NormalMarketsPage({Key? key}) : super(key: key);

  @override
  State<NormalMarketsPage> createState() => _NormalMarketsPageState();
}

class _NormalMarketsPageState extends State<NormalMarketsPage> {
  late NormalMarketProvider _provider;

  @override
  void initState() {
    super.initState();
    // Store provider reference to avoid context in async gaps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<NormalMarketProvider>(context, listen: false);
      _provider.loadMarkets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // More responsive grid configuration
    final crossAxisCount = screenSize.width > 1200
        ? 4
        : screenSize.width > 900
            ? 3
            : screenSize.width > 600
                ? 2
                : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: Consumer<NormalMarketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF24C168), // Green accent
              ),
            );
          } else if (provider.errorMessage.isNotEmpty) {
            return _buildErrorView(provider);
          } else if (provider.markets.isEmpty) {
            return _buildEmptyView();
          }

          return _buildDashboardView(provider, screenSize, crossAxisCount);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMarket(),
        tooltip: 'Add Market',
        backgroundColor: const Color(0xFF24C168), // Green button
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add, size: 24),
        label: const Text('New Market',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // Organized error view into a separate method
  Widget _buildErrorView(NormalMarketProvider provider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              'Error Loading Markets',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => provider.loadMarkets(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24C168), // Green button
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 22),
              label: const Text('Try Again', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Organized empty view into a separate method
  Widget _buildEmptyView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        constraints: const BoxConstraints(maxWidth: 550),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF24C168).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 90,
                color: Color(0xFF24C168),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'No Markets Yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Create your first market to get started with managing your business',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddMarket(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24C168), // Green button
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add, size: 24),
              label:
                  const Text('Create Market', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Main dashboard view with stats
  Widget _buildDashboardView(
      NormalMarketProvider provider, Size screenSize, int crossAxisCount) {
    final marketsCount = provider.markets.length;
    final hasNftCount = provider.markets
        .where((m) =>
            (m as dynamic).fractionalNFTAddress != null &&
            (m as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED")
        .length;

    // Calculate average ownership
    double averageOwnership = 0;
    if (marketsCount > 0) {
      averageOwnership = provider.markets
              .fold(0.0, (sum, m) => sum + (m as dynamic).fractions) /
          marketsCount;
    }

    return RefreshIndicator(
      color: const Color(0xFF24C168),
      onRefresh: () => provider.loadMarkets(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 16),
                      child: Text(
                        'Markets Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    LayoutBuilder(builder: (context, constraints) {
                      final isTiny = constraints.maxWidth < 600;
                      final isSmall = constraints.maxWidth < 900;

                      if (isTiny) {
                        // Stack cards vertically on very small screens
                        return Column(
                          children: _buildStatCards(
                              marketsCount, hasNftCount, averageOwnership),
                        );
                      }

                      // Use a responsive row/grid approach for larger screens
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: _buildStatCards(
                            marketsCount, hasNftCount, averageOwnership),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Markets Header with Search (placeholder for future enhancement)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Markets',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // This could be expanded into a real search feature
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort, color: Colors.white70, size: 20),
                        SizedBox(width: 6),
                        Text('Sort',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Markets Grid in a Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75, // Taller cards for better layout
                  ),
                  itemCount: provider.markets.length,
                  itemBuilder: (context, index) {
                    final market = provider.markets[index];
                    return _buildMarketCard(market);
                  },
                ),
              ),

              // Add padding at the bottom
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build stat cards
  List<Widget> _buildStatCards(
      int marketsCount, int hasNftCount, double averageOwnership) {
    return [
      _buildStatCard(
        title: 'Total Markets',
        value: '$marketsCount',
        icon: Icons.storefront,
        color: Colors.blueAccent,
      ),
      _buildStatCard(
        title: 'NFT Markets',
        value: '$hasNftCount',
        icon: Icons.token,
        color: const Color(0xFF24C168),
      ),
      _buildStatCard(
        title: 'Avg. Ownership',
        value: '${averageOwnership.toStringAsFixed(1)}%',
        icon: Icons.pie_chart,
        color: Colors.amber,
      ),
    ];
  }

  // Helper method to build a stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCard(Markets market) {
    final String? imagePath = (market as dynamic).marketImage;
    final bool hasNft = (market as dynamic).fractionalNFTAddress != null &&
        (market as dynamic).fractionalNFTAddress != "PENDING_FUNDING_NEEDED";

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      color: const Color(0xFF2A2A2A), // Darker card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => _navigateToMarketDetails(market.id),
        splashColor: const Color(0xFF24C168).withOpacity(0.3),
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Image - with proper URL handling
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMarketImage(imagePath),
                  // Add gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // Ownership badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF24C168).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pie_chart,
                            size: 14,
                            color: Color(0xFF24C168),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(market as dynamic).fractions}% owned',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Market Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (market as dynamic).marketName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (market as dynamic).marketLocation,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // NFT Status indicator
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: hasNft
                          ? const Color(0xFF24C168).withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasNft
                            ? const Color(0xFF24C168).withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasNft ? Icons.token : Icons.token_outlined,
                          size: 16,
                          color: hasNft ? const Color(0xFF24C168) : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasNft ? 'NFT Active' : 'No NFT',
                          style: TextStyle(
                            color:
                                hasNft ? const Color(0xFF24C168) : Colors.grey,
                            fontSize: 13,
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
      ),
    );
  }

  Widget _buildMarketImage(String? imagePath) {
    if (imagePath == null ||
        imagePath.isEmpty ||
        imagePath == 'image_url_here') {
      return Container(
        color:
            const Color(0xFF3A3A3A), // Slightly lighter background for contrast
        child: const Center(
          child: Icon(Icons.store, size: 50, color: Colors.grey),
        ),
      );
    }

    // Fix backslashes in paths coming from server
    final String normalizedPath = imagePath.replaceAll('\\', '/');

    // Process the image URL using ApiConstants
    final String imageUrl = ApiConstants.getFullImageUrl(normalizedPath);

    // Use BoxDecoration approach for better CORS handling in Flutter Web
    return Container(
      decoration: BoxDecoration(
        color:
            const Color(0xFF3A3A3A), // Slightly lighter background for contrast
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            print('Decoration image error for: $imageUrl');
          },
        ),
      ),
      // Fallback when image fails to load
      child: Stack(
        children: [
          // Error placeholder that only shows when the network image fails
          Center(
            child: Icon(Icons.image_not_supported,
                size: 40, color: Colors.grey.withOpacity(0.5)),
          ),

          // Transparent image widget that will "succeed" even if the background fails
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stack) {
              // Just return a transparent placeholder
              return const SizedBox.shrink();
            },
            // Make sure it's in front but invisible
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _navigateToMarketDetails(String marketId) {
    // Store reference to provider before navigation
    final provider = _provider;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NormalMarketDetailsPage(marketId: marketId),
      ),
    ).then((_) {
      // Use stored provider reference to avoid context issues
      if (mounted) {
        provider.loadMarkets();
      }
    });
  }

  void _navigateToAddMarket() {
    // Store reference to provider before navigation
    final provider = _provider;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NormalMarketFormPage(),
      ),
    ).then((_) {
      // Use stored provider reference to avoid context issues
      if (mounted) {
        provider.loadMarkets();
      }
    });
  }
}
