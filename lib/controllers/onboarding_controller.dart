import 'package:flutter/foundation.dart';

import '../models/onboarding_slide.dart';
import '../services/storage_service.dart';

/// Controller: owns the first run experience.
///
/// The slides are shown once. Finishing them (or skipping) writes a flag to
/// storage, so the next launch goes straight to the login screen. [restart]
/// clears the flag again, which is what the "Show onboarding" entry in the
/// account menu uses.
class OnboardingController extends ChangeNotifier {
  OnboardingController({required StorageService storage})
    : _storage = storage {
    _isComplete = _storage.onboardingDone;
  }

  final StorageService _storage;

  final List<OnboardingSlide> slides = kOnboardingSlides;

  bool _isComplete = false;
  int _page = 0;

  bool get isComplete => _isComplete;

  int get page => _page;

  int get pageCount => slides.length;

  bool get isFirstPage => _page == 0;

  bool get isLastPage => _page == pageCount - 1;

  /// Moves to the next slide, or finishes the flow on the last one.
  Future<void> next() async {
    if (isLastPage) {
      await complete();
      return;
    }
    goTo(_page + 1);
  }

  void goTo(int page) {
    if (page < 0 || page >= pageCount || page == _page) return;
    _page = page;
    notifyListeners();
  }

  Future<void> skip() => complete();

  Future<void> complete() async {
    if (_isComplete) return;
    _isComplete = true;
    await _storage.saveOnboardingDone();
    notifyListeners();
  }

  /// Shows the slides again, from the first one.
  Future<void> restart() async {
    _page = 0;
    _isComplete = false;
    await _storage.clearOnboardingDone();
    notifyListeners();
  }
}