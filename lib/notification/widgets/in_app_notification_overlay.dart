import 'dart:async';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Zomato-style in-app notification overlay.
///
/// Slides down from the top of the screen when a notification arrives
/// while the app is in the foreground. Includes:
/// - Profile image thumbnail
/// - Title + body text
/// - Tap to navigate
/// - Auto-dismiss after 4 seconds
/// - Swipe up to dismiss
class InAppNotificationOverlay {
  static final InAppNotificationOverlay _instance =
      InAppNotificationOverlay._internal();
  factory InAppNotificationOverlay() => _instance;
  InAppNotificationOverlay._internal();

  OverlayEntry? _currentOverlay;
  Timer? _autoDismissTimer;

  /// Show an in-app notification banner.
  ///
  /// [context] must be from a widget whose [Overlay] ancestor exists (e.g., MaterialApp).
  /// [onTap] is called when the user taps the banner.
  void show({
    required BuildContext context,
    required NotificationPayload payload,
    VoidCallback? onTap,
    Duration autoDismissDuration = const Duration(seconds: 4),
  }) {
    // Dismiss any existing banner first
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);

    _currentOverlay = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        payload: payload,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto-dismiss after duration
    _autoDismissTimer = Timer(autoDismissDuration, dismiss);
  }

  void dismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _InAppNotificationBanner extends StatefulWidget {
  final NotificationPayload payload;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationBanner({
    required this.payload,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState
    extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  Future<void> _animateOut() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -100) {
                _animateOut();
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                top: topPadding + 10,
                left: 14,
                right: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.materialPink.withValues(alpha: AppColors.opacity20),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.materialPink.withValues(alpha: AppColors.opacity12),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: AppColors.opacity8),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Category icon or profile image with active indicator border
                        _buildLeading(),
                        const SizedBox(width: 12),

                        // Text content with Category Tag
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Category Tag Banner
                              _buildCategoryBadge(widget.payload.category),
                              const SizedBox(height: 4),

                              if (widget.payload.title != null)
                                Text(
                                  widget.payload.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.headingStyle(
                                    fontSize: AppTypography.bodyLarge,
                                    color: AppColors.slate800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              if (widget.payload.body != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.payload.body!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppTypography.bodyMedium,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Action Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.materialPink.withValues(alpha: AppColors.opacity8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.materialPink,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.materialPink,
                                size: 16,
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
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(NotificationCategory category) {
    final label = _getCategoryLabel(category);
    final color = _getCategoryVisuals(category).$2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacity12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: AppTypography.labelMedium,
          fontWeight: AppTypography.extraBold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getCategoryLabel(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.interestReceived:
        return 'Interest Alert';
      case NotificationCategory.matchFound:
        return 'Mutual Match 💕';
      case NotificationCategory.chatMessage:
        return 'New Message 💬';
      case NotificationCategory.profileView:
        return 'Profile Update';
      case NotificationCategory.nudge:
        return 'Match Nudge ⭐';
      case NotificationCategory.system:
        return 'System Alert';
      case NotificationCategory.general:
        return 'BanjaraBio';
      case NotificationCategory.staffTask:
        return 'Staff Task';
      case NotificationCategory.adminAlert:
        return 'Important Alert';
      case NotificationCategory.verificationReview:
        return 'Verified';
    }
  }

  Widget _buildLeading() {
    if (widget.payload.hasImage) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.materialPink.withValues(alpha: AppColors.opacity50),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CachedNetworkImage(
            imageUrl: widget.payload.imageUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            cacheManager: PersistentCacheManager.instance,
            cacheKey: PersistentCacheManager.stableKeyFor(widget.payload.imageUrl!),
            placeholder: (context2, url) => _buildCategoryIcon(),
            errorWidget: (context2, url, error) => _buildCategoryIcon(),
          ),
        ),
      );
    }
    return _buildCategoryIcon();
  }

  Widget _buildCategoryIcon() {
    final (icon, color) = _getCategoryVisuals(widget.payload.category);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacity12),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: AppColors.opacity30),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(icon, style: TextStyle(fontSize: AppTypography.headingLarge)),
      ),
    );
  }

  (String, Color) _getCategoryVisuals(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.interestReceived:
        return ('❤️', AppColors.materialPink);
      case NotificationCategory.matchFound:
        return ('💍', AppColors.successDark);
      case NotificationCategory.chatMessage:
        return ('💬', AppColors.teal);
      case NotificationCategory.profileView:
        return ('👀', AppColors.materialOrange);
      case NotificationCategory.nudge:
        return ('⭐', AppColors.categoryAstro);
      case NotificationCategory.system:
        return ('🔔', AppColors.instagramPurple);
      case NotificationCategory.general:
        return ('📢', AppColors.blueGray500);
      case NotificationCategory.staffTask:
        return ('📋', AppColors.materialBlue);
      case NotificationCategory.adminAlert:
        return ('🚨', AppColors.deepOrange);
      case NotificationCategory.verificationReview:
        return ('✅', AppColors.successDark);
    }
  }
}
