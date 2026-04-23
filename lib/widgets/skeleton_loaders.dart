import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/widgets/shimmer_widget.dart';

/// Additional skeleton loading placeholders for screens that still use
/// plain CircularProgressIndicator. These complement the existing
/// ProfileCardSkeleton and ProfileDetailSkeleton in shimmer_widget.dart.

// ─────────────────────────────────────────────────────────────
//  Chat Bubble Skeleton  (matches _buildMessageBubble layout)
// ─────────────────────────────────────────────────────────────
class ChatBubbleSkeleton extends StatelessWidget {
  const ChatBubbleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: List.generate(6, (index) {
          final isMe = index.isEven;
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(
                bottom: 1.5.h,
                left: isMe ? 25.w : 0,
                right: isMe ? 0 : 25.w,
              ),
              child: ShimmerWidget.rectangular(
                height: isMe ? 5.h : 7.h,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 20),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Conversation List Skeleton  (matches conversation list items)
// ─────────────────────────────────────────────────────────────
class ConversationListSkeleton extends StatelessWidget {
  const ConversationListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              // Avatar circle
              ShimmerWidget.circular(
                width: 12.w,
                height: 12.w,
              ),
              SizedBox(width: 3.w),
              // Name and last message lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.rectangular(height: 2.h, width: 40.w),
                    SizedBox(height: 0.8.h),
                    ShimmerWidget.rectangular(height: 1.5.h, width: 60.w),
                  ],
                ),
              ),
              // Time placeholder
              ShimmerWidget.rectangular(height: 1.5.h, width: 10.w),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Filter Screen Skeleton  (matches filter layout)
// ─────────────────────────────────────────────────────────────
class FilterScreenSkeleton extends StatelessWidget {
  const FilterScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar skeleton
          ShimmerWidget.rectangular(height: 6.h, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          SizedBox(height: 3.h),
          // Section title
          ShimmerWidget.rectangular(height: 2.h, width: 25.w),
          SizedBox(height: 1.5.h),
          // Slider skeleton
          ShimmerWidget.rectangular(height: 4.h, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          SizedBox(height: 3.h),
          // Section title
          ShimmerWidget.rectangular(height: 2.h, width: 20.w),
          SizedBox(height: 1.5.h),
          // Chips row 1
          _buildChipRow(),
          SizedBox(height: 1.5.h),
          // Section title
          ShimmerWidget.rectangular(height: 2.h, width: 22.w),
          SizedBox(height: 1.5.h),
          // Chips row 2
          _buildChipRow(),
          SizedBox(height: 3.h),
          // Section title
          ShimmerWidget.rectangular(height: 2.h, width: 28.w),
          SizedBox(height: 1.5.h),
          // Chips row 3
          _buildChipRow(),
        ],
      ),
    );
  }

  Widget _buildChipRow() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.5.h,
      children: List.generate(
        4,
        (index) => ShimmerWidget.rectangular(
          height: 4.h,
          width: (18 + index * 3).w,
          shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Trust Score Screen Skeleton  (matches score card + steps)
// ─────────────────────────────────────────────────────────────
class TrustScoreSkeleton extends StatelessWidget {
  const TrustScoreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Score circle
          Center(
            child: ShimmerWidget.circular(width: 30.w, height: 30.w),
          ),
          SizedBox(height: 2.h),
          // Score label
          Center(
            child: ShimmerWidget.rectangular(height: 2.5.h, width: 35.w),
          ),
          SizedBox(height: 1.h),
          Center(
            child: ShimmerWidget.rectangular(height: 1.5.h, width: 50.w),
          ),
          SizedBox(height: 4.h),
          // Step cards
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: ShimmerWidget.rectangular(
                height: 8.h,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Generic List Skeleton  (for referral, admin, etc.)
// ─────────────────────────────────────────────────────────────
class GenericListSkeleton extends StatelessWidget {
  final int itemCount;
  const GenericListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: ShimmerWidget.rectangular(
            height: 9.h,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}
