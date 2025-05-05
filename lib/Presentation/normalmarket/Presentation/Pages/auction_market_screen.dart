import 'package:flutter/material.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/Farm_Crop/Presentation_Layer/viewmodels/farm_crop_viewmodel.dart';
import 'package:hanouty/Presentation/auction/domain/entity/auction.dart';
import 'package:hanouty/Presentation/auction/presentation/provider/auction_provider.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/auction_bid_screen.dart';
import 'package:provider/provider.dart';


class MarketOwnerAuctionsScreen extends StatefulWidget {
  const MarketOwnerAuctionsScreen({Key? key}) : super(key: key);

  @override
  State<MarketOwnerAuctionsScreen> createState() => _MarketOwnerAuctionsScreenState();
}

class _MarketOwnerAuctionsScreenState extends State<MarketOwnerAuctionsScreen> {
  List<Auction> activeAuctions = [];
  bool isLoading = false;
  String errorText = "";

  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  Future<void> _loadAuctions() async {
    setState(() {
      isLoading = true;
      errorText = "";
    });

    try {
      final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
      final auctions = await auctionProvider.fetchActiveAuctions();

      setState(() {
        activeAuctions = auctions;
        errorText = auctionProvider.errorMessage;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorText = e.toString();
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  void _joinBid(Auction auction) async {
    final secureStorageService = SecureStorageService();
    final String? bidderId = await secureStorageService.getUserId();

    if (bidderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not determine your user ID.')),
      );
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => AuctionBidScreen(
        auctionId: auction.id,
        bidderId: bidderId,
      ),
    ));
  }

  Widget _buildMarketBackgroundImage(String? imagePath, bool isSmallScreen, bool isDarkMode) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'image_url_here') {
      return Container(
        color: isDarkMode
            ? const Color(0xFF1A2E1A)
            : const Color(0xFFEEF7ED),
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

    final String normalizedPath = imagePath.replaceAll('\\', '/');
    final String imageUrl = ApiConstants.getFullImageUrl(normalizedPath);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: isDarkMode
              ? const Color(0xFF1A2E1A)
              : const Color(0xFFEEF7ED),
        ),
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Available Auctions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAuctions,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorText.isNotEmpty
          ? Center(child: Text("Error: $errorText"))
          : activeAuctions.isEmpty
          ? _buildEmptyAuctionsView()
          : _buildAuctionsList(isSmallScreen, isDarkMode),
    );
  }

  Widget _buildEmptyAuctionsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gavel,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No auctions available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Active auctions will show here for the market owner.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionsList(bool isSmallScreen, bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: activeAuctions.length,
      itemBuilder: (context, index) {
        final auction = activeAuctions[index];
        return FutureBuilder(
          future: Provider.of<FarmCropViewModel>(context, listen: false)
              .fetchCropById(auction.cropId),
          builder: (context, snapshot) {
            final crop = Provider.of<FarmCropViewModel>(context, listen: false).selectedCrop;
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                leading: crop != null
                    ? SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildMarketBackgroundImage(
                        crop.picture, isSmallScreen, isDarkMode),
                  ),
                )
                    : Icon(
                  auction.status == AuctionStatus.active
                      ? Icons.gavel
                      : Icons.check_circle,
                  color: auction.status == AuctionStatus.active
                      ? Colors.blue
                      : Colors.green,
                ),
                title: Text(
                  crop?.productName ?? auction.description ?? "No Description",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Quantity: ${crop?.quantity ?? "--"}\n'
                      'Ends: ${_formatDate(auction.endTime)}\n'
                      'Start Price: \$${auction.startingPrice?.toStringAsFixed(2) ?? "--"}',
                ),
                trailing: auction.status == AuctionStatus.active
                    ? ElevatedButton(
                  onPressed: () => _joinBid(auction),
                  child: const Text('Join Bid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
                children: [
                  ListTile(
                    title: Text('Status: ${auction.status?.name ?? "Unknown"}'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}