import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/widgets/typing_indicator.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Track animated message keys so entrance animation only fires once
  final Set<String> _animatedMessageIds = {};

  // Track message reactions locally (MessageId -> emoji)
  final Map<String, String> _reactions = {};

  PlanType? _planType;
  int _bonusMessagesCount = 0;
  bool _isLoadingPlan = true;

  // 💡 Quick Icebreaker Suggestions
  static const List<String> _icebreakerChips = [
    '🙏 Namaste!',
    '💍 Interested in your profile',
    '📄 Shared my Biodata PDF',
    '👨‍👩‍👧 Can our families talk?',
    '📍 Where are you located?',
    '✨ Let\'s schedule a call',
  ];

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

  void _sendMessage([String? directText]) async {
    final text = (directText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    if (directText == null) {
      _messageController.clear();
    }
    HapticFeedback.lightImpact();

    final response = await _chatRepository.sendMessage(
      widget.conversation.id,
      text,
    );

    if (!response.isSuccess) {
      if (mounted) {
        if (directText == null && _messageController.text.isEmpty) {
          _messageController.text = text;
        }
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
      if (mounted && (_planType == null || _planType == PlanType.free || _planType == PlanType.basic)) {
        if (_bonusMessagesCount > 0) {
          setState(() {
            _bonusMessagesCount--;
          });
        }
      }
    }
  }

  void _handleDoubleTapReaction(String messageId) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_reactions[messageId] == '❤️') {
        _reactions.remove(messageId);
      } else {
        _reactions[messageId] = '❤️';
      }
    });
  }

  void _showMessageOptions(MessageModel message) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasNearBlack : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                // Reactions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['❤️', '👍', '🙏', '💍', '😊'].map((emoji) {
                    return TactilePressable(
                      onTap: () {
                        setState(() {
                          _reactions[message.id] = emoji;
                        });
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.surfaceDark30 : AppColors.slate100,
                        ),
                        child: Text(emoji, style: TextStyle(fontSize: AppTypography.headingLarge)),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 2.h),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: Text(AppLocalizations.of(context)?.copyMessage ?? 'Copy Message', style: const TextStyle(fontWeight: AppTypography.bold)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.messageText));
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: AppLocalizations.of(context)?.copiedToClipboard ?? 'Copied to clipboard');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMatrimonialAttachmentSheet(bool isDark) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final options = [
          {
            'icon': Icons.picture_as_pdf_rounded,
            'color': AppColors.crimsonRose,
            'title': 'Share My Biodata PDF',
            'subtitle': 'Directly attach and send your official BanjaraBio Biodata PDF card',
            'text': '📄 [BIODATA_PDF] Namaste! I have shared my official BanjaraBio Biodata PDF. Please review our family details.',
            'directSend': true,
          },
          {
            'icon': Icons.phone_forwarded_rounded,
            'color': AppColors.categoryCareerDark,
            'title': 'Propose Family Phone Call',
            'subtitle': 'Ask if elders/families can connect over a brief phone call',
            'text': '👨‍👩‍👧 Namaste! If you and your family are interested, can our elders have a brief phone conversation?',
            'directSend': false,
          },
          {
            'icon': Icons.auto_awesome_rounded,
            'color': AppColors.categoryFamilyDark,
            'title': 'Request Horoscope / Kundali',
            'subtitle': 'Politely request birth chart / Kundali match details',
            'text': '✨ Namaste! Could we exchange Kundali / Horoscope details for family matching?',
            'directSend': false,
          },
          {
            'icon': Icons.location_on_rounded,
            'color': AppColors.categoryLocationDark,
            'title': 'Share Native Place & Location',
            'subtitle': 'Share current city & native origin details',
            'text': '📍 We are currently based in our city. Would love to know more about your family’s location and native place.',
            'directSend': false,
          },
        ];

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasNearBlack : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  'Quick Matrimonial Actions',
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.black,
                    color: isDark ? Colors.white : AppColors.slate900,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 1.2.h),
                ...options.map((opt) {
                  final isDirect = opt['directSend'] == true;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TactilePressable(
                      onTap: () {
                        Navigator.pop(context);
                        if (isDirect) {
                          _sendMessage(opt['text'] as String);
                          Fluttertoast.showToast(msg: AppLocalizations.of(context)?.officialBiodataPdfShared ?? 'Official Biodata PDF Shared 📄');
                        } else {
                          _messageController.text = opt['text'] as String;
                          _messageController.selection = TextSelection.fromPosition(
                            TextPosition(offset: (opt['text'] as String).length),
                          );
                          HapticFeedback.lightImpact();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark30 : AppColors.slate50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white10 : AppColors.slate200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (opt['color'] as Color).withValues(alpha: AppColors.opacity15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 18),
                            ),
                            SizedBox(width: 3.5.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['title'] as String,
                                    style: TextStyle(
                                      fontWeight: AppTypography.extraBold,
                                      fontSize: AppTypography.bodySmall,
                                      color: isDark ? Colors.white : AppColors.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    opt['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: AppTypography.labelTiny,
                                      color: isDark ? Colors.white54 : AppColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
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
                child: messages.isEmpty
                    ? _buildBreakTheIceCard(theme, isDark)
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
                            child: _buildMessageBubble(theme, isDark, message, isMe),
                          );
                        },
                      ),
              ),
              _buildIcebreakerChips(theme, isDark),
              _buildMessageInput(theme, isDark, messages),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      titleSpacing: 0,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: AppColors.opacity8),
      backgroundColor: isDark ? AppColors.canvasCharcoal : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 19,
          color: isDark ? Colors.white : AppColors.slate900,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      title: TactilePressable(
        onTap: () {
          if (widget.conversation.otherParticipantId.isNotEmpty) {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(
              context,
              AppRoutes.profileDetail,
              arguments: widget.conversation.otherParticipantId,
            );
          }
        },
        pressedScale: 0.98,
        child: Row(
          children: [
            // Avatar with Online Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity40),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: widget.conversation.otherParticipantImageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.categoryLocation,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.canvasCharcoal : Colors.white,
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity60),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 2.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.conversation.otherParticipantName ?? 'User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: AppTypography.extraBold,
                            color: isDark ? Colors.white : AppColors.slate900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColors.categoryCareer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 1.5),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.categoryLocation,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)?.online ?? 'Online',
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.bold,
                          color: AppColors.categoryLocation,
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
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark ? Colors.white70 : AppColors.slate600,
            size: 20,
          ),
          color: isDark ? AppColors.surfaceDark28 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) {
            HapticFeedback.lightImpact();
            if (value == 'profile' && widget.conversation.otherParticipantId.isNotEmpty) {
              Navigator.pushNamed(
                context,
                AppRoutes.profileDetail,
                arguments: widget.conversation.otherParticipantId,
              );
            } else if (value == 'biodata') {
              Navigator.pushNamed(
                context,
                AppRoutes.biodataPdf,
                arguments: widget.conversation.otherParticipantId,
              );
            } else if (value == 'block') {
              Fluttertoast.showToast(msg: AppLocalizations.of(context)?.userBlockRequestSubmitted ?? 'User block request submitted');
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 18),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)?.viewProfile ?? 'View Profile', style: TextStyle(fontSize: AppTypography.bodyMedium, fontWeight: AppTypography.bold)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'biodata',
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.crimsonRose),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)?.viewBiodataPdf ?? 'View Biodata PDF', style: TextStyle(fontSize: AppTypography.bodyMedium, fontWeight: AppTypography.bold)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  const Icon(Icons.block_flipped, size: 18, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)?.blockUser ?? 'Block User', style: TextStyle(fontSize: AppTypography.bodyMedium, fontWeight: AppTypography.bold, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌟 BREAK THE ICE ZERO STATE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBreakTheIceCard(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.crimsonRose, AppColors.coralRed],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CustomImageWidget(
                    imageUrl: widget.conversation.otherParticipantImageUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Break the Ice with ${widget.conversation.otherParticipantName ?? "your match"}! 💍',
              style: TextStyle(
                fontSize: AppTypography.headingSmall,
                fontWeight: AppTypography.black,
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Start a respectful conversation. You can also share your Biodata PDF directly.',
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                color: isDark ? Colors.white60 : AppColors.slate500,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💬 MESSAGE BUBBLES WITH REACTIONS & GESTURES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMessageBubble(
    ThemeData theme,
    bool isDark,
    MessageModel message,
    bool isMe,
  ) {
    final reaction = _reactions[message.id];

    return GestureDetector(
      onDoubleTap: () => _handleDoubleTapReaction(message.id),
      onLongPress: () => _showMessageOptions(message),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: EdgeInsets.only(
                bottom: 1.h,
                left: isMe ? 18.w : 0,
                right: isMe ? 0 : 18.w,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [
                          AppColors.crimsonRose,
                          AppColors.wineRed,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe
                    ? null
                    : (isDark ? AppColors.surfaceDark28 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isMe
                    ? Border.all(
                        color: Colors.white.withValues(alpha: AppColors.opacity20),
                      )
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: AppColors.opacity8)
                            : AppColors.slate200,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? AppColors.crimsonRose.withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.messageText.replaceAll('[BIODATA_PDF] ', ''),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.slate900),
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.medium,
                      height: 1.35,
                    ),
                  ),
                  if (message.messageText.contains('Biodata PDF') ||
                      message.messageText.contains('[BIODATA_PDF]')) ...[
                    const SizedBox(height: 6),
                    _buildBiodataAttachmentCard(theme, isDark, isMe),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.75)
                              : (isDark ? Colors.white38 : Colors.black45),
                          fontSize: AppTypography.labelTiny,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildReadReceipt(theme, message),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Floating Emoji Reaction Badge
            if (reaction != null)
              Positioned(
                bottom: 2,
                right: isMe ? 4 : null,
                left: isMe ? null : 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark30 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppColors.opacity15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    reaction,
                    style: TextStyle(fontSize: AppTypography.bodySmall),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadReceipt(ThemeData theme, MessageModel message) {
    final isRead = message.isRead;
    if (isRead) {
      return const Icon(Icons.done_all_rounded, size: 13, color: AppColors.blue300);
    }
    return Icon(Icons.done_all_rounded, size: 13, color: Colors.white.withValues(alpha: 0.65));
  }

  Widget _buildBiodataAttachmentCard(ThemeData theme, bool isDark, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasDeepDark : AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.categoryAstro.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official Matrimonial Biodata',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.black,
                        color: isDark ? AppColors.goldTint200 : AppColors.amberDarkestText,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '॥ जय सेवालाल ॥ Verified Format',
                      style: TextStyle(
                        fontSize: AppTypography.labelTiny,
                        color: isDark ? Colors.white60 : AppColors.amberDark,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TactilePressable(
            onTap: () {
              HapticFeedback.lightImpact();
              final targetProfileId = isMe
                  ? SessionManager.instance.profileId
                  : widget.conversation.otherParticipantId;
              Navigator.pushNamed(
                context,
                AppRoutes.biodataPdf,
                arguments: targetProfileId,
              );
            },
            pressedScale: 0.96,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.crimsonRose, AppColors.wineRed],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    'View Biodata PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.labelSmall,
                      fontWeight: AppTypography.black,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💡 ICEBREAKER SUGGESTION CHIPS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildIcebreakerChips(ThemeData theme, bool isDark) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        itemCount: _icebreakerChips.length,
        itemBuilder: (context, index) {
          final chip = _icebreakerChips[index];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TactilePressable(
              onTap: () {
                _messageController.text = chip;
                _messageController.selection = TextSelection.fromPosition(
                  TextPosition(offset: chip.length),
                );
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.canvasNearBlack
                      : AppColors.slate100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: AppColors.opacity10)
                        : AppColors.slate300,
                  ),
                ),
                child: Text(
                  chip,
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.bold,
                    color: isDark ? Colors.white70 : AppColors.slate700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✍️ MESSAGE INPUT BAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMessageInput(
    ThemeData theme,
    bool isDark,
    List<MessageModel> messages,
  ) {
    if (_isLoadingPlan) {
      return Container(
        height: 60,
        color: isDark ? AppColors.canvasCharcoal : theme.colorScheme.surface,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final isFreePlan = _planType == null || _planType == PlanType.free || _planType == PlanType.basic;
    final myMessagesCount = messages.where((m) => m.senderId == SessionManager.instance.profileId).length;

    if (isFreePlan && myMessagesCount >= 1 && _bonusMessagesCount <= 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.canvasDeepDark : AppColors.primaryLight,
          border: Border(
            top: BorderSide(
              color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity20),
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Free plan allows 1 message. Upgrade to continue chatting.',
                style: TextStyle(
                  color: AppColors.crimsonRose,
                  fontWeight: AppTypography.extraBold,
                  fontSize: AppTypography.bodySmall,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.2.h),
              TactilePressable(
                onTap: () {
                  UpgradeDialog.showMessagingLimit(context);
                },
                pressedScale: 0.97,
                child: Container(
                  width: double.infinity,
                  height: 4.6.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.crimsonRose, AppColors.wineRed],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)?.upgradePlan ?? 'Upgrade Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasCharcoal : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quick Matrimonial Action Attachment Button
            TactilePressable(
              onTap: () => _showMatrimonialAttachmentSheet(isDark),
              pressedScale: 0.9,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark28 : AppColors.slate100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white10 : AppColors.slate200,
                  ),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: isDark ? AppColors.rose400 : AppColors.crimsonRose,
                  size: 22,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.canvasRichDark
                      : AppColors.slate100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: AppColors.opacity8)
                        : AppColors.slate200,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.slate900,
                    fontSize: AppTypography.bodySmall,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.typeAMessage ?? 'Type a message...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: AppTypography.bodySmall,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            TactilePressable(
              onTap: () => _sendMessage(),
              pressedScale: 0.88,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.crimsonRose, AppColors.wineRed],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 19,
                ),
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
