import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get totalPrice => _items.fold(
        0,
        (total, item) => total + item.product.price * item.quantity,
      );

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index == -1) {
      _items.add(CartItem(product: product, quantity: 1));
    } else {
      final item = _items[index];
      _items[index] = CartItem(
        product: item.product,
        quantity: item.quantity + 1,
      );
    }

    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) {
      return;
    }

    final item = _items[index];
    _items[index] = CartItem(product: item.product, quantity: qty);
    notifyListeners();
  }

  void clearCart() {
    if (_items.isEmpty) {
      return;
    }

    _items.clear();
    notifyListeners();
  }
}
