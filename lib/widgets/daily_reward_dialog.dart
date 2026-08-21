import 'package:banjarabio/core/constants/app_typography.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/core/repositories/daily_reward_repository.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

class DailyRewardDialog extends StatefulWidget {
  final DailyRewardModel initialStatus;

  const DailyRewardDialog({super.key, required this.initialStatus});

  static Future<DailyRewardModel?> show(BuildContext context, DailyRewardModel status) {
    return showModalBottomSheet<DailyRewardModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (context) => DailyRewardDialog(initialStatus: status),
    );
  }

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog>
    with TickerProviderStateMixin {
  late DailyRewardModel _status;
  bool _isClaiming = false;
  bool _showCelebration = false;

  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  AnimationController? _confettiController;
  AnimationController? _entryController;
  Animation<double>? _entryAnimation;

  // ─── 7-Day Rewards Master Definition ───
  final List<Map<String, dynamic>> _rewardTiers = const [
    {
      'day': 1,
      'label': '+1 Profile View',
      'icon': Icons.visibility_rounded,
      'accent': Color(0xFF38BDF8),
    },
    {
      'day': 2,
      'label': '+1 Bookmark',
      'icon': Icons.bookmark_rounded,
      'accent': Color(0xFFA78BFA),
    },
    {
      'day': 3,
      'label': '+2 Profile Views',
      'icon': Icons.visibility_rounded,
      'accent': Color(0xFF34D399),
    },
    {
      'day': 4,
      'label': '+1 Bookmark',
      'icon': Icons.bookmark_rounded,
      'accent': Color(0xFFF472B6),
    },
    {
      'day': 5,
      'label': '+3 Profile Views',
      'icon': Icons.visibility_rounded,
      'accent': Color(0xFFFBBF24),
    },
    {
      'day': 6,
      'label': '+5 Profile Views',
      'icon': Icons.visibility_rounded,
      'accent': Color(0xFFFB923C),
    },
    {
      'day': 7,
      'label': '👑 +1 Free Direct Message & VIP Spotlight',
      'icon': Icons.chat_bubble_rounded,
      'isJackpot': true,
      'accent': Color(0xFFF59E0B),
    },
  ];

  void _initAnimations() {
    _pulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation ??= Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _confettiController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _entryController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    _entryAnimation ??= CurvedAnimation(
      parent: _entryController!,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _initAnimations();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _confettiController?.dispose();
    _entryController?.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_status.isClaimedToday || _isClaiming) return;

    setState(() => _isClaiming = true);
    HapticFeedback.mediumImpact();

    final res = await DailyRewardRepository().claimDailyReward();

    if (mounted) {
      if (res.isSuccess) {
        HapticFeedback.heavyImpact();
        setState(() {
          _status = res.data;
          _showCelebration = true;
        });

        _confettiController?.forward(from: 0.0);

        // Auto close after 2.8 seconds to let celebration animation play
        Future.delayed(const Duration(milliseconds: 2800), () {
          if (mounted) Navigator.of(context).pop(_status);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.errorMessage),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentStreak = _status.streakCount;
    final progressPercent = math.min(currentStreak / 7.0, 1.0);

    return Stack(
      children: [
        // ─── Modal Sheet Body ───
        FadeTransition(
          opacity: _entryAnimation ?? const AlwaysStoppedAnimation(1.0),
          child: Container(
          constraints: BoxConstraints(maxHeight: 88.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1528), const Color(0xFF13101E), const Color(0xFF0C0A14)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFFFF7ED), const Color(0xFFFEF3C7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.20 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 3.0.h),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 1.8.h),

                  // ─── Hero Header: Streak Flame & Title ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.local_fire_department_rounded,
                                color: Colors.white, size: 20),
                          ),
                          SizedBox(width: 2.5.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Streak Rewards',
                                style: TextStyle(
                                  fontSize: AppTypography.headingSmall,
                                  fontWeight: AppTypography.black,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                _status.isClaimedToday
                                    ? '🔥 $currentStreak Day Streak active!'
                                    : '🎁 Day $currentStreak reward is waiting!',
                                style: TextStyle(
                                  fontSize: AppTypography.labelSmall,
                                  fontWeight: AppTypography.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TactilePressable(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.5.h),

                  // ─── Streak Progress Bar ───
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.0.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141220) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Journey to Day 7 Mega Jackpot',
                              style: TextStyle(
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.bold,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                            Text(
                              '${(progressPercent * 100).toInt()}% Done',
                              style: TextStyle(
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.extraBold,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 7,
                            backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.0.h),

                  // ─── 7-Day Journey Grid (Days 1 to 6) ───
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final tier = _rewardTiers[index];
                      return _buildDayCard(tier, isDark, theme);
                    },
                  ),

                  SizedBox(height: 1.2.h),

                  // ─── Day 7 Mega Jackpot Banner Card ───
                  _buildDay7JackpotCard(_rewardTiers[6], isDark, theme),

                  SizedBox(height: 2.2.h),

                  // ─── Glowing Action Claim Button ───
                  TactilePressable(
                    onTap: _status.isClaimedToday ? null : _claimReward,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        gradient: _status.isClaimedToday
                            ? LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                    : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(20),
                        border: _status.isClaimedToday
                            ? null
                            : Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                        boxShadow: _status.isClaimedToday
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _isClaiming
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _status.isClaimedToday
                                        ? Icons.check_circle_rounded
                                        : Icons.redeem_rounded,
                                    color: _status.isClaimedToday
                                        ? (isDark ? Colors.white54 : Colors.black45)
                                        : Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _status.isClaimedToday
                                        ? 'Claimed for Today ✓'
                                        : 'Claim Day $currentStreak Reward 🎁',
                                    style: TextStyle(
                                      fontWeight: AppTypography.extraBold,
                                      fontSize: AppTypography.bodyMedium,
                                      color: _status.isClaimedToday
                                        ? (isDark ? Colors.white54 : Colors.black45)
                                        : Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 0.8.h),
                  Text(
                    'Daily rewards reset every night at 12:00 AM',
                    style: TextStyle(
                      fontSize: AppTypography.labelTiny,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

        // ─── Custom Celebration Confetti Layer ───
        if (_showCelebration && _confettiController != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController!,
                builder: (context, _) {
                  return CustomPaint(
                    painter: ConfettiParticlePainter(progress: _confettiController!.value),
                  );
                },
              ),
            ),
          ),

        // ─── Optional Lottie Fallback ───
        if (_showCelebration)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.network(
                'https://assets2.lottiefiles.com/packages/lf20_u4yrau.json',
                repeat: false,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Day 1 to 6 Milestone Card ───
  Widget _buildDayCard(Map<String, dynamic> tier, bool isDark, ThemeData theme) {
    final int day = tier['day'] as int;
    final String label = tier['label'] as String;
    final IconData icon = tier['icon'] as IconData;
    final Color accent = tier['accent'] as Color;

    final bool isClaimedToday = _status.isClaimedToday;
    final int streak = _status.streakCount;

    bool isCompleted = false;
    bool isToday = false;

    if (isClaimedToday) {
      if (day <= streak) isCompleted = true;
    } else {
      if (day < streak) isCompleted = true;
      if (day == streak) isToday = true;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation ?? const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        final scale = isToday ? (_pulseAnimation?.value ?? 1.0) : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              gradient: isToday
                  ? LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF382312), const Color(0xFF1E1528)]
                          : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : isCompleted
                      ? LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF0B2418), const Color(0xFF0F1E19)]
                              : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                        )
                      : LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF161424), const Color(0xFF100E1C)]
                              : [Colors.white, const Color(0xFFF8FAFC)],
                        ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday
                    ? const Color(0xFFF59E0B)
                    : isCompleted
                        ? const Color(0xFF10B981).withValues(alpha: 0.5)
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                width: isToday ? 1.8 : 1.0,
              ),
              boxShadow: isToday
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Day Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day $day',
                      style: TextStyle(
                        fontSize: AppTypography.labelTiny,
                        fontWeight: AppTypography.extraBold,
                        color: isToday
                            ? const Color(0xFFF59E0B)
                            : isCompleted
                                ? const Color(0xFF10B981)
                                : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                    if (isCompleted)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 12)
                    else if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: AppTypography.labelTiny,
                            fontWeight: AppTypography.black,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      Icon(Icons.lock_outline_rounded,
                          size: 11, color: isDark ? Colors.white30 : Colors.black26),
                  ],
                ),

                // Icon Center
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : isToday
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.18)
                            : accent.withValues(alpha: isDark ? 0.12 : 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : icon,
                    size: 18,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : isToday
                            ? const Color(0xFFF59E0B)
                            : accent,
                  ),
                ),

                // Label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.labelTiny,
                    fontWeight: AppTypography.bold,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Day 7 Mega Jackpot Card ───
  Widget _buildDay7JackpotCard(Map<String, dynamic> tier, bool isDark, ThemeData theme) {
    final String label = tier['label'] as String;
    final bool isClaimedToday = _status.isClaimedToday;
    final int streak = _status.streakCount;

    final bool isCompleted = isClaimedToday && streak >= 7;
    final bool isToday = !isClaimedToday && streak == 7;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        gradient: isToday
            ? const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : isCompleted
                ? LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0B2418), const Color(0xFF0F1E19)]
                        : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                  )
                : LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF281C0F), const Color(0xFF1A1424)]
                        : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                  ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: isToday ? 0.9 : 0.5),
          width: isToday ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: isToday ? 0.35 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Crown Icon Emblem
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: isToday
                  ? const LinearGradient(colors: [Colors.white, Color(0xFFFDE68A)])
                  : const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.military_tech_rounded,
              color: isToday ? const Color(0xFFB45309) : Colors.white,
              size: 22,
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Day 7 MEGA JACKPOT',
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.black,
                        color: isToday
                            ? Colors.white
                            : (isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isToday ? Colors.white24 : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'VIP PERK',
                        style: TextStyle(
                          fontSize: AppTypography.labelTiny,
                          fontWeight: AppTypography.black,
                          color: isToday ? Colors.white : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.bold,
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.92)
                        : (isDark ? Colors.white70 : const Color(0xFF78350F)),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
          else if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'CLAIM',
                style: TextStyle(
                  color: const Color(0xFFB45309),
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.labelTiny,
                ),
              ),
            )
          else
            Icon(Icons.lock_outline_rounded,
                size: 16, color: isDark ? Colors.white38 : Colors.black38),
        ],
      ),
    );
  }
}

// ─── Custom Flutter Canvas Confetti Particle System ───
class ConfettiParticlePainter extends CustomPainter {
  final double progress;
  static final List<_Particle> _particles = List.generate(45, (i) => _Particle(i));

  ConfettiParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    for (final p in _particles) {
      final t = (progress - p.delay).clamp(0.0, 1.0) / (1.0 - p.delay);
      if (t <= 0) continue;

      final currentX = (size.width / 2) + (p.vx * t * size.width * 0.45);
      final currentY = (size.height * 0.6) - (p.vy * t * size.height * 0.5) + (300 * t * t);
      final alpha = ((1.0 - t) * 255).toInt().clamp(0, 255);

      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotation * t);

      if (p.isStar) {
        _drawStar(canvas, 0, 0, p.size * (1 - t * 0.3), paint);
      } else {
        canvas.drawCircle(Offset.zero, p.size * (1 - t * 0.3), paint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final double outerAngle = -math.pi / 2 + (i * 4 * math.pi / 5);
      final double x = cx + radius * math.cos(outerAngle);
      final double y = cy + radius * math.sin(outerAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ConfettiParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  late double vx;
  late double vy;
  late double size;
  late Color color;
  late double rotation;
  late double delay;
  late bool isStar;

  static final List<Color> _palette = [
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFF38BDF8),
    const Color(0xFFF472B6),
    const Color(0xFFFBBF24),
    const Color(0xFFA78BFA),
    const Color(0xFFBE123C),
  ];

  _Particle(int index) {
    final rand = math.Random(index * 7919);
    final angle = rand.nextDouble() * 2 * math.pi;
    final speed = 0.4 + (rand.nextDouble() * 0.6);

    vx = math.cos(angle) * speed;
    vy = (math.sin(angle).abs() * 0.8 + 0.4) * speed;
    size = 3.5 + (rand.nextDouble() * 5);
    color = _palette[rand.nextInt(_palette.length)];
    rotation = (rand.nextDouble() - 0.5) * 10;
    delay = rand.nextDouble() * 0.15;
    isStar = rand.nextBool();
  }
}
