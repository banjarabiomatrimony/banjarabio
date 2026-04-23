import 'dart:ui' as ui;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';

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
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters ?? const FilterCriteria();
    _searchController.text = _currentFilters.searchQuery ?? '';
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
          debugPrint('FilterScreen: Error fetching profile: $error');
          if (mounted) {
            setState(() {
              _isPremium = false;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('FilterScreen: Exception in _checkPremiumStatus: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadSearchHistory() {
    setState(() {
      _recentSearches = _cacheService.getSearchHistory();
    });
  }

  void _onSearchCleared() {
    _searchController.clear();
    setState(() {
      _currentFilters = _currentFilters.copyWith(searchQuery: '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await _cacheService.addSearchTerm(query);
    }
    _currentFilters = _currentFilters.copyWith(searchQuery: query);
    if (!mounted) return;
    Navigator.pop(context, _currentFilters);
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = const FilterCriteria();
      _searchController.clear();
    });
  }

  Widget _buildSearchSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.keywordSearch ?? 'Keyword Search',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.searchByNameJobEducation ?? 'Search by name, job, education...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _onSearchCleared,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.5.h,
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
              Text(AppLocalizations.of(context)?.recentSearches ?? 'Recent Searches',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _cacheService.clearSearchHistory();
                  _loadSearchHistory();
                },
                child: Text(AppLocalizations.of(context)?.clear ?? 'Clear'),
              ),
            ],
          ),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _recentSearches
                .map(
                  (term) => ActionChip(
                    label: Text(term),
                    onPressed: () {
                      _searchController.text = term;
                      setState(() {
                        _currentFilters = _currentFilters.copyWith(
                          searchQuery: term,
                        );
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          TextButton(onPressed: _resetFilters, child: Text(AppLocalizations.of(context)?.reset ?? 'Reset')),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchSection(theme),
                SizedBox(height: 3.h),
                _buildAgeSection(theme),
                SizedBox(height: 3.h),
                _buildEducationSection(theme),
                SizedBox(height: 3.h),
                _buildProfessionSection(theme),
                SizedBox(height: 3.h),
                _buildMaritalStatusSection(theme),
                SizedBox(height: 12.h), // Space for button
              ],
            ),
          ),

          if (!_isPremium) _buildPremiumOverlay(theme),

          // Apply Button
          if (_isPremium)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text(AppLocalizations.of(context)?.applyFilters ?? 'Apply Filters'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.ageRange ?? 'Age Range',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(
                AppLocalizations.of(context)?.minAge ?? 'Min Age',
                [18, 20, 25, 30, 35, 40],
                _currentFilters.minAge,
                (val) => setState(
                  () => _currentFilters = _currentFilters.copyWith(minAge: val),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildDropdownFilter(
                AppLocalizations.of(context)?.maxAge ?? 'Max Age',
                [25, 30, 35, 40, 50, 60],
                _currentFilters.maxAge,
                (val) => setState(
                  () => _currentFilters = _currentFilters.copyWith(maxAge: val),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFilter<T>(
    String label,
    List<T> options,
    T? selected,
    Function(T?) onChanged,
  ) {
    return DropdownButtonFormField<T>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      items: options
          .map(
            (opt) => DropdownMenuItem(
              value: opt,
              child: Text(
                opt.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMaritalStatusSection(ThemeData theme) {
    final options = [
      AppLocalizations.of(context)?.neverMarried ?? 'Never Married',
      AppLocalizations.of(context)?.divorced ?? 'Divorced',
      AppLocalizations.of(context)?.widowed ?? 'Widowed',
      AppLocalizations.of(context)?.awaitingDivorce ?? 'Awaiting Divorce',
    ];
    return _buildChipSection(
      AppLocalizations.of(context)?.maritalStatusLabel ?? 'Marital Status',
      options,
      [_currentFilters.maritalStatus ?? ''],
      (val) {
        setState(
          () => _currentFilters = _currentFilters.copyWith(maritalStatus: val),
        );
      },
    );
  }

  Widget _buildEducationSection(ThemeData theme) {
    final options = [
      AppLocalizations.of(context)?.graduate ?? 'Graduate',
      AppLocalizations.of(context)?.postGraduate ?? 'Post Graduate',
      AppLocalizations.of(context)?.doctorate ?? 'Doctorate',
      AppLocalizations.of(context)?.professional ?? 'Professional'
    ];
    return _buildMultiChipSection(
      AppLocalizations.of(context)?.educationLabel ?? 'Education',
      options,
      _currentFilters.education ?? [],
      (val) {
        final list = List<String>.from(_currentFilters.education ?? []);
        if (list.contains(val)) {
          list.remove(val);
        } else {
          list.add(val);
        }
        setState(
          () => _currentFilters = _currentFilters.copyWith(education: list),
        );
      },
    );
  }

  Widget _buildProfessionSection(ThemeData theme) {
    final options = [
      AppLocalizations.of(context)?.governmentJob ?? 'Government Job',
      AppLocalizations.of(context)?.privateJob ?? 'Private Job',
      AppLocalizations.of(context)?.business ?? 'Business',
      AppLocalizations.of(context)?.selfEmployed ?? 'Self Employed',
    ];
    return _buildMultiChipSection(
      AppLocalizations.of(context)?.professionLabel ?? 'Profession',
      options,
      _currentFilters.profession ?? [],
      (val) {
        final list = List<String>.from(_currentFilters.profession ?? []);
        if (list.contains(val)) {
          list.remove(val);
        } else {
          list.add(val);
        }
        setState(
          () => _currentFilters = _currentFilters.copyWith(profession: list),
        );
      },
    );
  }

  Widget _buildMultiChipSection(
    String title,
    List<String> options,
    List<String> selected,
    Function(String) onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.5.h,
          children: options
              .map(
                (opt) => _buildPremiumChip(
                  label: opt,
                  isSelected: selected.contains(opt),
                  onTap: () => onToggle(opt),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildChipSection(
    String title,
    List<String> options,
    List<String> selected,
    Function(String) onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.5.h,
          children: options
              .map(
                (opt) => _buildPremiumChip(
                  label: opt,
                  isSelected: selected.contains(opt),
                  onTap: () => onToggle(opt),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// Custom "Tag" style chip for premium feel
  Widget _buildPremiumChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOverlay(ThemeData theme) {
    // Glassmorphism overlay
    return Stack(
      children: [
        // Blur Effect
        Positioned.fill(
          child: BackdropFilter(
            filter:
                // Use a modest blur for performance
                ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        // Center Card
        Center(
          child: Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CustomIconWidget(
                    iconName: 'lock',
                    size: 32,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(AppLocalizations.of(context)?.unlockAdvancedFilters ?? 'Unlock Advanced Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(AppLocalizations.of(context)?.upgradeToPremiumToAccessGranularFiltersF ?? 'Upgrade to Premium to access granular filters for profession, location, and more.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/subscription'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)?.upgradePlan ?? 'Upgrade Plan'),
                  ),
                ),
                SizedBox(height: 1.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)?.maybeLater ?? 'Maybe Later',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
