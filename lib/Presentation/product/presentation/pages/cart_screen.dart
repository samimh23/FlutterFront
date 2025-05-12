import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/order/domain/entities/order.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/Presentation/product/data/models/product_model.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/widgets/cart_card.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:hanouty/Core/Utils/secure_storage.dart';

import '../../../../Core/theme/AppColors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isDeleteMode = false;
  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).clearNewItemCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: ClientColors.background, // Updated background color
      appBar: AppBar(
        title: const Text('Cart'),
        elevation: 0,
        backgroundColor: ClientColors.primary, // Updated app bar color
        foregroundColor: ClientColors.onPrimary, // Updated text color
        actions: [
          // Delete mode toggle
          IconButton(
            icon: Icon(isDeleteMode ? Icons.delete : Icons.delete_outline),
            tooltip: isDeleteMode ? 'Delete Selected' : 'Enter Delete Mode',
            color: ClientColors.onPrimary, // Updated icon color
            onPressed: () {
              if (isDeleteMode && selectedItems.isNotEmpty) {
                _deleteSelectedItems(cart);
              } else {
                setState(() {
                  isDeleteMode = !isDeleteMode;
                  selectedItems.clear();
                });
              }
            },
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          // Cart items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: cartItems.length,
              itemBuilder: (ctx, index) {
                final item = cartItems[index];
                return InkWell(
                  onTap: isDeleteMode
                      ? () => setState(() {
                    if (selectedItems.contains(index)) {
                      selectedItems.remove(index);
                    } else {
                      selectedItems.add(index);
                    }
                  })
                      : null,
                  child: Stack(
                    children: [
                      CartCard(
                        item: item,
                        onIncrease: () {
                          setState(() {
                            cart.addItem(item.id, item.title, item.price,
                                item.imageUrl, item.shop);
                          });
                        },
                        onDecrease: () {
                          setState(() {
                            cart.removeSingleItem(item.id);
                          });
                        },
                      ),
                      if (isDeleteMode)
                        Positioned(
                          right: 20,
                          top: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedItems.contains(index)
                                  ? ClientColors.primary // Updated selection color
                                  : Colors.white,
                              border: Border.all(
                                color: ClientColors.primary, // Updated border color
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.check,
                              size: 15,
                              color: selectedItems.contains(index)
                                  ? ClientColors.onPrimary // Updated icon color
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildSummaryCard(cart, context),
        ],
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: ClientColors.primary.withOpacity(0.15), // Updated shadow color
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Implement checkout functionality
            _processCheckout(cart);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ClientColors.primary, // Updated button color
            foregroundColor: ClientColors.onPrimary, // Updated text color
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'CHECKOUT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _processCheckout(CartProvider cart) async {
    print('Processing checkout...');
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Retrieve the user ID from secure storage
    final secureStorageService = SecureStorageService();
    String? userId = await secureStorageService.getUserId(); // Await the future

    if (userId == null) {
      print('User ID not found');
      return;
    }

    print('*******************$userId*********************');

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    List<ProductModel> products = cart.items.values.map((cartItem) {
      return ProductModel(
          id: cartItem.id,
          name: cartItem.title,
          description: '',
          price: cartItem.price.toDouble(),
          originalPrice: cartItem.price.toDouble(),
          category: ProductCategory.Vegetables,
          stock: cartItem.quantity,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDiscounted: false,
          discountValue: 0.0,
          shop: cartItem.shop);
    }).toList();

    // Assuming the normalMarket ID is stored in the first product's ID or another field
    String normalMarketId = products.isNotEmpty ? products.first.shop : '';

    Order newOrder = Order(
      id: orderId,
      normalMarket: normalMarketId, // Use the normalMarket ID from the product
      products: products,
      user: userId,
      orderStatus: OrderStatus.isProcessing, // Set initial status to isReceived
      dateOrder: DateTime.now(),
      isConfirmed: false,
      totalPrice: cart.totalAmount.toInt(),
    );
    print(
        'New order created with id: $orderId and ${products.length} products.');

    await orderProvider.createNewOrder(newOrder);

    cart.clearCart();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounder corners
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: ClientColors.secondary, size: 28), // Success icon
            const SizedBox(width: 12),
            const Text('Order Confirmed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your order #$orderId has been confirmed successfully.'),
            const SizedBox(height: 12),
            Text(
              'You can track your order in the "My Orders" section.',
              style: TextStyle(
                color: ClientColors.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: ClientColors.primary, // Updated text color
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedItems(CartProvider cart) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounder corners
        ),
        title: Row(
          children: [
            Icon(Icons.delete, color: ClientColors.accent, size: 24), // Delete icon
            const SizedBox(width: 12),
            const Text('Delete Items'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${selectedItems.length} item(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: ClientColors.textLight, // Updated text color
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Get the items to be deleted
              List<String> itemsToDelete = selectedItems
                  .map((index) => cart.items.values.toList()[index].id)
                  .toList();

              // Delete items
              for (String id in itemsToDelete) {
                // Remove completely instead of just reducing quantity
                cart.removeItem(id);
              }

              // Exit delete mode
              setState(() {
                isDeleteMode = false;
                selectedItems.clear();
              });

              Navigator.of(ctx).pop();

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${itemsToDelete.length} item(s) deleted'),
                  backgroundColor: ClientColors.accent, // Updated snackbar color
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: ClientColors.accent, // Updated text color
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(CartProvider cart, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounder corners
      shadowColor: ClientColors.primary.withOpacity(0.1), // Updated shadow color
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal',
                  style: TextStyle(
                    fontSize: 16,
                    color: ClientColors.text, // Updated text color
                  ),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: ClientColors.text, // Updated text color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping',
                  style: TextStyle(
                    fontSize: 16,
                    color: ClientColors.text, // Updated text color
                  ),
                ),
                Text(
                  'Free',
                  style: TextStyle(
                    fontSize: 16,
                    color: ClientColors.secondary, // Updated text color
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Divider(
              height: 25,
              color: ClientColors.primary.withOpacity(0.1), // Updated divider color
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ClientColors.text, // Updated text color
                  ),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ClientColors.primary, // Updated text color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${cart.itemCount} items',
              style: TextStyle(
                color: ClientColors.textLight, // Updated text color
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: ClientColors.textLight, // Updated icon color
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ClientColors.text, // Updated text color
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Looks like you haven\'t added any items yet',
            style: TextStyle(
              fontSize: 16,
              color: ClientColors.textLight, // Updated text color
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to the home screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ClientColors.primary, // Updated button color
              foregroundColor: ClientColors.onPrimary, // Updated text color
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              elevation: 0, // Flatter design
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounder corners
              ),
            ),
          ),
        ],
      ),
    );
  }
}