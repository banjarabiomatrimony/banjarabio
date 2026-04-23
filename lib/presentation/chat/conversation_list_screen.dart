import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/presentation/chat/chat_screen.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final ShareRepository _shareRepository = ShareRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.messages ?? 'MESSAGES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // 1. New Matches Section (Horizontal)
          SliverToBoxAdapter(child: _buildNewMatchesSection()),

          // 2. Who Viewed Me Short-cut Card
          SliverToBoxAdapter(child: _buildWhoViewedMeCard()),

          // 3. Conversation List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 1.h),
              child: Text(AppLocalizations.of(context)?.recentConversations ?? 'Recent Conversations',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          // 4. Main Conversation List or Empty State
          StreamBuilder<List<ConversationModel>>(
            stream: _chatRepository.getConversationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: ConversationListSkeleton(),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final conversations = snapshot.data ?? [];

              if (conversations.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildPremiumEmptyState(),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final conversation = conversations[index];
                  return RepaintBoundary(
                    child: Column(
                      children: [
                        _buildConversationTile(conversation),
                        if (index < conversations.length - 1)
                          Divider(
                            indent: 20.w,
                            endIndent: 5.w,
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                      ],
                    ),
                  );
                }, childCount: conversations.length),
              );
            },
          ),

          // Extra padding at bottom for FAB or just breathing room
          SliverToBoxAdapter(child: SizedBox(height: 5.h)),
        ],
      ),
    );
  }

  Widget _buildNewMatchesSection() {
    return FutureBuilder<BackendResponse<List<ProfileShare>>>(
      future: _shareRepository.getMatchedProfiles(limit: 10),
      builder: (context, snapshot) {
        final matches = snapshot.data?.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)?.newMatches ?? 'New Matches',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (matches.isNotEmpty)
                    Text(AppLocalizations.of(context)?.viewAll ?? 'View All',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 12.h,
              child: matches.isEmpty
                  ? _buildMatchPlaceholder()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return RepaintBoundary(child: _buildMatchItem(match));
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchPlaceholder() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 18.w,
          margin: EdgeInsets.only(right: 3.w),
          child: Column(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[200]!, width: 2),
                ),
                child: Icon(Icons.add_rounded, color: Colors.grey[400]),
              ),
              SizedBox(height: 1.h),
              Container(
                width: 12.w,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchItem(ProfileShare match) {
    return GestureDetector(
      onTap: () {
        // Find if conversation exists or start new
        // For now, navigate to detail
        Navigator.pushNamed(
          context,
          AppRoutes.profileDetail,
          arguments: match.sharedProfileId,
        );
      },
      child: Container(
        width: 18.w,
        margin: EdgeInsets.only(right: 3.w),
        child: Column(
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: match.sharedProfileImage ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              match.sharedProfileName?.split(' ').first ?? AppLocalizations.of(context)?.newLabel ?? 'New',
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhoViewedMeCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF25376E),
            const Color(0xFF25376E).withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25376E).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.whoViewedMe),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.visibility_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)?.profileInsights ?? 'Profile Insights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(AppLocalizations.of(context)?.checkWhoIsLookingAtYourProfile ?? 'Check who is looking at your profile',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conversation) {
    final int unreadCount =
        conversation.participantOneId == SessionManager.instance.profileId
        ? conversation.unreadCountOne
        : conversation.unreadCountTwo;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
      leading: Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: CustomImageWidget(
            imageUrl: conversation.otherParticipantImageUrl ?? '',
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        conversation.otherParticipantName ?? AppLocalizations.of(context)?.userLabel ?? 'User',
        style: TextStyle(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
      subtitle: Text(
        conversation.lastMessageText ?? AppLocalizations.of(context)?.sayHelloLabel ?? 'Say hello!',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unreadCount > 0 ? Colors.black87 : Colors.grey,
          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
          fontSize: 11.sp,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(conversation.lastMessageAt),
            style: TextStyle(
              fontSize: 9.sp,
              color: unreadCount > 0
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumEmptyState() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 50.sp,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: 3.h),
          Text(AppLocalizations.of(context)?.startAConversation ?? 'Start a Conversation',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(AppLocalizations.of(context)?.yourMatchesWillAppearHereOnceYouBothExpr ?? 'Your matches will appear here once you both express interest. Keep sharing profiles to find your perfect match!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to Home/Discovery
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(AppLocalizations.of(context)?.browseProfiles ?? 'Browse Profiles',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1]; // We should localize these later or use intl package
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
