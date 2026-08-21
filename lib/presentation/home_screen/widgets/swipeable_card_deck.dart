import 'dart:math' as math;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';

/// Tinder-style swipeable card deck widget.
class SwipeableCardDeck extends StatefulWidget {
  final List<ProfileModel> profiles;
  final void Function(ProfileModel profile) onTap;
  final void Function(ProfileModel profile) onInterest;
  final void Function(ProfileModel profile) onSkip;
  final void Function(ProfileModel profile) onSuperLike;
  final void Function(ProfileModel profile) onShare;
  final void Function(ProfileModel profile) onBookmark;
  final VoidCallback? onLoadMore;

  const SwipeableCardDeck({
    super.key,
    required this.profiles,
    required this.onTap,
    required this.onInterest,
    required this.onSkip,
    required this.onSuperLike,
    required this.onShare,
    required this.onBookmark,
    this.onLoadMore,
  });

  @override
  State<SwipeableCardDeck> createState() => _SwipeableCardDeckState();
}

class _SwipeableCardDeckState extends State<SwipeableCardDeck>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Offset _dragPosition = Offset.zero;
  double _dragAngle = 0;

  late AnimationController _swipeController;
  late AnimationController _heartBurstController;
  late Animation<double> _heartScaleAnim;

  bool _showHeartBurst = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _heartBurstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _heartBurstController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _heartBurstController.dispose();
    super.dispose();
  }

  bool get _hasProfiles =>
      widget.profiles.isNotEmpty && _currentIndex < widget.profiles.length;

  ProfileModel? get _topProfileOrNull =>
      _currentIndex < widget.profiles.length ? widget.profiles[_currentIndex] : null;


  void _onPanStart(DragStartDetails details) {
    // Drag started
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta;
      _dragAngle = _dragPosition.dx / 400 * (math.pi / 12);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dx = _dragPosition.dx;

    if (dx > 100 || velocity > 500) {
      _animateSwipe(true); // Right = Interest
    } else if (dx < -100 || velocity < -500) {
      _animateSwipe(false); // Left = Skip
    } else {
      _snapBack();
    }
  }

  void _animateSwipe(bool isRight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;
    final targetAngle = isRight ? math.pi / 8 : -math.pi / 8;

    final startPos = _dragPosition;
    final startAngle = _dragAngle;

    _swipeController.reset();
    _swipeController.addListener(() {
      setState(() {
        _dragPosition = Offset(
          startPos.dx + (targetX - startPos.dx) * _swipeController.value,
          startPos.dy + (0 - startPos.dy) * _swipeController.value,
        );
        _dragAngle = startAngle +
            (targetAngle - startAngle) * _swipeController.value;
      });
    });

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _swipeController.removeListener(() {});
        final profile = _topProfileOrNull;
        if (profile == null) return;

        if (isRight) {
          widget.onInterest(profile);
          _triggerHeartBurst();
        } else {
          widget.onSkip(profile);
        }

        HapticFeedback.mediumImpact();

        setState(() {
          _currentIndex++;
          _dragPosition = Offset.zero;
          _dragAngle = 0;
        });

        // Check if we need to load more
        if (widget.onLoadMore != null &&
            _currentIndex >= widget.profiles.length - 3) {
          widget.onLoadMore!();
        }
      }
    });

    _swipeController.forward();
  }

  void _snapBack() {
    final startPos = _dragPosition;
    final startAngle = _dragAngle;

    _swipeController.reset();
    _swipeController.addListener(() {
      setState(() {
        _dragPosition = Offset(
          startPos.dx * (1 - _swipeController.value),
          startPos.dy * (1 - _swipeController.value),
        );
        _dragAngle = startAngle * (1 - _swipeController.value);
      });
    });
    _swipeController.forward();
  }

  void _triggerHeartBurst() {
    setState(() => _showHeartBurst = true);
    _heartBurstController.reset();
    _heartBurstController.forward().then((_) {
      if (mounted) setState(() => _showHeartBurst = false);
    });
  }

  void _handleButtonSkip() {
    if (!_hasProfiles) return;
    HapticFeedback.lightImpact();
    _animateSwipe(false);
  }

  void _handleButtonInterest() {
    if (!_hasProfiles) return;
    HapticFeedback.lightImpact();
    _animateSwipe(true);
  }

  void _handleSuperLike() {
    final profile = _topProfileOrNull;
    if (profile == null) return;
    HapticFeedback.heavyImpact();
    widget.onSuperLike(profile);
    _triggerHeartBurst();
    // Move to next card
    setState(() {
      _currentIndex++;
    });

    // Check if we need to load more
    if (widget.onLoadMore != null &&
        _currentIndex >= widget.profiles.length - 3) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasProfiles) {
      return _buildEmptyDeck(context);
    }

    return Column(
      children: [
        // Card stack
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background cards (show 2 behind the top card)
              ..._buildBackgroundCards(),

              // Top card (draggable)
              Positioned.fill(
                child: _buildTopCard(),
              ),

              // Swipe decision overlays
              Positioned.fill(
                child: _buildSwipeOverlays(),
              ),

              // Heart burst animation
              if (_showHeartBurst)
                Positioned.fill(
                  child: Center(child: _buildHeartBurst()),
                ),
            ],
          ),
        ),

        // Action buttons
        _buildActionButtons(context),
      ],
    );
  }

  List<Widget> _buildBackgroundCards() {
    final cards = <Widget>[];
    for (int i = 2; i >= 1; i--) {
      final index = _currentIndex + i;
      if (index >= widget.profiles.length) continue;
      final profile = widget.profiles[index];
      cards.add(
        Positioned(
          top: (i * 6).toDouble(),
          left: (i * 3).toDouble(),
          right: (i * 3).toDouble(),
          bottom: (i * 6).toDouble(),
          child: Opacity(
            opacity: 1.0 - (i * 0.15),
            child: Transform.scale(
              scale: 1.0 - (i * 0.035),
              child: RepaintBoundary(
                child: _buildProfileCard(profile, isBackground: true),
              ),
            ),
          ),
        ),
      );
    }
    return cards;
  }

  Widget _buildTopCard() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () {
        final profile = _topProfileOrNull;
        if (profile != null) widget.onTap(profile);
      },
      child: Transform.translate(
        offset: _dragPosition,
        child: Transform.rotate(
          angle: _dragAngle,
          child: RepaintBoundary(
            child: _hasProfiles 
                ? _buildProfileCard(widget.profiles[_currentIndex], isBackground: false)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeOverlays() {
    final dx = _dragPosition.dx;
    if (dx == 0) return const SizedBox.shrink();

    final opacity = (dx.abs() / 140).clamp(0.0, 1.0);
    final scale = 0.9 + (dx.abs() / 300).clamp(0.0, 0.25);

    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Stack(
          children: [
            // NOPE / PASS stamp (left swipe)
            if (dx < 0)
              Align(
                alignment: Alignment.topRight,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(color: const Color(0xFFFF3366), width: 3),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3366).withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.close_rounded, color: Color(0xFFFF3366), size: 24),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)?.skip ?? 'PASS',
                              style: TextStyle(
                                color: const Color(0xFFFF3366),
                                fontSize: AppTypography.headingMedium,
                                fontWeight: AppTypography.black,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // LIKE / INTEREST stamp (right swipe)
            if (dx > 0)
              Align(
                alignment: Alignment.topLeft,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: -0.18,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(color: const Color(0xFF10B981), width: 3),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_rounded, color: Color(0xFF10B981), size: 24),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)?.interest ?? 'INTEREST',
                              style: TextStyle(
                                color: const Color(0xFF10B981),
                                fontSize: AppTypography.headingMedium,
                                fontWeight: AppTypography.black,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileModel profile,
      {required bool isBackground}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: ProfileCardWidget(
        profile: profile,
        showActionButtons: false,
        onTap: () => widget.onTap(profile),
        onBookmark: () => widget.onBookmark(profile),
        onShare: (p) => widget.onShare(p),
        onInterest: (p) => widget.onInterest(p),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final topProfile = _topProfileOrNull;
    final isBookmarked = topProfile?.isBookmarked ?? false;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.6.h, horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. ❌ Skip / Pass button
          _buildCircularButton(
            icon: Icons.close_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            size: 5.4.h,
            iconSize: 18.sp,
            onPressed: _handleButtonSkip,
            label: AppLocalizations.of(context)?.skip ?? 'Pass',
          ),

          // 2. 🔖 Bookmark / Shortlist button
          _buildCircularButton(
            icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            gradient: isBookmarked
                ? const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.shade800,
                      Colors.grey.shade700,
                    ],
                  ),
            size: 4.5.h,
            iconSize: 15.sp,
            onPressed: () {
              final profile = _topProfileOrNull;
              if (profile != null) {
                HapticFeedback.mediumImpact();
                widget.onBookmark(profile);
              }
            },
            label: isBookmarked
                ? (AppLocalizations.of(context)?.saved ?? 'Saved')
                : (AppLocalizations.of(context)?.save ?? 'Shortlist'),
          ),

          // 3. ⭐ Super Like button
          _buildCircularButton(
            icon: Icons.star_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            size: 4.5.h,
            iconSize: 16.sp,
            onPressed: _handleSuperLike,
            label: AppLocalizations.of(context)?.textSuper ?? 'Super',
          ),

          // 4. 💖 Express Interest / Like button
          _buildCircularButton(
            icon: Icons.favorite_rounded,
            gradient: AppGradients.love,
            size: 5.4.h,
            iconSize: 19.sp,
            onPressed: _handleButtonInterest,
            label: AppLocalizations.of(context)?.interest ?? 'Interest',
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required LinearGradient gradient,
    required double size,
    required double iconSize,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.40),
                    blurRadius: 10,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.labelTiny,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.90),
            fontWeight: AppTypography.bold,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildHeartBurst() {
    return AnimatedBuilder(
      animation: _heartBurstController,
      builder: (context, child) {
        return Transform.scale(
          scale: _heartScaleAnim.value,
          child: Icon(
            Icons.favorite_rounded,
            color: Colors.redAccent.withValues(
                alpha: (1.0 - _heartBurstController.value).clamp(0.0, 1.0)),
            size: 80.sp,
          ),
        );
      },
    );
  }

  Widget _buildEmptyDeck(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              gradient: AppGradients.romance,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF416C).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 40.sp,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            AppLocalizations.of(context)?.seenAllProfiles ?? "You've seen all profiles!",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(AppLocalizations.of(context)?.checkBackSoonForNewMatchesnpullDownToRef ?? 'Check back soon for new matches.\nPull down to refresh.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
