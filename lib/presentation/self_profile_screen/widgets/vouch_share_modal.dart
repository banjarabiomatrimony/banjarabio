import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/share_service.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Interactive, animated bottom sheet displaying a live preview of the
/// Vouch Invitation card with dynamic share triggers (WhatsApp, Copy Link, Native Share).
class VouchShareModal extends StatefulWidget {
  final ProfileModel profile;

  const VouchShareModal({
    super.key,
    required this.profile,
  });

  /// Static helper to display the modal
  static Future<void> show(BuildContext context, ProfileModel profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VouchShareModal(profile: profile),
    );
  }

  @override
  State<VouchShareModal> createState() => _VouchShareModalState();
}

class _VouchShareModalState extends State<VouchShareModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isGeneratingImage = false;

  String get _inviteText {
    final deepLink =
        'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=vouch_${widget.profile.id}';
    final gotraStr = (widget.profile.gotra != null && widget.profile.gotra!.isNotEmpty)
        ? ' • गोत्र: ${widget.profile.gotra}'
        : '';
    return 'जय सेवालाल! 🚩\n\n'
        'कृपया BanjaraBio (बंजाराबायो) ॲपवर माझ्या बायोडाटाला खात्री (Vouch) देऊन "समाज विश्वासार्ह" बॅज मिळवण्यास मदत करा! 🙏💍\n\n'
        '👤 नाव: ${widget.profile.fullName}\n'
        '🎂 वय: ${widget.profile.age} वर्षे $gotraStr\n'
        '📍 ठिकाण: ${widget.profile.locationExcludingVillage}\n\n'
        '📲 *खात्री (Vouch) देण्यासाठी खालील लिंकवर क्लिक करा:*\n'
        '$deepLink\n\n'
        '✨ (BanjaraBio Matrimony — सुरक्षित बंजारा समाज विवाह ॲप)';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleWhatsAppShare() async {
    HapticFeedback.mediumImpact();
    setState(() => _isGeneratingImage = true);

    try {
      await ShareService().shareVouchInvitation(
        context,
        widget.profile,
        customCaption: _inviteText,
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingImage = false);
      }
    }
  }

  void _handleCopyLink() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: _inviteText));
    AppFeedback.showSuccess(
      context,
      '📋 निमंत्रण मेसेज आणि लिंक कॉपी झाली!',
    );
  }

  Future<void> _handleMoreShare() async {
    HapticFeedback.lightImpact();
    setState(() => _isGeneratingImage = true);
    try {
      await ShareService().shareVouchInvitation(
        context,
        widget.profile,
        customCaption: _inviteText,
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: 90.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.crimsonBlack : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.opacity30),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          SizedBox(height: 1.5.h),
          Center(
            child: Container(
              width: 12.w,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity30),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '॥ जय सेवालाल ॥',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodySmall,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Invite Relatives to Vouch',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.headingSmall,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity50),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.5.h),

          // Scrollable Preview Area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                children: [
                  // ── Animated Card Preview ──────────────────────────────
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.crimsonBlack,
                              AppColors.crimsonBlack,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.gold.withValues(
                              alpha: 0.45 * _pulseAnimation.value,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(
                                alpha: 0.18 * _pulseAnimation.value,
                              ),
                              blurRadius: 16 * _pulseAnimation.value,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Top Row: Logo & Blessing
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/logo/BanjaraBio.webp',
                                      height: 28,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const SizedBox.shrink(),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'BANJARABIO',
                                      style:                                       AppTypography.bodyStyle(
                                        color: Colors.white,
                                        fontWeight: AppTypography.black,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.5.w, vertical: 0.4.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.gold
                                          .withValues(alpha: AppColors.opacity50),
                                    ),
                                  ),
                                  child: Text(
                                    'समाज खात्री',
                                    style: TextStyle(
                                      color: AppColors.categoryVip,
                                      fontWeight: AppTypography.extraBold,
                                      fontSize: AppTypography.labelSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.8.h),

                            // Profile Spotlight Row
                            Row(
                              children: [
                                // Circular Photo
                                Container(
                                  width: 18.w,
                                  height: 18.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.categoryVip,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: widget.profile.photos.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: widget
                                                .profile.photos.first.publicUrl,
                                            fit: BoxFit.cover,
                                            cacheManager: PersistentCacheManager
                                                .instance,
                                            errorWidget: (context, error, stackTrace) =>
                                                _buildFallbackAvatar(),
                                          )
                                        : _buildFallbackAvatar(),
                                  ),
                                ),
                                SizedBox(width: 3.5.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.profile.fullName}, ${widget.profile.age}',
                                        style:                                         AppTypography.displayStyle(
                                          color: Colors.white,
                                          fontSize: AppTypography.headingMedium,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 0.4.h),
                                      Text(
                                        widget.profile.education.isNotEmpty
                                            ? widget.profile.education
                                            : widget.profile.locationExcludingVillage,
                                        style:                                         AppTypography.bodyStyle(
                                          color: Colors.white70,
                                          fontWeight: AppTypography.semiBold,
                                          fontSize: AppTypography.bodySmall,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 0.6.h),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.verified_user_rounded,
                                            color: AppColors.green500,
                                            size: 14,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            '${widget.profile.vouchCount} / 5 Vouches Received',
                                            style: TextStyle(
                                              color: AppColors.categoryVip,
                                              fontWeight: AppTypography.extraBold,
                                              fontSize: AppTypography.labelSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.8.h),

                            // Mini Vouch Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (widget.profile.vouchCount / 5)
                                    .clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.green500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2.h),

                  // Motivation Tip
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: AppTypography.headingMedium)),
                        SizedBox(width: 2.5.w),
                        Expanded(
                          child: Text(
                            'Share on WhatsApp Status or send to relatives. Each verified vouch increases match responses by 3x!',
                            style:                             AppTypography.bodyStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: AppTypography.semiBold,
                              fontSize: AppTypography.labelMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),

          // ── Action Buttons ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 3.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.crimsonBlack : Colors.grey[50],
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withValues(alpha: AppColors.opacity20),
                ),
              ),
            ),
            child: Column(
              children: [
                // 1. Primary Action: WhatsApp Share
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isGeneratingImage ? null : _handleWhatsAppShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.whatsapp.withValues(alpha: AppColors.opacity40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isGeneratingImage
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Creating High-Res Card...',
                                style:                                 AppTypography.headingStyle(
                                  fontSize: AppTypography.headingSmall,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(FontAwesomeIcons.whatsapp, size: 20),
                              SizedBox(width: 2.5.w),
                              Text(
                                'Share Image on WhatsApp',
                                style:                                 AppTypography.displayStyle(
                                  fontSize: AppTypography.headingSmall,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 1.2.h),

                // 2. Secondary Row: Copy Link & More Options
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleCopyLink,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text(
                          'Copy Link',
                          style: TextStyle(fontWeight: AppTypography.extraBold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isGeneratingImage ? null : _handleMoreShare,
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text(
                          'More Apps',
                          style: TextStyle(fontWeight: AppTypography.extraBold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: AppColors.burgundy,
      child: Center(
        child: Text(
          widget.profile.fullName.isNotEmpty
              ? widget.profile.fullName[0].toUpperCase()
              : 'B',
          style: TextStyle(
            color: AppColors.categoryVip,
            fontSize: AppTypography.displayMedium,
            fontWeight: AppTypography.bold,
          ),
        ),
      ),
    );
  }
}
