import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Promo code input. Shows the applied code as a removable chip, otherwise a
/// compact text field with an "Apply" action.
class PromoCodeField extends StatefulWidget {
  const PromoCodeField({
    super.key,
    required this.appliedCode,
    required this.onApply,
    required this.onRemove,
  });

  final String? appliedCode;
  final ValueChanged<String> onApply;
  final VoidCallback onRemove;

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final String code = _controller.text.trim();
    if (code.isEmpty) return;
    widget.onApply(code);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? applied = widget.appliedCode;

    if (applied != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: AppRadii.chip,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.sell_rounded,
              size: 18,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              '$applied applied',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            InkWell(
              key: const Key('remove_promo'),
              onTap: widget.onRemove,
              borderRadius: AppRadii.chip,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return TextField(
      key: const Key('promo_field'),
      controller: _controller,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _apply(),
      decoration: InputDecoration(
        hintText: 'Promo code',
        helperText: 'Try SAVE10 or SHIPFREE',
        helperStyle: theme.textTheme.labelSmall,
        prefixIcon: const Icon(Icons.sell_outlined),
        suffixIcon: TextButton(
          key: const Key('apply_promo'),
          onPressed: _apply,
          child: const Text('Apply'),
        ),
      ),
    );
  }
}