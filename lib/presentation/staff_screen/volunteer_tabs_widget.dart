import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/volunteer_repository.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/presentation/staff_screen/widgets/melava_biodata_digitizer_dialog.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Self-contained volunteer tabs widget that can be embedded inside any host Scaffold.
/// Manages its own TabController, state, and VolunteerRepository interactions.
class VolunteerTabsWidget extends StatefulWidget {
  const VolunteerTabsWidget({super.key});
  @override
  State<VolunteerTabsWidget> createState() => VolunteerTabsWidgetState();
}

class VolunteerTabsWidgetState extends State<VolunteerTabsWidget>
    with SingleTickerProviderStateMixin {
  final _repo = VolunteerRepository();
  late TabController _tabCtrl;

  // Search state
  final _searchCtrl = TextEditingController();
  List<ProfileModel> _searchResults = [];
  bool _isSearching = false;

  // Stats
  Map<String, dynamic>? _stats;

  // Registration form
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _regFields = {};
  String _regGender = 'Male';
  bool _isRegistering = false;

  // Dynamic location lists for Registration
  String? _regSelectedState;
  String? _regSelectedDistrict;
  String? _regSelectedTaluka;
  List<String> _regDistricts = [];
  List<String> _regTalukas = [];

  // Correction state
  ProfileModel? _editingProfile;
  final Map<String, TextEditingController> _editFields = {};
  String _editGender = 'Male';
  bool _isSaving = false;

  // Dynamic location lists for Correction
  String? _editSelectedState;
  String? _editSelectedDistrict;
  String? _editSelectedTaluka;
  List<String> _editDistricts = [];
  List<String> _editTalukas = [];

  // Work Log state
  List<Map<String, dynamic>> _recentCalls = [];
  List<Map<String, dynamic>> _recentRegistrations = [];
  bool _isLoadingWorkLog = false;
  String _workLogTab = 'calls'; // 'calls' or 'registrations'

  static const _regFieldNames = [
    'full_name', 'surname', 'phone_number', 'age', 'date_of_birth',
    'education', 'profession', 'job_details', 'company', 'annual_income',
    'state', 'district', 'taluka', 'village',
    'father_name', 'father_occupation', 'mother_name', 'mother_occupation',
    'brother_count', 'sister_count', 'family_type', 'gotra',
    'marital_status', 'height', 'complexion', 'blood_group',
    'about_self', 'partner_expectations',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (mounted) {
        setState(() {});
        if (_tabCtrl.index == 3 && !_tabCtrl.indexIsChanging) {
          _loadWorkLog();
        }
      }
    });
    for (final f in _regFieldNames) {
      _regFields[f] = TextEditingController();
    }
    _loadStats();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    for (final c in _regFields.values) { c.dispose(); }
    for (final c in _editFields.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadStats() async {
    await _loadWorkLog();
  }

  Future<void> _loadWorkLog() async {
    if (!mounted) return;
    setState(() => _isLoadingWorkLog = true);
    
    // Fetch stats
    final statsRes = await _repo.getMyStats();
    statsRes.fold(
      onSuccess: (d) { if (mounted) setState(() => _stats = d); },
      onFailure: (_) {},
    );

    // Fetch call logs
    final callsRes = await _repo.getMyCallLogs();
    callsRes.fold(
      onSuccess: (list) { if (mounted) setState(() => _recentCalls = list); },
      onFailure: (_) {},
    );

    // Fetch registrations
    final regsRes = await _repo.getMyRegistrations();
    regsRes.fold(
      onSuccess: (list) { if (mounted) setState(() => _recentRegistrations = list); },
      onFailure: (_) {},
    );

    if (mounted) {
      setState(() => _isLoadingWorkLog = false);
    }
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _isSearching = true);
    final res = await _repo.searchProfiles(q);
    if (!mounted) return;
    res.fold(
      onSuccess: (list) => setState(() { _searchResults = list; _isSearching = false; }),
      onFailure: (e) { setState(() => _isSearching = false); _snack(e); },
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isRegistering = true);
    final data = <String, dynamic>{'gender': _regGender};
    for (final e in _regFields.entries) {
      if (e.value.text.trim().isNotEmpty) data[e.key] = e.value.text.trim();
    }
    final res = await _repo.registerProfile(data);
    if (!mounted) return;
    res.fold(
      onSuccess: (d) {
        _snack('✅ ${d['message'] ?? 'Profile registered'}');
        for (final c in _regFields.values) { c.clear(); }
        setState(() {
          _regSelectedState = null;
          _regSelectedDistrict = null;
          _regSelectedTaluka = null;
          _regDistricts = [];
          _regTalukas = [];
          _regGender = 'Male';
        });
        _loadStats();
      },
      onFailure: (e) => _snack('❌ $e'),
    );
    setState(() => _isRegistering = false);
  }

  void _openCorrection(ProfileModel p) async {
    final res = await _repo.getProfileDetail(p.id);
    if (!mounted) return;
    res.fold(
      onSuccess: (full) {
        _editFields.clear();
        final json = full.toJson();
        for (final k in _regFieldNames) {
          _editFields[k] = TextEditingController(text: json[k]?.toString() ?? '');
        }
        
        // Initialize cascading locations from existing values
        _editGender = json['gender']?.toString() ?? 'Male';
        _editSelectedState = json['state']?.toString();
        _editSelectedDistrict = json['district']?.toString();
        _editSelectedTaluka = json['taluka']?.toString();

        _editDistricts = _editSelectedState != null && _editSelectedState!.isNotEmpty
            ? LocationData.getDistricts(_editSelectedState!)
            : [];
        _editTalukas = _editSelectedDistrict != null && _editSelectedDistrict!.isNotEmpty
            ? LocationData.getTalukas(_editSelectedDistrict!)
            : [];

        setState(() { _editingProfile = full; _tabCtrl.animateTo(2); });
      },
      onFailure: (e) => _snack(e),
    );
  }

  Future<void> _saveCorrection() async {
    if (_editingProfile == null) return;
    setState(() => _isSaving = true);
    final data = <String, dynamic>{};
    for (final e in _editFields.entries) {
      if (e.value.text.trim().isNotEmpty) data[e.key] = e.value.text.trim();
    }
    // Sync corrected location keys explicitly
    data['state'] = _editSelectedState ?? '';
    data['district'] = _editSelectedDistrict ?? '';
    data['taluka'] = _editSelectedTaluka ?? '';
    data['gender'] = _editGender;

    final res = await _repo.correctProfile(_editingProfile!.id, data);
    if (!mounted) return;
    res.fold(
      onSuccess: (_) {
        _snack('✅ Profile updated');
        _loadStats();
        setState(() {
          _editingProfile = null;
        });
      },
      onFailure: (e) => _snack('❌ $e'),
    );
    setState(() => _isSaving = false);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _logout() async {
    try {
      await AppSupabaseClient.client.auth.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
    }
  }

  // Cascading Location methods for Registration Form
  void _onRegStateChanged(String? val) {
    setState(() {
      _regSelectedState = val;
      _regSelectedDistrict = null;
      _regSelectedTaluka = null;
      _regDistricts = val != null ? LocationData.getDistricts(val) : [];
      _regTalukas = [];
      
      _regFields['state']?.text = val ?? '';
      _regFields['district']?.text = '';
      _regFields['taluka']?.text = '';
    });
  }

  void _onRegDistrictChanged(String? val) {
    setState(() {
      _regSelectedDistrict = val;
      _regSelectedTaluka = null;
      _regTalukas = val != null ? LocationData.getTalukas(val) : [];
      
      _regFields['district']?.text = val ?? '';
      _regFields['taluka']?.text = '';
    });
  }

  void _onRegTalukaChanged(String? val) {
    setState(() {
      _regSelectedTaluka = val;
      _regFields['taluka']?.text = val ?? '';
    });
  }

  // Cascading Location methods for Correction Form
  void _onEditStateChanged(String? val) {
    setState(() {
      _editSelectedState = val;
      _editSelectedDistrict = null;
      _editSelectedTaluka = null;
      _editDistricts = val != null ? LocationData.getDistricts(val) : [];
      _editTalukas = [];
      
      _editFields['state']?.text = val ?? '';
      _editFields['district']?.text = '';
      _editFields['taluka']?.text = '';
    });
  }

  void _onEditDistrictChanged(String? val) {
    setState(() {
      _editSelectedDistrict = val;
      _editSelectedTaluka = null;
      _editTalukas = val != null ? LocationData.getTalukas(val) : [];
      
      _editFields['district']?.text = val ?? '';
      _editFields['taluka']?.text = '';
    });
  }

  void _onEditTalukaChanged(String? val) {
    setState(() {
      _editSelectedTaluka = val;
      _editFields['taluka']?.text = val ?? '';
    });
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const kBgDark = AppColors.canvasCharcoal;
    const kAccentColor = AppColors.violetDigital;

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        backgroundColor: kBgDark,
        foregroundColor: Colors.white,
        title: const Text('Volunteer Dashboard', style: TextStyle(fontWeight: AppTypography.semiBold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadStats();
              if (_tabCtrl.index == 3) {
                _loadWorkLog();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: kAccentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.search_rounded), text: 'Search'),
            Tab(icon: Icon(Icons.person_add_rounded), text: 'Register'),
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Correct'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Work Log'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_tabCtrl.index != 3) _buildStatsBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildSearchTab(),
                _buildRegisterTab(),
                _buildCorrectTab(),
                _buildWorkLogTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MelavaBiodataDigitizerDialog.show(context),
        backgroundColor: kAccentColor,
        icon: const Icon(Icons.bolt_rounded, color: Colors.white),
        label: const Text(
          '⚡ मेळावा Onboarding',
          style: TextStyle(color: Colors.white, fontWeight: AppTypography.bold),
        ),
      ),
    );
  }

  // ─── STATS BAR ──────────────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    if (_stats == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    
    final callsToday = _stats!['called_today'] ?? 0;
    final regsToday = _stats!['registered_today'] ?? 0;
    final correctionsToday = _stats!['corrected_today'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.primaryColor.withValues(alpha: AppColors.opacity8),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'Calls',
              actual: callsToday,
              target: 30,
              icon: Icons.phone_forwarded_rounded,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              label: 'Registrations',
              actual: regsToday,
              target: 10,
              icon: Icons.person_add_rounded,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              label: 'Corrections',
              actual: correctionsToday,
              target: 10,
              icon: Icons.edit_note_rounded,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int actual,
    required int target,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final double percent = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;
    final isTargetMet = actual >= target;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isTargetMet ? 0.35 : 0.15),
          width: isTargetMet ? 1.5 : 1,
        ),
        boxShadow: [
          if (isTargetMet)
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppColors.opacity10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: AppTypography.semiBold,
                    fontSize: AppTypography.bodySmall,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$actual',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: AppTypography.headingMedium,
                ),
              ),
              Text(
                ' / $target',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
                  fontWeight: AppTypography.medium,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withValues(alpha: AppColors.opacity10),
              valueColor: AlwaysStoppedAnimation<Color>(isTargetMet ? Colors.green : color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percent * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isTargetMet ? Colors.green : color,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.labelMedium,
                ),
              ),
              if (isTargetMet)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 10,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SEARCH TAB ─────────────────────────────────────────────────────────────
  Widget _buildSearchTab() {

    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            style: theme.textTheme.bodyLarge,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search by name, phone, BB-ID…',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity50),
              ),
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(Icons.search_rounded, color: theme.primaryColor),
                  onPressed: _search,
                ),
              ),
            ),
          ),
        ),
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.all(24),
            child: CircularProgressIndicator(color: theme.primaryColor),
          ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchCtrl.text.isEmpty ? 'Enter a search term' : 'No results found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, i) => _profileCard(_searchResults[i]),
                ),
        ),
      ],
    );
  }

  Widget _getCallStatusBadge(String status, ThemeData theme) {
    if (status == 'not_called') return const SizedBox.shrink();
    Color badgeColor = Colors.grey;
    final String displayStatus = status;
    if (status == 'Connected') {
      badgeColor = Colors.green;
    } else if (status == 'Busy') {
      badgeColor = Colors.orange;
    } else if (status == 'Callback Needed') {
      badgeColor = Colors.amber.shade700;
    } else if (status == 'No Answer') {
      badgeColor = Colors.red.shade400;
    } else if (status == 'Wrong Number') {
      badgeColor = Colors.purple;
    } else if (status == 'Not Interested') {
      badgeColor = Colors.blueGrey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: AppColors.opacity10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: AppColors.opacity20)),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: badgeColor,
          fontSize: AppTypography.bodySmall,
          fontWeight: AppTypography.bold,
        ),
      ),
    );
  }

  void _openCallLoggingSheet(ProfileModel p) {
    final theme = Theme.of(context);
    String selectedOutcome = 'Connected';
    final notesCtrl = TextEditingController();
    bool isSavingCall = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: AppColors.opacity15),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity20),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Log Follow-up Call',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For: ${p.fullName} (${p.phoneNumber})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Call Outcome',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTypography.semiBold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Connected', 'Busy', 'Callback Needed', 'No Answer', 'Wrong Number', 'Not Interested'].map((outcome) {
                        final isSelected = selectedOutcome == outcome;
                        return ChoiceChip(
                          label: Text(outcome),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() => selectedOutcome = outcome);
                            }
                          },
                          selectedColor: theme.primaryColor.withValues(alpha: AppColors.opacity15),
                          checkmarkColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? AppTypography.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? theme.primaryColor : theme.colorScheme.outline.withValues(alpha: AppColors.opacity20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Notes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTypography.semiBold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 3,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Enter call notes (e.g. details discussed, callback time, etc.)',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity50),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSavingCall ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity30)),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSavingCall
                                ? null
                                : () async {
                                    setSheetState(() => isSavingCall = true);
                                    final res = await _repo.logCall(
                                      profileId: p.id,
                                      outcome: selectedOutcome,
                                      notes: notesCtrl.text.trim(),
                                    );
                                    if (!mounted) return;
                                    res.fold(
                                      onSuccess: (_) {
                                        _snack('✅ Call logged successfully');
                                        _loadWorkLog();
                                        _search();
                                        Navigator.pop(context);
                                      },
                                      onFailure: (e) {
                                        _snack('❌ $e');
                                        setSheetState(() => isSavingCall = false);
                                      },
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSavingCall
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save & Log'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _profileCard(ProfileModel p) {
    final theme = Theme.of(context);
    final initials = p.fullName.trim().isNotEmpty ? p.fullName.trim()[0].toUpperCase() : '?';
    final isFemale = p.gender.toLowerCase() == 'female';
    final avatarColor = isFemale ? Colors.pink.shade400 : theme.primaryColor;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor.withValues(alpha: AppColors.opacity10),
              child: Text(
                initials,
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.headingMedium,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.age} Yrs · ${p.gender}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: AppTypography.semiBold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (p.callStatus != 'not_called') ...[
                        const SizedBox(width: 8),
                        _getCallStatusBadge(p.callStatus, theme),
                      ],
                    ],
                  ),
                  if (p.phoneNumber != null && p.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_iphone_rounded,
                          size: 14,
                          color: theme.primaryColor.withValues(alpha: AppColors.opacity70),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.phoneNumber!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: AppTypography.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (p.phoneNumber != null && p.phoneNumber!.isNotEmpty) ...[
              IconButton.filled(
                icon: const Icon(Icons.phone_rounded),
                onPressed: () async {
                  final phone = p.phoneNumber!;
                  final uri = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                  _openCallLoggingSheet(p);
                },
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            IconButton.filledTonal(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () => _openCorrection(p),
              style: IconButton.styleFrom(
                foregroundColor: theme.primaryColor,
                backgroundColor: theme.primaryColor.withValues(alpha: AppColors.opacity10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── REGISTER TAB ──────────────────────────────────────────────────────────
  Widget _buildRegisterTab() {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFormSection(
            context: context,
            title: 'Personal Details',
            icon: Icons.person_rounded,
            initiallyExpanded: true,
            children: [
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Full Name', controller: _regFields['full_name']!, isRequired: true, prefixIcon: Icons.badge_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Surname', controller: _regFields['surname']!, prefixIcon: Icons.badge_outlined)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Phone Number', controller: _regFields['phone_number']!, isRequired: true, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_android_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Age', controller: _regFields['age']!, keyboardType: TextInputType.number, prefixIcon: Icons.cake_rounded)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Gender',
                      value: _regGender,
                      items: const ['Male', 'Female', 'Other'],
                      onChanged: (val) => setState(() => _regGender = val ?? 'Male'),
                      prefixIcon: Icons.face_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Date of Birth (YYYY-MM-DD)', controller: _regFields['date_of_birth']!, hint: 'YYYY-MM-DD', prefixIcon: Icons.calendar_month_rounded)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Marital Status',
                      value: _regFields['marital_status']?.text,
                      items: const ['Single', 'Divorced', 'Widowed', 'Awaiting Divorce'],
                      onChanged: (val) => setState(() => _regFields['marital_status']?.text = val ?? ''),
                      prefixIcon: Icons.favorite_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Complexion',
                      value: _regFields['complexion']?.text,
                      items: const ['Very Fair', 'Fair', 'Medium', 'Wheatish', 'Dark'],
                      onChanged: (val) => setState(() => _regFields['complexion']?.text = val ?? ''),
                      prefixIcon: Icons.brush_rounded,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Height', controller: _regFields['height']!, hint: 'e.g. 5\'6"', prefixIcon: Icons.height_rounded)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Blood Group',
                      value: _regFields['blood_group']?.text,
                      items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                      onChanged: (val) => setState(() => _regFields['blood_group']?.text = val ?? ''),
                      prefixIcon: Icons.bloodtype_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildFormSection(
            context: context,
            title: 'Education & Career',
            icon: Icons.work_rounded,
            children: [
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Education', controller: _regFields['education']!, prefixIcon: Icons.school_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Profession', controller: _regFields['profession']!, prefixIcon: Icons.work_outline_rounded)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Company', controller: _regFields['company']!, prefixIcon: Icons.store_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Annual Income', controller: _regFields['annual_income']!, prefixIcon: Icons.payments_rounded)),
                ],
              ),
              _buildInput(label: 'Job Details', controller: _regFields['job_details']!, maxLines: 2, prefixIcon: Icons.description_rounded),
            ],
          ),
          _buildFormSection(
            context: context,
            title: 'Location Details',
            icon: Icons.place_rounded,
            children: [
              _buildDropdown(
                label: 'State',
                value: _regSelectedState,
                items: LocationData.states,
                onChanged: _onRegStateChanged,
                prefixIcon: Icons.map_rounded,
              ),
              _buildDropdown(
                label: 'District',
                value: _regSelectedDistrict,
                items: _regDistricts,
                onChanged: _onRegDistrictChanged,
                prefixIcon: Icons.location_city_rounded,
              ),
              _buildDropdown(
                label: 'Taluka',
                value: _regSelectedTaluka,
                items: _regTalukas,
                onChanged: _onRegTalukaChanged,
                prefixIcon: Icons.explore_rounded,
              ),
              _buildInput(label: 'Village', controller: _regFields['village']!, prefixIcon: Icons.home_rounded),
            ],
          ),
          _buildFormSection(
            context: context,
            title: 'Family & Other Details',
            icon: Icons.family_restroom_rounded,
            children: [
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Father Name', controller: _regFields['father_name']!, prefixIcon: Icons.person_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Father Occupation', controller: _regFields['father_occupation']!, prefixIcon: Icons.work_rounded)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Mother Name', controller: _regFields['mother_name']!, prefixIcon: Icons.person_outline_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Mother Occupation', controller: _regFields['mother_occupation']!, prefixIcon: Icons.work_outline_rounded)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildInput(label: 'Brothers Count', controller: _regFields['brother_count']!, keyboardType: TextInputType.number, prefixIcon: Icons.groups_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Sisters Count', controller: _regFields['sister_count']!, keyboardType: TextInputType.number, prefixIcon: Icons.groups_outlined)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Family Type',
                      value: _regFields['family_type']?.text,
                      items: const ['Nuclear', 'Joint'],
                      onChanged: (val) => setState(() => _regFields['family_type']?.text = val ?? ''),
                      prefixIcon: Icons.diversity_3_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(label: 'Gotra', controller: _regFields['gotra']!, prefixIcon: Icons.history_edu_rounded)),
                ],
              ),
              _buildInput(label: 'About Self', controller: _regFields['about_self']!, maxLines: 3, prefixIcon: Icons.notes_rounded),
              _buildInput(label: 'Partner Expectations', controller: _regFields['partner_expectations']!, maxLines: 3, prefixIcon: Icons.star_rounded),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isRegistering ? null : _register,
              icon: _isRegistering
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.person_add_rounded),
              label: Text(_isRegistering ? 'Registering…' : 'Register Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── CORRECT TAB ───────────────────────────────────────────────────────────
  Widget _buildCorrectTab() {
    final theme = Theme.of(context);
    if (_editingProfile == null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              style: theme.textTheme.bodyLarge,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search profile to correct…',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity50),
                ),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                    width: 1.5,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.search_rounded, color: theme.primaryColor),
                    onPressed: _search,
                  ),
                ),
              ),
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: theme.primaryColor),
            ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchCtrl.text.isEmpty
                              ? 'Search & select a profile to correct'
                              : 'No profiles found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (_, i) => _profileCard(_searchResults[i]),
                  ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: AppColors.opacity8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: AppColors.opacity15),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.person_rounded, color: theme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Editing: ${_editingProfile!.fullName}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _editingProfile = null;
                  });
                },
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Change'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildFormSection(
          context: context,
          title: 'Personal Details',
          icon: Icons.person_rounded,
          initiallyExpanded: true,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Full Name', controller: _editFields['full_name']!, isRequired: true, prefixIcon: Icons.badge_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Surname', controller: _editFields['surname']!, prefixIcon: Icons.badge_outlined)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Phone Number', controller: _editFields['phone_number']!, isRequired: true, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_android_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Age', controller: _editFields['age']!, keyboardType: TextInputType.number, prefixIcon: Icons.cake_rounded)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Gender',
                    value: _editGender,
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (val) => setState(() => _editGender = val ?? 'Male'),
                    prefixIcon: Icons.face_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Date of Birth (YYYY-MM-DD)', controller: _editFields['date_of_birth']!, hint: 'YYYY-MM-DD', prefixIcon: Icons.calendar_month_rounded)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Marital Status',
                    value: _editFields['marital_status']?.text,
                    items: const ['Single', 'Divorced', 'Widowed', 'Awaiting Divorce'],
                    onChanged: (val) => setState(() => _editFields['marital_status']?.text = val ?? ''),
                    prefixIcon: Icons.favorite_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Complexion',
                    value: _editFields['complexion']?.text,
                    items: const ['Very Fair', 'Fair', 'Medium', 'Wheatish', 'Dark'],
                    onChanged: (val) => setState(() => _editFields['complexion']?.text = val ?? ''),
                    prefixIcon: Icons.brush_rounded,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Height', controller: _editFields['height']!, hint: 'e.g. 5\'6"', prefixIcon: Icons.height_rounded)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Blood Group',
                    value: _editFields['blood_group']?.text,
                    items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                    onChanged: (val) => setState(() => _editFields['blood_group']?.text = val ?? ''),
                    prefixIcon: Icons.bloodtype_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildFormSection(
          context: context,
          title: 'Education & Career',
          icon: Icons.work_rounded,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Education', controller: _editFields['education']!, prefixIcon: Icons.school_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Profession', controller: _editFields['profession']!, prefixIcon: Icons.work_outline_rounded)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Company', controller: _editFields['company']!, prefixIcon: Icons.store_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Annual Income', controller: _editFields['annual_income']!, prefixIcon: Icons.payments_rounded)),
              ],
            ),
            _buildInput(label: 'Job Details', controller: _editFields['job_details']!, maxLines: 2, prefixIcon: Icons.description_rounded),
          ],
        ),
        _buildFormSection(
          context: context,
          title: 'Location Details',
          icon: Icons.place_rounded,
          children: [
            _buildDropdown(
              label: 'State',
              value: _editSelectedState,
              items: LocationData.states,
              onChanged: _onEditStateChanged,
              prefixIcon: Icons.map_rounded,
            ),
            _buildDropdown(
              label: 'District',
              value: _editSelectedDistrict,
              items: _editDistricts,
              onChanged: _onEditDistrictChanged,
              prefixIcon: Icons.location_city_rounded,
            ),
            _buildDropdown(
              label: 'Taluka',
              value: _editSelectedTaluka,
              items: _editTalukas,
              onChanged: _onEditTalukaChanged,
              prefixIcon: Icons.explore_rounded,
            ),
            _buildInput(label: 'Village', controller: _editFields['village']!, prefixIcon: Icons.home_rounded),
          ],
        ),
        _buildFormSection(
          context: context,
          title: 'Family & Other Details',
          icon: Icons.family_restroom_rounded,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Father Name', controller: _editFields['father_name']!, prefixIcon: Icons.person_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Father Occupation', controller: _editFields['father_occupation']!, prefixIcon: Icons.work_rounded)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Mother Name', controller: _editFields['mother_name']!, prefixIcon: Icons.person_outline_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Mother Occupation', controller: _editFields['mother_occupation']!, prefixIcon: Icons.work_outline_rounded)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildInput(label: 'Brothers Count', controller: _editFields['brother_count']!, keyboardType: TextInputType.number, prefixIcon: Icons.groups_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Sisters Count', controller: _editFields['sister_count']!, keyboardType: TextInputType.number, prefixIcon: Icons.groups_outlined)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Family Type',
                    value: _editFields['family_type']?.text,
                    items: const ['Nuclear', 'Joint'],
                    onChanged: (val) => setState(() => _editFields['family_type']?.text = val ?? ''),
                    prefixIcon: Icons.diversity_3_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildInput(label: 'Gotra', controller: _editFields['gotra']!, prefixIcon: Icons.history_edu_rounded)),
              ],
            ),
            _buildInput(label: 'About Self', controller: _editFields['about_self']!, maxLines: 3, prefixIcon: Icons.notes_rounded),
            _buildInput(label: 'Partner Expectations', controller: _editFields['partner_expectations']!, maxLines: 3, prefixIcon: Icons.star_rounded),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveCorrection,
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
            label: Text(_isSaving ? 'Saving…' : 'Save Corrections'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── FORM HELPERS ──────────────────────────────────────────────────────────
  Widget _buildFormSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: theme.primaryColor),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          expandedAlignment: Alignment.topLeft,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: theme.textTheme.bodyMedium,
            validator: isRequired
                ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity50),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: theme.colorScheme.onSurfaceVariant, size: 20)
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
    String? hint,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);
    
    // Ensure the current value is actually in the items list to prevent crash
    final selectedValue = items.contains(value) ? value : null;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey('${label}_$selectedValue'),
            initialValue: selectedValue,
            isExpanded: true,
            dropdownColor: theme.cardColor,
            style: theme.textTheme.bodyMedium,
            validator: isRequired
                ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity50),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: theme.colorScheme.onSurfaceVariant, size: 20)
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
            items: items.map((g) {
              return DropdownMenuItem<String>(
                value: g,
                child: Text(
                  g,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Color _getOutcomeColor(String outcome) {
    switch (outcome.toLowerCase()) {
      case 'connected':
      case 'success':
        return Colors.green.shade600;
      case 'busy':
      case 'ringing':
        return Colors.orange.shade700;
      case 'switched off':
      case 'not reachable':
        return Colors.amber.shade800;
      case 'wrong number':
      case 'decline':
      case 'failed':
      default:
        return Colors.red.shade600;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final parsed = DateTime.parse(timestamp.toString()).toLocal();
      final now = DateTime.now();
      final difference = now.difference(parsed);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
    } catch (_) {
      return timestamp.toString();
    }
  }

  Widget _buildWorkLogTab() {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: _loadWorkLog,
      color: theme.primaryColor,
      child: Column(
        children: [
          // Lifetime Stats Header
          _buildLifetimeStatsHeader(),
          
          // Toggle Segment Selector
          _buildWorkLogToggle(),

          // List content
          Expanded(
            child: _isLoadingWorkLog
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  )
                : _buildWorkLogList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeStatsHeader() {
    if (_stats == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final totalCalled = _stats!['total_called'] ?? 0;
    final totalReg = _stats!['total_registered'] ?? 0;
    final totalCorr = _stats!['total_corrected'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: AppColors.opacity10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LIFETIME PERFORMANCE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.primaryColor,
              fontWeight: AppTypography.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLifetimeStatItem(
                  'Total Called',
                  '$totalCalled',
                  Icons.phone_rounded,
                  Colors.blue.shade600,
                ),
              ),
              Container(
                height: 32,
                width: 1,
                color: theme.dividerColor.withValues(alpha: AppColors.opacity50),
              ),
              Expanded(
                child: _buildLifetimeStatItem(
                  'Registered',
                  '$totalReg',
                  Icons.person_add_rounded,
                  theme.primaryColor,
                ),
              ),
              Container(
                height: 32,
                width: 1,
                color: theme.dividerColor.withValues(alpha: AppColors.opacity50),
              ),
              Expanded(
                child: _buildLifetimeStatItem(
                  'Corrected',
                  '$totalCorr',
                  Icons.edit_note_rounded,
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
                fontSize: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppTypography.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkLogToggle() {
    final theme = Theme.of(context);
    final isCalls = _workLogTab == 'calls';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: AppColors.opacity15),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _workLogTab = 'calls'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isCalls ? theme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_callback_rounded,
                        color: isCalls ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calls History (${_recentCalls.length})',
                        style: TextStyle(
                          color: isCalls ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: isCalls ? AppTypography.bold : FontWeight.normal,
                          fontSize: AppTypography.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _workLogTab = 'registrations'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !isCalls ? theme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        color: !isCalls ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Registrations (${_recentRegistrations.length})',
                        style: TextStyle(
                          color: !isCalls ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: !isCalls ? AppTypography.bold : FontWeight.normal,
                          fontSize: AppTypography.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkLogList() {
    final isCalls = _workLogTab == 'calls';
    final items = isCalls ? _recentCalls : _recentRegistrations;

    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCalls ? Icons.phone_disabled_rounded : Icons.person_add_disabled_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity30),
              ),
              const SizedBox(height: 16),
              Text(
                isCalls ? 'No calls logged today' : 'No registrations logged today',
                style: TextStyle(
                  fontWeight: AppTypography.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh and fetch latest activity',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return isCalls
            ? _buildCallHistoryCard(item)
            : _buildRegistrationHistoryCard(item);
      },
    );
  }

  Widget _buildCallHistoryCard(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final name = '${item['profile_name'] ?? 'Candidate'} ${item['profile_surname'] ?? ''}'.trim();
    final outcome = item['outcome']?.toString() ?? 'Connected';
    final notes = item['notes']?.toString() ?? '';
    final timeStr = _formatTimestamp(item['created_at']);
    final phone = item['profile_phone_number']?.toString() ?? '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.primaryColor.withValues(alpha: AppColors.opacity8),
        ),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Unknown Candidate' : name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOutcomeColor(outcome).withValues(alpha: AppColors.opacity10),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    outcome,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getOutcomeColor(outcome),
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.phone_rounded, color: Colors.green),
                    onPressed: () async {
                      final uri = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                      final mockProfile = ProfileModel.fromJson({
                        'id': item['profile_id'] ?? '',
                        'full_name': item['profile_name'] ?? '',
                        'surname': item['profile_surname'] ?? '',
                        'phone_number': phone,
                      });
                      _openCallLoggingSheet(mockProfile);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: AppColors.opacity10),
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: AppColors.opacity5),
                  ),
                ),
                child: Text(
                  notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity80),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationHistoryCard(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final name = '${item['full_name'] ?? 'Candidate'} ${item['surname'] ?? ''}'.trim();
    final phone = item['phone_number']?.toString() ?? '';
    final timeStr = _formatTimestamp(item['created_at']);
    final location = [
      item['taluka'],
      item['district'],
      item['state'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.primaryColor.withValues(alpha: AppColors.opacity8),
        ),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Unknown Candidate' : name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ],
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity50),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Registered $timeStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor.withValues(alpha: AppColors.opacity70),
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
            ),
            if (phone.isNotEmpty) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: Colors.green),
                onPressed: () async {
                  final uri = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                  final mockProfile = ProfileModel.fromJson(item);
                  _openCallLoggingSheet(mockProfile);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: AppColors.opacity10),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}






