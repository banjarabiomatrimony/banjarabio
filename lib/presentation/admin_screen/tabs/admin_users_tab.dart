import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/staggered_list_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/presentation/admin_screen/admin_helpers.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// User management tab with search, gender / premium / tester sub-tabs,
/// verification chips, and edit navigation.
class AdminUsersTab extends StatefulWidget {
  final AdminRepository adminRepository;

  const AdminUsersTab({super.key, required this.adminRepository});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  bool _isLoading = false;
  List<ProfileModel> _users = [];
  String _activeSubTab = 'Female';
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUsers('');
  }

  Future<void> _loadStats() async {
    final res = await widget.adminRepository.getAdminStats();
    res.fold(
      onSuccess: (data) { if (mounted) setState(() => _stats = data); },
      onFailure: (_) {},
    );
  }

  Future<void> _loadUsers(String query) async {
    setState(() => _isLoading = true);
    try {
      String? gender;
      bool? isPremium;
      bool? isActive;

      if (_activeSubTab == 'Female') { gender = 'Female'; isActive = true; }
      else if (_activeSubTab == 'Male') { gender = 'Male'; isActive = true; }
      else if (_activeSubTab == 'Paid') { isPremium = true; isActive = true; }
      else if (_activeSubTab == 'Deleted') { isActive = false; }
      else if (_activeSubTab == 'Testers') { isActive = true; }
      else { isActive = true; }

      final response = await widget.adminRepository.getAllProfiles(
        searchQuery: query, gender: gender, isPremium: isPremium,
        isActive: isActive, onlyTesters: _activeSubTab == 'Testers',
      );
      await response.fold(
        onSuccess: (users) { if (mounted) setState(() { _users = users; _isLoading = false; }); },
        onFailure: (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            AppLogger.error('AdminUsersTab', 'Error loading users: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.errorLoadingAdminUsers ?? 'Could not fetch user list.')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _manualVerify(String userId, {bool email = false, bool phone = false}) async {
    try {
      final response = await widget.adminRepository.verifyProfileManually(userId, email: email, phone: phone);
      await response.fold(
        onSuccess: (_) async => await _loadUsers(''),
        onFailure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.failedToVerify(error) ?? 'Failed to verify: $error')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.errorPrefix(e.toString()) ?? 'Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                prefixIcon: const Icon(Icons.search), filled: true, fillColor: theme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: _loadUsers,
            ),
          ),
        ),
        // Gender Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: Row(children: [
              Expanded(child: _buildShortStatCard('Total Females', _stats['women_count']?.toString() ?? '0', Colors.pink, Icons.female, theme)),
              SizedBox(width: 4.w),
              Expanded(child: _buildShortStatCard('Total Males', _stats['men_count']?.toString() ?? '0', Colors.blue, Icons.male, theme)),
            ]),
          ),
        ),
        // Sub-tabs
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: GlassmorphismContainer(
              padding: const EdgeInsets.all(6), borderRadius: BorderRadius.circular(20), opacity: 0.08,
              child: Row(children: [
                Expanded(child: _buildSubTab('Female', Icons.female, theme)),
                const SizedBox(width: 4),
                Expanded(child: _buildSubTab('Male', Icons.male, theme)),
                const SizedBox(width: 4),
                Expanded(child: _buildSubTab('Paid', Icons.star, theme)),
                const SizedBox(width: 4),
                Expanded(child: _buildSubTab('Testers', Icons.bug_report, theme)),
                const SizedBox(width: 4),
                Expanded(child: _buildSubTab('Deleted', Icons.delete_outline, theme)),
              ]),
            ),
          ),
        ),
        // List
        if (_isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (filteredUsers.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_activeSubTab == 'Female' ? Icons.female : _activeSubTab == 'Male' ? Icons.male : Icons.star_outline, size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
              SizedBox(height: 2.h),
              Text('No $_activeSubTab users found', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
            ])),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildUserCard(filteredUsers[index], index, theme),
                childCount: filteredUsers.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(ProfileModel user, int index, ThemeData theme) {
    return StaggeredListItem(
      index: index,
      child: Padding(
        padding: EdgeInsets.only(bottom: 1.5.h),
        child: GlassmorphismContainer(
          padding: EdgeInsets.all(2.w), borderRadius: BorderRadius.circular(20), opacity: 0.05,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/biodata-creation-screen', arguments: {'isEditMode': true, 'isAdminEdit': true, 'profile': user});
              if (result != null && mounted) _loadUsers('');
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 2)),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: user.photos.isNotEmpty
                        ? CachedNetworkImageProvider(user.photos.first.publicUrl, maxWidth: 112, maxHeight: 112, cacheManager: PersistentCacheManager.instance, cacheKey: PersistentCacheManager.stableKeyFor(user.photos.first.publicUrl))
                        : null,
                    child: user.photos.isEmpty ? const Icon(Icons.person, size: 32) : null,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(user.fullName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                    if (user.isPremium) Icon(Icons.stars, color: Colors.amber, size: 16.sp),
                  ]),
                  SizedBox(height: 0.5.h),
                  Row(children: [
                    Text(user.gender, style: theme.textTheme.bodySmall?.copyWith(color: user.gender.toLowerCase() == 'female' ? Colors.pink : Colors.blue, fontWeight: FontWeight.bold)),
                    Text(' • ', style: theme.textTheme.bodySmall),
                    Text(AppLocalizations.of(context)?.idLabel(user.id.substring(0, 8)) ?? 'ID: ${user.id.substring(0, 8)}', style: theme.textTheme.bodySmall),
                  ]),
                  if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(user.phoneNumber!, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w500)),
                  ],
                  SizedBox(height: 1.5.h),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                    _buildVerifyChip(AppLocalizations.of(context)?.emailLabel ?? 'Email', user.emailVerified, () => _manualVerify(user.id, email: true)),
                    SizedBox(width: 2.w),
                    _buildVerifyChip(AppLocalizations.of(context)?.phoneLabel ?? 'Phone', user.phoneVerified, () => _manualVerify(user.id, phone: true)),
                  ])),
                  SizedBox(height: 1.5.h),
                  if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                    Row(children: [
                      buildAdminContactAction(icon: Icons.call, label: 'Call', color: Colors.blue, onTap: () => launchCaller(context, user.phoneNumber!), theme: theme),
                      SizedBox(width: 3.w),
                      buildAdminContactAction(icon: Icons.chat, label: 'WhatsApp', color: Colors.green, onTap: () => launchWhatsApp(context, user.phoneNumber!), theme: theme),
                    ]),
                ])),
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.primary),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(String label, IconData icon, ThemeData theme) {
    final isActive = _activeSubTab == label;
    return GestureDetector(
      onTap: () { setState(() => _activeSubTab = label); _loadUsers(''); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1.5) : null,
          boxShadow: isActive ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14.sp, color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7)),
          SizedBox(width: 1.5.w),
          Text(label, style: TextStyle(color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7), fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: AppTypography.labelMedium)),
        ]),
      ),
    );
  }

  Widget _buildShortStatCard(String label, String value, Color color, IconData icon, ThemeData theme) {
    return GlassmorphismContainer(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h), borderRadius: BorderRadius.circular(20), opacity: 0.05,
      child: Row(children: [
        Container(padding: EdgeInsets.all(2.w), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 16.sp)),
        SizedBox(width: 3.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.8))),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: AppTypography.labelSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _buildVerifyChip(String label, bool isVerified, VoidCallback onTap) {
    return InkWell(
      onTap: isVerified ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: isVerified ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isVerified ? Colors.green : Colors.orange),
        ),
        child: Text(
          isVerified ? '$label ✓' : (AppLocalizations.of(context)?.verifyLabel(label) ?? 'Verify $label'),
          style: TextStyle(fontSize: AppTypography.labelSmall, color: isVerified ? Colors.green[700] : Colors.orange[700], fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
