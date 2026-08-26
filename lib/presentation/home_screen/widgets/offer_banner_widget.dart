import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/banner_model.dart';
import 'package:banjarabio/core/repositories/banner_repository.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// Ultra-Premium Animated Horizontal Mini-Promo Strip:
/// 1. 📸 Instagram Stories (Follow Daily Match Updates)
/// 2. 💬 WhatsApp Help (Direct Admin Support)
/// 3. 🏛️ Banjara Virasat Sangh (Portrait of Na. Shri Sanjay Rathod & Gold BVS Badge)
/// 4. 💍 Candidates Meet (Banjara Vadhu Var Suchak Initiative)
/// 5. 👑 VIP 50% OFF Card (Solar Gold Gradient + 3D Shimmering Crown)
/// 6. 📢 Dynamic Marketing Announcements
///
/// Features:
/// - 🌟 Distinct Illuminated Colored Outline Borders on every card & icon shield
/// - 🌟 Continuous Gentle Auto-Scroll Marquee (Hands-Free)
/// - ✨ Shimmering Diagonal Light-Sweep Glint across all cards
/// - 🚀 1st Tap: Pauses auto-move, scales up card (1.04x), radiates pulsing aura & CTA
/// - ⚡ 2nd Tap: Executes destination launch immediately
class OfferBannerWidget extends StatefulWidget {
  final String? gender;
  final String? currentPlan;
  final BannerRepository? repository;

  const OfferBannerWidget({
    super.key,
    this.gender,
    this.currentPlan,
    this.repository,
  });

  @override
  State<OfferBannerWidget> createState() => _OfferBannerWidgetState();
}

class _OfferBannerWidgetState extends State<OfferBannerWidget>
    with TickerProviderStateMixin {
  late final BannerRepository _bannerRepository =
      widget.repository ?? BannerRepository();
  final ScrollController _scrollController = ScrollController();
  List<BannerModel> _backendBanners = [];

  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  bool _isAutoMoving = true;
  String? _selectedCardId;

  AnimationController? _pulseController;
  AnimationController? _shimmerController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadBanners();
    _startAutoScroll();
  }

  void _initAnimations() {
    if (_pulseController == null) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 850),
      )..repeat(reverse: true);

      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );

      _glowAnimation = Tween<double>(begin: 0.35, end: 0.90).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }

    _shimmerController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _pulseController?.dispose();
    _shimmerController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (!_isAutoMoving || !_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentScroll + 0.65);
      }
    });
  }

  void _handleCardTap({
    required String cardId,
    required VoidCallback onOpen,
  }) {
    if (_isAutoMoving) {
      // 1st Tap: Stop auto-movement and highlight card
      HapticFeedback.mediumImpact();
      _resumeTimer?.cancel();
      setState(() {
        _isAutoMoving = false;
        _selectedCardId = cardId;
      });

      // Auto-resume if untouched for 5 seconds
      _resumeTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && !_isAutoMoving) {
          setState(() {
            _isAutoMoving = true;
            _selectedCardId = null;
          });
        }
      });
    } else {
      // 2nd Tap: Launch destination action!
      HapticFeedback.selectionClick();
      _resumeTimer?.cancel();
      setState(() {
        _isAutoMoving = true;
        _selectedCardId = null;
      });
      onOpen();
    }
  }

  Future<void> _loadBanners() async {
    final response = await _bannerRepository.getActiveBanners(
      gender: widget.gender,
      currentPlan: widget.currentPlan,
    );

    if (mounted) {
      response.fold(
        onSuccess: (banners) {
          setState(() {
            _backendBanners = banners;
          });
        },
        onFailure: (_) {},
      );
    }
  }

  Future<void> _launchUrlHelper(String urlString) async {
    HapticFeedback.lightImpact();
    final Uri uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            _isAutoMoving = false;
            _resumeTimer?.cancel();
          } else if (notification is ScrollEndNotification) {
            _resumeTimer?.cancel();
            _resumeTimer = Timer(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() => _isAutoMoving = true);
              }
            });
          }
          return false;
        },
        child: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1),
          children: [
            // ─── 1. 📸 Instagram (Follow Daily Match Updates) ───
            _buildAnimatedMiniCard(
              cardId: 'instagram_matches',
              outlineBorderColor: AppColors.rose200,
              leadingWidget: Image.asset(
                'assets/icons/instagram_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                  'assets/images/social/instagram.svg',
                  width: 28,
                  height: 28,
                  placeholderBuilder: (_) => const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              badgeText: '⚡ DAILY',
              badgeColor: AppColors.rose100,
              badgeTextColor: AppColors.wineRed,
              title: AppLocalizations.of(context)?.instagramStories ?? 'Instagram Stories',
              subtitle: _selectedCardId == 'instagram_matches'
                  ? (AppLocalizations.of(context)?.tapAgainToView ?? 'Tap again to View ➔')
                  : (AppLocalizations.of(context)?.followDailyMatchUpdates ?? 'Follow Daily Match Updates'),
              gradient: const LinearGradient(
                colors: [AppColors.coralRed, AppColors.crimsonBlush, AppColors.crimsonRose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _launchUrlHelper(
                  'https://www.instagram.com/banjarabio.matrimony/'),
            ),
            const SizedBox(width: 8),

            // ─── 2. 💬 WhatsApp Help (Direct Admin Support) ───
            _buildAnimatedMiniCard(
              cardId: 'whatsapp_help',
              outlineBorderColor: AppColors.cyanAccent,
              leadingWidget: Image.asset(
                'assets/icons/whatsapp_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                  'assets/images/social/whatsapp.svg',
                  width: 28,
                  height: 28,
                  placeholderBuilder: (_) => const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              badgeText: '● 24/7 LIVE',
              badgeColor: AppColors.green100alt,
              badgeTextColor: AppColors.greenDeepForest,
              title: AppLocalizations.of(context)?.whatsappHelp ?? 'WhatsApp Help',
              subtitle: _selectedCardId == 'whatsapp_help'
                  ? (AppLocalizations.of(context)?.tapAgainToChat ?? 'Tap again to Chat ➔')
                  : (AppLocalizations.of(context)?.directAdminSupport ?? 'Direct Admin Support'),
              gradient: const LinearGradient(
                colors: [AppColors.categoryLocation, AppColors.categoryLocationDark, AppColors.emerald],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _launchUrlHelper('https://wa.me/8186050406'),
            ),
            const SizedBox(width: 8),

            // ─── 3. 🏛️ BVS Community (Banjara Virasat Sangh) ───
            _buildAnimatedMiniCard(
              cardId: 'bvs_virasat',
              outlineBorderColor: AppColors.goldTint200,
              leadingWidget: ClipOval(
                child: Image.asset(
                  'assets/sanjay rathod.webp',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/bvs_logo_gold.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.person_rounded,
                      color: Colors.amberAccent,
                      size: 24,
                    ),
                  ),
                ),
              ),
              badgeWidget: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.goldTint200,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: AppColors.opacity25),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/bvs_logo_gold.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.groups_rounded,
                      size: 14,
                      color: Colors.amberAccent,
                    ),
                  ),
                ),
              ),
              title: AppLocalizations.of(context)?.banjaraVirasatSangh ?? 'Banjara Virasat Sangh',
              subtitle: _selectedCardId == 'bvs_virasat'
                  ? (AppLocalizations.of(context)?.tapAgainToJoin ?? 'Tap again to Join ➔')
                  : (AppLocalizations.of(context)?.banjaraVirasatSangh ?? 'बणजारा विरासत संघ'),
              gradient: const LinearGradient(
                colors: [AppColors.categoryFamily, AppColors.violetDeep, AppColors.deepIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.bvsGateway),
            ),
            const SizedBox(width: 8),

            // ─── 4. 💍 Candidates Meet (Banjara Vadhu Var Suchak Initiative) ───
            _buildAnimatedMiniCard(
              cardId: 'candidates_meet',
              outlineBorderColor: AppColors.rose100,
              leadingWidget: const ClipOval(
                child: AppLogoImage(
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              badgeText: '💍 VADHU VAR',
              badgeColor: AppColors.purple50,
              badgeTextColor: AppColors.wineRed,
              title: AppLocalizations.of(context)?.candidatesMeet ?? 'Candidates Meet',
              subtitle: _selectedCardId == 'candidates_meet'
                  ? (AppLocalizations.of(context)?.tapAgainToView ?? 'Tap again to View ➔')
                  : (AppLocalizations.of(context)?.vadhuVarSuchakInitiative ?? 'Vadhu Var Suchak Initiative'),
              gradient: const LinearGradient(
                colors: [AppColors.categoryPersonal, AppColors.categoryPersonalDark, AppColors.wineRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.bvsGateway),
            ),
            const SizedBox(width: 8),

            // ─── 5. 🎁 VIP Offer (🔥 50% OFF VIP Upgrade) ───
            _buildAnimatedMiniCard(
              cardId: 'vip_offer',
              outlineBorderColor: AppColors.goldLemon,
              leadingWidget: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppColors.surfaceLight,
                    AppColors.goldTint200,
                    AppColors.categoryAstro,
                    AppColors.categoryAstroDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              badgeText: '🔥 50% OFF',
              badgeColor: AppColors.goldTint100,
              badgeTextColor: AppColors.amberDarkestText,
              title: AppLocalizations.of(context)?.vipFiftyPercentOff ?? '50% OFF VIP',
              subtitle: _selectedCardId == 'vip_offer'
                  ? (AppLocalizations.of(context)?.tapAgainToOpen ?? 'Tap again to Open ➔')
                  : (AppLocalizations.of(context)?.fiftyPercentOffVipUpgrade ?? '🔥 50% OFF VIP Upgrade'),
              gradient: const LinearGradient(
                colors: [AppColors.categoryAstro, AppColors.categoryAstroDark, AppColors.amberDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.subscription),
            ),

            // ─── 6. Dynamic Backend Announcements (if any) ───
            for (final banner in _backendBanners) ...[
              const SizedBox(width: 8),
              _buildAnimatedMiniCard(
                cardId: banner.id,
                outlineBorderColor: AppColors.blue300,
                leadingWidget: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                badgeText: '✨ SPECIAL',
                badgeColor: AppColors.blue100,
                badgeTextColor: AppColors.blue800,
                title: banner.title.isNotEmpty
                    ? banner.title
                    : 'Announcement',
                subtitle: _selectedCardId == banner.id
                    ? 'Tap again to View ➔'
                    : 'Tap to discover more ➔',
                gradient: const LinearGradient(
                  colors: [AppColors.categoryCareer, AppColors.categoryCareerDark, AppColors.blue600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  if (banner.actionUrl != null &&
                      banner.actionUrl!.isNotEmpty) {
                    _launchUrlHelper(banner.actionUrl!);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMiniCard({
    required String cardId,
    required Widget leadingWidget,
    Color? outlineBorderColor,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    Widget? badgeWidget,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    final bool isPausedCard = _selectedCardId == cardId;

    _initAnimations();
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController!, _shimmerController!]),
      builder: (context, child) {
        final double scale = isPausedCard ? (_scaleAnimation?.value ?? 1.0) : 1.0;
        final double glowAlpha = isPausedCard ? (_glowAnimation?.value ?? 0.35) : 0.35;
        final double shimmerPercent = _shimmerController?.value ?? 0.0;

        final Color effectiveBorderColor = isPausedCard
            ? Colors.amberAccent
            : (outlineBorderColor ?? Colors.white.withValues(alpha: 0.45));

        return Transform.scale(
          scale: scale,
          child: TactilePressable(
            onTap: () => _handleCardTap(cardId: cardId, onOpen: onTap),
            pressedScale: 0.96,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: effectiveBorderColor,
                      width: isPausedCard ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isPausedCard
                            ? Colors.amberAccent.withValues(alpha: glowAlpha)
                            : (outlineBorderColor?.withValues(alpha: AppColors.opacity40) ??
                                gradient.colors.first.withValues(alpha: AppColors.opacity35)),
                        blurRadius: isPausedCard ? 10 : 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── High-Impact Icon Shield with Colored Outline ───
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isPausedCard
                                ? Colors.amberAccent
                                : (outlineBorderColor?.withValues(alpha: AppColors.opacity85) ??
                                    Colors.white.withValues(alpha: AppColors.opacity40)),
                          ),
                        ),
                        child: leadingWidget,
                      ),
                      const SizedBox(width: 6),

                      // ─── Text Column + Highlight Micro-Badge ───
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: AppTypography.black,
                                  fontSize: AppTypography.labelLarge,
                                  height: 1.15,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(width: 5),
                              if (isPausedCard)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PAUSED',
                                    style: TextStyle(
                                      color: AppColors.amberDeepText,
                                      fontWeight: AppTypography.black,
                                      fontSize: AppTypography.labelSmall,
                                      height: 1.1,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                )
                              else if (badgeWidget != null)
                                badgeWidget
                              else if (badgeText != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: badgeColor ?? AppColors.goldTint100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(
                                      color: badgeTextColor ?? AppColors.amberDarkestText,
                                      fontWeight: AppTypography.black,
                                      fontSize: AppTypography.labelSmall,
                                      height: 1.1,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 1.0),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: isPausedCard
                                  ? Colors.amberAccent
                                  : Colors.white.withValues(alpha: 0.94),
                              fontWeight: isPausedCard
                                  ? AppTypography.black
                                  : AppTypography.medium,
                              fontSize: AppTypography.labelSmall,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),

                      // ─── Interactive Trailing Indicator ───
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isPausedCard
                              ? Colors.amberAccent
                              : Colors.white.withValues(alpha: AppColors.opacity20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPausedCard
                              ? Icons.arrow_outward_rounded
                              : Icons.arrow_forward_ios_rounded,
                          color: isPausedCard
                              ? AppColors.amberDeepText
                              : Colors.white,
                          size: isPausedCard ? 14 : 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Shimmering Diagonal Light-Sweep Sheen ───
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: _CardGlintPainter(
                          percent: shimmerPercent,
                          isPaused: isPausedCard,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter rendering a luxury diagonal glint reflection across the card
class _CardGlintPainter extends CustomPainter {
  final double percent;
  final bool isPaused;

  _CardGlintPainter({
    required this.percent,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isPaused) return;

    final double startX = -size.width + (size.width * 2.5 * percent);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(startX, 0, size.width * 0.8, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CardGlintPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.isPaused != isPaused;
}
