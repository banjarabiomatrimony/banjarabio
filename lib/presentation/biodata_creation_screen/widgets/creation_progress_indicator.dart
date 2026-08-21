import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/models/creation_step_config.dart';

/// Progress indicator with animated interactive step tabs and profile strength badge.
class CreationProgressIndicator extends StatefulWidget {
  final int currentStep;
  final List<CreationStep> activeSteps;
  final Map<String, dynamic> formData;
  final Map<String, bool> sectionValidation;
  final bool isLite;
  final bool isEditMode;
  final ValueChanged<int>? onStepTapped;

  const CreationProgressIndicator({
    super.key,
    required this.currentStep,
    required this.activeSteps,
    required this.formData,
    required this.sectionValidation,
    this.isLite = false,
    this.isEditMode = false,
    this.onStepTapped,
  });

  @override
  State<CreationProgressIndicator> createState() =>
      _CreationProgressIndicatorState();
}

class _CreationProgressIndicatorState extends State<CreationProgressIndicator> {
  final ScrollController _tabScrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _updateKeys();
  }

  @override
  void didUpdateWidget(covariant CreationProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSteps.length != widget.activeSteps.length) {
      _updateKeys();
    }
    if (oldWidget.currentStep != widget.currentStep) {
      _scrollToActiveTab();
    }
  }

  void _updateKeys() {
    _tabKeys.clear();
    for (int i = 0; i < widget.activeSteps.length; i++) {
      _tabKeys.add(GlobalKey());
    }
  }

  void _scrollToActiveTab() {
    if (widget.currentStep < _tabKeys.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final keyContext = _tabKeys[widget.currentStep].currentContext;
        if (keyContext != null) {
          Scrollable.ensureVisible(
            keyContext,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  IconData _getStepIcon(CreationStep step) {
    switch (step) {
      case CreationStep.personal:
        return Icons.person_rounded;
      case CreationStep.family:
        return Icons.family_restroom_rounded;
      case CreationStep.education:
        return Icons.work_rounded;
      case CreationStep.photo:
        return Icons.photo_camera_rounded;
      case CreationStep.location:
        return Icons.location_on_rounded;
    }
  }

  String _getStepTitle(BuildContext context, CreationStep step) {
    final l10n = AppLocalizations.of(context);
    switch (step) {
      case CreationStep.personal:
        return l10n?.personalDetails ?? 'Personal';
      case CreationStep.family:
        return l10n?.familyDetails ?? 'Family';
      case CreationStep.education:
        return l10n?.educationProfession ?? 'Career';
      case CreationStep.photo:
        return l10n?.photos ?? 'Photos';
      case CreationStep.location:
        return l10n?.locationPreferences ?? 'Location';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = ProfileModel.calculateScore(widget.formData);
    final totalSteps = widget.activeSteps.length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Bar: Step count & Strength Badge / Completion percentage
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStepIcon(widget.activeSteps[widget.currentStep]),
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _getStepTitle(context, widget.activeSteps[widget.currentStep]),
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '(${widget.currentStep + 1}/$totalSteps)',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.semiBold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (!widget.isLite)
                  _buildProfileStrengthBadge(context, theme, percentage),
              ],
            ),
          ),
          SizedBox(height: 1.h),

          // 2. Animated Interactive Tab Pills (horizontal scrollable)
          SizedBox(
            height: 40,
            child: ListView.separated(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: totalSteps,
              separatorBuilder: (_, _) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final isSelected = index == widget.currentStep;
                final step = widget.activeSteps[index];
                final isValid = widget.sectionValidation[step.validationKey] ?? false;

                return _AnimatedStepPill(
                  key: _tabKeys.length > index ? _tabKeys[index] : null,
                  step: step,
                  title: _getStepTitle(context, step),
                  icon: _getStepIcon(step),
                  stepNumber: index + 1,
                  isSelected: isSelected,
                  isValid: isValid,
                  canTap: widget.isEditMode || widget.onStepTapped != null,
                  onTap: () {
                    if (widget.onStepTapped != null) {
                      HapticFeedback.selectionClick();
                      widget.onStepTapped!(index);
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(height: 0.8.h),

          // 3. Smooth animated completion progress line
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: percentage / 100.0),
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 4,
                    backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 80
                          ? const Color(0xFF10B981)
                          : (percentage >= 50
                              ? const Color(0xFFD97706)
                              : theme.colorScheme.primary),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStrengthBadge(
      BuildContext context, ThemeData theme, int percentage) {
    String badgeText;
    Color badgeColor;
    IconData badgeIcon;

    if (percentage < 40) {
      badgeText = AppLocalizations.of(context)?.bronze ?? 'Bronze';
      badgeColor = const Color(0xFFCD7F32);
      badgeIcon = Icons.stars_outlined;
    } else if (percentage < 80) {
      badgeText = AppLocalizations.of(context)?.silver ?? 'Silver';
      badgeColor = const Color(0xFF9E9E9E);
      badgeIcon = Icons.stars_rounded;
    } else {
      badgeText = AppLocalizations.of(context)?.gold ?? 'Gold';
      badgeColor = const Color(0xFFD97706);
      badgeIcon = Icons.stars_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 13, color: badgeColor),
          SizedBox(width: 1.w),
          Text(
            '$percentage% • $badgeText',
            style: TextStyle(
              color: badgeColor,
              fontWeight: AppTypography.extraBold,
              fontSize: AppTypography.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Tab Pill for each step
class _AnimatedStepPill extends StatelessWidget {
  final CreationStep step;
  final String title;
  final IconData icon;
  final int stepNumber;
  final bool isSelected;
  final bool isValid;
  final bool canTap;
  final VoidCallback onTap;

  const _AnimatedStepPill({
    super.key,
    required this.step,
    required this.title,
    required this.icon,
    required this.stepNumber,
    required this.isSelected,
    required this.isValid,
    required this.canTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected
            ? null
            : (isValid
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : (isValid
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.15)),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: canTap ? onTap : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step Icon or Checkmark
                if (isValid && !isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  )
                else
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                SizedBox(width: 1.5.w),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isValid
                            ? const Color(0xFF047857)
                            : theme.colorScheme.onSurfaceVariant),
                    fontSize: AppTypography.labelSmall,
                    fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
