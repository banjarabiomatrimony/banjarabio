import 'package:banjarabio/core/constants/app_typography.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/presentation/shared_profiles_screen/shared_profiles_screen.dart';
import 'package:banjarabio/presentation/chat/conversation_list_screen.dart';
import 'package:banjarabio/notification/features/notification_bridge.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💬 Unified Connect Screen (Single-Row 4-Tab Architecture)
/// Tab 0: 💬 Chat (Live Conversations & Story Reel)
/// Tab 1: 📥 Received (Incoming connection requests)
/// Tab 2: 💍 Matched (Mutual matches ready to chat)
/// Tab 3: 📤 Sent (Outgoing shared profiles)
class InboxScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const InboxScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  AnimationController? _auraController;
  int _selectedIndex = 0;

  AnimationController get auraController {
    _auraController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
    return _auraController!;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, 3);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _selectedIndex,
    );
    _tabController.addListener(_handleTabSelection);

    _initAura();

    AnalyticsService.logScreenView('connect_screen');
  }

  void _initAura() {
    _auraController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  void _handleTabSelection() {
    FocusScope.of(context).unfocus();
    if (_tabController.index != _selectedIndex) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _auraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final receivedCount = ref.watch(receivedSharesCountProvider).value ?? 0;
    final matchedCount = ref.watch(matchedSharesCountProvider).value ?? 0;

    final tabs = [
      {
        'label': l10n?.chat ?? 'Chat',
        'icon': Icons.forum_rounded,
        'inactiveIcon': Icons.forum_outlined,
        'badge': 0,
      },
      {
        'label': l10n?.received ?? 'Received',
        'icon': Icons.move_to_inbox_rounded,
        'inactiveIcon': Icons.inbox_outlined,
        'badge': receivedCount,
      },
      {
        'label': l10n?.matched ?? 'Matched',
        'icon': Icons.favorite_rounded,
        'inactiveIcon': Icons.favorite_border_rounded,
        'badge': matchedCount,
      },
      {
        'label': l10n?.sent ?? 'Sent',
        'icon': Icons.outbox_rounded,
        'inactiveIcon': Icons.outbox_outlined,
        'badge': 0,
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: Text(
          l10n?.chat ?? 'Connect',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: ListenableBuilder(
                listenable: NotificationBridge().historyStore,
                builder: (context, _) {
                  final unreadCount = NotificationBridge().historyStore.unreadCount;
                  return TactilePressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pushNamed(context, AppRoutes.activityHub);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: AppColors.opacity20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: AppColors.opacity20)
                              : Colors.white.withValues(alpha: AppColors.opacity35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                size: 13,
                                color: Colors.white,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: -3,
                                  top: -3,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 9, minHeight: 9),
                                    child: Text(
                                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                                      style:                                       AppTypography.bodyStyle(
                                        color: Colors.white,
                                        fontWeight: AppTypography.black,
                                        fontSize: AppTypography.labelTiny,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Notifications',
                            style:                             AppTypography.labelStyle(
                              color: Colors.white,
                              fontSize: AppTypography.labelSmall,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6.6.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
            child: Container(
              height: 5.2.h,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.canvasNearBlack
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity70),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: AppColors.opacity8)
                      : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: AnimatedBuilder(
                animation: auraController,
                builder: (context, _) {
                  return TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: RunningAuraTabIndicator(
                      animationPercent: auraController.value,
                      selectedIndex: _selectedIndex,
                      isDark: isDark,
                      strokeWidth: 1.8,
                    ),
                    labelStyle: TextStyle(
                      fontSize: AppTypography.labelMedium,
                      fontWeight: AppTypography.black,
                      letterSpacing: 0.1,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: AppTypography.labelMedium,
                      fontWeight: AppTypography.bold,
                      letterSpacing: 0.1,
                    ),
                    tabAlignment: TabAlignment.fill,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    tabs: List.generate(tabs.length, (index) {
                      final tab = tabs[index];
                      final isSelected = _selectedIndex == index;
                      final activeColor = _getTabColor(index, isDark);

                      return Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? (tab['icon'] as IconData)
                                  : (tab['inactiveIcon'] as IconData),
                              size: 13.5,
                              color: isSelected
                                  ? activeColor
                                  : (isDark ? Colors.white60 : AppColors.slate500),
                            ),
                            SizedBox(width: 1.w),
                            Flexible(
                              child: Text(
                                tab['label'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected
                                      ? activeColor
                                      : (isDark ? Colors.white60 : AppColors.slate500),
                                  fontWeight: isSelected
                                      ? AppTypography.black
                                      : AppTypography.bold,
                                ),
                              ),
                            ),
                            if ((tab['badge'] as int? ?? 0) > 0) ...[
                              const SizedBox(width: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (index == 2 ? AppColors.categoryAstro : AppColors.categoryCareerDark)
                                      : (index == 2
                                          ? AppColors.categoryAstro.withValues(alpha: AppColors.opacity70)
                                          : AppColors.categoryCareerDark.withValues(alpha: AppColors.opacity70)),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (index == 2 ? AppColors.categoryAstro : AppColors.categoryCareerDark)
                                          .withValues(alpha: AppColors.opacity40),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${tab['badge']}',
                                  style:                                   AppTypography.bodyStyle(
                                    color: Colors.white,
                                    fontWeight: AppTypography.black,
                                    fontSize: AppTypography.labelTiny,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: TabBarView(
          controller: _tabController,
          children: const [
            // 💬 Tab 0: Live Chat Threads
            ConversationListScreen(isEmbedded: true),

            // 📥 Tab 1: Received Requests
            SharedProfilesScreen(
              isEmbedded: true,
              fixedFilter: SharedProfileTabFilter.received,
            ),

            // 💍 Tab 2: Mutual Matches
            SharedProfilesScreen(
              isEmbedded: true,
              fixedFilter: SharedProfileTabFilter.matched,
            ),

            // 📤 Tab 3: Sent Profiles
            SharedProfilesScreen(
              isEmbedded: true,
              fixedFilter: SharedProfileTabFilter.sent,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTabColor(int index, bool isDark) {
    switch (index) {
      case 1: // 📥 Received: Sapphire Blue
        return isDark ? AppColors.blue300 : AppColors.categoryCareerDark;
      case 2: // 💍 Matched: Sacred Gold
        return isDark ? AppColors.goldTint200 : AppColors.amberDark;
      case 3: // 📤 Sent: Amethyst Purple
        return isDark ? AppColors.lavender : AppColors.categoryFamilyDark;
      case 0: // 💬 Chat: Royal Ruby
      default:
        return isDark ? AppColors.rose200 : AppColors.crimsonRose;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Running Aura Tab Indicator (Tab-Specific Matrimonial Aura)
// ─────────────────────────────────────────────────────────────
class RunningAuraTabIndicator extends Decoration {
  final double animationPercent;
  final int selectedIndex;
  final bool isDark;
  final double borderRadius;
  final double strokeWidth;

  const RunningAuraTabIndicator({
    this.animationPercent = 0.0,
    this.selectedIndex = 0,
    this.isDark = false,
    this.borderRadius = 14.0,
    this.strokeWidth = 1.6,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RunningAuraTabIndicatorPainter(this, onChanged);
  }
}

class _RunningAuraTabIndicatorPainter extends BoxPainter {
  final RunningAuraTabIndicator decoration;

  _RunningAuraTabIndicatorPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    if (rect.width <= 0 || rect.height <= 0) return;

    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(decoration.strokeWidth / 2 + 0.5),
      Radius.circular(decoration.borderRadius),
    );

    final isDark = decoration.isDark;
    final tabIndex = decoration.selectedIndex;

    // 🌟 Tab-Specific Authentic Matrimonial Colors
    final Color baseFillColor;
    final List<Color> auraColors;
    final List<double> auraStops;
    final List<Color> bottomBarColors;

    if (tabIndex == 1) {
      // 📥 Tab 1: Received Requests (Trust Sapphire Blue)
      baseFillColor = isDark
          ? AppColors.blue900.withValues(alpha: AppColors.opacity35)
          : AppColors.infoLight;
      auraColors = const [
        AppColors.categoryCareerDark, // Sapphire Blue
        AppColors.blue400, // Soft Azure
        AppColors.categoryCareer, // Vivid Cobalt
        AppColors.blue300, // Ice Blue Highlight
        AppColors.blue600, // Deep Royal Blue
        AppColors.categoryCareerDark, // Loop
      ];
      auraStops = const [0.0, 0.25, 0.5, 0.75, 0.9, 1.0];
      bottomBarColors = const [
        AppColors.categoryCareerDark,
        AppColors.blue400,
        AppColors.categoryCareer,
      ];
    } else if (tabIndex == 2) {
      // 💍 Tab 2: Matched Profiles (Sacred Ruby & 24K Royal Gold)
      baseFillColor = isDark
          ? AppColors.crimsonDarkBg.withValues(alpha: AppColors.opacity35)
          : AppColors.primaryLight;
      auraColors = const [
        AppColors.crimsonRose, // Sacred Ruby
        AppColors.categoryAstro, // 24K Wedding Gold
        AppColors.crimsonBlush, // Crimson Flame
        AppColors.goldSoft, // Amber Sun
        AppColors.rose200, // Rose Velvet
        AppColors.crimsonRose, // Loop
      ];
      auraStops = const [0.0, 0.2, 0.45, 0.7, 0.85, 1.0];
      bottomBarColors = const [
        AppColors.crimsonRose,
        AppColors.categoryAstro,
        AppColors.crimsonBlush,
      ];
    } else if (tabIndex == 3) {
      // 📤 Tab 3: Sent Shares (Royal Amethyst Purple)
      baseFillColor = isDark
          ? AppColors.deepIndigo.withValues(alpha: AppColors.opacity35)
          : AppColors.violetBgSoft;
      auraColors = const [
        AppColors.categoryFamilyDark, // Amethyst Purple
        AppColors.purple400, // Orchid Lavender
        AppColors.electricPurple, // Royal Violet
        AppColors.violetSoft, // Soft Lilac Highlight
        AppColors.violetDeep, // Deep Purple
        AppColors.categoryFamilyDark, // Loop
      ];
      auraStops = const [0.0, 0.25, 0.5, 0.75, 0.9, 1.0];
      bottomBarColors = const [
        AppColors.categoryFamilyDark,
        AppColors.purple400,
        AppColors.electricPurple,
      ];
    } else {
      // 💬 Tab 0: Chat (Royal Crimson & Rose)
      baseFillColor = isDark
          ? AppColors.crimsonDarkBg.withValues(alpha: AppColors.opacity35)
          : AppColors.primaryLight;
      auraColors = const [
        AppColors.crimsonRose, // Banjara Ruby
        AppColors.rose400, // Coral Rose
        AppColors.crimsonBlush, // Crimson Flame
        AppColors.rose200, // Rose Velvet
        AppColors.wineRed, // Deep Ruby
        AppColors.crimsonRose, // Loop
      ];
      auraStops = const [0.0, 0.25, 0.5, 0.75, 0.9, 1.0];
      bottomBarColors = const [
        AppColors.crimsonRose,
        AppColors.rose400,
        AppColors.crimsonBlush,
      ];
    }

    // 1. Subtle Active Tab Glassmorphic Background Fill
    final Paint bgPaint = Paint()
      ..color = baseFillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // 2. Rotating Matrimonial Sweep Gradient
    final sweepGradient = SweepGradient(
      transform: GradientRotation(decoration.animationPercent * 2 * math.pi),
      colors: auraColors,
      stops: auraStops,
    );

    // 3. Glowing Outer Blur Aura around the border
    final Paint glowPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = decoration.strokeWidth * 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(rrect, glowPaint);

    // 4. Sharp Crisp Running Stroke on Button Border
    final Paint strokePaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = decoration.strokeWidth;
    canvas.drawRRect(rrect, strokePaint);

    // 5. Anchoring Bottom Radiant Bar (Curved with the tab)
    final double barWidth = (rect.width - 16).clamp(24.0, rect.width);
    final double barLeft = rect.left + (rect.width - barWidth) / 2;
    final double barTop = rect.bottom - 3.5 - 1.5;
    final Rect barRect = Rect.fromLTWH(barLeft, barTop, barWidth, 3.0);
    final RRect barRRect = RRect.fromRectAndRadius(barRect, const Radius.circular(2.5));

    final Paint barPaint = Paint()
      ..shader = LinearGradient(colors: bottomBarColors).createShader(barRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(barRRect, barPaint);
  }
}

