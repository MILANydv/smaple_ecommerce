import 'product.dart';

/// Model: one product plus how many of it the customer wants.
class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  String get lineTotalLabel => Product.formatPrice(lineTotal);
}