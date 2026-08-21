import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

class FeatureComparisonSheet extends StatelessWidget {
  const FeatureComparisonSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeatureComparisonSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // List of features to compare
    final comparisonRows = [
      _ComparisonRow('Profile Views / Day', ['10', '50', '100', '∞', '∞']),
      _ComparisonRow('Photos Limit', ['5', '10', '20', '∞', '∞']),
      _ComparisonRow('Direct Messaging', ['No', 'Yes', 'Yes', 'Yes', 'Yes']),
      _ComparisonRow('Advanced Filters', ['No', 'Yes', 'Yes', 'Yes', 'Yes']),
      _ComparisonRow('Profile Boosts / Mo', ['No', '1', '3', '∞', '∞']),
      _ComparisonRow('Verified Badge', ['No', 'No', 'Yes', 'Yes', 'Yes']),
      _ComparisonRow('Ad-Free Experience', ['No', 'Yes', 'Yes', 'Yes', 'Yes']),
      _ComparisonRow('Contact Unlocks / Mo', ['No', 'No', '10', '50', '∞']),
      _ComparisonRow('Incognito Mode', ['No', 'No', 'No', 'Yes', 'Yes']),
      _ComparisonRow('Dedicated Manager', ['No', 'No', 'No', 'No', 'Yes']),
      _ComparisonRow('Profile Makeover', ['No', 'No', 'No', 'No', 'Yes']),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handlebar
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Feature Matrix Comparison',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Sticky horizontal headers for plan columns
              Container(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                color: theme.cardColor.withValues(alpha: 0.9),
                child: Row(
                  children: [
                    Expanded(
                      flex: 32,
                      child: Padding(
                        padding: EdgeInsets.only(left: 3.w),
                        child: Text(
                          'FEATURE',
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex: 13, child: _buildPlanHeaderColumn('FREE', Colors.grey)),
                    Expanded(flex: 13, child: _buildPlanHeaderColumn('SLVR', Colors.blueGrey)),
                    Expanded(flex: 14, child: _buildPlanHeaderColumn('GOLD', Colors.amber)),
                    Expanded(flex: 14, child: _buildPlanHeaderColumn('PLAT', Colors.cyan)),
                    Expanded(flex: 14, child: _buildPlanHeaderColumn('ETRN', Colors.deepPurple)),
                  ],
                ),
              ),

              // Content rows list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: comparisonRows.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = comparisonRows[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 32,
                            child: Padding(
                              padding: EdgeInsets.only(left: 3.w, right: 1.w),
                              child: Text(
                                row.featureName,
                                style: TextStyle(
                                  fontSize: AppTypography.labelMedium,
                                  fontWeight: AppTypography.semiBold,
                                ),
                              ),
                            ),
                          ),
                          ...row.values.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final val = entry.value;
                            // Flex values match the headers: 13, 13, 14, 14, 14
                            final flexValue = (idx == 0 || idx == 1) ? 13 : 14;
                            return Expanded(
                              flex: flexValue,
                              child: Center(
                                child: _buildValueWidget(theme, val),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanHeaderColumn(String text, Color color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            fontWeight: AppTypography.bold,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildValueWidget(ThemeData theme, String val) {
    if (val == 'Yes') {
      return Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 16);
    }
    if (val == 'No') {
      return Icon(Icons.cancel_outlined, color: theme.colorScheme.outline.withValues(alpha: 0.3), size: 14);
    }
    return Text(
      val,
      style: TextStyle(
        fontSize: AppTypography.labelMedium,
        fontWeight: AppTypography.bold,
        color: val == '∞' ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
    );
  }
}

class _ComparisonRow {
  final String featureName;
  final List<String> values;
  _ComparisonRow(this.featureName, this.values);
}
