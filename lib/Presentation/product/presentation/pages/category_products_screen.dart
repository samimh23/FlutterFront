import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/pages/cart_screen.dart';
import 'package:hanouty/Presentation/product/presentation/pages/product_details_screen.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/product_card.dart'; // ✅ NEW
import 'package:hanouty/app_colors.dart';
import 'package:provider/provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;

  const CategoryProductsScreen({Key? key, required this.category})
      : super(key: key);

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _showSearch = false;
                      _searchQuery = '';
                      _searchController.clear();
                    }),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text(widget.category),
        backgroundColor: AppColors.grey,
        actions: [
          if (!_showSearch)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _showSearch = true),
            ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          var filteredProducts = widget.category.toLowerCase() == 'all'
              ? provider.products
              : provider.products
                  .where((product) =>
                      product.category.name.toLowerCase() ==
                      widget.category.toLowerCase())
                  .toList();

          if (_searchQuery.isNotEmpty) {
            filteredProducts = filteredProducts
                .where((p) => p.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (filteredProducts.isEmpty) {
            return Center(
              child: Text(
                'No products found in the ${widget.category} category.',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.6,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) => ProductCard(
                  product: filteredProducts[index],
                  onTap: () =>
                      _navigateToProductDetails(filteredProducts[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addToCart(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      product.id.toString(),
      product.name,
      product.originalPrice.toInt(),
      product.image!,
      product.shop,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }
}
