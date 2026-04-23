import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

/// Enum to track the current stage of the multi-screen tour
enum TourStage {
  none,
  homeScreen,
  profileDetail,
  chatScreen,
  matchesScreen,
  myProfileScreen,
  finished
}

final guestTourProvider = ChangeNotifierProvider<GuestGuidedTourService>((ref) {
  return GuestGuidedTourService(ref);
});

class GuestGuidedTourService extends ChangeNotifier {
  final Ref ref;
  final FlutterTts _flutterTts = FlutterTts();
  
  TourStage currentStage = TourStage.none;
  TutorialCoachMark? _tutorialCoachMark;
  
  bool isVoiceEnabled = false;
  double tourSpeed = 1.0; // 1x, 2x, 3x, 4x
  
  GuestGuidedTourService(this.ref) {
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    // Language is set dynamically before speaking
  }

  void toggleVoice() {
    isVoiceEnabled = !isVoiceEnabled;
    if (!isVoiceEnabled) {
      _flutterTts.stop();
    }
    notifyListeners();
  }

  void setSpeed(double speed) {
    tourSpeed = speed;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!isVoiceEnabled) return;
    
    // Set language based on active locale
    final locale = ref.read(localeProvider)?.languageCode ?? 'en';
    String ttsLang = 'en-US';
    switch (locale) {
      case 'mr': ttsLang = 'mr-IN'; break;
      case 'hi': ttsLang = 'hi-IN'; break;
      case 'te': ttsLang = 'te-IN'; break;
      case 'kn': ttsLang = 'kn-IN'; break;
      case 'en': 
      default:
        ttsLang = 'en-US'; break;
    }
    
    await _flutterTts.setLanguage(ttsLang);
    // Adjust speech rate based on tourSpeed (TTS rate usually between 0.0 and 1.0)
    // 1x = 0.5 (normal), 2x = 0.7, 3x = 0.9, 4x = 1.0
    double rate = 0.5 * (1 + (tourSpeed - 1) * 0.3);
    if (rate > 1.0) rate = 1.0;
    await _flutterTts.setSpeechRate(rate);
    
    await _flutterTts.speak(text);
  }

  void stopSpeaking() {
    _flutterTts.stop();
  }

  OverlayEntry? _controlsOverlay;

  /// Starts or resumes the tour for a specific context and stage.
  void startTour(
    BuildContext context, {
    required TourStage stage,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
    Function(TargetFocus)? onClickTarget,
  }) {
    // 🚀 NEW REQUIREMENT: Tour only available in Guest Mode
    if (!LocalCacheService().isGuestMode()) {
      debugPrint('GuestGuidedTourService: Skipping tour - not in Guest Mode');
      return;
    }

    currentStage = stage;
    _tutorialCoachMark?.finish();
    _removeOverlay();
    
    // Calculate animation duration based on speed
    final int transitionMs = (600 / tourSpeed).round();
    
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Theme.of(context).colorScheme.primary,
      opacityShadow: 0.85,
      focusAnimationDuration: Duration(milliseconds: transitionMs),
      unFocusAnimationDuration: Duration(milliseconds: transitionMs),
      pulseAnimationDuration: Duration(milliseconds: (transitionMs * 1.5).round()),
      onFinish: () {
        stopSpeaking();
        _removeOverlay();
        if (onFinish != null) onFinish();
      },
      onClickTarget: (target) {
        stopSpeaking();
        if (onClickTarget != null) onClickTarget(target);
      },
      onClickOverlay: (target) {
        stopSpeaking();
      },
      onSkip: () {
        stopSpeaking();
        _removeOverlay();
        currentStage = TourStage.finished;
        // Optionally save to prefs that Guest Tour is done
        notifyListeners();
        if (onSkip != null) onSkip();
        return true;
      },
    )..show(context: context);

    _showControlsOverlay(context);
  }

  void _removeOverlay() {
    _controlsOverlay?.remove();
    _controlsOverlay = null;
  }

  void _showControlsOverlay(BuildContext context) {
    _controlsOverlay = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: _TourControlsWidget(service: this),
          ),
        );
      },
    );
    Overlay.of(context).insert(_controlsOverlay!);
  }
}

class _TourControlsWidget extends StatefulWidget {
  final GuestGuidedTourService service;
  const _TourControlsWidget({required this.service});

  @override
  State<_TourControlsWidget> createState() => _TourControlsWidgetState();
}

class _TourControlsWidgetState extends State<_TourControlsWidget> {
  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speed Control
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildSpeedBtn(1.0, '1x', theme),
              _buildSpeedBtn(2.0, '2x', theme),
              _buildSpeedBtn(3.0, '3x', theme),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // TTS Control
        GestureDetector(
          onTap: () {
            widget.service.toggleVoice();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.service.isVoiceEnabled ? theme.colorScheme.primary : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.service.isVoiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: widget.service.isVoiceEnabled ? Colors.white : theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedBtn(double speed, String label, ThemeData theme) {
    final bool isSelected = widget.service.tourSpeed == speed;
    return GestureDetector(
      onTap: () {
        widget.service.setSpeed(speed);
        // We can't immediately change coach mark animation durations while it's running
        // but we can adjust speech rate on the fly.
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
