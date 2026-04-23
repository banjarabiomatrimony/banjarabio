import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/trust_score_badge.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/core/services/scroll_velocity_service.dart';

class ProfileCardWidget extends StatefulWidget {
  final ProfileModel profile;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final Function(ProfileModel) onShare;
  final Function(ProfileModel) onInterest;

  final bool useHero;

  const ProfileCardWidget({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
    required this.onInterest,
    this.useHero = false,
  });

  @override
  State<ProfileCardWidget> createState() => _ProfileCardWidgetState();
}

class _ProfileCardWidgetState extends State<ProfileCardWidget> {
  late bool _isBookmarked;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.profile.isBookmarked;
  }

  @override
  void didUpdateWidget(covariant ProfileCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.isBookmarked != oldWidget.profile.isBookmarked) {
      _isBookmarked = widget.profile.isBookmarked;
    }
  }

  void _handleBookmark() {
    if (kDebugMode) {
      debugPrint('[BOOKMARK] ProfileCardWidget > User tapped ${_isBookmarked ? "Saved" : "Save"} on card (profile ${widget.profile.id}) > delegating to parent');
    }
    HapticFeedback.lightImpact();
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    Future.microtask(() => widget.onBookmark());
  }

  bool _isGhosting = false;
  void _onVelocityChanged() {
    final hyper = ScrollVelocityService.instance.isHyperScrolling;
    if (hyper != _isGhosting) {
      setState(() => _isGhosting = hyper);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScrollVelocityService.instance.removeListener(_onVelocityChanged);
    ScrollVelocityService.instance.addListener(_onVelocityChanged);
  }

  @override
  void dispose() {
    ScrollVelocityService.instance.removeListener(_onVelocityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🧬 PERFORMANCE: Convert to display map lazily ONLY when building the card.
    // This avoids heavy serialization of the whole list at once.
    final displayMap = widget.profile.toDisplayMap();
    final theme = Theme.of(context);
    
    final isPremium = widget.profile.isPremium;
    final isMatched = widget.profile.isMatched;
    final photos = displayMap['photos'] as List? ?? [];
    final primaryPhoto = photos.isNotEmpty
        ? photos[0] as Map<String, dynamic>
        : null;

    final name = widget.profile.fullName;
    final age = widget.profile.age.toString();
    final location = widget.profile.locationExcludingVillage;
    
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Slidable(
        key: ValueKey('slidable_${widget.profile.id}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _handleBookmark(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              label: _isBookmarked
                  ? (AppLocalizations.of(context)?.saved ?? 'Saved')
                  : (AppLocalizations.of(context)?.save ?? 'Save'),
            ),
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.lightImpact();
                Future.microtask(() => widget.onShare(widget.profile));
              },
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              icon: Icons.share,
              label: AppLocalizations.of(context)?.share ?? 'Share',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Future.microtask(() => widget.onTap());
          },
          child: Container(
            // Auto size to parent bounds (68.h from SliverGrid)
            margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h), // 0 gap
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: isMatched
                    ? AppGradients.romance.colors.first.withValues(alpha: 0.4)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: isMatched ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23), // Slightly less than container to fit inside border
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 📸 Full-bleed Hero image
                  // 🧬 EXTREME SCALE: Ghosting Mode (Skip PageView during fast scrolls)
                  _isGhosting || photos.length <= 1
                      ? CustomImageWidget(
                          imageUrl: primaryPhoto?['url'] as String?,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          semanticLabel: primaryPhoto?['semanticLabel'] as String?,
                        )
                      : PageView.builder(
                          onPageChanged: (index) {
                            setState(() => _currentPhotoIndex = index);
                          },
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final photo = photos[index] as Map<String, dynamic>;
                            final child = CustomImageWidget(
                              imageUrl: photo['url'] as String?,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              isHighQuality: true,
                              semanticLabel: photo['semanticLabel'] as String?,
                            );
                            if (!widget.useHero) return child;
                            return Hero(
                              tag: 'profile_${widget.profile.id}_$index',
                              child: child,
                            );
                          },
                        ),

                  // 🌓 Beautiful Dark Gradient Overlay for Text Readability
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black45,
                              Colors.black87,
                            ],
                            stops: [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 🔵 Photo dot indicators
                  if (photos.length > 1)
                    Positioned(
                      top: 1.5.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (index) {
                            final isActive = index == _currentPhotoIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: isActive ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // 🏅 Badges
                  if (isMatched)
                    Positioned(
                      top: 2.h,
                      left: 4.w,
                      child: _buildGradientBadge(
                        context,
                        AppLocalizations.of(context)?.matched ?? 'MATCHED',
                        AppGradients.romance.colors,
                        Icons.favorite,
                      ),
                    ),
                  if (isPremium)
                    Positioned(
                      top: 7.h,
                      right: 4.w,
                      child: _buildGradientBadge(
                        context,
                        AppLocalizations.of(context)?.premium ?? 'PREMIUM',
                        AppGradients.gold.colors,
                        Icons.star,
                      ),
                    ),
                  if (widget.profile.isDisabled)
                    Positioned(
                      top: 7.h,
                      left: 4.w,
                      child: _buildGradientBadge(
                        context,
                        AppLocalizations.of(context)?.disabledTagLabel ??
                            'DISABLED',
                        [Colors.indigo, Colors.deepPurpleAccent],
                        Icons.accessible_forward,
                      ),
                    ),

                  // 🏷️ Gender Badge: Consistency with Profile Detail Screen
                  Positioned(
                    top: 2.h,
                    right: 4.w,
                    child: _buildGenderBadge(
                      context,
                      widget.profile.gender,
                    ),
                  ),

                  // 📄 Info & Action Pane (Glassmorphism removed for memory performance)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.h),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.black.withValues(alpha: 0.65)
                            : Colors.black.withValues(alpha: 0.45),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Line 1: Name, Age, Trust Score
                          Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$name, ',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 21.sp,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextSpan(
                                        text: age,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 24.sp,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isPremium)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.verified, color: Colors.blueAccent, size: 20),
                                ),
                                TrustScoreBadge(
                                  score: widget.profile.trustScore,
                                  isGhosting: _isGhosting,
                                ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),

                          // Line 2: Location
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14.sp, color: Colors.white70),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  location,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.5.h),

                          // Line 3: Actions & Info (Symmetric)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQuickActionButton(
                                context: context,
                                icon: Icons.share_rounded,
                                color: Colors.white.withValues(alpha: 0.2),
                                onTap: () => widget.onShare(widget.profile),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: _buildQuickActionButton(
                                  context: context,
                                  icon: Icons.favorite_rounded,
                                  gradient: AppGradients.love,
                                  label: AppLocalizations.of(context)?.interest ?? 'INTEREST',
                                  isExpanded: true,
                                  onTap: () => widget.onInterest(widget.profile),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              _buildQuickActionButton(
                                context: context,
                                icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: _isBookmarked 
                                    ? Colors.amber.withValues(alpha: 0.9)
                                    : Colors.white.withValues(alpha: 0.2),
                                onTap: _handleBookmark,
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),

                          // Line 4: Info Row (Education & Job - Glass chips)
                          Row(
                            children: [
                              Expanded(
                                child: _buildGlassChip(context, 'school', displayMap['education']?.toString() ?? (AppLocalizations.of(context)?.notAvailable ?? 'N/A')),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: _buildGlassChip(context, 'work', displayMap['job']?.toString() ?? (AppLocalizations.of(context)?.notAvailable ?? 'N/A')),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),

                          // Line 5: New Info Row (Marital Status & Gotra/Surname - Centered)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.profile.maritalStatus} • ${widget.profile.gotra ?? widget.profile.surname} • ID: ${widget.profile.displayId}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ], // matching Stack
              ),
            ), // matching ClipRRect
            // Container auto-sizes without height restriction
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    Color? color,
    Gradient? gradient,
    Color iconColor = Colors.white,
    String? label,
    bool isExpanded = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(1.2.h),
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
            boxShadow: gradient != null
                ? [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              if (label != null) ...[
                SizedBox(width: 1.5.w),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: iconColor == Colors.white ? Colors.white : iconColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.sp,
                          letterSpacing: 0.5,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassChip(BuildContext context, String icon, String text) {
    final theme = Theme.of(context);
    return Container(
      // width removed to allow Row/Expanded to control size
      height: 4.8.h, // Matching typical action button height
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: 14,
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderBadge(BuildContext context, String genderString) {
    final isMale = genderString.toLowerCase() == 'male';
    final label = isMale
        ? (AppLocalizations.of(context)?.male ?? 'MALE')
        : (AppLocalizations.of(context)?.female ?? 'FEMALE');

    final colors = isMale
        ? [const Color(0xFF2196F3), const Color(0xFF00BCD4)] // Blue/Cyan for Male
        : [const Color(0xFFE91E63), const Color(0xFFFF4081)]; // Pink/Accent for Female

    return _buildGradientBadge(
      context,
      label.toUpperCase(),
      colors,
      isMale ? Icons.male : Icons.female,
    );
  }

  Widget _buildGradientBadge(
    BuildContext context,
    String text,
    List<Color> colors,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 1.5.w),
          Text(text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              fontSize: 11.sp, // Increased badge font size
            ),
          ),
        ],
      ),
    );
  }
}
