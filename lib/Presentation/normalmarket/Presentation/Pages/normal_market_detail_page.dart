import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Widgets/products_grid.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NormalMarketProvider>().loadMarketById(widget.marketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3), // Light cream background
      body: Consumer<NormalMarketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingView();
          } else if (provider.errorMessage.isNotEmpty) {
            return _buildErrorView(provider);
          } else if (provider.selectedMarket == null) {
            return _buildEmptyView();
          }

          final market = provider.selectedMarket!;
          final String? imagePath = (market as dynamic).marketImage;
          final String? nftAddress = (market as dynamic).fractionalNFTAddress;
          final bool hasValidNft =
              nftAddress != null && nftAddress != "PENDING_FUNDING_NEEDED";

          return CustomScrollView(
            slivers: [
              // Sliver App Bar with expandable image
              _buildSliverAppBar(market, imagePath, hasValidNft),

              // Market content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Stats card
                      _buildStatsCard(market),

                      const SizedBox(height: 24),

                      // Market details card
                      _buildDetailsCard(market, hasValidNft, nftAddress),

                      const SizedBox(height: 24),

                      // Products section
                      _buildProductsCard(market),

                      const SizedBox(height: 30),

                      // Action buttons
                      _buildActionButtons(market.id, hasValidNft),

                      const SizedBox(height: 40),
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

  Widget _buildLoadingView() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('icons/fruits_pattern_light.gif'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'icons/loading_basket.png',
              height: 120,
              width: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading market details...',
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
                'assets/images/empty_basket.png',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Could not load market',
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
                onPressed: () => provider.loadMarketById(widget.marketId),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                'assets/images/empty_basket.png',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'Market not found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF555555),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Markets', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Markets market, String? imagePath, bool hasNft) {
    return SliverAppBar(
      expandedHeight: 240.0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Market image
            _buildMarketBackgroundImage(imagePath),

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
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (market as dynamic).marketName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (hasNft)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(20),
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
                              Icon(Icons.token, color: Colors.white, size: 16),
                              SizedBox(width: 6),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (market as dynamic).marketLocation,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          shadows: [
                            const Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.edit_outlined,
                    color: Colors.grey,

                    onPressed: () => _editMarket(context, market),
                  ),
                  const SizedBox(width: 8),
                  _buildCircleButton(
                    icon: Icons.delete_outline,
                    color: Colors.grey,
                    onPressed: () => _deleteMarket(context, market.id),
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
    Color color = const Color(0xFF4CAF50),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
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
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minHeight: 40,
          minWidth: 40,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMarketBackgroundImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'image_url_here') {
      return Container(
        color: const Color(0xFF4CAF50).withOpacity(0.2),
        child: Center(
          child: Image.asset(
            'assets/images/vegetable_placeholder.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // Fix backslashes in paths coming from server
    final String normalizedPath = imagePath.replaceAll('\\', '/');

    // Process the image URL correctly
    final String imageUrl = ApiConstants.getFullImageUrl(normalizedPath);

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          child: Center(
            child: Image.asset(
              'assets/images/vegetable_placeholder.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          color: const Color(0xFFEEF7ED),
          child: Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF4CAF50),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(Markets market) {
    final double ownership = (market as dynamic).fractions.toDouble() / 100;
    final int productsCount = market.products.length;

    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                _buildStatItem(
                  icon: Icons.pie_chart,
                  iconColor: const Color(0xFF2196F3),
                  bgColor: const Color(0xFF2196F3).withOpacity(0.1),
                  value: '$ownership%',
                  label: 'Ownership',
                ),
                _buildStatDivider(),
                _buildStatItem(
                  icon: Icons.shopping_basket,
                  iconColor: const Color(0xFFFF9800),
                  bgColor: const Color(0xFFFF9800).withOpacity(0.1),
                  value: productsCount.toString(),
                  label: 'Products',
                ),
                if ((market as dynamic).marketPhone != null || (market as dynamic).marketEmail != null)
                  _buildStatDivider(),
                if ((market as dynamic).marketPhone != null)
                  _buildContactItem(
                    icon: Icons.phone,
                    value: (market as dynamic).marketPhone!,
                  )
                else if ((market as dynamic).marketEmail != null)
                  _buildContactItem(
                    icon: Icons.email,
                    value: (market as dynamic).marketEmail!,
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
  }) {
    return Expanded(
      child: Column(
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
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String value,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Could add functionality to call or email
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              icon == Icons.phone ? 'Call' : 'Email',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _truncateText(value, 15),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildDetailsCard(Markets market, bool hasValidNft, String? nftAddress) {
    // Cast market to NormalMarket to access specific properties
    final normalMarket = market as NormalMarket;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Blockchain Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24, thickness: 1, indent: 20, endIndent: 20),

          // Wallet address
          _buildCopyableInfoRow(
            label: 'Wallet Public Key',
            value: normalMarket.marketWalletPublicKey,
            icon: Icons.account_balance_wallet_outlined,
          ),

          // NFT address (if available)
          if (hasValidNft && nftAddress != null)
            _buildCopyableInfoRow(
              label: 'NFT Address',
              value: nftAddress,
              icon: Icons.token_outlined,
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
  Widget _buildCopyableInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _truncateKey(value),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF4CAF50),
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('Copied to clipboard', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: Color(0xFF4CAF50),
                      size: 16,
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

  Widget _buildProductsCard(Markets market) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using the horizontal products list widget
          HorizontalProductsList(
            products: market.products,
            marketName: (market as dynamic).marketName,
            marketId: market.id, // Pass the market ID here
            onProductsUpdated: () => context.read<NormalMarketProvider>().loadMarketById(widget.marketId),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProductsView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'icons/groceries.png',
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Products Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Start adding products to this market to track your inventory',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Add product functionality
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add First Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(Markets market) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: market.products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final productId = market.products[index];
          return _buildProductItem(productId);
        },
      ),
    );
  }

  Widget _buildProductItem(String productId) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD8EBD8),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.shopping_basket,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        title: Text(
          'Product ID: ${_truncateKey(productId)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontSize: 15,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Tap to view details',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.copy,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: productId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF4CAF50),
                    content: Text('Product ID copied', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
              splashRadius: 24,
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF666666),
              ),
              onPressed: () {
                // Navigate to product details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF4CAF50),
                    content: Text('Product details for ${_truncateKey(productId)}'),
                  ),
                );
              },
              splashRadius: 24,
            ),
          ],
        ),
        onTap: () {
          // Navigate to product details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF4CAF50),
              content: Text('Opening product ${_truncateKey(productId)}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(String marketId, bool hasValidNft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasValidNft)
        // Share NFT button
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showShareNFTDialog(context, marketId),
              icon: const Icon(Icons.share),
              label: const Text('Share NFT Ownership'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 2,
              ),
            ),
          )
        else
        // Create NFT button
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => _createNFT(context, marketId),
              icon: const Icon(Icons.token),
              label: const Text('Create NFT for this Market'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 2,
              ),
            ),
          ),
      ],
    );
  }

  String _truncateKey(String key) {
    if (key.length <= 12) return key;
    return '${key.substring(0, 6)}...${key.substring(key.length - 6)}';
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

  void _createNFT(BuildContext context, String marketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.token,
                color: Color(0xFF4CAF50), size: 24),
            SizedBox(width: 14),
            Text('Create NFT',
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Creating an NFT will tokenize this market on the blockchain.',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you sure you want to proceed?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF666666),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<NormalMarketProvider>();
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF4CAF50)),
                      const SizedBox(width: 24),
                      const Text('Creating NFT...',
                          style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16)),
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
                    const SnackBar(
                      backgroundColor: Color(0xFF4CAF50),
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'NFT created successfully',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16),
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
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Create NFT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Inside your _NormalMarketDetailsPageState class
  void _showShareNFTDialog(BuildContext context, String marketId) {
    final recipientController = TextEditingController();
    int percentageToShare = 10; // Default value
    String? selectedRecipientType; // Will be null by default, 'user' or 'market'
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.share, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 14),
              Text(
                'Share NFT Ownership',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: isLoading
              ? Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF4CAF50)),
                const SizedBox(height: 24),
                const Text(
                  'Processing share request...',
                  style: TextStyle(color: Color(0xFF333333), fontSize: 16),
                ),
              ],
            ),
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient Type Selection
              const Text(
                'Recipient Type',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD8EBD8),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedRecipientType,
                    hint: const Text('Select recipient type (optional)'),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
                    style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
                    dropdownColor: Colors.white,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Auto-detect'),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'user',
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Color(0xFF4CAF50), size: 18),
                            SizedBox(width: 8),
                            Text('User'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem<String>(
                        value: 'market',
                        child: Row(
                          children: [
                            Icon(Icons.store, color: Color(0xFF4CAF50), size: 18),
                            SizedBox(width: 8),
                            Text('Market'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRecipientType = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Recipient Address
              const Text(
                'Recipient Address',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: recipientController,
                style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter wallet address or ID',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.3),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEEF7ED),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  prefixIcon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Percentage to Share
              const Text(
                'Percentage to Share',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$percentageToShare%',
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'You keep ${100 - percentageToShare}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFF4CAF50),
                        inactiveTrackColor: Colors.grey.shade200,
                        thumbColor: Colors.white,
                        overlayColor: const Color(0xFF4CAF50).withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: percentageToShare.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        onChanged: (value) {
                          setState(() {
                            percentageToShare = value.round();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Information about recipient type
              if (selectedRecipientType != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedRecipientType == 'user'
                              ? 'You selected "User". Enter a user ID or Hedera account.'
                              : 'You selected "Market". Enter a market ID or Hedera account.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: isLoading
              ? []
              : [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Use dialogContext here
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF666666),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                if (recipientController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Please enter recipient address',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Set loading state
                setState(() {
                  isLoading = true;
                });

                // Get provider and call shareNFT
                final provider = context.read<NormalMarketProvider>();

                // Store important data in local variables
                final String recipient = recipientController.text;
                final int percentage = percentageToShare;
                final String? recipientType = selectedRecipientType;

                provider.shareNFT(
                  marketId,
                  recipient,
                  percentage,
                  recipientType: recipientType,
                ).then((result) {
                  // Close dialog immediately
                  Navigator.pop(dialogContext);

                  // Reload market data
                  provider.loadMarketById(marketId);

                  // Show success or error message
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF4CAF50),
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text(
                              'NFT shared successfully',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    // Show error message from the response
                    String errorMessage = result['message'] ?? 'Failed to share NFT';

                    // Check if it's a token association error
                    if (errorMessage.contains('TOKEN_NOT_ASSOCIATED_TO_ACCOUNT') ||
                        errorMessage.contains('token association required')) {
                      errorMessage = 'Token association required. The recipient must associate with the token first.';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }).catchError((e) {
                  // Always close the dialog on error
                  Navigator.pop(dialogContext);

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Error sharing NFT: ${e.toString()}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Share NFT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Dispose of controller when dialog is closed
      recipientController.dispose();
      // Refresh market data when dialog is closed
      context.read<NormalMarketProvider>().loadMarketById(marketId);
    });
  }

  void _deleteMarket(BuildContext context, String marketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 24),
            SizedBox(width: 14),
            Text('Delete Market',
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This action cannot be undone. All market data will be permanently deleted.',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you sure you want to delete this market?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF666666),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<NormalMarketProvider>();
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.redAccent),
                      const SizedBox(width: 24),
                      const Text('Deleting market...',
                          style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16)),
                    ],
                  ),
                ),
              );

              try {
                final success = await provider.removeMarket(marketId);

                if (context.mounted) {
                  Navigator.pop(context);
                }

                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF4CAF50),
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Market deleted successfully',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context); // Go back to markets list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Failed to delete market',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                      'Error deleting market: ${e.toString()}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete Market',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}