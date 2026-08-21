import 'package:banjarabio/core/constants/app_typography.dart';
import 'dart:async';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

class MobileVerificationScreen extends StatefulWidget {
  const MobileVerificationScreen({super.key});

  @override
  State<MobileVerificationScreen> createState() =>
      _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final bool _isOtpSent = false;
  bool _isLoading = false;
  Timer? _countdownTimer;
  /*
  final AuthRepository _authRepository = AuthRepository();
  int _timer = 30;
  */

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _sendOtp() async {
    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.pleaseEnterAValid10DigitMobileNumber ?? 'Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simplified for V1: Just update the profile flag
      final profileRepository = ProfileRepository();
      final response = await profileRepository.getOwnProfile();

      await response.fold(
        onSuccess: (profile) async {
          if (profile != null) {
            final updateRes = await profileRepository.updateProfile(
              profile.userId,
              {'phone_verified': true, 'phone_number': _mobileController.text},
            );

            await updateRes.fold(
              onSuccess: (_) async {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)?.mobileVerifiedSuccessfully10Points ?? 'Mobile Verified Successfully! +10 Points'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop(true);
                }
              },
              onFailure: (error) async {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)?.updateFailed(error) ??
                            'Failed to update profile: $error',
                      ),
                    ),
                  );
                }
              },
            );
          } else {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)?.profileNotFound ?? 'Profile not found')),
              );
            }
          }
        },
        onFailure: (error) async {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)?.failedToLoadProfileError(error) ??
                      'Failed to load profile: $error',
                ),
              ),
            );
          }
        },
      );
      /* Legacy OTP Flow
      final phoneNumber = '+91${_mobileController.text}';
      await _authRepository.signInWithPhone(phoneNumber);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
          _startTimer();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.verificationCodeSent ?? 'Verification code sent!')),
        );
      }
      */
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)?.errorWithLabel(e.toString()) ??
                'Error: ${e.toString()}',
          ),
        ));
      }
    }
  }

  /* Legacy OTP Flow
  void _verifyOtp() async {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.pleaseEnterFull6DigitOtp ?? 'Please enter full 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phoneNumber = '+91${_mobileController.text}';
      final success = await _authRepository.verifyPhoneOtp(
        phoneNumber,
        _otpController.text,
      );

      if (success) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppLocalizations.of(context)?.mobileVerifiedSuccessfully10Points ?? 'Mobile Verified Successfully! +10 Points'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  */

  /* Legacy Timer
  void _startTimer() {
    _timer = 30;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)?.mobileVerification ?? 'Mobile Verification'),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomIconWidget(
              iconName: 'phone_android',
              color: Colors.blue,
              size: 48,
            ),
            SizedBox(height: 3.h),
            Text(
              _isOtpSent ? (AppLocalizations.of(context)?.verifyOtp ?? 'Verify OTP') : (AppLocalizations.of(context)?.enterMobileNumber ?? 'Enter Mobile Number'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.verifyYourMobileNumberToAddTrustAndReach ?? 'Verify your mobile number to add trust and reach more profiles.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            /*
            Text(
              _isOtpSent
                  ? 'We have sent a verification code to +91 ${_mobileController.text}'
                  : 'We will send you a One Time Password (OTP) to verify your number.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            */
            SizedBox(height: 4.h),

            if (!_isOtpSent) ...[
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.mobileNumber ?? 'Mobile Number',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
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
                      : Text(AppLocalizations.of(context)?.verifyMobile ?? 'Verify Mobile'),
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
