import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/onboarding_controller.dart';

/// Avatar in the app bar. Tapping it opens the account sheet, where signing
/// out lives together with a confirmation dialog.
class AccountButton extends StatelessWidget {
  const AccountButton({super.key, required this.auth, required this.onboarding});

  final AuthController auth;
  final OnboardingController onboarding;

  static const String _signOutValue = 'sign-out';
  static const String _tourValue = 'tour';

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.logout_rounded),
          title: const Text('Sign out?'),
          content: Text(
            'You will need to sign in again as ${auth.currentUserEmail}.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              key: const Key('confirm_sign_out'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return PopupMenuButton<String>(
      key: const Key('logout_button'),
      tooltip: 'Account',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 46),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.control),
      onSelected: (String value) {
        if (value == _signOutValue) _confirmSignOut(context);
        if (value == _tourValue) onboarding.restart();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Signed in', style: theme.textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(
                auth.currentUserEmail ?? '',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          key: Key('replay_tour_item'),
          value: _tourValue,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.auto_awesome_rounded),
            title: Text('Show onboarding'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          key: Key('sign_out_item'),
          value: _signOutValue,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded),
            title: Text('Sign out'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: CircleAvatar(
          radius: 17,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            auth.initial,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}