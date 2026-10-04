import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'controllers/shop_controllers.dart';
import 'controllers/shop_scope.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'services/storage_service.dart';
import 'views/screens/forgot_password_screen.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/onboarding_screen.dart';
import 'views/screens/register_screen.dart';
import 'views/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ShopApp(
      controllers: ShopControllers.create(
        storage: StorageService(prefs),
      ),
    ),
  );
}

/// Root widget: theme + the single gate that decides which screen is on
/// screen: splash, onboarding, one of the three account pages, or the shop.
///
/// Sign in, sign out and moving between the account pages never touch the
/// [Navigator]. They flip a flag on a controller and this widget swaps the
/// page, which is why there is no route stack to keep in sync.
class ShopApp extends StatefulWidget {
  const ShopApp({super.key, required this.controllers});

  final ShopControllers controllers;

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  @override
  void dispose() {
    widget.controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController auth = widget.controllers.auth;

    return ShopScope(
      controllers: widget.controllers,
      child: MaterialApp(
        title: 'Shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            widget.controllers.boot,
            widget.controllers.onboarding,
            auth,
          ]),
          builder: (BuildContext context, Widget? child) {
            final bool booted = widget.controllers.boot.isReady;
            final bool onboarded = widget.controllers.onboarding.isComplete;
            final bool signedIn = auth.isSignedIn;

            // The whole navigation of the app is this one switch: splash,
            // onboarding, login, shop.
            //
            // The screens are deliberately not `const`: a canonicalised const
            // widget is identical to the previous one, and Flutter skips the
            // rebuild when the widget it is handed did not change.
            final Widget screen = switch ((
              booted,
              onboarded,
              signedIn,
            )) {
              (false, _, _) =>
                SplashScreen(key: const ValueKey<String>('splash')),
              (true, false, _) =>
                OnboardingScreen(key: const ValueKey<String>('onboarding')),
              (true, true, false) => switch (auth.mode) {
                AuthMode.signIn =>
                  LoginScreen(key: const ValueKey<String>('login')),
                AuthMode.register =>
                  RegisterScreen(key: const ValueKey<String>('register')),
                AuthMode.forgotPassword => ForgotPasswordScreen(
                  key: const ValueKey<String>('forgot-password'),
                ),
              },
              (true, true, true) =>
                HomeScreen(key: const ValueKey<String>('home')),
            };

            return AnimatedSwitcher(
              duration: booted ? AppMotion.medium : Duration.zero,
              child: screen,
            );
          },
        ),
      ),
    );
  }
}