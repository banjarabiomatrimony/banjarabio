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
      height: 52,
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
          padding: EdgeInsets.symmetric(horizontal: 3.5.w),
          children: [
            // ─── 1. 📸 Instagram (Follow Daily Match Updates) ───
            _buildAnimatedMiniCard(
              cardId: 'instagram_matches',
              outlineBorderColor: const Color(0xFFFDA4AF),
              leadingWidget: Image.asset(
                'assets/icons/instagram_icon.png',
                width: 29,
                height: 29,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                  'assets/images/social/instagram.svg',
                  width: 29,
                  height: 29,
                  placeholderBuilder: (_) => const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              badgeText: '⚡ DAILY',
              badgeColor: const Color(0xFFFFE4E6),
              badgeTextColor: const Color(0xFF9F1239),
              title: AppLocalizations.of(context)?.instagramStories ?? 'Instagram Stories',
              subtitle: _selectedCardId == 'instagram_matches'
                  ? (AppLocalizations.of(context)?.tapAgainToView ?? 'Tap again to View ➔')
                  : (AppLocalizations.of(context)?.followDailyMatchUpdates ?? 'Follow Daily Match Updates'),
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFFE11D48), Color(0xFFBE123C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _launchUrlHelper(
                  'https://www.instagram.com/banjarabio.matrimony/'),
            ),
            const SizedBox(width: 7),

            // ─── 2. 💬 WhatsApp Help (Direct Admin Support) ───
            _buildAnimatedMiniCard(
              cardId: 'whatsapp_help',
              outlineBorderColor: const Color(0xFF6EE7B7),
              leadingWidget: Image.asset(
                'assets/icons/whatsapp_icon.png',
                width: 29,
                height: 29,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                  'assets/images/social/whatsapp.svg',
                  width: 29,
                  height: 29,
                  placeholderBuilder: (_) => const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              badgeText: '● 24/7 LIVE',
              badgeColor: const Color(0xFFD1FAE5),
              badgeTextColor: const Color(0xFF065F46),
              title: AppLocalizations.of(context)?.whatsappHelp ?? 'WhatsApp Help',
              subtitle: _selectedCardId == 'whatsapp_help'
                  ? (AppLocalizations.of(context)?.tapAgainToChat ?? 'Tap again to Chat ➔')
                  : (AppLocalizations.of(context)?.directAdminSupport ?? 'Direct Admin Support'),
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _launchUrlHelper('https://wa.me/8186050406'),
            ),
            const SizedBox(width: 7),

            // ─── 3. 🏛️ BVS Community (Banjara Virasat Sangh) ───
            _buildAnimatedMiniCard(
              cardId: 'bvs_virasat',
              outlineBorderColor: const Color(0xFFFDE68A),
              leadingWidget: ClipOval(
                child: Image.asset(
                  'assets/sanjay rathod.webp',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/bvs_logo_gold.png',
                    width: 29,
                    height: 29,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.person_rounded,
                      color: Colors.amberAccent,
                      size: 26,
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
                    color: const Color(0xFFFEF08A),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
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
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9), Color(0xFF4C1D95)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.bvsGateway),
            ),
            const SizedBox(width: 7),

            // ─── 4. 💍 Candidates Meet (Banjara Vadhu Var Suchak Initiative) ───
            _buildAnimatedMiniCard(
              cardId: 'candidates_meet',
              outlineBorderColor: const Color(0xFFFBCFE8),
              leadingWidget: const ClipOval(
                child: AppLogoImage(
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              badgeText: '💍 VADHU VAR',
              badgeColor: const Color(0xFFFCE7F3),
              badgeTextColor: const Color(0xFF9D174D),
              title: AppLocalizations.of(context)?.candidatesMeet ?? 'Candidates Meet',
              subtitle: _selectedCardId == 'candidates_meet'
                  ? (AppLocalizations.of(context)?.tapAgainToView ?? 'Tap again to View ➔')
                  : (AppLocalizations.of(context)?.vadhuVarSuchakInitiative ?? 'Vadhu Var Suchak Initiative'),
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFDB2777), Color(0xFF9D174D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.bvsGateway),
            ),
            const SizedBox(width: 7),

            // ─── 5. 🎁 VIP Offer (🔥 50% OFF VIP Upgrade) ───
            _buildAnimatedMiniCard(
              cardId: 'vip_offer',
              outlineBorderColor: const Color(0xFFFDE047),
              leadingWidget: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFEF08A),
                    Color(0xFFF59E0B),
                    Color(0xFFD97706),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              badgeText: '🔥 50% OFF',
              badgeColor: const Color(0xFFFEF3C7),
              badgeTextColor: const Color(0xFF92400E),
              title: AppLocalizations.of(context)?.vipFiftyPercentOff ?? '50% OFF VIP',
              subtitle: _selectedCardId == 'vip_offer'
                  ? (AppLocalizations.of(context)?.tapAgainToOpen ?? 'Tap again to Open ➔')
                  : (AppLocalizations.of(context)?.fiftyPercentOffVipUpgrade ?? '🔥 50% OFF VIP Upgrade'),
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.subscription),
            ),

            // ─── 6. Dynamic Backend Announcements (if any) ───
            for (final banner in _backendBanners) ...[
              const SizedBox(width: 7),
              _buildAnimatedMiniCard(
                cardId: banner.id,
                outlineBorderColor: const Color(0xFF93C5FD),
                leadingWidget: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 27,
                ),
                badgeText: '✨ SPECIAL',
                badgeColor: const Color(0xFFDBEAFE),
                badgeTextColor: const Color(0xFF1E40AF),
                title: banner.title.isNotEmpty
                    ? banner.title
                    : 'Announcement',
                subtitle: _selectedCardId == banner.id
                    ? 'Tap again to View ➔'
                    : 'Tap to discover more ➔',
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0.5),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: effectiveBorderColor,
                      width: isPausedCard ? 2.0 : 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isPausedCard
                            ? Colors.amberAccent.withValues(alpha: glowAlpha)
                            : (outlineBorderColor?.withValues(alpha: 0.40) ??
                                gradient.colors.first.withValues(alpha: 0.35)),
                        blurRadius: isPausedCard ? 12 : 6,
                        offset: const Offset(0, 2.5),
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
                                : (outlineBorderColor?.withValues(alpha: 0.85) ??
                                    Colors.white.withValues(alpha: 0.40)),
                            width: 1.2,
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
                                  fontSize: AppTypography.labelSmall,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (isPausedCard)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PAUSED',
                                    style: TextStyle(
                                      color: const Color(0xFF78350F),
                                      fontWeight: AppTypography.black,
                                      fontSize: AppTypography.labelTiny,
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
                                    color: badgeColor ?? const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(
                                      color: badgeTextColor ?? const Color(0xFF92400E),
                                      fontWeight: AppTypography.black,
                                      fontSize: AppTypography.labelTiny,
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
                              fontSize: AppTypography.labelTiny,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),

                      // ─── Interactive Trailing Indicator ───
                      Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isPausedCard
                              ? Colors.amberAccent
                              : Colors.white.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPausedCard
                              ? Icons.arrow_outward_rounded
                              : Icons.arrow_forward_ios_rounded,
                          color: isPausedCard
                              ? const Color(0xFF78350F)
                              : Colors.white,
                          size: isPausedCard ? 10.5 : 8,
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Shimmering Diagonal Light-Sweep Sheen ───
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
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
