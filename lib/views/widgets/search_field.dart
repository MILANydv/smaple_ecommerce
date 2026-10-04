import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Rounded search input with a clear button that only appears when there is
/// something to clear. The controller owning the text lives in the screen.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search products',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        return TextField(
          key: const Key('search_field'),
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    key: const Key('clear_search'),
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClear,
                  ),
          ),
        );
      },
    );
  }
}

/// Animated horizontal category filter. The selected chip grows slightly so
/// the change is visible even without a colour difference.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: categories.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final String category = categories[index];
          final bool isSelected = category == selected;

          return AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.enter,
            child: ChoiceChip(
              key: Key('category_$category'),
              label: Text(category),
              selected: isSelected,
              showCheckmark: false,
              avatar: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
              onSelected: (_) => onSelected(category),
            ),
          );
        },
      ),
    );
  }
}