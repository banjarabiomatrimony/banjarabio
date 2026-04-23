import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/widgets/typing_indicator.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Track animated message keys so entrance animation only fires once
  final Set<String> _animatedMessageIds = {};

  PlanType? _planType;
  int _bonusMessagesCount = 0;
  bool _isLoadingPlan = true;

  @override
  void initState() {
    super.initState();
    _chatRepository.markAsRead(widget.conversation.id);
    _loadPlanAndBonus();
  }

  Future<void> _loadPlanAndBonus() async {
    final futures = await Future.wait([
      SubscriptionRepository().getPlanType(),
      UsageRepository().getRemainingBonusMessages(),
    ]);

    final planRes = futures[0] as BackendResponse<PlanType>;
    final bonusRes = futures[1] as BackendResponse<int>;

    if (mounted) {
      setState(() {
        _planType = planRes.isSuccess ? planRes.data : PlanType.free;
        _bonusMessagesCount = bonusRes.isSuccess ? bonusRes.data : 0;
        _isLoadingPlan = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final response = await _chatRepository.sendMessage(
      widget.conversation.id,
      text,
    );

    if (!response.isSuccess) {
      if (mounted) {
        if (response.errorMessage.contains('FREE_LIMIT_REACHED')) {
          UpgradeDialog.showMessagingLimit(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)
                        ?.failedToSendMessage(response.errorMessage) ??
                    'Failed to send message: ${response.errorMessage}',
              ),
            ),
          );
        }
      }
    } else {
      // Message sent successfully. If we used a bonus, deduct locally to lock UI immediately.
      if (mounted && (_planType == null || _planType == PlanType.free || _planType == PlanType.basic)) {
        if (_bonusMessagesCount > 0) {
          setState(() {
            _bonusMessagesCount--;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: StreamBuilder<List<MessageModel>>(
        stream: _chatRepository.getMessagesStream(widget.conversation.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ChatBubbleSkeleton();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(context)
                        ?.errorWithLabel(snapshot.error.toString()) ??
                    'Error: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final messages = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const TypingIndicator();
                    }

                    final message = messages[index - 1];
                    final isMe = message.senderId ==
                        SessionManager.instance.profileId;

                    final isNew = !_animatedMessageIds.contains(message.id);
                    if (isNew) _animatedMessageIds.add(message.id);

                    return _AnimatedMessageBubble(
                      key: ValueKey(message.id),
                      animate: isNew,
                      child: _buildMessageBubble(theme, message, isMe),
                    );
                  },
                ),
              ),
              _buildMessageInput(theme, messages),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: widget.conversation.otherParticipantImageUrl ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.otherParticipantName ?? 'User',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(AppLocalizations.of(context)?.online ?? 'Online',
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }

  Widget _buildMessageBubble(
      ThemeData theme, MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 1.h,
          left: isMe ? 20.w : 0,
          right: isMe ? 0 : 20.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          gradient: isMe ? AppGradients.primary : null,
          color: isMe ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: (isMe
                      ? theme.colorScheme.primary
                      : theme.colorScheme.shadow)
                  .withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.messageText,
              style: TextStyle(
                color:
                    isMe ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 7.sp,
                  ),
                ),
                // Read receipts for sent messages
                if (isMe) ...[
                  SizedBox(width: 1.w),
                  _buildReadReceipt(theme, message),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadReceipt(ThemeData theme, MessageModel message) {
    final isRead = message.isRead;

    if (isRead) {
      // Double blue ticks — read
      return const Icon(Icons.done_all, size: 12, color: Colors.lightBlueAccent);
    }
    // Double grey ticks — delivered but unread
    return Icon(Icons.done_all,
        size: 12, color: Colors.white.withValues(alpha: 0.6));
  }

  Widget _buildMessageInput(ThemeData theme, List<MessageModel> messages) {
    if (_isLoadingPlan) {
      return Container(
        height: 60,
        color: theme.colorScheme.surface,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final isFreePlan = _planType == null || _planType == PlanType.free || _planType == PlanType.basic;
    
    // Count my sent messages
    final myMessagesCount = messages.where((m) => m.senderId == SessionManager.instance.profileId).length;

    // Only lock them out if they are on a free plan, have sent 1 message, AND have 0 bonus messages left.
    if (isFreePlan && myMessagesCount >= 1 && _bonusMessagesCount <= 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Free plan allows 1 message. Upgrade to continue chatting.',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.5.h),
              ElevatedButton(
                onPressed: () {
                  UpgradeDialog.showMessagingLimit(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Upgrade Plan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.typeAMessage ?? 'Type a message...',
                    hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: EdgeInsets.all(1.5.h),
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animates a message bubble sliding up and fading in on first appearance.
class _AnimatedMessageBubble extends StatefulWidget {
  final Widget child;
  final bool animate;

  const _AnimatedMessageBubble({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<_AnimatedMessageBubble> createState() =>
      _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
