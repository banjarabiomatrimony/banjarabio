import 'package:banjarabio/core/constants/app_typography.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/config/admin_config.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';

// Tab imports
import 'package:banjarabio/presentation/admin_screen/tabs/admin_overview_tab.dart';
import 'package:banjarabio/presentation/admin_screen/tabs/admin_review_tab.dart';
import 'package:banjarabio/presentation/admin_screen/tabs/admin_payments_tab.dart';
import 'package:banjarabio/presentation/admin_screen/tabs/admin_creators_tab.dart';
import 'package:banjarabio/presentation/admin_screen/tabs/admin_users_tab.dart';
import 'package:banjarabio/presentation/admin_screen/coupon_management_tab.dart';
import 'package:banjarabio/presentation/admin_screen/special_discount_tab.dart';
import 'package:banjarabio/presentation/admin_screen/team_management_tab.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/theme/app_colors.dart';

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
  String _activeTab = 'Dashboard';
  final ScrollController _scrollController = ScrollController();

  // Key for accessing CreatorsTab public method
  final GlobalKey<AdminCreatorsTabState> _creatorsKey = GlobalKey<AdminCreatorsTabState>();

  @override
  void initState() {
    super.initState();
    _adminRepository = widget.adminRepository ?? AdminRepository();
    _influencerRepository = widget.influencerRepository ?? InfluencerRepository();
    _profileRepository = widget.profileRepository ?? ProfileRepository();
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    final currentUser = AppSupabaseClient.currentUser;
    final userEmail = currentUser?.email?.toLowerCase() ?? '';

    if (AdminConfig.isAdminEmail(userEmail)) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

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
        if (mounted) setState(() => _isLoading = false);
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

  Future<void> _handleLogout() async {
    try {
      await AppSupabaseClient.client.auth.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
    } catch (e) {
      AppLogger.error('AdminDashboardScreen', 'Logout error: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        child: Column(
          children: [
            _buildPremiumHeader(theme),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [_buildContentSliver(theme)],
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
            color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
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
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: AppTypography.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: AppColors.opacity70)),
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
                      onPressed: () => _creatorsKey.currentState?.showCreatorForm(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add New Influencer', style: TextStyle(color: Colors.white, fontWeight: AppTypography.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: AppColors.opacity20),
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

  Widget _buildContentSliver(ThemeData theme) {
    switch (_activeTab) {
      case 'Dashboard':
        return AdminOverviewTab(adminRepository: _adminRepository);
      case 'Review':
        return AdminReviewTab(adminRepository: _adminRepository);
      case 'Payments':
        return AdminPaymentsTab(adminRepository: _adminRepository);
      case 'Offers':
        return CouponManagementTab(theme: theme);
      case 'Discounts':
        return SpecialDiscountTab(theme: theme);
      case 'Creators':
        return AdminCreatorsTab(key: _creatorsKey, influencerRepository: _influencerRepository);
      case 'Team':
        return TeamManagementTab(theme: theme);
      case 'Users':
        return AdminUsersTab(adminRepository: _adminRepository);
      default:
        return AdminOverviewTab(adminRepository: _adminRepository);
    }
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: AppColors.opacity10), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => _activeTab = items[index]['key']),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.hintColor,
        selectedLabelStyle: const TextStyle(fontWeight: AppTypography.bold),
        items: items.map((item) => BottomNavigationBarItem(
          icon: Icon(item['icon']),
          activeIcon: Icon(item['activeIcon']),
          label: item['label'],
        )).toList(),
      ),
    );
  }
}
