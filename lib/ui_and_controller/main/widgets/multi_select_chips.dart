import 'package:flutter/material.dart';
import '../../../utils/theme_manager.dart';

class MultiSelectChips extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedItems;
  final Function(String) onToggle;

  const MultiSelectChips({
    super.key,
    required this.label,
    required this.options,
    required this.selectedItems,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyleSubHeading.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedItems.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onToggle(option),
              selectedColor: colorMainTheme.withOpacity(0.2),
              checkmarkColor: colorMainTheme,
              labelStyle: TextStyle(
                color: isSelected ? colorMainTheme : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? colorMainTheme : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

