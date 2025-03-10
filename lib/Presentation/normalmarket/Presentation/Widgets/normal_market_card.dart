import 'package:flutter/material.dart';
import 'package:hanouty/Core/heritables/Markets.dart';
import 'package:hanouty/Core/network/apiconastant.dart';

class MarketCard extends StatelessWidget {
  final Markets market;
  final VoidCallback onTap;

  const MarketCard({
    Key? key,
    required this.market,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? imagePath = (market as dynamic).marketImage;
    // Create a unique hero tag using the market ID
    final String heroTag = 'market_image_${market.id}';

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Hero animation
            SizedBox(
              height: 140,
              width: double.infinity,
              child: _buildMarketImage(imagePath, heroTag),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (market as dynamic).marketName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (market as dynamic).marketLocation,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build market image with hero tag
  Widget _buildMarketImage(String? imagePath, String heroTag) {
    final Widget imageContent = imagePath != null && imagePath.isNotEmpty
        ? _buildNetworkImage(imagePath)
        : _buildPlaceholderImage();

    // Wrap with Hero widget using unique tag
    return Hero(
      tag: heroTag,
      child: imageContent,
    );
  }

  Widget _buildNetworkImage(String imagePath) {
    return Image.network(
      ApiConstants.getFullImageUrl(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Image error in card: $error');
        return _buildPlaceholderImage();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.store, size: 40),
      ),
    );
  }
}
