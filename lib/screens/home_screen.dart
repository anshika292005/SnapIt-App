import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/local_category_products.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/top_message.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'category_products_screen.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _QuickHeader()),
          SliverToBoxAdapter(child: _PromoBanner()),
          SliverToBoxAdapter(child: _CategoryGrid()),
          SliverToBoxAdapter(
            child: _ProductPreviewSection(
              title: 'Dairy, Bread & Milk',
              products: homeDairyBreadMilkProducts,
            ),
          ),
          SliverToBoxAdapter(
            child: _ProductPreviewSection(
              title: 'Cold Drinks & Juices',
              products: homeColdDrinksJuicesProducts,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickHeader extends StatefulWidget {
  const _QuickHeader();

  @override
  State<_QuickHeader> createState() => _QuickHeaderState();
}

class _QuickHeaderState extends State<_QuickHeader> {
  final LocationService _locationService = createLocationService();
  String _locationLabel = 'Home - Fresh groceries delivered fast';
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _detectLocation());
  }

  Future<void> _detectLocation() async {
    if (_isLoadingLocation) {
      return;
    }

    setState(() => _isLoadingLocation = true);
    try {
      final location = await _locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }
      setState(() => _locationLabel = location.label);
      showTopMessage(
        context,
        message: 'Live location updated',
        type: TopMessageType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showTopMessage(
        context,
        message: 'Allow location permission to detect your live location',
        type: TopMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.yellow,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.green),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Delivery in 8 minutes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                      ),
                ),
              ),
              const _CartBadge(),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _detectLocation,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _isLoadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.my_location, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _openSearch,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Text(
                    'Search atta, milk, chips...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CategoryProductsScreen(
                title: 'Stock up on daily essentials',
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/categories/mega_grocery_banner.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shop by category',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = (width / 150).floor().clamp(3, 10);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _CategoryTile(category: category);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductPreviewSection extends StatelessWidget {
  const _ProductPreviewSection({
    required this.title,
    required this.products,
  });

  final String title;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CategoryProductsScreen(title: title),
                    ),
                  );
                },
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: visibleProducts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 190,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.66,
            ),
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
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final _HomeCategory category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (category.opensLocalProducts) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CategoryProductsScreen(title: category.title),
            ),
          );
          return;
        }
        showTopMessage(
          context,
          message: '${category.title} selected',
          type: TopMessageType.info,
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAF2FF)),
              ),
              child: Image.asset(
                category.asset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategory {
  const _HomeCategory({
    required this.title,
    required this.asset,
    this.opensLocalProducts = false,
  });

  final String title;
  final String asset;
  final bool opensLocalProducts;
}

const _categories = [
  _HomeCategory(
    title: 'Breakfast & Instant Food',
    asset: 'assets/categories/slice_6_5.png',
    opensLocalProducts: true,
  ),
  _HomeCategory(
    title: 'Sweet Tooth',
    asset: 'assets/categories/slice_7_3.png',
    opensLocalProducts: true,
  ),
  _HomeCategory(
    title: 'Tea, Coffee & Milk Drinks',
    asset: 'assets/categories/slice_7_1_0.png',
    opensLocalProducts: true,
  ),
  _HomeCategory(
    title: 'Bakery & Biscuits',
    asset: 'assets/categories/slice_8_4.png',
    opensLocalProducts: true,
  ),
  _HomeCategory(
    title: 'Atta, Rice & Dal',
    asset: 'assets/categories/slice_10.png',
    opensLocalProducts: true,
  ),
  _HomeCategory(
    title: 'Snacks & Munchies',
    asset: 'assets/categories/blinkit_image.png',
    opensLocalProducts: true,
  ),
];

class _CartBadge extends StatelessWidget {
  const _CartBadge();

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
        child: const Icon(Icons.shopping_cart_outlined, color: AppColors.ink),
      ),
    );
  }
}
