import 'package:flutter/material.dart';

import '../../controllers/catalog_controller.dart';
import '../../controllers/shop_controllers.dart';
import '../../controllers/shop_scope.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/product.dart';
import '../widgets/account_button.dart';
import '../widgets/cart_button.dart';
import '../widgets/catalog_skeleton.dart';
import '../widgets/empty_state.dart';
import '../widgets/featured_card.dart';
import '../widgets/product_card.dart';
import '../widgets/search_field.dart';
import '../widgets/section_header.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

/// View: the shop itself, a sliver based page with
/// greeting -> search -> categories -> featured -> results grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Hero tags have to be unique per route, so each list passes its own prefix
  /// and the detail screen animates the tile that was actually tapped.
  static const String gridHeroPrefix = 'grid';
  static const String featuredHeroPrefix = 'featured';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  CatalogController get _catalog => ShopScope.of(context).catalog;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The controller comes from an InheritedWidget, so the first safe moment
    // to read it is here. loadProducts is a no-op when the catalog is loaded.
    _catalog.loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProduct(Product product, String heroPrefix) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProductDetailScreen(
          product: product,
          heroPrefix: heroPrefix,
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) => const CartScreen()),
    );
  }

  Future<void> _openSortSheet() async {
    final CatalogController catalog = _catalog;

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text('Sort products', style: theme.textTheme.titleLarge),
              ),
              for (final CatalogSort sort in CatalogSort.values)
                ListTile(
                  key: Key('sort_${sort.name}'),
                  title: Text(sort.label),
                  trailing: sort == catalog.sort
                      ? Icon(
                          Icons.check_rounded,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    catalog.setSort(sort);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        );
      },
    );
  }

  void _clearFilters() {
    _searchController.clear();
    _catalog.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ShopControllers controllers = ShopScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge(controllers.all),
      builder: (BuildContext context, Widget? child) {
        final CatalogController catalog = controllers.catalog;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => catalog.loadProducts(force: true),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 68,
                  titleSpacing: AppSpacing.page,
                  title: _Greeting(
                    greeting: controllers.auth.greeting,
                    name: controllers.auth.displayName,
                  ),
                  actions: <Widget>[
                    IconButton(
                      key: const Key('sort_button'),
                      tooltip: 'Sort products',
                      onPressed: _openSortSheet,
                      icon: const Icon(Icons.swap_vert_rounded),
                    ),
                    CartButton(
                      count: controllers.cart.itemCount,
                      onPressed: _openCart,
                    ),
                    AccountButton(
                      auth: controllers.auth,
                      onboarding: controllers.onboarding,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.xs,
                      AppSpacing.page,
                      0,
                    ),
                    child: SearchField(
                      controller: _searchController,
                      onChanged: catalog.search,
                      onClear: _clearFilters,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                SliverToBoxAdapter(
                  child: CategoryChips(
                    categories: catalog.categories,
                    selected: catalog.selectedCategory,
                    onSelected: catalog.selectCategory,
                  ),
                ),
                if (catalog.showFeaturedSection) ...<Widget>[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.lg,
                        AppSpacing.page,
                        AppSpacing.sm,
                      ),
                      child: SectionHeader(
                        title: 'Featured',
                        subtitle: 'Picks from this week',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 236,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.page,
                        ),
                        itemCount: catalog.featuredProducts.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final Product product = catalog.featuredProducts[index];
                          return FeaturedCard(
                            product: product,
                            heroPrefix: HomeScreen.featuredHeroPrefix,
                            onTap: () => _openProduct(
                              product,
                              HomeScreen.featuredHeroPrefix,
                            ),
                            onAddToCart: () =>
                                controllers.cart.add(product),
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.sm,
                      AppSpacing.page,
                      AppSpacing.sm,
                    ),
                    child: _ResultsHeader(
                      summary: catalog.resultSummary,
                      hasFilters: catalog.hasActiveFilters,
                      onClear: _clearFilters,
                    ),
                  ),
                ),
                ..._buildResults(controllers, theme),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildResults(ShopControllers controllers, ThemeData theme) {
    final CatalogController catalog = controllers.catalog;

    if (catalog.isLoading) {
      return <Widget>[const CatalogSkeleton(itemCount: 6)];
    }

    if (catalog.errorMessage != null) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Something went wrong',
            subtitle: catalog.errorMessage,
            actionLabel: 'Try again',
            onAction: () => catalog.loadProducts(force: true),
          ),
        ),
      ];
    }

    final List<Product> products = catalog.visibleProducts;
    if (products.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            subtitle: 'Try another search term or category',
            actionLabel: catalog.hasActiveFilters ? 'Clear filters' : null,
            onAction: catalog.hasActiveFilters ? _clearFilters : null,
          ),
        ),
      ];
    }

    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 262,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
            final Product product = products[index];
            return ProductCard(
              key: Key('product_${product.id}'),
              product: product,
              quantityInCart: controllers.cart.quantityOf(product),
              heroPrefix: HomeScreen.gridHeroPrefix,
              onTap: () => _openProduct(product, HomeScreen.gridHeroPrefix),
              onAddToCart: () => controllers.cart.add(product),
            );
          }, childCount: products.length),
        ),
      ),
    ];
  }
}

/// Two line greeting in the app bar.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.greeting, required this.name});

  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          greeting,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}

/// "6 products" plus a quick way to drop the active filters.
class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.summary,
    required this.hasFilters,
    required this.onClear,
  });

  final String summary;
  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Text(
              summary,
              key: ValueKey<String>(summary),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        if (hasFilters)
          TextButton.icon(
            key: const Key('clear_filters'),
            onPressed: onClear,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
            label: const Text('Clear'),
          ),
      ],
    );
  }
}