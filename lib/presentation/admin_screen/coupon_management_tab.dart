import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/staggered_list_animation.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

class CouponManagementTab extends StatefulWidget {
  final ThemeData theme;

  const CouponManagementTab({super.key, required this.theme});

  @override
  State<CouponManagementTab> createState() => _CouponManagementTabState();
}

class _CouponManagementTabState extends State<CouponManagementTab> {
  final AdminRepository _adminRepository = AdminRepository();
  List<CouponModel> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    final response = await _adminRepository.getCoupons();
    if (mounted) {
      response.fold(
        onSuccess: (data) {
          setState(() {
            _coupons = data.map((json) => CouponModel.fromJson(json)).toList();
            _isLoading = false;
          });
        },
        onFailure: (error) {
          setState(() => _isLoading = false);
          AppLogger.error('CouponManagementTab', 'Error loading coupons: $error');
          AppFeedback.showError(
            context,
            error,
            contextTag: 'admin',
            fallbackMessage: AppLocalizations.of(context)?.errorLoadingAdminCoupons ?? 'Failed to load coupon offers.',
          );
        },
      );
    }
  }

  Future<void> _showAddCouponDialog() async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final offerNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final discountController = TextEditingController();
    final genderController = TextEditingController();
    final minAgeController = TextEditingController();
    final maxAgeController = TextEditingController();
    PlanType? selectedPlanType;
    
    File? bannerImage;
    bool isUploading = false;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    final picker = ImagePicker();

    Future<void> pickImage(StateSetter setDialogState) async {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920, // Vertical orientation
      );
      if (pickedFile != null) {
        setDialogState(() => bannerImage = File(pickedFile.path));
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: 85.h,
          decoration: BoxDecoration(
            color: widget.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.5.h, bottom: 1.h),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Coupon',
                          style: widget.theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Design a special offer for your premium users.',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.theme.hintColor,
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // LIVE PREVIEW CARD
                        Text(
                          'Live Preview',
                          style: widget.theme.textTheme.titleSmall?.copyWith(
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: codeController,
                          builder: (context, codeVal, _) => ValueListenableBuilder<TextEditingValue>(
                            valueListenable: offerNameController,
                            builder: (context, nameVal, _) => ValueListenableBuilder<TextEditingValue>(
                              valueListenable: discountController,
                              builder: (context, discountVal, _) => _buildCouponPreview(
                                codeVal.text.isEmpty ? 'COUPON50' : codeVal.text.toUpperCase(),
                                nameVal.text.isEmpty ? 'Your Offer Name' : nameVal.text,
                                discountVal.text.isEmpty ? '0' : discountVal.text,
                                selectedDate,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        _buildFormLabel('Coupon Code', Icons.local_offer_outlined),
                        TextFormField(
                          controller: codeController,
                          decoration: _buildInputDecoration('e.g. SUMMER2024'),
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (_) => setDialogState(() {}),
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 2.5.h),

                        _buildFormLabel('Offer Name', Icons.celebration_outlined),
                        TextFormField(
                          controller: offerNameController,
                          decoration: _buildInputDecoration('e.g. Anniversary Special'),
                          onChanged: (_) => setDialogState(() {}),
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 2.5.h),

                        _buildFormLabel('Discount Percentage', Icons.percent_outlined),
                        TextFormField(
                          controller: discountController,
                          decoration: _buildInputDecoration('e.g. 25'),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setDialogState(() {}),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Required';
                            final val = int.tryParse(v!);
                            if (val == null || val < 0 || val > 100) return 'Enter 0-100';
                            return null;
                          },
                        ),
                        SizedBox(height: 2.5.h),

                        _buildFormLabel('Valid Until', Icons.calendar_month_outlined),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: widget.theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: widget.theme.dividerColor.withValues(alpha: AppColors.opacity10)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event, color: widget.theme.colorScheme.primary, size: 20),
                                SizedBox(width: 3.w),
                                Text(
                                  DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: AppTypography.semiBold,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.edit_calendar, color: widget.theme.hintColor, size: 18),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2.5.h),

                        _buildFormLabel('Description (Optional)', Icons.description_outlined),
                        TextFormField(
                          controller: descriptionController,
                          decoration: _buildInputDecoration('Briefly describe the offer...'),
                          maxLines: 3,
                        ),
                        SizedBox(height: 2.5.h),

                        // --- BANNER UPLOAD ---
                        _buildFormLabel('Optional Banner (Vertical 16:9)', Icons.image_outlined),
                        InkWell(
                          onTap: () => pickImage(setDialogState),
                          child: Container(
                            height: 25.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: widget.theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.theme.dividerColor.withValues(alpha: AppColors.opacity10),
                              ),
                              image: bannerImage != null
                                  ? DecorationImage(
                                      image: FileImage(bannerImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: bannerImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, 
                                          color: widget.theme.colorScheme.primary, 
                                          size: 32),
                                      SizedBox(height: 1.h),
                                      Text('Tap to select banner image',
                                          style: widget.theme.textTheme.bodySmall),
                                    ],
                                  )
                                : Container(
                                    alignment: Alignment.bottomRight,
                                    padding: const EdgeInsets.all(8),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                                        onPressed: () => pickImage(setDialogState),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // --- TARGETING FILTERS ---
                        Text(
                          'Target Audience (Optional)',
                          style: widget.theme.textTheme.titleSmall?.copyWith(
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Empty filters will show the coupon to everyone.',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.theme.hintColor,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        _buildFormLabel('Target Gender', Icons.person_outline),
                        DropdownButtonFormField<String>(
                          initialValue: genderController.text.isEmpty ? null : genderController.text,
                          decoration: _buildInputDecoration('Select Gender'),
                          items: ['Male', 'Female', 'Other']
                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (v) => genderController.text = v ?? '',
                        ),
                        SizedBox(height: 2.h),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFormLabel('Min Age', Icons.calendar_today),
                                  TextFormField(
                                    controller: minAgeController,
                                    decoration: _buildInputDecoration('Min'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFormLabel('Max Age', Icons.calendar_today),
                                  TextFormField(
                                    controller: maxAgeController,
                                    decoration: _buildInputDecoration('Max'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        _buildFormLabel('Target Plan', Icons.card_membership),
                        DropdownButtonFormField<PlanType>(
                          initialValue: selectedPlanType,
                          decoration: _buildInputDecoration('Select Plan'),
                          items: PlanType.values
                              .map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase())))
                              .toList(),
                          onChanged: (v) => setDialogState(() => selectedPlanType = v),
                        ),
                        SizedBox(height: 6.h),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isUploading ? null : () async {
                              if (formKey.currentState?.validate() ?? false) {
                                setDialogState(() => isUploading = true);
                                
                                String? bannerUrl;
                                if (bannerImage != null) {
                                  final fileName = 'coupon_banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                  // Use the public client directly to avoid visibility_for_testing issues
                                  try {
                                    final supabase = AppSupabaseClient.client;
                                    await supabase.storage
                                        .from('banners')
                                        .upload(fileName, bannerImage!);
                                    bannerUrl = supabase.storage
                                        .from('banners')
                                        .getPublicUrl(fileName);
                                  } catch (e) {
                                    AppLogger.error('CouponManagementTab', 'Upload failed: $e');
                                  }
                                }

                                final filters = <String, dynamic>{};
                                if (genderController.text.isNotEmpty) {
                                  filters['gender'] = genderController.text;
                                }
                                if (minAgeController.text.isNotEmpty) {
                                  filters['min_age'] = int.tryParse(minAgeController.text);
                                }
                                if (maxAgeController.text.isNotEmpty) {
                                  filters['max_age'] = int.tryParse(maxAgeController.text);
                                }
                                if (selectedPlanType != null) {
                                  filters['plan_type'] = selectedPlanType!.name;
                                }

                                final response = await _adminRepository.addCoupon(
                                  code: codeController.text.toUpperCase().trim(),
                                  offerName: offerNameController.text.trim(),
                                  description: descriptionController.text.trim(),
                                  validUntil: selectedDate,
                                  discountPercentage: int.parse(discountController.text),
                                  bannerUrl: bannerUrl,
                                  targetFilters: filters.isEmpty ? null : filters,
                                );
                                
                                if (mounted) {
                                  setDialogState(() => isUploading = false);
                                  response.fold(
                                    onSuccess: (_) {
                                      Navigator.pop(context);
                                      _loadCoupons();
                                    },
                                    onFailure: (err) {
                                      AppFeedback.showError(
                                        context,
                                        err,
                                        contextTag: 'admin',
                                        fallbackMessage: AppLocalizations.of(context)?.errorAdminActionFailed ?? 'Failed to add coupon',
                                      );
                                    },
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            child: isUploading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Publish Coupon', style: TextStyle(fontWeight: AppTypography.bold)),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(icon, size: 16, color: widget.theme.colorScheme.primary),
          SizedBox(width: 2.w),
          Text(
            label,
            style: widget.theme.textTheme.labelMedium?.copyWith(
              fontWeight: AppTypography.bold,
              color: widget.theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: widget.theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: widget.theme.dividerColor.withValues(alpha: AppColors.opacity10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: widget.theme.dividerColor.withValues(alpha: AppColors.opacity10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: widget.theme.colorScheme.primary, width: 2),
      ),
    );
  }

  Widget _buildCouponPreview(String code, String name, String discount, DateTime date) {
    return GlassmorphismContainer(
      padding: EdgeInsets.all(4.w),
      borderRadius: BorderRadius.circular(24),
      blur: 20,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COUPON CODE',
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          letterSpacing: 2,
                          color: widget.theme.hintColor,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: AppTypography.headingMedium,
                          fontWeight: AppTypography.bold,
                          color: widget.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_offer, color: widget.theme.colorScheme.primary),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 0.5),
              ),
              Text(
                name.toUpperCase(),
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.extraBold,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 14, color: widget.theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        'Ends ${_formatShortDate(date)}',
                        style: TextStyle(fontSize: AppTypography.labelSmall, color: widget.theme.hintColor),
                      ),
                    ],
                  ),
                   Text(
                    '$discount% OFF',
                    style: TextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.black,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatShortDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);

  Future<void> _toggleCouponStatus(CouponModel coupon) async {
    final response = await _adminRepository.updateCoupon(
      coupon.id,
      isActive: !coupon.isActive,
    );
    response.fold(
      onSuccess: (_) => _loadCoupons(),
      onFailure: (err) {
        AppLogger.error('CouponManagementTab', 'Toggle coupon failed: $err');
        AppFeedback.showError(
          context,
          err,
          contextTag: 'admin',
          fallbackMessage: AppLocalizations.of(context)?.errorAdminActionFailed ?? 'The requested action could not be completed.',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_coupons.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No coupons created yet.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showAddCouponDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Coupon'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final coupon = _coupons[index];
            final isToday = coupon.isValidToday;
            final isExpired = coupon.isExpired;

            return StaggeredListItem(
              index: index,
              child: GlassmorphismContainer(
                margin: EdgeInsets.only(bottom: 1.5.h),
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                coupon.code,
                                style: widget.theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: AppTypography.bold,
                                  color: widget.theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.green.withValues(alpha: AppColors.opacity10)
                                      : isExpired
                                          ? Colors.red.withValues(alpha: AppColors.opacity10)
                                          : Colors.blue.withValues(alpha: AppColors.opacity10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isToday ? 'LIVE' : isExpired ? 'EXPIRED' : 'UPCOMING',
                                  style: TextStyle(
                                    fontSize: AppTypography.bodySmall,
                                    fontWeight: AppTypography.bold,
                                    color: isToday ? Colors.green : isExpired ? Colors.red : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            coupon.offerName,
                            style: widget.theme.textTheme.bodyLarge?.copyWith(fontWeight: AppTypography.semiBold),
                          ),
                          if (coupon.description != null && coupon.description!.isNotEmpty)
                            Text(
                              coupon.description!,
                              style: widget.theme.textTheme.bodySmall,
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: widget.theme.hintColor),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(coupon.validUntil),
                                style: widget.theme.textTheme.bodySmall,
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.percent, size: 14, color: widget.theme.hintColor),
                              const SizedBox(width: 4),
                              Text(
                                '${coupon.discountPercentage}% Off',
                                style: widget.theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Switch(
                          value: coupon.isActive,
                          onChanged: (_) => _toggleCouponStatus(coupon),
                          activeThumbColor: widget.theme.colorScheme.primary,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: _showAddCouponDialog,
                          tooltip: 'Add another',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: _coupons.length,
        ),
      ),
    );
  }
}
