import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/repositories/volunteer_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Ultra-fast paper biodata digitizer dialog for trust volunteers at Melava events.
class MelavaBiodataDigitizerDialog extends StatefulWidget {
  const MelavaBiodataDigitizerDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const MelavaBiodataDigitizerDialog(),
    );
  }

  @override
  State<MelavaBiodataDigitizerDialog> createState() =>
      _MelavaBiodataDigitizerDialogState();
}

class _MelavaBiodataDigitizerDialogState
    extends State<MelavaBiodataDigitizerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repo = VolunteerRepository();

  // Controllers
  final _fullNameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();

  String _gender = 'Male';
  String _maritalStatus = 'Never Married';
  String? _selectedState = 'Maharashtra';
  String? _selectedDistrict;
  String? _selectedTaluka;

  List<String> _districts = LocationData.getDistricts('Maharashtra');
  List<String> _talukas = [];

  bool _isSubmitting = false;
  Map<String, dynamic>? _lastRegisteredResult;
  int _sessionCount = 0;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _surnameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _educationCtrl.dispose();
    _professionCtrl.dispose();
    _villageCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    super.dispose();
  }

  void _onStateChanged(String? state) {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _selectedTaluka = null;
      _districts = state != null ? LocationData.getDistricts(state) : [];
      _talukas = [];
    });
  }

  void _onDistrictChanged(String? dist) {
    setState(() {
      _selectedDistrict = dist;
      _selectedTaluka = null;
      _talukas = dist != null ? LocationData.getTalukas(dist) : [];
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      'full_name': _fullNameCtrl.text.trim(),
      'surname': _surnameCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()) ?? 22,
      'gender': _gender,
      'marital_status': _maritalStatus,
      'education': _educationCtrl.text.trim(),
      'profession': _professionCtrl.text.trim(),
      'state': _selectedState ?? 'Maharashtra',
      'district': _selectedDistrict ?? '',
      'taluka': _selectedTaluka ?? '',
      'village': _villageCtrl.text.trim(),
      'father_name': _fatherNameCtrl.text.trim(),
      'mother_name': _motherNameCtrl.text.trim(),
    };

    final result = await _repo.registerProfile(payload);

    if (!mounted) return;

    result.fold(
      onSuccess: (data) {
        setState(() {
          _isSubmitting = false;
          _lastRegisteredResult = {
            'fullName': '${_fullNameCtrl.text.trim()} ${_surnameCtrl.text.trim()}',
            'phone': _phoneCtrl.text.trim(),
            'profileId': data['profile_id'] ?? '',
            'message': data['message'] ?? 'Profile Created',
          };
          _sessionCount++;
        });
      },
      onFailure: (error) {
        setState(() => _isSubmitting = false);
        AppLogger.error('MelavaDigitizer', 'Registration failed: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }

  void _resetForNextForm() {
    _fullNameCtrl.clear();
    _surnameCtrl.clear();
    _phoneCtrl.clear();
    _ageCtrl.clear();
    _educationCtrl.clear();
    _professionCtrl.clear();
    _villageCtrl.clear();
    _fatherNameCtrl.clear();
    _motherNameCtrl.clear();

    setState(() {
      _lastRegisteredResult = null;
      _gender = 'Male';
      _maritalStatus = 'Never Married';
    });
  }

  Future<void> _launchWhatsAppCandidateInvite() async {
    if (_lastRegisteredResult == null) return;
    final phone = _lastRegisteredResult!['phone'] as String;
    final name = _lastRegisteredResult!['fullName'] as String;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final waPhone = cleanPhone.startsWith('+') ? cleanPhone.substring(1) : '91$cleanPhone';

    final message =
        'जय सेवालाल! 🚩\n'
        'नमस्ते $name,\n'
        'बंजारा समाज मेळाव्यात आपली बंजाराबायो (BanjaraBio) मॅट्रिमोनी प्रोफाईल यशस्वीपणे नोंदवली आहे.\n\n'
        '👉 ॲप डाऊनलोड करा आणि बायोडेटा पहा:\n'
        'https://play.google.com/store/apps/details?id=com.avishio.banjarabio\n\n'
        'धन्यवाद - बंजाराबायो मेळावा संघ 🚩';

    final uri = Uri.parse('https://wa.me/$waPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const kDarkBg = Color(0xFF0F0F1A);
    const kCardBg = Color(0xFF1E1E2E);
    const kAccent = Color(0xFF6C63FF);

    return Dialog(
      backgroundColor: kDarkBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: kAccent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚡ मेळावा बायोडेटा ऑनबोर्डिंग',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.headingMedium,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'सत्रात नोंदणी केलेले: $_sessionCount बायो-डाटा',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: AppTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _lastRegisteredResult != null
                    ? _buildSuccessCard()
                    : _buildFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    const kAccent = Color(0xFF6C63FF);
    final name = _lastRegisteredResult!['fullName'] ?? 'Candidate';

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
        ),
        const SizedBox(height: 16),
        Text(
          'बायो-डाटा ऑनबोर्ड पूर्ण! 🎉',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$name ची प्रोफाईल बंजाराबायो सिस्टीमवर यशस्वीरित्या जोडली गेली आहे.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: AppTypography.bodyLarge),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _launchWhatsAppCandidateInvite,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.chat_bubble_rounded),
          label: const Text(
            'उमेदवाराला व्हॉट्सॲपवर निमंत्रण पाठवा 📲',
            style: TextStyle(fontWeight: AppTypography.bold),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _resetForNextForm,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: kAccent),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            '➕ पुढील कागदी बायोडेटा ऑनबोर्ड करा (Next Form)',
            style: TextStyle(fontWeight: AppTypography.bold),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFormContent() {
    const kAccent = Color(0xFF6C63FF);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fullNameCtrl,
                  label: 'नाव (Full Name) *',
                  icon: Icons.person_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'नाव आवश्यक आहे' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _surnameCtrl,
                  label: 'आडनाव (Surname)',
                  icon: Icons.badge_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _phoneCtrl,
                  label: 'मोबाईल नंबर *',
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().length < 10 ? '१० अंकी नंबर आवश्यक' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _ageCtrl,
                  label: 'वय (Age)',
                  icon: Icons.cake_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'लिंग (Gender)',
                  value: _gender,
                  items: const ['Male', 'Female'],
                  onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'वैवाहिक स्थिती',
                  value: _maritalStatus,
                  items: const ['Never Married', 'Divorced', 'Widowed'],
                  onChanged: (v) => setState(() => _maritalStatus = v ?? 'Never Married'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _educationCtrl,
                  label: 'शिक्षण (Education)',
                  icon: Icons.school_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _professionCtrl,
                  label: 'व्यवसाय (Profession)',
                  icon: Icons.work_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Location Dropdowns
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'राज्य (State)',
                  value: _selectedState,
                  items: LocationData.states,
                  onChanged: _onStateChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'जिल्हा (District)',
                  value: _selectedDistrict,
                  items: _districts,
                  onChanged: _onDistrictChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'तालुका (Taluka)',
                  value: _selectedTaluka,
                  items: _talukas,
                  onChanged: (v) => setState(() => _selectedTaluka = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _villageCtrl,
                  label: 'गाव / तांडा (Village/Tanda)',
                  icon: Icons.home_work_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherNameCtrl,
                  label: 'वडिलांचे नाव (Father Name)',
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _motherNameCtrl,
                  label: 'आईचे नाव (Mother Name)',
                  icon: Icons.face_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ऑनबोर्ड करा (Save & Invite Candidate)',
                        style: TextStyle(fontSize: AppTypography.headingSmall, fontWeight: AppTypography.bold),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    const kCardBg = Color(0xFF1E1E2E);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: Colors.white, fontSize: AppTypography.bodyLarge),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: AppTypography.bodyMedium),
        prefixIcon: Icon(icon, color: Colors.white54, size: 18),
        filled: true,
        fillColor: kCardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    const kCardBg = Color(0xFF1E1E2E);
    final validValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      style: TextStyle(color: Colors.white, fontSize: AppTypography.bodyLarge),
      dropdownColor: kCardBg,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: AppTypography.bodyMedium),
        filled: true,
        fillColor: kCardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
    );
  }
}
