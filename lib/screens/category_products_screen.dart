import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/local_category_products.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/top_message.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final products = productsForCategory(title);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [_CategoryCartButton()],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.offer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: AppColors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add items to basket and checkout with dummy payment.',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.66,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onAdd: () => _addToBasket(context, product),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addToBasket(BuildContext context, Product product) {
    context.read<CartProvider>().addToCart(product);
    showTopMessage(
      context,
      message: '${product.name} added to cart',
      type: TopMessageType.success,
    );
  }
}

class _CategoryCartButton extends StatelessWidget {
  const _CategoryCartButton();

  @override
  Widget build(BuildContext context) {
    final itemCount =
        context.select<CartProvider, int>((cart) => cart.itemCount);
    return IconButton(
      tooltip: 'Basket',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => CartScreen()),
        );
      },
      icon: Badge(
        isLabelVisible: itemCount > 0,
        label: Text('$itemCount'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
