import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/presentation/chat/chat_screen.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const ConversationListScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _hintTimer;
  int _currentHintIndex = 0;
  String _searchQuery = '';
  String _activeFilter = 'All'; // 'All', 'Unread'
  final Set<String> _pinnedIds = {};
  List<ProfileShare> _cachedMatches = [];

  static const List<String> _animatedHints = [
    'Search "Pooja Rathod"...',
    'Search "Doctor", "Engineer"...',
    'Search "Pune", "Hyderabad"...',
    'Search "Rathod", "Chavan", "Pawar"...',
    'Search by chat message or name...',
  ];

  @override
  void initState() {
    super.initState();
    _startHintAnimation();
    _loadMutualMatches();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadMutualMatches() async {
    try {
      final res = await ShareRepository().getMatchedProfiles(limit: 10);
      if (mounted && res.isSuccess) {
        setState(() {
          _cachedMatches = res.data;
        });
      }
    } catch (_) {}
  }

  void _startHintAnimation() {
    _hintTimer = Timer.periodic(const Duration(milliseconds: 2800), (timer) {
      if (mounted && _searchQuery.isEmpty && !_searchFocusNode.hasFocus) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _animatedHints.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isEmbedded
          ? null
          : CustomAppBar(
              title: AppLocalizations.of(context)?.messages ?? 'Messages',
              automaticallyImplyLeading: false,
            ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            // 1. Search & Filter Bar (Preserved for future on-demand use)
            // SliverToBoxAdapter(
            //   child: _buildSearchBar(theme, isDark),
            // ),

            // 2. Main Stream delivering Live Conversations & Filtered List
            StreamBuilder<List<ConversationModel>>(
              stream: _chatRepository.getConversationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverMainAxisGroup(
                    slivers: [
                      // Filter chips rail visible even during loading
                      SliverToBoxAdapter(
                        child: _buildFilterChips(
                          theme,
                          isDark,
                        ),
                      ),
                      // Recent Conversations Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5.w, 1.2.h, 5.w, 0.8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.recentConversations ?? 'Recent Conversations',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.black,
                                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Live ⚡',
                                  style: TextStyle(
                                    fontSize: AppTypography.labelTiny,
                                    fontWeight: AppTypography.bold,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: ConversationListSkeleton(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                }

                final rawConversations = snapshot.data ?? [];
                var conversations = List<ConversationModel>.from(rawConversations);

                // Apply dynamic 4-tab filter
                if (_activeFilter == 'Unread') {
                  conversations = conversations.where((c) {
                    final unread = c.participantOneId == SessionManager.instance.profileId
                        ? c.unreadCountOne
                        : c.unreadCountTwo;
                    return unread > 0;
                  }).toList();
                } else if (_activeFilter.startsWith('Matches') || _activeFilter == 'Matches 💍') {
                  conversations = conversations.where((c) {
                    final msg = (c.lastMessageText ?? '').toLowerCase();
                    return msg.contains('match') ||
                        msg.contains('kundali') ||
                        msg.contains('horoscope') ||
                        msg.contains('interest') ||
                        msg.contains('connected');
                  }).toList();
                } else if (_activeFilter.startsWith('Biodata') || _activeFilter == 'Biodata 📄') {
                  conversations = conversations.where((c) {
                    final msg = (c.lastMessageText ?? '').toLowerCase();
                    return msg.contains('biodata') ||
                        msg.contains('pdf') ||
                        msg.contains('profile') ||
                        msg.contains('share');
                  }).toList();
                }

                // Apply search query
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.toLowerCase().trim();
                  conversations = conversations.where((c) {
                    final name = (c.otherParticipantName ?? '').toLowerCase();
                    final lastMsg = (c.lastMessageText ?? '').toLowerCase();
                    return name.contains(q) || lastMsg.contains(q);
                  }).toList();
                }

                // Sort pinned conversations to top, then by recent message
                conversations.sort((a, b) {
                  final aPinned = _pinnedIds.contains(a.id);
                  final bPinned = _pinnedIds.contains(b.id);
                  if (aPinned && !bPinned) return -1;
                  if (!aPinned && bPinned) return 1;
                  return b.lastMessageAt.compareTo(a.lastMessageAt);
                });

                return SliverMainAxisGroup(
                  slivers: [
                    // 2. Animated Luxury Filter Chips Rail with live badge counts
                    SliverToBoxAdapter(
                      child: _buildFilterChips(
                        theme,
                        isDark,
                        allConversations: rawConversations,
                      ),
                    ),

                    // 3. Conversation List Header with Live Count Badge
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5.w, 1.2.h, 5.w, 0.8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.recentConversations ?? 'Recent Conversations',
                                  style: TextStyle(
                                    fontSize: AppTypography.bodyMedium,
                                    fontWeight: AppTypography.black,
                                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (conversations.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${conversations.length}',
                                      style: TextStyle(
                                        fontSize: AppTypography.labelTiny,
                                        fontWeight: AppTypography.black,
                                        color: const Color(0xFFBE123C),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Live ⚡',
                                style: TextStyle(
                                  fontSize: AppTypography.labelTiny,
                                  fontWeight: AppTypography.bold,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. Content or Filtered Empty State
                    if (conversations.isEmpty)
                      if (_activeFilter != 'All')
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildFilteredEmptyState(theme, isDark),
                        )
                      else
                        SliverToBoxAdapter(
                          child: _buildPremiumEmptyState(theme, isDark),
                        )
                    else ...[
                      SliverToBoxAdapter(
                        child: _buildActiveConnectionsReel(conversations, theme, isDark),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final conversation = conversations[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 220 + (index.clamp(0, 7) * 45)),
                              curve: Curves.easeOutCubic,
                              builder: (context, val, child) {
                                return Transform.translate(
                                  offset: Offset(0, 18 * (1 - val)),
                                  child: Opacity(
                                    opacity: val.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 1.2.h),
                                child: _buildConversationTile(conversation, theme, isDark),
                              ),
                            );
                          }, childCount: conversations.length),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            // Bottom padding
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    final isFocused = _searchFocusNode.hasFocus;
    final hintColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 0.6.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 48,
        decoration: BoxDecoration(
          color: isDark
              ? (isFocused ? const Color(0xFF222230) : const Color(0xFF1B1B26))
              : (isFocused ? Colors.white : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isFocused
                ? const Color(0xFFBE123C)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFFCBD5E1)),
            width: isFocused ? 1.5 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? const Color(0xFFBE123C).withValues(alpha: isDark ? 0.25 : 0.12)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: isFocused ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Animated Ruby Search Icon Pill
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: isFocused
                      ? const LinearGradient(
                          colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                        )
                      : null,
                  color: isFocused
                      ? null
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFBE123C).withValues(alpha: 0.1)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: 17,
                  color: isFocused
                      ? Colors.white
                      : (isDark ? const Color(0xFFFB7185) : const Color(0xFFBE123C)),
                ),
              ),
            ),

            // Input TextField with Zepto-Style Animated Cycling Placeholder (Centered)
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Vertical Slide & Fade Placeholder (Centered & High Contrast)
                  if (_searchQuery.isEmpty)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.35),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _animatedHints[_currentHintIndex % _animatedHints.length],
                              key: ValueKey<int>(_currentHintIndex),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: AppTypography.semiBold,
                                color: hintColor,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Real TextField (Centered)
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textAlign: TextAlign.center,
                    onTapOutside: (_) => _searchFocusNode.unfocus(),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.semiBold,
                      color: textColor,
                    ),
                    cursorColor: const Color(0xFFBE123C),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TactilePressable(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  pressedScale: 0.88,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    ThemeData theme,
    bool isDark, {
    List<ConversationModel> allConversations = const [],
  }) {
    // 1. Calculate live counts
    final unreadCount = allConversations.where((c) {
      final unread = c.participantOneId == SessionManager.instance.profileId
          ? c.unreadCountOne
          : c.unreadCountTwo;
      return unread > 0;
    }).length;

    final matchesCount = allConversations.where((c) {
      final msg = (c.lastMessageText ?? '').toLowerCase();
      return msg.contains('match') ||
          msg.contains('kundali') ||
          msg.contains('horoscope') ||
          msg.contains('interest') ||
          msg.contains('connected');
    }).length;

    final biodataCount = allConversations.where((c) {
      final msg = (c.lastMessageText ?? '').toLowerCase();
      return msg.contains('biodata') ||
          msg.contains('pdf') ||
          msg.contains('profile') ||
          msg.contains('share');
    }).length;

    final filters = [
      {
        'id': 'All',
        'label': 'All',
        'icon': Icons.forum_rounded,
        'count': allConversations.length,
        'gradient': const [Color(0xFFBE123C), Color(0xFFE11D48)],
        'accent': const Color(0xFFBE123C),
      },
      {
        'id': 'Unread',
        'label': 'Unread',
        'icon': Icons.mark_chat_unread_rounded,
        'count': unreadCount,
        'gradient': const [Color(0xFFE11D48), Color(0xFFBE123C)],
        'accent': const Color(0xFFE11D48),
      },
      {
        'id': 'Matches 💍',
        'label': 'Matches 💍',
        'icon': Icons.favorite_rounded,
        'count': matchesCount,
        'gradient': const [Color(0xFFF59E0B), Color(0xFFD97706)],
        'accent': const Color(0xFFF59E0B),
      },
      {
        'id': 'Biodata 📄',
        'label': 'Biodata 📄',
        'icon': Icons.description_rounded,
        'count': biodataCount,
        'gradient': const [Color(0xFF10B981), Color(0xFF059669)],
        'accent': const Color(0xFF10B981),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: filters.map((f) {
            final String id = f['id'] as String;
            final String label = f['label'] as String;
            final IconData icon = f['icon'] as IconData;
            final int count = f['count'] as int;
            final List<Color> gradient = f['gradient'] as List<Color>;
            final Color accent = f['accent'] as Color;
            final isSelected = _activeFilter == id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _activeFilter = id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(colors: gradient) : null,
                    color: isSelected
                        ? null
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? accent.withValues(alpha: 0.9)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      width: isSelected ? 1.4 : 1.1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 13.5,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: isSelected ? AppTypography.black : AppTypography.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : const Color(0xFF334155)),
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : (id == 'Unread'
                                    ? const Color(0xFFBE123C)
                                    : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06))),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: AppTypography.labelTiny,
                              fontWeight: AppTypography.black,
                              color: isSelected
                                  ? Colors.white
                                  : (id == 'Unread'
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF475569))),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState(ThemeData theme, bool isDark) {
    IconData emptyIcon = Icons.filter_list_off_rounded;
    String title = 'No Conversations Found';
    String description = 'No conversations match the "$_activeFilter" filter.';

    if (_activeFilter == 'Unread') {
      emptyIcon = Icons.mark_chat_read_rounded;
      title = 'You\'re All Caught Up! ✨';
      description = 'No unread messages right now. All family conversations are up to date.';
    } else if (_activeFilter.startsWith('Matches')) {
      emptyIcon = Icons.favorite_border_rounded;
      title = 'No Match Chats Yet 💍';
      description = 'Start chatting with your mutual matches to begin your sacred journey.';
    } else if (_activeFilter.startsWith('Biodata')) {
      emptyIcon = Icons.description_outlined;
      title = 'No Biodata Shared Yet 📄';
      description = 'Exchange biodata PDFs with mutual connections to review family profiles.';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFF1F2),
                border: Border.all(
                  color: const Color(0xFFBE123C).withValues(alpha: 0.2),
                  width: 1.2,
                ),
              ),
              child: Icon(
                emptyIcon,
                size: 32,
                color: const Color(0xFFBE123C),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.black,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TactilePressable(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _activeFilter = 'All';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBE123C).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '✨ Show All Conversations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.extraBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✨ ACTIVE CONNECTIONS & MATCHES HORIZONTAL REEL
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveConnectionsReel(
    List<ConversationModel> conversations,
    ThemeData theme,
    bool isDark,
  ) {
    if (conversations.isEmpty || _searchQuery.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0.8.h, 4.w, 0.8.h),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFFFF1F2).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFBE123C).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: Color(0xFFBE123C),
                ),
                const SizedBox(width: 5),
                Text(
                  'Active Connections',
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.extraBold,
                    color: isDark ? const Color(0xFFFB7185) : const Color(0xFF9F1239),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: conversations.length.clamp(0, 10),
              separatorBuilder: (context, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final c = conversations[index];
                return TactilePressable(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(conversation: c),
                      ),
                    );
                  },
                  pressedScale: 0.92,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBE123C), Color(0xFFF59E0B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFBE123C).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF13131A) : Colors.white,
                              ),
                              padding: const EdgeInsets.all(1.5),
                              child: ClipOval(
                                child: CustomImageWidget(
                                  imageUrl: c.otherParticipantImageUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF171720) : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 58,
                        child: Text(
                          (c.otherParticipantName ?? 'User').split(' ').first,
                          style: TextStyle(
                            fontSize: AppTypography.labelTiny,
                            fontWeight: AppTypography.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💬 ROYAL JEWEL CONVERSATION TILE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildConversationTile(
    ConversationModel conversation,
    ThemeData theme,
    bool isDark,
  ) {
    final int unreadCount =
        conversation.participantOneId == SessionManager.instance.profileId
        ? conversation.unreadCountOne
        : conversation.unreadCountTwo;

    final hasUnread = unreadCount > 0;
    final isPinned = _pinnedIds.contains(conversation.id);
    final lastMsg = (conversation.lastMessageText ?? '').toLowerCase();

    // Determine Matrimonial Context Tag
    String? matrimonialTag;
    Color tagColor = const Color(0xFFBE123C);
    IconData tagIcon = Icons.favorite_rounded;

    if (lastMsg.contains('biodata') || lastMsg.contains('pdf')) {
      matrimonialTag = 'Biodata Exchanged 📄';
      tagColor = const Color(0xFF10B981);
      tagIcon = Icons.description_rounded;
    } else if (lastMsg.contains('kundali') || lastMsg.contains('horoscope') || lastMsg.contains('match')) {
      matrimonialTag = 'Kundali Match ✨';
      tagColor = const Color(0xFFF59E0B);
      tagIcon = Icons.auto_awesome_rounded;
    } else if (hasUnread) {
      matrimonialTag = 'New Message';
      tagColor = const Color(0xFFBE123C);
      tagIcon = Icons.mark_chat_unread_rounded;
    }

    return Dismissible(
      key: ValueKey('conv_${conversation.id}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: isPinned ? const Color(0xFF64748B) : const Color(0xFFF59E0B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isPinned ? 'Unpin' : 'Pin 📌',
              style: TextStyle(
                color: Colors.white,
                fontWeight: AppTypography.black,
                fontSize: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFBE123C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Archive',
              style: TextStyle(
                color: Colors.white,
                fontWeight: AppTypography.black,
                fontSize: AppTypography.bodySmall,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.archive_outlined,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.mediumImpact();
          setState(() {
            if (_pinnedIds.contains(conversation.id)) {
              _pinnedIds.remove(conversation.id);
              Fluttertoast.showToast(msg: AppLocalizations.of(context)?.conversationUnpinned ?? 'Conversation unpinned');
            } else {
              _pinnedIds.add(conversation.id);
              Fluttertoast.showToast(msg: AppLocalizations.of(context)?.conversationPinnedToTop ?? 'Conversation pinned to top 📌');
            }
          });
          return false;
        } else {
          HapticFeedback.lightImpact();
          Fluttertoast.showToast(msg: AppLocalizations.of(context)?.chatConversationArchived ?? 'Chat conversation archived');
          return false;
        }
      },
      child: TactilePressable(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversation: conversation),
            ),
          );
        },
        pressedScale: 0.98,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? (hasUnread ? const Color(0xFF241B26) : const Color(0xFF191924))
                : (hasUnread ? const Color(0xFFFFF1F2) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPinned
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                  : (hasUnread
                      ? const Color(0xFFBE123C).withValues(alpha: 0.4)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0))),
              width: (isPinned || hasUnread) ? 1.4 : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.28)
                    : (hasUnread
                        ? const Color(0xFFBE123C).withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.03)),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with Gradient Aura & Live Beacon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 13.w,
                    height: 13.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: (hasUnread || isPinned)
                          ? LinearGradient(
                              colors: isPinned
                                  ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                                  : [const Color(0xFFBE123C), const Color(0xFFF59E0B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      border: (hasUnread || isPinned)
                          ? null
                          : Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1.2,
                            ),
                    ),
                    padding: EdgeInsets.all((hasUnread || isPinned) ? 2 : 0),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: conversation.otherParticipantImageUrl ?? '',
                        fit: BoxFit.cover,
                      ),
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
                  if (isPinned || matrimonialTag != null)
                    Positioned(
                      top: -2,
                      left: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: isPinned
                              ? const Color(0xFFF59E0B)
                              : tagColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF191924) : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isPinned ? Icons.push_pin_rounded : tagIcon,
                          size: 8.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 3.5.w),

              // Content (Name, Verified, Matrimonial Tag, Message snippet)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  conversation.otherParticipantName ?? AppLocalizations.of(context)?.userLabel ?? 'User',
                                  style: TextStyle(
                                    fontWeight: (hasUnread || isPinned) ? AppTypography.black : AppTypography.bold,
                                    fontSize: AppTypography.bodyMedium,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                size: 13.5,
                                color: Color(0xFF0284C7),
                              ),
                              if (isPinned) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.push_pin_rounded,
                                  size: 13,
                                  color: Color(0xFFF59E0B),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          _formatTimestamp(conversation.lastMessageAt),
                          style: TextStyle(
                            fontSize: AppTypography.labelTiny,
                            fontWeight: hasUnread ? AppTypography.extraBold : AppTypography.semiBold,
                            color: hasUnread
                                ? const Color(0xFFBE123C)
                                : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessageText ?? AppLocalizations.of(context)?.sayHelloLabel ?? 'Say hello! 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasUnread
                                  ? (isDark ? Colors.white : const Color(0xFF1E293B))
                                  : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                              fontWeight: hasUnread ? AppTypography.bold : AppTypography.medium,
                              fontSize: AppTypography.labelSmall,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFBE123C).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (matrimonialTag != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: isDark ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: tagColor.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tagIcon, size: 10, color: tagColor),
                            const SizedBox(width: 3.5),
                            Text(
                              matrimonialTag,
                              style: TextStyle(
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.bold,
                                color: tagColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌟 4. LUXURY BRANDED EMPTY STATE WITH MUTUAL MATCHES CAROUSEL
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPremiumEmptyState(ThemeData theme, bool isDark) {
    if (_cachedMatches.isNotEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        children: [
          // 👑 Mutual Matches Waiting Nudge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF2C151B), Color(0xFF1E1015)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBE123C).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✨ ${_cachedMatches.length} Mutual Matches Waiting!',
                            style: TextStyle(
                              fontSize: AppTypography.bodyMedium,
                              fontWeight: AppTypography.black,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'You both expressed mutual interest. Say hello to start the family conversation!',
                            style: TextStyle(
                              fontSize: AppTypography.labelSmall,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 145,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _cachedMatches.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final match = _cachedMatches[index];
                      return Container(
                        width: 125,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E28) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFBE123C)],
                                ),
                              ),
                              child: ClipOval(
                                child: CustomImageWidget(
                                  imageUrl: match.sharedProfileImage ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              match.sharedProfileName ?? match.sharerName ?? 'Match',
                              style: TextStyle(
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.extraBold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            TactilePressable(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                final otherId = match.recipientId == SessionManager.instance.profileId
                                    ? match.sharerId
                                    : (match.recipientId ?? match.sharerId);
                                if (otherId.isNotEmpty) {
                                  final convRes = await _chatRepository.getOrCreateConversation(otherId);
                                  if (convRes.isSuccess && context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(conversation: convRes.data),
                                      ),
                                    );
                                  }
                                }
                              },
                              pressedScale: 0.92,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Say Hi 👋',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTypography.labelTiny,
                                    fontWeight: AppTypography.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.5.h),
          const ConversationListSkeleton(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
        ],
      );
    }

    return const ConversationListSkeleton(
      itemCount: 12,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1];
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

