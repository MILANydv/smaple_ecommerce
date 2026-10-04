import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service: thin wrapper around SharedPreferences. Controllers talk to this,
/// never to the plugin directly, which keeps persistence swappable.
class StorageService {
  StorageService(this._prefs);

  static const String emailKey = 'saved_email';
  static const String nameKey = 'user_name';
  static const String cartKey = 'saved_cart';
  static const String onboardingKey = 'onboarding_done';

  final SharedPreferences _prefs;

  String? get savedEmail => _prefs.getString(emailKey);

  /// Name typed on the register screen. Optional: an account that only ever
  /// signed in has no name, and the app falls back to the email prefix.
  String? get savedName => _prefs.getString(nameKey);

  bool get onboardingDone => _prefs.getBool(onboardingKey) ?? false;

  Map<String, int> loadCart() {
    final String? raw = _prefs.getString(cartKey);
    if (raw == null) return <String, int>{};

    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return <String, int>{};

    return decoded.map(
      (String key, Object? value) => MapEntry(key, (value as num).toInt()),
    );
  }

  Future<void> saveEmail(String email) => _prefs.setString(emailKey, email);

  Future<void> saveName(String name) => _prefs.setString(nameKey, name);

  Future<void> saveCart(Map<String, int> cart) =>
      _prefs.setString(cartKey, jsonEncode(cart));

  Future<void> clearSession() async {
    await _prefs.remove(emailKey);
    await _prefs.remove(nameKey);
  }

  Future<void> clearCart() => _prefs.remove(cartKey);

  Future<void> saveOnboardingDone() => _prefs.setBool(onboardingKey, true);

  Future<void> clearOnboardingDone() => _prefs.remove(onboardingKey);
}