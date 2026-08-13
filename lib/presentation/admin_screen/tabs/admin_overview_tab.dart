import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Dashboard overview tab showing financial, engagement, safety,
/// demographics, and growth statistics.
class AdminOverviewTab extends StatefulWidget {
  final AdminRepository adminRepository;

  const AdminOverviewTab({super.key, required this.adminRepository});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  bool _isLoading = true;
  RealtimeChannel? _realtimeChannel;
  Timer? _debounceTimer;

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

  @override
  void initState() {
    super.initState();
    _loadStats();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_realtimeChannel != null && AppSupabaseClient.isInitialized) {
      AppSupabaseClient.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    try {
      if (!AppSupabaseClient.isInitialized) return;
      _realtimeChannel = AppSupabaseClient.client
          .channel('public:admin_stats')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            callback: (_) => _refreshStatsDebounced(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'payments',
            callback: (_) => _refreshStatsDebounced(),
          )
          .subscribe();
      AppLogger.debug('AdminOverviewTab', '📡 Supabase Realtime subscribed for admin stats');
    } catch (e) {
      AppLogger.warn('AdminOverviewTab', 'Failed to subscribe to Realtime: $e');
    }
  }

  void _refreshStatsDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) _loadStats(showLoading: false);
    });
  }

  Future<void> _loadStats({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    final statsRes = await widget.adminRepository.getAdminStats();
    statsRes.fold(
      onSuccess: (data) {
        if (mounted) setState(() => _stats = data);
      },
      onFailure: (e) {
        AppLogger.error('AdminOverviewTab', 'Stats failed: $e');
      },
    );
    if (mounted && showLoading) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final theme = Theme.of(context);
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

  // ─── Revenue ────────────────────────────────────────────────────────────────

  Widget _buildRevenueSection(ThemeData theme) {
    final lastMonthName = DateFormat('MMMM').format(DateTime(DateTime.now().year, DateTime.now().month - 1));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Financial Performance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Icon(Icons.trending_up, color: Colors.green, size: 20),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Time Revenue', style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('EXCLUSIVE TESTER', style: TextStyle(color: Colors.green, fontSize: AppTypography.labelSmall, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2.w, crossAxisSpacing: 2.w, childAspectRatio: 0.9,
          children: [
            _buildStatCardSimple(theme, 'Combined', '₹${_stats['revenue_total']?.toStringAsFixed(0) ?? '0'}', Icons.account_balance_wallet, Colors.green),
            _buildStatCardSimple(theme, 'Subscription', '₹${_stats['revenue_subscription']?.toStringAsFixed(0) ?? '0'}', Icons.card_membership, Colors.blue),
            _buildStatCardSimple(theme, 'PDF Rev', '₹${_stats['revenue_pdf']?.toStringAsFixed(0) ?? '0'}', Icons.picture_as_pdf, Colors.orange),
          ],
        ),
        SizedBox(height: 2.h),
        Text('Last Month ($lastMonthName)', style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)),
        SizedBox(height: 1.h),
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2.w, crossAxisSpacing: 2.w, childAspectRatio: 0.9,
          children: [
            _buildStatCardSimple(theme, 'Combined', '₹${_stats['revenue_last_month']?.toStringAsFixed(0) ?? '0'}', Icons.history, Colors.teal),
            _buildStatCardSimple(theme, 'Subscription', '₹${_stats['revenue_last_month_subscription']?.toStringAsFixed(0) ?? '0'}', Icons.card_membership, Colors.indigo),
            _buildStatCardSimple(theme, 'PDF Rev', '₹${_stats['revenue_last_month_pdf']?.toStringAsFixed(0) ?? '0'}', Icons.picture_as_pdf, Colors.deepOrange),
          ],
        ),
      ],
    );
  }

  // ─── Engagement ─────────────────────────────────────────────────────────────

  Widget _buildEngagementSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('User Engagement', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 2.h),
        Row(children: [
          _buildStatCard(theme, 'Daily Active Users', _stats['dau_today']?.toString() ?? '0', Icons.bolt, Colors.orange),
          SizedBox(width: 3.w),
          _buildStatCard(theme, 'Profile Views', _stats['total_profile_views']?.toString() ?? '0', Icons.visibility, Colors.blue),
        ]),
        SizedBox(height: 3.w),
        Row(children: [
          _buildStatCard(theme, 'Total Messages', _stats['total_messages']?.toString() ?? '0', Icons.chat_bubble, Colors.purple),
          SizedBox(width: 3.w),
          _buildStatCard(theme, 'Conversations', _stats['total_conversations']?.toString() ?? '0', Icons.forum, Colors.indigo),
        ]),
      ],
    );
  }

  // ─── Safety ─────────────────────────────────────────────────────────────────

  Widget _buildSafetyHealthSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Safety & Health', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 2.h),
        Row(children: [
          _buildStatCard(theme, 'Pending Reports', _stats['pending_reports']?.toString() ?? '0', Icons.report_problem, Colors.red),
          SizedBox(width: 3.w),
          _buildStatCard(theme, 'Total Blocks', _stats['total_blocks']?.toString() ?? '0', Icons.block, Colors.grey),
        ]),
        SizedBox(height: 3.w),
        Row(children: [
          _buildStatCard(theme, 'Pending Verif', _stats['pending_verifications']?.toString() ?? '0', Icons.verified_user, Colors.blueGrey),
          SizedBox(width: 3.w),
          _buildStatCard(theme, 'Pending Refs', _stats['pending_references']?.toString() ?? '0', Icons.thumbs_up_down, Colors.brown),
        ]),
      ],
    );
  }

  // ─── Demographics ───────────────────────────────────────────────────────────

  Widget _buildDemographicsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Demographics & Premium', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 2.h),
        Row(children: [
          _buildStatCard(theme, 'Total Users', _stats['total_auth_users']?.toString() ?? '0', Icons.people, Colors.deepPurple),
          SizedBox(width: 3.w),
          _buildStatCard(theme, 'Profiles', _stats['total_profiles']?.toString() ?? '0', Icons.badge, Colors.cyan),
        ]),
        SizedBox(height: 3.w),
        Row(children: [
          _buildStatCard(theme, 'Premium Men', _stats['premium_men']?.toString() ?? '0', Icons.stars, Colors.blue),
          SizedBox(width: 3.w),
          _buildStatCard(theme, 'Premium Women', _stats['premium_women']?.toString() ?? '0', Icons.stars, Colors.pink),
        ]),
        SizedBox(height: 3.h),
        _buildGenderStats(theme),
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
            value: pct, backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ─── Growth ─────────────────────────────────────────────────────────────────

  Widget _buildGrowthSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Growth', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 2.h),
        Row(children: [
          _buildStatCard(theme, 'Completed Referrals', _stats['completed_referrals']?.toString() ?? '0', Icons.person_add_alt_1, Colors.pink),
          SizedBox(width: 3.w),
          _buildStatCard(theme, 'Active Creators', _stats['total_creators']?.toString() ?? '0', Icons.campaign, Colors.deepOrange),
        ]),
      ],
    );
  }

  // ─── Card Widgets ───────────────────────────────────────────────────────────

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassmorphismContainer(
        padding: EdgeInsets.all(3.w), borderRadius: BorderRadius.circular(20), blur: 10, opacity: 0.05,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 1.h),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: AppTypography.labelSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardSimple(ThemeData theme, String label, String value, IconData icon, Color color) {
    return GlassmorphismContainer(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
      borderRadius: BorderRadius.circular(12), blur: 8, opacity: 0.05,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 0.5.h),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: AppTypography.bodyLarge, color: theme.colorScheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontSize: AppTypography.labelMedium, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
