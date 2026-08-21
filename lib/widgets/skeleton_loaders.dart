import 'package:banjarabio/core/constants/app_typography.dart';
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
//  Conversation List Skeleton  (matches Tab 0: 💬 Chat Tab)
// ─────────────────────────────────────────────────────────────
class ConversationListSkeleton extends StatelessWidget {
  final int itemCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ConversationListSkeleton({
    super.key,
    this.itemCount = 10,
    this.physics = const BouncingScrollPhysics(),
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final isFirst = index == 0;
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? (isFirst ? const Color(0xFF241B26) : const Color(0xFF191924))
                    : (isFirst ? const Color(0xFFFFF1F2) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFirst
                      ? const Color(0xFFBE123C).withValues(alpha: 0.35)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0)),
                  width: isFirst ? 1.4 : 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : (isFirst
                            ? const Color(0xFFBE123C).withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.03)),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with online ring
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 13.w,
                        height: 13.w,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFirst
                                ? const Color(0xFFBE123C).withValues(alpha: 0.4)
                                : (isDark ? Colors.white24 : Colors.black12),
                            width: 1.2,
                          ),
                        ),
                        child: ClipOval(
                          child: ShimmerWidget.circular(width: 13.w, height: 13.w),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF191924) : Colors.white,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 3.5.w),

                  // Conversation Metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerWidget.rectangular(
                              height: 14,
                              width: index == 1 ? 130 : 100,
                              shapeBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                            ),
                            const ShimmerWidget.rectangular(
                              height: 10,
                              width: 35,
                              shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ShimmerWidget.rectangular(
                          height: 11,
                          width: index == 2 ? 180 : 140,
                          shapeBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: (index == 0
                                        ? const Color(0xFFBE123C)
                                        : (index == 1
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B)))
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: (index == 0
                                              ? const Color(0xFFBE123C)
                                              : (index == 1
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFF59E0B)))
                                          .withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  ShimmerWidget.rectangular(
                                    height: 9,
                                    width: index == 0 ? 65 : (index == 1 ? 95 : 75),
                                    shapeBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared Profiles Screen Skeleton (Tabs 1, 2, 3: Received, Matched, Sent)
// ─────────────────────────────────────────────────────────────
enum SharedProfileSkeletonType { received, matched, sent }

class SharedProfilesScreenSkeleton extends StatelessWidget {
  final SharedProfileSkeletonType type;
  final int itemCount;
  final ScrollPhysics? physics;

  const SharedProfilesScreenSkeleton({
    super.key,
    this.type = SharedProfileSkeletonType.received,
    this.itemCount = 8,
    this.physics = const BouncingScrollPhysics(),
  });

  const SharedProfilesScreenSkeleton.received({
    super.key,
    this.itemCount = 8,
    this.physics = const BouncingScrollPhysics(),
  }) : type = SharedProfileSkeletonType.received;

  const SharedProfilesScreenSkeleton.matched({
    super.key,
    this.itemCount = 8,
    this.physics = const BouncingScrollPhysics(),
  }) : type = SharedProfileSkeletonType.matched;

  const SharedProfilesScreenSkeleton.sent({
    super.key,
    this.itemCount = 8,
    this.physics = const BouncingScrollPhysics(),
  }) : type = SharedProfileSkeletonType.sent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMatched = type == SharedProfileSkeletonType.matched;
    final isSent = type == SharedProfileSkeletonType.sent;

    return ListView.builder(
      physics: physics,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Item 0: Hero Highlights Banner Skeleton (matches _buildHeroHighlightsBanner)
        if (index == 0) {
          return _buildSkeletonHeroBanner(context, isDark, type);
        }

        // Dynamic Tab-Matching Border & Glow Colors
        final Color cardBorderColor;
        final Color cardShadowColor;
        if (isMatched) {
          // 💍 Matched Tab: Sacred 24K Gold
          cardBorderColor = const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.55 : 0.45);
          cardShadowColor = const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.09);
        } else if (isSent) {
          // 📤 Sent Tab: Royal Amethyst Purple
          cardBorderColor = const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.45 : 0.35);
          cardShadowColor = const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.18 : 0.07);
        } else {
          // 📥 Received Tab: Trust Sapphire Blue
          cardBorderColor = const Color(0xFF2563EB).withValues(alpha: isDark ? 0.45 : 0.35);
          cardShadowColor = const Color(0xFF2563EB).withValues(alpha: isDark ? 0.18 : 0.07);
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1B24) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: cardBorderColor,
              width: isMatched ? 1.5 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header: Share Metadata (To / From / Matched + Timestamp)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMatched
                              ? const Color(0xFFBE123C).withValues(alpha: 0.15)
                              : (isDark ? Colors.white10 : const Color(0xFFEFF6FF)),
                        ),
                        child: Icon(
                          isMatched
                              ? Icons.favorite_rounded
                              : (isSent
                                  ? Icons.arrow_outward_rounded
                                  : Icons.call_received_rounded),
                          size: 13,
                          color: isMatched
                              ? const Color(0xFFBE123C)
                              : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.rectangular(
                              height: 12,
                              width: isMatched ? 110 : (isSent ? 130 : 120),
                              shapeBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                            ),
                            const SizedBox(height: 4),
                            const ShimmerWidget.rectangular(
                              height: 9,
                              width: 70,
                              shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const ShimmerWidget.rectangular(
                          height: 9,
                          width: 42,
                          shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Full Width Image Media with Badges & Gradient Overlay (24.h)
                Stack(
                  children: [
                    ShimmerWidget.rectangular(
                      height: 24.h,
                    ),
                    // High-contrast Bottom Gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 10.h,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Verified Badge (Top Left)
                    Positioned(
                      top: 1.2.h,
                      left: 3.w,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: Color(0xFF3B82F6), size: 12),
                            const SizedBox(width: 3.5),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.extraBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Matched / Status Badge (Top Right)
                    if (isMatched)
                      Positioned(
                        top: 1.2.h,
                        right: 3.w,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_rounded, color: Colors.white, size: 11),
                              const SizedBox(width: 4),
                              Text(
                                'MATCHED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTypography.labelTiny,
                                  fontWeight: AppTypography.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isSent)
                      Positioned(
                        top: 1.2.h,
                        right: 3.w,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule_rounded, color: Colors.white, size: 11),
                              const SizedBox(width: 4),
                              Text(
                                'PENDING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTypography.labelTiny,
                                  fontWeight: AppTypography.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Name & Age Overlay at Bottom
                    Positioned(
                      bottom: 1.2.h,
                      left: 4.w,
                      right: 4.w,
                      child: const Row(
                        children: [
                          ShimmerWidget.rectangular(
                            height: 15,
                            width: 140,
                            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 3. Detail Section: Micro-tag Pills
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 0.8.h,
                        children: [
                          _buildSkeletonChip(context, isDark, Icons.school_rounded, 70),
                          _buildSkeletonChip(context, isDark, Icons.work_outline_rounded, 80),
                          _buildSkeletonChip(context, isDark, Icons.straighten_rounded, 55),
                          _buildSkeletonChip(context, isDark, Icons.favorite_outline_rounded, 65),
                        ],
                      ),
                    ],
                  ),
                ),

                // 4. Modern Floating Action Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF14141C)
                        : const Color(0xFFFAFAFC),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isMatched) ...[
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  'Say Hi 👋',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTypography.bodySmall,
                                    fontWeight: AppTypography.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF242430) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFBE123C).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.description_outlined, color: Color(0xFFBE123C), size: 14),
                                SizedBox(width: 4),
                                ShimmerWidget.rectangular(
                                  height: 10,
                                  width: 45,
                                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (isSent) ...[
                        Expanded(
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF242430) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share_outlined, color: Color(0xFF2563EB), size: 14),
                                SizedBox(width: 6),
                                ShimmerWidget.rectangular(
                                  height: 10,
                                  width: 50,
                                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF242430) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 14),
                                SizedBox(width: 6),
                                ShimmerWidget.rectangular(
                                  height: 10,
                                  width: 55,
                                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Received: Decline + Accept & Connect
                        Expanded(
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF242430) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 15),
                                SizedBox(width: 6),
                                ShimmerWidget.rectangular(
                                  height: 10,
                                  width: 40,
                                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Accept & Connect',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTypography.labelSmall,
                                    fontWeight: AppTypography.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonHeroBanner(BuildContext context, bool isDark, SharedProfileSkeletonType type) {
    final Color primaryColor;
    final List<Color> gradientColors;
    final IconData iconData;
    final double titleWidth;

    if (type == SharedProfileSkeletonType.matched) {
      primaryColor = const Color(0xFFF59E0B);
      gradientColors = isDark
          ? const [Color(0xFF3B1E05), Color(0xFF1E1002)]
          : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)];
      iconData = Icons.favorite_rounded;
      titleWidth = 140;
    } else if (type == SharedProfileSkeletonType.received) {
      primaryColor = const Color(0xFF2563EB);
      gradientColors = isDark
          ? const [Color(0xFF172554), Color(0xFF0F172A)]
          : const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)];
      iconData = Icons.inbox_rounded;
      titleWidth = 160;
    } else {
      primaryColor = const Color(0xFF7C3AED);
      gradientColors = isDark
          ? const [Color(0xFF2E1065), Color(0xFF1E1B4B)]
          : const [Color(0xFFFAF5FF), Color(0xFFF3E8FF)];
      iconData = Icons.send_rounded;
      titleWidth = 150;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
            ),
            child: Icon(
              iconData,
              color: primaryColor,
              size: 18,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerWidget.rectangular(
                  height: 13,
                  width: titleWidth,
                  shapeBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                ),
                const SizedBox(height: 5),
                const ShimmerWidget.rectangular(
                  height: 10,
                  width: 220,
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSkeletonChip(BuildContext context, bool isDark, IconData icon, double width) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22222E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? Colors.white38 : const Color(0xFF64748B)),
          const SizedBox(width: 5),
          ShimmerWidget.rectangular(
            height: 9,
            width: width,
            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          ),
        ],
      ),
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
//  Trust Score Screen Skeleton  (matches score card + discount card + verifications)
// ─────────────────────────────────────────────────────────────
class TrustScoreSkeleton extends StatelessWidget {
  const TrustScoreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Score Card Skeleton ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
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
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget.rectangular(
                      height: 2.4.h,
                      width: 38.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    ShimmerWidget.rectangular(
                      height: 3.2.h,
                      width: 28.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.5.h),
                // Score Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ShimmerWidget.circular(width: 30.w, height: 30.w),
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShimmerWidget.rectangular(
                            height: 2.5.h,
                            width: 12.w,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          ShimmerWidget.rectangular(
                            height: 1.2.h,
                            width: 8.w,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.2.h),
                // Nudge Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const ShimmerWidget.circular(width: 28, height: 28),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.rectangular(
                              height: 1.2.h,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            ShimmerWidget.rectangular(
                              height: 1.2.h,
                              width: 50.w,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // ── 2. Discounts & Perks Card Skeleton ──
          Container(
            padding: EdgeInsets.all(4.5.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ShimmerWidget.circular(width: 28, height: 28),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ShimmerWidget.rectangular(
                        height: 2.2.h,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    ShimmerWidget.rectangular(
                      height: 2.8.h,
                      width: 24.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                ShimmerWidget.rectangular(
                  height: 1.3.h,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 0.6.h),
                ShimmerWidget.rectangular(
                  height: 1.3.h,
                  width: 65.w,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    ShimmerWidget.rectangular(
                      height: 2.6.h,
                      width: 26.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    ShimmerWidget.rectangular(
                      height: 2.6.h,
                      width: 22.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    ShimmerWidget.rectangular(
                      height: 2.6.h,
                      width: 26.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.5.h),

          // ── 3. Checklist Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget.rectangular(
                height: 2.2.h,
                width: 44.w,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              ShimmerWidget.rectangular(
                height: 2.4.h,
                width: 22.w,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.2.h),

          // ── 4. Verification Items (List of 8) ──
          ...List.generate(
            6,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 1.2.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  const ShimmerWidget.circular(width: 44, height: 44),
                  SizedBox(width: 3.5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget.rectangular(
                          height: 1.8.h,
                          width: 38.w,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        ShimmerWidget.rectangular(
                          height: 1.2.h,
                          width: 22.w,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ShimmerWidget.rectangular(
                    height: 3.2.h,
                    width: 18.w,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
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

// ─────────────────────────────────────────────────────────────
//  Subscription Skeleton (matches SubscriptionScreen layout)
// ─────────────────────────────────────────────────────────────
class SubscriptionSkeleton extends StatelessWidget {
  const SubscriptionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Current Plan / Header Card Skeleton
          Container(
            padding: EdgeInsets.all(4.5.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ShimmerWidget.circular(width: 26, height: 26),
                    SizedBox(width: 2.5.w),
                    ShimmerWidget.rectangular(
                      height: 1.8.h,
                      width: 30.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.8.h),
                ShimmerWidget.rectangular(
                  height: 3.2.h,
                  width: 50.w,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(height: 1.h),
                ShimmerWidget.rectangular(
                  height: 1.6.h,
                  width: 35.w,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // 2. Coupon Box Skeleton
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerWidget.rectangular(
                    height: 5.h,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                ShimmerWidget.rectangular(
                  height: 5.h,
                  width: 20.w,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // 3. Tab Bar Skeleton
          ShimmerWidget.rectangular(
            height: 5.5.h,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          SizedBox(height: 2.h),

          // 4. Trust Score Discount Bar Skeleton
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget.rectangular(
                      height: 2.h,
                      width: 40.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    ShimmerWidget.rectangular(
                      height: 2.2.h,
                      width: 25.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                ShimmerWidget.rectangular(
                  height: 1.h,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.5.h),

          // 5. Plan Cards (2 cards)
          ...List.generate(2, (index) {
            return Container(
              margin: EdgeInsets.only(bottom: 2.5.h),
              padding: EdgeInsets.all(4.5.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ShimmerWidget.rectangular(
                      height: 2.8.h,
                      width: 40.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Center(
                    child: ShimmerWidget.rectangular(
                      height: 3.5.h,
                      width: 30.w,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ...List.generate(3, (fIndex) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.2.h),
                      child: Row(
                        children: [
                          const ShimmerWidget.circular(width: 16, height: 16),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ShimmerWidget.rectangular(
                              height: 1.6.h,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 1.5.h),
                  ShimmerWidget.rectangular(
                    height: 5.2.h,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

