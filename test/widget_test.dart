import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ecommerce_app/models/product.dart';
import 'package:flutter_ecommerce_app/providers/cart_provider.dart';
import 'package:flutter_ecommerce_app/screens/checkout_screen.dart';
import 'package:flutter_ecommerce_app/screens/login_screen.dart';
import 'package:flutter_ecommerce_app/screens/product_detail_screen.dart';
import 'package:flutter_ecommerce_app/widgets/product_card.dart';

void main() {
  testWidgets('Login screen shows email and password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Fresh groceries\nin minutes'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'LOGIN'), findsOneWidget);
  });

  testWidgets('Product card shows product name and price', (
    WidgetTester tester,
  ) async {
    const product = Product(
      id: 'test-product',
      name: 'Test Product',
      description: 'A product for testing.',
      price: 1299,
      imageUrl: 'https://example.com/product.png',
      category: 'Testing',
      stock: 5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 320,
            child: ProductCard(
              product: product,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('₹1,299'), findsOneWidget);
  });

  testWidgets('Adding product from detail updates cart badge state', (
    WidgetTester tester,
  ) async {
    const product = Product(
      id: 'test-product',
      name: 'Test Product',
      description: 'A product for testing.',
      price: 1299,
      imageUrl: 'https://example.com/product.png',
      category: 'Testing',
      stock: 5,
    );
    final cart = CartProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<CartProvider>.value(
        value: cart,
        child: MaterialApp(
          home: ProductDetailScreen(product: product),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'ADD TO CART'));
    await tester.pump();

    expect(cart.itemCount, 1);
    expect(cart.items.single.product.id, 'test-product');
  });

  testWidgets('Checkout screen shows address form and total', (
    WidgetTester tester,
  ) async {
    const product = Product(
      id: 'test-product',
      name: 'Test Product',
      description: 'A product for testing.',
      price: 1299,
      imageUrl: 'https://example.com/product.png',
      category: 'Testing',
      stock: 5,
    );
    final cart = CartProvider()..addToCart(product);

    await tester.pumpWidget(
      ChangeNotifierProvider<CartProvider>.value(
        value: cart,
        child: const MaterialApp(
          home: CheckoutScreen(),
        ),
      ),
    );

    expect(find.text('Delivery details'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'PAY ₹1,299'), findsOneWidget);
  });
}
