import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/core/repositories/email_repository.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

class EmailPreferencesScreen extends StatefulWidget {
  const EmailPreferencesScreen({super.key});

  @override
  State<EmailPreferencesScreen> createState() => _EmailPreferencesScreenState();
}

class _EmailPreferencesScreenState extends State<EmailPreferencesScreen> {
  final EmailRepository _repository = EmailRepository();
  Map<String, dynamic> _prefs = {
    'daily_recommendations': true,
    'weekly_digest': true,
    'monthly_digest': true,
    'match_alerts': true,
    'interest_alerts': true,
    'local_profiles': true,
    'offers': true,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _repository.getPreferences();
    if (prefs.isNotEmpty) {
      setState(() {
        _prefs = prefs;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePreference(String column, bool value) async {
    setState(() {
      _prefs[column] = value;
    });
    await _repository.updatePreference(column, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n?.emailNotifications ?? 'Email Notifications',
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              children: [
                _buildSectionHeader(theme, 'Engagement'),
                _buildToggle(
                  'daily_recommendations',
                  l10n?.dailyMatchPicks ?? 'Daily Match Picks',
                  'Get a daily email with handpicked profiles for you.',
                  Icons.auto_awesome,
                ),
                _buildToggle(
                  'match_alerts',
                  l10n?.newMatchAlerts ?? 'New Match Alerts',
                  'Instant email when you get a mutual match.',
                  Icons.favorite,
                ),
                _buildToggle(
                  'interest_alerts',
                  'Interest Notifications',
                  'Emails when someone bookmarks your profile.',
                  Icons.bookmark,
                ),
                SizedBox(height: 3.h),
                _buildSectionHeader(theme, 'Community & News'),
                _buildToggle(
                  'weekly_digest',
                  'Weekly Community Wrap-up',
                  'A summary of new members and activity from the past week.',
                  Icons.insert_chart,
                ),
                _buildToggle(
                  'monthly_digest',
                  'Monthly Report',
                  'Your month at a glance with key stats.',
                  Icons.calendar_month,
                ),
                _buildToggle(
                  'local_profiles',
                  'New Local Members',
                  'Be notified when someone from your district joins.',
                  Icons.location_on,
                ),
                _buildToggle(
                  'offers',
                  'Special Offers',
                  'Exclusive deals and discounts for your membership.',
                  Icons.card_giftcard,
                ),
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Text(
                    'We promise not to spam you. You can turn these off at any time.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 1.h, top: 1.h),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontSize: AppTypography.bodySmall,
        ),
      ),
    );
  }

  Widget _buildToggle(String column, String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      margin: EdgeInsets.only(bottom: 1.5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        secondary: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        value: _prefs[column] ?? true,
        onChanged: (value) => _togglePreference(column, value),
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }
}
