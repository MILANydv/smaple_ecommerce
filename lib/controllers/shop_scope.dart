import 'package:flutter/widgets.dart';

import 'shop_controllers.dart';

/// Makes the controllers reachable from any widget below it.
///
/// This is the only bridge between the view layer and the controller layer:
/// a screen asks `ShopScope.of(context).cart` and never receives a controller
/// through its constructor.
class ShopScope extends InheritedWidget {
  const ShopScope({
    super.key,
    required this.controllers,
    required super.child,
  });

  final ShopControllers controllers;

  static ShopControllers of(BuildContext context) {
    final ShopScope? scope = context
        .dependOnInheritedWidgetOfExactType<ShopScope>();
    assert(scope != null, 'ShopScope is missing from the widget tree');
    return scope!.controllers;
  }

  @override
  bool updateShouldNotify(ShopScope oldWidget) =>
      oldWidget.controllers != controllers;
}