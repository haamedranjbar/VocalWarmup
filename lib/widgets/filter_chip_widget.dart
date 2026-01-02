import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum FilterType { all, beginner, intermediate, advanced }

class FilterChipWidget extends StatelessWidget {
  final FilterType filterType;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const FilterChipWidget({
    super.key,
    required this.filterType,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? AppTheme.cardDark : const Color(0xFFE2E8F0)),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected ? [AppTheme.getNeonShadow()] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.backgroundDark
                : (isDark
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF4B5563)),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}




