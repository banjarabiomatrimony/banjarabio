import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

class InstagramFollowInterstitial extends StatelessWidget {
  const InstagramFollowInterstitial({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: AppColors.opacity85),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.categorySecurityDark.withValues(alpha: AppColors.opacity60), // Instagram Blue
                  AppColors.categorySecurityDark.withValues(alpha: AppColors.opacity60), // Instagram Purple
                  AppColors.instagramPurple.withValues(alpha: AppColors.opacity60), // Instagram Violet
                  AppColors.categoryPersonalDark.withValues(alpha: AppColors.opacity60), // Instagram Magenta
                  AppColors.roseBlushAccent.withValues(alpha: AppColors.opacity60), // Instagram Red
                  AppColors.deepOrange600.withValues(alpha: AppColors.opacity60), // Instagram Orange
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Content Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  padding: EdgeInsets.all(4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppColors.opacity30),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(2.h),
                        decoration: const BoxDecoration(
                          color: AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/instagram_icon.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      
                      // Title
                      Text(
                        AppLocalizations.of(context)?.increaseBiodataScore ?? 'Increase Biodata Score!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.headingLarge,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.5.h),
                      
                      // Subtitle
                      Text(
                        AppLocalizations.of(context)?.followUsOnInstagramBonus ?? 'Follow us on Instagram to get a 5% biodata completion bonus and stay updated with the latest matches.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      
                      // Follow Button
                      SizedBox(
                        width: double.infinity,
                        height: 7.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse('https://www.instagram.com/banjarabio.matrimony/');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                              // Mark as followed to grant rewards
                              await ProfileRepository().followInstagram();
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.roseBlushAccent, // Instagram Pink
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.followAndGetFivePercent ?? 'Follow & Get +5%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.headingSmall,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      
                      // Skip Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)?.maybeLater ?? 'Maybe Later',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey[400],
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Footer
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    AppLocalizations.of(context)?.joinOurCommunity ?? 'Join our 10K+ community!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Close Icon Top Right
          Positioned(
            top: 6.h,
            right: 6.w,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
