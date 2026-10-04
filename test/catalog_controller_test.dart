import 'package:ecommerce/controllers/catalog_controller.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogController buildCatalog() =>
    CatalogController(service: ProductService(latency: Duration.zero));

void main() {
  late CatalogController catalog;

  setUp(() {
    catalog = buildCatalog();
  });

  test('starts empty and reports that it is loading', () async {
    expect(catalog.hasProducts, isFalse);

    final Future<void> load = catalog.loadProducts();
    expect(catalog.isLoading, isTrue);

    await load;
    expect(catalog.isLoading, isFalse);
    expect(catalog.visibleProducts.length, 10);
    expect(catalog.categories, contains('All'));
    expect(catalog.categories, contains('Audio'));
  });

  test('loading twice does not refetch unless it is forced', () async {
    await catalog.loadProducts();
    await catalog.loadProducts();

    expect(catalog.visibleProducts.length, 10);
  });

  test('search matches the name and the category', () async {
    await catalog.loadProducts();

    catalog.search('keyboard');
    expect(catalog.resultSummary, '1 result for "keyboard"');

    catalog.search('audio');
    expect(catalog.resultCount, 2);

    catalog.search('   ');
    expect(catalog.resultCount, 10);
    expect(catalog.hasActiveFilters, isFalse);
  });

  test('category chips narrow the list and combine with search', () async {
    await catalog.loadProducts();

    catalog.selectCategory('Home');
    expect(catalog.resultCount, 2);
    expect(catalog.selectedCategory, 'Home');
    expect(catalog.hasActiveFilters, isTrue);

    catalog.search('lamp');
    expect(catalog.resultCount, 1);

    catalog.clearFilters();
    expect(catalog.selectedCategory, CatalogController.allCategories);
    expect(catalog.searchQuery, isEmpty);
    expect(catalog.resultCount, 10);
  });

  test('sorting reorders without touching the filters', () async {
    await catalog.loadProducts();

    catalog.setSort(CatalogSort.priceLowToHigh);
    final List<double> prices = catalog.visibleProducts
        .map((Product product) => product.price)
        .toList();
    expect(prices, <double>[...prices]..sort());

    catalog.setSort(CatalogSort.priceHighToLow);
    expect(catalog.visibleProducts.first.price, 279.00);

    catalog.setSort(CatalogSort.nameAtoZ);
    expect(catalog.visibleProducts.first.name, 'Aurora Headphones');

    catalog.setSort(CatalogSort.featured);
    expect(catalog.visibleProducts.first.isFeatured, isTrue);
  });

  test('the featured list only holds products marked as featured', () async {
    await catalog.loadProducts();

    expect(catalog.featuredProducts, isNotEmpty);
    expect(
      catalog.featuredProducts.every((Product p) => p.isFeatured),
      isTrue,
    );
    expect(catalog.showFeaturedSection, isTrue);

    catalog.selectCategory('Home');
    expect(catalog.showFeaturedSection, isFalse);
  });

  test('productById resolves a stored cart id', () async {
    await catalog.loadProducts();

    expect(catalog.productById('p3')?.name, 'Pulse Smartwatch');
    expect(catalog.productById('nope'), isNull);
  });

  test('notifies listeners when the filters change', () async {
    await catalog.loadProducts();

    int notifications = 0;
    catalog.addListener(() => notifications++);

    catalog.search('lamp');
    catalog.selectCategory('Home');
    catalog.setSort(CatalogSort.nameAtoZ);
    catalog.setSort(CatalogSort.nameAtoZ);

    expect(notifications, 3, reason: 'the repeated sort is ignored');
  });
}