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
    return Container(
      width: double.infinity,
      height: 62.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: ShimmerWidget.rectangular(
              height: double.infinity,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ), // Image area
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(height: 3.h, width: 50.w), // Name
                SizedBox(height: 1.h),
                ShimmerWidget.rectangular(
                  height: 2.h,
                  width: 35.w,
                ), // Subtitle
                SizedBox(height: 2.h),
                ShimmerWidget.rectangular(height: 5.h), // Details
              ],
            ),
          ),
          // Action row skeleton
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Center(
                    child: ShimmerWidget.rectangular(height: 2.h, width: 10.w),
                  ),
                ),
              ),
            ),
          ),
        ],
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
