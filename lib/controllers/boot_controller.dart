import 'package:flutter/foundation.dart';

import 'catalog_controller.dart';

/// Controller: owns the start up sequence behind the splash screen.
///
/// While the splash is on screen it does two things at once: it keeps the
/// splash visible for a minimum time (so it never flashes) and it prefetches
/// the catalog, so the shop page has products on its very first frame.
class BootController extends ChangeNotifier {
  BootController({
    required this.catalog,
    this.minimumDuration = const Duration(milliseconds: 1100),
  });

  final CatalogController catalog;
  final Duration minimumDuration;

  bool _isReady = false;
  bool _isStarted = false;
  bool _isDisposed = false;

  /// `false` while the splash is still on screen.
  bool get isReady => _isReady;

  bool get isStarted => _isStarted;

  /// Kicks off the boot sequence. Safe to call more than once, the splash
  /// widget can call it from `didChangeDependencies` as well.
  Future<void> start() async {
    if (_isStarted) return;
    _isStarted = true;

    final Stopwatch stopwatch = Stopwatch()..start();
    final Future<void> products = catalog.loadProducts();

    final Duration remaining = minimumDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    await products;

    _isReady = true;
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}