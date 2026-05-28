import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

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
                top: topPadding + 8,
                left: 12,
                right: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Category icon or profile image
                        _buildLeading(),
                        const SizedBox(width: 12),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.payload.title != null)
                                Text(
                                  widget.payload.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              if (widget.payload.body != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  widget.payload.body!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade600,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Dismiss hint
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
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

  Widget _buildLeading() {
    if (widget.payload.hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.payload.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          cacheManager: PersistentCacheManager.instance,
          placeholder: (context2, url) => _buildCategoryIcon(),
          errorWidget: (context2, url, error) => _buildCategoryIcon(),
        ),
      );
    }
    return _buildCategoryIcon();
  }

  Widget _buildCategoryIcon() {
    final (icon, color) = _getCategoryVisuals(widget.payload.category);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  (String, Color) _getCategoryVisuals(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.interestReceived:
        return ('❤️', const Color(0xFFC94B4B));
      case NotificationCategory.matchFound:
        return ('💍', const Color(0xFF4CAF50));
      case NotificationCategory.chatMessage:
        return ('💬', const Color(0xFF2196F3));
      case NotificationCategory.profileView:
        return ('👀', const Color(0xFFFF9800));
      case NotificationCategory.nudge:
        return ('⭐', const Color(0xFFFFC107));
      case NotificationCategory.system:
        return ('🔔', const Color(0xFF9E9E9E));
      case NotificationCategory.general:
        return ('📢', const Color(0xFF607D8B));
      case NotificationCategory.staffTask:
        return ('📋', const Color(0xFF2196F3));
      case NotificationCategory.adminAlert:
        return ('🚨', const Color(0xFFFF5722));
      case NotificationCategory.verificationReview:
        return ('✅', const Color(0xFF4CAF50));
    }
  }
}
