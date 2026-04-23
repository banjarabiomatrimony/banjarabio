import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/presentation/widgets/rewarded_ad_dialog.dart';
import 'package:banjarabio/core/services/ad_reward_service.dart';

class WhoViewedMeScreen extends StatefulWidget {
  const WhoViewedMeScreen({super.key});

  @override
  State<WhoViewedMeScreen> createState() => _WhoViewedMeScreenState();
}

class _WhoViewedMeScreenState extends State<WhoViewedMeScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  bool _isLoading = true;
  List<ProfileViewModel> _views = [];
  bool _isUnlockedByAd = false;

  @override
  void initState() {
    super.initState();
    _loadViews();
  }

  Future<void> _loadViews() async {
    final response = await _chatRepository.getWhoViewedMe();
    if (mounted) {
      Future.microtask(() {
        if (!mounted) return;
        if (response.isSuccess) {
          setState(() {
            _views = response.data;
            _isLoading = false;
          });
        } else {
          debugPrint('Error loading views: ${response.errorMessage}');
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.whoViewedMe ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 14.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState(theme)
          : _views.isEmpty
              ? _buildEmptyState(theme)
              : _buildTimelineList(theme),
      bottomNavigationBar: (!SessionManager.instance.isPremium && !_isUnlockedByAd && _views.length > 3)
          ? _buildUnlockBanner(theme)
          : null,
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(AppLocalizations.of(context)?.loadingViews ?? '',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(ThemeData theme) {
    final bool isPremium = SessionManager.instance.isPremium;
    final int displayCount = (isPremium || _isUnlockedByAd) ? _views.length : 3;
    final int itemCount = _views.length > displayCount ? displayCount : _views.length;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final view = _views[index];
        return _AnimatedTimelineEntry(
          index: index,
          isLast: index == itemCount - 1 && (isPremium || _isUnlockedByAd || _views.length <= 3),
          child: _buildViewCard(theme, view),
        );
      },
    );
  }

  Widget _buildUnlockBanner(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.unlockMoreVisitors(_views.length - 3) ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => RewardedAdDialog(
                    rewardType: AdRewardType.whoViewedMe,
                    onRewardGranted: () {
                      setState(() {
                        _isUnlockedByAd = true;
                      });
                    },
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_fill),
              label: Text(l10n?.watchAdToUnlockAll ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.subscription),
            child: Text(l10n?.goProAdFree ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildViewCard(ThemeData theme, ProfileViewModel view) {
    final relativeTime = _relativeTime(view.lastViewedAt);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.profileDetail,
          arguments: view.viewerId,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with gradient border
            Container(
              width: 14.w,
              height: 14.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.romance,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: view.viewerImageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    view.viewerName ?? AppLocalizations.of(context)?.someone ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${view.viewCount} ${view.viewCount == 1 ? (AppLocalizations.of(context)?.viewLabel ?? "") : (AppLocalizations.of(context)?.viewsLabel ?? "")}',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Relative time + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  relativeTime,
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.visibility_off_outlined,
              size: 40.sp,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 3.h),
          Text(AppLocalizations.of(context)?.noViewsYet ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(AppLocalizations.of(context)?.completeYourProfileToGetNoticed ?? '',
            style: TextStyle(
              fontSize: 10.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return AppLocalizations.of(context)?.justNow ?? '';
    if (diff.inMinutes < 60) return AppLocalizations.of(context)?.minutesAgo(diff.inMinutes.toString()) ?? '';
    if (diff.inHours < 24) return AppLocalizations.of(context)?.hoursAgo(diff.inHours.toString()) ?? '';
    if (diff.inDays == 1) return AppLocalizations.of(context)?.yesterday ?? '';
    if (diff.inDays < 7) return AppLocalizations.of(context)?.daysAgo(diff.inDays.toString()) ?? '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Animates each timeline entry: slide-in from left + fade + timeline connector.
class _AnimatedTimelineEntry extends StatefulWidget {
  final int index;
  final bool isLast;
  final Widget child;

  const _AnimatedTimelineEntry({
    required this.index,
    required this.isLast,
    required this.child,
  });

  @override
  State<_AnimatedTimelineEntry> createState() => _AnimatedTimelineEntryState();
}

class _AnimatedTimelineEntryState extends State<_AnimatedTimelineEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Stagger animation by index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline connector
                SizedBox(
                  width: 6.w,
                  child: Column(
                    children: [
                      // Dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.primary,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      // Line
                      if (!widget.isLast)
                        Container(
                          width: 2,
                          height: 10.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Card
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}
