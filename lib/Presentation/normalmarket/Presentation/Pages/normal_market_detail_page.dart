
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
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
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark app bar
        title:
            const Text('Market Details', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        actions: [
          Consumer<NormalMarketProvider>(
            builder: (context, provider, child) {
              if (provider.selectedMarket != null) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.token,
                          color: Color(0xFF24C168)), // Green icon for NFT
                      tooltip: 'Create NFT',
                      onPressed: () =>
                          _createNFT(context, provider.selectedMarket!.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Edit Market',
                      onPressed: () =>
                          _editMarket(context, provider.selectedMarket!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Delete Market',
                      onPressed: () =>
                          _deleteMarket(context, provider.selectedMarket!.id),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NormalMarketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF24C168), // Green accent for contrast
              ),
            );
          } else if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24C168), // Green button
                      foregroundColor: Colors.white, // White text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => provider.loadMarketById(widget.marketId),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (provider.selectedMarket == null) {
            return const Center(
              child: Text(
                'Market not found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final market = provider.selectedMarket!;
          final String? imagePath = (market as dynamic).marketImage;
          final String? nftAddress = (market as dynamic).fractionalNFTAddress;
          final bool hasValidNft =
              nftAddress != null && nftAddress != "PENDING_FUNDING_NEEDED";

          // Calculate optimal width for cards - increased for better usability
          final screenWidth = MediaQuery.of(context).size.width;
          final contentWidth = screenWidth > 800
              ? 750.0 // Max width for larger screens - increased
              : screenWidth > 600
                  ? screenWidth * 0.85 // 85% of width for medium screens
                  : screenWidth -
                      32.0; // Full width minus padding for small screens

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: contentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card for market header with image
                    Card(
                      color: const Color(0xFF1E1E1E),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Increased image height
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: _buildMarketImage(imagePath),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.all(20.0), // Increased padding
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (market as dynamic).marketName,
                                  style: const TextStyle(
                                    fontSize: 24, // Increased font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16), // Increased spacing
                                _buildInfoRow(Icons.location_on,
                                    (market as dynamic).marketLocation),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20), // Increased spacing

                    // Market details card
                    Card(
                      color: const Color(0xFF1E1E1E),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(20.0), // Increased padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Market Details',
                              style: TextStyle(
                                fontSize: 20, // Increased font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16), // Increased spacing
                            if ((market as dynamic).marketPhone != null)
                              _buildInfoRow(Icons.phone,
                                  (market as dynamic).marketPhone!),
                            if ((market as dynamic).marketEmail != null)
                              _buildInfoRow(Icons.email,
                                  (market as dynamic).marketEmail!),

                            const SizedBox(height: 8),

                            // Wallet public key with improved copy button
                            _buildCompactCopyableRow(
                              Icons.account_balance_wallet,
                              'Public Key',
                              _truncateKey(
                                  (market as dynamic).marketWalletPublicKey),
                              (market as dynamic).marketWalletPublicKey,
                            ),

                            const SizedBox(height: 12), // Increased spacing
                            _buildInfoRow(Icons.pie_chart,
                                'Ownership: ${(market as dynamic).fractions}%'),

                            // NFT address with improved copy button
                            if (hasValidNft)
                              const SizedBox(height: 12), // Increased spacing
                            if (hasValidNft)
                              _buildCompactCopyableRow(
                                Icons.token,
                                'NFT Address',
                                _truncateKey(
                                    (market as dynamic).fractionalNFTAddress!),
                                (market as dynamic).fractionalNFTAddress!,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Increased spacing

                    // Products card
                    Card(
                      color: const Color(0xFF1E1E1E),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(20.0), // Increased padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Products',
                              style: TextStyle(
                                fontSize: 20, // Increased font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16), // Increased spacing
                            market.products.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30), // Increased padding
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'No products available',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize:
                                                16), // Increased font size
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: market.products.length,
                                    itemBuilder: (context, index) {
                                      final productId = market.products[index];
                                      return Container(
                                        margin: const EdgeInsets.only(
                                            bottom: 12.0), // Increased margin
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2A2A2A),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 16,
                                              vertical:
                                                  8), // Added vertical padding
                                          title: Text(
                                            'Product ID: ${_truncateKey(productId)}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    15), // Increased font size
                                          ),
                                          leading: const CircleAvatar(
                                            backgroundColor: Color(0xFF24C168),
                                            radius: 22, // Increased size
                                            child: Icon(Icons.shopping_basket,
                                                color: Colors.white,
                                                size:
                                                    24), // Increased icon size
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.copy,
                                                color: Colors.white54,
                                                size:
                                                    20), // Increased icon size
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: productId));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  backgroundColor:
                                                      Color(0xFF24C168),
                                                  content: Text(
                                                    'Product ID copied',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          onTap: () {
                                            // Navigate to product details
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    const Color(0xFF24C168),
                                                content: Text(
                                                  'Product details for $productId',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30), // Increased spacing

                    // Action buttons
                    // Show Share NFT button only if NFT is valid (not null and not pending)
                    if (hasValidNft)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showShareNFTDialog(context, market.id),
                        icon: const Icon(Icons.share,
                            size: 22), // Increased icon size
                        label: const Text('Share NFT Ownership',
                            style:
                                TextStyle(fontSize: 16)), // Increased font size
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24C168),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24), // Increased padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),

                    // Show Create NFT button if NFT is null or pending
                    if (!hasValidNft)
                      ElevatedButton.icon(
                        onPressed: () => _createNFT(context, market.id),
                        icon: const Icon(Icons.token,
                            size: 22), // Increased icon size
                        label: const Text('Create NFT for this Market',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)), // Increased font size
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24C168),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24), // Increased padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Updated helper method to build market image with increased height
  Widget _buildMarketImage(String? imagePath) {
    // If image path is null or empty, return placeholder
    if (imagePath == null ||
        imagePath.isEmpty ||
        imagePath == 'image_url_here') {
      return Container(
        height: 180, // Increased image height
        color: const Color(0xFF2A2A2A), // Darker placeholder
        child: const Icon(Icons.store,
            size: 60, color: Colors.grey), // Increased icon size
      );
    }

    // Process the image URL correctly
    final String imageUrl = ApiConstants.getFullImageUrl(imagePath);

    // For Flutter Web - using standard Image.network but with additional configurations
    return Image.network(
      imageUrl,
      height: 180, // Increased image height
      fit: BoxFit.cover,

      // Key for Flutter Web - load image through direct cache
      cacheHeight: 540, // Increased cached image height
      cacheWidth: 960,

      // Ensure fallback on error
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180, // Increased image height
          color: const Color(0xFF2A2A2A), // Darker placeholder
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Image not available',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ],
          ),
        );
      },

      // Show loading indicator
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          height: 180, // Increased image height
          color: const Color(0xFF2A2A2A), // Darker placeholder
          child: Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF24C168), // Green accent for visibility
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

  // Standard info row
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Increased padding
      child: Row(
        children: [
          Icon(icon,
              color: const Color(0xFF24C168), size: 22), // Increased icon size
          const SizedBox(width: 14), // Increased spacing
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15, // Increased font size
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Improved compact copyable row with label and value
  Widget _buildCompactCopyableRow(
      IconData icon, String label, String displayText, String copyText) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Increased margin
      padding: const EdgeInsets.all(14), // Increased padding
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10), // Increased radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: const Color(0xFF24C168),
                  size: 18), // Increased icon size
              const SizedBox(width: 10), // Increased spacing
              Text(label,
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14, // Increased font size
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8), // Increased spacing
          Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 16, // Increased font size
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(
                  minWidth: 40, // Increased constraints
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
                icon: Container(
                  padding: const EdgeInsets.all(6), // Increased padding
                  decoration: BoxDecoration(
                    color: const Color(0xFF24C168).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6), // Increased radius
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: Color(0xFF24C168),
                    size: 18, // Increased icon size
                  ),
                ),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: copyText)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF24C168),
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white,
                                size: 18), // Increased icon size
                            const SizedBox(width: 10), // Increased spacing
                            Expanded(
                              child: Text(
                                'Copied to clipboard',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _truncateKey(String key) {
    if (key.length <= 12) return key;
    return '${key.substring(0, 6)}...${key.substring(key.length - 6)}';
  }

  void _editMarket(BuildContext context, Markets market) {
    // Store provider reference to avoid context issues after navigation
    final provider = context.read<NormalMarketProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NormalMarketFormPage(normalMarket: market as NormalMarket?),
      ),
    ).then((_) {
      // Refresh market details after editing using stored provider
      provider.loadMarketById(market.id);
    });
  }

  void _createNFT(BuildContext context, String marketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)), // Increased radius
        title: const Row(
          children: [
            Icon(Icons.token,
                color: Color(0xFF24C168), size: 24), // Increased icon size
            SizedBox(width: 14), // Increased spacing
            Text('Create NFT',
                style: TextStyle(
                    color: Colors.white, fontSize: 20)), // Increased font size
          ],
        ),
        content: const Text(
          'Are you sure you want to create an NFT for this market?',
          style: TextStyle(
              color: Colors.white70, fontSize: 16), // Increased font size
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10), // Increased padding
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16)), // Increased font size
          ),
          ElevatedButton(
            onPressed: () async {
              // Store provider reference before popping the dialog
              final provider = context.read<NormalMarketProvider>();
              Navigator.pop(context); // Close dialog

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2A2A2A),
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF24C168)),
                      const SizedBox(width: 24), // Increased spacing
                      const Text('Creating NFT...',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16)), // Increased font size
                    ],
                  ),
                ),
              );

              try {
                final success = await provider.createNFT(marketId);

                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);
                }

                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF24C168),
                      content: Text(
                        'NFT created successfully',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16), // Increased font size
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog if still showing
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
                          fontSize: 16), // Increased font size
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24C168),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12), // Increased padding
            ),
            child: const Text('Create NFT',
                style: TextStyle(fontSize: 16)), // Increased font size
          ),
        ],
      ),
    );
  }

  void _showShareNFTDialog(BuildContext context, String marketId) {
    final recipientController = TextEditingController();
    int percentageToShare = 10; // Default value

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)), // Increased radius
          title: const Row(
            children: [
              Icon(Icons.share,
                  color: Color(0xFF24C168), size: 24), // Increased icon size
              SizedBox(width: 14), // Increased spacing
              Text('Share NFT Ownership',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20)), // Increased font size
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recipient Address',
                style: TextStyle(
                    color: Colors.white70, fontSize: 16), // Increased font size
              ),
              const SizedBox(height: 10), // Increased spacing
              TextFormField(
                controller: recipientController,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16), // Increased font size
                decoration: InputDecoration(
                  hintText: 'Enter wallet address',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 16), // Increased font size
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10), // Increased radius
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16), // Increased padding
                ),
              ),
              const SizedBox(height: 24), // Increased spacing
              const Text(
                'Percentage to Share',
                style: TextStyle(
                    color: Colors.white70, fontSize: 16), // Increased font size
              ),
              const SizedBox(height: 10), // Increased spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percentageToShare%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Increased font size
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6), // Increased padding
                    decoration: BoxDecoration(
                      color: const Color(0xFF24C168),
                      borderRadius:
                          BorderRadius.circular(20), // Increased radius
                    ),
                    child: Text(
                      'You keep ${100 - percentageToShare}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Increased font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Increased spacing
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFF24C168),
                  inactiveTrackColor: Colors.grey.shade800,
                  thumbColor: const Color(0xFF24C168),
                  overlayColor: const Color(0xFF24C168).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 14), // Increased radius
                  overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24), // Increased radius
                  trackHeight: 6, // Increased height
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10), // Increased padding
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 16)), // Increased font size
            ),
            ElevatedButton(
              onPressed: () async {
                if (recipientController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Please enter recipient address',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16), // Increased font size
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Store provider reference before popping the dialog
                // Store provider reference before popping the dialog
                final provider = context.read<NormalMarketProvider>();
                Navigator.pop(context); // Close dialog

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF2A2A2A),
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: Color(0xFF24C168)),
                        const SizedBox(width: 24), // Increased spacing
                        const Text('Sharing NFT...',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)), // Increased font size
                      ],
                    ),
                  ),
                );

                try {
                  final success = await provider.shareNFT(
                      marketId, recipientController.text, percentageToShare);

                  // Close loading dialog
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  if (!context.mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF24C168),
                        content: Text(
                          'NFT shared successfully',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16), // Increased font size
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'Failed to share NFT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16), // Increased font size
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  // Close loading dialog if still showing
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Error sharing NFT: ${e.toString()}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16), // Increased font size
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24C168),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Increased padding
              ),
              child: const Text('Share',
                  style: TextStyle(fontSize: 16)), // Increased font size
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMarket(BuildContext context, String marketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)), // Increased radius
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 24), // Increased icon size
            SizedBox(width: 14), // Increased spacing
            Text('Delete Market',
                style: TextStyle(
                    color: Colors.white, fontSize: 20)), // Increased font size
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this market? This action cannot be undone.',
          style: TextStyle(
              color: Colors.white70, fontSize: 16), // Increased font size
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10), // Increased padding
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16)), // Increased font size
          ),
          ElevatedButton(
            onPressed: () async {
              // Store provider reference before popping the dialog
              final provider = context.read<NormalMarketProvider>();
              Navigator.pop(context); // Close dialog

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2A2A2A),
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.redAccent),
                      const SizedBox(width: 24), // Increased spacing
                      const Text('Deleting market...',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16)), // Increased font size
                    ],
                  ),
                ),
              );

              try {
                final success = await provider.removeMarket(marketId);

                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);
                }

                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF24C168),
                      content: Text(
                        'Market deleted successfully',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16), // Increased font size
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
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16), // Increased font size
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog if still showing
                if (context.mounted) {
                  Navigator.pop(context);
                }

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      'Error deleting market: ${e.toString()}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16), // Increased font size
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12), // Increased padding
            ),
            child: const Text('Delete',
                style: TextStyle(fontSize: 16)), // Increased font size
          ),
        ],
      ),
    );
  }
}
