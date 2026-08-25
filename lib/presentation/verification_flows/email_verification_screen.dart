import 'dart:async';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  final bool _isSent = false;
  Timer? _countdownTimer;
  /*
  final AuthRepository _authRepository = AuthRepository();
  int _timer = 60;
  */

  @override
  void initState() {
    super.initState();
    final email = SessionManager.instance.email;
    if (email != null) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /*
  void _startTimer() {
    _timer = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timer--;
        });
      }
    });
  }
  */

  Future<void> _sendVerification() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      AppFeedback.showWarning(
        context,
        AppLocalizations.of(context)?.pleaseEnterAValidEmailAddress ?? 'Please enter a valid email address',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simplified for V1: Just update the profile flag
      final profileRepository = ProfileRepository();
      final response = await profileRepository.getOwnProfile();

      await response.fold(
        onSuccess: (ownProfile) async {
          if (ownProfile != null) {
            final updateRes = await profileRepository.updateProfile(
              ownProfile.userId,
              {'email_verified': true, 'email': _emailController.text},
            );

            await updateRes.fold(
              onSuccess: (_) async {
                if (mounted) {
                  setState(() => _isLoading = false);
                  AppFeedback.showSuccess(
                    context,
                    AppLocalizations.of(context)?.emailVerifiedSuccessfully10Points ?? 'Email Verified Successfully! +10 Points',
                  );
                  Navigator.of(context).pop(true);
                }
              },
              onFailure: (error) async {
                if (mounted) {
                  setState(() => _isLoading = false);
                  AppFeedback.showError(
                    context,
                    error,
                    contextTag: 'verification',
                    fallbackMessage: AppLocalizations.of(context)?.updateFailed(''),
                  );
                }
              },
            );
          } else {
            if (mounted) {
              setState(() => _isLoading = false);
              AppFeedback.showError(
                context,
                AppLocalizations.of(context)?.profileNotFound ?? 'Profile not found',
                contextTag: 'profile',
              );
            }
          }
        },
        onFailure: (error) async {
          if (mounted) {
            setState(() => _isLoading = false);
            AppFeedback.showError(
              context,
              error,
              contextTag: 'profile',
              fallbackMessage: AppLocalizations.of(context)?.failedToLoadProfileError(''),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppFeedback.showError(
          context,
          e,
          contextTag: 'verification',
        );
      }
    }
  }

  /* Legacy OTP Flow
  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) {
      AppFeedback.showWarning(
        context,
        AppLocalizations.of(context)?.pleaseEnter6DigitOtp ?? 'Please enter 6-digit OTP',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authRepository.verifyEmailOtp(
        _emailController.text,
        _otpController.text,
      );

      if (success) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppFeedback.showSuccess(
            context,
            AppLocalizations.of(context)?.emailVerifiedSuccessfully10Points ?? 'Email Verified Successfully! +10 Points',
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppFeedback.showError(
          context,
          e,
          contextTag: 'verification',
          fallbackMessage: 'Verification failed',
        );
      }
    }
  }

  Future<void> _checkVerifiedStatus() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.refreshSession();
      final user = AppSupabaseClient.currentUser;

      if (user?.emailConfirmedAt != null) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppFeedback.showSuccess(
            context,
            AppLocalizations.of(context)?.verified10PointsAddedToTrustScore ?? 'Verified! +10 Points added to Trust Score',
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          AppFeedback.showInfo(
            context,
            AppLocalizations.of(context)?.notVerifiedYetPleaseClickTheLinkInYourEm ?? 'Not verified yet. Please click the link in your email.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppFeedback.showError(
          context,
          e,
          contextTag: 'verification',
          fallbackMessage: 'Error checking status',
        );
      }
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)?.emailVerification ?? 'Email Verification'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            const CustomIconWidget(
              iconName: 'email',
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 3.h),
            Text(
              _isSent ? (AppLocalizations.of(context)?.checkInbox ?? 'Check your Inbox') : (AppLocalizations.of(context)?.verifyEmailAddressHeading ?? 'Verify Email Address'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(AppLocalizations.of(context)?.verifyYourEmailAddressToAddTrustAndReach ?? 'Verify your email address to add trust and reach more profiles.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            /*
            Text(
              _isSent
                  ? 'We have sent a verification link or a 6-digit code to ${_emailController.text}.'
                  : 'We will send a verification link or code to your email address.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            */
            if (_isSent) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: AppColors.opacity10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: AppColors.opacity30)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.emailVerificationTip ?? 'Tip: If your email contains a "Log In" link instead of a code, just click that link to verify.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue[800],
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 4.h),

            if (!_isSent) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.emailAddress ?? 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.mail),
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendVerification,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 2.5.h,
                          width: 2.5.h,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)?.sendVerification ?? 'Send Verification'),
                ),
              ),
            ] /* else ...[
               // Legacy OTP UI commented out
            ] */,
          ],
        ),
      ),
    );
  }
}
