import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// A stylish modal bottom sheet displayed after successful authentication
/// showcasing the 6 core trust pillars of BanjaraBio.
class PostAuthWelcomeSheet extends StatelessWidget {
  const PostAuthWelcomeSheet({super.key});

  /// Helper static method to display the sheet easily
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PostAuthWelcomeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle Indicator ──
              Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 2.h),

              // ── Celebration Header ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      const Color(0xFFE91E63).withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '🌸',
                        style: TextStyle(fontSize: AppTypography.displayLarge),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Welcome to BanjaraBio!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTypography.extraBold,
                        color: theme.colorScheme.primary,
                        fontSize: AppTypography.headingLarge,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Your trusted, 100% free & verified Banjara Samaj matrimonial platform.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTypography.bodyMedium,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),

              // ── 6 Trust Pillars Grid ──
              Text(
                'WHY OUR COMMUNITY TRUSTS US',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: AppTypography.bold,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  letterSpacing: 1.1,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
              SizedBox(height: 1.5.h),

              Row(
                children: [
                  Expanded(
                    child: _buildPillarCard(
                      theme: theme,
                      icon: Icons.shield_rounded,
                      title: 'Secure Data',
                      subtitle: '100% Private',
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: _buildPillarCard(
                      theme: theme,
                      icon: Icons.flash_on_rounded,
                      title: '1-Click Join',
                      subtitle: 'Fast Sign In',
                      color: const Color(0xFFF57C00),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),

              Row(
                children: [
                  Expanded(
                    child: _buildPillarCard(
                      theme: theme,
                      icon: Icons.thumb_up_alt_rounded,
                      title: 'Simple UX',
                      subtitle: 'Easiest To Use',
                      color: const Color(0xFF8E24AA),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: _buildPillarCard(
                      theme: theme,
                      icon: Icons.favorite_rounded,
                      title: 'Banjara Samaj',
                      subtitle: 'Trusted Family',
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),

              Row(
                children: [
                  Expanded(
                    child: _buildPillarCard(
                      theme: theme,
                      icon: Icons.card_giftcard_rounded,
                      title: '100% Free',
                      subtitle: 'Zero Charge',
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: _buildPillarCard(
                      theme: theme,
                      icon: Icons.verified_user_rounded,
                      title: 'Verified',
                      subtitle: 'Authentic Profiles',
                      color: const Color(0xFF00897B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // ── Action Button ──
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Explore Matches Now 🎉',
                        style: TextStyle(
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTypography.bold,
                    fontSize: AppTypography.bodyMedium,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: AppTypography.medium,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
