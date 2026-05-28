import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/config/admin_config.dart';
import 'package:banjarabio/core/config/storage_config.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';

import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/core/models/creator_model.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/staggered_list_animation.dart';
import 'package:banjarabio/presentation/admin_screen/coupon_management_tab.dart';
import 'package:banjarabio/presentation/admin_screen/special_discount_tab.dart';
import 'package:banjarabio/presentation/admin_screen/team_management_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminRepository? adminRepository;
  final InfluencerRepository? influencerRepository;
  final ProfileRepository? profileRepository;

  const AdminDashboardScreen({
    super.key,
    this.adminRepository,
    this.influencerRepository,
    this.profileRepository,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminRepository _adminRepository;
  late final InfluencerRepository _influencerRepository;
  late final ProfileRepository _profileRepository;

  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _pendingReferences = [];
  List<Creator> _creators = [];
  List<Map<String, dynamic>> _payments = [];
  bool _isPaymentsLoading = false;
  Map<String, dynamic> _stats = {
    'total_users': 0,
    'pending_verifications': 0,
    'premium_users': 0,
    'revenue_total': 0,
    'revenue_monthly': 0,
    'revenue_today': 0,
    'revenue_pdf': 0,
    'revenue_subscription': 0,
  };
  String _activeTab = 'Dashboard';
  String _activePaymentSubTab = 'Subscription';
  String _activeUserSubTab = 'Female';
  String _paymentSearchQuery = '';
  final ScrollController _scrollController = ScrollController();
  Timer? _autoUpdateTimer;

  @override
  void initState() {
    super.initState();
    _adminRepository = widget.adminRepository ?? AdminRepository();
    _influencerRepository = widget.influencerRepository ?? InfluencerRepository();
    _profileRepository = widget.profileRepository ?? ProfileRepository();
    _checkAdminAccess();
    _startAutoUpdate();
  }

  void _startAutoUpdate() {
    _autoUpdateTimer?.cancel();
    // 24 hours = 86400 seconds
    _autoUpdateTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _autoUpdateTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    // First check by email (admin doesn't need profile)
    final currentUser = AppSupabaseClient.currentUser;
    final userEmail = currentUser?.email?.toLowerCase() ?? '';

    if (AdminConfig.isAdminEmail(userEmail)) {
      // Admin by email - grant access
      _loadData();
      return;
    }

    // Fallback: check by profile isAdmin flag
    final profileRes = await _profileRepository.getOwnProfile();

    await profileRes.fold(
      onSuccess: (profile) {
        if (profile == null || !profile.isAdmin) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.unauthorizedAccessAdminsOnly ?? 'Unauthorized access. Admins only.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        _loadData();
      },
      onFailure: (error) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.errorPrefix(error) ?? 'Error validating access: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Stats
      final statsRes = await _adminRepository.getAdminStats();
      statsRes.fold(
        onSuccess: (data) {
          if (mounted) {
            setState(() => _stats = data);
          }
        },
        onFailure: (e) {
          debugPrint('Stats failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminStats ?? 'Unable to load dashboard statistics.'))
            );
          }
        },
      );

      // 2. Load Verifications
      final response = await _adminRepository.getPendingVerifications();
      response.fold(
        onSuccess: (requests) => setState(() => _pendingRequests = requests),
        onFailure: (error) {
          debugPrint('Verifications failed: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminVerifications ?? 'Could not load verification requests.'))
            );
          }
        },
      );

      // 3. Load References
      final refResponse = await _adminRepository.getPendingReferences();
      refResponse.fold(
        onSuccess: (refs) => setState(() => _pendingReferences = refs),
        onFailure: (error) {
          debugPrint('References failed: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminReferences ?? 'Unable to fetch pending references.'))
            );
          }
        },
      );
      
      // 4. Load Creators
      final creatorsRes = await _influencerRepository.getAllCreators();
      creatorsRes.fold(
        onSuccess: (creators) => setState(() => _creators = creators),
        onFailure: (e) {
          debugPrint('Creators failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminCreators ?? 'Could not fetch creator list.'))
            );
          }
        },
      );

      // 5. Load Payments
      await _loadPayments();

      // 6. Load Users (Initial load for Admin)
      _loadUsers('');

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminData(e.toString()) ?? 'Error loading admin data: $e')));
      }
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isPaymentsLoading = true);
    final response = await _adminRepository.getPaymentsList();
    response.fold(
      onSuccess: (payments) {
        if (mounted) {
          setState(() {
            _payments = payments;
            _isPaymentsLoading = false;
          });
        }
      },
      onFailure: (e) {
        debugPrint('Payments load failed: $e');
        if (mounted) {
          setState(() => _isPaymentsLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminPayments ?? 'Failed to load payment history.'))
          );
        }
      },
    );
  }

  Future<void> _handleAction(
    String requestId,
    String status, {
    String? notes,
    String? reason,
  }) async {
    try {
      final response = await _adminRepository.updateVerificationStatus(
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (reference['user_id'] != null)
                                  Text(
                                    'ID: ${reference['user_id']}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontSize: 10,
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
                                  onTap: () => _launchCaller(reference['phone_number'].toString()),
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
                                  onTap: () => _launchWhatsApp(reference['phone_number'].toString()),
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
      final response = await _adminRepository.updateReferenceStatus(
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
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                if (request['user_id'] != null)
                                                  Text('ID: ${request['user_id']}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.hintColor)),
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
                                              _buildContactAction(
                                                icon: Icons.call,
                                                label: 'Call',
                                                color: Colors.blue,
                                                onTap: () => _launchCaller(userPhone),
                                                theme: theme,
                                              ),
                                              SizedBox(width: 3.w),
                                              _buildContactAction(
                                                icon: Icons.chat,
                                                label: 'WhatsApp',
                                                color: Colors.green,
                                                onTap: () => _launchWhatsApp(userPhone),
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
                          Text('Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: 1.5.h),
                          _buildTrackedProofSection(payload, theme, viewedMedia, (path) {
                            setModalState(() => viewedMedia.add(path));
                          }),
                          SizedBox(height: 4.h),
                          
                          if (allViewed) ...[
                            // Action Selection
                            Text('Action', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                              Text('Rejection Reason', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                            
                            Text('Admin Notes (Internal)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                                      style: TextStyle(color: Colors.orange[800], fontSize: 9.sp),
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
              fontWeight: FontWeight.bold,
              fontSize: 9.sp,
            ),
          ),
        ),
      ),
    );
  }

  bool _isUsersLoading = false;
  List<ProfileModel> _users = [];

  Future<void> _loadUsers(String query) async {
    setState(() => _isUsersLoading = true);
    try {
      String? gender;
      bool? isPremium;
      bool? isActive;

      if (_activeUserSubTab == 'Female') {
        gender = 'Female';
        isActive = true;
      } else if (_activeUserSubTab == 'Male') {
        gender = 'Male';
        isActive = true;
      } else if (_activeUserSubTab == 'Paid') {
        isPremium = true;
        isActive = true;
      } else if (_activeUserSubTab == 'Deleted') {
        isActive = false;
      } else if (_activeUserSubTab == 'Testers') {
        isActive = true;
      } else {
        isActive = true; // Default to active users
      }

      final response = await _adminRepository.getAllProfiles(
        searchQuery: query,
        gender: gender,
        isPremium: isPremium,
        isActive: isActive,
        onlyTesters: _activeUserSubTab == 'Testers',
      );
      await response.fold(
        onSuccess: (users) {
          if (mounted) {
            setState(() {
              _users = users;
              _isUsersLoading = false;
            });
          }
        },
        onFailure: (error) {
          if (mounted) {
            setState(() => _isUsersLoading = false);
            debugPrint('Error loading users: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminUsers ?? 'Could not fetch user list.'))
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUsersLoading = false);
      }
    }
  }

  Future<void> _manualVerify(
    String userId, {
    bool email = false,
    bool phone = false,
  }) async {
    try {
      final response = await _adminRepository.verifyProfileManually(
        userId,
        email: email,
        phone: phone,
      );
      await response.fold(
        onSuccess: (_) async {
          await _loadUsers(''); // Refresh
        },
        onFailure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.failedToVerify(error) ?? 'Failed to verify: $error')));
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

  Future<void> _launchCaller(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    try {
      if (await url_launcher.canLaunchUrl(url)) {
        await url_launcher.launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch dialer')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching caller: $e');
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Remove non-digits for wa.me link
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    try {
      await url_launcher.launchUrl(url, mode: url_launcher.LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }



  Future<void> _handleLogout() async {
    try {
      await AppSupabaseClient.client.auth.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/authentication-screen', (route) => false);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/authentication-screen', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            _buildPremiumHeader(theme),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          _buildContentSliver(theme),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme) {
    final user = AppSupabaseClient.currentUser;
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 7.h, 6.w, 3.h),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.adminPortal ?? 'Admin Portal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _handleLogout,
                child: GlassmorphismContainer(
                  padding: const EdgeInsets.all(8),
                  borderRadius: BorderRadius.circular(12),
                  blur: 10,
                  opacity: 0.2,
                  child: const Icon(Icons.logout, color: Colors.white),
                ),
              ),
            ],
          ),
          if (_activeTab == 'Creators')
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCreatorForm,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add New Influencer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildDashboardOverviewSliver(ThemeData theme) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildRevenueSection(theme),
          SizedBox(height: 4.h),
          _buildEngagementSection(theme),
          SizedBox(height: 4.h),
          _buildSafetyHealthSection(theme),
          SizedBox(height: 4.h),
          _buildDemographicsSection(theme),
          SizedBox(height: 4.h),
          _buildGrowthSection(theme),
          SizedBox(height: 4.h),
        ]),
      ),
    );
  }

  Widget _buildRevenueSection(ThemeData theme) {
    final lastMonthName = DateFormat('MMMM').format(DateTime(DateTime.now().year, DateTime.now().month - 1));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Financial Performance',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.trending_up, color: Colors.green, size: 20),
          ],
        ),
        SizedBox(height: 2.h),
        
        // All Time Revenue Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Time Revenue',
              style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'EXCLUSIVE TESTER',
                style: TextStyle(color: Colors.green, fontSize: 7.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2.w,
          crossAxisSpacing: 2.w,
          childAspectRatio: 0.9,
          children: [
            _buildStatCardSimple(
              theme,
              'Combined',
              '₹${_stats['revenue_total']?.toStringAsFixed(0) ?? '0'}',
              Icons.account_balance_wallet,
              Colors.green,
            ),
            _buildStatCardSimple(
              theme,
              'Subscription',
              '₹${_stats['revenue_subscription']?.toStringAsFixed(0) ?? '0'}',
              Icons.card_membership,
              Colors.blue,
            ),
            _buildStatCardSimple(
              theme,
              'PDF Rev',
              '₹${_stats['revenue_pdf']?.toStringAsFixed(0) ?? '0'}',
              Icons.picture_as_pdf,
              Colors.orange,
            ),
          ],
        ),
        SizedBox(height: 2.h),

        // Last Month Revenue Section (Calendar Wise)
        Text(
          'Last Month ($lastMonthName)',
          style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 1.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2.w,
          crossAxisSpacing: 2.w,
          childAspectRatio: 0.9,
          children: [
            _buildStatCardSimple(
              theme,
              'Combined',
              '₹${_stats['revenue_last_month']?.toStringAsFixed(0) ?? '0'}',
              Icons.history,
              Colors.teal,
            ),
            _buildStatCardSimple(
              theme,
              'Subscription',
              '₹${_stats['revenue_last_month_subscription']?.toStringAsFixed(0) ?? '0'}',
              Icons.card_membership,
              Colors.indigo,
            ),
            _buildStatCardSimple(
              theme,
              'PDF Rev',
              '₹${_stats['revenue_last_month_pdf']?.toStringAsFixed(0) ?? '0'}',
              Icons.picture_as_pdf,
              Colors.deepOrange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardSimple(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphismContainer(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
      borderRadius: BorderRadius.circular(12),
      blur: 8,
      opacity: 0.05,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Engagement',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildStatCard(
              theme,
              'Daily Active Users',
              _stats['dau_today']?.toString() ?? '0',
              Icons.bolt,
              Colors.orange,
            ),
            SizedBox(width: 3.w),
            _buildStatCard(
              theme,
              'Profile Views',
              _stats['total_profile_views']?.toString() ?? '0',
              Icons.visibility,
              Colors.blue,
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            _buildStatCard(
              theme,
              'Total Messages',
              _stats['total_messages']?.toString() ?? '0',
              Icons.chat_bubble,
              Colors.purple,
            ),
            SizedBox(width: 3.w),
            _buildStatCard(
              theme,
              'Conversations',
              _stats['total_conversations']?.toString() ?? '0',
              Icons.forum,
              Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyHealthSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety & Health',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildStatCard(
              theme,
              'Pending Reports',
              _stats['pending_reports']?.toString() ?? '0',
              Icons.report_problem,
              Colors.red,
            ),
            SizedBox(width: 3.w),
            _buildStatCard(
              theme,
              'Total Blocks',
              _stats['total_blocks']?.toString() ?? '0',
              Icons.block,
              Colors.grey,
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            _buildStatCard(
              theme,
              'Pending Verif',
              _stats['pending_verifications']?.toString() ?? '0',
              Icons.verified_user,
              Colors.blueGrey,
            ),
            SizedBox(width: 3.w),
            _buildStatCard(
              theme,
              'Pending Refs',
              _stats['pending_references']?.toString() ?? '0',
              Icons.thumbs_up_down,
              Colors.brown,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDemographicsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demographics & Premium',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildStatCard(
              theme,
              'Total Users',
              _stats['total_auth_users']?.toString() ?? '0',
              Icons.people,
              Colors.deepPurple,
            ),
            SizedBox(width: 3.w),
            _buildStatCard(
              theme,
              'Profiles',
              _stats['total_profiles']?.toString() ?? '0',
              Icons.badge,
              Colors.cyan,
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            _buildStatCard(
              theme,
              'Premium Men',
              _stats['premium_men']?.toString() ?? '0',
              Icons.stars,
              Colors.blue,
            ),
            SizedBox(width: 3.w),
            _buildStatCard(
              theme,
              'Premium Women',
              _stats['premium_women']?.toString() ?? '0',
              Icons.stars,
              Colors.pink,
            ),
          ],
        ),
        SizedBox(height: 3.h),
        _buildGenderStats(theme),
      ],
    );
  }

  Widget _buildGrowthSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Growth',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildStatCard(
              theme,
              'Completed Referrals',
              _stats['completed_referrals']?.toString() ?? '0',
              Icons.person_add_alt_1,
              Colors.pink,
            ),
            SizedBox(width: 3.w),
            _buildStatCard(
              theme,
              'Active Creators',
              _stats['total_creators']?.toString() ?? '0',
              Icons.campaign,
              Colors.deepOrange,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildGenderStats(ThemeData theme) {
    final maleCount = _stats['men_count'] ?? 0;
    final femaleCount = _stats['women_count'] ?? 0;
    final total = maleCount + femaleCount;
    final malePct = total > 0 ? maleCount / total : 0.0;
    final femalePct = total > 0 ? femaleCount / total : 0.0;

    return GlassmorphismContainer(
      padding: EdgeInsets.all(4.w),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.05,
      child: Column(
        children: [
          _buildDistributionRow('Men', maleCount, malePct, Colors.blue, theme),
          SizedBox(height: 2.h),
          _buildDistributionRow('Women', femaleCount, femalePct, Colors.pink, theme),
        ],
      ),
    );
  }


  Widget _buildDistributionRow(String label, int count, double pct, Color color, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$count (${(pct * 100).toStringAsFixed(1)}%)', style: theme.textTheme.bodySmall),
          ],
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }


  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: GlassmorphismContainer(
        padding: EdgeInsets.all(3.w),
        borderRadius: BorderRadius.circular(20),
        blur: 10,
        opacity: 0.05,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 8.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    final List<Map<String, dynamic>> items = [
      {'key': 'Dashboard', 'label': 'Dash', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard},
      {'key': 'Review', 'label': 'Review', 'icon': Icons.rate_review_outlined, 'activeIcon': Icons.rate_review},
      {'key': 'Payments', 'label': 'Pay', 'icon': Icons.payments_outlined, 'activeIcon': Icons.payments},
      {'key': 'Offers', 'label': 'Offers', 'icon': Icons.local_offer_outlined, 'activeIcon': Icons.local_offer},
      {'key': 'Creators', 'label': 'Creators', 'icon': Icons.campaign_outlined, 'activeIcon': Icons.campaign},
      {'key': 'Discounts', 'label': 'Discs', 'icon': Icons.percent_outlined, 'activeIcon': Icons.percent},
      {'key': 'Team', 'label': 'Team', 'icon': Icons.headset_mic_outlined, 'activeIcon': Icons.headset_mic},
      {'key': 'Users', 'label': 'Users', 'icon': Icons.people_outlined, 'activeIcon': Icons.people},
    ];

    int currentIndex = items.indexWhere((item) => item['key'] == _activeTab);
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          final newTab = items[index]['key'];
          setState(() => _activeTab = newTab);
          if (newTab == 'Users' && _users.isEmpty) {
            _loadUsers('');
          } else if (newTab == 'Team') {
            // Team tab loads its own data internally
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.hintColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon']),
            activeIcon: Icon(item['activeIcon']),
            label: item['label'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentSliver(ThemeData theme) {
    if (_activeTab == 'Dashboard') {
      return _buildDashboardOverviewSliver(theme);
    } else if (_activeTab == 'Review') {
      return SliverMainAxisGroup(
        slivers: [
          _buildVerificationsListSliver(theme),
          _buildReferencesListSliver(theme),
        ],
      );
    } else if (_activeTab == 'Payments') {
      return _buildPaymentsListSliver(theme);
    } else if (_activeTab == 'Offers') {
      return CouponManagementTab(theme: theme);
    } else if (_activeTab == 'Discounts') {
      return SpecialDiscountTab(theme: theme);
    } else if (_activeTab == 'Creators') {
      return _buildCreatorsListSliver(theme);
    } else if (_activeTab == 'Team') {
      return TeamManagementTab(theme: theme);
    } else {
      return _buildUsersManagementSliver(theme);
    }
  }

  Widget _buildCreatorsListSliver(ThemeData theme) {
    if (_creators.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'people_outline',
                size: 64,
                color: theme.hintColor,
              ),
              SizedBox(height: 2.h),
              Text(
                'No creators found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton.icon(
                onPressed: _showCreatorForm,
                icon: const Icon(Icons.add),
                label: const Text('Add First Creator'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final creator = _creators[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: StaggeredListItem(
                index: index,
                child: GlassmorphismContainer(
                  padding: EdgeInsets.all(4.w),
                  borderRadius: BorderRadius.circular(20),
                  blur: 10,
                  opacity: 0.1,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.person, color: theme.colorScheme.primary),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      creator.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        creator.promoCode,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (creator.instagramHandle != null)
                                  Text(
                                    '@${creator.instagramHandle}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCreatorMetric('Referrals', creator.totalReferrals.toString()),
                          _buildCreatorMetric('Conversions', creator.totalConversions.toString()),
                          _buildCreatorMetric('Earnings', '₹${creator.totalCommissionEarned.toStringAsFixed(0)}'),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showCreatorForm(creator: creator),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          if (creator.phoneNumber != null && creator.phoneNumber!.isNotEmpty) ...[
                            SizedBox(width: 2.w),
                            _buildContactAction(
                              icon: Icons.call,
                              label: 'Call',
                              color: Colors.blue,
                              onTap: () => _launchCaller(creator.phoneNumber!),
                              theme: theme,
                            ),
                            SizedBox(width: 2.w),
                            _buildContactAction(
                              icon: Icons.chat,
                              label: 'WhatsApp',
                              color: Colors.green,
                              onTap: () => _launchWhatsApp(creator.phoneNumber!),
                              theme: theme,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: _creators.length,
        ),
      ),
    );
  }

  Widget _buildCreatorMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8.sp, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  void _showCreatorForm({Creator? creator}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _CreatorForm(
          creator: creator,
          onSuccess: () {
            _loadData();
            if (mounted) Navigator.pop(context);
          },
          influencerRepository: _influencerRepository,
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (userId.isNotEmpty)
                                  Text(
                                    'ID: $userId',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontSize: 10,
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
                                          _buildContactAction(
                                            icon: Icons.call,
                                            label: 'Call',
                                            color: Colors.blue,
                                            onTap: () => _launchCaller(userPhone),
                                            theme: theme,
                                          ),
                                          SizedBox(width: 2.w),
                                          _buildContactAction(
                                            icon: Icons.chat,
                                            label: 'WhatsApp',
                                            color: Colors.green,
                                            onTap: () => _launchWhatsApp(userPhone),
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
                                fontWeight: FontWeight.bold,
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
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 8.sp),
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

  Widget _buildPaymentsListSliver(ThemeData theme) {
    return SliverMainAxisGroup(
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search payments (name, email, promo)...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _paymentSearchQuery = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: GlassmorphismContainer(
              padding: const EdgeInsets.all(6),
              borderRadius: BorderRadius.circular(20),
              opacity: 0.08,
              child: Row(
                children: [
                  Expanded(child: _buildPaymentSubTab('Subscription', Icons.card_membership, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildPaymentSubTab('PDF', Icons.picture_as_pdf, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildPaymentSubTab('Tester', Icons.bug_report, theme)),
                ],
              ),
            ),
          ),
        ),
        _buildFilteredPaymentsSliver(theme),
      ],
    );
  }

  Widget _buildPaymentSubTab(String label, IconData icon, ThemeData theme) {
    final isActive = _activePaymentSubTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activePaymentSubTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1.5) : null,
          boxShadow: isActive ? [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7),
            ),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 8.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredPaymentsSliver(ThemeData theme) {
    if (_isPaymentsLoading && _payments.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_payments.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.money_off, size: 64, color: Colors.grey),
              SizedBox(height: 2.h),
              Text(
                'No transactions found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredPayments = _payments.where((p) {
      final profile = p['profiles'] as Map?;
      final userName = profile?['full_name']?.toString().toLowerCase() ?? '';
      final userEmail = profile?['email']?.toString().toLowerCase() ?? '';
      final promoCode = p['promo_code']?.toString().toLowerCase() ?? '';
      
      // 1. Filter by Search Query (Client-side)
      if (_paymentSearchQuery.isNotEmpty) {
        final query = _paymentSearchQuery.toLowerCase();
        final matchesSearch = userName.contains(query) || 
                            userEmail.contains(query) || 
                            promoCode.contains(query);
        if (!matchesSearch) return false;
      }

      final isOfficialTester = userEmail == 'tester@banjarabio.com';
      final isMarkedAsTest = p['is_test'] == true;
      final isTesterData = isOfficialTester || isMarkedAsTest;

      if (_activePaymentSubTab == 'Tester') {
        return isTesterData;
      }
      
      // For all other tabs, exclude tester data
      if (isTesterData) return false;

      if (_activePaymentSubTab == 'PDF') {
        return p['category'] == 'PDF' || p['plan_type'] == 'biodata_unlock';
      }
      
      // Default: Subscription tab
      return p['category'] == 'Subscription' || p['plan_type'] != 'biodata_unlock';
    }).toList();

    if (filteredPayments.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _activePaymentSubTab == 'PDF' ? Icons.picture_as_pdf : (_activePaymentSubTab == 'Tester' ? Icons.bug_report : Icons.card_membership),
                size: 64,
                color: theme.hintColor.withValues(alpha: 0.3),
              ),
              SizedBox(height: 2.h),
              Text(
                'No $_activePaymentSubTab transactions',
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
            final payment = filteredPayments[index];
            final profile = payment['profiles'] as Map?;
            final category = payment['category'] ?? 'Subscription';
            final amount = payment['amount_rupees'] ?? 0.0;
            final isTest = payment['is_test'] == true;
            final date = payment['created_at'] != null 
                ? DateTime.parse(payment['created_at']).toLocal() 
                : DateTime.now();

            return StaggeredListItem(
              index: index,
              child: Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: GlassmorphismContainer(
                  padding: EdgeInsets.all(4.w),
                  borderRadius: BorderRadius.circular(20),
                  opacity: 0.1,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isTest ? Colors.red : (category == 'PDF' ? Colors.orange : Colors.blue)).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isTest ? Icons.bug_report : (category == 'PDF' ? Icons.picture_as_pdf : Icons.card_membership),
                          color: isTest ? Colors.red : (category == 'PDF' ? Colors.orange : Colors.blue),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                   child: Text(
                                     '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim().isEmpty
                                         ? 'Unknown User'
                                         : '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim(),
                                     style: const TextStyle(fontWeight: FontWeight.bold),
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                ),
                                if (isTest)
                                  Container(
                                    margin: EdgeInsets.only(left: 2.w),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'TEST',
                                      style: TextStyle(color: Colors.red, fontSize: 7.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            if (payment['user_id'] != null)
                              Text('ID: ${payment['user_id']}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.hintColor)),
                            Text(
                              profile?['email'] ?? 'No email available',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                             Text(
                               '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                               style: theme.textTheme.bodySmall?.copyWith(fontSize: 8.sp),
                             ),
                             if (profile?['phone_number'] != null && profile!['phone_number'].toString().isNotEmpty) ...[
                               SizedBox(height: 1.h),
                               Row(
                                 children: [
                                   _buildContactAction(
                                     icon: Icons.call,
                                     label: 'Call',
                                     color: Colors.blue,
                                     onTap: () => _launchCaller(profile['phone_number'].toString()),
                                     theme: theme,
                                   ),
                                   SizedBox(width: 2.w),
                                   _buildContactAction(
                                     icon: Icons.chat,
                                     label: 'WhatsApp',
                                     color: Colors.green,
                                     onTap: () => _launchWhatsApp(profile['phone_number'].toString()),
                                     theme: theme,
                                   ),
                                 ],
                               ),
                             ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (category == 'PDF' ? Colors.orange : Colors.blue).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: category == 'PDF' ? Colors.orange : Colors.blue,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: filteredPayments.length,
        ),
      ),
    );
  }

  Widget _buildUsersManagementSliver(ThemeData theme) {
    // We now rely entirely on server-side filtering via _loadUsers
    final filteredUsers = _users;

    return SliverMainAxisGroup(
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.searchUserName ?? 'Search user...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _loadUsers,
            ),
          ),
        ),

        // User Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: Row(
              children: [
                Expanded(
                  child: _buildShortStatCard(
                    'Total Females',
                    _stats['women_count']?.toString() ?? '0',
                    Colors.pink,
                    Icons.female,
                    theme,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildShortStatCard(
                    'Total Males',
                    _stats['men_count']?.toString() ?? '0',
                    Colors.blue,
                    Icons.male,
                    theme,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Custom Topside Tabs
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: GlassmorphismContainer(
              padding: const EdgeInsets.all(6),
              borderRadius: BorderRadius.circular(20),
              opacity: 0.08,
              child: Row(
                children: [
                  Expanded(child: _buildUserSubTab('Female', Icons.female, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildUserSubTab('Male', Icons.male, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildUserSubTab('Paid', Icons.star, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildUserSubTab('Testers', Icons.bug_report, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildUserSubTab('Deleted', Icons.delete_outline, theme)),
                ],
              ),
            ),
          ),
        ),

        if (_isUsersLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filteredUsers.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _activeUserSubTab == 'Female'
                        ? Icons.female
                        : _activeUserSubTab == 'Male'
                            ? Icons.male
                            : Icons.star_outline,
                    size: 64,
                    color: theme.hintColor.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No $_activeUserSubTab users found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = filteredUsers[index];
                  return StaggeredListItem(
                    index: index,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 1.5.h),
                      child: GlassmorphismContainer(
                        padding: EdgeInsets.all(2.w),
                        borderRadius: BorderRadius.circular(20),
                        opacity: 0.05,
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/biodata-creation-screen',
                              arguments: {
                                'isEditMode': true,
                                'isAdminEdit': true,
                                'profile': user,
                              },
                            );
                            if (result != null && mounted) {
                              _loadUsers('');
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Avatar
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundImage: user.photos.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            user.photos.first.publicUrl,
                                            maxWidth: 112,
                                            maxHeight: 112,
                                            cacheManager: PersistentCacheManager.instance,
                                            cacheKey: PersistentCacheManager.stableKeyFor(user.photos.first.publicUrl),
                                          )
                                        : null,
                                    child: user.photos.isEmpty
                                        ? const Icon(Icons.person, size: 32)
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                
                                // Center: User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user.fullName,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (user.isPremium)
                                            Icon(Icons.stars, color: Colors.amber, size: 16.sp),
                                        ],
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Row(
                                        children: [
                                          Text(
                                            user.gender,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: user.gender.toLowerCase() == 'female' ? Colors.pink : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(' • ', style: theme.textTheme.bodySmall),
                                          Text(
                                            AppLocalizations.of(context)?.idLabel(user.id.substring(0, 8)) ?? 'ID: ${user.id.substring(0, 8)}',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          user.phoneNumber!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.hintColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                      SizedBox(height: 1.5.h),
                                      
                                      // Verify Chips Row
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildManualVerifyChip(
                                              AppLocalizations.of(context)?.emailLabel ?? 'Email',
                                              user.emailVerified,
                                              () => _manualVerify(user.id, email: true),
                                            ),
                                            SizedBox(width: 2.w),
                                            _buildManualVerifyChip(
                                              AppLocalizations.of(context)?.phoneLabel ?? 'Phone',
                                              user.phoneVerified,
                                              () => _manualVerify(user.id, phone: true),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      SizedBox(height: 1.5.h),
                                      
                                      // Action Row: Call & WhatsApp
                                      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                                        Row(
                                          children: [
                                            _buildContactAction(
                                              icon: Icons.call,
                                              label: 'Call',
                                              color: Colors.blue,
                                              onTap: () => _launchCaller(user.phoneNumber!),
                                              theme: theme,
                                            ),
                                            SizedBox(width: 3.w),
                                            _buildContactAction(
                                              icon: Icons.chat,
                                              label: 'WhatsApp',
                                              color: Colors.green,
                                              onTap: () => _launchWhatsApp(user.phoneNumber!),
                                              theme: theme,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                
                                // Right: Edit Button
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: filteredUsers.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserSubTab(String label, IconData icon, ThemeData theme) {
    final isActive = _activeUserSubTab == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeUserSubTab = label);
        _loadUsers('');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1.5) : null,
          boxShadow: isActive ? [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7),
            ),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 8.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortStatCard(String label, String value, Color color, IconData icon, ThemeData theme) {
    return GlassmorphismContainer(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.05,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 8.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
          fontWeight: FontWeight.bold,
          fontSize: 8.sp,
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
          fontWeight: FontWeight.bold,
          fontSize: 8.sp,
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualVerifyChip(
    String label,
    bool isVerified,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: isVerified ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: isVerified
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isVerified ? Colors.green : Colors.orange),
        ),
        child: Text(
          isVerified ? '$label ✓' : (AppLocalizations.of(context)?.verifyLabel(label) ?? 'Verify $label'),
          style: TextStyle(
            fontSize: 8.sp,
            color: isVerified ? Colors.green[700] : Colors.orange[700],
            fontWeight: FontWeight.bold,
          ),
        ),
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
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
            fontWeight: FontWeight.bold,
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
                        future: _adminRepository.getSignedUrl(StorageConfig.verificationDocs, pathOrUrl),
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
            future: _adminRepository.getSignedUrl(
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
                                fontWeight: FontWeight.bold, 
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
                  future: _adminRepository.getSignedUrl(
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
                                    Text('404', style: TextStyle(color: Colors.red, fontSize: 8.sp, fontWeight: FontWeight.bold)),
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

class _CreatorForm extends StatefulWidget {
  final Creator? creator;
  final VoidCallback onSuccess;
  final InfluencerRepository influencerRepository;

  const _CreatorForm({
    required this.creator,
    required this.onSuccess,
    required this.influencerRepository,
  });

  @override
  State<_CreatorForm> createState() => _CreatorFormState();
}

class _CreatorFormState extends State<_CreatorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _promoController;
  late final TextEditingController _instaController;
  late final TextEditingController _phoneController;
  late final TextEditingController _commissionController;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.creator?.name);
    _promoController = TextEditingController(text: widget.creator?.promoCode);
    _instaController = TextEditingController(text: widget.creator?.instagramHandle);
    _phoneController = TextEditingController(text: widget.creator?.phoneNumber);
    _commissionController = TextEditingController(
      text: (widget.creator?.commissionPct ?? 0.1).toString(),
    );
    _isActive = widget.creator?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promoController.dispose();
    _instaController.dispose();
    _phoneController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final response = widget.creator == null
        ? await widget.influencerRepository.addCreator(
            name: _nameController.text.trim(),
            promoCode: _promoController.text.trim().toUpperCase(),
            commissionPct: double.tryParse(_commissionController.text) ?? 0.1,
            instagramHandle: _instaController.text.trim().isEmpty ? null : _instaController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          )
        : await widget.influencerRepository.updateCreator(
            id: widget.creator!.id,
            name: _nameController.text.trim(),
            commissionPct: double.tryParse(_commissionController.text),
            instagramHandle: _instaController.text.trim().isEmpty ? null : _instaController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            isActive: _isActive,
          );

    setState(() => _isSubmitting = false);

    response.fold(
      onSuccess: (_) => widget.onSuccess(),
      onFailure: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.creator != null;

    return GlassmorphismContainer(
      padding: EdgeInsets.only(
        left: 6.w,
        right: 6.w,
        top: 2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 4.h,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      blur: 20,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Influencer' : 'Add New Influencer',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              Text(
                isEdit ? 'Update details for ${widget.creator!.name}' : 'Register a new creator for influencer marketing',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              SizedBox(height: 4.h),
              _buildField(
                label: 'Creator Name',
                controller: _nameController,
                icon: Icons.person_outline,
                validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              SizedBox(height: 2.h),
              _buildField(
                label: 'Promo Code',
                controller: _promoController,
                icon: Icons.local_offer_outlined,
                enabled: !isEdit,
                hintText: 'e.g. BANJARA10',
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v?.isEmpty ?? true ? 'Promo code is required' : null,
              ),
              SizedBox(height: 2.h),
              _buildField(
                label: 'Instagram Handle',
                controller: _instaController,
                icon: Icons.alternate_email,
                hintText: '@username (optional)',
              ),
              SizedBox(height: 2.h),
              _buildField(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hintText: 'e.g. +91 9876543210 (optional)',
              ),
              SizedBox(height: 2.h),
              _buildField(
                label: 'Commission %',
                controller: _commissionController,
                icon: Icons.percent,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: '0.1 = 10%',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Commission is required';
                  final d = double.tryParse(v);
                  if (d == null || d < 0 || d > 1) return 'Must be between 0 and 1';
                  return null;
                },
              ),
              if (isEdit) ...[
                SizedBox(height: 2.h),
                GlassmorphismContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(16),
                  blur: 5,
                  opacity: 0.05,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Account Status'),
                    subtitle: Text(_isActive ? 'Active' : 'Deactivated'),
                    value: _isActive,
                    activeThumbColor: theme.colorScheme.primary,
                    activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ),
              ],
              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                height: 7.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update Creator' : 'Register Creator',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? hintText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: TextStyle(fontSize: 11.sp),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class TimeAgo {
  static String format(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
