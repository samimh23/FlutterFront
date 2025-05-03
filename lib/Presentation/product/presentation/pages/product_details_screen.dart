import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/reservation_dialog.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/review/data/models/review_model.dart';
import 'package:hanouty/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanouty/responsive/responsive_layout.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hanouty/Presentation/review/presentation/provider/review_provider.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  double _userRating = 0.0; // State variable to track review mode

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileTabletLayout(),
      bottomNavigationBar: isDesktop ? null : _buildAddToCartButton(context),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Images
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(context),
                const SizedBox(height: 16),
                _buildRatingSection(), // Add rating section here
                const SizedBox(height: 16),
                _buildUserRatingSection(), // Add user rating section here
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right side - Details
          Expanded(
            flex: 7,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPriceSection(isDesktop: true),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Category and stock info
                    _buildInfoRow(
                      Icons.category,
                      "Category",
                      _getCategoryName(widget.product.category),
                      fontSize: 16,
                      iconSize: 20,
                    ),
                    _buildInfoRow(
                      Icons.inventory,
                      "In Stock",
                      "${widget.product.stock} units",
                      fontSize: 16,
                      iconSize: 20,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildAddToCartButton(context, isDesktop: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rate this product",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: _userRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _userRating = rating;
            });
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final reviewProvider =
                Provider.of<ReviewProvider>(context, listen: false);
            final secureStorageService = SecureStorageService();
  
            String? userId = await secureStorageService.getUserId();
  
            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User ID not found. Please log in.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
  
            final review = ReviewModel(
              rating: _userRating.toInt(),
              user: userId, // Set the user ID in the review model,
              product: widget.product.id,
            );
  
            // Debug print to check if the review is being created
            print('Creating review for product: ${widget.product.id} by user: $userId');
  
            // Create new review
            reviewProvider.createNewReview(review, userId).then((success) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review submitted successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to submit review.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text("Submit Review"),
        ),
      ],
    );
  }

  void _refreshProductRating() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    // Fetch updated product rating
    final updatedProduct =
        await productProvider.fetchProductById(widget.product.id);
    if (updatedProduct != null) {
      setState(() {
        widget.product.ratingsAverage = updatedProduct.ratingsAverage;
        widget.product.ratingsQuantity =
            updatedProduct.ratingsQuantity; // Update ratingsQuantity
      });
    }
  }

  Widget _buildMobileTabletLayout() {
    final isTablet = ResponsiveLayout.isTablet(context);
    final padding = isTablet ? 20.0 : 16.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with error handling
          _buildProductImage(context),
          const SizedBox(height: 16),
          _buildRatingSection(), // Add rating section here
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPriceSection(),
                const SizedBox(height: 16),
                // Category and stock info
                _buildInfoRow(
                  Icons.category,
                  "Category",
                  _getCategoryName(widget.product.category),
                  fontSize: isTablet ? 15 : 14,
                ),
                _buildInfoRow(
                  Icons.inventory,
                  "In Stock",
                  "${widget.product.stock} units",
                  fontSize: isTablet ? 15 : 14,
                ),
                const SizedBox(height: 24),
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.description,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RatingBarIndicator(
            rating: widget.product.ratingsAverage?.toDouble() ?? 0.0,
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 24.0,
            direction: Axis.horizontal,
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.product.ratingsAverage} / 5',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.product.ratingsQuantity == 1
                ? 'Rated by 1 client'
                : 'Rated by ${widget.product.ratingsQuantity} clients',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    // Check if the product has an image
    if (widget.product.image == null || widget.product.image!.isEmpty) {
      return _buildPlaceholderImage(context);
    }

    // Use ApiConstants to get full image URL, similar to ProductCard implementation
    final String fullImageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(widget.product.image!)
        : ApiConstants.getFullImageUrl(widget.product.image!);

    debugPrint('Loading product detail image: $fullImageUrl');

    return Hero(
      tag: 'product_image_${widget.product.id}',
      child: CachedNetworkImage(
        imageUrl: fullImageUrl,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 250,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Error loading detail image: $error');
          return GestureDetector(
            onTap: () {
              // Show image URL in dialog for debugging, similar to ProductCard
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
                        Text(fullImageUrl,
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('Original path: ${widget.product.image}',
                            style: const TextStyle(fontSize: 12)),
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
            child: _buildPlaceholderImage(context),
          );
        },
      ),
    );
  }

  // Helper method to extract category name from ProductCategory object
  String _getCategoryName(dynamic category) {
    if (category is String) {
      return category;
    } else if (category == null) {
      return "Uncategorized";
    } else {
      try {
        return category.name ?? "Unknown";
      } catch (e) {
        return category.toString();
      }
    }
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Image not available",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 2),
          Text(
            "Tap for details",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection({bool isDesktop = false}) {
    final isTablet = !isDesktop && ResponsiveLayout.isTablet(context);

    final priceFontSize = isDesktop ? 26.0 : (isTablet ? 24.0 : 22.0);
    final discountFontSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          "${widget.product.originalPrice} DT",
          style: TextStyle(
            fontSize: priceFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        if (widget.product.isDiscounted && widget.product.discountValue > 0)
          Text(
            "${(widget.product.originalPrice + widget.product.discountValue).toStringAsFixed(0)} DT",
            style: TextStyle(
              fontSize: discountFontSize,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {double fontSize = 14, double iconSize = 16}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, {bool isDesktop = false}) {
    final buttonHeight = isDesktop ? 56.0 : 50.0;
    final fontSize = isDesktop ? 20.0 : 18.0;

    final buttonWidth =
        isDesktop ? double.infinity : MediaQuery.of(context).size.width;
    final horizontalPadding = isDesktop ? 0.0 : 16.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: buttonHeight,
          width: buttonWidth,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 8),
          child: ElevatedButton(
            onPressed: () {
              final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);
              cartProvider.addToCart(widget.product);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.product.name} added to cart',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'VIEW CART',
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigate to cart page
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              ),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: isDesktop ? 24 : 20,
                ),
                SizedBox(width: isDesktop ? 12 : 8),
                Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
       Container(
  height: buttonHeight,
  width: buttonWidth,
  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
  margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
  child: ElevatedButton(
    onPressed: () {
      // Show the reservation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ReservationDialog(
            productId: widget.product.id, // Pass your product ID here
            productName: widget.product.name, // Pass your product name here
            availableStock: widget.product.stock, // Pass available stock
          );
        },
      ).then((reservationData) {
        if (reservationData != null) {
          // Handle the reservation data
          _createReservation(reservationData);
        }
      });
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_bag,
          size: isDesktop ? 24 : 20,
        ),
        SizedBox(width: isDesktop ? 12 : 8),
        Text(
          'Reserve for later',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
      ],
    );
  }

  // Helper method to format currency
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} DT';
  }

  // Helper method to calculate discount percentage
  String calculateDiscountPercentage() {
    if (!widget.product.isDiscounted || widget.product.discountValue <= 0) {
      return '';
    }

    final originalPrice =
        widget.product.originalPrice + widget.product.discountValue;
    final discountPercentage =
        (widget.product.discountValue / originalPrice) * 100;
    return '${discountPercentage.round()}% OFF';
  }
}

void _createReservation(reservationData) {
}
