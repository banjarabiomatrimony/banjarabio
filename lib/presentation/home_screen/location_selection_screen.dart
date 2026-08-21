import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _recentLocations = [];

  // Manual selection state
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String _searchQuery = '';
  bool _isSearchExpanded = false;

  AnimationController? _animController;
  Animation<double>? _fadeAnimation;
  AnimationController? _pulseController;

  void _initAnimations() {
    _animController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();

    _fadeAnimation ??= CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOutCubic,
    );

    _pulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRecentLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  Future<void> _loadRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _recentLocations = prefs.getStringList('recent_locations') ?? [];
      });
    }
  }

  Future<void> _saveRecentLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> current = prefs.getStringList('recent_locations') ?? [];
    if (current.contains(location)) {
      current.remove(location);
    }
    current.insert(0, location);
    if (current.length > 6) {
      current = current.sublist(0, 6);
    }
    await prefs.setStringList('recent_locations', current);
  }

  void _onLocationSelected({String? taluka, String? district, String? state}) {
    HapticFeedback.selectionClick();
    final Map<String, String?> result = {
      'taluka': taluka,
      'district': district,
      'state': state,
    };

    String displayString;
    final locTaluka = LocationData.getLocalizedName(taluka, context);
    final locDistrict = LocationData.getLocalizedName(district, context);
    final locState = LocationData.getLocalizedName(state, context);

    if (locTaluka.isNotEmpty && locDistrict.isNotEmpty) {
      displayString = '$locTaluka, $locDistrict';
    } else if (locDistrict.isNotEmpty) {
      displayString = locDistrict;
    } else if (locState.isNotEmpty) {
      displayString = locState;
    } else {
      displayString = AppLocalizations.of(context)?.allIndia ?? 'All India';
    }

    if (displayString != (AppLocalizations.of(context)?.allIndia ?? 'All India')) {
      _saveRecentLocation(displayString);
    }

    Navigator.pop(context, result);
  }

  void _toggleSearch() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _stepBack() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedTaluka != null) {
        _selectedTaluka = null;
      } else if (_selectedDistrict != null) {
        _selectedDistrict = null;
      } else {
        _selectedState = null;
      }
    });
    _animController?.forward(from: 0.0);
  }

  void _resetHierarchy() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedState = null;
      _selectedDistrict = null;
      _selectedTaluka = null;
    });
    _animController?.forward(from: 0.0);
  }

  // ─── STATE STYLING METADATA ───
  Map<String, dynamic> _getStateMetadata(String state) {
    switch (state) {
      case 'Maharashtra':
        return {
          'icon': '🚩',
          'sub': 'अस्सल महाराष्ट्र',
          'gradient': const [Color(0xFFBE123C), Color(0xFF881337)],
          'tag': 'TOP POPULAR',
          'tagColor': const Color(0xFFF59E0B),
          'accent': const Color(0xFFBE123C),
        };
      case 'Karnataka':
        return {
          'icon': '🌟',
          'sub': 'ಕರ್ನಾಟಕ',
          'gradient': const [Color(0xFF047857), Color(0xFF064E3B)],
          'tag': 'ACTIVE',
          'tagColor': const Color(0xFF10B981),
          'accent': const Color(0xFF059669),
        };
      case 'Telangana':
        return {
          'icon': '🏛️',
          'sub': 'తెలంగాణ',
          'gradient': const [Color(0xFF4338CA), Color(0xFF312E81)],
          'tag': 'GROWING',
          'tagColor': const Color(0xFF818CF8),
          'accent': const Color(0xFF6366F1),
        };
      case 'Andhra Pradesh':
        return {
          'icon': '🌅',
          'sub': 'ఆంధ్ర ప్రదేశ్',
          'gradient': const [Color(0xFF0284C7), Color(0xFF075985)],
          'tag': 'POPULAR',
          'tagColor': const Color(0xFF38BDF8),
          'accent': const Color(0xFF0EA5E9),
        };
      case 'Madhya Pradesh':
        return {
          'icon': '🌲',
          'sub': 'मध्य प्रदेश',
          'gradient': const [Color(0xFFB45309), Color(0xFF78350F)],
          'tag': 'CENTRAL',
          'tagColor': const Color(0xFFFBBF24),
          'accent': const Color(0xFFD97706),
        };
      case 'Gujarat':
        return {
          'icon': '🪔',
          'sub': 'ગુજરાત',
          'gradient': const [Color(0xFFD97706), Color(0xFF92400E)],
          'tag': 'WESTERN',
          'tagColor': const Color(0xFFFDE68A),
          'accent': const Color(0xFFF59E0B),
        };
      case 'Rajasthan':
        return {
          'icon': '🏰',
          'sub': 'राजस्थान',
          'gradient': const [Color(0xFF9F1239), Color(0xFF4C0519)],
          'tag': 'HERITAGE',
          'tagColor': const Color(0xFFFDA4AF),
          'accent': const Color(0xFFE11D48),
        };
      default:
        return {
          'icon': '📍',
          'sub': state,
          'gradient': const [Color(0xFF475569), Color(0xFF1E293B)],
          'tag': 'STATE',
          'tagColor': const Color(0xFF94A3B8),
          'accent': const Color(0xFF64748B),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = theme.appBarTheme.foregroundColor ?? Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 175,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: foreground,
                    size: 16,
                  ),
                ),
              ),
              ClipOval(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select',
              style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
                fontSize: AppTypography.headingSmall,
                fontWeight: AppTypography.bold,
                color: foreground,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: Color(0xFFFBBF24),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: TactilePressable(
                onTap: _toggleSearch,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: _isSearchExpanded
                        ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.20)
                        : foreground.withValues(alpha: isDark ? 0.12 : 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isSearchExpanded
                          ? const Color(0xFFF59E0B)
                          : foreground.withValues(alpha: isDark ? 0.25 : 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
                        color: _isSearchExpanded ? const Color(0xFFF59E0B) : foreground,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSearchExpanded ? 'Close' : 'Search',
                        style: TextStyle(
                          color: _isSearchExpanded ? const Color(0xFFF59E0B) : foreground,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.labelSmall,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: _isSearchExpanded
            ? PreferredSize(
                preferredSize: Size.fromHeight(6.2.h),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(3.5.w, 0, 3.5.w, 1.0.h),
                  child: Container(
                    height: 4.8.h,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.20 : 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim().toLowerCase();
                        });
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.semiBold,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.searchStateDistrictOrTaluka ??
                            'Search State, District or Taluka...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: AppTypography.bodySmall,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? TactilePressable(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.5.h),
        child: FadeTransition(
          opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
          child: _searchQuery.isNotEmpty
              ? _buildSearchResults(theme, isDark)
              : _buildHierarchicalSelection(theme, isDark),
        ),
      ),
    );
  }

  // ─── 1. Hierarchical Selection Mode ───
  Widget _buildHierarchicalSelection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👑 Radiant All-India Master Card (24K Gold & Crimson Obsidian Glow)
        TactilePressable(
          onTap: () => _onLocationSelected(),
          child: Container(
            padding: EdgeInsets.all(3.8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF38151D), const Color(0xFF1E1528), const Color(0xFF14121E)]
                    : [const Color(0xFFBE123C), const Color(0xFF881337), const Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.30 : 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Glowing Animated Globe Emblem
                AnimatedBuilder(
                  animation: _pulseController ?? const AlwaysStoppedAnimation(0.0),
                  builder: (context, child) {
                    final pulse = _pulseController?.value ?? 0.0;
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35 + (0.25 * pulse)),
                            blurRadius: 10 + (4 * pulse),
                            spreadRadius: 1 * pulse,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.public_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    );
                  },
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)?.allIndia ?? 'All India',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: AppTypography.black,
                              fontSize: AppTypography.bodyLarge,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'PAN-INDIA',
                              style: TextStyle(
                                color: const Color(0xFFFDE68A),
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Browse 10,000+ candidate profiles across all states',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.medium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ),

        // Recently Selected Locations
        if (_recentLocations.isNotEmpty) ...[
          SizedBox(height: 2.0.h),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded, size: 13, color: Color(0xFFF59E0B)),
              ),
              SizedBox(width: 2.w),
              Text(
                AppLocalizations.of(context)?.recentlyUsed ?? 'RECENT LOCATIONS',
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  fontWeight: AppTypography.extraBold,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          SizedBox(
            height: 4.4.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recentLocations.length,
              separatorBuilder: (_, _) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final loc = _recentLocations[index];
                return TactilePressable(
                  onTap: () {
                    final parts = loc.split(', ');
                    if (parts.length >= 2) {
                      _onLocationSelected(taluka: parts[0], district: parts[1]);
                    } else {
                      _onLocationSelected(district: loc);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1828) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                            : const Color(0xFFE2E8F0),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 5),
                        Text(
                          LocationData.getLocalizedFullLocation(loc, context),
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.bold,
                            color: isDark ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        SizedBox(height: 2.2.h),

        // Interactive Breadcrumb Header
        _buildBreadcrumbBar(theme, isDark),

        SizedBox(height: 1.2.h),

        // Hierarchy Level Lists with Staggered Entrance Animations
        if (_selectedState == null)
          _buildStatesList(theme, isDark)
        else if (_selectedDistrict == null)
          _buildDistrictsList(theme, isDark)
        else if (_selectedTaluka == null)
          _buildTalukasList(theme, isDark)
        else
          _buildCustomVillageInput(theme, isDark),
      ],
    );
  }

  // ─── 2. Breadcrumb Navigation Bar ───
  Widget _buildBreadcrumbBar(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TactilePressable(
                    onTap: _selectedState != null ? _resetHierarchy : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _selectedState == null
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🇮🇳 States',
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: _selectedState == null ? AppTypography.extraBold : AppTypography.semiBold,
                          color: _selectedState == null
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedState != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey),
                    ),
                    TactilePressable(
                      onTap: _selectedDistrict != null
                          ? () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedDistrict = null;
                                _selectedTaluka = null;
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _selectedDistrict == null
                              ? theme.colorScheme.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          LocationData.getLocalizedName(_selectedState, context),
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            fontWeight: _selectedDistrict == null ? AppTypography.extraBold : AppTypography.semiBold,
                            color: _selectedDistrict == null
                                ? theme.colorScheme.primary
                                : (isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_selectedDistrict != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        LocationData.getLocalizedName(_selectedDistrict, context),
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.extraBold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_selectedState != null) ...[
            TactilePressable(
              onTap: _stepBack,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 12, color: theme.colorScheme.primary),
                    const SizedBox(width: 3),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.extraBold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 3. Level 1: States List with Staggered Entrance Animations ───
  Widget _buildStatesList(ThemeData theme, bool isDark) {
    return Column(
      children: LocationData.states.asMap().entries.map((entry) {
        final index = entry.key;
        final state = entry.value;
        final meta = _getStateMetadata(state);
        final districtCount = LocationData.getDistricts(state).length;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 220 + (index * 40)),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, val, child) {
            return Transform.translate(
              offset: Offset(0, 16 * (1.0 - val)),
              child: Opacity(opacity: val, child: child),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 1.0.h),
            child: TactilePressable(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedState = state;
                  _selectedDistrict = null;
                  _selectedTaluka = null;
                });
                _animController?.forward(from: 0.0);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.4.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161424) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (meta['accent'] as Color).withValues(alpha: isDark ? 0.12 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // State Cultural Emblem
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: meta['gradient'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: (meta['gradient'][0] as Color).withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          meta['icon'] as String,
                          style: TextStyle(fontSize: AppTypography.headingMedium),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                LocationData.getLocalizedName(state, context),
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.extraBold,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: (meta['tagColor'] as Color).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  meta['tag'] as String,
                                  style: TextStyle(
                                    fontSize: AppTypography.labelTiny,
                                    fontWeight: AppTypography.extraBold,
                                    color: meta['tagColor'] as Color,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${meta['sub']} • $districtCount Districts available',
                            style: TextStyle(
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.medium,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── 4. Level 2: Districts List ───
  Widget _buildDistrictsList(ThemeData theme, bool isDark) {
    final districts = LocationData.getDistricts(_selectedState!);
    final meta = _getStateMetadata(_selectedState!);

    return Column(
      children: [
        // "All in State" Select Card
        Padding(
          padding: EdgeInsets.only(bottom: 1.2.h),
          child: TactilePressable(
            onTap: () => _onLocationSelected(state: _selectedState),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.select_all_rounded, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All in ${LocationData.getLocalizedName(_selectedState, context)} (State-wide)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: AppTypography.extraBold,
                            fontSize: AppTypography.bodyMedium,
                          ),
                        ),
                        Text(
                          'Match profiles anywhere across ${_selectedState!}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFFA7F3D0), size: 20),
                ],
              ),
            ),
          ),
        ),

        // District Tiles with Staggered Entrance
        ...districts.asMap().entries.map((entry) {
          final index = entry.key;
          final district = entry.value;
          final talukaCount = LocationData.getTalukas(district).length;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 180 + (index * 25)),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, val, child) {
              return Transform.translate(
                offset: Offset(0, 12 * (1.0 - val)),
                child: Opacity(opacity: val, child: child),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 0.8.h),
              child: TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedDistrict = district;
                    _selectedTaluka = null;
                  });
                  _animController?.forward(from: 0.0);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.3.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161424) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (meta['accent'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_city_rounded,
                          color: meta['accent'] as Color,
                          size: 17,
                        ),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Text(
                          LocationData.getLocalizedName(district, context),
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: AppTypography.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (talukaCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$talukaCount Talukas',
                            style: TextStyle(
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.bold,
                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── 5. Level 3: Talukas List ───
  Widget _buildTalukasList(ThemeData theme, bool isDark) {
    final talukas = LocationData.getTalukas(_selectedDistrict!);

    return Column(
      children: [
        // "All in District" Select Card
        Padding(
          padding: EdgeInsets.only(bottom: 1.2.h),
          child: TactilePressable(
            onTap: () => _onLocationSelected(
              district: _selectedDistrict,
              state: _selectedState,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFB45309)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All in ${LocationData.getLocalizedName(_selectedDistrict, context)} (District-wide)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: AppTypography.extraBold,
                            fontSize: AppTypography.bodyMedium,
                          ),
                        ),
                        Text(
                          'Match profiles across entire ${_selectedDistrict!} district',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFFFDE68A), size: 20),
                ],
              ),
            ),
          ),
        ),

        // Talukas Tiles
        ...talukas.asMap().entries.map((entry) {
          final index = entry.key;
          final taluka = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 160 + (index * 20)),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, val, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1.0 - val)),
                child: Opacity(opacity: val, child: child),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 0.8.h),
              child: TactilePressable(
                onTap: () => _onLocationSelected(
                  taluka: taluka,
                  district: _selectedDistrict,
                  state: _selectedState,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.3.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161424) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.holiday_village_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Text(
                          LocationData.getLocalizedName(taluka, context),
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: AppTypography.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFFF59E0B), size: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        // Manual Custom Village / Tanda Button
        Padding(
          padding: EdgeInsets.only(top: 1.2.h),
          child: TactilePressable(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedTaluka = 'Custom';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.3.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_location_alt_rounded, color: Color(0xFF8B5CF6), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Enter Specific Village or Tanda Name',
                    style: TextStyle(
                      color: const Color(0xFF8B5CF6),
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.extraBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── 6. Level 4: Custom Village / Tanda Entry ───
  Widget _buildCustomVillageInput(ThemeData theme, bool isDark) {
    final villageController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161424) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_location_alt_rounded, color: Color(0xFF8B5CF6), size: 18),
                  ),
                  SizedBox(width: 2.5.w),
                  Text(
                    'Village / Tanda Name (Optional)',
                    style: TextStyle(
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              TextField(
                controller: villageController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: AppTypography.semiBold),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.villageTandaExampleHint ?? 'e.g. Pohradevi Tanda, Sevadas Nagar...',
                  hintStyle: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              SizedBox(height: 2.0.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onLocationSelected(
                        district: _selectedDistrict,
                        state: _selectedState,
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context)?.skipAndUseDistrict ?? 'Skip & Use District'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final val = villageController.text.trim();
                        _onLocationSelected(
                          taluka: val.isNotEmpty ? val : null,
                          district: _selectedDistrict,
                          state: _selectedState,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(AppLocalizations.of(context)?.applyLocation ?? 'Apply Location'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 7. Search Results Mode with Rich Badges ───
  Widget _buildSearchResults(ThemeData theme, bool isDark) {
    final query = _searchQuery;

    final stateMatches = LocationData.states
        .where((s) => s.toLowerCase().contains(query) || LocationData.getLocalizedName(s, context).toLowerCase().contains(query))
        .toList();

    final districtMatches = <MapEntry<String, String>>[];
    for (final entry in LocationData.districts.entries) {
      for (final dist in entry.value) {
        if (dist.toLowerCase().contains(query) || LocationData.getLocalizedName(dist, context).toLowerCase().contains(query)) {
          districtMatches.add(MapEntry(entry.key, dist));
        }
      }
    }

    final talukaMatches = <Map<String, String>>[];
    for (final entry in LocationData.talukas.entries) {
      final district = entry.key;
      final state = LocationData.districts.entries
          .firstWhere((e) => e.value.contains(district), orElse: () => const MapEntry('', []))
          .key;

      for (final tal in entry.value) {
        if (tal.toLowerCase().contains(query) || LocationData.getLocalizedName(tal, context).toLowerCase().contains(query)) {
          talukaMatches.add({'taluka': tal, 'district': district, 'state': state});
        }
      }
    }

    final totalCount = stateMatches.length + districtMatches.length + talukaMatches.length;

    if (totalCount == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFF59E0B)),
              ),
              SizedBox(height: 2.h),
              Text(
                'No locations found for "$query"',
                style: TextStyle(fontWeight: AppTypography.extraBold, fontSize: AppTypography.bodyMedium),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Try searching for another state, district or city.',
                style: TextStyle(color: Colors.grey, fontSize: AppTypography.bodySmall),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // States Matches
        if (stateMatches.isNotEmpty) ...[
          _buildSearchCategoryHeader('STATES', Icons.map_rounded, const Color(0xFF6366F1)),
          ...stateMatches.map((s) => _buildSearchTile(
                title: LocationData.getLocalizedName(s, context),
                subtitle: AppLocalizations.of(context)?.stateInIndia ?? 'State in India',
                badgeText: 'STATE',
                badgeColor: const Color(0xFF6366F1),
                onTap: () => _onLocationSelected(state: s),
                isDark: isDark,
              )),
          SizedBox(height: 1.5.h),
        ],

        // Districts Matches
        if (districtMatches.isNotEmpty) ...[
          _buildSearchCategoryHeader('DISTRICTS', Icons.location_city_rounded, const Color(0xFF0EA5E9)),
          ...districtMatches.map((d) => _buildSearchTile(
                title: LocationData.getLocalizedName(d.value, context),
                subtitle: 'District in ${LocationData.getLocalizedName(d.key, context)}',
                badgeText: 'DISTRICT',
                badgeColor: const Color(0xFF0EA5E9),
                onTap: () => _onLocationSelected(district: d.value, state: d.key),
                isDark: isDark,
              )),
          SizedBox(height: 1.5.h),
        ],

        // Talukas Matches
        if (talukaMatches.isNotEmpty) ...[
          _buildSearchCategoryHeader('TALUKAS & CITIES', Icons.holiday_village_rounded, const Color(0xFFF59E0B)),
          ...talukaMatches.map((t) => _buildSearchTile(
                title: LocationData.getLocalizedName(t['taluka'], context),
                subtitle: '${LocationData.getLocalizedName(t['district'], context)}, ${LocationData.getLocalizedName(t['state'], context)}',
                badgeText: 'TALUKA',
                badgeColor: const Color(0xFFF59E0B),
                onTap: () => _onLocationSelected(
                  taluka: t['taluka'],
                  district: t['district'],
                  state: t['state'],
                ),
                isDark: isDark,
              )),
        ],
      ],
    );
  }

  Widget _buildSearchCategoryHeader(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.labelSmall,
              fontWeight: AppTypography.extraBold,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTile({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TactilePressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161424) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: isDark ? 0.10 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: AppTypography.labelTiny,
                    fontWeight: AppTypography.extraBold,
                    color: badgeColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
