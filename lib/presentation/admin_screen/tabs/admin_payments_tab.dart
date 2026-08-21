import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/staggered_list_animation.dart';
import 'package:banjarabio/presentation/admin_screen/admin_helpers.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/csv_export_service.dart';

/// Payments management tab with search, sub-tab filtering
/// (Subscription / PDF / Tester), and detailed transaction cards.
class AdminPaymentsTab extends StatefulWidget {
  final AdminRepository adminRepository;

  const AdminPaymentsTab({super.key, required this.adminRepository});

  @override
  State<AdminPaymentsTab> createState() => _AdminPaymentsTabState();
}

class _AdminPaymentsTabState extends State<AdminPaymentsTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];
  String _activeSubTab = 'Subscription';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final response = await widget.adminRepository.getPaymentsList();
    response.fold(
      onSuccess: (payments) {
        if (mounted) setState(() { _payments = payments; _isLoading = false; });
      },
      onFailure: (e) {
        AppLogger.error('AdminPaymentsTab', 'Payments load failed: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverMainAxisGroup(
      slivers: [
        // Search Bar & Export Button
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: Row(
              children: [
                Expanded(
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
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                SizedBox(width: 2.w),
                IconButton.filledTonal(
                  onPressed: () {
                    CsvExportService.exportPaymentsToCsv(context, _payments);
                  },
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Export CSV',
                ),
              ],
            ),
          ),
        ),
        // Sub-tabs
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: GlassmorphismContainer(
              padding: const EdgeInsets.all(6), borderRadius: BorderRadius.circular(20), opacity: 0.08,
              child: Row(
                children: [
                  Expanded(child: _buildSubTab('Subscription', Icons.card_membership, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildSubTab('PDF', Icons.picture_as_pdf, theme)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildSubTab('Tester', Icons.bug_report, theme)),
                ],
              ),
            ),
          ),
        ),
        _buildFilteredList(theme),
      ],
    );
  }

  Widget _buildSubTab(String label, IconData icon, ThemeData theme) {
    final isActive = _activeSubTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeSubTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1.5) : null,
          boxShadow: isActive ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7)),
            SizedBox(width: 1.5.w),
            Text(label, style: TextStyle(color: isActive ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.7), fontWeight: isActive ? AppTypography.bold : AppTypography.medium, fontSize: AppTypography.labelMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(ThemeData theme) {
    if (_isLoading && _payments.isEmpty) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }
    if (_payments.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.money_off, size: 64, color: Colors.grey),
          SizedBox(height: 2.h),
          Text('No transactions found', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
        ])),
      );
    }

    final filteredPayments = _payments.where((p) {
      final profile = p['profiles'] as Map?;
      final userName = profile?['full_name']?.toString().toLowerCase() ?? '';
      final userEmail = profile?['email']?.toString().toLowerCase() ?? '';
      final promoCode = p['promo_code']?.toString().toLowerCase() ?? '';

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!userName.contains(query) && !userEmail.contains(query) && !promoCode.contains(query)) return false;
      }

      final isOfficialTester = userEmail == 'tester@banjarabio.com';
      final isMarkedAsTest = p['is_test'] == true;
      final isTesterData = isOfficialTester || isMarkedAsTest;

      if (_activeSubTab == 'Tester') return isTesterData;
      if (isTesterData) return false;
      if (_activeSubTab == 'PDF') return p['category'] == 'PDF' || p['plan_type'] == 'biodata_unlock';
      return p['category'] == 'Subscription' || p['plan_type'] != 'biodata_unlock';
    }).toList();

    if (filteredPayments.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_activeSubTab == 'PDF' ? Icons.picture_as_pdf : (_activeSubTab == 'Tester' ? Icons.bug_report : Icons.card_membership), size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
          SizedBox(height: 2.h),
          Text('No $_activeSubTab transactions', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
        ])),
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
            final date = payment['created_at'] != null ? DateTime.parse(payment['created_at']).toLocal() : DateTime.now();

            return StaggeredListItem(
              index: index,
              child: Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: GlassmorphismContainer(
                  padding: EdgeInsets.all(4.w), borderRadius: BorderRadius.circular(20), opacity: 0.1,
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
                            Row(children: [
                              Expanded(
                                child: Text(
                                  '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim().isEmpty ? 'Unknown User' : '${profile?['full_name'] ?? ''} ${profile?['surname'] ?? ''}'.trim(),
                                  style: const TextStyle(fontWeight: AppTypography.bold), maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isTest)
                                Container(
                                  margin: EdgeInsets.only(left: 2.w),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text('TEST', style: TextStyle(color: Colors.red, fontSize: AppTypography.labelSmall, fontWeight: AppTypography.bold)),
                                ),
                            ]),
                            if (payment['user_id'] != null)
                              Text('ID: ${payment['user_id']}', style: theme.textTheme.bodySmall?.copyWith(fontSize: AppTypography.labelSmall, color: theme.hintColor)),
                            Text(profile?['email'] ?? 'No email available', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 0.5.h),
                            Text('${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}', style: theme.textTheme.bodySmall?.copyWith(fontSize: AppTypography.labelSmall)),
                            if (profile?['phone_number'] != null && profile!['phone_number'].toString().isNotEmpty) ...[
                              SizedBox(height: 1.h),
                              Row(children: [
                                buildAdminContactAction(icon: Icons.call, label: 'Call', color: Colors.blue, onTap: () => launchCaller(context, profile['phone_number'].toString()), theme: theme),
                                SizedBox(width: 2.w),
                                buildAdminContactAction(icon: Icons.chat, label: 'WhatsApp', color: Colors.green, onTap: () => launchWhatsApp(context, profile['phone_number'].toString()), theme: theme),
                              ]),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: AppTypography.bold, fontSize: AppTypography.bodySmall)),
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: (category == 'PDF' ? Colors.orange : Colors.blue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(category, style: TextStyle(color: category == 'PDF' ? Colors.orange : Colors.blue, fontSize: AppTypography.labelSmall, fontWeight: AppTypography.bold)),
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
}
