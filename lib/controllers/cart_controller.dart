import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

/// How the cart finds a [Product] for a stored id. Injected so the controller
/// does not have to know about the catalog controller.
typedef ProductResolver = Product? Function(String id);

/// Controller: owns the shopping cart and every number on the checkout screen.
///
/// Quantities live as `id -> quantity`, exactly the shape that is written to
/// storage, so restoring a cart after a restart is a one line lookup. Prices
/// and names are resolved through [resolveProduct] at read time.
class CartController extends ChangeNotifier {
  CartController({required StorageService storage, ProductResolver? resolveProduct})
    : _storage = storage,
      _resolveProduct = resolveProduct ?? _missingProduct {
    _quantities.addAll(_storage.loadCart());
  }

  /// Spend this much (after discounts) and shipping is free.
  static const double freeShippingThreshold = 75;

  static const double standardShipping = 6.95;
  static const double taxRate = 0.08;

  /// Promo codes the checkout accepts.
  static const Map<String, double> promoPercentByCode = <String, double>{
    'SAVE10': 0.10,
    'WELCOME15': 0.15,
  };

  static const String freeShippingCode = 'SHIPFREE';

  static Product? _missingProduct(String id) => null;

  final StorageService _storage;
  final ProductResolver _resolveProduct;
  final Map<String, int> _quantities = <String, int>{};

  String? _promoCode;

  /// The raw `id -> quantity` map, useful for tests and storage.
  Map<String, int> get quantities => Map<String, int>.unmodifiable(_quantities);

  String? get promoCode => _promoCode;

  bool get isEmpty => _quantities.isEmpty;

  bool get isNotEmpty => _quantities.isNotEmpty;

  /// Cart lines resolved against the catalog, in the order they were added.
  List<CartItem> get items {
    final List<CartItem> lines = <CartItem>[];
    _quantities.forEach((String id, int quantity) {
      final Product? product = _resolveProduct(id);
      if (product != null) {
        lines.add(CartItem(product: product, quantity: quantity));
      }
    });
    return lines;
  }

  int get itemCount =>
      _quantities.values.fold<int>(0, (int sum, int q) => sum + q);

  String get itemCountLabel => '$itemCount ${itemCount == 1 ? 'item' : 'items'}';

  int quantityOf(Product product) => _quantities[product.id] ?? 0;

  double get subtotal => items.fold<double>(
    0,
    (double sum, CartItem item) => sum + item.lineTotal,
  );

  double get discount => promoPercentByCode[_promoCode] == null
      ? 0
      : (subtotal * promoPercentByCode[_promoCode]!);

  /// Free above the threshold, or when the promo code covers shipping.
  double get shipping {
    if (isEmpty) return 0;
    if (_promoCode == freeShippingCode) return 0;
    final double payable = subtotal - discount;
    if (payable >= freeShippingThreshold) return 0;
    return standardShipping;
  }

  double get tax => (subtotal - discount) * taxRate;

  double get total {
    final double sum = subtotal - discount + shipping + tax;
    return sum < 0 ? 0 : sum;
  }

  /// 0..1 progress towards free shipping, for the little meter on the cart.
  double get freeShippingProgress {
    if (subtotal <= 0) return 0;
    final double payable = subtotal - discount;
    if (payable >= freeShippingThreshold) return 1;
    return (payable / freeShippingThreshold).clamp(0.0, 1.0);
  }

  /// How much more is needed for free shipping, or `null` when it is met.
  double? get amountToFreeShipping {
    final double missing = freeShippingThreshold - (subtotal - discount);
    if (missing <= 0) return null;
    return missing;
  }

  bool get hasFreeShipping => amountToFreeShipping == null;

  Future<void> add(Product product, {int quantity = 1}) async {
    if (quantity <= 0 || !product.inStock) return;
    final int next = quantityOf(product) + quantity;
    _quantities[product.id] = next > product.stock ? product.stock : next;
    await _persist();
  }

  Future<void> removeOne(Product product) async {
    await setQuantity(product, quantityOf(product) - 1);
  }

  Future<void> setQuantity(Product product, int quantity) async {
    if (quantity <= 0) {
      _quantities.remove(product.id);
    } else {
      _quantities[product.id] = quantity > product.stock
          ? product.stock
          : quantity;
    }
    await _persist();
  }

  /// Drops the whole line and hands it back so the view can offer an undo.
  Future<CartItem?> removeLine(Product product) async {
    final int quantity = quantityOf(product);
    if (quantity == 0) return null;
    final CartItem? removed = items
        .where((CartItem item) => item.product.id == product.id)
        .firstOrNull;
    _quantities.remove(product.id);
    await _persist();
    return removed ?? CartItem(product: product, quantity: quantity);
  }

  /// Puts a line back after an undo.
  Future<void> restore(CartItem item) async {
    _quantities[item.product.id] = quantityOf(item.product) + item.quantity;
    await _persist();
  }

  Future<void> clear() async {
    _quantities.clear();
    _promoCode = null;
    await _storage.clearCart();
    notifyListeners();
  }

  /// Returns `true` when the code was accepted.
  bool applyPromo(String code) {
    final String normalized = code.trim().toUpperCase();
    final bool known =
        promoPercentByCode.containsKey(normalized) ||
        normalized == freeShippingCode;
    if (!known) return false;
    _promoCode = normalized;
    notifyListeners();
    return true;
  }

  void removePromo() {
    if (_promoCode == null) return;
    _promoCode = null;
    notifyListeners();
  }

  /// Turns the cart into an [Order] and empties it.
  Order placeOrder() {
    final DateTime now = DateTime.now();
    final Order order = Order(
      id: 'SO-${now.millisecondsSinceEpoch % 1000000}',
      placedAt: now,
      lines: items.map(OrderLine.fromCartItem).toList(),
      subtotal: subtotal,
      shipping: shipping,
      discount: discount,
      tax: tax,
      total: total,
    );
    _quantities.clear();
    _promoCode = null;
    _storage.clearCart();
    notifyListeners();
    return order;
  }

  Future<void> _persist() async {
    await _storage.saveCart(_quantities);
    notifyListeners();
  }
}