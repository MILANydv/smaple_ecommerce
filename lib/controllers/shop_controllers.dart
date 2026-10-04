import 'package:flutter/foundation.dart';

import '../services/product_service.dart';
import '../services/storage_service.dart';
import 'auth_controller.dart';
import 'boot_controller.dart';
import 'cart_controller.dart';
import 'catalog_controller.dart';
import 'onboarding_controller.dart';

/// Every controller of the app, created once and handed down the tree.
///
/// [create] wires the dependencies for you: the boot controller gets the
/// catalog so it can prefetch, and the cart gets a lookup function that points
/// at the catalog, so ids stored on disk can be turned back into products.
class ShopControllers {
  ShopControllers({
    required this.auth,
    required this.catalog,
    required this.cart,
    required this.boot,
    required this.onboarding,
  });

  factory ShopControllers.create({
    required StorageService storage,
    ProductService? productService,
    DateTime Function()? clock,
    Duration splashDuration = const Duration(milliseconds: 1100),
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
      boot: BootController(
        catalog: catalog,
        minimumDuration: splashDuration,
      ),
      onboarding: OnboardingController(storage: storage),
    );
  }

  /// The session: who is signed in.
  final AuthController auth;

  /// The products and every filter applied to them.
  final CatalogController catalog;

  /// The cart, the money and the checkout.
  final CartController cart;

  /// Start up: how long the splash stays up.
  final BootController boot;

  /// First run: the onboarding slides.
  final OnboardingController onboarding;

  /// Everything the root needs to listen to at once.
  List<ChangeNotifier> get all => <ChangeNotifier>[
    auth,
    catalog,
    cart,
    boot,
    onboarding,
  ];

  void dispose() {
    for (final ChangeNotifier controller in all) {
      controller.dispose();
    }
  }
}