import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/presentation/chat/chat_screen.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class MatchSuccessDialog extends StatefulWidget {
  final String shareId;

  const MatchSuccessDialog({super.key, required this.shareId});

  @override
  State<MatchSuccessDialog> createState() => _MatchSuccessDialogState();
}

class _MatchSuccessDialogState extends State<MatchSuccessDialog>
    with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = AppSupabaseClient.client;
  bool _isLoading = true;
  Map<String, dynamic>? _matchData;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fetchMatchDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMatchDetails() async {
    try {
      // Fetch the share record
      final share = await _supabase
          .from('profile_shares')
          .select()
          .eq('id', widget.shareId)
          .single();

      final sharerId = share['sharer_id']?.toString();
      final recipientId = share['recipient_id']?.toString();
      if (sharerId == null || recipientId == null) throw Exception('Invalid share: missing sharer or recipient');

      // Get both profiles (matched shares always have sharer + recipient from 06_shares/14)
      final currentUserId = _supabase.auth.currentUser?.id;

      final List<dynamic> profiles = await _supabase
          .from('profiles')
          .select('id, full_name, user_id, photos(public_url)')
          .inFilter('id', [sharerId, recipientId]);

      Map<String, dynamic>? myProfile;
      Map<String, dynamic>? theirProfile;

      for (var p in profiles) {
        if (p['user_id'] == currentUserId) {
          myProfile = p;
        } else {
          theirProfile = p;
        }
      }

      if (mounted) {
        setState(() {
          _matchData = {'me': myProfile, 'them': theirProfile};
          _isLoading = false;
        });
        _controller.forward();
      }
    } catch (e) {
      AppLogger.error('MatchSuccessDialog', 'Error fetching match details: $e');
      if (mounted) {
        Navigator.pop(context); // Close on error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _matchData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final me = _matchData!['me'];
    final them = _matchData!['them'];

    // Extract photos safely
    String? myPhoto;
    if (me != null &&
        me['photos'] != null &&
        (me['photos'] as List).isNotEmpty) {
      myPhoto = me['photos'][0]['public_url'];
    }

    String? theirPhoto;
    if (them != null &&
        them['photos'] != null &&
        (them['photos'] as List).isNotEmpty) {
      theirPhoto = them['photos'][0]['public_url'];
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 90.w,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.canvasRichDark, AppColors.slate700],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyanAccent.withValues(alpha: AppColors.opacity30),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                AppLocalizations.of(context)?.itSAMatch ?? "IT'S A MATCH!",
                style: TextStyle(
                  fontFamily: 'Orbitron', // Assuming we have this or similar
                  color: AppColors.cyanAccent,
                  fontSize: AppTypography.headingLarge,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: AppColors.cyanAccent.withValues(alpha: AppColors.opacity50),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // Avatars
              SizedBox(
                height: 18.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Me (Left)
                    Positioned(left: 0, child: _buildAvatar(myPhoto, true)),
                    // Them (Right)
                    Positioned(
                      right: 0,
                      child: _buildAvatar(theirPhoto, false),
                    ),
                    // Icon in middle
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: AppColors.opacity20),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Text
              Text(
                AppLocalizations.of(context)?.sharedProfilesWithEachOther(them?['full_name'] ?? 'Someone') ?? 'You and ${them?['full_name'] ?? 'Someone'} have shared profiles with each other.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: AppColors.opacity90),
                  fontSize: AppTypography.bodyMedium,
                ),
              ),

              SizedBox(height: 4.h),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    final conversationList = await AppSupabaseClient.client
                        .from('conversations')
                        .select()
                        .or(
                          'and(participant_one_id.eq.${me['id']},participant_two_id.eq.${them['id']}),and(participant_one_id.eq.${them['id']},participant_two_id.eq.${me['id']})',
                        )
                        .limit(1);

                    if (conversationList.isNotEmpty && mounted) {
                      final conversation = ConversationModel.fromJson({
                        ...conversationList[0],
                        'other_participant_name': them['full_name'],
                        'other_participant_image_url':
                            them['photos'] != null &&
                                (them['photos'] as List).isNotEmpty
                            ? them['photos'][0]['public_url']
                            : null,
                      });

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(conversation: conversation),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyanAccent,
                    foregroundColor: AppColors.canvasRichDark,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)?.sendMessage ?? 'SEND MESSAGE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)?.keepBrowsing ?? 'Keep Browsing',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: AppColors.opacity60),
                    fontSize: AppTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? url, bool isLeft) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.opacity30),
            blurRadius: 10,
            offset: Offset(isLeft ? -5 : 5, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomImageWidget(imageUrl: url ?? '', fit: BoxFit.cover),
      ),
    );
  }
}
