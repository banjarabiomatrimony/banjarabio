import 'dart:async';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/widgets/trust_score_badge.dart';

import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/profile_display_policy.dart';

/// Daily Match widget that shows curated daily profiles
/// with a premium reveal animation and countdown timer.
class DailyMatchWidget extends StatefulWidget {
  final List<ProfileModel> dailyProfiles;
  final void Function(ProfileModel profile) onTap;
  final void Function(ProfileModel profile) onInterest;
  final void Function(ProfileModel profile) onBookmark;
  final void Function(ProfileModel profile) onShare;

  const DailyMatchWidget({
    super.key,
    required this.dailyProfiles,
    required this.onTap,
    required this.onInterest,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  State<DailyMatchWidget> createState() => _DailyMatchWidgetState();
}

class _DailyMatchWidgetState extends State<DailyMatchWidget>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _pulseController;
  late Animation<double> _revealAnim;
  late Animation<double> _pulseAnim;

  int _currentMatchIndex = 0;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _revealAnim = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutBack,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _revealController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _revealMatch() {
    HapticFeedback.heavyImpact();
    _revealController.forward();
    setState(() => _isRevealed = true);
  }

  void _nextMatch() {
    if (_currentMatchIndex < widget.dailyProfiles.length - 1) {
      HapticFeedback.lightImpact();
      _revealController.reset();
      setState(() {
        _currentMatchIndex++;
        _isRevealed = false;
      });
    }
  }

  void _previousMatch() {
    if (_currentMatchIndex > 0) {
      HapticFeedback.lightImpact();
      _revealController.reset();
      setState(() {
        _currentMatchIndex--;
        _isRevealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.dailyProfiles.isEmpty) {
      return _buildEmptyState(theme);
    }

    final profile = widget.dailyProfiles[_currentMatchIndex];

    return Column(
      children: [
        // Countdown header
        _buildCountdownHeader(theme),

        // Match navigation dots
        _buildNavigationDots(theme),

        SizedBox(height: 1.h),

        // Main match card
        Expanded(
          child: _isRevealed
              ? _buildRevealedCard(profile, theme)
              : _buildBlurredCard(profile, theme),
        ),

        // Action area
        SizedBox(height: 1.5.h),
        if (_isRevealed) _buildActionButtons(profile, theme),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _buildCountdownHeader(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.hotPink, AppColors.sunsetBlush],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(255, 65, 108, 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 16.sp),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.yourDailyMatches ??
                      'Your Daily Matches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)?.curatedProfilesJustForYou(
                          widget.dailyProfiles.length) ??
                      '${widget.dailyProfiles.length} curated profiles just for you',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: AppColors.opacity80),
                    fontSize: AppTypography.labelMedium,
                  ),
                ),
              ],
            ),
          ),
          // 🧬 PRO SCALE: Isolated Countdown Widget
          // Using a separate stateful child prevents the entire 3D animated card
          // from rebuilding 60 times a minute.
          const _CountdownTimerRow(),
        ],
      ),
    );
  }
  Widget _buildNavigationDots(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          onPressed: _currentMatchIndex > 0 ? _previousMatch : null,
          icon: Icon(
            Icons.chevron_left_rounded,
            color: _currentMatchIndex > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity30),
          ),
          iconSize: 20.sp,
        ),
        // Dots
        ...List.generate(widget.dailyProfiles.length, (i) {
          final isActive = i == _currentMatchIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            width: isActive ? 5.w : 2.w,
            height: 0.8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: isActive ? AppGradients.romance : null,
              color: isActive
                  ? null
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity20),
            ),
          );
        }),
        // Next button
        IconButton(
          onPressed: _currentMatchIndex < widget.dailyProfiles.length - 1
              ? _nextMatch
              : null,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: _currentMatchIndex < widget.dailyProfiles.length - 1
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity30),
          ),
          iconSize: 20.sp,
        ),
      ],
    );
  }


  Widget _buildBlurredCard(ProfileModel profile, ThemeData theme) {
    // 🧬 PERFORMANCE: Minimal mapping for blurred card
    final displayMap = profile.toDisplayMap();
    final photos = (displayMap['photos'] as List<dynamic>?) ?? [];
    final mainPhoto = photos.isNotEmpty
        ? (photos[0] as Map<String, dynamic>)['url']?.toString() ?? ''
        : '';

    return GestureDetector(
      onTap: _revealMatch,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnim.value,
              child: child,
            );
          },
          child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(255, 65, 108, 0.25),
                blurRadius: 8,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Blurred photo
                ImageFiltered(
                  imageFilter:
                      ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: CustomImageWidget(
                    imageUrl: mainPhoto,
                    fit: BoxFit.cover,
                  ),
                ),

                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: AppColors.opacity20),
                        Colors.black.withValues(alpha: AppColors.opacity60),
                      ],
                    ),
                  ),
                ),

                // Reveal prompt
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lock icon with gradient ring
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.romance,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(255, 65, 108, 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(AppLocalizations.of(context)?.tapToReveal ?? '✨ Tap to Reveal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.extraBold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        AppLocalizations.of(context)?.matchNOfTotal((_currentMatchIndex + 1).toString(), widget.dailyProfiles.length.toString()) ?? 'Match ${_currentMatchIndex + 1} of ${widget.dailyProfiles.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: AppColors.opacity70),
                          fontSize: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildRevealedCard(ProfileModel profile, ThemeData theme) {
    // 🧬 PERFORMANCE: Lazy mapping for revealed card
    final displayMap = profile.toDisplayMap();
    final photos = (displayMap['photos'] as List<dynamic>?) ?? [];
    
    final mainPhoto = photos.isNotEmpty
        ? (photos[0] as Map<String, dynamic>)['url']?.toString() ?? ''
        : '';
        
    final name = ProfileDisplayPolicy.getDisplayName(profile);
    final age = profile.age.toString();
    final location = profile.locationExcludingVillage;
    final education = ProfileDisplayPolicy.getFormattedEducation(profile);
    final profession = profile.profession;
    final trustScore = ProfileDisplayPolicy.getDynamicTrustScore(profile);
    final isVerified = profile.isVerified;

    return AnimatedBuilder(
      animation: _revealAnim,
      builder: (context, child) {
        final value = _revealAnim.value;
        // 3D Flip & Scale rotation
        final rotation = (1 - value) * math.pi / 4; // subtle 45 deg start
        final scale = 0.8 + (0.2 * value);
        
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(rotation)
          ..rotateX(-rotation / 2);

        return Transform(
          transform: matrix,
          alignment: Alignment.center,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => widget.onTap(profile),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2), // Replace theme dependency with literal if possible, but actually theme isn't const.
                blurRadius: 10,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full photo
                CustomImageWidget(
                  imageUrl: mainPhoto,
                  fit: BoxFit.cover,
                ),

                // Bottom gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: AppColors.opacity30),
                          Colors.black.withValues(alpha: AppColors.opacity85),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // "Daily Match" badge at top
                Positioned(
                  top: 2.h,
                  left: 4.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      gradient: AppGradients.romance,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(255, 65, 108, 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Colors.white, size: 11.sp),
                        SizedBox(width: 1.w),
                        Text(AppLocalizations.of(context)?.dailyMatch ?? 'Daily Match',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.labelMedium,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile info at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '$name${age.isNotEmpty ? ', $age' : ''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTypography.headingMedium,
                                  fontWeight: AppTypography.extraBold,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 10,
                                        color: Colors.black54),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              SizedBox(width: 2.w),
                              Icon(Icons.verified,
                                  color: Colors.blueAccent,
                                  size: 18.sp),
                            ],
                            SizedBox(width: 1.w),
                            TrustScoreBadge(
                                score: trustScore, size: 3.5.h),
                          ],
                        ),
                        SizedBox(height: 0.8.h),
                        if (location.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  color: Colors.white70, size: 13.sp),
                              SizedBox(width: 1.w),
                              Text(
                                location,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.medium,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 0.5.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 0.8.h,
                          children: [
                            if (profession.isNotEmpty)
                              _buildInfoTag(
                                  Icons.work_outline, profession),
                            if (education.isNotEmpty)
                              _buildInfoTag(
                                  Icons.school_outlined, education),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppColors.opacity15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: AppColors.opacity20), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 11.sp),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: AppColors.opacity90),
              fontSize: AppTypography.labelMedium,
              fontWeight: AppTypography.medium,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProfileModel profile, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionBtn(
            icon: Icons.close_rounded,
            label: AppLocalizations.of(context)?.skip ?? 'Skip',
            gradient: const LinearGradient(
              colors: [AppColors.neutral400, AppColors.neutral500],
            ),
            onTap: _nextMatch,
          ),
          _buildActionBtn(
            icon: Icons.bookmark_outline_rounded,
            label: AppLocalizations.of(context)?.save ?? 'Save',
            gradient: const LinearGradient(
              colors: [AppColors.orange400, AppColors.orangeDark900],
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onBookmark(profile);
            },
          ),
          _buildActionBtn(
            icon: Icons.share_outlined,
            label: AppLocalizations.of(context)?.share ?? 'Share',
            gradient: const LinearGradient(
              colors: [AppColors.skyBlueBright, AppColors.materialBlueDark],
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onShare(profile);
            },
          ),
          _buildActionBtn(
            icon: Icons.favorite_rounded,
            label: AppLocalizations.of(context)?.interest ?? 'Interest',
            gradient: AppGradients.romance,
            size: 7.h,
            onTap: () {
              HapticFeedback.heavyImpact();
              widget.onInterest(profile);
              // Move to next after interest
              Future.delayed(const Duration(milliseconds: 400), _nextMatch);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
    double? size,
  }) {
    final btnSize = size ?? 5.5.h;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: btnSize * 0.45),
          ),
        ),
        SizedBox(height: 0.4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: AppTypography.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              gradient: AppGradients.romance,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(255, 65, 108, 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 35.sp,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            AppLocalizations.of(context)?.noDailyMatchesYet ??
                'No Daily Matches Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            AppLocalizations.of(context)?.comeBackTomorrowFornnewCuratedMatches ??
                'Come back tomorrow for\nnew curated matches!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: 2.h),
          // 🧬 PRO SCALE: Isolated Countdown in Empty State
          const _CountdownTimerRow(showLabel: true),
        ],
      ),
    );
  }
}

class _CountdownTimerRow extends StatefulWidget {
  final bool showLabel;
  const _CountdownTimerRow({this.showLabel = false});

  @override
  State<_CountdownTimerRow> createState() => _CountdownTimerRowState();
}

class _CountdownTimerRowState extends State<_CountdownTimerRow> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    if (mounted) {
      setState(() {
        _timeRemaining = midnight.difference(now);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = _format(_timeRemaining);

    if (widget.showLabel) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined,
                color: theme.colorScheme.primary, size: 14.sp),
            SizedBox(width: 2.w),
            Text(
              AppLocalizations.of(context)?.nextRefreshTime(timeStr) ??
                  'Next refresh: $timeStr',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: AppTypography.bodySmall,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppColors.opacity20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: Colors.white, size: 11.sp),
          SizedBox(width: 1.w),
          Text(
            timeStr,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}


/// Helper to pick daily matches from a list
/// Selects up to [count] profiles using a seeded random based on today's date,
/// ensuring consistent results for the same day.
List<ProfileModel> pickDailyMatches(
    List<ProfileModel> allProfiles,
    {int count = 5}) {
  if (allProfiles.isEmpty) return [];
  final now = DateTime.now();
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final rng = math.Random(seed);

  final shuffled = List<ProfileModel>.from(allProfiles)..shuffle(rng);
  return shuffled.take(count).toList();
}
