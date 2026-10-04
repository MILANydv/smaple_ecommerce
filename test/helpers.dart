import 'package:ecommerce/controllers/shop_controllers.dart';
import 'package:ecommerce/main.dart';
import 'package:ecommerce/services/product_service.dart';
import 'package:ecommerce/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fixed "now" so the greeting in the app bar never changes between runs.
final DateTime fixedNoon = DateTime(2026, 5, 4, 12);

/// Controllers wired to fake storage and a product service with no latency.
Future<ShopControllers> buildControllers({
  Map<String, Object> initialPrefs = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return ShopControllers.create(
    storage: StorageService(prefs),
    productService: ProductService(latency: Duration.zero),
    clock: () => fixedNoon,
  );
}

/// Mounts the whole app with the given controllers.
///
/// The surface is enlarged so a full phone sized layout is on screen: on the
/// default 800x600 test window the catalog grid starts below the fold.
Future<ShopControllers> pumpShop(
  WidgetTester tester, {
  Size size = const Size(1000, 1800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final ShopControllers controllers = await buildControllers();
  await tester.pumpWidget(ShopApp(controllers: controllers));
  return controllers;
}

/// Signs in through the form, the way a user would.
Future<void> signIn(
  WidgetTester tester, {
  String email = 'a@b.com',
  String password = 'flutter',
}) async {
  await tester.enterText(find.byKey(const Key('email_field')), email);
  await tester.enterText(find.byKey(const Key('password_field')), password);
  await tester.tap(find.byKey(const Key('sign_in_button')));
  await tester.pumpAndSettle();
}