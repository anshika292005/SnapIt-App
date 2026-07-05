import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_app/models/app_order.dart';
import 'package:flutter_ecommerce_app/models/cart_item.dart';
import 'package:flutter_ecommerce_app/models/product.dart';

void main() {
  test('serializes and deserializes orders', () {
    const product = Product(
      id: 'desk-lamp',
      name: 'Desk Lamp',
      description: 'A lamp.',
      price: 3299,
      imageUrl: 'https://example.com/lamp.png',
      category: 'Home',
      stock: 4,
    );
    final timestamp = DateTime(2026, 7, 4, 12);
    final order = AppOrder(
      id: 'order-1',
      userId: 'user-1',
      items: const [CartItem(product: product, quantity: 2)],
      total: 6598,
      status: 'pending',
      timestamp: timestamp,
      shippingAddress: '123 Test Street, Test City',
    );

    final map = order.toMap();
    final parsed = AppOrder.fromMap(map);

    expect(parsed.id, 'order-1');
    expect(parsed.userId, 'user-1');
    expect(parsed.items.single.product.id, 'desk-lamp');
    expect(parsed.items.single.quantity, 2);
    expect(parsed.total, 6598);
    expect(parsed.status, 'pending');
    expect(parsed.shippingAddress, '123 Test Street, Test City');
  });
}
