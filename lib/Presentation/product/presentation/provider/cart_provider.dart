import 'package:flutter/foundation.dart';
import 'package:hanouty/Presentation/product/domain/entities/product.dart';

class CartItem {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String shop;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    required this.shop 
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  int _newItemCount = 0; // New field for badge count

  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;
  int get newItemCount => _newItemCount; // Getter for badge count

  double get totalAmount {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void addToCart(Product product) {
    final productId = product.id.toString();
    final imageUrl = product.image;

    addItem(
      productId,
      product.name,
      product.originalPrice.toInt(),
      imageUrl!,
      product.shop
    );
  }

  void addItem(String productId, String title, int price, String imageUrl , String shop) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
          imageUrl: existingItem.imageUrl,
          shop: existingItem.shop,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
            id: productId, title: title, price: price, imageUrl: imageUrl, shop: shop),
      );
    }
    _newItemCount++; // Increment badge count each time an item is added
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity - 1,
          imageUrl: existingItem.imageUrl,
          shop: existingItem.shop,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Remove an item completely regardless of quantity
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Call this method when the cart screen is opened
  void clearNewItemCount() {
    _newItemCount = 0;
    notifyListeners();
  }
}
