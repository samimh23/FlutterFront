import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/reservation_dialog.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/review/domain/entity/review.dart';
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
  double _userRating = 0.0;
  late Product _product;
  Review? _userReview;
  String? _userId;
  bool _userReviewsFetchFailed = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _initUserReview();
  }

  Future<void> _initUserReview() async {
    final secureStorageService = SecureStorageService();
    _userId = await secureStorageService.getUserId();

    if (_userId == null) return;

    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    List<Review> reviews = [];
    try {
      reviews = await reviewProvider.fetchReviewsByUserId(_userId!);
      _userReviewsFetchFailed = false;
    } catch (e) {
      debugPrint("Failed to fetch user reviews: $e");
      _userReviewsFetchFailed = true;
    }

    final userReview = reviews.cast<Review?>().firstWhere(
        (r) => r != null && r.product == _product.id,
        orElse: () => null);

    if (mounted) {
      setState(() {
        _userReview = userReview;
        _userRating = userReview?.rating.toDouble() ?? 0.0;
      });
    }
  }

  Future<void> _refreshProduct() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final updatedProduct = await productProvider.fetchProductById(_product.id);
    if (updatedProduct != null) {
      setState(() {
        _product = updatedProduct;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _product.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileTabletLayout(),
      bottomNavigationBar: isDesktop ? null : _buildAddToCartButton(context),
    );
  }

  Widget _buildUserRatingSection() {
    if (_userReviewsFetchFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          children:  [
            Text(
              'Failed to load your previous reviews. Please check your connection and try again.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userReview != null ? "Update your review" : "Rate this product",
            style: TextStyle(
              fontSize: 17,
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

                if (_userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User ID not found. Please log in.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // If user reviews failed to fetch, prevent submit and show error.
                if (_userReviewsFetchFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to fetch your previous reviews. Please try again.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                bool success = false;
                if (_userReview != null && _userReview!.id != null) {
                  final review = Review(
                    rating: _userRating.toInt(),
                    user: _userId!,
                    product: _product.id,
                    id: _userReview!.id,
                    createdAt: _userReview!.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  success = await reviewProvider.updateExistingReview(_userReview!.id!, review);
                } else {
                  final review = Review(
                    rating: _userRating.toInt(),
                    user: _userId!,
                    product: _product.id,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  success = await reviewProvider.createNewReview(review, _userId!);
                }

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_userReview != null
                          ? 'Review updated successfully!'
                          : 'Review submitted successfully!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  await _refreshProduct();
                  await _initUserReview();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to submit review.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.send_rounded),
              label: Text(_userReview != null ? "Update Review" : "Submit Review"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(context),
                const SizedBox(height: 16),
                _buildRatingSection(),
                const SizedBox(height: 16),
                _buildUserRatingSection(),
              ],
            ),
          ),
          const SizedBox(width: 32),
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
                      _product.name,
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
                    _buildInfoRow(
                      Icons.category,
                      "Category",
                      _getCategoryName(_product.category),
                      fontSize: 16,
                      iconSize: 20,
                    ),
                    _buildInfoRow(
                      Icons.inventory,
                      "In Stock",
                      "${_product.stock} units",
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
                      _product.description,
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

  Widget _buildMobileTabletLayout() {
    final isTablet = ResponsiveLayout.isTablet(context);
    final padding = isTablet ? 20.0 : 16.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildProductImage(context),
              Positioned(
                top: 16,
                right: 16,
                child: _buildStockBadge(),
              ),
              if (_product.isDiscounted && _product.discountValue > 0)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildDiscountBadge(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRatingSection(),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndCategory(isTablet),
                const SizedBox(height: 6),
                _buildPriceSection(),
                const SizedBox(height: 18),
                _buildInfoRow(
                  Icons.inventory,
                  "Stock",
                  "${_product.stock} units",
                  fontSize: isTablet ? 15 : 14,
                ),
                const SizedBox(height: 20),
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.13),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Text(
                    _product.description,
                    style: TextStyle(
                      fontSize: isTablet ? 17 : 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildUserRatingSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndCategory(bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _product.name,
            style: TextStyle(
              fontSize: isTablet ? 25 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
              letterSpacing: 0.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.category, color: AppColors.primary, size: 15),
              const SizedBox(width: 3),
              Text(
                _getCategoryName(_product.category),
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockBadge() {
    final inStock = _product.stock != null && _product.stock! > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: inStock ? Colors.green[600] : Colors.red[600],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (inStock ? Colors.green : Colors.red).withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Text(
        inStock ? 'In Stock' : 'Out of Stock',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildDiscountBadge() {
    final originalPrice = _product.originalPrice + _product.discountValue;
    final discountPercentage = (_product.discountValue / originalPrice) * 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Text(
        '-${discountPercentage.round()}% OFF',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.09),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RatingBarIndicator(
              rating: _product.ratingsAverage?.toDouble() ?? 0.0,
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 24.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(width: 10),
            Text(
              '${_product.ratingsAverage?.toStringAsFixed(1) ?? "0.0"} / 5',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _product.ratingsQuantity == 1
                  ? 'Rated by 1 client'
                  : 'Rated by ${_product.ratingsQuantity} clients',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    if (_product.image == null || _product.image!.isEmpty) {
      return _buildPlaceholderImage(context);
    }
    final String fullImageUrl = kIsWeb
        ? ApiConstants.getImageUrlWithCacheBusting(_product.image!)
        : ApiConstants.getFullImageUrl(_product.image!);

    return Hero(
      tag: 'product_image_${_product.id}',
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: CachedNetworkImage(
          imageUrl: fullImageUrl,
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 260,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) {
            return GestureDetector(
              onTap: () {
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
                          Text('Original path: ${_product.image}', style: const TextStyle(fontSize: 12)),
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
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_not_supported, size: 50, color: Colors.white),
          SizedBox(height: 8),
          Text(
            "Image not available",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 2),
          Text(
            "Tap for details",
            style: TextStyle(fontSize: 10, color: Colors.white70),
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
          "${_product.originalPrice} DT",
          style: TextStyle(
            fontSize: priceFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        if (_product.isDiscounted && _product.discountValue > 0)
          Text(
            "${(_product.originalPrice + _product.discountValue).toStringAsFixed(0)} DT",
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
                color: Colors.black87,
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
              cartProvider.addToCart(_product);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_product.name} added to cart',
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
        const SizedBox(height: 12),
        Container(
          height: buttonHeight,
          width: buttonWidth,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ReservationDialog(
                    productId: _product.id,
                    productName: _product.name,
                    availableStock: _product.stock,
                  );
                },
              ).then((reservationData) {
                if (reservationData != null) {
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

  String _getCategoryName(dynamic category) {
    if (category == null) return "Uncategorized";
    if (category is String) {
      if (category.contains('.')) return category.split('.').last;
      return category;
    }
    try {
      return category.name ?? category.toString().split('.').last;
    } catch (_) {
      return category.toString().split('.').last;
    }
  }

  void _createReservation(reservationData) {}
}