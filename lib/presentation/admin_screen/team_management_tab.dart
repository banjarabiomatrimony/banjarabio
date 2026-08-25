import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

/// [TeamManagementTab]
///
/// Admin-only tab for managing telecaller team.
/// Sub-views: Team List | Leaderboard | Incentives | ROI Dashboard
/// Telecallers NEVER see this — all data is admin-only.
class TeamManagementTab extends StatefulWidget {
  final ThemeData theme;
  const TeamManagementTab({super.key, required this.theme});

  @override
  State<TeamManagementTab> createState() => _TeamManagementTabState();
}

class _TeamManagementTabState extends State<TeamManagementTab> {
  final AdminRepository _repo = AdminRepository();

  // Sub-tab state
  String _subTab = 'team'; // team, leaderboard, incentives, roi

  // Team data
  List<Map<String, dynamic>> _telecallers = [];
  Map<String, dynamic>? _selectedReport;
  String? _selectedTelecallerId;
  bool _isLoading = true;
  bool _isReportLoading = false;

  // Leaderboard
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLeaderboardLoading = false;

  // ROI
  Map<String, dynamic>? _roiData;
  bool _isRoiLoading = false;

  // Incentives
  Map<String, dynamic>? _incentiveReport;
  bool _isIncentiveLoading = false;

  // Inventory
  Map<String, dynamic>? _inventory;
  bool _isInventoryLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTelecallers();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isInventoryLoading = true);
    final res = await _repo.getLeadInventory();
    res.fold(
      onSuccess: (data) => setState(() {
        _inventory = data;
        _isInventoryLoading = false;
      }),
      onFailure: (_) => setState(() => _isInventoryLoading = false),
    );
  }

  Future<void> _loadTelecallers() async {
    setState(() => _isLoading = true);
    final res = await _repo.getTeam();
    res.fold(
      onSuccess: (data) => setState(() {
        _telecallers = data;
        _isLoading = false;
      }),
      onFailure: (_) => setState(() => _isLoading = false),
    );
  }

  Future<void> _loadStaffReport(String staffUserId) async {
    setState(() {
      _isReportLoading = true;
      _selectedTelecallerId = staffUserId;
    });
    final res = await _repo.getStaffReport(staffUserId);
    res.fold(
      onSuccess: (data) => setState(() {
        _selectedReport = data;
        _isReportLoading = false;
      }),
      onFailure: (_) => setState(() => _isReportLoading = false),
    );
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLeaderboardLoading = true);
    final res = await _repo.getLeaderboard();
    res.fold(
      onSuccess: (data) => setState(() {
        _leaderboard = data;
        _isLeaderboardLoading = false;
      }),
      onFailure: (_) => setState(() => _isLeaderboardLoading = false),
    );
  }

  Future<void> _loadRoi() async {
    setState(() => _isRoiLoading = true);
    final res = await _repo.getRoiDashboard();
    res.fold(
      onSuccess: (data) => setState(() {
        _roiData = data;
        _isRoiLoading = false;
      }),
      onFailure: (_) => setState(() => _isRoiLoading = false),
    );
  }

  Future<void> _loadIncentive(String telecallerUserId) async {
    setState(() => _isIncentiveLoading = true);
    final res = await _repo.calculateIncentives(telecallerUserId);
    res.fold(
      onSuccess: (data) => setState(() {
        _incentiveReport = data;
        _isIncentiveLoading = false;
      }),
      onFailure: (_) => setState(() => _isIncentiveLoading = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildSubTabBar()),
        ..._buildSubTabContent(),
      ],
    );
  }

  // ===========================================================================
  // Sub-tab bar
  // ===========================================================================

  Widget _buildSubTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _tabChip('team', '👥 Team', Icons.people),
          _tabChip('leaderboard', '🏆 Leaderboard', Icons.leaderboard),
          _tabChip('incentives', '💰 Incentives', Icons.calculate),
          _tabChip('roi', '📈 ROI', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _tabChip(String key, String label, IconData icon) {
    final isActive = _subTab == key;
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        selectedColor: theme.colorScheme.primary.withValues(alpha: AppColors.opacity20),
        onSelected: (_) {
          setState(() => _subTab = key);
          if (key == 'leaderboard' && _leaderboard.isEmpty) _loadLeaderboard();
          if (key == 'roi' && _roiData == null) _loadRoi();
        },
      ),
    );
  }

  List<Widget> _buildSubTabContent() {
    switch (_subTab) {
      case 'leaderboard':
        return _buildLeaderboardView();
      case 'incentives':
        return _buildIncentivesView();
      case 'roi':
        return _buildRoiView();
      default:
        return _buildTeamView();
    }
  }

  // ===========================================================================
  // TEAM view (original)
  // ===========================================================================

  List<Widget> _buildTeamView() {
    return [
      SliverToBoxAdapter(child: _buildInventorySection()),
      SliverToBoxAdapter(child: _buildTeamHeader()),
      if (_telecallers.isEmpty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'No telecallers yet.\nUse "Auto-Assign" to set up.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildTelecallerCard(_telecallers[index]),
            childCount: _telecallers.length,
          ),
        ),
      if (_selectedReport != null && !_isReportLoading)
        SliverToBoxAdapter(child: _buildReportDetail()),
      if (_isReportLoading)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
    ];
  }

  Widget _buildTeamHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team (${_telecallers.length})',
                style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () {
                  _loadTelecallers();
                  _loadInventory();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: _showHireDialog,
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Hire'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.materialBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: AppTypography.bodyMedium),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _autoAssign,
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('Auto-Assign'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.successDark,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: AppTypography.bodyMedium),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _showManualAssignDialog(),
                  icon: const Icon(Icons.assignment_ind, size: 16),
                  label: const Text('Manual Assign'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.materialOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: AppTypography.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHireDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    
    final Map<String, List<String>> roleMap = {
      'sales': ['telecaller', 'sales manager', 'account executive'],
      'engineering': ['frontend developer', 'backend developer', 'fullstack developer', 'devops'],
      'qa': ['tester', 'qa automation', 'qa lead'],
      'management': ['product manager', 'project manager', 'hr manager'],
      'support': ['customer support', 'technical support'],
    };

    String selectedDepartment = 'sales';
    String selectedDesignation = 'telecaller';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('👤 Hire Staff'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'e.g. Bhavani Chinthakindi',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: roleMap.keys.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          // Capitalize first letter
                          child: Text('${dept[0].toUpperCase()}${dept.substring(1)}'),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            selectedDepartment = v;
                            // Reset designation when department changes
                            selectedDesignation = roleMap[v]!.first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDesignation,
                      decoration: const InputDecoration(
                        labelText: 'Designation',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      items: roleMap[selectedDepartment]!.map((dsg) {
                        return DropdownMenuItem(
                          value: dsg,
                          // Capitalize first letters of each word
                          child: Text(dsg.split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ')),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            selectedDesignation = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'e.g. name@gmail.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Min 6 characters',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final pass = passCtrl.text.trim();
                    if (name.isEmpty || email.isEmpty || pass.length < 6) {
                      AppFeedback.showWarning(
                        context,
                        'Please fill all fields (password min 6 chars)',
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    
                    _hireStaff(name, email, pass, selectedDepartment, selectedDesignation);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Create Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _hireStaff(String name, String email, String password, String department, String designation) async {
    if (!mounted) return;
    AppFeedback.showInfo(
      context,
      'Creating $designation account...',
    );

    final res = await _repo.hireStaff(
      fullName: name,
      email: email,
      password: password,
      department: department,
      designation: designation,
    );
    res.fold(
      onSuccess: (data) {
        if (mounted) {
          AppFeedback.showSuccess(
            context,
            'Hired $name as $designation!',
          );
        }
        _loadTelecallers();
      },
      onFailure: (e) {
        if (mounted) {
          AppFeedback.showError(
            context,
            e,
            contextTag: 'admin',
            fallbackMessage: 'Hire failed',
          );
        }
      },
    );
  }

  Widget _buildTelecallerCard(Map<String, dynamic> tc) {
    final theme = widget.theme;
    final isSelected = _selectedTelecallerId == tc['user_id'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: AppColors.opacity30) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _loadStaffReport(tc['user_id']),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    tc['department'] == 'sales' ? Icons.headset_mic : Icons.computer, 
                    size: 18, 
                    color: tc['department'] == 'sales' ? AppColors.successDark : AppColors.materialBlue
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tc['full_name'] ?? 'Unknown',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.semiBold),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (action) => _handleAction(action, tc),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'demote', child: Text('Remove Staff')),
                      PopupMenuItem(value: 'unassign_all', child: Text('Unassign All Leads')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                       color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                       borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${tc['designation'] ?? 'staff'}'.toUpperCase(),
                      style: TextStyle(fontSize: AppTypography.bodySmall, fontWeight: AppTypography.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${tc['phone_number'] ?? 'No Phone'} • ${tc['email'] ?? ''}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
              if (tc['department'] == 'sales') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statChip('Leads', '${tc['total_leads'] ?? 0}', AppColors.materialBlue),
                    _statChip('Conv.', '${tc['total_converted'] ?? 0}', AppColors.successDark),
                    _statChip('Calls', '${tc['total_calls'] ?? 0}', AppColors.materialOrange),
                    _statChip('Today', '${tc['calls_today'] ?? 0}', AppColors.materialPurple700),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: AppColors.opacity10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: AppTypography.bold, fontSize: AppTypography.headingSmall)),
            Text(label, style: TextStyle(color: color.withValues(alpha: AppColors.opacity70), fontSize: AppTypography.bodySmall)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetail() {
    final theme = widget.theme;
    final r = _selectedReport!;
    final tcName = _telecallers.firstWhere(
      (t) => t['user_id'] == _selectedTelecallerId,
      orElse: () => {'full_name': 'Unknown'},
    )['full_name'];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Report: $tcName',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
            const Divider(),
            _reportRow('Total Leads', '${r['total_leads'] ?? 0}'),
            _reportRow('Not Called', '${r['not_called'] ?? 0}', color: Colors.grey),
            _reportRow('Connected', '${r['connected'] ?? 0}', color: AppColors.successDark),
            _reportRow('Follow Up', '${r['follow_up'] ?? 0}', color: AppColors.materialOrange),
            _reportRow('Converted ✓', '${r['converted'] ?? 0}', color: AppColors.greenBright),
            _reportRow('Not Interested', '${r['not_interested'] ?? 0}', color: Colors.redAccent),
            const Divider(),
            _reportRow('Calls Today', '${r['calls_today'] ?? 0}'),
            _reportRow('Calls This Week', '${r['calls_this_week'] ?? 0}'),
            _reportRow('Calls This Month', '${r['calls_this_month'] ?? 0}'),
            _reportRow('Total Calls', '${r['total_calls'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // LEADERBOARD view (Phase 3)
  // ===========================================================================

  List<Widget> _buildLeaderboardView() {
    if (_isLeaderboardLoading) {
      return [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))];
    }
    if (_leaderboard.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('No data yet', style: TextStyle(color: Colors.white54))),
        )
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text('🏆 Leaderboard',
                  style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _loadLeaderboard),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tc = _leaderboard[index];
            final rank = index + 1;
            final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '#$rank';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              child: ListTile(
                leading: Text(medal, style: TextStyle(fontSize: AppTypography.headingLarge)),
                title: Text(
                  tc['full_name'] ?? 'Unknown',
                  style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.semiBold),
                ),
                subtitle: Text(
                  '${tc['converted'] ?? 0} conversions • ${tc['profiles_completed'] ?? 0} profiles • ${tc['conversion_rate'] ?? 0}% rate',
                  style: widget.theme.textTheme.bodySmall,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${tc['calls_this_month'] ?? 0}',
                      style: TextStyle(fontWeight: AppTypography.bold, fontSize: AppTypography.headingMedium),
                    ),
                    Text('calls/mo', style: TextStyle(fontSize: AppTypography.labelMedium, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
          childCount: _leaderboard.length,
        ),
      ),
    ];
  }

  // ===========================================================================
  // INCENTIVES view (Phase 3)
  // ===========================================================================

  List<Widget> _buildIncentivesView() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text('💰 Incentive Calculator',
              style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
        ),
      ),
      // Telecaller picker
      SliverToBoxAdapter(
        child: SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _telecallers.length,
            itemBuilder: (context, index) {
              final tc = _telecallers[index];
              final isSelected = _incentiveReport?['telecaller_id'] == tc['user_id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(tc['full_name'] ?? '?'),
                  selected: isSelected,
                  onSelected: (_) => _loadIncentive(tc['user_id']),
                ),
              );
            },
          ),
        ),
      ),
      if (_isIncentiveLoading)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        )
      else if (_incentiveReport != null)
        SliverToBoxAdapter(child: _buildIncentiveCard()),
    ];
  }

  Widget _buildIncentiveCard() {
    final r = _incentiveReport!;
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final tcName = _telecallers.firstWhere(
      (t) => t['user_id'] == r['telecaller_id'],
      orElse: () => {'full_name': 'Unknown'},
    )['full_name'];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 $tcName — This Month',
                style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
            const Divider(),
            // Work breakdown
            _reportRow('Welcome Calls', '${r['welcome_calls'] ?? 0}'),
            _reportRow('Basic Profiles (50-79%)', '${r['basic_profiles'] ?? 0}'),
            _reportRow('Full Profiles (80%+)', '${r['full_profiles'] ?? 0}'),
            _reportRow('Conversions', '${r['conversions'] ?? 0}'),
            _reportRow('Total Calls', '${r['total_calls'] ?? 0}'),
            _reportRow('Active Days', '${r['active_days'] ?? 0}'),
            const Divider(),
            // Earnings breakdown
            _reportRow('Profile Incentive', fmt.format(r['profile_incentive'] ?? 0),
                color: AppColors.materialBlue),
            _reportRow('Subscription Incentive', fmt.format(r['subscription_incentive'] ?? 0),
                color: AppColors.successDark),
            _reportRow('Bonuses', fmt.format(r['bonuses'] ?? 0), color: AppColors.materialOrange),
            const Divider(thickness: 2),
            _reportRow(
              'TOTAL PAYOUT',
              fmt.format(r['total_payout'] ?? 0),
              color: AppColors.greenBright,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ROI DASHBOARD view (Phase 3)
  // ===========================================================================

  List<Widget> _buildRoiView() {
    if (_isRoiLoading) {
      return [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))];
    }
    if (_roiData == null) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Loading...', style: TextStyle(color: Colors.white54))),
        ),
      ];
    }

    final r = _roiData!;
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final roi = r['estimated_roi'] ?? 0;
    final roiColor = (roi as num) > 0 ? AppColors.successDark : Colors.redAccent;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text('📈 ROI Dashboard',
                  style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _loadRoi),
            ],
          ),
        ),
      ),
      // Big ROI card
      SliverToBoxAdapter(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: roiColor.withValues(alpha: AppColors.opacity10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '$roi%',
                  style: TextStyle(fontSize: AppTypography.displayLarge, fontWeight: AppTypography.bold, color: roiColor),
                ),
                Text('Estimated ROI', style: TextStyle(color: roiColor, fontSize: AppTypography.bodyLarge)),
              ],
            ),
          ),
        ),
      ),
      // Detail card
      SliverToBoxAdapter(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business Metrics',
                    style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
                const Divider(),
                _reportRow('Total Telecallers', '${r['total_telecallers'] ?? 0}'),
                _reportRow('Total Leads Assigned', '${r['total_leads'] ?? 0}'),
                _reportRow('Profiles Completed (80%+)', '${r['total_profiles_completed'] ?? 0}'),
                _reportRow('Conversions', '${r['total_converted'] ?? 0}'),
                _reportRow('Conversion Rate', '${r['conversion_rate'] ?? 0}%'),
                _reportRow('Calls This Month', '${r['total_calls_this_month'] ?? 0}'),
                _reportRow('Avg Calls/Telecaller', '${r['avg_calls_per_telecaller'] ?? 0}'),
                const Divider(),
                _reportRow('Est. Revenue', fmt.format(r['estimated_revenue'] ?? 0),
                    color: AppColors.successDark),
                _reportRow('Est. Cost', fmt.format(r['estimated_cost'] ?? 0),
                    color: AppColors.materialOrange),
                _reportRow('Net Profit', fmt.format(r['net_profit'] ?? 0),
                    color: (r['net_profit'] as num? ?? 0) > 0
                        ? AppColors.greenBright
                        : Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  // ===========================================================================
  // ADVANCED LEAD MANAGEMENT (Inventory & Manual Assign)
  // ===========================================================================

  Widget _buildInventorySection() {
    if (_isInventoryLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_inventory == null) return const SizedBox.shrink();

    final inv = _inventory!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lead Inventory',
            style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _inventoryCard('Unassigned', '${inv['total_unassigned'] ?? 0}', Colors.grey),
                _inventoryCard('Incomplete', '${inv['incomplete'] ?? 0}', Colors.orange),
                _inventoryCard('No Contact', '${inv['no_contact'] ?? 0}', Colors.red),
                _inventoryCard('No Photo', '${inv['no_photo'] ?? 0}', Colors.blue),
                _inventoryCard('Free Users', '${inv['unsubscribed'] ?? 0}', Colors.cyan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryCard(String label, String count, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacity10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: AppColors.opacity20)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(color: color, fontWeight: AppTypography.bold, fontSize: AppTypography.headingMedium),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color.withValues(alpha: AppColors.opacity80), fontSize: AppTypography.bodySmall),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showManualAssignDialog() {
    String? selectedStaffId;
    String selectedStage = 'all';
    String selectedGender = 'Both';
    int selectedLimit = 10;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('🎯 Manual Assign'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Staff Picker
                    DropdownButtonFormField<String>(
                      initialValue: selectedStaffId,
                      decoration: const InputDecoration(labelText: 'Target Staff', prefixIcon: Icon(Icons.person)),
                      items: _telecallers.map((tc) {
                        return DropdownMenuItem(
                          value: tc['user_id'] as String,
                          child: Text(tc['full_name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedStaffId = v),
                    ),
                    const SizedBox(height: 16),
                    // Stage Picker
                    DropdownButtonFormField<String>(
                      initialValue: selectedStage,
                      decoration: const InputDecoration(labelText: 'Profile Stage', prefixIcon: Icon(Icons.filter_list)),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Unassigned')),
                        DropdownMenuItem(value: 'incomplete', child: Text('Incomplete Profiles')),
                        DropdownMenuItem(value: 'no_contact', child: Text('Missing Contact Info')),
                        DropdownMenuItem(value: 'no_photo', child: Text('Missing Photo')),
                        DropdownMenuItem(value: 'unsubscribed', child: Text('Unsubscribed (Free)')),
                      ],
                      onChanged: (v) => setDialogState(() => selectedStage = v!),
                    ),
                    const SizedBox(height: 16),
                    // Gender Picker
                    DropdownButtonFormField<String>(
                      initialValue: selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc)),
                      items: const [
                        DropdownMenuItem(value: 'Both', child: Text('Both')),
                        DropdownMenuItem(value: 'Male', child: Text('Male Only')),
                        DropdownMenuItem(value: 'Female', child: Text('Female Only')),
                      ],
                      onChanged: (v) => setDialogState(() => selectedGender = v!),
                    ),
                    const SizedBox(height: 16),
                    // Limit Picker
                    DropdownButtonFormField<int>(
                      initialValue: selectedLimit,
                      decoration: const InputDecoration(labelText: 'Batch Size', prefixIcon: Icon(Icons.numbers)),
                      items: [10, 25, 50, 100].map((l) {
                        return DropdownMenuItem(value: l, child: Text('$l Profiles'));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedLimit = v!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton.icon(
                  onPressed: selectedStaffId == null
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          _manualAssign(selectedStaffId!, selectedStage, selectedGender, selectedLimit);
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Assign Now'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _manualAssign(String staffId, String stage, String gender, int limit) async {
    AppFeedback.showInfo(
      context,
      '⏳ Assigning leads...',
    );
    final res = await _repo.manualAssignLeads(
      staffUserId: staffId,
      stage: stage,
      gender: gender,
      limit: limit,
    );
    res.fold(
      onSuccess: (data) {
        final count = data['assigned'] ?? 0;
        AppFeedback.showSuccess(
          context,
          '✅ Successfully assigned $count leads!',
        );
        _loadTelecallers();
        _loadInventory();
      },
      onFailure: (e) => AppFeedback.showError(
        context,
        e,
        contextTag: 'admin',
        fallbackMessage: 'Assignment failed',
      ),
    );
  }

  Widget _reportRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: AppTypography.bodyLarge)),
          Text(value, style: TextStyle(fontWeight: AppTypography.bold, color: color, fontSize: AppTypography.bodyLarge)),
        ],
      ),
    );
  }

  // ===========================================================================
  // Actions
  // ===========================================================================

  Future<void> _autoAssign() async {
    final res = await _repo.autoAssignLeads();
    res.fold(
      onSuccess: (data) {
        if (mounted) {
          AppFeedback.showSuccess(
            context,
            '✅ Auto-assigned ${data['assigned'] ?? 0} profiles',
          );
        }
        _loadTelecallers();
      },
      onFailure: (e) {
        if (mounted) {
          AppFeedback.showError(
            context,
            e,
            contextTag: 'admin',
          );
        }
      },
    );
  }

  Future<void> _handleAction(String action, Map<String, dynamic> tc) async {
    final userId = tc['user_id'] as String;
    final name = tc['full_name'] ?? 'Unknown';

    switch (action) {
      case 'demote':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove Telecaller'),
            content: Text('Remove "$name" as telecaller?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await _repo.setUserRole(userId, 'staff');
          _loadTelecallers();
        }
        break;

      case 'unassign_all':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unassign All Leads'),
            content: Text('Remove all leads from "$name"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Unassign'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await _repo.unassignAllLeads(userId);
          _loadTelecallers();
        }
        break;
    }
  }
}
