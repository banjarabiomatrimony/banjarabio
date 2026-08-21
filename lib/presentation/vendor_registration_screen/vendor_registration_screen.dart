import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/models/vendor_model.dart';
import 'package:banjarabio/core/repositories/vendor_repository.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🏢 Dedicated Vendor Self-Registration Screen (Network Effect)
/// Enables wedding service providers to register themselves directly on the platform
/// with dynamic, business-specific custom fields tailored to their exact trade.
class VendorRegistrationScreen extends ConsumerStatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  ConsumerState<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState
    extends ConsumerState<VendorRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ─── Step 1: Category Selection ───
  String _selectedCategoryKey = 'dj_sound';
  String _selectedCategoryTitle = 'DJ & Sound System';

  // ─── Step 2: General Business Details ───
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  bool _sameAsMobile = true;

  String? _selectedState = 'Maharashtra';
  String? _selectedDistrict = 'Pune';
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  // ─── Step 3: Dynamic Category-Specific Spec States ───
  // DJ & Sound
  String _djWattage = '10,000W';
  final Set<String> _djEquipment = {
    'RCF Tops',
    'Bass Cabinets',
    'Sharpie Lights',
  };
  bool _djBanjaraPlaylist = true;
  bool _djGeneratorBackup = true;

  // Mandap & Decor
  final Set<String> _mandapStyles = {
    'Traditional Wooden',
    'Royal Palace Theme',
  };
  String _mandapFlowerType = 'Both (Fresh & Artificial)';
  bool _mandapEntryArch = true;
  String _mandapStageSize = 'Grand (30-40 ft)';

  // Catering
  final Set<String> _cateringCuisines = {
    'Authentic Banjara (Daal Baati, Gulgule)',
    'Maharashtrian Traditional',
    'North Indian',
  };
  String _cateringServiceStyle = 'Both (Buffet & Table Pangat)';
  String _cateringMaxGuests = '1,000 - 2,500 Guests';
  final _perPlatePriceController = TextEditingController(text: '350');
  final String _cateringFoodType = 'Pure Veg & Non-Veg';

  // Photography & Cinema
  final Set<String> _photoDeliverables = {
    'Pre-Wedding Shoot',
    'Cinematic Teaser',
    '4K Full Video',
    'Premium Album',
    'Reels & Shorts',
  };
  bool _photoDrone = true;
  String _photoGear = 'Sony Alpha 4K Cinema';
  String _photoTeamSize = '4-Member Full Crew';

  // Makeup & Mehndi
  final Set<String> _makeupStyles = {
    'HD Bridal Makeup',
    'Traditional Banjara Gor Bride',
    'Airbrush',
  };
  final Set<String> _mehndiStyles = {'Full Bridal Hands', 'Banjara Motifs'};
  bool _makeupHomeVisit = true;
  bool _makeupTrialAvailable = true;

  // Guruji / Rituals
  final Set<String> _gurujiRituals = {
    'Lagna Muhurat & Kundali',
    'Sant Sevalal Maharaj Pooja',
    'Kanyadan Vidhi',
    'Mangalashtak',
  };
  final Set<String> _gurujiLanguages = {
    'Gorboli (Banjara)',
    'Marathi',
    'Hindi',
  };
  bool _gurujiSamagriProvided = true;

  // Banquet Halls & Lawns
  String _venueType = 'AC Banquet Hall + Lawn';
  String _venueCapacity = '500 - 1,000 Guests';
  String _venueRooms = '5 AC Rooms';
  bool _venueOutsideCateringAllowed = true;
  bool _venueDedicatedParking = true;

  // ─── Step 4: Pricing, Experience & Links ───
  int _experienceYears = 5;
  final _startingPriceController = TextEditingController(text: '15000');
  final _avgPriceController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _aboutController = TextEditingController();

  // ─── Step 5: Terms ───
  bool _agreedToTerms = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'key': 'dj_sound',
      'title': 'DJ & Sound',
      'sub': 'Audio, Dhol & Lighting',
      'icon': Icons.music_note_rounded,
      'color': AppColors.crimsonBlush,
    },
    {
      'key': 'mandap_decor',
      'title': 'Mandap & Decor',
      'sub': 'Royal Stage & Themes',
      'icon': Icons.celebration_rounded,
      'color': AppColors.categoryAstroDark,
    },
    {
      'key': 'catering',
      'title': 'Catering & Food',
      'sub': 'Banjara & Multi-Cuisine',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.sunsetOrange,
    },
    {
      'key': 'photography',
      'title': 'Photography',
      'sub': '4K Cinema & Drone',
      'icon': Icons.camera_alt_rounded,
      'color': AppColors.teal,
    },
    {
      'key': 'makeup_mehndi',
      'title': 'Bridal Makeup',
      'sub': 'Beauty & Mehndi Art',
      'icon': Icons.face_retouching_natural_rounded,
      'color': AppColors.electricPurple,
    },
    {
      'key': 'guruji',
      'title': 'Guruji / Rituals',
      'sub': 'Vedic & Sevalal Puja',
      'icon': Icons.auto_awesome_rounded,
      'color': AppColors.darkGoldenrod,
    },
    {
      'key': 'banquet_hall',
      'title': 'Banquet & Lawns',
      'sub': 'Venues & AC Halls',
      'icon': Icons.apartment_rounded,
      'color': AppColors.categoryCareerDark,
    },
    {
      'key': 'other',
      'title': 'Other Services',
      'sub': 'Ghodi, Dhol, Transport',
      'icon': Icons.more_horiz_rounded,
      'color': AppColors.categoryLocationDark,
    },
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('vendor_registration_screen');
    _autoFillFromUserProfile();
  }

  void _autoFillFromUserProfile() {
    final user = SessionManager.instance.currentProfile;
    if (user != null) {
      if (user.fullName.isNotEmpty) {
        _ownerNameController.text = user.fullName;
      }
      final phone = user.phoneNumber;
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
        _whatsappController.text = phone;
      }
      if (user.district != null && user.district!.isNotEmpty) {
        _selectedDistrict = user.district;
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _perPlatePriceController.dispose();
    _startingPriceController.dispose();
    _avgPriceController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildSpecificAttributes() {
    switch (_selectedCategoryKey) {
      case 'dj_sound':
        return {
          'wattage': _djWattage,
          'equipment': _djEquipment.toList(),
          'banjara_playlist': _djBanjaraPlaylist,
          'generator_backup': _djGeneratorBackup,
        };
      case 'mandap_decor':
        return {
          'styles': _mandapStyles.toList(),
          'flower_type': _mandapFlowerType,
          'entry_arch': _mandapEntryArch,
          'stage_size': _mandapStageSize,
        };
      case 'catering':
        return {
          'cuisines': _cateringCuisines.toList(),
          'service_style': _cateringServiceStyle,
          'max_guests': _cateringMaxGuests,
          'food_type': _cateringFoodType,
          'per_plate_price':
              int.tryParse(_perPlatePriceController.text.trim()) ?? 350,
        };
      case 'photography':
        return {
          'deliverables': _photoDeliverables.toList(),
          'drone_included': _photoDrone,
          'gear': _photoGear,
          'team_size': _photoTeamSize,
        };
      case 'makeup_mehndi':
        return {
          'makeup_styles': _makeupStyles.toList(),
          'mehndi_styles': _mehndiStyles.toList(),
          'home_visit': _makeupHomeVisit,
          'trial_available': _makeupTrialAvailable,
        };
      case 'guruji':
        return {
          'rituals': _gurujiRituals.toList(),
          'languages': _gurujiLanguages.toList(),
          'samagri_provided': _gurujiSamagriProvided,
        };
      case 'banquet_hall':
        return {
          'venue_type': _venueType,
          'capacity': _venueCapacity,
          'rooms': _venueRooms,
          'outside_catering_allowed': _venueOutsideCateringAllowed,
          'dedicated_parking': _venueDedicatedParking,
        };
      default:
        return {};
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
        msg:
            AppLocalizations.of(context)?.pleaseFillAllRequiredFields ??
            'Please fill all required fields',
      );
      return;
    }

    if (!_agreedToTerms) {
      Fluttertoast.showToast(
        msg:
            AppLocalizations.of(context)?.pleaseAcceptVendorPartnerTerms ??
            'Please accept the vendor partner terms',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final startingPrice =
        int.tryParse(_startingPriceController.text.trim()) ?? 10000;
    final avgPrice = int.tryParse(_avgPriceController.text.trim());

    final specificAttrs = _buildSpecificAttributes();

    final response = await VendorRepository.instance.registerVendor(
      businessName: _businessNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      whatsapp: _sameAsMobile
          ? _phoneController.text.trim()
          : _whatsappController.text.trim(),
      category: _selectedCategoryKey,
      categoryLabel: _selectedCategoryTitle,
      state: _selectedState ?? 'Maharashtra',
      district: _selectedDistrict ?? 'Pune',
      city: _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : (_selectedDistrict ?? 'City'),
      address: _addressController.text.trim(),
      experienceYears: _experienceYears,
      startingPrice: startingPrice,
      averagePrice: avgPrice,
      aboutBusiness: _aboutController.text.trim(),
      instagramUrl: _instagramController.text.trim(),
      youtubeUrl: _youtubeController.text.trim(),
      specificAttributes: specificAttrs,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response.isSuccess) {
      _showSuccessDialog(response.data);
    } else {
      Fluttertoast.showToast(msg: response.errorMessage);
    }
  }

  void _showSuccessDialog(VendorModel vendor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? AppColors.surfaceDark28 : Colors.white,
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.categoryLocation, AppColors.categoryLocationDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context)?.registrationSubmitted ??
                      'Registration Submitted!',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontWeight: AppTypography.black,
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTypography.headingMedium,
                  ),
                ),
                Text(
                  AppLocalizations.of(
                        context,
                      )?.vendorRegistrationSubmittedCongrats(
                        vendor.businessName,
                      ) ??
                      'Congratulations! ${vendor.businessName} has been submitted for verified vendor listing on the BanjaraBio Network.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity30),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.categoryLocationDark,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                                context,
                              )?.vendorVerificationDeskNote ??
                              'Our vendor verification desk will verify and activate your listing within 2-4 hours.',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            color: AppColors.greenDeepForest,
                            fontWeight: AppTypography.semiBold,
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TactilePressable(
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  pressedScale: 0.96,
                  child: Container(
                    width: double.infinity,
                    height: 5.2.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.done ?? 'Done',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontWeight: AppTypography.extraBold,
                          color: Colors.white,
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title:
            AppLocalizations.of(context)?.vendorRegistration ??
            'Vendor Registration',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌟 1. Hero Onboarding Callout Banner
              _buildHeroBanner(theme, isDark),
              SizedBox(height: 2.2.h),

              // 🎪 2. Step A: Select Service Category
              _buildSectionHeader(
                AppLocalizations.of(context)?.step1SelectCategory ??
                    '1. Select Your Service Category',
                AppLocalizations.of(context)?.step1SelectCategorySubtitle ??
                    'Choose the primary wedding service you provide',
              ),
              SizedBox(height: 1.2.h),
              _buildCategorySelectorGrid(theme, isDark),
              SizedBox(height: 2.5.h),

              // 👤 3. Step B: Business Identity & Contact Details
              _buildSectionHeader(
                AppLocalizations.of(context)?.step2BusinessContact ??
                    '2. Business & Contact Information',
                AppLocalizations.of(context)?.step2BusinessContactSubtitle ??
                    'Enter authentic details for community clients',
              ),
              SizedBox(height: 1.4.h),
              _buildBusinessContactCard(theme, isDark),
              SizedBox(height: 2.5.h),

              // ⚙️ 4. Step C: Dynamic Business-Specific Specifications
              _buildSectionHeader(
                AppLocalizations.of(context)?.step3ServiceSpecs ??
                    '3. Dynamic Service Specifications',
                AppLocalizations.of(
                      context,
                    )?.step3ServiceSpecsSubtitle(_selectedCategoryTitle) ??
                    'Specific details tailored for $_selectedCategoryTitle',
              ),
              SizedBox(height: 1.4.h),
              _buildDynamicCategorySpecsCard(theme, isDark),
              SizedBox(height: 2.5.h),

              // 💰 5. Step D: Pricing, Experience & Social Proof
              _buildSectionHeader(
                AppLocalizations.of(context)?.step4PricingExperience ??
                    '4. Pricing & Experience',
                AppLocalizations.of(context)?.step4PricingExperienceSubtitle ??
                    'Help families understand your package range',
              ),
              SizedBox(height: 1.4.h),
              _buildPricingAndSocialCard(theme, isDark),
              SizedBox(height: 2.5.h),

              // 📜 6. Step E: Agreement & Submit Action
              _buildAgreementAndSubmit(theme, isDark),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  AppColors.amberBrownBg,
                  AppColors.amberBgDark,
                  AppColors.amberBrownBg,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  AppColors.amberDarkestText,
                  AppColors.deepOrange,
                  AppColors.sunsetOrange,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.categoryVip.withValues(alpha: AppColors.opacity35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFEA580C,
            ).withValues(alpha: isDark ? 0.3 : 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppColors.opacity20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: AppColors.opacity25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      color: AppColors.categoryVip,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'BANJARABIO NETWORK EFFECT',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        color: Colors.white,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.labelTiny,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.storefront_rounded,
                color: AppColors.categoryVip,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Text(
            AppLocalizations.of(context)?.growYourWeddingBusiness ??
                'Grow Your Wedding Business',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontWeight: AppTypography.black,
              color: Colors.white,
              fontSize: AppTypography.headingMedium,
            ),
          ),
          Text(
            AppLocalizations.of(context)?.vendorNetworkEffectDesc ??
                'Self-register your services to receive direct 1-click WhatsApp inquiries from thousands of Banjara families.',
            style: TextStyle(
              fontSize: AppTypography.labelSmall,
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.35,
            ),
          ),
          Row(
            children: [
              _buildBannerMicroPill(
                AppLocalizations.of(context)?.zeroPercentCommission ??
                    '💰 0% Commission',
              ),
              _buildBannerMicroPill(
                AppLocalizations.of(context)?.directWhatsAppLeads ??
                    '📱 Direct WhatsApp Leads',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMicroPill(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: AppColors.opacity25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: AppColors.opacity15)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontWeight: AppTypography.bold,
              color: Colors.white,
              fontSize: AppTypography.labelTiny,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontWeight: AppTypography.black,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: AppTypography.headingSmall,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelectorGrid(ThemeData theme, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final item = _categories[index];
        final key = item['key'] as String;
        final title = item['title'] as String;
        final icon = item['icon'] as IconData;
        final color = item['color'] as Color;
        final isSelected = _selectedCategoryKey == key;

        return TactilePressable(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedCategoryKey = key;
              _selectedCategoryTitle = title;
            });
          },
          pressedScale: 0.96,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.25 : 0.12)
                  : (isDark ? AppColors.canvasNearBlack : theme.cardColor),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark
                          ? Colors.white.withValues(alpha: AppColors.opacity8)
                          : Colors.black.withValues(alpha: 0.06)),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: AppColors.opacity25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: AppColors.opacity15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : color,
                    size: 18,
                  ),
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: isSelected
                              ? AppTypography.black
                              : AppTypography.bold,
                          color: isSelected
                              ? color
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        item['sub'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.labelTiny,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: color, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBusinessContactCard(ThemeData theme, bool isDark) {
    final statesList = LocationData.states;
    final List<String> districtsList =
        _selectedState != null &&
            LocationData.districts.containsKey(_selectedState)
        ? LocationData.districts[_selectedState]!
        : ['Pune', 'Nanded', 'Yavatmal', 'Hyderabad', 'Kalaburagi'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasNearBlack : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: AppColors.opacity8)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Name
          _buildFormTextField(
            label: 'Business / Brand Name * (e.g. Jai Sevalal Sound)',
            controller: _businessNameController,
            prefixIcon: Icons.store_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter business name' : null,
          ),
          SizedBox(height: 1.5.h),

          // Owner Name
          _buildFormTextField(
            label: 'Owner / Contact Person Name *',
            controller: _ownerNameController,
            prefixIcon: Icons.person_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter owner name' : null,
          ),
          SizedBox(height: 1.5.h),

          // Mobile Number
          _buildFormTextField(
            label: 'Primary Calling Mobile Number *',
            controller: _phoneController,
            prefixIcon: Icons.phone_rounded,
            isPhone: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter mobile number';
              if (v.trim().length < 10) return 'Enter valid 10-digit number';
              return null;
            },
          ),
          SizedBox(height: 0.8.h),

          // WhatsApp Checkbox
          Row(
            children: [
              Checkbox(
                value: _sameAsMobile,
                activeColor: AppColors.whatsapp,
                onChanged: (val) => setState(() => _sameAsMobile = val ?? true),
              ),
              Expanded(
                child: Text(
                  'WhatsApp number is same as calling mobile',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontWeight: AppTypography.semiBold,
                    fontSize: AppTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ),

          if (!_sameAsMobile) ...[
            SizedBox(height: 0.5.h),
            _buildFormTextField(
              label: 'WhatsApp Business Number *',
              controller: _whatsappController,
              prefixIcon: Icons.chat_bubble_rounded,
              isPhone: true,
            ),
          ],

          SizedBox(height: 1.5.h),

          // State & District Dropdowns Row
          Row(
            children: [
              // State Dropdown
              Expanded(
                child: _buildLocationSelector(
                  label: 'State',
                  value: _selectedState ?? 'Select State',
                  icon: Icons.map_rounded,
                  onTap: () {
                    _showPickerModal(
                      title: 'Select State',
                      options: statesList,
                      onSelected: (val) {
                        setState(() {
                          _selectedState = val;
                          _selectedDistrict =
                              LocationData.districts[val]?.first ?? 'District';
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 3.w),
              // District Dropdown
              Expanded(
                child: _buildLocationSelector(
                  label: 'District',
                  value: _selectedDistrict ?? 'Select District',
                  icon: Icons.location_city_rounded,
                  onTap: () {
                    _showPickerModal(
                      title: 'Select District in $_selectedState',
                      options: districtsList,
                      onSelected: (val) {
                        setState(() => _selectedDistrict = val);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),

          // City / Taluka & Address
          _buildFormTextField(
            label: 'City / Taluka / Village (गाव किंवा शहर)',
            controller: _cityController,
            prefixIcon: Icons.pin_drop_rounded,
          ),
          SizedBox(height: 1.5.h),

          _buildFormTextField(
            label: 'Full Office / Shop Address',
            controller: _addressController,
            prefixIcon: Icons.home_work_rounded,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector({
    required String label,
    required String value,
    required IconData icon,
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
              ? Colors.white.withValues(alpha: AppColors.opacity5)
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
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            Row(
              children: [
                Icon(icon, size: 15, color: theme.colorScheme.primary),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontWeight: AppTypography.extraBold,
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerModal({
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
            color: isDark ? AppColors.canvasNearBlack : theme.colorScheme.surface,
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
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.headingSmall,
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = options[index];
                    return ListTile(
                      title: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelected(item);
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

  Widget _buildDynamicCategorySpecsCard(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasNearBlack : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: AppColors.opacity8)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render specific custom fields based on category
          if (_selectedCategoryKey == 'dj_sound') _buildDjSoundFields(),
          if (_selectedCategoryKey == 'mandap_decor') _buildMandapFields(),
          if (_selectedCategoryKey == 'catering') _buildCateringFields(),
          if (_selectedCategoryKey == 'photography') _buildPhotographyFields(),
          if (_selectedCategoryKey == 'makeup_mehndi') _buildMakeupFields(),
          if (_selectedCategoryKey == 'guruji') _buildGurujiFields(),
          if (_selectedCategoryKey == 'banquet_hall') _buildBanquetFields(),
          if (_selectedCategoryKey == 'other') _buildOtherServiceFields(),
        ],
      ),
    );
  }

  // 🎵 1. DJ & Sound Specific Fields
  Widget _buildDjSoundFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Sound Wattage / Output Setup'),
        _buildPillChoiceRow(
          options: ['5,000W', '10,000W', '20,000W', '50,000W Line Array'],
          selected: _djWattage,
          onSelected: (val) => setState(() => _djWattage = val),
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Equipment & Special FX Available'),
        _buildMultiSelectChips(
          options: [
            'RCF Tops',
            'Bass Cabinets',
            'Sharpie Lights',
            'Smoke Machine',
            'Truss Lighting',
            'Live Dhol Tasha',
          ],
          selectedSet: _djEquipment,
        ),
        SizedBox(height: 1.5.h),
        _buildSwitchTile(
          title: 'Banjara Gorboli Songs Playlist Included',
          subtitle: 'Special Banjara wedding songs & folk beats library',
          value: _djBanjaraPlaylist,
          onChanged: (val) => setState(() => _djBanjaraPlaylist = val),
        ),
        _buildSwitchTile(
          title: 'Power Generator / Backup Included',
          subtitle: 'Own generator for uninterrupted wedding audio',
          value: _djGeneratorBackup,
          onChanged: (val) => setState(() => _djGeneratorBackup = val),
        ),
      ],
    );
  }

  // 🎪 2. Mandap & Decor Specific Fields
  Widget _buildMandapFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Mandap & Stage Styles Available'),
        _buildMultiSelectChips(
          options: [
            'Traditional Wooden',
            'Glass Mandap',
            'Royal Palace Theme',
            'Floral Canopy',
            'Fiber Mandap',
          ],
          selectedSet: _mandapStyles,
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Flower Decoration Type'),
        _buildPillChoiceRow(
          options: [
            'Fresh Flowers Only',
            'Artificial Only',
            'Both (Fresh & Artificial)',
          ],
          selected: _mandapFlowerType,
          onSelected: (val) => setState(() => _mandapFlowerType = val),
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Stage Backdrop Size'),
        _buildPillChoiceRow(
          options: ['Standard (20 ft)', 'Grand (30-40 ft)', 'Custom Size'],
          selected: _mandapStageSize,
          onSelected: (val) => setState(() => _mandapStageSize = val),
        ),
        SizedBox(height: 1.5.h),
        _buildSwitchTile(
          title: 'Welcome Arch & Entry Tunnel Included',
          subtitle: 'Complete red carpet and illuminated entrance gate',
          value: _mandapEntryArch,
          onChanged: (val) => setState(() => _mandapEntryArch = val),
        ),
      ],
    );
  }

  // 🍛 3. Catering Specific Fields
  Widget _buildCateringFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Cuisine Specialities'),
        _buildMultiSelectChips(
          options: [
            'Authentic Banjara (Daal Baati, Gulgule)',
            'Maharashtrian Traditional',
            'North Indian',
            'South Indian',
            'Live Chaat & Starter Counters',
            'Dessert & Ice Cream Bar',
          ],
          selectedSet: _cateringCuisines,
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Serving Style'),
        _buildPillChoiceRow(
          options: [
            'Buffet Style',
            'Table Pangat',
            'Both (Buffet & Table Pangat)',
          ],
          selected: _cateringServiceStyle,
          onSelected: (val) => setState(() => _cateringServiceStyle = val),
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Maximum Guest Capacity'),
        _buildPillChoiceRow(
          options: [
            'Up to 500 Guests',
            '500 - 1,000 Guests',
            '1,000 - 2,500 Guests',
            '5,000+ Guests',
          ],
          selected: _cateringMaxGuests,
          onSelected: (val) => setState(() => _cateringMaxGuests = val),
        ),
        SizedBox(height: 1.8.h),
        _buildFormTextField(
          label: 'Starting Per-Plate Price (₹ per person)',
          controller: _perPlatePriceController,
          prefixIcon: Icons.currency_rupee_rounded,
          isPhone: true,
        ),
      ],
    );
  }

  // 📸 4. Photography & Cinema Specific Fields
  Widget _buildPhotographyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Deliverables & Packages Offered'),
        _buildMultiSelectChips(
          options: [
            'Pre-Wedding Shoot',
            'Cinematic Teaser',
            '4K Full Video',
            'Premium Album',
            'Reels & Shorts',
            'Traditional Photos',
          ],
          selectedSet: _photoDeliverables,
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Camera & Video Gear Setup'),
        _buildPillChoiceRow(
          options: [
            'Sony Alpha 4K Cinema',
            'Canon EOS Cinema',
            'RED / Blackmagic',
          ],
          selected: _photoGear,
          onSelected: (val) => setState(() => _photoGear = val),
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Wedding Day Crew Size'),
        _buildPillChoiceRow(
          options: ['2 Photographers', '4-Member Full Crew', '6+ Team Members'],
          selected: _photoTeamSize,
          onSelected: (val) => setState(() => _photoTeamSize = val),
        ),
        SizedBox(height: 1.5.h),
        _buildSwitchTile(
          title: '4K Drone Aerial Shoot Included',
          subtitle: 'FAA/DGCA compliant aerial cinematic coverage',
          value: _photoDrone,
          onChanged: (val) => setState(() => _photoDrone = val),
        ),
      ],
    );
  }

  // 💄 5. Bridal Makeup & Mehndi Fields
  Widget _buildMakeupFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Bridal Makeup Specializations'),
        _buildMultiSelectChips(
          options: [
            'HD Bridal Makeup',
            'Traditional Banjara Gor Bride',
            'Airbrush',
            'Engagement / Reception Makeup',
            'Hair Styling & Saree Draping',
          ],
          selectedSet: _makeupStyles,
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Mehndi Art Styles'),
        _buildMultiSelectChips(
          options: [
            'Full Bridal Hands',
            'Banjara Motifs',
            'Arabic Mehndi',
            'Portrait Mehndi',
          ],
          selectedSet: _mehndiStyles,
        ),
        SizedBox(height: 1.5.h),
        _buildSwitchTile(
          title: 'Home & Wedding Venue Visit Available',
          subtitle: 'Artist travels directly to bride location',
          value: _makeupHomeVisit,
          onChanged: (val) => setState(() => _makeupHomeVisit = val),
        ),
        _buildSwitchTile(
          title: 'Pre-Wedding Trial Session Available',
          subtitle: 'Look testing before the final wedding day',
          value: _makeupTrialAvailable,
          onChanged: (val) => setState(() => _makeupTrialAvailable = val),
        ),
      ],
    );
  }

  // 🪔 6. Guruji / Rituals Specific Fields
  Widget _buildGurujiFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Rituals & Poojas Conducted'),
        _buildMultiSelectChips(
          options: [
            'Lagna Muhurat & Kundali',
            'Sant Sevalal Maharaj Pooja',
            'Kanyadan Vidhi',
            'Mangalashtak',
            'Grah Shanti Pooja',
            'Satyanarayan Pooja',
          ],
          selectedSet: _gurujiRituals,
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Languages Spoken for Mantras & Vidhi'),
        _buildMultiSelectChips(
          options: [
            'Gorboli (Banjara)',
            'Marathi',
            'Hindi',
            'Telugu',
            'Kannada',
            'Sanskrit',
          ],
          selectedSet: _gurujiLanguages,
        ),
        SizedBox(height: 1.5.h),
        _buildSwitchTile(
          title: 'Complete Pooja Samagri & Havankund Provided',
          subtitle: 'Guruji brings all traditional ritual materials',
          value: _gurujiSamagriProvided,
          onChanged: (val) => setState(() => _gurujiSamagriProvided = val),
        ),
      ],
    );
  }

  // 🏰 7. Banquet Halls & Lawns Specific Fields
  Widget _buildBanquetFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Venue Type'),
        _buildPillChoiceRow(
          options: [
            'AC Banquet Hall',
            'Open Lawn & Garden',
            'AC Banquet Hall + Lawn',
            'Resort & Lawns',
          ],
          selected: _venueType,
          onSelected: (val) => setState(() => _venueType = val),
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Total Guest Capacity (Seating / Floating)'),
        _buildPillChoiceRow(
          options: [
            '200 - 500 Guests',
            '500 - 1,000 Guests',
            '1,000 - 2,500 Guests',
            '2,500+ Guests',
          ],
          selected: _venueCapacity,
          onSelected: (val) => setState(() => _venueCapacity = val),
        ),
        SizedBox(height: 1.8.h),
        _buildFieldLabel('Bride & Groom AC Rooms Included'),
        _buildPillChoiceRow(
          options: ['2 AC Rooms', '5 AC Rooms', '10+ AC Rooms'],
          selected: _venueRooms,
          onSelected: (val) => setState(() => _venueRooms = val),
        ),
        SizedBox(height: 1.5.h),
        _buildSwitchTile(
          title: 'Outside Catering & Decorators Allowed',
          subtitle: 'Families can bring their own preferred vendor',
          value: _venueOutsideCateringAllowed,
          onChanged: (val) =>
              setState(() => _venueOutsideCateringAllowed = val),
        ),
        _buildSwitchTile(
          title: 'Dedicated Valet & Vehicle Parking Available',
          subtitle: 'Space for 100+ four-wheelers and two-wheelers',
          value: _venueDedicatedParking,
          onChanged: (val) => setState(() => _venueDedicatedParking = val),
        ),
      ],
    );
  }

  // 🐎 8. Other Wedding Services
  Widget _buildOtherServiceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Describe Your Speciality'),
        _buildFormTextField(
          label:
              'Service Details (e.g. Wedding Ghodi, Dhol, AC Bus, Fireworks)',
          controller: _aboutController,
          prefixIcon: Icons.stars_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPricingAndSocialCard(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasNearBlack : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: AppColors.opacity8)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Years in Wedding Industry'),
          _buildPillChoiceRow(
            options: ['1-2 Years', '3-5 Years', '5-10 Years', '10+ Years'],
            selected: '$_experienceYears Years',
            onSelected: (val) {
              final parsed = int.tryParse(val.split(' ').first) ?? 3;
              setState(() => _experienceYears = parsed);
            },
          ),
          SizedBox(height: 1.8.h),
          Row(
            children: [
              Expanded(
                child: _buildFormTextField(
                  label: 'Starting Base Price (₹) *',
                  controller: _startingPriceController,
                  prefixIcon: Icons.currency_rupee_rounded,
                  isPhone: true,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildFormTextField(
                  label: 'Average Package (₹)',
                  controller: _avgPriceController,
                  prefixIcon: Icons.payments_outlined,
                  isPhone: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _buildFormTextField(
            label: 'Instagram Page / Portfolio Link (Optional)',
            controller: _instagramController,
            prefixIcon: Icons.camera_alt_outlined,
          ),
          SizedBox(height: 1.5.h),
          _buildFormTextField(
            label: 'About Your Work / Special Message to Families',
            controller: _aboutController,
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementAndSubmit(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreedToTerms,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) => setState(() => _agreedToTerms = val ?? true),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  AppLocalizations.of(context)?.vendorTermsAgreement ??
                      'I agree to provide authentic, verified wedding services to Banjara community families with 100% transparency.',
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Big Gradient Submit Button
        TactilePressable(
          onTap: _isSubmitting ? () {} : _submitRegistration,
          pressedScale: 0.97,
          child: Container(
            width: double.infinity,
            height: 6.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.sunsetOrange,
                  AppColors.deepOrange,
                  AppColors.amberDarkestText,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sunsetOrange.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.how_to_reg_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(
                                context,
                              )?.submitVendorRegistration ??
                              'Submit Vendor Registration',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontWeight: AppTypography.extraBold,
                            color: Colors.white,
                            fontSize: AppTypography.bodyLarge,
                            letterSpacing: 0.3,
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

  // ─── Helper Widget Builders ───
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontWeight: AppTypography.extraBold,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: AppTypography.labelSmall,
        ),
      ),
    );
  }

  Widget _buildPillChoiceRow({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: options.map((opt) {
          final isSelected = selected == opt;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TactilePressable(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(opt);
              },
              pressedScale: 0.95,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark
                            ? Colors.white.withValues(alpha: AppColors.opacity5)
                            : AppColors.slate100),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark
                              ? Colors.white.withValues(alpha: AppColors.opacity8)
                              : Colors.black.withValues(alpha: 0.06)),
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    fontWeight: isSelected
                        ? AppTypography.extraBold
                        : AppTypography.semiBold,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> options,
    required Set<String> selectedSet,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selectedSet.contains(opt);
        return TactilePressable(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                selectedSet.remove(opt);
              } else {
                selectedSet.add(opt);
              }
            });
          },
          pressedScale: 0.95,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(
                      0xFF059669,
                    ).withValues(alpha: isDark ? 0.3 : 0.15)
                  : (isDark
                        ? Colors.white.withValues(alpha: AppColors.opacity5)
                        : AppColors.slate100),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.categoryLocationDark
                    : (isDark
                          ? Colors.white.withValues(alpha: AppColors.opacity8)
                          : Colors.black.withValues(alpha: 0.06)),
                width: isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.categoryLocationDark,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  opt,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: isSelected ? AppColors.categoryLocationDark : (isDark ? Colors.white70 : AppColors.slate500),
                    fontWeight: isSelected
                        ? AppTypography.extraBold
                        : AppTypography.semiBold,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontWeight: AppTypography.extraBold,
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTypography.bodySmall,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.labelTiny,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: theme.colorScheme.primary.withValues(alpha: AppColors.opacity50),
            activeThumbColor: theme.colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFormTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool isPhone = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontFamily: AppTypography.bodyFontFamily,
        color: theme.colorScheme.onSurface,
        fontWeight: AppTypography.semiBold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: AppTypography.labelSmall,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: AppColors.opacity5)
            : AppColors.neutral100,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 3.5.w,
          vertical: 1.3.h,
        ),
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
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
