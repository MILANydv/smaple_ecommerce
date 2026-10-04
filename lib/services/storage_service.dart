import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service: thin wrapper around SharedPreferences. Controllers talk to this,
/// never to the plugin directly, which keeps persistence swappable.
class StorageService {
  StorageService(this._prefs);

  static const String emailKey = 'saved_email';
  static const String cartKey = 'saved_cart';

  final SharedPreferences _prefs;

  String? get savedEmail => _prefs.getString(emailKey);

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

  Future<void> saveCart(Map<String, int> cart) =>
      _prefs.setString(cartKey, jsonEncode(cart));

  Future<void> clearSession() => _prefs.remove(emailKey);

  Future<void> clearCart() => _prefs.remove(cartKey);
}