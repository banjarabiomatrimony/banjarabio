import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

class ReferenceVerificationScreen extends StatefulWidget {
  const ReferenceVerificationScreen({super.key});

  @override
  State<ReferenceVerificationScreen> createState() =>
      _ReferenceVerificationScreenState();
}

class _ReferenceVerificationScreenState
    extends State<ReferenceVerificationScreen> {
  final TrustScoreRepository _repository = TrustScoreRepository();

  // Contact 1
  final TextEditingController _name1Controller = TextEditingController();
  final TextEditingController _mobile1Controller = TextEditingController();

  // Contact 2
  final TextEditingController _name2Controller = TextEditingController();
  final TextEditingController _mobile2Controller = TextEditingController();

  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _name1Controller.dispose();
    _mobile1Controller.dispose();
    _name2Controller.dispose();
    _mobile2Controller.dispose();
    super.dispose();
  }

  Future<void> _sendRequests() async {
    if (_name1Controller.text.isEmpty ||
        _mobile1Controller.text.isEmpty ||
        _name2Controller.text.isEmpty ||
        _mobile2Controller.text.isEmpty) {
      AppFeedback.showWarning(
        context,
        AppLocalizations.of(context)?.pleaseFillAllFields ?? 'Please fill all fields',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Add both references
      final res1 = await _repository.addReference(
        name: _name1Controller.text,
        phone: _mobile1Controller.text,
      );

      await res1.fold(
        onSuccess: (_) async {
          final res2 = await _repository.addReference(
            name: _name2Controller.text,
            phone: _mobile2Controller.text,
          );

          await res2.fold(
            onSuccess: (_) async {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isSent = true;
                });
                AppFeedback.showSuccess(
                  context,
                  AppLocalizations.of(context)?.requestsSentSuccessfully ?? 'Requests sent successfully!',
                );
              }
            },
            onFailure: (error) async {
              throw Exception('Second reference failed: $error');
            },
          );
        },
        onFailure: (error) async {
          throw Exception('First reference failed: $error');
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppFeedback.showError(
          context,
          e,
          contextTag: 'verification',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)?.referenceVerification ?? 'Reference Verification'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            Icon(Icons.group_add, size: 48.sp, color: Colors.purple),
            SizedBox(height: 2.h),
            Text(AppLocalizations.of(context)?.addTwoReferences ?? 'Add Two References',
              style: TextStyle(fontSize: AppTypography.headingSmall, fontWeight: AppTypography.bold),
            ),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.weWillSendAVerificationRequestToTheirMob ?? 'We will send a verification request to their mobile number. Once they approve, you get +10 Points.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4.h),

            if (!_isSent) ...[
              _buildContactForm(1, _name1Controller, _mobile1Controller),
              SizedBox(height: 3.h),
              _buildContactForm(2, _name2Controller, _mobile2Controller),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendRequests,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)?.sendVerificationRequests ?? 'Send Verification Requests'),
                ),
              ),
            ] else ...[
              Icon(Icons.check_circle, size: 60.sp, color: Colors.green),
              SizedBox(height: 2.h),
              Text(AppLocalizations.of(context)?.requestsSent ?? 'Requests Sent!',
                style: TextStyle(fontSize: AppTypography.headingMedium, fontWeight: AppTypography.bold),
              ),
              SizedBox(height: 1.h),
              Text(AppLocalizations.of(context)?.statusWaitingForApproval ?? 'Status: Waiting for approval',
                style: const TextStyle(color: Colors.orange),
              ),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context)?.done ?? 'Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm(
    int index,
    TextEditingController nameCtrl,
    TextEditingController mobileCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.referenceWithNumber(index) ??
              'Reference $index',
          style: const TextStyle(fontWeight: AppTypography.bold),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)?.name ?? 'Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: mobileCtrl,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)?.mobileNumber ?? 'Mobile Number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixText: '+91 ',
          ),
        ),
      ],
    );
  }
}
