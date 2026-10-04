import 'dart:convert';

import 'package:ecommerce/data/sample_products.dart';
import 'package:ecommerce/models/cart_item.dart';
import 'package:ecommerce/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product firstProduct() =>
    Product.fromJson(jsonDecode(kProductsJson)[0] as Map<String, dynamic>);

void main() {
  group('Product', () {
    test('reads every field out of a JSON map', () {
      final Product product = Product.fromJson(
        jsonDecode(kProductsJson)[0] as Map<String, dynamic>,
      );

      expect(product.id, 'p1');
      expect(product.name, 'Aurora Headphones');
      expect(product.price, 129.99);
      expect(product.category, 'Audio');
      expect(product.stock, 12);
      expect(product.isFeatured, isTrue);
      expect(product.toJson()['icon'], 'headphones');
    });

    test('falls back to safe values when optional fields are missing', () {
      const Product product = Product(
        id: 'x',
        name: 'X',
        category: 'Home',
        price: 10,
        rating: 4,
        iconName: 'lamp',
      );

      expect(product.description, isEmpty);
      expect(product.stock, 0);
      expect(product.inStock, isFalse);
      expect(product.isOnSale, isFalse);
      expect(product.stockLabel, 'Out of stock');
    });

    test('knows when it is discounted and by how much', () {
      final Product product = firstProduct();

      expect(product.isOnSale, isTrue);
      expect(product.originalPriceLabel, r'$179.99');
      expect(product.discountPercent, 28);
      expect(product.priceLabel, r'$129.99');
    });

    test('warns when only a few units are left', () {
      const Product product = Product(
        id: 'x',
        name: 'X',
        category: 'Wearables',
        price: 10,
        rating: 4,
        iconName: 'watch',
        stock: 2,
      );

      expect(product.isLowStock, isTrue);
      expect(product.stockLabel, 'Only 2 left');
    });
  });

  group('CartItem', () {
    test('multiplies price by quantity', () {
      final CartItem item = CartItem(product: firstProduct(), quantity: 3);

      expect(item.lineTotal, closeTo(389.97, 0.001));
      expect(item.lineTotalLabel, r'$389.97');
    });
  });
}