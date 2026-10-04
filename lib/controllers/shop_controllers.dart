import 'package:flutter/foundation.dart';

import '../services/product_service.dart';
import '../services/storage_service.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';
import 'catalog_controller.dart';

/// The three controllers of the app, created once and handed down the tree.
///
/// [create] wires the dependencies for you: the cart gets a lookup function
/// that points at the catalog, so ids stored on disk can be turned back into
/// products.
class ShopControllers {
  ShopControllers({
    required this.auth,
    required this.catalog,
    required this.cart,
  });

  factory ShopControllers.create({
    required StorageService storage,
    ProductService? productService,
    DateTime Function()? clock,
  }) {
    final CatalogController catalog = CatalogController(
      service: productService ?? ProductService(),
    );
    return ShopControllers(
      auth: AuthController(storage: storage, clock: clock),
      catalog: catalog,
      cart: CartController(
        storage: storage,
        resolveProduct: catalog.productById,
      ),
    );
  }

  final AuthController auth;
  final CatalogController catalog;
  final CartController cart;

  /// Every controller the root needs to listen to at once.
  List<ChangeNotifier> get all => <ChangeNotifier>[auth, catalog, cart];

  void dispose() {
    for (final ChangeNotifier controller in all) {
      controller.dispose();
    }
  }
}