import 'package:banjarabio/core/constants/app_typography.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💎 Global-Standard 4-State Adaptive Floating Action Dock for Matrimonial Match Profile.
/// 
/// 🏆 4 Dynamic Relationship States:
/// 1. Unmatched: [ 🔖 Save ] + [ 💖 CONNECT (Hero) ] + [ 💌 INTRO NOTE (if DM credit/VIP) ] + [ 📤 Share ]
/// 2. Interest Sent (Pending): [ 🔖 Save ] + [ ⏳ INTEREST SENT ] + [ 📤 Share ]
/// 3. Mutual Match (Accepted!): [ 🔖 Save ] + [ 💬 START CHAT (Hero Indigo) ] + [ 📤 Share ]
/// 4. Received Interest: [ ❌ DECLINE ] + [ 💖 ACCEPT & CONNECT (Hero) ]
class ActionButtonsWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final Function(Map<String, dynamic>) onShare;
  final Function(Map<String, dynamic>) onInterest;
  final Function(Map<String, dynamic>) onMessage;
  final Function(Map<String, dynamic>) onBookmark;
  final Function(Map<String, dynamic>)? onDirectNote;
  final Function(Map<String, dynamic>)? onAcceptInterest;
  final Function(Map<String, dynamic>)? onDeclineInterest;

  const ActionButtonsWidget({
    super.key,
    required this.profileData,
    required this.onShare,
    required this.onInterest,
    required this.onMessage,
    required this.onBookmark,
    this.onDirectNote,
    this.onAcceptInterest,
    this.onDeclineInterest,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget>
    with SingleTickerProviderStateMixin {
  bool _isBookmarked = false;
  int _bonusDmCredits = 0;
  bool _isVip = false;

  late final AnimationController _heartPulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  late final Animation<double> _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.16).animate(
    CurvedAnimation(
      parent: _heartPulseController,
      curve: Curves.easeInOutCubic,
    ),
  );

  late final Animation<double> _glowAnimation = Tween<double>(begin: 0.35, end: 0.75).animate(
    CurvedAnimation(
      parent: _heartPulseController,
      curve: Curves.easeInOutSine,
    ),
  );

  bool get _isProfileTourActive {
    final cache = LocalCacheService();
    return cache.isGuestMode() &&
        !cache.isTourStageCompleted(TourStage.profileDetail.name);
  }

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.profileData['isBookmarked'] == true;
    _checkDmCredits();
  }

  Future<void> _checkDmCredits() async {
    final usageRes = await UsageRepository().getRemainingBonusMessages();
    final planRes = await SubscriptionRepository().getPlanType();

    if (mounted) {
      setState(() {
        _bonusDmCredits = usageRes.fold(onSuccess: (val) => val, onFailure: (_) => 0);
        final plan = planRes.fold(onSuccess: (p) => p.name.toLowerCase(), onFailure: (_) => '');
        _isVip = plan.contains('vip') || plan.contains('matchmaker');
      });
    }
  }

  @override
  void didUpdateWidget(ActionButtonsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileData['isBookmarked'] !=
        widget.profileData['isBookmarked']) {
      _isBookmarked = widget.profileData['isBookmarked'] == true;
    }
  }

  @override
  void dispose() {
    _heartPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isMatched = widget.profileData['isMatched'] == true ||
        widget.profileData['isMutual'] == true;
    final isPendingSent = widget.profileData['interestSent'] == true ||
        widget.profileData['isInterestSent'] == true ||
        widget.profileData['status'] == 'pending_sent' ||
        widget.profileData['status'] == 'pending';
    final isPendingReceived = widget.profileData['hasIncomingInterest'] == true ||
        widget.profileData['isIncomingInterest'] == true ||
        widget.profileData['status'] == 'pending_received';

    final hasDmAccess = _isVip || _bonusDmCredits > 0 || widget.onDirectNote != null;

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(3.5.w, 0, 3.5.w, 1.2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.65)
                  : AppColors.slate500.withValues(alpha: 0.22),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            if (isDark)
              BoxShadow(
                color: AppColors.categoryPersonal.withValues(alpha: AppColors.opacity8),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 7.6.h,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.slate900.withValues(alpha: AppColors.opacity85)
                    : Colors.white.withValues(alpha: AppColors.opacity90),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: AppColors.opacity85),
                  width: 1.2,
                ),
              ),
              child: _buildAdaptiveDockContent(
                context: context,
                isDark: isDark,
                theme: theme,
                isMatched: isMatched,
                isPendingSent: isPendingSent,
                isPendingReceived: isPendingReceived,
                hasDmAccess: hasDmAccess,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔄 Dynamic Dock Content based on 4 Relationship States
  Widget _buildAdaptiveDockContent({
    required BuildContext context,
    required bool isDark,
    required ThemeData theme,
    required bool isMatched,
    required bool isPendingSent,
    required bool isPendingReceived,
    required bool hasDmAccess,
  }) {
    // ══════════════════════════════════════════════════════════════════════
    // STATE 4: THEY SENT YOU INTEREST (Incoming Request: Decline vs Accept)
    // ══════════════════════════════════════════════════════════════════════
    if (isPendingReceived) {
      return Row(
        children: [
          Expanded(
            flex: 14,
            child: _buildDeclineButton(context, isDark, theme),
          ),
          SizedBox(width: 2.w),
          Expanded(
            flex: 28,
            child: _buildAcceptButton(context, isDark, theme),
          ),
        ],
      );
    }

    // ══════════════════════════════════════════════════════════════════════
    // STATE 3: MUTUAL MATCH (Accepted! -> Start Chatting Hero)
    // ══════════════════════════════════════════════════════════════════════
    if (isMatched) {
      return Row(
        children: [
          Expanded(
            flex: 11,
            child: _buildSaveButton(context, isDark, theme),
          ),
          SizedBox(width: 1.8.w),
          Expanded(
            flex: 26,
            child: _buildChatHeroButton(context, isDark, theme),
          ),
          SizedBox(width: 1.8.w),
          Expanded(
            flex: 11,
            child: _buildShareButton(context, isDark, theme),
          ),
        ],
      );
    }

    // ══════════════════════════════════════════════════════════════════════
    // STATE 2: INTEREST SENT / PENDING
    // ══════════════════════════════════════════════════════════════════════
    if (isPendingSent) {
      return Row(
        children: [
          Expanded(
            flex: 11,
            child: _buildSaveButton(context, isDark, theme),
          ),
          SizedBox(width: 1.8.w),
          Expanded(
            flex: 26,
            child: _buildInterestSentButton(context, isDark, theme),
          ),
          SizedBox(width: 1.8.w),
          Expanded(
            flex: 11,
            child: _buildShareButton(context, isDark, theme),
          ),
        ],
      );
    }

    // ══════════════════════════════════════════════════════════════════════
    // STATE 1: UNMATCHED (Default - 1 Free Message to all users + VIP / Streak)
    // ══════════════════════════════════════════════════════════════════════
    return Row(
      children: [
        Expanded(
          flex: 10,
          child: _buildSaveButton(context, isDark, theme),
        ),
        SizedBox(width: 1.5.w),
        Expanded(
          flex: 20,
          child: _buildConnectHeroButton(context, isDark),
        ),
        SizedBox(width: 1.5.w),
        Expanded(
          flex: 13,
          child: _buildIntroNoteButton(context, isDark, theme),
        ),
        SizedBox(width: 1.5.w),
        Expanded(
          flex: 10,
          child: _buildShareButton(context, isDark, theme),
        ),
      ],
    );
  }

  /// 🔖 1. Shortlist / Save Button with smooth toggle animation
  Widget _buildSaveButton(
      BuildContext context, bool isDark, ThemeData theme) {
    return TactilePressable(
      pressedScale: 0.92,
      onTap: () {
        if (kDebugMode) {
          AppLogger.debug('ActionButtonsWidget',
              '[BOOKMARK] User tapped save on bottom bar');
        }
        HapticFeedback.lightImpact();
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
        widget.onBookmark(widget.profileData);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        key: _isProfileTourActive ? TourKeys.bookmarkButtonKey : null,
        decoration: BoxDecoration(
          gradient: _isBookmarked
              ? const LinearGradient(
                  colors: [AppColors.categoryLocationDark, AppColors.categoryLocation],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.slate800.withValues(alpha: AppColors.opacity90),
                          AppColors.slate900.withValues(alpha: AppColors.opacity90)
                        ]
                      : [
                          AppColors.slate50,
                          AppColors.slate100
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isBookmarked
                ? AppColors.green400.withValues(alpha: AppColors.opacity60)
                : (isDark
                    ? Colors.white.withValues(alpha: AppColors.opacity12)
                    : AppColors.slate200),
          ),
          boxShadow: _isBookmarked
              ? [
                  BoxShadow(
                    color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Column(
            key: ValueKey<bool>(_isBookmarked),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isBookmarked
                    ? Icons.bookmark_added_rounded
                    : Icons.bookmark_border_rounded,
                color: _isBookmarked
                    ? Colors.white
                    : (isDark
                        ? AppColors.slate400
                        : AppColors.slate600),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                _isBookmarked
                    ? (AppLocalizations.of(context)?.saved ?? 'SAVED')
                    : (AppLocalizations.of(context)?.save ?? 'SAVE'),
                style: TextStyle(
                  color: _isBookmarked
                      ? Colors.white
                      : (isDark
                          ? AppColors.slate300
                          : AppColors.slate700),
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.labelTiny,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 💖 2. Connect / Send Interest (Hero Primary Action with Pulsing Aura)
  Widget _buildConnectHeroButton(
      BuildContext context, bool isDark) {
    return TactilePressable(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onInterest(widget.profileData);
      },
      child: AnimatedBuilder(
        animation: _heartPulseController,
        builder: (context, child) {
          return Container(
            key: _isProfileTourActive ? TourKeys.interestButtonKey : null,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.crimsonBlush, // Electric Sunset Rose
                  AppColors.coralRed, // Vibrant Coral
                  AppColors.coralRed, // Rose Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: AppColors.opacity50),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.crimsonBlush
                      .withValues(alpha: _glowAnimation.value),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _heartScaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: AppColors.opacity25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)?.interest ?? 'CONNECT',
                    style:                     AppTypography.bodyStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.bodySmall,
                      letterSpacing: 0.6,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ⏳ State 2: Interest Sent / Pending Button
  Widget _buildInterestSentButton(
      BuildContext context, bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.slate700.withValues(alpha: AppColors.opacity80),
                  AppColors.slate800.withValues(alpha: AppColors.opacity80),
                ]
              : [
                  AppColors.slate100,
                  AppColors.slate200,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity50),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.categoryAstro,
              size: 14,
            ),
          ),
          SizedBox(width: 1.5.w),
          Text(
            AppLocalizations.of(context)?.interestSent ?? 'INTEREST SENT',
            style: TextStyle(
              color: isDark ? AppColors.goldLemonLight : AppColors.amberDark,
              fontWeight: AppTypography.black,
              fontSize: AppTypography.labelSmall,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 💬 State 3: Start Chatting Hero Button (Mutual Match)
  Widget _buildChatHeroButton(
      BuildContext context, bool isDark, ThemeData theme) {
    return TactilePressable(
      pressedScale: 0.95,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onMessage(widget.profileData);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.categorySecurity, // Royal Indigo
              AppColors.categorySecurityDark, // Deep Violet
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.indigoSoft.withValues(alpha: AppColors.opacity70),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.categorySecurity.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: AppColors.opacity25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppLocalizations.of(context)?.startChatting ?? 'START CHATTING 💬',
                style:                 AppTypography.bodyStyle(
                  color: Colors.white,
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.bodySmall,
                  letterSpacing: 0.6,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💌 Intro Note Button (Available for 7-Day Streak DM Credit / VIP)
  Widget _buildIntroNoteButton(
      BuildContext context, bool isDark, ThemeData theme) {
    return TactilePressable(
      pressedScale: 0.92,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onDirectNote?.call(widget.profileData);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.categoryAstro, // Warm Amber
              AppColors.categoryAstroDark, // Gold Orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.goldLemonLight.withValues(alpha: AppColors.opacity80),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isVip
                  ? Icons.workspace_premium_rounded
                  : _bonusDmCredits > 0
                      ? Icons.local_fire_department_rounded
                      : Icons.mark_email_unread_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(height: 2),
            Text(
              _isVip
                  ? (AppLocalizations.of(context)?.vipNote ?? 'VIP NOTE 👑')
                  : _bonusDmCredits > 0
                      ? 'NOTE (🔥$_bonusDmCredits)'
                      : (AppLocalizations.of(context)?.oneFreeNote ?? '1 FREE 💌'),
              style:               AppTypography.bodyStyle(
                color: Colors.white,
                fontWeight: AppTypography.black,
                fontSize: AppTypography.labelTiny,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// ❌ State 4: Decline Incoming Interest Button
  Widget _buildDeclineButton(
      BuildContext context, bool isDark, ThemeData theme) {
    return TactilePressable(
      pressedScale: 0.92,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onDeclineInterest?.call(widget.profileData);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.trustLow.withValues(alpha: AppColors.opacity50),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.close_rounded,
              color: AppColors.trustLow,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              AppLocalizations.of(context)?.decline ?? 'DECLINE',
              style: TextStyle(
                color: AppColors.trustLow,
                fontWeight: AppTypography.black,
                fontSize: AppTypography.labelSmall,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💖 State 4: Accept & Connect Button
  Widget _buildAcceptButton(
      BuildContext context, bool isDark, ThemeData theme) {
    return TactilePressable(
      pressedScale: 0.95,
      onTap: () {
        HapticFeedback.heavyImpact();
        widget.onAcceptInterest?.call(widget.profileData);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.categoryLocation, // Emerald
              AppColors.categoryLocationDark, // Deep Mint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.cyanAccent.withValues(alpha: AppColors.opacity70),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: AppColors.opacity25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              AppLocalizations.of(context)?.acceptAndConnect ?? 'ACCEPT & CONNECT 💖',
              style:               AppTypography.bodyStyle(
                color: Colors.white,
                fontWeight: AppTypography.black,
                fontSize: AppTypography.labelSmall,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📤 4. Share Biodata Button with Modern Cyan Tint
  Widget _buildShareButton(
      BuildContext context, bool isDark, ThemeData theme) {
    return TactilePressable(
      pressedScale: 0.92,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onShare(widget.profileData);
      },
      child: Container(
        key: _isProfileTourActive ? TourKeys.shareButtonKey : null,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.slate900.withValues(alpha: 0.95),
                    AppColors.slate800.withValues(alpha: 0.95),
                  ]
                : [
                    AppColors.infoLight,
                    AppColors.infoLight,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.skyBlue.withValues(alpha: AppColors.opacity35)
                : AppColors.infoDark,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.skyBlue.withValues(alpha: AppColors.opacity12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share_rounded,
              color: isDark
                  ? AppColors.skyBlueBright
                  : AppColors.sapphireBlue,
              size: 19,
            ),
            const SizedBox(height: 2),
            Text(
              AppLocalizations.of(context)?.share ?? 'SHARE',
              style: TextStyle(
                color: isDark
                    ? AppColors.infoDark
                    : AppColors.oceanBlueDark,
                fontWeight: AppTypography.black,
                fontSize: AppTypography.labelTiny,
                letterSpacing: 0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

