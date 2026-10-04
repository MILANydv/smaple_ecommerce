import 'package:flutter/foundation.dart';

import '../models/password_strength.dart';
import '../services/storage_service.dart';

/// Which of the three account pages is on screen.
///
/// The root widget switches on it, so moving between sign in, register and
/// forgot password never pushes a route: it is a controller decision, like the
/// rest of the navigation in this app.
enum AuthMode { signIn, register, forgotPassword }

/// Controller: owns the session and every account rule.
///
/// It holds the signed in email and name, restores them from storage on start
/// up, keeps the form rules (so a screen never invents its own validation) and
/// notifies the view when something changed. The view renders, the controller
/// decides.
class AuthController extends ChangeNotifier {
  AuthController({
    required StorageService storage,
    DateTime Function()? clock,
    Duration requestLatency = const Duration(milliseconds: 650),
  }) : _storage = storage,
       _clock = clock ?? DateTime.now,
       _requestLatency = requestLatency {
    _email = _storage.savedEmail;
    _name = _storage.savedName;
  }

  /// Shortest password we accept. The register meter uses the same number.
  static const int minPasswordLength = PasswordStrength.minimumLength;

  final StorageService _storage;

  /// Injectable clock so the greeting is deterministic in tests.
  final DateTime Function() _clock;

  /// How long a fake request takes, so the busy state on the button is real.
  final Duration _requestLatency;

  String? _email;
  String? _name;
  bool _isBusy = false;
  AuthMode _mode = AuthMode.signIn;
  String? _resetEmail;

  String? get currentUserEmail => _email;

  String? get currentUserName => _name;

  bool get isSignedIn => _email != null;

  /// Which account page is showing.
  AuthMode get mode => _mode;

  /// True on register and forgot password, where a back button makes sense.
  bool get canGoBack => _mode != AuthMode.signIn;

  /// True while a request is in flight, so the button can show a spinner
  /// instead of pretending the tap did nothing.
  bool get isBusy => _isBusy;

  /// Email a reset link was "sent" to, or null before that happened.
  String? get resetEmail => _resetEmail;

  bool get resetSent => _resetEmail != null;

  /// "student@school.edu" -> "student", used for the greeting on the home page.
  /// A registered account greets with the name it signed up with.
  String get displayName {
    final String name = _name?.trim() ?? '';
    if (name.isNotEmpty) return name;

    final String email = _email ?? '';
    final int at = email.indexOf('@');
    final String fallback = at > 0 ? email.substring(0, at) : email;
    return fallback.isEmpty ? 'there' : fallback;
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

  // ---------------------------------------------------------------- validators

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

  static String? validateName(String? value) {
    final String name = (value ?? '').trim();
    if (name.isEmpty) return 'Name is required';
    if (name.length < 2) return 'Use at least 2 characters';
    return null;
  }

  /// Both fields must match, and the check runs after the password rule.
  static String? validateConfirmation(
    String? password,
    String? confirmation,
  ) {
    if ((confirmation ?? '').isEmpty) return 'Repeat the password';
    if (password != confirmation) return 'Passwords do not match';
    return null;
  }

  /// Shared strength rule, exposed for the register meter.
  static PasswordStrength strengthOf(String? value) =>
      PasswordStrength.from(value);

  // ------------------------------------------------------------------- modes

  void showSignIn() => _setMode(AuthMode.signIn);

  void showRegister() => _setMode(AuthMode.register);

  void showForgotPassword() => _setMode(AuthMode.forgotPassword);

  void _setMode(AuthMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _isBusy = false;
    _resetEmail = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- requests

  Future<void> signIn({required String email, required String password}) async {
    _startRequest();
    await Future<void>.delayed(_requestLatency);

    _email = email.trim();
    _name = _storage.savedName;
    await _storage.saveEmail(_email!);

    _endRequest();
  }

  /// Creates the account and signs it straight in, the way most shops do.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _startRequest();
    await Future<void>.delayed(_requestLatency);

    _name = name.trim();
    _email = email.trim();
    await _storage.saveName(_name!);
    await _storage.saveEmail(_email!);

    _endRequest();
  }

  /// Pretends to mail a reset link. There is no backend, so the confirmation
  /// screen is driven by this flag instead of a network response.
  Future<void> sendResetLink({required String email}) async {
    _startRequest();
    await Future<void>.delayed(_requestLatency);

    _resetEmail = email.trim();

    _endRequest();
  }

  /// Dismisses the "check your inbox" panel so the form can be used again.
  void dismissResetConfirmation() {
    if (_resetEmail == null) return;
    _resetEmail = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    _email = null;
    _name = null;
    _resetEmail = null;
    _mode = AuthMode.signIn;
    await _storage.clearSession();
    notifyListeners();
  }

  void _startRequest() {
    _isBusy = true;
    notifyListeners();
  }

  void _endRequest() {
    _isBusy = false;
    notifyListeners();
  }
}
