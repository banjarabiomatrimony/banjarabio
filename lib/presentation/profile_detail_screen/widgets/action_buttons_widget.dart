import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Action buttons widget for profile interactions
/// Provides sharing, messaging, and bookmarking functionality
class ActionButtonsWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final Function(Map<String, dynamic>) onShare;
  final Function(Map<String, dynamic>) onInterest;
  final Function(Map<String, dynamic>) onMessage;
  final Function(Map<String, dynamic>) onBookmark;

  const ActionButtonsWidget({
    super.key,
    required this.profileData,
    required this.onShare,
    required this.onInterest,
    required this.onMessage,
    required this.onBookmark,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.profileData['isBookmarked'] == true;
  }

  @override
  void didUpdateWidget(ActionButtonsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync when parent passes updated profileData (e.g. from Riverpod bookmark state)
    if (oldWidget.profileData['isBookmarked'] != widget.profileData['isBookmarked']) {
      _isBookmarked = widget.profileData['isBookmarked'] == true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 7.2.h,
          padding: EdgeInsets.symmetric(vertical: 0.6.h, horizontal: 2.w),
          child: Row(
            children: [
              // Save button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (kDebugMode) {
                        AppLogger.debug('ActionButtonsWidget', '[BOOKMARK] ActionButtonsWidget (ProfileDetail) > User tapped ${_isBookmarked ? "SAVED" : "SAVE"} on bottom bar (profile ${widget.profileData['id']}) > delegating to ProfileDetailScreen');
                      }
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                      widget.onBookmark(widget.profileData);
                      Fluttertoast.showToast(
                        msg: _isBookmarked
                            ? (AppLocalizations.of(context)?.profileSaved ??
                                'Profile saved!')
                            : (AppLocalizations.of(context)?.profileRemovedFromSaved ??
                                'Profile removed from saved'),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        gradient: _isBookmarked
                            ? AppGradients.trust
                            : AppGradients.gold,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isBookmarked
                                        ? Colors.green.shade600
                                        : Colors.amber.shade600)
                                    .withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      key: TourKeys.bookmarkButtonKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _isBookmarked ? Colors.white : theme.colorScheme.onSurface,
                            size: 22,
                          ),
                          SizedBox(height: 0.2.h),
                          Text(
                            _isBookmarked
                                ? (AppLocalizations.of(context)?.saved ?? 'SAVED')
                                : (AppLocalizations.of(context)?.save ?? 'SAVE'),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: _isBookmarked
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: AppTypography.labelMedium,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Interest button
              Expanded(
                flex: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onInterest(widget.profileData);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        gradient: AppGradients.love,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      key: TourKeys.interestButtonKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 1.5.w),
                          Text(
                            AppLocalizations.of(context)?.interest ?? 'INTEREST',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: AppTypography.bodySmall,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Message button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onMessage(widget.profileData);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.message,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(height: 0.2.h),
                          Text(AppLocalizations.of(context)?.message ?? 'MESSAGE',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: AppTypography.labelMedium,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Share button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onShare(widget.profileData);
                    },
                    child: Container(
                      key: TourKeys.shareButtonKey,
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(height: 0.2.h),
                          Text(AppLocalizations.of(context)?.share ?? 'SHARE',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: AppTypography.labelMedium,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
