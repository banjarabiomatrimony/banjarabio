import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/config/storage_config.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/staggered_list_animation.dart';
import 'package:banjarabio/presentation/admin_screen/admin_helpers.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

/// Review tab handling Verifications and References with
/// detailed review dialog, proof viewing, and admin actions.
class AdminReviewTab extends StatefulWidget {
  final AdminRepository adminRepository;
  final String subTab; // 'Verify' or 'Review'

  const AdminReviewTab({
    super.key,
    required this.adminRepository,
    this.subTab = 'Verify',
  });

  @override
  State<AdminReviewTab> createState() => _AdminReviewTabState();
}

class _AdminReviewTabState extends State<AdminReviewTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _pendingReferences = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final vRes = await widget.adminRepository.getPendingVerifications();
    vRes.fold(
      onSuccess: (r) { if (mounted) setState(() => _pendingRequests = r); },
      onFailure: (e) => debugPrint('Verifications failed: $e'),
    );
    final rRes = await widget.adminRepository.getPendingReferences();
    rRes.fold(
      onSuccess: (r) { if (mounted) setState(() => _pendingReferences = r); },
      onFailure: (e) => debugPrint('References failed: $e'),
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }
    if (widget.subTab == 'Review') {
      return _buildReferencesListSliver(theme);
    }
    return SliverMainAxisGroup(
      slivers: [
        _buildVerificationsListSliver(theme),
      ],
    );
  }

  Future<void> _handleAction(
    String requestId,
    String status, {
    String? notes,
    String? reason,
  }) async {
    try {
      final response = await widget.adminRepository.updateVerificationStatus(
        requestId: requestId,
        status: status,
        adminNotes: notes,
        rejectionReason: reason,
      );

      await response.fold(
        onSuccess: (_) async {
          await _loadData(); // Reload list
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(status == 'on_hold' 
                    ? (AppLocalizations.of(context)?.onHold ?? 'On Hold')
                    : (AppLocalizations.of(context)?.requestProcessedSuccessfullyMsg(status) ?? 'Request $status successfully')),
                backgroundColor: status == 'approved' ? Colors.green : (status == 'on_hold' ? Colors.orange : Colors.red),
              ),
            );
          }
        },
        onFailure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.errorPrefix(error) ?? 'Error: $error')));
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.errorPrefix(e.toString()) ?? 'Error: $e')));
      }
    }
  }
  Widget _buildReferencesListSliver(ThemeData theme) {
    if (_pendingReferences.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 2.h),
              Text(
                'No pending references',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final reference = _pendingReferences[index];
            final profile = reference['profiles'] as Map?;

            return StaggeredListItem(
              index: index,
              child: Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: GlassmorphismContainer(
                  padding: EdgeInsets.all(4.w),
                  borderRadius: BorderRadius.circular(24),
                  opacity: 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim().isEmpty
                                      ? 'Unknown User'
                                      : '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                                if (reference['user_id'] != null)
                                  Text(
                                    'ID: ${reference['user_id']}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontSize: AppTypography.labelSmall,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildTypeBadge(reference['reference_type'], theme),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('Reference Name', reference['name']),
                                _buildDetailRow('Phone Number', reference['phone_number']),
                              ],
                            ),
                          ),
                          if (reference['phone_number'] != null && reference['phone_number'].toString().isNotEmpty)
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => launchCaller(context, reference['phone_number'].toString()),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.call, size: 18, color: Colors.blue),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                InkWell(
                                  onTap: () => launchWhatsApp(context, reference['phone_number'].toString()),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.chat, size: 18, color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (reference['reference_type'] == 'internal')
                        _buildDetailRow('Linked User ID', reference['referenced_user_id']),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          _buildActionButton(
                            label: 'Reject',
                            onPressed: () => _handleReferenceAction(reference['id'], 'rejected'),
                            color: Colors.red,
                            theme: theme,
                          ),
                          SizedBox(width: 3.w),
                          _buildActionButton(
                            label: 'Approve & Verify',
                            onPressed: () => _handleReferenceAction(reference['id'], 'verified'),
                            color: Colors.green,
                            isPrimary: true,
                            theme: theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: _pendingReferences.length,
        ),
      ),
    );
  }
  Future<void> _handleReferenceAction(
    String referenceId,
    String status,
  ) async {
    try {
      final response = await widget.adminRepository.updateReferenceStatus(
        referenceId: referenceId,
        status: status,
      );

      await response.fold(
        onSuccess: (_) async {
          await _loadData(); // Reload list
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(status == 'verified' 
                    ? (AppLocalizations.of(context)?.referenceVerified ?? 'Reference Verified')
                    : (AppLocalizations.of(context)?.referenceRejected ?? 'Reference Rejected')),
                backgroundColor: status == 'verified' ? Colors.green : Colors.red,
              ),
            );
          }
        },
        onFailure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $error')));
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
  void _showReviewDialog(Map<String, dynamic> request, String initialAction) {
    final theme = Theme.of(context);
    final profile = request['profiles'] as Map?;
    final type = request['verification_type'] as String;
    final payload = request['payload'] as Map? ?? {};

    String action = initialAction;
    final TextEditingController notesController = TextEditingController();
    String? selectedReason;

    final List<String> rejectionReasons = [
      'Document not clear',
      'Invalid ID number',
      'Name mismatch',
      'Expired document',
      'Incorrect document type',
      'File missing/corrupted',
      'Other',
    ];

    // Collect ALL possible media items for review
    final Set<String> proofPaths = {};
    if (payload['image_urls'] is List) {
      proofPaths.addAll((payload['image_urls'] as List)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty && s != 'null'));
    }
    if (payload['proof_url'] != null) {
      final s = payload['proof_url'].toString();
      if (s.isNotEmpty && s != 'null') proofPaths.add(s);
    }
    if (payload['selfie_url'] != null) {
      final s = payload['selfie_url'].toString();
      if (s.isNotEmpty && s != 'null') proofPaths.add(s);
    }
    if (payload['video_url'] != null) {
      final s = payload['video_url'].toString();
      if (s.isNotEmpty && s != 'null') proofPaths.add(s);
    }

    // Track viewed media
    final Set<String> viewedMedia = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final allViewed =
              proofPaths.every((path) => viewedMedia.contains(path));

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 85.h,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Top bar
                  Container(
                    margin: EdgeInsets.only(top: 1.5.h, bottom: 1.h),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thoroughly Review Data',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: AppTypography.bold),
                          ),
                          Text(
                            'You must open/watch all items below before taking action.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                          ),
                          SizedBox(height: 3.h),
                          
                                Column(
                                  children: [
                                    GlassmorphismContainer(
                                      padding: EdgeInsets.all(4.w),
                                      borderRadius: BorderRadius.circular(20),
                                      opacity: 0.05,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                            child: Text(
                                              (profile?['full_name'] as String?)?.isNotEmpty == true
                                                  ? profile!['full_name'][0]
                                                  : '?',
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim().isEmpty
                                                      ? 'Unknown User'
                                                      : '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim(),
                                                  style: const TextStyle(fontWeight: AppTypography.bold),
                                                ),
                                                 if (request['user_id'] != null)
                                                   Text('ID: ${request['user_id']}', style: theme.textTheme.bodySmall?.copyWith(fontSize: AppTypography.labelSmall, color: theme.hintColor)),
                                                Text(profile?['email'] ?? '', style: theme.textTheme.bodySmall),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    () {
                                      final String? userPhone = profile?['phone_number']?.toString();
                                      if (userPhone != null && userPhone.isNotEmpty) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 1.5.h),
                                          child: Row(
                                            children: [
                                              buildAdminContactAction(
                                                icon: Icons.call,
                                                label: 'Call',
                                                color: Colors.blue,
                                                onTap: () => launchCaller(context, userPhone),
                                                theme: theme,
                                              ),
                                              SizedBox(width: 3.w),
                                              buildAdminContactAction(
                                                icon: Icons.chat,
                                                label: 'WhatsApp',
                                                color: Colors.green,
                                                onTap: () => launchWhatsApp(context, userPhone),
                                                theme: theme,
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }(),
                                  ],
                                ),
                          SizedBox(height: 3.h),
                          
                          // Request Details
                          Text('Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
                          SizedBox(height: 1.5.h),
                          _buildDetailRow('Type', type.replaceAll('_', ' ').toUpperCase()),
                          if (type == 'govt_id') ...[
                            _buildDetailRow('ID Type', payload['doc_type']),
                            _buildDetailRow('ID Number', payload['id_number']),
                          ] else if (type == 'community_id') ...[
                            _buildDetailRow('Gotra', payload['gotra']),
                            _buildDetailRow('Village', payload['village']),
                          ],
                          SizedBox(height: 3.h),

                          // Side-by-Side Photo Comparison
                          _buildComparisonSection(profile, payload, theme),
                          
                          // Proofs Section with checkmarks
                          Text('Proof Evidence (${viewedMedia.length}/${proofPaths.length})', 
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
                          SizedBox(height: 1.5.h),
                          _buildTrackedProofSection(payload, theme, viewedMedia, (path) {
                            setModalState(() => viewedMedia.add(path));
                          }),
                          SizedBox(height: 4.h),
                          
                          if (allViewed) ...[
                            // Action Selection
                            Text('Action', style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                _buildMiniActionChip('Reject', 'rejected', Colors.red, action, (val) => setModalState(() => action = val)),
                                SizedBox(width: 2.w),
                                _buildMiniActionChip('Hold', 'on_hold', Colors.orange, action, (val) => setModalState(() => action = val)),
                                SizedBox(width: 2.w),
                                _buildMiniActionChip('Approve', 'approved', Colors.green, action, (val) => setModalState(() => action = val)),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            
                            if (action == 'rejected') ...[
                              Text('Rejection Reason', style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
                              SizedBox(height: 1.5.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedReason,
                                    hint: const Text('Select a reason'),
                                    items: rejectionReasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                                    onChanged: (val) => setModalState(() => selectedReason = val),
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                            ],
                            
                            Text('Admin Notes (Internal)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
                            SizedBox(height: 1.5.h),
                            TextField(
                              key: const ValueKey('admin_notes_field'),
                              controller: notesController,
                              maxLines: 3,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: 'Enter internal notes...',
                                filled: true,
                                fillColor: theme.cardColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.orange),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      'Please review all media items above to unlock actions.',
                                      style: TextStyle(color: Colors.orange[800], fontSize: AppTypography.labelMedium),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 4.h),
                          
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: notesController,
                              builder: (context, value, _) {
                                final hasNotes = value.text.trim().isNotEmpty;
                                final canSubmit = allViewed && hasNotes;
  
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: !canSubmit
                                        ? null
                                        : () {
                                            if (action == 'rejected' &&
                                                selectedReason == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Please select a rejection reason')));
                                              return;
                                            }
                                            Navigator.pop(context);
                                            _handleAction(
                                              request['id'],
                                              action,
                                              notes: notesController.text,
                                              reason: selectedReason,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !canSubmit
                                          ? theme.disabledColor
                                          : (action == 'approved'
                                              ? Colors.green
                                              : (action == 'rejected'
                                                  ? Colors.red
                                                  : Colors.orange)),
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.h),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                    child: Text(!allViewed
                                        ? 'Review Required'
                                        : (!hasNotes
                                            ? 'Admin Note Required'
                                            : 'Confirm ${action[0].toUpperCase()}${action.substring(1).replaceAll('_', ' ')}')),
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildMiniActionChip(String label, String value, Color color, String currentVal, Function(String) onSelect) {
    final isSelected = currentVal == value;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.labelMedium,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildVerificationsListSliver(ThemeData theme) {
    if (_pendingRequests.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'check_circle_outline',
                size: 64,
                color: theme.hintColor,
              ),
              SizedBox(height: 2.h),
              Text(
                AppLocalizations.of(context)?.noPendingRequests ?? 'No pending requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group requests by user_id
    final Map<String, List<Map<String, dynamic>>> groupedRequests = {};
    for (var req in _pendingRequests) {
      final userId = req['user_id'] as String;
      if (!groupedRequests.containsKey(userId)) {
        groupedRequests[userId] = [];
      }
      groupedRequests[userId]!.add(req);
    }

    final userIds = groupedRequests.keys.toList();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final userId = userIds[index];
            final userRequests = groupedRequests[userId]!;
            final firstRequest = userRequests.first;
            final profileMap = firstRequest['profiles'] as Map?;

            return StaggeredListItem(
              index: index,
              child: Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: GlassmorphismContainer(
                  padding: EdgeInsets.all(4.w),
                  borderRadius: BorderRadius.circular(24),
                  opacity: 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profileMap?['full_name'] ?? ''} ${profileMap?['surname'] ?? ''}'.trim().isEmpty
                                      ? AppLocalizations.of(context)?.unknownUser ?? 'Unknown User'
                                      : '${profileMap?['full_name'] ?? ''} ${profileMap?['surname'] ?? ''}'.trim(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                                if (userId.isNotEmpty)
                                  Text(
                                    'ID: $userId',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontSize: AppTypography.labelSmall,
                                    ),
                                  ),
                                if (profileMap?['email'] != null)
                                  Text(
                                    profileMap!['email'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                () {
                                  final String? userPhone = profileMap?['phone_number']?.toString();
                                  if (userPhone != null && userPhone.isNotEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 1.h),
                                      child: Row(
                                        children: [
                                          buildAdminContactAction(
                                            icon: Icons.call,
                                            label: 'Call',
                                            color: Colors.blue,
                                            onTap: () => launchCaller(context, userPhone),
                                            theme: theme,
                                          ),
                                          SizedBox(width: 2.w),
                                          buildAdminContactAction(
                                            icon: Icons.chat,
                                            label: 'WhatsApp',
                                            color: Colors.green,
                                            onTap: () => launchWhatsApp(context, userPhone),
                                            theme: theme,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }(),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${userRequests.length} ${userRequests.length == 1 ? "Request" : "Requests"}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: AppTypography.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      
                      // Individual Requests
                      ...userRequests.map((request) {
                        final type = request['verification_type'] as String;
                        final payload = request['payload'] as Map? ?? {};
                        final isLast = userRequests.indexOf(request) == userRequests.length - 1;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Row(
                                   children: [
                                     _buildTypeBadge(type, theme),
                                     if (request['status'] == 'on_hold') ...[
                                       SizedBox(width: 2.w),
                                       _buildStatusBadge((AppLocalizations.of(context)?.onHold ?? 'HOLD').toUpperCase(), Colors.orange, theme),
                                     ],
                                   ],
                                 ),
                                Text(
                                  TimeAgo.format(DateTime.parse(request['created_at'])),
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: AppTypography.labelSmall),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.5.h),
                            if (type == 'govt_id') ...[
                              _buildDetailRow(AppLocalizations.of(context)?.idType ?? 'ID Type', payload['doc_type']),
                              _buildDetailRow(AppLocalizations.of(context)?.idNumber ?? 'ID Number', payload['id_number']),
                            ] else if (type == 'community_id') ...[
                              _buildDetailRow(AppLocalizations.of(context)?.gotra ?? 'Gotra', payload['gotra']),
                              _buildDetailRow(AppLocalizations.of(context)?.village ?? 'Village', payload['village']),
                            ],
                            SizedBox(height: 1.h),
                            _buildTrackedProofSection(payload, theme, {}, (_) {}),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                _buildActionButton(
                                  label: 'Review & Verify',
                                  onPressed: () => _showReviewDialog(request, 'approved'),
                                  color: theme.colorScheme.primary,
                                  isPrimary: true,
                                  theme: theme,
                                ),
                              ],
                            ),
                            if (!isLast) const Divider(height: 32),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: userIds.length,
        ),
      ),
    );
  }
  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required ThemeData theme,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(label),
            ),
    );
  }
  Widget _buildTypeBadge(String type, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type == 'govt_id'
            ? (AppLocalizations.of(context)?.govtId ?? 'Govt ID')
            : type == 'community_id'
                ? (AppLocalizations.of(context)?.communityId ?? 'Community ID')
                : type.toUpperCase().replaceAll('_', ' '),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: AppTypography.bold,
          fontSize: AppTypography.labelSmall,
        ),
      ),
    );
  }
  Widget _buildStatusBadge(String label, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: AppTypography.bold,
          fontSize: AppTypography.labelSmall,
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, dynamic value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(
    Map? profile,
    Map payload,
    ThemeData theme,
  ) {
    final selfiePath = payload['selfie_url']?.toString();
    if (selfiePath == null || selfiePath.isEmpty || selfiePath == 'null') {
      return const SizedBox.shrink();
    }

    final profilePhotoUrl = profile?['primary_photo_url']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identity Verification',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold),
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                'Profile Photo',
                profilePhotoUrl,
                theme,
                isPrivate: false,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildComparisonCard(
                'Selfie Proof',
                selfiePath,
                theme,
                isPrivate: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
      ],
    );
  }
  Widget _buildComparisonCard(
    String label,
    String? pathOrUrl,
    ThemeData theme, {
    required bool isPrivate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
            fontWeight: AppTypography.bold,
          ),
        ),
        SizedBox(height: 1.h),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              color: theme.cardColor,
            ),
            child: pathOrUrl == null || pathOrUrl.isEmpty || pathOrUrl == 'null'
                ? Center(child: Icon(Icons.person_outline, size: 48, color: theme.hintColor.withValues(alpha: 0.3)))
                : isPrivate 
                    ? FutureBuilder<BackendResponse<String>>(
                        future: widget.adminRepository.getSignedUrl(StorageConfig.verificationDocs, pathOrUrl),
                        builder: (context, snapshot) {
                          final signedUrl = snapshot.data?.fold(onSuccess: (u) => u, onFailure: (_) => null);
                          if (signedUrl == null) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return CachedNetworkImage(
                            imageUrl: signedUrl,
                            fit: BoxFit.cover,
                            cacheManager: PersistentCacheManager.instance,
                            cacheKey: PersistentCacheManager.stableKeyFor(signedUrl),
                          );
                        },
                      )
                    : CachedNetworkImage(
                        imageUrl: pathOrUrl,
                        fit: BoxFit.cover,
                        cacheManager: PersistentCacheManager.instance,
                        cacheKey: PersistentCacheManager.stableKeyFor(pathOrUrl),
                      ),
          ),
        ),
      ],
    );
  }
  Widget _buildTrackedProofSection(
    Map payload,
    ThemeData theme,
    Set<String> viewedMedia,
    Function(String) onViewed,
  ) {
    final List<String> paths = [];
    String? videoUrl;

    if (payload['image_urls'] is List) {
      paths.addAll((payload['image_urls'] as List)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty && s != 'null'));
    }
    if (payload['proof_url'] != null) {
      final s = payload['proof_url'].toString();
      if (s.isNotEmpty && s != 'null') paths.add(s);
    }
    if (payload['selfie_url'] != null) {
      final s = payload['selfie_url'].toString();
      if (s.isNotEmpty && s != 'null') paths.add(s);
    }

    if (payload['video_url'] != null) {
      videoUrl = payload['video_url'].toString();
    }

    if (paths.isEmpty && (videoUrl == null || videoUrl == 'null' || videoUrl.isEmpty)) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (videoUrl != null) ...[
          FutureBuilder<BackendResponse<String>>(
            future: widget.adminRepository.getSignedUrl(
              StorageConfig.verificationDocs,
              videoUrl,
            ),
            builder: (context, snapshot) {
              final response = snapshot.data;
              final fullVideoUrl = response?.fold(
                onSuccess: (u) => u,
                onFailure: (_) => null,
              );
              final isViewed = viewedMedia.contains(videoUrl);

              return InkWell(
                onTap: () {
                  onViewed(videoUrl!);
                  if (fullVideoUrl != null) {
                    _viewVideo(fullVideoUrl);
                  } else if (response != null && !response.isSuccess) {
                    // Feedback that the missing file is acknowledged and marked as "viewed"
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Acknowledged: Missing file marked as processed.'),
                        duration: Duration(seconds: 2),
                      )
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: response != null && !response.isSuccess
                        ? Colors.red.withValues(alpha: 0.05)
                        : (isViewed ? Colors.green.withValues(alpha: 0.05) : theme.colorScheme.primary.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: response != null && !response.isSuccess
                          ? Colors.red.withValues(alpha: 0.3)
                          : (isViewed ? Colors.green : theme.colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (response != null && !response.isSuccess)
                        const Icon(Icons.error_outline, color: Colors.red, size: 32)
                      else
                        Icon(Icons.play_circle_fill, 
                          color: fullVideoUrl == null ? theme.disabledColor : (isViewed ? Colors.green : Colors.blue), 
                          size: 32),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              response != null && !response.isSuccess ? 'Video Missing' : 'Watch Video Proof', 
                              style: TextStyle(
                                fontWeight: AppTypography.bold, 
                                color: response != null && !response.isSuccess ? Colors.red : theme.colorScheme.primary
                              )
                            ),
                            Text(
                              response != null && !response.isSuccess 
                                ? 'Tap to acknowledge missing file' 
                                : (isViewed ? 'Viewed' : 'Action required'), 
                              style: theme.textTheme.bodySmall
                            ),
                          ],
                        ),
                      ),
                      if (isViewed)
                        const Icon(Icons.check_circle, color: Colors.green),
                      if (fullVideoUrl == null && response == null)
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
        ],
        
        if (paths.isNotEmpty) ...[
          SizedBox(
            height: 12.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: paths.length,
              itemBuilder: (context, i) {
                final path = paths[i];
                final isViewed = viewedMedia.contains(path);
                
                return FutureBuilder<BackendResponse<String>>(
                  future: widget.adminRepository.getSignedUrl(
                    StorageConfig.verificationDocs,
                    path,
                  ),
                  builder: (context, snapshot) {
                    final response = snapshot.data;
                    final url = response?.fold(
                      onSuccess: (u) => u,
                      onFailure: (_) => null,
                    );
                    final isError = response != null && !response.isSuccess;

                    return InkWell(
                      onTap: () {
                        onViewed(path);
                        if (url != null) {
                          _viewImage(url);
                        } else if (isError) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Acknowledged: Missing file marked as processed.'),
                              duration: Duration(seconds: 2),
                            )
                          );
                        }
                      },
                      child: Container(
                        width: 30.w,
                        margin: EdgeInsets.only(right: 3.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isError 
                              ? Colors.red.withValues(alpha: 0.5) 
                              : (isViewed ? Colors.green : theme.dividerColor.withValues(alpha: 0.5)),
                            width: isViewed ? 2 : 1,
                          ),
                          color: isError ? Colors.red.withValues(alpha: 0.05) : theme.cardColor,
                        ),
                        child: Stack(
                          children: [
                            if (url != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: CachedNetworkImage(
                                  imageUrl: url, 
                                  fit: BoxFit.cover, 
                                  width: double.infinity, 
                                  height: double.infinity,
                                  cacheManager: PersistentCacheManager.instance,
                                  cacheKey: PersistentCacheManager.stableKeyFor(url),
                                  errorWidget: (context, url, error) => Container(
                                    color: theme.disabledColor.withValues(alpha: 0.1),
                                    child: const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                                  ),
                                ),
                              ),
                            if (isError)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.broken_image, color: Colors.red, size: 24),
                                    SizedBox(height: 0.5.h),
                                    Text('404', style: TextStyle(color: Colors.red, fontSize: AppTypography.labelSmall, fontWeight: AppTypography.bold)),
                                  ],
                                ),
                              ),
                            if (url == null && !isError)
                              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            if (isViewed)
                              const Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.check_circle, color: Colors.green, size: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
  void _viewVideo(String videoUrl) {
    // Basic video preview (could use a full player if needed)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Video Proof'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, size: 64, color: Colors.blue),
            SizedBox(height: 2.h),
            const Text('Admin must watch the video thoroughly.', textAlign: TextAlign.center),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: () => url_launcher.launchUrl(Uri.parse(videoUrl)),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open External Player'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
        ],
      ),
    );
  }
  void _viewImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: CustomImageWidget(
                imageUrl: url,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
