/// Model: how strong a password looks, decided by [AuthController] rules.
///
/// The register form renders this, the controller owns the rule, so the meter
/// and the validation can never tell the user two different stories.
enum PasswordStrength {
  tooShort('Too short', 0),
  weak('Weak', 1),
  fair('Fair', 2),
  good('Good', 3),
  strong('Strong', 4);

  const PasswordStrength(this.label, this.score);

  /// Text shown next to the meter.
  final String label;

  /// 0 out of 4, so the meter can be drawn with a simple fraction.
  final int score;

  /// How many segments of the meter are filled in.
  int get filledSegments => score;

  bool get isAcceptable => score > 0;

  /// Shortest password [AuthController] accepts.
  static const int minimumLength = 6;

  /// Grades a password on length and character variety.
  ///
  /// Length does most of the work, mixing in an upper case letter, a digit and
  /// a symbol pushes the score up. Purely a UI hint: [minimumLength] is the
  /// rule that actually gates registration.
  factory PasswordStrength.from(String? value) {
    final String password = value ?? '';
    if (password.length < minimumLength) return PasswordStrength.tooShort;

    int score = 1;
    if (password.length >= 10) score++;
    if (password.length >= 14) score++;
    if (RegExp('[A-Z]').hasMatch(password) &&
        RegExp('[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp('[0-9]').hasMatch(password)) score++;

    if (score > 4) score = 4;
    return PasswordStrength.values[score];
  }
}
