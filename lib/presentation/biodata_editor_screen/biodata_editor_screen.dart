import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/editor_loading_state.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/editor_bottom_action_bar.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/editor_locked_overlay_widget.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/editor_template_picker_widget.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/editor_language_picker_widget.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/editor_details_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';


import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/pdf_assets_service.dart';
import 'package:banjarabio/core/models/biodata_content.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/services/pdf/pdf_generator_service.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/biodata_ui_helpers.dart';
import 'package:banjarabio/core/services/pdf/biodata_translations.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// World-class Biodata Editor Screen with production-ready architecture
/// 
/// Features:
/// - Proper async initialization with error handling
/// - Memory-efficient image loading; compression only on upload, not on display
/// - Debounced PDF generation to prevent OOM
/// - Graceful error recovery
/// - Optimized for low-end devices
class BiodataEditorScreen extends StatefulWidget {
  const BiodataEditorScreen({super.key});

  @override
  State<BiodataEditorScreen> createState() => _BiodataEditorScreenState();
}

enum _LoadingState {
  initializing,
  loadingProfile,
  loadingAssets,
  ready,
  error,
}

class _BiodataEditorScreenState extends State<BiodataEditorScreen>
    with SingleTickerProviderStateMixin {
  final ProfileRepository _profileRepository = ProfileRepository();
  final RazorpayRepository _razorpayRepository = RazorpayRepository();
  final UsageRepository _usageRepository = UsageRepository();
  final PdfIsolateManager _pdfManager = PdfIsolateManager();

  // State
  ProfileModel? _profile;
  BiodataContent? _content;
  BiodataTemplateType _selectedTemplate = BiodataTemplateType.royalGold;
  String _selectedLanguage = 'English';
  Uint8List? _pdfData;
  Uint8List? _logoBytes;
  Uint8List? _profilePhotoBytes;
  
  _LoadingState _loadingState = _LoadingState.initializing;
  String? _errorMessage;
  bool _isGeneratingPdf = false;
  bool _isProcessingPayment = false;

  // Controllers
  final Map<String, TextEditingController> _controllers = {};
  Timer? _debounceTimer;
  late TabController _tabController;
  late VoidCallback _tabListener;
  late ValueNotifier<int> _tabIndexNotifier;
  final GlobalKey<State<StatefulWidget>> _previewKey = GlobalKey();

  // Cancellation tokens for async operations
  final Set<Completer<void>> _activeOperations = {};

  bool _uiInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer UI and data to next frame so first paint is light (avoids crash in debug)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Initialize language from current locale
      setState(() {
        _selectedLanguage = BiodataTranslations.fromLocale(
          Localizations.localeOf(context).languageCode,
        );
      });

      if (!_uiInitialized) {
        _uiInitialized = true;
        _initializeUI();
      }
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _loadData();
      });
    });
  }

  void _initializeUI() {
    _tabController = TabController(length: 3, vsync: this);
    _tabIndexNotifier = ValueNotifier<int>(0);
    _tabListener = () {
      if (!_tabController.indexIsChanging) {
        _tabIndexNotifier.value = _tabController.index;
      }
    };
    _tabController.addListener(_tabListener);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_uiInitialized) {
      _tabController.removeListener(_tabListener);
      _tabController.dispose();
      _tabIndexNotifier.dispose();
    }
    
    // Cancel all active operations
    for (final op in _activeOperations) {
      if (!op.isCompleted) {
        op.complete();
      }
    }
    _activeOperations.clear();
    
    // Dispose controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    
    // Dispose PDF manager
    _pdfManager.dispose();
    
    // Clear memory only on dispose (not on entry)
    _clearMemory();
    super.dispose();
  }

  void _clearMemory() {
    // 🧬 PERFORMANCE: Removed global imageCache.clear() which was causing feed stutter.
    // Proactive limits are now managed globally by PerformanceService.
  }

  /// After payment success: refresh profile to get updated isPdfUnlocked.
  /// Uses forceRefresh: false so we read from cache – RazorpayRepository applies
  /// an optimistic unlock before completing, so cache has correct isPdfUnlocked.
  /// Deferred to next frame so UI updates cleanly after returning from Razorpay.
  Future<void> _refreshProfileFromCacheAfterPayment() async {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final profileResponse = await _profileRepository.getOwnProfile(
          
        );
        if (!mounted) return;
        profileResponse.fold(
          onSuccess: (profile) {
            if (profile != null && mounted) {
              setState(() {
                _profile = profile;
                _content = BiodataContent.fromProfile(profile);
              });
              _generatePdf();
              AppLogger.debug('BiodataEditorScreen', '[RAZORPAY] BiodataEditorScreen > Profile refreshed from cache | isPdfUnlocked=${profile.isPdfUnlocked}');
            } else if (mounted) {
              _loadData(forceRefreshProfile: true);
            }
          },
          onFailure: (_) {
            if (mounted) _loadData(forceRefreshProfile: true);
          },
        );
      } catch (e) {
        AppLogger.error('BiodataEditorScreen', '[RAZORPAY] BiodataEditorScreen > Cache refresh failed | $e');
        if (mounted) _loadData(forceRefreshProfile: true);
      }
    });
  }

  /// Main data loading method with comprehensive error handling.
  /// Use [forceRefreshProfile: true] after payment to get fresh unlock status.
  Future<void> _loadData({bool forceRefreshProfile = false}) async {
    if (!mounted) return;
    
    final completer = Completer<void>();
    _activeOperations.add(completer);
    
    try {
      setState(() {
        _loadingState = _LoadingState.loadingProfile;
        _errorMessage = null;
      });

      // Step 1: Load profile (critical path)
      final profileResponse = await _profileRepository.getOwnProfile(
        forceRefresh: forceRefreshProfile,
      );
      
      await profileResponse.fold(
        onSuccess: (profile) async {
          if (profile == null || !mounted) {
            if (mounted) {
              setState(() {
                _loadingState = _LoadingState.error;
                _errorMessage = 'Profile not found';
              });
            }
            return;
          }

          // Initialize content and controllers; show editor immediately (don't block on assets)
          if (mounted) {
            setState(() {
              _profile = profile;
              _content = BiodataContent.fromProfile(profile);
              _loadingState = _LoadingState.ready;
            });
            _initializeControllers();
            // Defer PDF generation to next frame so UI paints first
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _generatePdf();
            });
          }

          // Load PDF assets (logo + profile photo) from global service; then refresh PDF
          PdfAssetsService.instance.getPdfAssets(profile).then((assets) {
            if (mounted) {
              setState(() {
                _logoBytes = assets.logoBytes;
                _profilePhotoBytes = assets.profilePhotoBytes;
              });
              _generatePdf();
            }
          }).catchError((_) {});
        },
        onFailure: (error) {
          if (mounted) {
            setState(() {
              _loadingState = _LoadingState.error;
              _errorMessage = 'Failed to load profile: $error';
            });
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('BiodataEditorScreen', 'Error in _loadData: $e');
      AppLogger.debug('BiodataEditorScreen', 'Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _loadingState = _LoadingState.error;
          _errorMessage = 'An unexpected error occurred';
        });
      }
    } finally {
      _activeOperations.remove(completer);
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  void _initializeControllers() {
    if (_content == null) return;

    _addControllersForMap(_content!.personalDetails);
    _addControllersForMap(_content!.educationProfession);
    _addControllersForMap(_content!.familyDetails);
    _addControllersForMap(_content!.locationContact);

    _controllers['partnerExpectations'] = TextEditingController(
      text: _content!.partnerExpectations,
    );
    _controllers['aboutMe'] = TextEditingController(text: _content!.aboutMe);
  }

  void _addControllersForMap(Map<String, String> data) {
    data.forEach((key, value) {
      if (!_controllers.containsKey(key)) {
        _controllers[key] = TextEditingController(text: value);
      }
    });
  }

  /// Generate PDF with debouncing and proper error handling
  Future<void> _generatePdf() async {
    if (_content == null || !mounted) return;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();
    
    // Debounce to prevent OOM on rapid changes
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted || _isGeneratingPdf) return;

      setState(() => _isGeneratingPdf = true);

      try {
        final isPremiumTemplate = _selectedTemplate.isPremium;
        final isPaid = _profile?.isPdfUnlocked ?? false;

        final templateConfig = kBiodataTemplates.firstWhere(
          (t) => t.type == _selectedTemplate,
          orElse: () => kBiodataTemplates.first,
        );

        Uint8List? templateImageBytes;
        try {
          final ByteData data = await rootBundle.load(templateConfig.assetPath);
          templateImageBytes = data.buffer.asUint8List();
        } catch (e) {
          AppLogger.error('BiodataEditorScreen', 'Error loading template image: $e');
        }

        final params = PdfGenerationParams(
          content: _content!,
          templateType: _selectedTemplate,
          language: _selectedLanguage,
          logoBytes: _logoBytes,
          profilePhotoBytes: _profilePhotoBytes,
          templateImageBytes: templateImageBytes,
          isLandscape: false,
          isPremiumTemplate: isPremiumTemplate,
          isPaid: isPaid,
          rootIsolateToken: RootIsolateToken.instance,
        );

        // Generate PDF in background isolate
        final pdfData = await _pdfManager.generate(params);

        if (mounted) {
          setState(() {
            _pdfData = pdfData;
            _isGeneratingPdf = false;
          });
        }
      } catch (e, stackTrace) {
        AppLogger.error('BiodataEditorScreen', 'Error generating PDF: $e');
        AppLogger.debug('BiodataEditorScreen', 'Stack trace: $stackTrace');
        if (mounted) {
          setState(() => _isGeneratingPdf = false);
          AppFeedback.showError(
            context,
            AppLocalizations.of(context)?.previewGenerationFailed ?? 'Preview generation failed. Please try again.',
            contextTag: 'pdf',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      // Show loading state
    if (_loadingState != _LoadingState.ready || _content == null) {
      return Scaffold(
        backgroundColor: BiodataTheme.royalIvory,
        body: Container(
          decoration: const BoxDecoration(gradient: BiodataTheme.royalBackground),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: _loadingState == _LoadingState.error
                    ? EditorErrorStateWidget(errorMessage: _errorMessage, onRetry: _loadData)
                    : EditorLoadingStateWidget(message: _getLoadingMessage()),
              ),
            ),
          ),
        ),
      );
    }

    // Temp bypass for growth campaign: premium features are free, keep original check dormant.
    // In future, change to: _selectedTemplate.isPremium && !(_profile?.isPdfUnlocked ?? false)
    final bool isLocked = false;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BiodataTheme.royalBackground),
        child: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 16.h,
                      floating: true,
                      snap: true,
                      pinned: true,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0.5,
                      leading: Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20.sp,
                          ),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)?.customizeBiodata ?? 'Customize Biodata',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: AppTypography.semiBold,
                          fontSize: AppTypography.bodyLarge,
                        ),
                      ),
                      centerTitle: false,
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(8.5.h),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.2.h),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(BiodataTheme.radiusPill),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: AppColors.opacity10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: const BoxDecoration(
                              color: BiodataTheme.surfaceWhite,
                              borderRadius: BorderRadius.all(Radius.circular(BiodataTheme.radiusPill)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(26, 26, 26, 0.15),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerHeight: 0,
                            labelColor: BiodataTheme.royalGold,
                            unselectedLabelColor: BiodataTheme.deepCharcoal.withValues(alpha: AppColors.opacity60),
                            labelStyle: TextStyle(
                              fontWeight: AppTypography.semiBold,
                              fontSize: AppTypography.bodySmall,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontWeight: AppTypography.medium,
                              fontSize: AppTypography.bodySmall,
                            ),
                            tabs: [
                              Tab(text: AppLocalizations.of(context)?.template ?? 'Template'),
                              Tab(text: AppLocalizations.of(context)?.language ?? 'Language'),
                              Tab(text: AppLocalizations.of(context)?.details ?? 'Details'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _tabIndexNotifier,
                        builder: (context, index, child) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 1.5.h),
                            child: Container(
                              decoration:
                                  BiodataTheme.sectionCardDecoration(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.w,
                                  vertical: 0.h,
                                ),
                                child: _getTabContent(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ];
                },
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    const maxContentWidth = 700.0;
                    final horizontalPadding =
                        constraints.maxWidth > maxContentWidth
                            ? (constraints.maxWidth - maxContentWidth) / 2
                            : 4.w;

                    return Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 2.h,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BiodataTheme.luxuryCardDecoration,
                                clipBehavior: Clip.antiAlias,
                                child: _pdfData != null
                                    ? RepaintBoundary(
                                        key: _previewKey,
                                        child: PdfPreview(
                                          build: (format) => _pdfData!,
                                          useActions: false,
                                          canChangePageFormat: false,
                                          canDebug: false,
                                          maxPageWidth: 400,
                                          padding: EdgeInsets.all(2.w),
                                          allowPrinting: false,
                                          allowSharing: false,
                                          pdfPreviewPageDecoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: AppColors.opacity10),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          scrollViewDecoration: const BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 5.h,
                                              height: 5.h,
                                              child: const CircularProgressIndicator(
                                                color: BiodataTheme.royalGold,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              AppLocalizations.of(context)?.generatingPreview ?? 'Generating preview...',
                                              style: BiodataTheme.bodyStyle.copyWith(
                                                fontSize: AppTypography.bodyLarge,
                                                color: BiodataTheme.deepCharcoal
                                                    .withValues(alpha: AppColors.opacity70),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              // ignore: dead_code
                              if (isLocked) EditorLockedOverlayWidget(
                                isProcessingPayment: _isProcessingPayment,
                                onUpgrade: _handleUpgrade,
                              ),
                              if (_isGeneratingPdf)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: AppColors.opacity30),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: BiodataTheme.royalGold.withValues(alpha: AppColors.opacity10),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (!isLocked) EditorBottomActionBar(
              canAct: _pdfData != null,
              onPrint: _handlePrint,
              onDownload: _handleDownload,
              onShare: _handleShare,
            ),
          ],
        ),
      ),
    );
  }

  String _getLoadingMessage() {
    switch (_loadingState) {
      case _LoadingState.initializing:
        return AppLocalizations.of(context)?.preparingBiodata ?? 'Preparing your biodata...';
      case _LoadingState.loadingProfile:
        return AppLocalizations.of(context)?.loadingProfile ?? 'Loading your profile...';
      case _LoadingState.loadingAssets:
        return AppLocalizations.of(context)?.loadingAssets ?? 'Loading assets...';
      case _LoadingState.ready:
        return AppLocalizations.of(context)?.ready ?? 'Ready';
      case _LoadingState.error:
        return AppLocalizations.of(context)?.error ?? 'Error';
    }
  }

  Widget _getTabContent(int index) {
    switch (index) {
      case 0:
        return EditorTemplatePickerWidget(
          selectedTemplate: _selectedTemplate,
          isPremiumUnlocked: _profile?.isPdfUnlocked ?? false,
          onTemplateSelected: (type) {
            setState(() => _selectedTemplate = type);
            _generatePdf();
          },
        );
      case 1:
        return EditorLanguagePickerWidget(
          selectedLanguage: _selectedLanguage,
          onLanguageSelected: (lang) {
            setState(() => _selectedLanguage = lang);
            _generatePdf();
          },
        );
      case 2:
        return RepaintBoundary(
          child: EditorDetailsWidget(
            content: _content!,
            controllers: _controllers,
            onContentChanged: _generatePdf,
            onContentUpdated: (updated) => _content = updated,
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> _handleShare() async {
    if (_pdfData == null) return;
    final tempLocalizations = AppLocalizations.of(context);

    try {
      final fileName =
          '${_content?.personalDetails['Full Name']?.replaceAll(' ', '_') ?? 'biodata'}.pdf';
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(_pdfData!);

      unawaited(_usageRepository.incrementPdfDownloadCount());
      unawaited(AnalyticsService.logEvent('pdf_download', parameters: {
        'template_type': _selectedTemplate.name,
        'action': 'share',
      }));

      await Share.shareXFiles([XFile(file.path)], text: tempLocalizations?.sharingBiodataPdf ?? 'Sharing Biodata PDF');
    } catch (e) {
      AppLogger.error('BiodataEditorScreen', 'Error sharing PDF: $e');
      if (mounted) {
        AppFeedback.showError(
          context,
          tempLocalizations?.failedToSharePdf ?? 'Failed to share PDF',
          contextTag: 'pdf',
        );
      }
    }
  }

  Future<void> _handlePrint() async {
    if (_pdfData == null) return;
    try {
      unawaited(_usageRepository.incrementPdfDownloadCount());
      unawaited(AnalyticsService.logEvent('pdf_download', parameters: {
        'template_type': _selectedTemplate.name,
        'action': 'print',
      }));

      await Printing.layoutPdf(
        onLayout: (format) => _pdfData!,
        name: _content?.personalDetails['Full Name'] ?? 'Biodata',
      );
    } catch (e) {
      AppLogger.error('BiodataEditorScreen', 'Error printing PDF: $e');
      if (mounted) {
        AppFeedback.showError(
          context,
          AppLocalizations.of(context)?.failedToPrintPdf ?? 'Failed to print PDF',
          contextTag: 'pdf',
        );
      }
    }
  }

  Future<void> _handleDownload() async {
    if (_pdfData == null) return;


    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName =
          'BanjaraBio_${_content?.personalDetails['Full Name']?.replaceAll(' ', '_') ?? 'Profile'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory!.path}/$fileName');

      await file.writeAsBytes(_pdfData!);

      unawaited(_usageRepository.incrementPdfDownloadCount());
      unawaited(AnalyticsService.logEvent('pdf_download', parameters: {
        'template_type': _selectedTemplate.name,
        'action': 'download',
      }));

      if (mounted) {
        AppFeedback.showSuccess(
          context,
          AppLocalizations.of(context)?.pdfSavedToDownloads(file.path) ?? 'PDF Saved to Downloads: ${file.path}',
        );
      }
    } catch (e) {
      AppLogger.error('BiodataEditorScreen', 'Error downloading PDF: $e');
      if (mounted) {
        AppFeedback.showError(
          context,
          e,
          contextTag: 'pdf',
          fallbackMessage: AppLocalizations.of(context)?.failedToSavePdf(''),
        );
      }
    }
  }



  Future<void> _handleUpgrade(PlanType planType) async {
    if (_isProcessingPayment) return;

    AppLogger.debug('BiodataEditorScreen', '[RAZORPAY] BiodataEditorScreen > User tapped Unlock now | planType=${planType.name}');
    setState(() => _isProcessingPayment = true);

    try {
      final response = await _razorpayRepository.startPayment(
        planType: planType,
      );

      if (mounted) {
        setState(() => _isProcessingPayment = false);

        if (response.isSuccess) {
          AppLogger.debug('BiodataEditorScreen', '[RAZORPAY] BiodataEditorScreen > Payment SUCCESS | refreshing profile from cache');
          AppFeedback.showSuccess(
            context,
            AppLocalizations.of(context)?.paymentSuccessful ?? 'Payment successful! Templates unlocked.',
          );
          // Use cache: RazorpayRepository already refreshed profile before completing.
          // Avoid forceRefresh here to prevent redundant network call that can fail
          // and show "Something went wrong" despite successful payment.
          _refreshProfileFromCacheAfterPayment();
        } else {
          AppLogger.error('BiodataEditorScreen', '[RAZORPAY] BiodataEditorScreen > Payment FAILED | ${response.errorMessage}');
          AppFeedback.showError(
            context,
            response.errorMessage,
            contextTag: 'subscription',
            fallbackMessage: AppLocalizations.of(context)?.paymentFailed(''),
          );
          // On timeout, webhook may have updated profile - try cache first
          if (response.errorMessage.toLowerCase().contains('timed out')) {
            _refreshProfileFromCacheAfterPayment();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        AppFeedback.showError(
          context,
          e,
          contextTag: 'subscription',
          fallbackMessage: AppLocalizations.of(context)?.unexpectedError(''),
        );
      }
    }
  }

  // Template picker, language picker, details editor, and section helpers
  // have been extracted to:
  //   - editor_template_picker_widget.dart
  //   - editor_language_picker_widget.dart
  //   - editor_details_widget.dart
  // Locked overlay extracted to editor_locked_overlay_widget.dart
  // Loading/error states extracted to editor_loading_state.dart
  // Bottom action bar extracted to editor_bottom_action_bar.dart
}


