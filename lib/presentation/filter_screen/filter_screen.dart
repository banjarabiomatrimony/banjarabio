import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class FilterScreen extends StatefulWidget {
  final FilterCriteria? initialFilters;
  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isPremium = false;
  bool _isLoading = true;
  late FilterCriteria _currentFilters;

  final LocalCacheService _cacheService = LocalCacheService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  List<String> _recentSearches = [];

  // Default age bounds for dual range slider
  static const double _minAgeLimit = 18;
  static const double _maxAgeLimit = 70;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters ?? const FilterCriteria();
    _searchController.text = _currentFilters.searchQuery ?? '';
    _districtController.text = _currentFilters.district ?? '';
    _checkPremiumStatus();
    _loadSearchHistory();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final response = await _profileRepository.getOwnProfile();
      await response.fold(
        onSuccess: (profile) async {
          if (mounted) {
            setState(() {
              _isPremium = profile?.isPremium ?? false;
              _isLoading = false;
            });
          }
        },
        onFailure: (error) async {
          AppLogger.error('FilterScreen', 'FilterScreen: Error fetching profile: $error');
          if (mounted) {
            setState(() {
              _isPremium = false;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      AppLogger.error('FilterScreen', 'FilterScreen: Exception in _checkPremiumStatus: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadSearchHistory() {
    setState(() {
      _recentSearches = _cacheService.getSearchHistory();
    });
  }

  void _onSearchCleared() {
    HapticFeedback.lightImpact();
    _searchController.clear();
    setState(() {
      _currentFilters = _currentFilters.copyWith(searchQuery: '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_searchController.text.trim().isNotEmpty) count++;
    if (_currentFilters.minAge != null || _currentFilters.maxAge != null) count++;
    if (_currentFilters.gender != null && _currentFilters.gender!.isNotEmpty) count++;
    if (_currentFilters.hasPhoto == true) count++;
    if (_currentFilters.maritalStatus != null && _currentFilters.maritalStatus!.isNotEmpty) count++;
    if (_currentFilters.education != null && _currentFilters.education!.isNotEmpty) {
      count += _currentFilters.education!.length;
    }
    if (_currentFilters.profession != null && _currentFilters.profession!.isNotEmpty) {
      count += _currentFilters.profession!.length;
    }
    if (_currentFilters.gotra != null && _currentFilters.gotra!.isNotEmpty) {
      count += _currentFilters.gotra!.length;
    }
    if (_currentFilters.minHeight != null || _currentFilters.maxHeight != null) count++;
    if (_currentFilters.annualIncome != null && _currentFilters.annualIncome!.isNotEmpty) {
      count += _currentFilters.annualIncome!.length;
    }
    if (_currentFilters.familyType != null && _currentFilters.familyType!.isNotEmpty) {
      count += _currentFilters.familyType!.length;
    }
    if (_currentFilters.familyStatus != null && _currentFilters.familyStatus!.isNotEmpty) {
      count += _currentFilters.familyStatus!.length;
    }
    if (_currentFilters.profileCreatedBy != null && _currentFilters.profileCreatedBy!.isNotEmpty) {
      count += _currentFilters.profileCreatedBy!.length;
    }
    if (_currentFilters.state != null && _currentFilters.state!.isNotEmpty) count++;
    if (_currentFilters.district != null && _currentFilters.district!.isNotEmpty) count++;
    if (_currentFilters.isVerified == true) count++;
    if (_currentFilters.isCommunityTrusted == true) count++;
    if (_currentFilters.isDisabled != null) count++;
    return count;
  }

  void _applyFilters() async {
    HapticFeedback.mediumImpact();
    final query = _searchController.text.trim();
    final district = _districtController.text.trim();
    if (query.isNotEmpty) {
      await _cacheService.addSearchTerm(query);
    }
    _currentFilters = _currentFilters.copyWith(
      searchQuery: query,
      district: district.isNotEmpty ? district : '',
    );
    if (!mounted) return;
    Navigator.pop(context, _currentFilters);
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentFilters = const FilterCriteria();
      _searchController.clear();
      _districtController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: AppLocalizations.of(context)?.advancedFilters ?? 'Advanced Filters'),
        body: const FilterScreenSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)?.advancedFilters ?? 'Advanced Filters',
        actions: [
          if (_activeFilterCount > 0)
            Center(
              child: Container(
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$_activeFilterCount Active',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              AppLocalizations.of(context)?.reset ?? 'Reset',
              style: TextStyle(
                color: _activeFilterCount > 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient gradient blur
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.06),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickTierSelectorBar(theme, isDark),
                SizedBox(height: 2.5.h),

                // -------------------------------------------------------------
                // 🟢 TIER 1: FREE FILTERS (Available to all)
                // -------------------------------------------------------------
                _buildTierHeader(
                  theme: theme,
                  title: 'Free Basic Filters',
                  subtitle: 'Available to all community members',
                  badgeText: 'FREE',
                  badgeColor: const Color(0xFF2E7D32),
                  icon: Icons.lock_open_rounded,
                ),
                SizedBox(height: 1.8.h),
                _buildSearchSection(theme, isDark),
                SizedBox(height: 2.5.h),
                _buildGenderSection(theme, isDark),
                SizedBox(height: 2.5.h),
                _buildAgeSection(theme, isDark),
                SizedBox(height: 2.5.h),
                _buildPhotoOnlySection(theme, isDark),
                SizedBox(height: 2.5.h),
                _buildMaritalStatusSection(theme, isDark),
                SizedBox(height: 2.5.h),
                _buildLocationSection(theme, isDark),
                SizedBox(height: 3.5.h),

                // -------------------------------------------------------------
                // 🟡 TIER 2: SMART MATCH FILTERS (₹20/mo or ₹200/yr)
                // -------------------------------------------------------------
                _buildTierHeader(
                  theme: theme,
                  title: 'Smart Match Filters',
                  subtitle: 'Gotra, Height, Income & Family Criteria',
                  badgeText: '₹20/mo or ₹200/yr',
                  badgeColor: const Color(0xFFD4AF37),
                  icon: _isPremium ? Icons.stars_rounded : Icons.lock_outline_rounded,
                ),
                SizedBox(height: 1.8.h),
                _buildSmartFiltersContainer(theme, isDark),
                SizedBox(height: 3.5.h),

                // -------------------------------------------------------------
                // 🔒 TIER 3: PREMIUM PRICE FILTERS (INACTIVE / COMING SOON)
                // -------------------------------------------------------------
                _buildTierHeader(
                  theme: theme,
                  title: 'Premium Price Filters',
                  subtitle: 'ID Verification & VIP Matchmaker Criteria',
                  badgeText: 'INACTIVE • COMING SOON',
                  badgeColor: Colors.grey,
                  icon: Icons.lock_clock_rounded,
                ),
                SizedBox(height: 1.8.h),
                _buildPremiumInactiveContainer(theme, isDark),

                SizedBox(height: 14.h), // Space for floating bottom button
              ],
            ),
          ),

          // Floating Apply CTA Bar for ALL users
          _buildFloatingApplyBar(theme, isDark),
        ],
      ),
    );
  }

  /// Glassmorphic Section Header Helper
  Widget _buildSectionHeader({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    int? selectedCount,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (selectedCount != null && selectedCount > 0) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 1. Keyword Search Bar with Glass Card
  Widget _buildSearchSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.search_rounded,
            title: AppLocalizations.of(context)?.keywordSearch ?? 'Keyword Search',
            subtitle: 'Filter profiles by name, qualification, or role',
          ),
          SizedBox(height: 1.8.h),
          TextField(
            controller: _searchController,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.searchByNameJobEducation ??
                  'Search by name, job, education...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded),
                      onPressed: _onSearchCleared,
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? theme.colorScheme.surface.withValues(alpha: 0.5)
                  : const Color(0xFFF7F8FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.8.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(searchQuery: val);
              });
            },
          ),
          if (_recentSearches.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.recentSearches ?? 'Recent Searches',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await _cacheService.clearSearchHistory();
                    _loadSearchHistory();
                  },
                  child: Text(
                    AppLocalizations.of(context)?.clear ?? 'Clear',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _recentSearches.map(
                (term) {
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _searchController.text = term;
                      setState(() {
                        _currentFilters = _currentFilters.copyWith(searchQuery: term);
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 1.5.w),
                          Text(
                            term,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 2. Verification Badges Section (ID Verified & Community Trusted)
  Widget _buildVerificationBadgesSection(ThemeData theme, bool isDark) {
    final isVerified = _currentFilters.isVerified ?? false;
    final isTrusted = _currentFilters.isCommunityTrusted ?? false;

    Widget buildToggleTile({
      required String title,
      required String subtitle,
      required IconData icon,
      required bool value,
      required Color activeColor,
      required Function(bool) onChanged,
    }) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: value
              ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? activeColor.withValues(alpha: 0.5) : theme.dividerColor.withValues(alpha: 0.3),
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value ? activeColor : activeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 20,
                color: value ? Colors.white : activeColor,
              ),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeTrackColor: activeColor,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onChanged(val);
              },
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        buildToggleTile(
          title: 'Verified Profiles Only',
          subtitle: 'Show profiles with verified Govt ID badge',
          icon: Icons.verified_user_rounded,
          value: isVerified,
          activeColor: const Color(0xFF2E7D32),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isVerified: val);
            });
          },
        ),
        SizedBox(height: 1.5.h),
        buildToggleTile(
          title: 'Community Trusted Only',
          subtitle: 'Highly vouched & trusted Banjara profiles',
          icon: Icons.shield_rounded,
          value: isTrusted,
          activeColor: const Color(0xFFD4AF37),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isCommunityTrusted: val);
            });
          },
        ),
      ],
    );
  }

  /// 3. Photo Availability Switch Card
  Widget _buildPhotoOnlySection(ThemeData theme, bool isDark) {
    final hasPhoto = _currentFilters.hasPhoto ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: hasPhoto
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPhoto
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.dividerColor.withValues(alpha: 0.3),
          width: hasPhoto ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasPhoto
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.photo_camera_rounded,
              size: 22,
              color: hasPhoto ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Must Have Photo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  'Only show profiles with visible photos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: hasPhoto,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentFilters = _currentFilters.copyWith(hasPhoto: val);
              });
            },
          ),
        ],
      ),
    );
  }

  /// 4. Gender Segment Selector
  Widget _buildGenderSection(ThemeData theme, bool isDark) {
    final selectedGender = _currentFilters.gender ?? '';

    Widget buildGenderPill(String label, String value, IconData icon) {
      final isSelected = selectedGender.toLowerCase() == value.toLowerCase();
      return Expanded(
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _currentFilters = _currentFilters.copyWith(
                gender: isSelected ? '' : value,
              );
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 1.4.h),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.85),
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : isDark
                      ? theme.colorScheme.surface.withValues(alpha: 0.6)
                      : const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.2),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 1.5.w),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.wc_rounded,
            title: 'Looking For',
            subtitle: 'Select gender preference for matching profiles',
          ),
          SizedBox(height: 1.8.h),
          Row(
            children: [
              buildGenderPill('All', '', Icons.people_outline_rounded),
              SizedBox(width: 2.w),
              buildGenderPill('Bride', 'female', Icons.female_rounded),
              SizedBox(width: 2.w),
              buildGenderPill('Groom', 'male', Icons.male_rounded),
            ],
          ),
        ],
      ),
    );
  }

  /// 5. Dual Range Age Controller & Presets
  Widget _buildAgeSection(ThemeData theme, bool isDark) {
    final double minAge = (_currentFilters.minAge ?? 18).toDouble().clamp(_minAgeLimit, _maxAgeLimit);
    final double maxAge = (_currentFilters.maxAge ?? 60).toDouble().clamp(minAge, _maxAgeLimit);

    final RangeValues currentRange = RangeValues(minAge, maxAge);

    Widget buildPresetPill(String label, int min, int max) {
      final isSelected = _currentFilters.minAge == min && _currentFilters.maxAge == max;
      return InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _currentFilters = _currentFilters.copyWith(minAge: min, maxAge: max);
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : isDark
                    ? theme.colorScheme.surface.withValues(alpha: 0.4)
                    : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSectionHeader(
                  theme: theme,
                  icon: Icons.cake_rounded,
                  title: AppLocalizations.of(context)?.ageRange ?? 'Age Range',
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${minAge.toInt()} - ${maxAge.toInt()} yrs',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 12.0,
                elevation: 4,
              ),
              trackHeight: 6.0,
            ),
            child: RangeSlider(
              values: currentRange,
              min: _minAgeLimit,
              max: _maxAgeLimit,
              divisions: (_maxAgeLimit - _minAgeLimit).toInt(),
              labels: RangeLabels(
                '${currentRange.start.toInt()} yrs',
                '${currentRange.end.toInt()} yrs',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    minAge: values.start.round(),
                    maxAge: values.end.round(),
                  );
                });
              },
            ),
          ),

          SizedBox(height: 1.5.h),
          Text(
            'Quick Presets',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              buildPresetPill('18 - 25', 18, 25),
              buildPresetPill('22 - 28', 22, 28),
              buildPresetPill('25 - 35', 25, 35),
              buildPresetPill('30 - 45', 30, 45),
              buildPresetPill('Any Age', 18, 60),
            ],
          ),
        ],
      ),
    );
  }

  /// 6. Banjara Gotra Multi-Chip Section
  Widget _buildGotraSection(ThemeData theme, bool isDark) {
    final gotraOptions = [
      'Pawar / Pramara',
      'Rathod',
      'Chauan / Chauhan',
      'Jadhav',
      'Vaditya',
      'Naik',
      'Bhukya',
      'Khamawat',
      'Puri',
      'Other Gotra',
    ];
    final selectedList = _currentFilters.gotra ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.auto_awesome_rounded,
      title: 'Banjara Gotra (गोत्र)',
      subtitle: 'Select Gotras for customary match preferences',
      options: gotraOptions,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(gotra: list);
        });
      },
    );
  }

  /// 7. Height Preference Section
  Widget _buildHeightSection(ThemeData theme, bool isDark) {
    final heightOptions = [
      'Any Height',
      '5\'0"+',
      '5\'3"+',
      '5\'5"+',
      '5\'8"+',
      '6\'0"+',
    ];
    final selectedMin = _currentFilters.minHeight ?? 'Any Height';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.height_rounded,
            title: 'Minimum Height',
            subtitle: 'Select minimum height requirement',
          ),
          SizedBox(height: 1.8.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.2.h,
            children: heightOptions.map((h) {
              final isSelected = (selectedMin == h) || (h == 'Any Height' && (selectedMin.isEmpty || selectedMin == 'Any Height'));
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      minHeight: h == 'Any Height' ? '' : h,
                    );
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isDark
                            ? theme.colorScheme.surface.withValues(alpha: 0.6)
                            : const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    h,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 8. Education Multi-Chip Section
  Widget _buildEducationSection(ThemeData theme, bool isDark) {
    final options = [
      AppLocalizations.of(context)?.graduate ?? 'Graduate',
      AppLocalizations.of(context)?.postGraduate ?? 'Post Graduate',
      AppLocalizations.of(context)?.doctorate ?? 'Doctorate',
      AppLocalizations.of(context)?.professional ?? 'Professional',
      'High School / Below'
    ];
    final selectedList = _currentFilters.education ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.school_rounded,
      title: AppLocalizations.of(context)?.educationLabel ?? 'Education',
      subtitle: 'Select one or more education levels',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(education: list);
        });
      },
    );
  }

  /// 9. Profession Multi-Chip Section
  Widget _buildProfessionSection(ThemeData theme, bool isDark) {
    final options = [
      AppLocalizations.of(context)?.governmentJob ?? 'Government Job',
      AppLocalizations.of(context)?.privateJob ?? 'Private Job',
      AppLocalizations.of(context)?.business ?? 'Business',
      AppLocalizations.of(context)?.selfEmployed ?? 'Self Employed',
      'Software / IT',
      'Doctor / Healthcare',
      'Banking / Finance',
      'Teaching / Education',
    ];
    final selectedList = _currentFilters.profession ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.work_rounded,
      title: AppLocalizations.of(context)?.professionLabel ?? 'Profession',
      subtitle: 'Select occupation categories',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(profession: list);
        });
      },
    );
  }

  /// 10. Annual Income Section
  Widget _buildAnnualIncomeSection(ThemeData theme, bool isDark) {
    final options = [
      'Below ₹3 Lakhs',
      '₹3L - ₹6L',
      '₹6L - ₹10L',
      '₹10L - ₹15L',
      '₹15L+',
    ];
    final selectedList = _currentFilters.annualIncome ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.payments_rounded,
      title: 'Annual Income',
      subtitle: 'Select candidate income expectations',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(annualIncome: list);
        });
      },
    );
  }

  /// 11. Marital Status Single Selection Group
  Widget _buildMaritalStatusSection(ThemeData theme, bool isDark) {
    final options = [
      AppLocalizations.of(context)?.neverMarried ?? 'Never Married',
      AppLocalizations.of(context)?.divorced ?? 'Divorced',
      AppLocalizations.of(context)?.widowed ?? 'Widowed',
      AppLocalizations.of(context)?.awaitingDivorce ?? 'Awaiting Divorce',
    ];
    final selectedStatus = _currentFilters.maritalStatus ?? '';

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.favorite_rounded,
      title: AppLocalizations.of(context)?.maritalStatusLabel ?? 'Marital Status',
      subtitle: 'Select marital status requirement',
      options: options,
      selectedItems: selectedStatus.isNotEmpty ? [selectedStatus] : [],
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        setState(() {
          _currentFilters = _currentFilters.copyWith(
            maritalStatus: selectedStatus == opt ? '' : opt,
          );
        });
      },
    );
  }

  /// 12. Location (State & District) Selection
  Widget _buildLocationSection(ThemeData theme, bool isDark) {
    final states = [
      'Maharashtra',
      'Telangana',
      'Karnataka',
      'Andhra Pradesh',
      'Madhya Pradesh',
      'Gujarat',
      'Rajasthan',
      'Other States',
    ];
    final selectedState = _currentFilters.state ?? '';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.location_on_rounded,
            title: 'Location & State',
            subtitle: 'Filter candidate home state or native place',
          ),
          SizedBox(height: 1.8.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.2.h,
            children: states.map((st) {
              final isSelected = selectedState.toLowerCase() == st.toLowerCase();
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      state: isSelected ? '' : st,
                    );
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isDark
                            ? theme.colorScheme.surface.withValues(alpha: 0.6)
                            : const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    st,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _districtController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter District (e.g. Nanded, Yavatmal, Nizamabad)',
              prefixIcon: Icon(
                Icons.map_rounded,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: isDark
                  ? theme.colorScheme.surface.withValues(alpha: 0.5)
                  : const Color(0xFFF7F8FA),
              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) {
              _currentFilters = _currentFilters.copyWith(district: val);
            },
          ),
        ],
      ),
    );
  }

  /// 13. Family Type Section
  Widget _buildFamilyTypeSection(ThemeData theme, bool isDark) {
    final options = ['Nuclear Family', 'Joint Family'];
    final selectedList = _currentFilters.familyType ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.groups_rounded,
      title: 'Family Type',
      subtitle: 'Select family structure preference',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(familyType: list);
        });
      },
    );
  }

  /// 14. Family Status Section
  Widget _buildFamilyStatusSection(ThemeData theme, bool isDark) {
    final options = ['Middle Class', 'Upper Middle Class', 'Rich / Affluent'];
    final selectedList = _currentFilters.familyStatus ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.villa_rounded,
      title: 'Family Status',
      subtitle: 'Select socioeconomic family status',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(familyStatus: list);
        });
      },
    );
  }

  /// 15. Profile Created By Section
  Widget _buildProfileCreatedBySection(ThemeData theme, bool isDark) {
    final options = ['Self', 'Parent', 'Sibling', 'Relative / Friend'];
    final selectedList = _currentFilters.profileCreatedBy ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.person_pin_rounded,
      title: 'Profile Managed By',
      subtitle: 'Select who created the candidate biodata',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(profileCreatedBy: list);
        });
      },
    );
  }

  /// 16. Physical Disability Section
  Widget _buildPhysicalStatusSection(ThemeData theme, bool isDark) {
    final bool? isDisabled = _currentFilters.isDisabled;

    Widget buildOptionPill(String label, bool? value) {
      final isSelected = isDisabled == value;
      return Expanded(
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _currentFilters = _currentFilters.copyWith(isDisabled: value);
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 1.4.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDark
                      ? theme.colorScheme.surface.withValues(alpha: 0.6)
                      : const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.accessible_rounded,
            title: 'Physical Disability',
            subtitle: 'Select physical status requirements',
          ),
          SizedBox(height: 1.8.h),
          Row(
            children: [
              buildOptionPill('All Profiles', null),
              SizedBox(width: 2.w),
              buildOptionPill('Able-Bodied', false),
              SizedBox(width: 2.w),
              buildOptionPill('Differently Abled', true),
            ],
          ),
        ],
      ),
    );
  }

  /// Shared Multi-Chip Group Builder
  Widget _buildGlassMultiChipGroup({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> options,
    required List<String> selectedItems,
    required Function(String) onToggle,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: icon,
            title: title,
            subtitle: subtitle,
            selectedCount: selectedItems.length,
          ),
          SizedBox(height: 1.8.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.4.h,
            children: options.map((opt) {
              final isSelected = selectedItems.contains(opt);
              return InkWell(
                onTap: () => onToggle(opt),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.85),
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isDark
                            ? theme.colorScheme.surface.withValues(alpha: 0.6)
                            : const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withValues(alpha: 0.25),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                        SizedBox(width: 1.5.w),
                      ],
                      Text(
                        opt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Floating Glass Bottom Apply Button
  Widget _buildFloatingApplyBar(ThemeData theme, bool isDark) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.only(
              left: 5.w,
              right: 5.w,
              top: 2.h,
              bottom: 3.h,
            ),
            decoration: BoxDecoration(
              color: (isDark ? theme.scaffoldBackgroundColor : Colors.white)
                  .withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 6.2.h,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.85),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2.5.w),
                        Text(
                          _activeFilterCount > 0
                              ? '${AppLocalizations.of(context)?.applyFilters ?? 'Apply Filters'} ($_activeFilterCount)'
                              : AppLocalizations.of(context)?.applyFilters ?? 'Apply Filters',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildPerkRow(ThemeData theme, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Tier Navigation & Section Header Helpers
  Widget _buildQuickTierSelectorBar(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildTierChip(
            theme: theme,
            label: 'Free Filters',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF2E7D32),
            isSelected: true,
          ),
          SizedBox(width: 1.w),
          _buildTierChip(
            theme: theme,
            label: '₹20/mo Filters',
            icon: _isPremium ? Icons.stars_rounded : Icons.lock_outline_rounded,
            color: const Color(0xFFD4AF37),
            isSelected: false,
            onTap: () {
              if (!_isPremium) {
                _showSmartFilterUpgradeSheet(context, theme, isDark);
              }
            },
          ),
          SizedBox(width: 1.w),
          _buildTierChip(
            theme: theme,
            label: 'Premium (Inactive)',
            icon: Icons.lock_clock_rounded,
            color: Colors.grey,
            isSelected: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium price filters are currently inactive.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTierChip({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.w),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: color.withValues(alpha: 0.5)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 1.w),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 8.5.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierHeader({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: badgeColor, size: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 0.2.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tier 2: Smart Filters (₹20/m or ₹200/yr) Container
  Widget _buildSmartFiltersContainer(ThemeData theme, bool isDark) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGotraSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildHeightSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildEducationSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildProfessionSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildAnnualIncomeSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildFamilyTypeSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildFamilyStatusSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildProfileCreatedBySection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildPhysicalStatusSection(theme, isDark),
      ],
    );

    if (_isPremium) {
      return child;
    }

    return Stack(
      children: [
        IgnorePointer(
          child: Opacity(
            opacity: 0.45,
            child: child,
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showSmartFilterUpgradeSheet(context, theme, isDark),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 2.h),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 32,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    'Unlock Smart Match Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    'Unlock Gotra, Height, Income, Profession & Family criteria for ₹20/month or ₹200/year.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF961B33), Color(0xFF731224)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF961B33).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Unlock for ₹20/mo or ₹200/yr',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  /// Tier 3: Premium Price Filters (Inactive) Container
  Widget _buildPremiumInactiveContainer(ThemeData theme, bool isDark) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVerificationBadgesSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildAstroMatchingSection(theme, isDark),
        SizedBox(height: 2.5.h),
        _buildVipMatchmakerSection(theme, isDark),
      ],
    );

    return Stack(
      children: [
        IgnorePointer(
          child: Opacity(
            opacity: 0.4,
            child: child,
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium price filters are currently inactive.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Premium Price Filters (Inactive)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'ID Verification, VIP & Astro match filters are currently inactive.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Modal Bottom Sheet for ₹20/mo or ₹200/yr Filter Plan Upgrade
  void _showSmartFilterUpgradeSheet(BuildContext context, ThemeData theme, bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B1B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.5.h),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 36,
                  color: Color(0xFFD4AF37),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Unlock Smart Match Filters',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Only ₹20 / month  •  ₹200 / year',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              _buildPerkRow(theme, 'Banjara Gotra & Clan filters'),
              SizedBox(height: 1.h),
              _buildPerkRow(theme, 'Height & Physical status filters'),
              SizedBox(height: 1.h),
              _buildPerkRow(theme, 'Annual Income & Profession brackets'),
              SizedBox(height: 1.h),
              _buildPerkRow(theme, 'Family Type & Socioeconomic status'),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF961B33),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Upgrade Plan (₹20/mo or ₹200/yr)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Continue with Free Filters',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        );
      },
    );
  }

  /// Placeholder Section: Astro & Kundali Match
  Widget _buildAstroMatchingSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.auto_awesome_rounded,
            title: 'Astro & Kundali Match',
            subtitle: 'Filter by Guna score & Rashi compatibility',
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    '36 Guna Score & Horoscope Matching (Inactive)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  /// Placeholder Section: VIP Matchmaker Direct Contact
  Widget _buildVipMatchmakerSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.contact_phone_rounded,
            title: 'VIP Direct Contact Access',
            subtitle: 'Instant phone & WhatsApp access filters',
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.purpleAccent, size: 20),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Direct Phone Number Verified Profiles (Inactive)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}
