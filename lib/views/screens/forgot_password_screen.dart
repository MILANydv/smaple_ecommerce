import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/shop_scope.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/auth_scaffold.dart';

/// View: the "forgot password" page.
///
/// One field and a confirmation panel. There is no backend, so the panel is
/// driven by [AuthController.resetSent] rather than by a server response.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send(AuthController auth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await auth.sendResetLink(email: _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AuthController auth = ShopScope.of(context).auth;

    return AuthScaffold(
      onBack: auth.showSignIn,
      title: auth.resetSent ? 'Check your inbox' : 'Reset your password',
      subtitle: auth.resetSent
          ? 'We sent a reset link to ${auth.resetEmail}.'
          : 'Enter the email you signed up with and we will send you a link '
                'to choose a new password.',
      footer: auth.resetSent
          ? null
          : Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  'Remembered it?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  key: const Key('sign_in_link'),
                  onPressed: auth.showSignIn,
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
      child: auth.resetSent
          ? _ConfirmationPanel(
              email: auth.resetEmail ?? '',
              onResend: () => _send(auth),
              onDismiss: () {
                auth.dismissResetConfirmation();
                _emailController.clear();
              },
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    key: const Key('email_field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _send(auth),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@school.edu',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                    validator: AuthController.validateEmail,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    key: const Key('send_reset_button'),
                    onPressed: auth.isBusy ? null : () => _send(auth),
                    icon: auth.isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      auth.isBusy ? 'Sending link' : 'Send reset link',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Demo app: no mail is actually sent.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Shown after the link was "sent": what happens next, plus a way back.
class _ConfirmationPanel extends StatelessWidget {
  const _ConfirmationPanel({
    required this.email,
    required this.onResend,
    required this.onDismiss,
  });

  final String email;
  final VoidCallback onResend;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      key: const Key('reset_confirmation'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: AppRadii.card,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Link sent to $email',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Open the link on this device to set a new password. It expires in '
            '15 minutes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: const Key('resend_button'),
            onPressed: onResend,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Send again'),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            key: const Key('use_another_email_button'),
            onPressed: onDismiss,
            child: const Text('Use a different email'),
          ),
        ],
      ),
    );
  }
}
