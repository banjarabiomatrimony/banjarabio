import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';

/// Gender selector widget with image-based selection cards.
/// Extracted from PersonalDetailsSection._buildGenderSelector.
class GenderSelectorWidget extends StatelessWidget {
  final String? selectedGender;
  final bool isAdminEdit;
  final ValueChanged<String> onGenderSelected;

  const GenderSelectorWidget({
    super.key,
    required this.selectedGender,
    required this.isAdminEdit,
    required this.onGenderSelected,
  });

  static const List<String> _genderKeys = ['Female', 'Male'];

  static String getLocalizedGender(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    if (key == 'Female') return l10n?.female ?? 'Female';
    if (key == 'Male') return l10n?.male ?? 'Male';
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)?.genderSelectHeading ?? 'Your Gender is',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: _genderKeys.map((gender) {
            final isSelected = selectedGender == gender;
            final isMale = gender == 'Male';

            // 🧬 PRO SCALE: High-visibility image-based backgrounds
            final imagePath = isMale ? 'assets/images/gender_male.png' : 'assets/images/gender_female.png';
            final baseColor = isMale ? Colors.blue.shade700 : Colors.pink.shade600;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: !isMale ? 2.w : 0),
                child: InkWell(
                  onTap: () => onGenderSelected(gender),
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 17.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? baseColor : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 4.0 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: baseColor.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 📸 Background Image
                          Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                          // 🌑 Gradient Overlay for Legibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          // 📝 Centered Gender Text
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                getLocalizedGender(context, gender).toUpperCase(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              if (isSelected)
                                Container(
                                  margin: EdgeInsets.only(bottom: 1.5.h),
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: baseColor,
                                    size: 16,
                                  ),
                                )
                              else
                                SizedBox(height: 3.5.h),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
