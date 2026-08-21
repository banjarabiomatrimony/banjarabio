import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Height selector widget with dual sliders for feet and inches.
/// Extracted from PersonalDetailsSection._buildHeightSelector.
class HeightSelectorWidget extends StatefulWidget {
  final int initialFeet;
  final int initialInches;
  final ValueChanged<String> onHeightChanged;

  const HeightSelectorWidget({
    super.key,
    required this.initialFeet,
    required this.initialInches,
    required this.onHeightChanged,
  });

  @override
  State<HeightSelectorWidget> createState() => _HeightSelectorWidgetState();
}

class _HeightSelectorWidgetState extends State<HeightSelectorWidget> {
  late int _heightFeet;
  late int _heightInches;
  late TextEditingController _feetController;
  late TextEditingController _inchesController;

  @override
  void initState() {
    super.initState();
    _heightFeet = widget.initialFeet;
    _heightInches = widget.initialInches;
    _feetController = TextEditingController(text: _heightFeet.toString());
    _inchesController = TextEditingController(text: _heightInches.toString());
  }

  @override
  void didUpdateWidget(covariant HeightSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFeet != widget.initialFeet || oldWidget.initialInches != widget.initialInches) {
      _heightFeet = widget.initialFeet;
      _heightInches = widget.initialInches;
      _feetController.text = _heightFeet.toString();
      _inchesController.text = _heightInches.toString();
    }
  }

  @override
  void dispose() {
    _feetController.dispose();
    _inchesController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onHeightChanged("$_heightFeet'$_heightInches\"");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'height',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    AppLocalizations.of(context)?.height ?? 'Height',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold),
                  ),
                  const Spacer(),
                  Text(
                    "$_heightFeet'$_heightInches\"",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: AppTypography.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)?.feet ?? 'Feet', style: theme.textTheme.bodySmall?.copyWith(fontWeight: AppTypography.bold)),
                            SizedBox(
                              width: 12.w,
                              height: 4.h,
                              child: TextField(
                                controller: _feetController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppTypography.bold),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity30),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                onChanged: (val) {
                                  final n = int.tryParse(val);
                                  if (n != null && n >= 4 && n <= 7) {
                                    setState(() => _heightFeet = n);
                                    _notifyChange();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _heightFeet.toDouble(),
                          min: 4,
                          max: 7,
                          divisions: 3,
                          label: _heightFeet.toString(),
                          onChanged: (value) {
                            setState(() {
                              _heightFeet = value.toInt();
                              _feetController.text = _heightFeet.toString();
                            });
                            _notifyChange();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)?.inches ?? 'Inches', style: theme.textTheme.bodySmall?.copyWith(fontWeight: AppTypography.bold)),
                            SizedBox(
                              width: 12.w,
                              height: 4.h,
                              child: TextField(
                                controller: _inchesController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppTypography.bold),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity30),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                onChanged: (val) {
                                  final n = int.tryParse(val);
                                  if (n != null && n >= 0 && n <= 11) {
                                    setState(() => _heightInches = n);
                                    _notifyChange();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _heightInches.toDouble(),
                          max: 11,
                          divisions: 11,
                          label: _heightInches.toString(),
                          onChanged: (value) {
                            setState(() {
                              _heightInches = value.toInt();
                              _inchesController.text = _heightInches.toString();
                            });
                            _notifyChange();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
