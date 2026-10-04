import 'package:ecommerce/controllers/boot_controller.dart';
import 'package:ecommerce/controllers/catalog_controller.dart';
import 'package:ecommerce/controllers/shop_controllers.dart';
import 'package:ecommerce/main.dart';
import 'package:ecommerce/services/product_service.dart';
import 'package:ecommerce/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  group('BootController', () {
    test('loads the catalog once and then reports ready', () async {
      final CatalogController catalog = CatalogController(
        service: ProductService(latency: Duration.zero),
      );
      final BootController boot = BootController(
        catalog: catalog,
        minimumDuration: Duration.zero,
      );
      int notifications = 0;
      boot.addListener(() => notifications++);

      await boot.start();
      await boot.start();

      expect(boot.isReady, isTrue);
      expect(catalog.visibleProducts.length, 10);
      expect(notifications, 1, reason: 'the second start() is ignored');

      boot.dispose();
      catalog.dispose();
    });
  });

  group('OnboardingController', () {
    late ShopControllers controllers;

    setUp(() async => controllers = await buildControllers());
    tearDown(() => controllers.dispose());

    test('starts on the first slide and walks forward', () {
      final onboarding = controllers.onboarding;

      expect(onboarding.isComplete, isFalse);
      expect(onboarding.page, 0);
      expect(onboarding.isFirstPage, isTrue);
      expect(onboarding.pageCount, 3);

      onboarding.goTo(1);
      expect(onboarding.page, 1);
      expect(onboarding.isLastPage, isFalse);

      onboarding.goTo(2);
      expect(onboarding.isLastPage, isTrue);
    });

    test('ignores duplicates and out of range pages', () {
      int notifications = 0;
      controllers.onboarding.addListener(() => notifications++);

      controllers.onboarding.goTo(0);
      controllers.onboarding.goTo(-1);
      controllers.onboarding.goTo(99);

      expect(notifications, 0);
      expect(controllers.onboarding.page, 0);
    });

    test('next finishes the flow on the last slide', () async {
      final onboarding = controllers.onboarding;

      await onboarding.next();
      expect(onboarding.page, 1);
      expect(onboarding.isComplete, isFalse);

      await onboarding.next();
      expect(onboarding.page, 2);
      expect(onboarding.isComplete, isFalse);

      await onboarding.next();
      expect(onboarding.isComplete, isTrue);
    });

    test('skip and complete store the flag, restart clears it', () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await controllers.onboarding.skip();
      expect(controllers.onboarding.isComplete, isTrue);
      expect(prefs.getBool(StorageService.onboardingKey), isTrue);

      await controllers.onboarding.restart();
      expect(controllers.onboarding.isComplete, isFalse);
      expect(controllers.onboarding.page, 0);

      prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(StorageService.onboardingKey), isNull);
    });

    test('a remembered tour is restored on the next launch', () async {
      final ShopControllers restored = await buildControllers(
        initialPrefs: <String, Object>{StorageService.onboardingKey: true},
      );
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      expect(restored.onboarding.isComplete, isTrue);
      expect(prefs.getBool(StorageService.onboardingKey), isTrue);

      restored.dispose();
    });
  });

  group('Splash and onboarding screens', () {
    testWidgets('the splash comes first and prefetches the catalog', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final ShopControllers controllers = await buildControllers(
        initialPrefs: <String, Object>{StorageService.onboardingKey: true},
      );
      await tester.pumpWidget(ShopApp(controllers: controllers));

      expect(find.byKey(const Key('splash_screen')), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Preparing your catalog'), findsOneWidget);
      expect(controllers.boot.isReady, isFalse);

      await settleBoot(tester);

      expect(find.byKey(const Key('splash_screen')), findsNothing);
      expect(find.text('Welcome to Shop'), findsOneWidget);
      expect(
        controllers.catalog.visibleProducts.length,
        10,
        reason: 'the products were fetched while the splash was up',
      );
    });

    testWidgets('a first launch walks through the onboarding slides', (
      WidgetTester tester,
    ) async {
      final ShopControllers controllers = await pumpShop(
        tester,
        onboardingSeen: false,
      );

      expect(find.byKey(const Key('onboarding_screen')), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('The whole shop in one place'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('A cart that remembers'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Get started'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onboarding_screen')), findsNothing);
      expect(find.text('Welcome to Shop'), findsOneWidget);
      expect(controllers.onboarding.isComplete, isTrue);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(StorageService.onboardingKey), isTrue);
    });

    testWidgets('a tapped dot jumps to that slide', (WidgetTester tester) async {
      await pumpShop(tester, onboardingSeen: false);

      await tester.tap(find.byKey(const Key('dot_2')));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Checkout in three taps'), findsOneWidget);
    });

    testWidgets('skip ends the tour right away', (WidgetTester tester) async {
      final ShopControllers controllers = await pumpShop(
        tester,
        onboardingSeen: false,
      );

      await tester.tap(find.byKey(const Key('skip_onboarding')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Shop'), findsOneWidget);
      expect(controllers.onboarding.isComplete, isTrue);
    });

    testWidgets('a returning user never sees the onboarding again', (
      WidgetTester tester,
    ) async {
      await pumpShop(tester);

      expect(find.byKey(const Key('onboarding_screen')), findsNothing);
      expect(find.text('Welcome to Shop'), findsOneWidget);
    });

    testWidgets('the account menu replays the tour', (
      WidgetTester tester,
    ) async {
      final ShopControllers controllers = await pumpShop(tester);
      await signIn(tester);

      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('replay_tour_item')));
      await tester.pumpAndSettle();

      expect(controllers.onboarding.isComplete, isFalse);
      expect(find.byKey(const Key('onboarding_screen')), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('skip_onboarding')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('product_p1')), findsOneWidget);
    });
  });
}