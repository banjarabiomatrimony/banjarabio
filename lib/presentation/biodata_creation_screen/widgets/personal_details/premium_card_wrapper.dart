import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Reusable premium card wrapper used across biodata form sections.
/// Extracted from PersonalDetailsSection._buildPremiumCard.
class PremiumCardWrapper extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const PremiumCardWrapper({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.8.h, 4.w, 0.8.h),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 18),
                SizedBox(width: 2.5.w),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
