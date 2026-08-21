import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';

/// Reusable premium card wrapper used across biodata form sections.
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tinted icon container
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.2.h),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: AppTypography.labelMedium,
                      fontWeight: AppTypography.extraBold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
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
