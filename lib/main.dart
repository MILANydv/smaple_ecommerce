import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth_controller.dart';
import 'controllers/shop_controllers.dart';
import 'controllers/shop_scope.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'services/storage_service.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';

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

/// Root widget: theme + the single gate that shows either the login screen or
/// the shop. Sign in and sign out never touch the [Navigator], they just flip
/// [AuthController.isSignedIn] and this widget swaps the page.
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
          listenable: auth,
          builder: (BuildContext context, Widget? child) {
            return AnimatedSwitcher(
              duration: AppMotion.medium,
              child: auth.isSignedIn
                  ? const HomeScreen(key: ValueKey<String>('home'))
                  : const LoginScreen(key: ValueKey<String>('login')),
            );
          },
        ),
      ),
    );
  }
}