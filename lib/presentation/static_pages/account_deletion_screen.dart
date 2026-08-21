import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  bool _isConfirmed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.deleteAccount ?? 'Delete Account'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CustomIconWidget(
                iconName: 'warning',
                color: theme.colorScheme.error,
                size: 64,
              ),
            ),
            SizedBox(height: 4.h),
            Center(
              child: Text(AppLocalizations.of(context)?.areYouSureYouWantToDeleteYourAccount ?? 'Are you sure you want to delete your account?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppTypography.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 2.h),
            Text(AppLocalizations.of(context)?.deletingYourAccountWillResultIn ?? 'Deleting your account will result in:',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            _buildWarningItem(
              theme,
              AppLocalizations.of(context)?.allYourProfileDataPermanentlyRemoved ?? 'All your profile data will be permanently removed.',
            ),
            _buildWarningItem(
              theme,
              AppLocalizations.of(context)?.activeSubscriptionCancelledNoRefund ?? 'Your active subscription will be cancelled without refund.',
            ),
            _buildWarningItem(
              theme,
              AppLocalizations.of(context)?.loseMatchesAndSavedProfiles ?? 'You will lose all your matches and saved profiles.',
            ),
            _buildWarningItem(theme, AppLocalizations.of(context)?.actionIsIrreversible ?? 'This action is irreversible.'),
            const Spacer(),
            Row(
              children: [
                Checkbox(
                  value: _isConfirmed,
                  onChanged: (value) {
                    setState(() {
                      _isConfirmed = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(AppLocalizations.of(context)?.iUnderstandThatThisActionCannotBeUndone ?? 'I understand that this action cannot be undone.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isConfirmed && !_isLoading ? _handleDelete : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  disabledBackgroundColor: theme.colorScheme.error.withValues(
                    alpha: 0.3,
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 2.5.h,
                        width: 2.5.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppLocalizations.of(context)?.deleteMyAccount ?? 'Delete My Account'),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: 'circle',
            color: theme.colorScheme.error,
            size: 8,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);

    try {
      final authRepository = AuthRepository();
      await authRepository.deleteAccount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.accountAndAllDataDeletedSuccessfully ?? 'Account and all data deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to splash/login and clear stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.splash,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToDeleteAccount(e.toString()) ?? 'Failed to delete account: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
