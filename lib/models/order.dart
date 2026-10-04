import 'cart_item.dart';
import 'product.dart';

/// Model: a line of a placed order. It copies the product name and price, so
/// the receipt stays correct even if the catalog changes later.
class OrderLine {
  const OrderLine({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderLine.fromCartItem(CartItem item) {
    return OrderLine(
      name: item.product.name,
      quantity: item.quantity,
      unitPrice: item.product.price,
    );
  }

  final String name;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;
}

/// Model: the receipt shown after checkout.
class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.tax,
    required this.total,
  });

  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final double subtotal;
  final double shipping;
  final double discount;
  final double tax;
  final double total;

  int get itemCount =>
      lines.fold<int>(0, (int sum, OrderLine line) => sum + line.quantity);

  String get itemCountLabel =>
      '$itemCount ${itemCount == 1 ? 'item' : 'items'}';

  String get totalLabel => Product.formatPrice(total);

  String get placedAtLabel {
    final String hh = placedAt.hour.toString().padLeft(2, '0');
    final String mm = placedAt.minute.toString().padLeft(2, '0');
    return '${placedAt.day}/${placedAt.month}/${placedAt.year} · $hh:$mm';
  }
}