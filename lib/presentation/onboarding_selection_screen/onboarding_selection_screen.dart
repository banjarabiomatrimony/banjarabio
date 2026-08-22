import 'package:flutter/material.dart';
import 'package:banjarabio/presentation/user_type_selection_screen/user_type_selection_screen.dart';

/// 🌟 OnboardingSelectionScreen is now unified with UserTypeSelectionScreen (New Member Tab)
class OnboardingSelectionScreen extends StatelessWidget {
  const OnboardingSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserTypeSelectionScreen(initialTabIndex: 1);
  }
}
