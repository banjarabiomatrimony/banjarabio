import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A customizable Shimmer widget for high-fidelity loading states
class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  });

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 🚨 ZERO-GPU FIX: Removed Shimmer.fromColors because it uses
    // an infinite 60fps AnimationController. When loading the home screen
    // grid of 30 profiles, 30 concurrent shimmer widgets caused a massive
    // gralloc4 GPU storm that starved the main thread and triggered an ANR
    // Signal 3 kill on memory-constrained (2GB) devices.
    // We now render a beautiful, static placeholder that uses 0% GPU.
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        shape: shapeBorder,
      ),
    );
  }
}

/// A pre-built skeleton for Profile Cards
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 60.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed image placeholder
            const ShimmerWidget.rectangular(
              height: double.infinity,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(23)),
              ),
            ),

            // Top Badges Row
            Positioned(
              top: 1.6.h,
              left: 4.w,
              right: 4.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ShimmerWidget.rectangular(
                      height: 3.2.h,
                      width: 80,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const ShimmerWidget.circular(width: 32, height: 32),
                ],
              ),
            ),

            // Bottom Gradient Content Area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name & Age Shimmer
                    FractionallySizedBox(
                      widthFactor: 0.65,
                      child: ShimmerWidget.rectangular(
                        height: 2.8.h,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    // Occupation & Location Shimmer
                    FractionallySizedBox(
                      widthFactor: 0.45,
                      child: ShimmerWidget.rectangular(
                        height: 1.6.h,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.2.h),
                    // Detail Chips Row
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerWidget.rectangular(
                            height: 2.6.h,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ShimmerWidget.rectangular(
                            height: 2.6.h,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.6.h),
                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerWidget.rectangular(
                            height: 4.6.h,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        const ShimmerWidget.circular(width: 44, height: 44),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pre-built skeleton for Profile Details
class ProfileDetailSkeleton extends StatelessWidget {
  const ProfileDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ShimmerWidget.rectangular(height: 60.h), // Matching 60.h header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: ShimmerWidget.rectangular(height: 18.h),
                      ),
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: ShimmerWidget.rectangular(height: 25.h),
                      ),
                    ],
                  ),
                ),
                // Right Column
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: ShimmerWidget.rectangular(height: 22.h),
                      ),
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: ShimmerWidget.rectangular(height: 20.h),
                      ),
                      Padding(
                        padding: EdgeInsets.all(1.w),
                        child: ShimmerWidget.rectangular(height: 15.h),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
