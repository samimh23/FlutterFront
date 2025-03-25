import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanouty/responsive/responsive_layout.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    
    return Scaffold(
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
        iconTheme: const IconThemeData(color: Colors.white),
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
                _buildProductImageGallery(),
                const SizedBox(height: 16),
                _buildImageSelector(),
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
  
  Widget _buildMobileTabletLayout() {
    final isTablet = ResponsiveLayout.isTablet(context);
    final padding = isTablet ? 20.0 : 16.0;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with error handling
          _buildProductImage(context),
          
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
                
                const SizedBox(height: 16),
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
  
  Widget _buildProductImageGallery() {
    if (widget.product.images.isEmpty) {
      return _buildPlaceholderImage(context, height: 350);
    }
    
    String imageUrl = widget.product.images[_currentImageIndex];
    
    // Handle CORS issues for web platform
    if (kIsWeb) {
      imageUrl = 'https://corsproxy.io/?${Uri.encodeComponent(imageUrl)}';
    }
    
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) {
            if (kIsWeb && !url.contains('allorigins')) {
              return CachedNetworkImage(
                imageUrl: 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(widget.product.images[_currentImageIndex])}',
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => _buildPlaceholderImage(context, height: 350),
              );
            }
            return _buildPlaceholderImage(context, height: 350);
          },
        ),
      ),
    );
  }
  
  Widget _buildImageSelector() {
    if (widget.product.images.length <= 1) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.product.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index;
              });
            },
            child: Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentImageIndex == index 
                      ? AppColors.primary 
                      : Colors.grey.shade300,
                  width: _currentImageIndex == index ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: kIsWeb 
                      ? 'https://corsproxy.io/?${Uri.encodeComponent(widget.product.images[index])}'
                      : widget.product.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, size: 20),
                  ),
                ),
              ),
            ),
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

  Widget _buildProductImage(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);
    final height = isTablet ? 300.0 : 250.0;
    
    if (widget.product.images.isEmpty) {
      return _buildPlaceholderImage(context, height: height);
    }

    String imageUrl = widget.product.images.first;

    // Handle CORS issues for web platform
    if (kIsWeb) {
      imageUrl = 'https://corsproxy.io/?${Uri.encodeComponent(imageUrl)}';
    }

    return Hero(
      tag: 'product_image_${widget.product.id}',
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          if (kIsWeb && !url.contains('allorigins')) {
            return CachedNetworkImage(
              imageUrl: 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(widget.product.images.first)}',
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: height,
                color: Colors.grey[200],
                               child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => _buildPlaceholderImage(context, height: height),
            );
          }
          return _buildPlaceholderImage(context, height: height);
        },
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, {required double height}) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported, 
            size: isDesktop ? 64 : 50, 
            color: Colors.grey
          ),
          const SizedBox(height: 8),
          Text(
            "Image not available",
            style: TextStyle(
              color: Colors.grey,
              fontSize: isDesktop ? 16 : 14,
            ),
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

  Widget _buildInfoRow(IconData icon, String label, String value, {double fontSize = 14, double iconSize = 16}) {
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
    
    final buttonWidth = isDesktop ? double.infinity : MediaQuery.of(context).size.width;
    final horizontalPadding = isDesktop ? 0.0 : 16.0;
    
    return Container(
      height: buttonHeight,
      width: buttonWidth,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: () {
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
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
    );
  }
  
  // Helper method to format currency
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} DT';
  }
  
  // Helper method to calculate discount percentage
  String _calculateDiscountPercentage() {
    if (!widget.product.isDiscounted || widget.product.discountValue <= 0) {
      return '';
    }
    
    final originalPrice = widget.product.originalPrice + widget.product.discountValue;
    final discountPercentage = (widget.product.discountValue / originalPrice) * 100;
    return '${discountPercentage.round()}% OFF';
  }
}