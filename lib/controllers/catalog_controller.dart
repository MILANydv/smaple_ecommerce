import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

/// The ways the catalog grid can be ordered.
enum CatalogSort {
  featured('Featured'),
  priceLowToHigh('Price: low to high'),
  priceHighToLow('Price: high to low'),
  topRated('Top rated'),
  nameAtoZ('Name: A to Z');

  const CatalogSort(this.label);

  final String label;
}

/// Controller: owns the product catalog and every filter applied to it.
///
/// Loading, searching, category selection and sorting all live here. The home
/// screen only reads [visibleProducts] and forwards user intent.
class CatalogController extends ChangeNotifier {
  CatalogController({required ProductService service})
    : _productService = service;

  /// The pseudo category that means "no category filter".
  static const String allCategories = 'All';

  final ProductService _productService;

  List<Product> _products = <Product>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = allCategories;
  CatalogSort _sort = CatalogSort.featured;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;

  String get selectedCategory => _selectedCategory;

  CatalogSort get sort => _sort;

  bool get hasProducts => _products.isNotEmpty;

  /// "All" first, then the categories that actually exist in the data.
  List<String> get categories {
    final Set<String> unique = _products
        .map((Product product) => product.category)
        .toSet();
    return <String>[allCategories, ...unique];
  }

  /// Products that survived the search box, the category chips and the sort.
  List<Product> get visibleProducts {
    final String query = _searchQuery.trim().toLowerCase();

    final List<Product> filtered = _products.where((Product product) {
      final bool matchesCategory =
          _selectedCategory == allCategories ||
          product.category == _selectedCategory;
      final bool matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return _sorted(filtered);
  }

  /// The carousel on top of the home page.
  List<Product> get featuredProducts =>
      _products.where((Product product) => product.isFeatured).toList();

  /// Only shown while no search or category filter is active.
  bool get showFeaturedSection =>
      _searchQuery.trim().isEmpty &&
      _selectedCategory == allCategories &&
      featuredProducts.isNotEmpty;

  bool get hasActiveFilters =>
      _searchQuery.trim().isNotEmpty || _selectedCategory != allCategories;

  int get resultCount => visibleProducts.length;

  /// "6 products" / "2 results for \"head\""
  String get resultSummary {
    final int count = resultCount;
    final String noun = count == 1 ? 'product' : 'products';
    final String query = _searchQuery.trim();
    if (query.isEmpty) return '$count $noun';
    return '$count ${count == 1 ? 'result' : 'results'} for "$query"';
  }

  Product? productById(String id) {
    for (final Product product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> loadProducts({bool force = false}) async {
    if (_isLoading) return;
    if (_products.isNotEmpty && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.fetchProducts();
    } catch (_) {
      _errorMessage = 'We could not load the catalog.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSort(CatalogSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = allCategories;
    notifyListeners();
  }

  List<Product> _sorted(List<Product> products) {
    final List<Product> copy = List<Product>.of(products);
    switch (_sort) {
      case CatalogSort.featured:
        copy.sort((Product a, Product b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
      case CatalogSort.priceLowToHigh:
        copy.sort((Product a, Product b) => a.price.compareTo(b.price));
      case CatalogSort.priceHighToLow:
        copy.sort((Product a, Product b) => b.price.compareTo(a.price));
      case CatalogSort.topRated:
        copy.sort((Product a, Product b) => b.rating.compareTo(a.rating));
      case CatalogSort.nameAtoZ:
        copy.sort(
          (Product a, Product b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
    return copy;
  }
}