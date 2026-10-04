import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Phone sized surface: the layout has to survive the narrowest common screen
/// (and any RenderFlex overflow fails the test).
const Size phone = Size(390, 844);

void main() {
  testWidgets('the shop lays out on a small phone', (WidgetTester tester) async {
    final controllers = await pumpShop(tester, size: phone);
    await signIn(tester, email: 'ada@shop.dev');

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('product_p1')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('product_p1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product_p1')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Aurora Headphones'), findsWidgets);

    await tester.drag(
      find.byKey(const Key('detail_scroll')),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Why you will like it'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add_to_cart_button')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(controllers.cart.itemCount, 1);

    await tester.tap(find.byKey(const Key('open_cart')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('checkout_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkout_button')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Order confirmed'), findsOneWidget);
  });

  testWidgets('the login screen lays out on a small phone', (
    WidgetTester tester,
  ) async {
    await pumpShop(tester, size: phone);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('sign_in_button')), findsOneWidget);
  });

  testWidgets('the account sheet and sort sheet fit on a small phone', (
    WidgetTester tester,
  ) async {
    await pumpShop(tester, size: phone);
    await signIn(tester);

    await tester.tap(find.byKey(const Key('sort_button')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Sort products'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('sign_out_item')), findsOneWidget);
  });
}