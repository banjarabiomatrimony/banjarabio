import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/theme/app_colors.dart';

class SpecialDiscountTab extends StatefulWidget {
  final ThemeData theme;
  final AdminRepository? adminRepository;

  const SpecialDiscountTab({
    super.key,
    required this.theme,
    this.adminRepository,
  });

  @override
  State<SpecialDiscountTab> createState() => _SpecialDiscountTabState();
}

class _SpecialDiscountTabState extends State<SpecialDiscountTab> {
  late final AdminRepository _adminRepository;
  final _formKey = GlobalKey<FormState>();
  
  final _userIdController = TextEditingController();
  final _discountController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _adminRepository = widget.adminRepository ?? AdminRepository();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _submitDiscount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    final response = await _adminRepository.grantSpecialDiscount(
      userId: _userIdController.text.trim(),
      percentage: int.parse(_discountController.text),
      expiresAt: _expiryDate,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      response.fold(
        onSuccess: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Special discount granted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _userIdController.clear();
          _discountController.clear();
          setState(() {
            _expiryDate = DateTime.now().add(const Duration(days: 7));
          });
        },
        onFailure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to grant discount: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      sliver: SliverToBoxAdapter(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grant Special Discount',
                style: widget.theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppTypography.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Grant a manual percentage discount to a specific user via their UID.',
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: widget.theme.hintColor,
                ),
              ),
              SizedBox(height: 4.h),
              
              GlassmorphismContainer(
                padding: EdgeInsets.all(6.w),
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('User ID (UID)', Icons.person_search_outlined),
                    TextFormField(
                      controller: _userIdController,
                      decoration: _buildInputDecoration('Enter target user id...'),
                      validator: (v) => v?.isEmpty ?? true ? 'User ID is required' : null,
                    ),
                    SizedBox(height: 3.h),
                    
                    _buildLabel('Discount Percentage (%)', Icons.percent_outlined),
                    TextFormField(
                      controller: _discountController,
                      decoration: _buildInputDecoration('e.g. 50'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Percentage is required';
                        final val = int.tryParse(v!);
                        if (val == null || val < 0 || val > 100) return 'Enter 0-100';
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    
                    _buildLabel('Discount Validity Until', Icons.calendar_month_outlined),
                    InkWell(
                      onTap: _selectDate,
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
                              DateFormat('EEEE, MMM dd, yyyy').format(_expiryDate),
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
                    SizedBox(height: 5.h),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitDiscount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: _isSubmitting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Grant Special Discount', style: TextStyle(fontWeight: AppTypography.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 4.h),
              _buildInfoNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, IconData icon) {
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

  Widget _buildInfoNote() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: AppColors.opacity5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: AppColors.opacity20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'User IDs can be found in the "Users" tab. Granting a new discount will override any existing special discount for that user.',
              style: widget.theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
