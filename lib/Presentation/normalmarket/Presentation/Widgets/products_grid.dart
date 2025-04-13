import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/add_edit_product_page.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:hanouty/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/injection_container.dart';
import 'package:hanouty/Core/network/apiconastant.dart';

class HorizontalProductsList extends StatefulWidget {
  final List<String> products; // List of product IDs
  final String marketName; // Optional market name to display
  final Function? onProductsUpdated; // Callback when products are updated
  final String? marketId; // Added market ID parameter

  const HorizontalProductsList({
    super.key,
    required this.products,
    this.marketName = '',
    this.onProductsUpdated,
    this.marketId,
  });

  @override
  State<HorizontalProductsList> createState() => _HorizontalProductsListState();
}

class _HorizontalProductsListState extends State<HorizontalProductsList> {
  // Create our own ScrollController to ensure it always exists
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // Dispose the controller when widget is removed
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section with title and count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_basket_outlined,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.marketName.isEmpty ? 'Products' : '${widget.marketName} Products',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      '${widget.products.length} ${widget.products.length == 1 ? 'item' : 'items'} available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Add Product page with market ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditProductPage(
                          marketId: widget.marketId, // Pass the market ID here
                        ),
                      ),
                    ).then((result) {
                      // Refresh the product list if a product was added
                      if (result == true && widget.onProductsUpdated != null) {
                        widget.onProductsUpdated!();
                      }
                    });
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Scrollable indicator with scroll buttons
        if (widget.products.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Arrow left - scroll left button
                if (_scrollController.hasClients && _scrollController.position.pixels > 0)
                  GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        _scrollController.position.pixels - 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                const SizedBox(width: 8),

                Icon(
                  Icons.swipe,
                  size: 14,
                  color: Colors.grey[400],
                ),

                const SizedBox(width: 6),

                Text(
                  'Swipe to see more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const Spacer(),

                // Arrow right - scroll right button
                if (widget.products.length > 2) // Only show if we have enough products to scroll
                  GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        _scrollController.position.pixels + 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Main product list
        widget.products.isEmpty
            ? _buildEmptyProductsView(context)
            : _buildProductList(context),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductList(BuildContext context) {
    // Get the ProductProvider instance from the GetIt container
    final productProvider = sl<ProductProvider>();

    // Using NotificationListener to update scroll buttons visibility
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Force a rebuild when scroll position changes
        if (notification is ScrollUpdateNotification) {
          setState(() {});
        }
        return false;
      },
      child: Container(
        // Ensure the parent has constraints for the ListView to work properly
        height: 250, // Increased height to fit all content
        constraints: const BoxConstraints(
          minHeight: 250,
          maxHeight: 250,
        ),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(), // Better scrolling behavior
          itemCount: widget.products.length,
          itemBuilder: (context, index) {
            final productId = widget.products[index];
            return FutureBuilder<Product?>(
              // Use the productProvider from GetIt instead of Provider.of
              future: productProvider.fetchProductById(productId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingProductCard();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorProductCard();
                } else {
                  final product = snapshot.data!;
                  return _buildProductCard(context, product, productProvider);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyProductsView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          Icon(
            Icons.shopping_basket,
            size: 80,
            color: const Color(0xFF4CAF50).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Products Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Start adding products to this market to track your inventory',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Add Product page with market ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductPage(
                    marketId: widget.marketId, // Pass the market ID here
                  ),
                ),
              ).then((result) {
                // Refresh the product list if a product was added
                if (result == true && widget.onProductsUpdated != null) {
                  widget.onProductsUpdated!();
                }
              });
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

  Widget _buildProductCard(BuildContext context, Product product, ProductProvider productProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: product,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: _buildProductImage(context, product.image),
              ),
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use min to avoid overflow
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1, // Limit to 1 line to avoid overflow
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Price information
                  Row(
                    children: [
                      Text(
                        "${product.originalPrice.toStringAsFixed(2)} DT",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.isDiscounted && product.discountValue > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          "${(product.originalPrice + product.discountValue).toStringAsFixed(2)} DT",
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Stock indicator
                  const SizedBox(height: 4),
                  Text(
                    "Stock: ${product.stock}",
                    style: TextStyle(
                      fontSize: 12,
                      color: product.stock > 0 ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Action buttons row
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditProductPage(
                                product: product,
                                marketId: widget.marketId, // Also pass market ID when editing
                              ),
                            ),
                          ).then((result) {
                            // Refresh the product list if a product was updated
                            if (result == true && widget.onProductsUpdated != null) {
                              widget.onProductsUpdated!();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: () {
                          // Show confirmation dialog
                          _showDeleteConfirmationDialog(
                            context,
                            product,
                            productProvider,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(
      BuildContext context,
      Product product,
      ProductProvider productProvider,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${product.name}?'),
          content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Dismiss the dialog
                Navigator.of(context).pop();

                // Show loading indicator
                _showLoadingDialog(context);

                // Delete the product
                final success = await productProvider.deleteProduct(product.id);

                // Dismiss the loading dialog
                Navigator.of(context).pop();

                if (success) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} has been deleted'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Call the callback to update the product list
                  if (widget.onProductsUpdated != null) {
                    widget.onProductsUpdated!();
                  }
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete ${product.name}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Deleting product...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingProductCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Shimmer effect for image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer for title
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),

                const SizedBox(height: 8),

                // Shimmer for price
                Container(
                  height: 14,
                  width: 80,
                  color: Colors.grey[200],
                ),

                const SizedBox(height: 8),

                // Shimmer for stock
                Container(
                  height: 12,
                  width: 60,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorProductCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Updated image loading function using ApiConstants
  Widget _buildProductImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: AppColors.primary.withOpacity(0.1),
        child: Center(
          child: Icon(
            Icons.image,
            color: Colors.grey[400],
            size: 30,
          ),
        ),
      );
    }

    // Get full image URL using ApiConstants
    final String fullImageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(imageUrl) // Use with cache busting for web
        : ApiConstants.getFullImageUrl(imageUrl);            // Use standard URL for mobile

    print('Loading product image: $fullImageUrl');

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base placeholder
        Container(color: AppColors.primary.withOpacity(0.1)),

        // Actual image
        CachedNetworkImage(
          imageUrl: fullImageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          errorWidget: (context, url, error) {
            print('Error loading product image: $url - Error: $error');

            return GestureDetector(
              onTap: () {
                // Show image URL in dialog for debugging
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Image Error'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Failed to load image:'),
                          const SizedBox(height: 8),
                          Text(fullImageUrl, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('Original path: $imageUrl', style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 12),
                          const Text('Check that:'),
                          const Text('• Backend server is running'),
                          const Text('• File exists on server'),
                          const Text('• Path is correct'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey[400], size: 24),
                      const SizedBox(height: 4),
                      const Text(
                        'Image not found',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap for details',
                        style: TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}