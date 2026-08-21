import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/creator_model.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/staggered_list_animation.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/presentation/admin_screen/admin_helpers.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Creators / Influencer management tab with list, metrics, and add/edit form.
class AdminCreatorsTab extends StatefulWidget {
  final InfluencerRepository influencerRepository;

  const AdminCreatorsTab({super.key, required this.influencerRepository});

  @override
  State<AdminCreatorsTab> createState() => AdminCreatorsTabState();
}

class AdminCreatorsTabState extends State<AdminCreatorsTab> {
  bool _isLoading = true;
  List<Creator> _creators = [];

  @override
  void initState() {
    super.initState();
    _loadCreators();
  }

  Future<void> _loadCreators() async {
    setState(() => _isLoading = true);
    final res = await widget.influencerRepository.getAllCreators();
    res.fold(
      onSuccess: (creators) {
        if (mounted) setState(() { _creators = creators; _isLoading = false; });
      },
      onFailure: (e) {
        AppLogger.error('AdminCreatorsTab', 'Creators failed: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  /// Public method so the shell header can trigger this.
  void showCreatorForm({Creator? creator}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (context, scrollController) => _CreatorForm(
          creator: creator,
          onSuccess: () { _loadCreators(); if (mounted) Navigator.pop(context); },
          influencerRepository: widget.influencerRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (_creators.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CustomIconWidget(iconName: 'people_outline', size: 64, color: theme.hintColor),
          SizedBox(height: 2.h),
          Text('No creators found', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: showCreatorForm,
            icon: const Icon(Icons.add),
            label: const Text('Add First Creator'),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ])),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final creator = _creators[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: StaggeredListItem(
                index: index,
                child: GlassmorphismContainer(
                  padding: EdgeInsets.all(4.w), borderRadius: BorderRadius.circular(20), blur: 10, opacity: 0.1,
                  child: Column(children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(radius: 24, backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1), child: Icon(Icons.person, color: theme.colorScheme.primary)),
                      SizedBox(width: 4.w),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(creator.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(creator.promoCode, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: AppTypography.bold)),
                          ),
                        ]),
                        if (creator.instagramHandle != null)
                          Text('@${creator.instagramHandle}', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                      ])),
                    ]),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      _buildMetric('Referrals', creator.totalReferrals.toString()),
                      _buildMetric('Conversions', creator.totalConversions.toString()),
                      _buildMetric('Earnings', '₹${creator.totalCommissionEarned.toStringAsFixed(0)}'),
                    ]),
                    SizedBox(height: 2.h),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () => showCreatorForm(creator: creator),
                        icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      )),
                      if (creator.phoneNumber != null && creator.phoneNumber!.isNotEmpty) ...[
                        SizedBox(width: 2.w),
                        buildAdminContactAction(icon: Icons.call, label: 'Call', color: Colors.blue, onTap: () => launchCaller(context, creator.phoneNumber!), theme: theme),
                        SizedBox(width: 2.w),
                        buildAdminContactAction(icon: Icons.chat, label: 'WhatsApp', color: Colors.green, onTap: () => launchWhatsApp(context, creator.phoneNumber!), theme: theme),
                      ],
                    ]),
                  ]),
                ),
              ),
            );
          },
          childCount: _creators.length,
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(children: [
      Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: AppTypography.labelSmall, color: Theme.of(context).hintColor)),
    ]);
  }
}

// ─── Creator Add/Edit Form ──────────────────────────────────────────────────

class _CreatorForm extends StatefulWidget {
  final Creator? creator;
  final VoidCallback onSuccess;
  final InfluencerRepository influencerRepository;

  const _CreatorForm({required this.creator, required this.onSuccess, required this.influencerRepository});

  @override
  State<_CreatorForm> createState() => _CreatorFormState();
}

class _CreatorFormState extends State<_CreatorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _promoController;
  late final TextEditingController _instaController;
  late final TextEditingController _phoneController;
  late final TextEditingController _commissionController;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.creator?.name);
    _promoController = TextEditingController(text: widget.creator?.promoCode);
    _instaController = TextEditingController(text: widget.creator?.instagramHandle);
    _phoneController = TextEditingController(text: widget.creator?.phoneNumber);
    _commissionController = TextEditingController(text: (widget.creator?.commissionPct ?? 0.1).toString());
    _isActive = widget.creator?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose(); _promoController.dispose(); _instaController.dispose();
    _phoneController.dispose(); _commissionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final response = widget.creator == null
        ? await widget.influencerRepository.addCreator(
            name: _nameController.text.trim(), promoCode: _promoController.text.trim().toUpperCase(),
            commissionPct: double.tryParse(_commissionController.text) ?? 0.1,
            instagramHandle: _instaController.text.trim().isEmpty ? null : _instaController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          )
        : await widget.influencerRepository.updateCreator(
            id: widget.creator!.id, name: _nameController.text.trim(),
            commissionPct: double.tryParse(_commissionController.text),
            instagramHandle: _instaController.text.trim().isEmpty ? null : _instaController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            isActive: _isActive,
          );

    setState(() => _isSubmitting = false);
    response.fold(onSuccess: (_) => widget.onSuccess(), onFailure: (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.creator != null;

    return GlassmorphismContainer(
      padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 2.h, bottom: MediaQuery.of(context).viewInsets.bottom + 4.h),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), blur: 20,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 12.w, height: 5, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 3.h),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(isEdit ? 'Edit Influencer' : 'Add New Influencer', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: AppTypography.bold, color: theme.colorScheme.primary)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), style: IconButton.styleFrom(backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
            ]),
            Text(isEdit ? 'Update details for ${widget.creator!.name}' : 'Register a new creator for influencer marketing', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
            SizedBox(height: 4.h),
            _buildField(label: 'Creator Name', controller: _nameController, icon: Icons.person_outline, validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null),
            SizedBox(height: 2.h),
            _buildField(label: 'Promo Code', controller: _promoController, icon: Icons.local_offer_outlined, enabled: !isEdit, hintText: 'e.g. BANJARA10', textCapitalization: TextCapitalization.characters, validator: (v) => v?.isEmpty ?? true ? 'Promo code is required' : null),
            SizedBox(height: 2.h),
            _buildField(label: 'Instagram Handle', controller: _instaController, icon: Icons.alternate_email, hintText: '@username (optional)'),
            SizedBox(height: 2.h),
            _buildField(label: 'Phone Number', controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone, hintText: 'e.g. +91 9876543210 (optional)'),
            SizedBox(height: 2.h),
            _buildField(label: 'Commission %', controller: _commissionController, icon: Icons.percent, keyboardType: const TextInputType.numberWithOptions(decimal: true), hintText: '0.1 = 10%', validator: (v) { if (v == null || v.isEmpty) return 'Commission is required'; final d = double.tryParse(v); if (d == null || d < 0 || d > 1) return 'Must be between 0 and 1'; return null; }),
            if (isEdit) ...[
              SizedBox(height: 2.h),
              GlassmorphismContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16), borderRadius: BorderRadius.circular(16), blur: 5, opacity: 0.05,
                child: SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Account Status'), subtitle: Text(_isActive ? 'Active' : 'Deactivated'), value: _isActive, activeThumbColor: theme.colorScheme.primary, activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.3), onChanged: (v) => setState(() => _isActive = v)),
              ),
            ],
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity, height: 7.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10, shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3)),
                child: _isSubmitting ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : Text(isEdit ? 'Update Creator' : 'Register Creator', style: TextStyle(fontSize: AppTypography.bodyMedium, fontWeight: AppTypography.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, required IconData icon, bool enabled = true, String? hintText, TextInputType? keyboardType, TextCapitalization textCapitalization = TextCapitalization.none, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: AppTypography.bold, color: theme.colorScheme.primary.withValues(alpha: 0.8))),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, enabled: enabled, keyboardType: keyboardType, textCapitalization: textCapitalization, validator: validator, style: TextStyle(fontSize: AppTypography.bodySmall),
        decoration: InputDecoration(
          hintText: hintText, prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
        ),
      ),
    ]);
  }
}
