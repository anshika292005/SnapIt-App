import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_app/models/product.dart';
import 'package:flutter_ecommerce_app/providers/cart_provider.dart';

void main() {
  const product = Product(
    id: 'linen-shirt',
    name: 'Linen Shirt',
    description: 'A shirt.',
    price: 1899,
    imageUrl: 'https://example.com/shirt.png',
    category: 'Apparel',
    stock: 10,
  );

  test('adds, updates, removes, clears, and totals cart items', () {
    final cart = CartProvider();

    cart.addToCart(product);
    cart.addToCart(product);

    expect(cart.itemCount, 2);
    expect(cart.items.single.quantity, 2);
    expect(cart.totalPrice, 3798);

    cart.updateQuantity(product.id, 4);

    expect(cart.itemCount, 4);
    expect(cart.totalPrice, 7596);

    cart.updateQuantity(product.id, 0);

    expect(cart.items, isEmpty);
    expect(cart.totalPrice, 0);

    cart.addToCart(product);
    cart.clearCart();

    expect(cart.items, isEmpty);
  });
}
