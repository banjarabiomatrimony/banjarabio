import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/staff_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';

import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/presentation/staff_screen/volunteer_tabs_widget.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/theme/app_colors.dart';

const _kBgDark = AppColors.canvasCharcoal;
const _kSurfaceColor = AppColors.canvasRichDark;
const _kAccentColor = AppColors.violetDigital;

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final StaffRepository _repo = StaffRepository();

  // --- Role detection ---
  String _userRole = ''; // 'volunteer', 'staff', 'telecaller'
  bool _roleLoaded = false;

  List<ProfileModel> _allLeads = [];
  List<ProfileModel> _filteredLeads = [];
  Map<String, dynamic>? _summary;
  
  bool _isLoading = true;
  String? _error;
  
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'New',
    'Follow Up',
    'Converted',
    'Issue'
  ];

  @override
  void initState() {
    super.initState();
    _detectRoleAndLoad();
  }

  Future<void> _detectRoleAndLoad() async {
    final profileRes = await ProfileRepository().getOwnProfile();
    if (!mounted) return;
    String role = 'staff';
    profileRes.fold(
      onSuccess: (profile) {
        if (profile != null) role = profile.role;
      },
      onFailure: (_) {},
    );
    setState(() {
      _userRole = role;
      _roleLoaded = true;
    });
    // Only load staff leads if NOT a volunteer
    if (_userRole != 'volunteer') {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await Future.wait([
       _repo.getMyLeads(),
       _repo.getMySummary(),
    ]);

    if (!mounted) return;

    final leadsRes = results[0];
    final summaryRes = results[1];

    setState(() {
      _isLoading = false;
      leadsRes.fold(
        onSuccess: (data) {
          final list = data as List<ProfileModel>;
          _allLeads = list;
          _applyFilters();
        },
        onFailure: (e) => _error = e,
      );
      summaryRes.fold(
        onSuccess: (data) => _summary = data as Map<String, dynamic>,
        onFailure: (_) {},
      );
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredLeads = _allLeads.where((profile) {
        // Search
        final matchesSearch = _searchQuery.isEmpty ||
            profile.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            profile.surname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            profile.displayId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (profile.phoneNumber?.contains(_searchQuery) ?? false);
        
        if (!matchesSearch) return false;

        // Filter status
        switch (_selectedFilter) {
          case 'New':
            return profile.callStatus == 'not_called';
          case 'Follow Up':
            return profile.callStatus == 'follow_up';
          case 'Converted':
            return profile.callStatus == 'converted';
          case 'Issue':
            return profile.callStatus == 'not_answered' || 
                   profile.callStatus == 'busy' || 
                   profile.callStatus == 'not_interested';
          case 'All':
          default:
            return true;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_roleLoaded) {
      return const Scaffold(
        backgroundColor: _kBgDark,
        body: Center(child: CircularProgressIndicator(color: _kAccentColor)),
      );
    }

    // --- Volunteer role: TabBar-based UI ---
    if (_userRole == 'volunteer') {
      return const VolunteerTabsWidget();
    }

    // --- Staff / Telecaller role: Leads pipeline (existing behavior) ---
    return _buildStaffScaffold();
  }

  Widget _buildStaffScaffold() {
    return Scaffold(
      backgroundColor: _kBgDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _summary != null ? 240.0 : 120.0,
              pinned: true,
              backgroundColor: _kBgDark,
              foregroundColor: Colors.white,
              title: const Text('Workspace', style: TextStyle(fontWeight: AppTypography.semiBold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _handleLogout,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: TextField(
                          style: TextStyle(color: Colors.white, fontSize: AppTypography.bodyLarge),
                          decoration: InputDecoration(
                            hintText: 'Search leads...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            filled: true,
                            fillColor: _kSurfaceColor,
                            contentPadding: const EdgeInsets.symmetric(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) {
                            _searchQuery = val;
                            _applyFilters();
                          },
                        ),
                      ),
                      // Summary Horizontal Scroll
                      if (_summary != null)
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: [
                              _buildMetricCard('Total Leads', '${_summary?['total_assigned'] ?? 0}', Icons.people, Colors.blue),
                              _buildMetricCard('Pending', '${_summary?['not_called'] ?? 0}', Icons.hourglass_top, Colors.orange),
                              _buildMetricCard('Follow Up', '${_summary?['follow_up'] ?? 0}', Icons.sync, Colors.amber),
                              _buildMetricCard('Updated Today', '${_summary?['updated_today'] ?? 0}', Icons.update, Colors.green),
                              _buildMetricCard('Calls Today', '${_summary?['calls_today'] ?? 0}', Icons.headset_mic, Colors.purple),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Filter Chips sticky header
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterHeaderDelegate(
                child: Container(
                  height: 50,
                  color: _kBgDark,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filter;
                                _applyFilters();
                              });
                            }
                          },
                          backgroundColor: _kSurfaceColor,
                          selectedColor: _kAccentColor.withValues(alpha: AppColors.opacity20),
                          labelStyle: TextStyle(
                            color: isSelected ? _kAccentColor : Colors.white70,
                            fontWeight: isSelected ? AppTypography.bold : FontWeight.normal,
                            fontSize: AppTypography.bodyLarge,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? _kAccentColor : Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                height: 50,
              ),
            ),
          ];
        },
        body: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (context, index) => _buildSkeletonCard(),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: $_error', style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _filteredLeads.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _filteredLeads.length,
                            itemBuilder: (context, index) => _buildPremiumLeadCard(_filteredLeads[index]),
                          ),
                  ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: AppColors.opacity20)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: AppColors.opacity5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.bold,
                    shadows: [Shadow(color: color.withValues(alpha: AppColors.opacity40), blurRadius: 4)],
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white54, fontSize: AppTypography.bodySmall, fontWeight: AppTypography.medium),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: _kSurfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sentiment_satisfied_alt, size: 64, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          Text(
            'All Caught Up!',
            style: TextStyle(color: Colors.white, fontSize: AppTypography.headingLarge, fontWeight: AppTypography.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No leads found matching the current filters.',
            style: TextStyle(color: Colors.white54, fontSize: AppTypography.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _kAccentColor),
      ),
    );
  }

  Widget _buildPremiumLeadCard(ProfileModel profile) {
    final statusColor = _getStatusColor(profile.callStatus);
    final statusText = _getStatusLabel(profile.callStatus);

    // Initial for avatar
    final initial = profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kSurfaceColor,
            _kSurfaceColor.withValues(alpha: AppColors.opacity80),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: AppColors.opacity5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top row: Avatar, Info, Status Badge
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _kAccentColor.withValues(alpha: AppColors.opacity20),
                  child: Text(
                    initial,
                    style: TextStyle(color: _kAccentColor, fontWeight: AppTypography.bold, fontSize: AppTypography.headingLarge),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.fullName} ${profile.surname}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.semiBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${profile.displayId}',
                        style: TextStyle(
                          color: _kAccentColor,
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.age} yrs • ${profile.gender} • ${profile.village ?? 'N/A'}',
                        style: TextStyle(color: Colors.white54, fontSize: AppTypography.bodyLarge),
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (profile.completionPercentage) / 100,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation(AppColors.successDark),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${profile.completionPercentage}%',
                            style: TextStyle(color: Colors.white54, fontSize: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: AppColors.opacity15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: AppColors.opacity30)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: AppTypography.bodySmall, fontWeight: AppTypography.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // Action Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: AppColors.opacity15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Call',
                  color: AppColors.successDark,
                  onTap: () => _makeCall(profile),
                ),
                _buildActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: 'WhatsApp',
                  color: AppColors.whatsapp,
                  onTap: () => _showWhatsAppTemplatePicker(profile),
                ),
                _buildActionButton(
                  icon: Icons.assignment_rounded,
                  label: 'Log Call',
                  color: AppColors.materialOrange,
                  onTap: () => _showCallOutcomeBottomsheet(profile),
                ),
                _buildActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Details',
                  color: AppColors.materialBlue,
                  onTap: () => _showProfileEditor(profile),
                ),
                _buildActionButton(
                  icon: Icons.alternate_email_rounded,
                  label: 'Email',
                  color: Colors.white70,
                  onTap: () => _sendEmail(profile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color.withValues(alpha: AppColors.opacity80), fontSize: AppTypography.bodySmall, fontWeight: AppTypography.medium)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action Handlers
  // ---------------------------------------------------------------------------

  Future<void> _makeCall(ProfileModel profile) async {
    if (profile.phoneNumber == null) {
      _showSnack('No phone number available');
      return;
    }
    await _repo.logCall(profileId: profile.id, actionType: 'call');
    final uri = Uri.parse('tel:${profile.phoneNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(ProfileModel profile) async {
    if (profile.email == null || profile.email!.isEmpty) {
      _showSnack('No email available');
      return;
    }
    await _repo.logCall(profileId: profile.id, actionType: 'email');
    final uri = Uri.parse('mailto:${profile.email}?subject=Regarding your BanjaraBio Profile&body=Namaste ${profile.fullName},');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnack('Could not launch email app');
    }
  }

  void _showWhatsAppTemplatePicker(ProfileModel profile) async {
    if (profile.phoneNumber == null) {
      _showSnack('No phone number available');
      return;
    }

    final results = await Future.wait([
      _repo.getWhatsAppTemplates(),
      _repo.getLeadForTemplate(profile.id),
    ]);

    List<Map<String, dynamic>> templates = [];
    Map<String, dynamic> leadData = {};

    results[0].fold(
      onSuccess: (data) => templates = data as List<Map<String, dynamic>>,
      onFailure: (_) {},
    );
    results[1].fold(
      onSuccess: (data) => leadData = data as Map<String, dynamic>,
      onFailure: (_) {},
    );

    if (templates.isEmpty) {
      _openWhatsAppWithMessage(profile, 'Namaste ${profile.fullName}! I am calling from BanjaraBio Matrimony App. 🙏');
      return;
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('📱 Start WhatsApp Chat', style: TextStyle(color: Colors.white, fontSize: AppTypography.headingMedium, fontWeight: AppTypography.bold)),
                  const SizedBox(height: 8),
                  Text('Select a template to engage with this lead.', style: TextStyle(color: Colors.white54, fontSize: AppTypography.bodyLarge)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: templates.length + 1,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white12),
                      itemBuilder: (context, index) {
                        if (index == templates.length) {
                          return ListTile(
                            leading: const Icon(Icons.edit, color: Colors.white54),
                            title: const Text('Custom Message', style: TextStyle(color: Colors.white)),
                            dense: true,
                            onTap: () {
                              Navigator.pop(ctx);
                              _openWhatsAppWithMessage(profile, 'Namaste ${profile.fullName}! I am calling from BanjaraBio Matrimony App. 🙏');
                            },
                          );
                        }

                        final t = templates[index];
                        String msg = t['message_template'] ?? '';
                        msg = msg.replaceAll('{name}', leadData['name'] ?? profile.fullName);
                        msg = msg.replaceAll('{completion}', '${leadData['completion'] ?? profile.profileCompletion}');
                        msg = msg.replaceAll('{views}', '${leadData['views'] ?? 0}');

                        final category = t['category'] ?? 'general';
                        final icon = switch (category) {
                          'welcome' => '🟢',
                          'follow_up' => '🔵',
                          'verification' => '🟡',
                          'premium_pitch' => '🟠',
                          're_engage' => '🔴',
                          _ => '💬',
                        };

                        return ListTile(
                          leading: Text(icon, style: TextStyle(fontSize: AppTypography.headingLarge)),
                          title: Text(t['name'] ?? 'Template', style: const TextStyle(color: Colors.white, fontWeight: AppTypography.medium)),
                          subtitle: Text(msg, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white54, fontSize: AppTypography.bodyMedium)),
                          onTap: () {
                            Navigator.pop(ctx);
                            _openWhatsAppWithMessage(profile, msg);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openWhatsAppWithMessage(ProfileModel profile, String message) async {
    await _repo.logCall(profileId: profile.id, actionType: 'whatsapp');
    final phone = profile.phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');
    final whatsappPhone = phone.startsWith('+') ? phone.substring(1) : '91$phone';
    final encodedMsg = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$whatsappPhone?text=$encodedMsg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showCallOutcomeBottomsheet(ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Log Call Outcome', style: TextStyle(color: Colors.white, fontSize: AppTypography.headingMedium, fontWeight: AppTypography.bold)),
              const SizedBox(height: 8),
              Text('Lead: ${profile.fullName}', style: TextStyle(color: Colors.white54, fontSize: AppTypography.bodyLarge)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _outcomePill(ctx, profile, 'connected', '✅ Connected', Colors.green),
                  _outcomePill(ctx, profile, 'busy', '📵 Busy', Colors.orange),
                  _outcomePill(ctx, profile, 'not_answered', '📴 No Answer', Colors.amber),
                  _outcomePill(ctx, profile, 'follow_up', '🔄 Follow Up', Colors.blue),
                  _outcomePill(ctx, profile, 'not_interested', '❌ Not Interested', Colors.red),
                  _outcomePill(ctx, profile, 'converted', '🎉 Converted!', Colors.tealAccent.shade400, isProminent: true),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _outcomePill(BuildContext ctx, ProfileModel profile, String outcome, String label, Color color, {bool isProminent = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        Navigator.pop(ctx);
        await _repo.logCall(profileId: profile.id, actionType: 'call', outcome: outcome);
        _showSnack('Logged: $label');
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isProminent ? color.withValues(alpha: AppColors.opacity15) : _kBgDark,
          border: Border.all(color: isProminent ? color : color.withValues(alpha: AppColors.opacity30)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: isProminent ? color : Colors.white, fontWeight: isProminent ? AppTypography.bold : FontWeight.normal),
        ),
      ),
    );
  }

  void _showProfileEditor(ProfileModel profile) async {
    final result = await Navigator.pushNamed(
      context,
      '/biodata-creation-screen',
      arguments: {
        'profile': profile,
        'isEditMode': true,
        'isAdminEdit': true,
      },
    );
    
    if (result != null) {
      _loadData();
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _kAccentColor));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'connected': return AppColors.successDark;
      case 'follow_up': return AppColors.materialBlue;
      case 'converted': return AppColors.greenBright;
      case 'not_interested': return AppColors.materialRed600;
      case 'busy':
      case 'not_answered': return AppColors.warningDark;
      case 'not_called':
      default: return AppColors.neutral500;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'connected': return 'Connected';
      case 'follow_up': return 'Follow Up';
      case 'converted': return 'Converted ✓';
      case 'not_interested': return 'Not Interested';
      case 'busy': return 'Busy';
      case 'not_answered': return 'No Answer';
      case 'not_called':
      default: return 'New';
    }
  }

  Future<void> _handleLogout() async {
    try {
      await AppSupabaseClient.client.auth.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
    } catch (e) {
      AppLogger.error('StaffDashboardScreen', 'Logout error: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
    }
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _FilterHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
