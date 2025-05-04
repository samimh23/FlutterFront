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
  final bool isDarkMode; // Add isDarkMode parameter for theme support


  const HorizontalProductsList({
    super.key,
    required this.products,
    this.marketName = '',
    this.onProductsUpdated,
    this.marketId,
    this.isDarkMode = false, // Default to light mode
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
    // Colors based on theme
    final accentColor = widget.isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final headingColor = widget.isDarkMode ? Colors.white : const Color(0xFF2E7D32);
    final subTextColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final iconBgColor = accentColor.withOpacity(widget.isDarkMode ? 0.2 : 0.1);
    final orangeBgColor = const Color(0xFFFF9800).withOpacity(widget.isDarkMode ? 0.2 : 0.1);
    final scrollBtnColor = widget.isDarkMode ? Colors.grey[800] : Colors.grey[100];
    final scrollIconColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];


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
                  color: orangeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  color: widget.isDarkMode ? Colors.amber[300] : const Color(0xFFFF9800),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                    Text(
                      '${widget.products.length} ${widget.products.length == 1 ? 'item' : 'items'} available',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconBgColor,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          color: accentColor,
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
                        color: scrollBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: scrollIconColor,
                      ),
                    ),
                  ),


                const SizedBox(width: 8),


                Icon(
                  Icons.swipe,
                  size: 14,
                  color: widget.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),


                const SizedBox(width: 6),


                Text(
                  'Swipe to see more',
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
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
                        color: scrollBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: scrollIconColor,
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
    // Colors for dark mode
    final emptyBgColor = widget.isDarkMode ? const Color(0xFF252525) : const Color(0xFFEEF7ED);
    final emptyBorderColor = widget.isDarkMode ? Colors.grey.shade800 : const Color(0xFF4CAF50).withOpacity(0.2);
    final textColor = widget.isDarkMode ? Colors.white : const Color(0xFF333333);
    final subtitleColor = widget.isDarkMode ? Colors.grey[400] : const Color(0xFF666666);
    final iconColor = widget.isDarkMode
        ? const Color(0xFF81C784).withOpacity(0.5)
        : const Color(0xFF4CAF50).withOpacity(0.5);
    final accentColor = widget.isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: emptyBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: emptyBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_basket,
            size: 80,
            color: iconColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding products to this market to track your inventory',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
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
              backgroundColor: accentColor,
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
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : const Color(0xFF333333);
    final accentColor = widget.isDarkMode ? const Color(0xFF81C784) : AppColors.primary;
    final stockPositiveColor = widget.isDarkMode ? Colors.green[400] : Colors.green[700];
    final stockNegativeColor = widget.isDarkMode ? Colors.red[400] : Colors.red[700];
    final shadowColor = widget.isDarkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.08);


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
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      if (product.isDiscounted && product.discountValue > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          "${(product.originalPrice + product.discountValue).toStringAsFixed(2)} DT",
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: widget.isDarkMode ? Colors.grey[500] : Colors.grey,
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
                      color: product.stock > 0 ? stockPositiveColor : stockNegativeColor,
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
                        color: widget.isDarkMode ? Colors.blue.shade300 : Colors.blue,
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
                        color: widget.isDarkMode ? Colors.red.shade300 : Colors.red,
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
    final dialogBgColor = widget.isDarkMode ? const Color(0xFF252525) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : null;
    final buttonTextColor = widget.isDarkMode ? Colors.grey[300] : Colors.grey;


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBgColor,
          title: Text('Delete ${product.name}?', style: TextStyle(color: textColor)),
          content: Text(
            'Are you sure you want to delete this product? This action cannot be undone.',
            style: TextStyle(color: textColor),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: buttonTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss confirmation dialog


                // Use a local context for the dialog
                final dialogContext = context;
                showDialog(
                  context: dialogContext,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Deleting...'),
                        ],
                      ),
                    ),
                  ),
                );


                bool success = false;
                try {
                  success = await productProvider.deleteProduct(product.id)
                      .timeout(const Duration(seconds: 10), onTimeout: () => false);
                } catch (e) {
                  print("Delete exception: $e");
                } finally {
                  // Always dismiss the loading dialog using dialogContext
                  if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  }
                }


                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} has been deleted'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Future.delayed(const Duration(seconds: 5), () {
                      if (mounted && widget.onProductsUpdated != null) {
                        widget.onProductsUpdated!();
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete ${product.name}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
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
    final dialogBgColor = widget.isDarkMode ? const Color(0xFF252525) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : null;
    final accentColor = widget.isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: dialogBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: accentColor),
                const SizedBox(width: 20),
                Text('Deleting product...', style: TextStyle(color: textColor)),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildLoadingProductCard() {
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final shimmerColor = widget.isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final shadowColor = widget.isDarkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.05);
    final loaderColor = widget.isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);


    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
              color: shimmerColor,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: loaderColor,
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
                  color: shimmerColor,
                ),


                const SizedBox(height: 8),


                // Shimmer for price
                Container(
                  height: 14,
                  width: 80,
                  color: shimmerColor,
                ),


                const SizedBox(height: 8),


                // Shimmer for stock
                Container(
                  height: 12,
                  width: 60,
                  color: shimmerColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildErrorProductCard() {
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final errorColor = widget.isDarkMode ? Colors.red[400] : Colors.red[300];
    final textColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey;
    final shadowColor = widget.isDarkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.05);


    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
            color: errorColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }


  // Updated image loading function with improved error handling
  Widget _buildProductImage(BuildContext context, String? imageUrl) {
    final placeholderColor = widget.isDarkMode
        ? AppColors.primary.withOpacity(0.2)
        : AppColors.primary.withOpacity(0.1);
    final iconColor = widget.isDarkMode ? Colors.grey[600] : Colors.grey[400];
    final accentColor = widget.isDarkMode ? const Color(0xFF81C784) : AppColors.primary;
    final errorBgColor = widget.isDarkMode ? Colors.grey[900] : Colors.grey[200];
    final errorTextColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey;


    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: placeholderColor,
        child: Center(
          child: Icon(
            Icons.image,
            color: iconColor,
            size: 30,
          ),
        ),
      );
    }


    // Get full image URL using ApiConstants
    final String fullImageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(imageUrl) // Use with cache busting for web
        : ApiConstants.getFullImageUrl(imageUrl);            // Use standard URL for mobile


    return Stack(
      fit: StackFit.expand,
      children: [
        // Base placeholder
        Container(color: placeholderColor),


        // Actual image
        CachedNetworkImage(
          imageUrl: fullImageUrl,
          fit: BoxFit.cover,
          // Add a key based on URL to force refresh when image changes
          key: ValueKey(fullImageUrl),
          // Add memory & disk cache settings
          memCacheHeight: 400, // Optimized size for thumbnail
          memCacheWidth: 400,
          maxHeightDiskCache: 800, // Higher quality for disk cache
          maxWidthDiskCache: 800,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accentColor,
            ),
          ),
          errorWidget: (context, url, error) {
            print('Error loading product image: $url - $error');
            return GestureDetector(
              onTap: () {
                // Show image URL in dialog for debugging
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: widget.isDarkMode ? const Color(0xFF252525) : Colors.white,
                    title: Text('Image Error',
                        style: TextStyle(color: widget.isDarkMode ? Colors.white : null)
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Failed to load image:',
                              style: TextStyle(color: widget.isDarkMode ? Colors.white : null)
                          ),
                          const SizedBox(height: 8),
                          Text(fullImageUrl,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isDarkMode ? Colors.grey[300] : null
                              )
                          ),
                          const SizedBox(height: 8),
                          Text('Original path: $imageUrl',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isDarkMode ? Colors.grey[300] : null
                              )
                          ),
                          const SizedBox(height: 12),
                          Text('Error: ${error.toString()}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[widget.isDarkMode ? 400 : 600]
                              )
                          ),
                          const SizedBox(height: 12),
                          Text('Check that:',
                              style: TextStyle(color: widget.isDarkMode ? Colors.white : null)
                          ),
                          Text('• Backend server is running',
                              style: TextStyle(color: widget.isDarkMode ? Colors.grey[300] : null)
                          ),
                          Text('• File exists on server',
                              style: TextStyle(color: widget.isDarkMode ? Colors.grey[300] : null)
                          ),
                          Text('• Path is correct',
                              style: TextStyle(color: widget.isDarkMode ? Colors.grey[300] : null)
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close',
                            style: TextStyle(color: accentColor)
                        ),
                      ),
                      // Add option to retry loading
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Force a refresh by clearing the cache for this URL
                          CachedNetworkImage.evictFromCache(fullImageUrl);
                          setState(() {});
                        },
                        child: Text('Retry',
                            style: TextStyle(color: accentColor)
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                color: errorBgColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: iconColor, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Image not found',
                        style: TextStyle(fontSize: 10, color: errorTextColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap for details',
                        style: TextStyle(fontSize: 8, color: errorTextColor),
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

