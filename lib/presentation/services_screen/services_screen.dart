import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/presentation/vendor_registration_screen/vendor_registration_screen.dart';
import 'package:banjarabio/theme/app_color_scheme.dart';

/// 🛍️ Ultra-Luxury Dedicated Banjara Wedding Services & Vendor Marketplace (Tab 3)
/// Features:
/// 1. Celebratory Animated Hero Banner with Trust Metrics & Shimmer
/// 2. Interactive Category Filter Switcher
/// 3. Dynamic Dropdown Filter Row (State, District, Budget, Price Low/High Sort, Verified Only)
/// 4. 8 Staggered Animated Jewel-Themed Service Cards with Real-Time Pricing & Ratings
/// 5. 1-Click WhatsApp Smart Quotation Sheet with Auto-Fill Profile Details
/// 6. B2B Vendor Partner Onboarding Card with Golden Shimmer
/// 7. 24/7 Direct WhatsApp & Phone Helpline
class ServicesScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const ServicesScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen>
    with TickerProviderStateMixin {
  AnimationController? _staggerController;
  AnimationController? _pulseController;
  AnimationController? _shimmerController;
  Animation<double>? _pulseAnimation;
  PageController? _bannerPageController;
  int _currentBannerIndex = 0;

  // ─── Category & Dropdown Filter States ───
  int _selectedFilterIndex = 0;
  String? _selectedState;
  String? _selectedDistrict;
  String _selectedSort = 'Recommended';
  String _selectedBudget = 'All Budgets';
  bool _verifiedOnly = false;

  final List<String> _filterCategories = [
    'All Services',
    '🎵 Entertainment',
    '🏛️ Venues & Decor',
    '🍛 Food & Rituals',
    '📸 Photo & Cinema',
  ];

  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated ★',
    'Most Popular 🔥',
  ];

  final List<String> _budgetOptions = [
    'All Budgets',
    'Under ₹25,000',
    '₹25,000 - ₹50,000',
    '₹50,000 - ₹1,00,000',
    '₹1,00,000+',
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('services_hub_screen');
    _initControllers();
  }

  void _initControllers() {
    _bannerPageController ??= PageController();

    _staggerController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    if (_pulseController == null) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat(reverse: true);
      _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }

    _shimmerController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _bannerPageController?.dispose();
    _staggerController?.dispose();
    _pulseController?.dispose();
    _shimmerController?.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedState != null ||
      _selectedDistrict != null ||
      _selectedSort != 'Recommended' ||
      _selectedBudget != 'All Budgets' ||
      _verifiedOnly;

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedState != null) count++;
    if (_selectedDistrict != null) count++;
    if (_selectedSort != 'Recommended') count++;
    if (_selectedBudget != 'All Budgets') count++;
    if (_verifiedOnly) count++;
    return count;
  }

  void _resetAllFilters() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedState = null;
      _selectedDistrict = null;
      _selectedSort = 'Recommended';
      _selectedBudget = 'All Budgets';
      _verifiedOnly = false;
      _selectedFilterIndex = 0;
    });
    Fluttertoast.showToast(msg: AppLocalizations.of(context)?.filtersResetToDefault ?? 'Filters reset to default');
  }

  Future<void> _launchUrlExternal(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        Fluttertoast.showToast(msg: AppLocalizations.of(context)?.couldNotLaunchUrl ?? 'Could not launch URL');
      }
    } catch (_) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.errorLaunchingLink ?? 'Error launching link');
    }
  }

  // ─── Dynamic Dropdown Bottom Sheet Selector ───
  void _showFilterSelectionSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<String> options,
    required String? currentValue,
    required ValueChanged<String?> onSelected,
    bool isSearchable = false,
  }) {
    HapticFeedback.lightImpact();
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final query = searchController.text.trim().toLowerCase();

          final filteredOptions = query.isEmpty
              ? options
              : options.where((o) => o.toLowerCase().contains(query)).toList();

          return Container(
            height: isSearchable ? 65.h : null,
            constraints: BoxConstraints(maxHeight: 75.h),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 2.h,
              left: 5.w,
              right: 5.w,
              top: 2.h,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.35 : 0.2),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: AppColors.opacity15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: AppColors.opacity20)
                          : Colors.grey.withValues(alpha: AppColors.opacity35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                SizedBox(height: 1.8.h),

                // Sheet Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: AppColors.opacity15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        title,
                        style:                         AppTypography.displayStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: AppTypography.headingSmall,
                        ),
                      ),
                    ),
                    if (currentValue != null && currentValue != options.first)
                      TextButton(
                        onPressed: () {
                          onSelected(null);
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Clear',
                          style:                           AppTypography.labelStyle(
                            color: theme.colorScheme.error,
                            fontSize: AppTypography.bodySmall,
                          ),
                        ),
                      ),
                  ],
                ),

                if (isSearchable) ...[
                  SizedBox(height: 1.5.h),
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setSheetState(() {}),
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search $title...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: context.colors.inputFill,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 1.5.h),

                // Options List
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredOptions.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: AppColors.opacity20),
                    ),
                    itemBuilder: (context, index) {
                      final option = filteredOptions[index];
                      final isSelected =
                          currentValue == option || (currentValue == null && index == 0);

                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelected(index == 0 ? null : option);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.4.h),
                          child: Row(
                            children: [
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight:
                                      isSelected ? AppTypography.extraBold : AppTypography.medium,
                                  color: isSelected
                                      ? accentColor
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded,
                                    color: accentColor, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() => searchController.dispose());
  }

  void _openVendorInquirySheet(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final title = item['title'] as String;
    final sub = item['sub'] as String;
    final icon = item['icon'] as IconData;
    final color = item['color'] as Color;
    final priceFormatted = item['priceFormatted'] as String;
    final tag = item['tag'] as String? ?? '⚡ FAST REPLY';

    final userProfile = SessionManager.instance.currentProfile;
    final nameController =
        TextEditingController(text: userProfile?.fullName ?? '');
    final phoneController =
        TextEditingController(text: userProfile?.phoneNumber ?? '');
    final talukaVillageController = TextEditingController(
      text: userProfile?.district ?? userProfile?.permanentLocation ?? '',
    );
    final dateController = TextEditingController();
    final noteController = TextEditingController(
      text:
          'I want $title and I want to check availability for this vendor in this budget with their provided package features.',
    );

    String dateType = 'Fixed Date (पक्की तारीख)';
    String inquiryState = _selectedState ?? 'Maharashtra';
    String inquiryDistrict =
        _selectedDistrict ?? userProfile?.district ?? 'Pune';

    final availableQuickChips = _getQuickChipsForService(title);
    final Set<String> selectedChips = {
      if (availableQuickChips.isNotEmpty) availableQuickChips.first,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          final bottomSafeArea = MediaQuery.of(ctx).padding.bottom;

          final List<String> currentDistricts =
              LocationData.districts[inquiryState] ??
                  ['Pune', 'Nanded', 'Yavatmal', 'Hyderabad', 'Kalaburagi'];

          return Container(
            constraints: BoxConstraints(maxHeight: 88.h),
            padding: EdgeInsets.only(
              bottom: bottomInset + bottomSafeArea + 1.2.h,
              left: 4.5.w,
              right: 4.5.w,
              top: 1.5.h,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.35 : 0.22),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scrollable Form Body
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle Bar
                        Center(
                          child: Container(
                            width: 44,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: AppColors.opacity20)
                                  : Colors.grey.withValues(alpha: AppColors.opacity35),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.8.h),

                        // Header Row with Jewel Icon & Price Anchor
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withValues(alpha: 0.75)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: AppColors.opacity35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(icon, color: Colors.white, size: 24),
                            ),
                            SizedBox(width: 3.5.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Get Free Quote',
                                        style:                                         AppTypography.labelStyle(
                                          color: color,
                                          fontSize: AppTypography.labelSmall,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: AppColors.opacity15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tag,
                                          style:                                           AppTypography.buttonStyle(
                                            color: Colors.green,
                                            fontSize: AppTypography.labelTiny,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    title,
                                    style:                                     AppTypography.displayStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: AppTypography.headingSmall,
                                    ),
                                  ),
                                  Text(
                                    '$sub • $priceFormatted',
                                    style:                                     AppTypography.labelStyle(
                                      color: color,
                                      fontSize: AppTypography.labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2.h),

                        // 👤 1. Contact Info: Name & Mobile
                        _buildSheetTextField(
                          context: context,
                          label: 'Your Full Name / नाव *',
                          controller: nameController,
                          prefixIcon: Icons.person_rounded,
                          accentColor: color,
                        ),
                        SizedBox(height: 1.2.h),

                        _buildSheetTextField(
                          context: context,
                          label: 'WhatsApp Mobile Number / मोबाईल *',
                          controller: phoneController,
                          prefixIcon: Icons.phone_iphone_rounded,
                          accentColor: color,
                          isPhone: true,
                        ),
                        SizedBox(height: 1.5.h),

                        // 📍 2. Wedding Location Section (State, District, Taluka/Village)
                        Text(
                          '📍 Wedding Location / लग्न ठिकाण',
                          style:                           AppTypography.buttonStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Row(
                          children: [
                            // State Picker
                            Expanded(
                              child: _buildSheetSelector(
                                context: context,
                                label: 'State',
                                value: inquiryState,
                                icon: Icons.map_rounded,
                                accentColor: color,
                                onTap: () {
                                  _showSheetPickerModal(
                                    context: context,
                                    title: AppLocalizations.of(context)?.selectState ?? 'Select State',
                                    options: LocationData.states,
                                    onSelected: (val) {
                                      setSheetState(() {
                                        inquiryState = val;
                                        inquiryDistrict =
                                            LocationData.districts[val]?.first ??
                                                'Pune';
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            // District Picker
                            Expanded(
                              child: _buildSheetSelector(
                                context: context,
                                label: 'District',
                                value: inquiryDistrict,
                                icon: Icons.location_city_rounded,
                                accentColor: color,
                                onTap: () {
                                  _showSheetPickerModal(
                                    context: context,
                                    title: 'Select District in $inquiryState',
                                    options: currentDistricts,
                                    onSelected: (val) {
                                      setSheetState(() => inquiryDistrict = val);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        _buildSheetTextField(
                          context: context,
                          label: 'Taluka / Village / Venue Name (गाव किंवा तालुका)',
                          controller: talukaVillageController,
                          prefixIcon: Icons.pin_drop_rounded,
                          accentColor: color,
                        ),
                        SizedBox(height: 1.5.h),

                        // 📅 3. Wedding Event Date & Type
                        Text(
                          '📅 Event Date & Status',
                          style:                           AppTypography.buttonStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Row(
                          children: [
                            _buildChoicePill(
                              label: 'Fixed Date (पक्की तारीख)',
                              isSelected:
                                  dateType == 'Fixed Date (पक्की तारीख)',
                              color: color,
                              onTap: () => setSheetState(() =>
                                  dateType = 'Fixed Date (पक्की तारीख)'),
                            ),
                            SizedBox(width: 2.w),
                            _buildChoicePill(
                              label: 'Tentative (अंदाजे)',
                              isSelected:
                                  dateType == 'Tentative Date (अंदाजे तारीख)',
                              color: color,
                              onTap: () => setSheetState(() =>
                                  dateType = 'Tentative Date (अंदाजे तारीख)'),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 730)),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                dateController.text =
                                    DateFormat('dd MMM yyyy').format(picked);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: _buildSheetTextField(
                              context: context,
                              label: dateController.text.isEmpty
                                  ? 'Select Wedding Date / तारीख निवडा *'
                                  : 'Selected Date',
                              controller: dateController,
                              prefixIcon: Icons.calendar_month_rounded,
                              accentColor: color,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),

                        // ⚙️ 4. Category-Smart Quick Requirement Chips
                        if (availableQuickChips.isNotEmpty) ...[
                          Text(
                            '✨ Specific Package Features Required',
                            style:                             AppTypography.buttonStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: AppTypography.labelSmall,
                            ),
                          ),
                          SizedBox(height: 0.8.h),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: availableQuickChips.map((chip) {
                              final isSelected = selectedChips.contains(chip);
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setSheetState(() {
                                    if (isSelected) {
                                      selectedChips.remove(chip);
                                    } else {
                                      selectedChips.add(chip);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withValues(
                                            alpha: isDark ? 0.3 : 0.15)
                                        : (isDark
                                            ? AppColors.shadowDark
                                            : AppColors.neutral100),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : (isDark
                                              ? Colors.white.withValues(alpha: AppColors.opacity8)
                                              : Colors.black.withValues(alpha: 0.06)),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        Icon(Icons.check_rounded,
                                            size: 13, color: color),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        chip,
                                        style: TextStyle(
                                          fontSize: AppTypography.labelSmall,
                                          fontWeight: isSelected
                                              ? AppTypography.extraBold
                                              : AppTypography.semiBold,
                                          color: isSelected
                                              ? color
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 1.5.h),
                        ],

                        // 📝 5. Specific Requirements Custom Message Box
                        _buildSheetTextField(
                          context: context,
                          label: 'Specific Requirements & Instructions / विशेष गरज',
                          controller: noteController,
                          prefixIcon: Icons.edit_note_rounded,
                          accentColor: color,
                          maxLines: 3,
                        ),

                        // 🔍 6. Active Screen Filters Automatic Context Pill
                        if (_selectedDistrict != null ||
                            _selectedBudget != 'All Budgets') ...[
                          SizedBox(height: 1.4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 0.9.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    theme.colorScheme.primary.withValues(alpha: AppColors.opacity20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_list_rounded,
                                    size: 16, color: theme.colorScheme.primary),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    'Active Filters Included: ${_selectedDistrict != null ? "📍 $_selectedDistrict • " : ""}${_selectedBudget != "All Budgets" ? "💰 $_selectedBudget • " : ""}↕️ $_selectedSort',
                                    style:                                     AppTypography.labelStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: AppTypography.labelTiny,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 1.h),

                // 🚀 7. Request Free Quote via WhatsApp Button (Pinned & Fully Visible)
                TactilePressable(
                  onTap: () async {
                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();
                    final village = talukaVillageController.text.trim();
                    final date = dateController.text.trim();
                    final note = noteController.text.trim();

                    if (name.isEmpty) {
                      Fluttertoast.showToast(
                          msg: 'Please enter your name');
                      return;
                    }

                    if (phone.isEmpty || phone.length < 10) {
                      Fluttertoast.showToast(
                          msg: 'Please enter valid 10-digit WhatsApp number');
                      return;
                    }

                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();

                    final buffer = StringBuffer();
                    buffer.write('💍 *BANJARABIO WEDDING SERVICE INQUIRY*%0A');
                    buffer.write('━━━━━━━━━━━━━━━━━━━━━━━%0A');
                    buffer.write('📌 *SERVICE REQUESTED:*%0A');
                    buffer.write('• *Category:* $title%0A');
                    buffer.write('• *Package Style:* $sub%0A');
                    buffer.write('• *Displayed Package Price:* $priceFormatted%0A');

                    buffer.write('%0A📍 *WEDDING LOCATION:*%0A');
                    buffer.write('• *State:* $inquiryState%0A');
                    buffer.write('• *District:* $inquiryDistrict%0A');
                    if (village.isNotEmpty) {
                      buffer.write('• *Taluka / Village / City:* $village%0A');
                    }

                    buffer.write('%0A📅 *EVENT DATE:*%0A');
                    buffer.write('• *Date Status:* $dateType%0A');
                    buffer.write('• *Date:* ${date.isNotEmpty ? date : "Date to be decided / बोलणी बाकी"}%0A');

                    buffer.write('%0A👤 *CLIENT CONTACT DETAILS:*%0A');
                    buffer.write('• *Name:* $name%0A');
                    buffer.write('• *WhatsApp Number:* $phone%0A');

                    if (_selectedDistrict != null ||
                        _selectedBudget != 'All Budgets') {
                      buffer.write('%0A🔍 *ACTIVE SCREEN FILTERS:*%0A');
                      if (_selectedDistrict != null) {
                        buffer.write('• *Filter District:* $_selectedDistrict%0A');
                      }
                      if (_selectedBudget != 'All Budgets') {
                        buffer.write('• *Selected Budget Filter:* $_selectedBudget%0A');
                      }
                    }

                    if (selectedChips.isNotEmpty) {
                      buffer.write('%0A⚙️ *SPECIFIC REQUIREMENTS SELECTED:*%0A');
                      for (final chip in selectedChips) {
                        buffer.write('  ✅ $chip%0A');
                      }
                    }

                    if (note.isNotEmpty) {
                      buffer.write('%0A📝 *CLIENT\'S SPECIFIC REQUIREMENTS:*%0A');
                      buffer.write('"$note"%0A');
                    }

                    buffer.write('%0A━━━━━━━━━━━━━━━━━━━━━━━%0A');
                    buffer.write('⚡ *Sent via BanjaraBio Services Hub (0% Commission)*%0A');
                    buffer.write('👉 *Please confirm vendor availability and share final quotation.*');

                    final whatsappUrl =
                        'https://wa.me/8186050406?text=${buffer.toString()}';
                    await _launchUrlExternal(whatsappUrl);
                  },
                  pressedScale: 0.97,
                  child: Container(
                    width: double.infinity,
                    height: 5.6.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.whatsapp, AppColors.whatsappDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.whatsapp.withValues(alpha: 0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 2.w),
                        Text(
                          'Request Free Quote via WhatsApp',
                          style:                           AppTypography.buttonStyle(
                            fontSize: AppTypography.bodyMedium,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      talukaVillageController.dispose();
      dateController.dispose();
      noteController.dispose();
    });
  }

  List<String> _getQuickChipsForService(String serviceTitle) {
    if (serviceTitle.contains('DJ') || serviceTitle.contains('Sound')) {
      return [
        '10k-20kW Full Sound Setup',
        'Banjara Folk & Gorboli Songs Playlist',
        'Sharpie Lights & Smoke Machine FX',
        'Live Dhol Tasha Team',
        'Generator Backup Included',
      ];
    } else if (serviceTitle.contains('Mandap') || serviceTitle.contains('Decor')) {
      return [
        'Royal Palace Stage Theme',
        'Fresh Flowers Canopy',
        'Grand Entry Tunnel & Arch',
        'Traditional Wooden Mandap',
        'Fiber Stage Backdrop',
      ];
    } else if (serviceTitle.contains('Floral') || serviceTitle.contains('Toran')) {
      return [
        'Fresh Rose & Jasmine Jaymala',
        'Traditional Welcome Gate Toran',
        'Stage Floral Border',
        'Car Floral Decoration',
      ];
    } else if (serviceTitle.contains('Catering') || serviceTitle.contains('Food')) {
      return [
        'Authentic Banjara (Daal Baati, Gulgule)',
        'Pure Veg Grand Buffet',
        'Table Pangat Service Format',
        'Live Chaat Counter',
        'Dessert & Ice Cream Bar',
      ];
    } else if (serviceTitle.contains('Photography') || serviceTitle.contains('Cinema')) {
      return [
        'Pre-Wedding Shoot',
        '4K Drone Aerial Cinematic Video',
        'Cinematic Teaser & Full Wedding Film',
        'Premium Hardcover Album',
        'Instagram Reels & Shorts',
      ];
    } else if (serviceTitle.contains('Makeup') || serviceTitle.contains('Mehndi')) {
      return [
        'HD Bridal Makeup',
        'Traditional Gor Banjara Bride Look',
        'Airbrush Makeup',
        'Full Bridal Hands & Feet Mehndi',
        'Home / Venue Visit Required',
      ];
    } else if (serviceTitle.contains('Guruji') || serviceTitle.contains('Ritual')) {
      return [
        'Lagna Muhurat & Kundali Vidhi',
        'Sant Sevalal Maharaj Pooja',
        'Gorboli & Marathi Mantras',
        'Complete Pooja Samagri Needed',
      ];
    } else if (serviceTitle.contains('Banquet') || serviceTitle.contains('Lawn')) {
      return [
        'AC Banquet Hall + Lawn Setup',
        'AC Rooms for Bride & Groom',
        'Outside Catering Allowed',
        'Dedicated Parking Space',
      ];
    }
    return [
      'Full Package Availability',
      'Instant Price Quotation',
      'On-Site Setup Assistance',
    ];
  }

  Widget _buildChoicePill({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : Colors.grey.withValues(alpha: AppColors.opacity12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style:               AppTypography.bodyStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                fontSize: AppTypography.labelSmall,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetSelector({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.shadowDark
              : AppColors.neutral100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: AppColors.opacity10)
                : Colors.black.withValues(alpha: AppColors.opacity8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.labelTiny,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity70),
              ),
            ),
            SizedBox(height: 0.2.h),
            Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:                     AppTypography.buttonStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSheetPickerModal({
    required BuildContext context,
    required String title,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          constraints: BoxConstraints(maxHeight: 65.h),
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: AppColors.opacity40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                title,
                style:                 AppTypography.displayStyle(
                  fontSize: AppTypography.headingSmall,
                ),
              ),
              SizedBox(height: 1.5.h),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    return ListTile(
                      title: Text(opt,
                          style:                           AppTypography.bodyStyle(
                            fontWeight: AppTypography.semiBold),
                          ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelected(opt);
                        Navigator.pop(ctx);
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
  }

  Widget _buildSheetTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    required Color accentColor,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      style:       AppTypography.bodyStyle(
        color: theme.colorScheme.onSurface,
        fontWeight: AppTypography.semiBold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: AppTypography.bodySmall,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
        ),
        prefixIcon: Icon(prefixIcon, size: 19, color: accentColor),
        filled: true,
        fillColor: context.colors.inputFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.4.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: AppColors.opacity10)
                : Colors.black.withValues(alpha: AppColors.opacity8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: AppColors.opacity10)
                : Colors.black.withValues(alpha: AppColors.opacity8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initControllers();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        titleWidget: Text(
          'Services',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorRegistrationScreen(),
                      settings: const RouteSettings(
                          name: AppRoutes.vendorRegistration),
                    ),
                  );
                },
                pressedScale: 0.95,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [AppColors.categoryAstroDark, AppColors.canvasDark],
                          )
                        : const LinearGradient(
                            colors: [AppColors.warningLight, AppColors.goldLight],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.categoryAstro
                          .withValues(alpha: isDark ? 0.4 : 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.categoryAstro
                            .withValues(alpha: isDark ? 0.15 : 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront_rounded,
                          color: AppColors.categoryAstroDark, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '+ Vendor',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.goldDarkContrast
                              : AppColors.goldDark,
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.extraBold,
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎪 1. Grand Animated Horizontal Swipeable Banner Carousel (3 Slides)
            _buildBannerCarousel(theme, isDark),
            SizedBox(height: 1.8.h),

            // 🏷️ 2. Animated Category Filter Switcher
            _buildCategoryFilterRow(theme, isDark),
            SizedBox(height: 1.4.h),

            // 🎛️ 3. Full-Width Multiple Dropdown Filters Row (State, District, Budget, Sort, Verified)
            _buildDropdownFiltersRow(theme, isDark),
            SizedBox(height: 1.8.h),

            // 🛍️ 4. 8-Category Interactive Grid
            _buildSectionTitle(
              '🎪 Verified Wedding Services',
              'Tap any service for an instant 1-click free WhatsApp quote',
            ),
            SizedBox(height: 1.4.h),
            _buildWeddingServicesGrid(theme, isDark),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(ThemeData theme, bool isDark) {
    final pageController = _bannerPageController ??= PageController();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 235,
          child: PageView(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            children: [
              _buildHubSlide(theme, isDark),
              _buildVendorSlide(theme, isDark),
              _buildHelplineSlide(theme, isDark),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        // Active Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isSelected = _currentBannerIndex == index;
            final dotColor = index == 0
                ? AppColors.primary
                : (index == 1
                    ? AppColors.categoryAstro
                    : AppColors.categoryLocation);

            return GestureDetector(
              onTap: () {
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 5,
                width: isSelected ? 24 : 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? dotColor
                      : (isDark
                          ? Colors.white.withValues(alpha: AppColors.opacity20)
                          : Colors.black.withValues(alpha: AppColors.opacity15)),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHubSlide(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? const [AppColors.primaryDark, AppColors.canvasDark]
              : const [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: AppColors.opacity35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.28),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.0.h),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row: Top Badge + Sparkle Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: AppColors.opacity25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation ??
                            const AlwaysStoppedAnimation<double>(1.0),
                        child: const Icon(Icons.verified_rounded,
                            color: AppColors.gold, size: 13),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '100% VERIFIED BANJARA NETWORK',
                        style: AppTypography.bodyStyle(
                          color: Colors.white,
                          fontWeight: AppTypography.black,
                          fontSize: AppTypography.labelTiny,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: AppColors.opacity15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.celebration_rounded,
                      color: AppColors.gold, size: 16),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            // Main Headline & Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Banjara Wedding Services Hub',
                  style: AppTypography.displayStyle(
                    color: Colors.white,
                    fontSize: AppTypography.headingMedium,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Direct quotations & authentic contacts from community vendors for your dream wedding.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    color: Colors.white.withValues(alpha: AppColors.opacity90),
                    height: 1.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
            // 3 Trust Metric Badges
            Row(
              children: [
                _buildTrustPill('🛡️ 500+ Vendors'),
                SizedBox(width: 1.5.w),
                _buildTrustPill('⚡ Instant Quote'),
                SizedBox(width: 1.5.w),
                _buildTrustPill('💰 0% Commission'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorSlide(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? const [AppColors.categoryAstroDark, AppColors.canvasDark]
              : const [AppColors.categoryAstro, AppColors.categoryAstroDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.goldLight.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.categoryAstro.withValues(alpha: isDark ? 0.35 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row: Top Badge + Store Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppColors.opacity20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: AppColors.opacity30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_rounded,
                        color: AppColors.goldLight, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'GROW YOUR BUSINESS • VENDOR NETWORK',
                      style:                       AppTypography.bodyStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.labelTiny,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppColors.opacity20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppColors.goldLight, size: 16),
              ),
            ],
          ),

          // Main Headline & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are You a Wedding Vendor?',
                style:                 AppTypography.displayStyle(
                  color: Colors.white,
                  fontSize: AppTypography.headingMedium,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'List your DJ, Mandap, Catering, Photo or Beauty business to get direct wedding bookings from Banjara families.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.3,
                ),
              ),
            ],
          ),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrustPill('🎯 0% Commission', isExpanded: false),
              TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorRegistrationScreen(),
                      settings: const RouteSettings(
                          name: AppRoutes.vendorRegistration),
                    ),
                  );
                },
                pressedScale: 0.95,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppColors.opacity15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Register Business',
                        style: TextStyle(
                          color: AppColors.categoryAstroDark,
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 13, color: AppColors.categoryAstroDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineSlide(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? const [AppColors.categoryLocationDark, AppColors.canvasDark]
              : const [AppColors.categoryLocationDark, AppColors.categoryLocation],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.categoryLocation.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.categoryLocation.withValues(alpha: isDark ? 0.35 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row: Top Badge + Headset Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppColors.opacity20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: AppColors.opacity30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.support_agent_rounded,
                        color: AppColors.successLight, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '24/7 HELPLINE • DIRECT ASSISTANCE',
                      style:                       AppTypography.bodyStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.labelTiny,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppColors.opacity20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_rounded,
                    color: AppColors.successLight, size: 16),
              ),
            ],
          ),

          // Main Headline & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need Custom Wedding Assistance?',
                style:                 AppTypography.displayStyle(
                  color: Colors.white,
                  fontSize: AppTypography.headingMedium,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Looking for special packages, pandits, hall bookings or tailored budget plans? Chat with our team.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.3,
                ),
              ),
            ],
          ),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrustPill('⚡ Fast Reply on WhatsApp', isExpanded: false),
              TactilePressable(
                onTap: () => _launchUrlExternal('https://wa.me/8186050406'),
                pressedScale: 0.95,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppColors.opacity15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_rounded,
                          size: 13, color: AppColors.categoryLocationDark),
                      const SizedBox(width: 4),
                      Text(
                        'WhatsApp Help',
                        style: TextStyle(
                          color: AppColors.categoryLocationDark,
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustPill(String label, {bool isExpanded = true}) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: AppColors.opacity15),
        ),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:           AppTypography.labelStyle(
            color: Colors.white,
            fontSize: AppTypography.labelTiny,
          ),
        ),
      ),
    );

    if (isExpanded) {
      return Expanded(child: pill);
    }
    return pill;
  }

  Widget _buildCategoryFilterRow(ThemeData theme, bool isDark) {
    return SizedBox(
      height: 4.2.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterCategories.length,
        separatorBuilder: (_, _) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return TactilePressable(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilterIndex = index);
            },
            pressedScale: 0.95,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: 3.5.w),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          AppColors.primaryDark,
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (context.colors.inputFill),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                          ? Colors.white.withValues(alpha: AppColors.opacity8)
                          : Colors.black.withValues(alpha: 0.06)),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _filterCategories[index],
                  style: TextStyle(
                    fontSize: AppTypography.labelMedium,
                    fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── 🎛️ Dynamic Multiple Dropdown Filters Row ───
  Widget _buildDropdownFiltersRow(ThemeData theme, bool isDark) {
    // Dynamic districts list based on state
    final List<String> availableDistricts = ['All Districts'];
    if (_selectedState != null && LocationData.districts.containsKey(_selectedState)) {
      availableDistricts.addAll(LocationData.districts[_selectedState]!);
    } else {
      // Default top Banjara districts across key states
      availableDistricts.addAll([
        'Pune',
        'Nanded',
        'Yavatmal',
        'Hyderabad',
        'Nizamabad',
        'Kalaburagi',
        'Vijayapura',
        'Nashik',
        'Nagpur',
        'Aurangabad',
        'Solapur',
        'Buldhana',
        'Jalna',
        'Beed',
        'Latur',
      ]);
    }

    final statesList = ['All States', ...LocationData.states];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // ✕ Active Filters Count / Reset Pill
          if (_hasActiveFilters) ...[
            TactilePressable(
              onTap: _resetAllFilters,
              pressedScale: 0.95,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: AppColors.opacity12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: AppColors.opacity40),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_off_rounded,
                        color: theme.colorScheme.error, size: 14),
                    SizedBox(width: 1.w),
                    Text(
                      'Reset ($_activeFiltersCount)',
                      style:                       AppTypography.buttonStyle(
                        color: theme.colorScheme.error,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 2.w),
          ],

          // 📍 1. State Filter Dropdown
          _buildFilterDropdownChip(
            theme: theme,
            isDark: isDark,
            icon: Icons.map_rounded,
            label: _selectedState ?? 'State',
            isActive: _selectedState != null,
            activeColor: AppColors.categoryCareer,
            onTap: () {
              _showFilterSelectionSheet(
                context: context,
                title: AppLocalizations.of(context)?.selectState ?? 'Select State',
                icon: Icons.map_rounded,
                accentColor: AppColors.categoryCareer,
                options: statesList,
                currentValue: _selectedState,
                isSearchable: true,
                onSelected: (val) {
                  setState(() {
                    _selectedState = val;
                    // Reset district if it doesn't belong to the newly selected state
                    if (val != null &&
                        LocationData.districts.containsKey(val) &&
                        _selectedDistrict != null &&
                        !LocationData.districts[val]!.contains(_selectedDistrict)) {
                      _selectedDistrict = null;
                    }
                  });
                },
              );
            },
          ),
          SizedBox(width: 2.w),

          // 🏙️ 2. District Filter Dropdown
          _buildFilterDropdownChip(
            theme: theme,
            isDark: isDark,
            icon: Icons.location_city_rounded,
            label: _selectedDistrict ?? 'District',
            isActive: _selectedDistrict != null,
            activeColor: AppColors.categoryLocation,
            onTap: () {
              _showFilterSelectionSheet(
                context: context,
                title: _selectedState != null
                    ? 'Districts in $_selectedState'
                    : (AppLocalizations.of(context)?.district ?? 'Select District'),
                icon: Icons.location_city_rounded,
                accentColor: AppColors.categoryLocation,
                options: availableDistricts,
                currentValue: _selectedDistrict,
                isSearchable: true,
                onSelected: (val) {
                  setState(() => _selectedDistrict = val);
                },
              );
            },
          ),
          SizedBox(width: 2.w),

          // 💰 3. Budget Range Dropdown
          _buildFilterDropdownChip(
            theme: theme,
            isDark: isDark,
            icon: Icons.account_balance_wallet_rounded,
            label: _selectedBudget == 'All Budgets' ? 'Budget' : _selectedBudget,
            isActive: _selectedBudget != 'All Budgets',
            activeColor: AppColors.categoryAstro,
            onTap: () {
              _showFilterSelectionSheet(
                context: context,
                title: AppLocalizations.of(context)?.selectBudgetRange ?? 'Select Budget Range',
                icon: Icons.account_balance_wallet_rounded,
                accentColor: AppColors.categoryAstro,
                options: _budgetOptions,
                currentValue: _selectedBudget,
                onSelected: (val) {
                  setState(() => _selectedBudget = val ?? 'All Budgets');
                },
              );
            },
          ),
          SizedBox(width: 2.w),

          // ↕️ 4. Price & Sorting Dropdown
          _buildFilterDropdownChip(
            theme: theme,
            isDark: isDark,
            icon: Icons.swap_vert_rounded,
            label: _selectedSort == 'Recommended' ? 'Sort' : _selectedSort,
            isActive: _selectedSort != 'Recommended',
            activeColor: AppColors.categoryFamily,
            onTap: () {
              _showFilterSelectionSheet(
                context: context,
                title: AppLocalizations.of(context)?.sortServicesBy ?? 'Sort Services By',
                icon: Icons.swap_vert_rounded,
                accentColor: AppColors.categoryFamily,
                options: _sortOptions,
                currentValue: _selectedSort,
                onSelected: (val) {
                  setState(() => _selectedSort = val ?? 'Recommended');
                },
              );
            },
          ),
          SizedBox(width: 2.w),

          // 🛡️ 5. Verified Vendors Only Toggle Chip
          TactilePressable(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _verifiedOnly = !_verifiedOnly);
            },
            pressedScale: 0.95,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: _verifiedOnly
                    ? AppColors.categoryLocationDark.withValues(alpha: isDark ? 0.25 : 0.15)
                    : (context.colors.inputFill),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _verifiedOnly
                      ? AppColors.categoryLocationDark
                      : (isDark
                          ? Colors.white.withValues(alpha: AppColors.opacity8)
                          : Colors.black.withValues(alpha: 0.06)),
                  width: _verifiedOnly ? 1.3 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _verifiedOnly
                        ? Icons.verified_rounded
                        : Icons.verified_outlined,
                    size: 14,
                    color: _verifiedOnly
                        ? AppColors.categoryLocationDark
                        : (isDark
                            ? Colors.white60
                            : theme.colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Verified Only',
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      fontWeight:
                          _verifiedOnly ? AppTypography.extraBold : AppTypography.semiBold,
                      color: _verifiedOnly
                        ? AppColors.categoryLocationDark
                        : (isDark
                            ? Colors.white70
                            : theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdownChip({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return TactilePressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : (context.colors.inputFill),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? activeColor
                : (isDark
                    ? Colors.white.withValues(alpha: AppColors.opacity8)
                    : Colors.black.withValues(alpha: 0.06)),
            width: isActive ? 1.3 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: AppColors.opacity20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.5,
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.white60 : theme.colorScheme.onSurfaceVariant),
            ),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                fontWeight: isActive ? AppTypography.extraBold : AppTypography.semiBold,
                color: isActive
                    ? activeColor
                    : (isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant),
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.white54 : theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllServices() {
    return [
      {
        'title': 'DJ & Sound System',
        'sub': 'Dhol, Stage Audio & 4K Lighting',
        'icon': Icons.music_note_rounded,
        'color': AppColors.categoryPersonal, // Rose
        'category': 1, // Entertainment
        'tag': '🔥 POPULAR',
        'price': 18000,
        'priceFormatted': 'From ₹18,000',
        'rating': 4.9,
        'reviewCount': 142,
        'isVerified': true,
        'districts': [
          'Pune',
          'Nanded',
          'Yavatmal',
          'Hyderabad',
          'Nizamabad',
          'Kalaburagi'
        ],
      },
      {
        'title': 'Mandap & Theme Decor',
        'sub': 'Royal Stage & Traditional Mandap',
        'icon': Icons.celebration_rounded,
        'color': AppColors.categoryAstro, // Amber
        'category': 2, // Venues & Decor
        'tag': '✨ BEST VALUE',
        'price': 45000,
        'priceFormatted': 'From ₹45,000',
        'rating': 4.8,
        'reviewCount': 98,
        'isVerified': true,
        'districts': [
          'Pune',
          'Mumbai City',
          'Nanded',
          'Aurangabad',
          'Hyderabad'
        ],
      },
      {
        'title': 'Floral Art & Toran',
        'sub': 'Fresh Garlands, Jaymala & Entry',
        'icon': Icons.local_florist_rounded,
        'color': AppColors.categoryLocation, // Emerald
        'category': 2, // Venues & Decor
        'tag': '🌸 FRESH',
        'price': 12000,
        'priceFormatted': 'From ₹12,000',
        'rating': 4.9,
        'reviewCount': 76,
        'isVerified': true,
        'districts': [
          'Pune',
          'Nanded',
          'Yavatmal',
          'Nashik',
          'Solapur',
          'Hyderabad'
        ],
      },
      {
        'title': 'Banjara & Multi Catering',
        'sub': 'Authentic Dishes & Sweet Counter',
        'icon': Icons.restaurant_rounded,
        'color': AppColors.warning, // Orange
        'category': 3, // Food & Rituals
        'tag': '🍛 TOP CHEFS',
        'price': 150000,
        'priceFormatted': 'From ₹1,50,000',
        'rating': 4.9,
        'reviewCount': 210,
        'isVerified': true,
        'districts': [
          'Pune',
          'Nanded',
          'Yavatmal',
          'Nagpur',
          'Hyderabad',
          'Kalaburagi'
        ],
      },
      {
        'title': '4K Cinema & Photography',
        'sub': 'Drone, Pre-Wedding & Reels',
        'icon': Icons.camera_alt_rounded,
        'color': AppColors.categoryVerificationDark, // Teal
        'category': 4, // Photo & Cinema
        'tag': '🎬 4K HD',
        'price': 35000,
        'priceFormatted': 'From ₹35,000',
        'rating': 4.9,
        'reviewCount': 184,
        'isVerified': true,
        'districts': [
          'Pune',
          'Mumbai City',
          'Nanded',
          'Hyderabad',
          'Aurangabad'
        ],
      },
      {
        'title': 'Bridal Makeup & Mehndi',
        'sub': 'HD Makeup, Hair Styling & Henna',
        'icon': Icons.face_retouching_natural_rounded,
        'color': AppColors.categoryFamilyDark, // Purple
        'category': 1, // Entertainment / Beauty
        'tag': '💄 ARTISTS',
        'price': 15000,
        'priceFormatted': 'From ₹15,000',
        'rating': 4.8,
        'reviewCount': 115,
        'isVerified': true,
        'districts': [
          'Pune',
          'Nanded',
          'Yavatmal',
          'Hyderabad',
          'Nizamabad',
          'Kalaburagi'
        ],
      },
      {
        'title': 'Guruji / Muhurat Rituals',
        'sub': 'Vedic Puja, Kanyadan & Muhurat',
        'icon': Icons.auto_awesome_rounded,
        'color': AppColors.categoryVipDark, // Gold
        'category': 3, // Food & Rituals
        'tag': '🪔 VEDIC',
        'price': 8000,
        'priceFormatted': 'From ₹8,000',
        'rating': 5.0,
        'reviewCount': 320,
        'isVerified': true,
        'districts': [
          'Pune',
          'Nanded',
          'Yavatmal',
          'Hyderabad',
          'Nashik',
          'Solapur',
          'Kalaburagi'
        ],
      },
      {
        'title': 'Banquet Halls & Lawns',
        'sub': 'AC Halls, Resorts & Open Lawns',
        'icon': Icons.apartment_rounded,
        'color': AppColors.categoryCareerDark, // Blue
        'category': 2, // Venues & Decor
        'tag': '🏰 PREMIUM',
        'price': 85000,
        'priceFormatted': 'From ₹85,000',
        'rating': 4.7,
        'reviewCount': 64,
        'isVerified': true,
        'districts': [
          'Pune',
          'Nanded',
          'Yavatmal',
          'Hyderabad',
          'Aurangabad',
          'Nagpur'
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredAndSortedServices() {
    List<Map<String, dynamic>> list = _getAllServices();

    // 1. Category Filter
    if (_selectedFilterIndex != 0) {
      list = list.where((s) => s['category'] == _selectedFilterIndex).toList();
    }

    // 2. District Filter
    if (_selectedDistrict != null) {
      list = list.where((s) {
        final districts = s['districts'] as List<String>?;
        return districts == null || districts.contains(_selectedDistrict);
      }).toList();
    }

    // 3. Budget Filter
    if (_selectedBudget != 'All Budgets') {
      list = list.where((s) {
        final price = (s['price'] as num?)?.toInt() ?? 0;
        switch (_selectedBudget) {
          case 'Under ₹25,000':
            return price <= 25000;
          case '₹25,000 - ₹50,000':
            return price > 25000 && price <= 50000;
          case '₹50,000 - ₹1,00,000':
            return price > 50000 && price <= 100000;
          case '₹1,00,000+':
            return price > 100000;
          default:
            return true;
        }
      }).toList();
    }

    // 4. Verified Only
    if (_verifiedOnly) {
      list = list.where((s) => s['isVerified'] == true).toList();
    }

    // 5. Sorting
    switch (_selectedSort) {
      case 'Price: Low to High':
        list.sort((a, b) =>
            ((a['price'] as num?) ?? 0).compareTo((b['price'] as num?) ?? 0));
        break;
      case 'Price: High to Low':
        list.sort((a, b) =>
            ((b['price'] as num?) ?? 0).compareTo((a['price'] as num?) ?? 0));
        break;
      case 'Top Rated ★':
        list.sort((a, b) =>
            ((b['rating'] as num?) ?? 0).compareTo((a['rating'] as num?) ?? 0));
        break;
      case 'Most Popular 🔥':
        list.sort((a, b) => ((b['reviewCount'] as num?) ?? 0)
            .compareTo((a['reviewCount'] as num?) ?? 0));
        break;
      default:
        break;
    }

    return list;
  }

  Widget _buildWeddingServicesGrid(ThemeData theme, bool isDark) {
    final filteredServices = _getFilteredAndSortedServices();

    if (filteredServices.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: AppColors.opacity8)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  color: theme.colorScheme.primary, size: 32),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'No services match your active filters',
              style:               AppTypography.labelStyle(
                color: theme.colorScheme.onSurface,
                fontSize: AppTypography.bodyMedium,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Try adjusting your budget or district filter to discover vendors.',
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: _resetAllFilters,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: Text(AppLocalizations.of(context)?.resetAllFilters ?? 'Reset All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final item = filteredServices[index];
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;
        final title = item['title'] as String;
        final sub = item['sub'] as String;
        final tag = item['tag'] as String;
        final priceFormatted = item['priceFormatted'] as String;
        final rating = (item['rating'] as num?)?.toDouble() ?? 4.9;

        return TactilePressable(
          onTap: () => _openVendorInquirySheet(context, item),
          pressedScale: 0.96,
          child: Container(
            padding: EdgeInsets.all(3.2.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.35 : 0.22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon Container + Mini Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withValues(alpha: 0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: AppColors.opacity35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        tag,
                        style:                         AppTypography.buttonStyle(
                          color: color,
                          fontSize: AppTypography.labelTiny,
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Title, Subtitle & Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:                       AppTypography.buttonStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                    SizedBox(height: 0.1.h),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.labelTiny,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: AppColors.opacity80),
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            priceFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:                             AppTypography.bodyStyle(
                              color: color,
                              fontWeight: AppTypography.black,
                              fontSize: AppTypography.labelTiny,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.gold, size: 11),
                            const SizedBox(width: 1),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.bold,
                                color: isDark
                                    ? Colors.white70
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Bottom Row: Get Quote Action
                Row(
                  children: [
                    Text(
                      'Get Quote',
                      style:                       AppTypography.buttonStyle(
                        color: color,
                        fontSize: AppTypography.labelTiny,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, color: color, size: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:           AppTypography.displayStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: AppTypography.headingSmall,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: AppColors.opacity80),
          ),
        ),
      ],
    );
  }
}
