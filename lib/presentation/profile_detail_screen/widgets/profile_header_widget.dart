import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/presentation/home_screen/widgets/community_trusted_badge.dart';

/// Profile header widget displaying user's primary photo and basic information
/// Implements hero animation for smooth transition from profile cards
class ProfileHeaderWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final bool isPremium;
  final VoidCallback? onOptionsTap;

  const ProfileHeaderWidget({
    super.key,
    required this.profileData,
    required this.isPremium,
    this.onOptionsTap,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photos = widget.isPremium
        ? (widget.profileData['photos'] as List<dynamic>? ?? [])
        : (widget.profileData['photos'] as List<dynamic>? ?? [])
              .take(1)
              .toList();

    // Fallback if no photos at all
    final displayPhotos = photos.isEmpty ? [''] : photos;
    final isMatched = widget.profileData['isMatched'] as bool? ?? false;
    final isDisabled = widget.profileData['isDisabled'] as bool? ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w), // "Increase both side little bit" (Margins)
      width: 94.w, // Balanced width
      height: 60.h, // Sleeker reduced height
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32), // Full rounding like Home Tab
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand, // Matches Home Card exactly
          children: [
            // 📸 Foreground Image Slider: Exactly matching Home Tab logic
            PageView.builder(
              controller: _pageController,
              itemCount: displayPhotos.length,
              onPageChanged: (index) {
                setState(() => _currentPhotoIndex = index);
              },
              itemBuilder: (context, index) {
                final photoData = displayPhotos[index];
                final imageUrl = photoData is Map
                    ? photoData['url']?.toString() ?? ''
                    : photoData?.toString() ?? '';
                final semanticLabel = photoData is Map
                    ? photoData['semanticLabel']?.toString() ?? 'Photo'
                    : 'Profile photo';

                return GestureDetector(
                  onTap: () =>
                      _showFullScreenPhoto(context, imageUrl, semanticLabel),
                  child: Hero(
                    tag: 'profile_${widget.profileData['id']}_$index',
                    child: CustomImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover, // Matches Home Tab
                      alignment: Alignment.center, // Guaranteed Full Body framing
                      semanticLabel: semanticLabel,
                      isHighQuality: true,
                    ),
                  ),
                );
              },
            ),

            // 🌓 Beautiful Dark Gradient Overlay for Readability (Bottom only)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.4),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Photo indicators – animated dots
            if (displayPhotos.length > 1)
              Positioned(
                top: 2.h,
                left: 10.w,
                right: 10.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    displayPhotos.length,
                    (index) {
                      final isActive = _currentPhotoIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 0.8.w),
                        width: isActive ? 6.w : 2.w,
                        height: 0.6.h,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Animated Digital Scroll Indicator (Intuitive guiding for all users)
            Positioned(
              bottom: 1.2.h,
              left: 0,
              right: 0,
              child: const AnimatedScrollIndicator(),
            ),

            // 🏷️ Bottom Badges Row & Tags (Positioned away from top AppBar toolbar)
            Positioned(
              bottom: 4.h,
              left: 4.w,
              right: 4.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left-aligned Badges (Gender, ID, Matched)
                  Wrap(
                    spacing: 1.5.w,
                    runSpacing: 0.8.h,
                    children: [
                      _buildGenderBadge(
                        context,
                        widget.profileData['gender']?.toString() ?? 'Female',
                      ),
                      _buildGradientBadge(
                        widget.profileData['displayId']?.toString() ?? 'BB-UNKNOWN',
                        [const Color(0xFF607D8B), const Color(0xFF455A64)],
                        Icons.fingerprint,
                      ),
                      if (isMatched)
                        _buildGradientBadge('MATCHED', [
                          const Color(0xFFFF4B2B),
                          const Color(0xFFFF416C),
                        ], Icons.favorite),
                      if (isDisabled)
                        _buildGradientBadge(
                          AppLocalizations.of(context)?.disabledTagLabel ??
                              'DISABLED',
                          [Colors.indigo, Colors.deepPurpleAccent],
                          Icons.accessible_forward,
                        ),
                    ],
                  ),

                  // Right-aligned Badges (Premium)
                  if (widget.isPremium)
                    _buildGradientBadge('PREMIUM', [
                      const Color(0xFFFFD700),
                      const Color(0xFFFFA500),
                    ], Icons.star),
                ],
              ),
            ),

            if (widget.profileData['isCommunityTrusted'] as bool? ?? false)
              Positioned(
                top: 8.5.h,
                left: 4.w,
                child: const CommunityTrustedBadge(isLarge: true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderBadge(BuildContext context, String gender) {
    final isMale = gender.toLowerCase() == 'male';
    final label = isMale
        ? (AppLocalizations.of(context)?.male ?? 'MALE')
        : (AppLocalizations.of(context)?.female ?? 'FEMALE');

    final colors = isMale
        ? [const Color(0xFF2196F3), const Color(0xFF00BCD4)] // Blue/Cyan for Male
        : [const Color(0xFFE91E63), const Color(0xFFFF4081)]; // Pink/Accent for Female

    return _buildGradientBadge(label.toUpperCase(), colors, isMale ? Icons.male : Icons.female);
  }

  Widget _buildGradientBadge(String text, List<Color> colors, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
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
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 1.5.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: AppTypography.black,
              fontSize: AppTypography.bodySmall,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenPhoto(
    BuildContext context,
    String imageUrl,
    String semanticLabel,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.contain,
                    semanticLabel: semanticLabel,
                  ),
                ),
              ),
              Positioned(
                top: 4.h,
                left: 2.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
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

/// Advanced Animated Scroll Indicator that mimics a finger scrolling up
class AnimatedScrollIndicator extends StatefulWidget {
  const AnimatedScrollIndicator({super.key});

  @override
  State<AnimatedScrollIndicator> createState() => _AnimatedScrollIndicatorState();
}

class _AnimatedScrollIndicatorState extends State<AnimatedScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _slideAnimation = Tween<double>(begin: 8.0, end: -12.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Column(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 24,
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 0.2.h),
        Text(
          'Scroll up for more details',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: AppTypography.labelMedium,
            fontWeight: AppTypography.bold,
            letterSpacing: 0.2,
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
    );
  }
}
