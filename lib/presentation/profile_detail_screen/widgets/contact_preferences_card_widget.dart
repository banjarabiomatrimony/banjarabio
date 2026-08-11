import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_detail_chip_widget.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Contact preferences card displaying communication and marriage readiness information
/// Respects family-driven communication protocols
class ContactPreferencesCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;

  const ContactPreferencesCardWidget({
    super.key,
    required this.profileData,
    this.margin,
  });

  /// Returns AppLocalizations.of(context).notEntered for null or empty values, otherwise the value string.
  String _displayValue(BuildContext context, dynamic value) {
    if (value == null) return AppLocalizations.of(context)?.notEntered ?? 'Not Entered';
    final str = value.toString().trim();
    return str.isEmpty ? AppLocalizations.of(context)?.notEntered ?? 'Not Entered' : str;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final tertiary = theme.colorScheme.tertiary;

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: primary.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(0.8.h),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomIconWidget(
                  iconName: 'contact_phone',
                  color: primary,
                  size: 22,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(AppLocalizations.of(context)?.contactPreferences ?? 'Contact & Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    fontSize: AppTypography.headingSmall, // Slightly reduced for narrow columns
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 2.w,
            children: [
              ProfileDetailChipWidget(
                iconName: 'volunteer_activism',
                label: AppLocalizations.of(context)?.marriageReadiness ?? 'Marriage Readiness',
                value: _displayValue(context, profileData['marriageReadiness']),
                tintColor: primary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'person',
                label: AppLocalizations.of(context)?.contactPersonLabel ?? 'Contact Person',
                value: _displayValue(context, profileData['contactPerson']),
                tintColor: secondary,
              ),
              ProfileDetailChipWidget(
                iconName: 'groups',
                label: AppLocalizations.of(context)?.relationLabel ?? 'Relation',
                value: _displayValue(context, profileData['contactRelation']),
                tintColor: tertiary,
              ),
              ProfileDetailChipWidget(
                iconName: 'access_time',
                label: AppLocalizations.of(context)?.bestTimeToContact ?? 'Best Time to Contact',
                value: _displayValue(context, profileData['preferredContactTime']),
                tintColor: primary,
                fullWidth: true,
              ),
            ],
          ),
          if (profileData['partnerPreferences'] != null &&
              profileData['partnerPreferences'].toString().isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(AppLocalizations.of(context)?.partnerPreferences ?? 'Partner Preferences',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(4.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: primary.withValues(alpha: 0.6),
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                profileData['partnerPreferences'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
