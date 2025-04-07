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
import 'package:hanouty/Core/Utils/secure_storage.dart'; // Import the secure storage service

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Order> userOrders = []; // Store user orders
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
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        elevation: 0,
        backgroundColor: AppColors.grey,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Order History',
            onPressed: () async {
              final secureStorageService = SecureStorageService();
              String? userId = await secureStorageService.getUserId();
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID not found')),
                );
                return;
              }

              // Use the orderProvider instance to call findOrdersByUserId
              userOrders = await orderProvider.findOrdersByUserId(userId);

              if (userOrders.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No order history yet')),
                );
              } else {
                _showOrderHistory(userOrders);
              }
            },
          ),
          // Delete mode toggle
          IconButton(
            icon: Icon(isDeleteMode ? Icons.delete : Icons.delete_outline),
            tooltip: isDeleteMode ? 'Delete Selected' : 'Enter Delete Mode',
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
                                        ? AppColors.yellow
                                        : Colors.white,
                                    border: Border.all(
                                      color: AppColors.yellow,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.check,
                                    size: 15,
                                    color: selectedItems.contains(index)
                                        ? Colors.white
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
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
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
                  backgroundColor: AppColors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'CHECKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.black,
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
      user: userId, // Use the retrieved user ID
      dateOrder: DateTime.now(),
      isConfirmed: false,
      totalPrice: cart.totalAmount.toInt(),
    );
    print(
        'New order created with id: $orderId and ${products.length} products.');

    await orderProvider.createNewOrder(newOrder);

    setState(() {
// Order ID is already saved in the database, no need to maintain a local list
    });

    cart.clearCart();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Order Confirmed'),
        content: Text('Your order #$orderId has been confirmed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  void _showOrderHistory(List<Order> orders) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Order History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                leading: Icon(
                  order.isConfirmed == true
                      ? Icons.check_circle
                      : Icons.pending,
                  color:
                      order.isConfirmed == true ? Colors.green : Colors.orange,
                ),
                title: Text('Order #${order.id}'),
                subtitle: Text(
                  'Ordered on ${_formatOrderDate(order.dateOrder)}',
                ),
                trailing: order.isConfirmed == true
                    ? null
                    : TextButton(
                        onPressed: () async {
                          await Provider.of<OrderProvider>(context,
                                  listen: false)
                              .confirmOrder(order.id);

                          // Refresh the order list after confirmation
                          final secureStorageService = SecureStorageService();
                          String? userId =
                              await secureStorageService.getUserId();
                          if (userId != null) {
                            userOrders = await Provider.of<OrderProvider>(
                                    context,
                                    listen: false)
                                .findOrdersByUserId(userId);
                          }

                          Navigator.of(ctx).pop(); // Close the dialog
                          _showOrderHistory(
                              userOrders); // Refresh the order history
                        },
                        child: const Text('Confirm'),
                      ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(DateTime dateOrder) {
    return '${dateOrder.day}/${dateOrder.month}/${dateOrder.year}';
  }

  void _deleteSelectedItems(CartProvider cart) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text(
          'Are you sure you want to delete ${selectedItems.length} item(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
                  duration: const Duration(seconds: 2),
                ),
              );
            },
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 16)),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: TextStyle(fontSize: 16)),
                Text(
                  'Free',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${cart.itemCount} items',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Looks like you haven\'t added any items yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate to the home screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
}
