import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// Controller: owns the session.
///
/// It holds the signed in email, restores it from storage on start up, keeps
/// the form rules (so a screen never invents its own validation) and notifies
/// the view when something changed. The view renders, the controller decides.
class AuthController extends ChangeNotifier {
  AuthController({
    required StorageService storage,
    DateTime Function()? clock,
  }) : _storage = storage,
       _clock = clock ?? DateTime.now {
    _email = _storage.savedEmail;
  }

  /// Shortest password we accept.
  static const int minPasswordLength = 6;

  final StorageService _storage;

  /// Injectable clock so the greeting is deterministic in tests.
  final DateTime Function() _clock;

  String? _email;
  bool _isBusy = false;

  String? get currentUserEmail => _email;

  bool get isSignedIn => _email != null;

  /// True while a sign in request is in flight, so the button can show a
  /// spinner instead of pretending the tap did nothing.
  bool get isBusy => _isBusy;

  /// "student@school.edu" -> "student", used for the greeting on the home page.
  String get displayName {
    final String email = _email ?? '';
    final int at = email.indexOf('@');
    final String name = at > 0 ? email.substring(0, at) : email;
    return name.isEmpty ? 'there' : name;
  }

  String get initial {
    final String name = displayName;
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  /// Time based greeting, so the header feels alive.
  String get greeting {
    final int hour = _clock().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  static String? validateEmail(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    if ((value ?? '').length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    return null;
  }

  Future<void> signIn({required String email, required String password}) async {
    _isBusy = true;
    notifyListeners();

    _email = email.trim();
    await _storage.saveEmail(_email!);

    _isBusy = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _email = null;
    await _storage.clearSession();
    notifyListeners();
  }
}