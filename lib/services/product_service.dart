import 'dart:convert';

import '../data/sample_products.dart';
import '../models/product.dart';

/// Service: the only place that knows products arrive asynchronously and come
/// from JSON. Swap the body for a real HTTP call and nothing else changes.
class ProductService {
  ProductService({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(latency);

    final List<dynamic> decoded = jsonDecode(kProductsJson) as List<dynamic>;

    return decoded
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}