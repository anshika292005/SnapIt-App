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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredProducts();
    final visibleProducts =
        _query.isEmpty ? allLocalProducts.take(8).toList() : results;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.yellow,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            'Search store',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const _SearchCartButton(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search milk, chips, cola...',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                        onChanged: (value) {
                          setState(() => _query = value.trim());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_query.isEmpty) ...[
                      Text(
                        'Popular searches',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final suggestion in const [
                            'milk',
                            'bread',
                            'cola',
                            'chips',
                            'lemon',
                            'atta',
                            'chocolate',
                          ])
                            ActionChip(
                              label: Text(suggestion),
                              avatar: const Icon(Icons.search, size: 16),
                              onPressed: () {
                                _controller.text = suggestion;
                                setState(() => _query = suggestion);
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Recommended for you',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ] else ...[
                      Text(
                        '${results.length} result${results.length == 1 ? '' : 's'} for "$_query"',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_query.isNotEmpty && results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptySearch(query: _query),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: visibleProducts.length,
                  itemBuilder: (context, index) {
                    final product = visibleProducts[index];
                    return ProductCard(
                      product: product,
                      onAdd: () {
                        context.read<CartProvider>().addToCart(product);
                        showTopMessage(
                          context,
                          message: '${product.name} added to cart',
                          type: TopMessageType.success,
                        );
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Product> _filteredProducts() {
    final needle = _query.toLowerCase();
    if (needle.isEmpty) {
      return const [];
    }

    return allLocalProducts.where((product) {
      return product.name.toLowerCase().contains(needle) ||
          product.category.toLowerCase().contains(needle) ||
          product.description.toLowerCase().contains(needle);
    }).toList();
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 28),
              const Icon(Icons.search_off, size: 44, color: AppColors.muted),
              const SizedBox(height: 12),
              Text(
                'No results for "$query"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different product name or category.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchCartButton extends StatelessWidget {
  const _SearchCartButton();

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
