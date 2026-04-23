import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/pdf_assets_service.dart';
import 'package:banjarabio/core/models/biodata_content.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/services/pdf/pdf_generator_service.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/biodata_ui_helpers.dart';
import 'package:banjarabio/core/services/pdf/biodata_translations.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

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
  final PdfIsolateManager _pdfManager = PdfIsolateManager();

  // State
  ProfileModel? _profile;
  BiodataContent? _content;
  BiodataTemplateType _selectedTemplate = BiodataTemplateType.simple;
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
              debugPrint('[RAZORPAY] BiodataEditorScreen > Profile refreshed from cache | isPdfUnlocked=${profile.isPdfUnlocked}');
            } else if (mounted) {
              _loadData(forceRefreshProfile: true);
            }
          },
          onFailure: (_) {
            if (mounted) _loadData(forceRefreshProfile: true);
          },
        );
      } catch (e) {
        debugPrint('[RAZORPAY] BiodataEditorScreen > Cache refresh failed | $e');
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
      debugPrint('Error in _loadData: $e');
      debugPrint('Stack trace: $stackTrace');
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
          debugPrint('Error loading template image: $e');
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
        debugPrint('Error generating PDF: $e');
        debugPrint('Stack trace: $stackTrace');
        if (mounted) {
          setState(() => _isGeneratingPdf = false);
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.previewGenerationFailed ?? 'Preview generation failed. Please try again.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
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
                    ? _buildErrorState()
                    : _buildLoadingState(),
              ),
            ),
          ),
        ),
      );
    }

    final bool isLocked =
        _selectedTemplate.isPremium && !(_profile?.isPdfUnlocked ?? false);

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
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
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
                                color: Colors.black.withValues(alpha: 0.1),
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
                            unselectedLabelColor: BiodataTheme.deepCharcoal.withValues(alpha: 0.6),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
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
                                                color: Colors.black.withValues(alpha: 0.1),
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
                                                fontSize: 13.sp,
                                                color: BiodataTheme.deepCharcoal
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              if (isLocked) _buildLockedOverlay(),
                              if (_isGeneratingPdf)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: BiodataTheme.royalGold.withValues(alpha: 0.1),
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
            if (!isLocked) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// Fixed action bar (Print, Download, Share) at bottom - always visible without scroll.
  Widget _buildBottomActionBar() {
    final theme = Theme.of(context);
    final canAct = _pdfData != null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.print_rounded,
              label: AppLocalizations.of(context)?.printBtn ?? 'Print',
              onTap: canAct ? _handlePrint : null,
            ),
            _buildActionButton(
              icon: Icons.download_rounded,
              label: AppLocalizations.of(context)?.downloadBtn ?? 'Download',
              onTap: canAct ? _handleDownload : null,
            ),
            _buildActionButton(
              icon: Icons.share_rounded,
              label: AppLocalizations.of(context)?.shareBtn ?? 'Share',
              onTap: canAct ? _handleShare : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final disabled = onTap == null;
    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: disabled
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(height: 0.4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: disabled
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
            ),
          ),
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

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
      decoration: BiodataTheme.sectionCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade400,
            size: 56.sp,
          ),
          SizedBox(height: 2.h),
          Text(
            AppLocalizations.of(context)?.somethingWentWrong ?? 'Something went wrong',
            style: BiodataTheme.subHeaderStyle.copyWith(
              fontSize: 16.sp,
              color: BiodataTheme.deepCharcoal,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            _errorMessage ?? (AppLocalizations.of(context)?.couldNotLoadProfile ?? 'We couldn\'t load your profile. Please try again.'),
            style: BiodataTheme.bodyStyle.copyWith(
              fontSize: 13.sp,
              color: BiodataTheme.deepCharcoal.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.5.h),
          SizedBox(
            height: 6.h,
            child: FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(AppLocalizations.of(context)?.tryAgain ?? 'Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: BiodataTheme.royalGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 6.h,
          height: 6.h,
          child: const CircularProgressIndicator(
            color: BiodataTheme.royalGold,
            strokeWidth: 2.5,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _getLoadingMessage(),
          style: BiodataTheme.bodyStyle.copyWith(
            fontSize: 14.sp,
            color: BiodataTheme.deepCharcoal.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _getTabContent(int index) {
    switch (index) {
      case 0:
        return _buildTemplatePicker();
      case 1:
        return _buildLanguagePicker();
      case 2:
        return RepaintBoundary(child: _buildDetailsEditor());
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

      await Share.shareXFiles([XFile(file.path)], text: tempLocalizations?.sharingBiodataPdf ?? 'Sharing Biodata PDF');
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: tempLocalizations?.failedToSharePdf ?? 'Failed to share PDF',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _handlePrint() async {
    if (_pdfData == null) return;
    try {
      await Printing.layoutPdf(
        onLayout: (format) => _pdfData!,
        name: _content?.personalDetails['Full Name'] ?? 'Biodata',
      );
    } catch (e) {
      debugPrint('Error printing PDF: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.failedToPrintPdf ?? 'Failed to print PDF',
          backgroundColor: Colors.red,
          textColor: Colors.white,
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.pdfSavedToDownloads(file.path) ?? 'PDF Saved to Downloads: ${file.path}'),
            action: SnackBarAction(label: AppLocalizations.of(context)?.ok ?? 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.failedToSavePdf(e.toString()) ?? 'Failed to save PDF: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  IconData _getSectionIcon(String title) {
    title = title.toLowerCase();
    if (title.contains('personal')) return Icons.person_outline_rounded;
    if (title.contains('family')) return Icons.favorite_outline_rounded;
    if (title.contains('education') || title.contains('career')) {
      return Icons.work_outline_rounded;
    }
    if (title.contains('horoscope')) return Icons.auto_awesome_rounded;
    if (title.contains('marriage')) return Icons.church_rounded;
    if (title.contains('contact')) return Icons.contact_phone_outlined;
    return Icons.edit_note_rounded;
  }

  Widget _buildLockedOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: BiodataTheme.deepCharcoal.withValues(alpha: 0.4),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: BiodataTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(BiodataTheme.radiusLg),
              boxShadow: [
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15), // Replaced BiodataTheme.deepCharcoal.withValues(alpha: 0.15) for const if possible, but actually BiodataTheme properties might not be const.
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  color: BiodataTheme.royalGold,
                  size: 80, // Approximate sp
                ),
                SizedBox(height: 1.5.h),
                Text(
                  AppLocalizations.of(context)?.premiumTemplate ?? 'Premium Template',
                  style: BiodataTheme.subHeaderStyle.copyWith(
                    fontSize: 16.sp,
                    color: BiodataTheme.deepCharcoal,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  AppLocalizations.of(context)?.unlockToDownload ?? 'Unlock to download and share this template in 5+ languages.',
                  textAlign: TextAlign.center,
                  style: BiodataTheme.bodyStyle.copyWith(
                    fontSize: 13.sp,
                    color: BiodataTheme.deepCharcoal.withValues(alpha: 0.65),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  height: 6.h,
                  child: FilledButton(
                    onPressed: _isProcessingPayment
                        ? null
                        : () => _handleUpgrade(PlanType.biodata_unlock),
                    style: FilledButton.styleFrom(
                      backgroundColor: BiodataTheme.royalGold,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                    ),
                    child: _isProcessingPayment
                        ? SizedBox(
                            height: 2.5.h,
                            width: 2.5.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                          )
                        : Text(AppLocalizations.of(context)?.unlockNow ?? 'Unlock now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpgrade(PlanType planType) async {
    if (_isProcessingPayment) return;

    debugPrint('[RAZORPAY] BiodataEditorScreen > User tapped Unlock now | planType=${planType.name}');
    setState(() => _isProcessingPayment = true);

    try {
      final response = await _razorpayRepository.startPayment(
        planType: planType,
      );

      if (mounted) {
        setState(() => _isProcessingPayment = false);

        if (response.isSuccess) {
          debugPrint('[RAZORPAY] BiodataEditorScreen > Payment SUCCESS | refreshing profile from cache');
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.paymentSuccessful ?? 'Payment successful! Templates unlocked.',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // Use cache: RazorpayRepository already refreshed profile before completing.
          // Avoid forceRefresh here to prevent redundant network call that can fail
          // and show "Something went wrong" despite successful payment.
          _refreshProfileFromCacheAfterPayment();
        } else {
          debugPrint('[RAZORPAY] BiodataEditorScreen > Payment FAILED | ${response.errorMessage}');
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.paymentFailed(response.errorMessage) ?? 'Payment failed: ${response.errorMessage}',
            backgroundColor: Colors.red,
            textColor: Colors.white,
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
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.unexpectedError(e.toString()) ?? 'An unexpected error occurred: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Widget _buildTemplatePicker() {
    final bool isPremiumUnlocked = _profile?.isPdfUnlocked ?? false;

    return SizedBox(
      // Slightly more compact cards, but still readable.
      height: 18.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: kBiodataTemplates.length,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemBuilder: (context, index) {
          final template = kBiodataTemplates[index];
          final type = template.type;
          final isSelected = _selectedTemplate == type;
          final isLockedTemplate = type.isPremium && !isPremiumUnlocked;

          return Padding(
            padding: EdgeInsets.only(right: 2.4.w),
            child: Semantics(
              label:
                  '${type.displayName} template${type.isPremium ? ', Premium' : ''}${isLockedTemplate ? ', locked' : ''}',
              selected: isSelected,
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(BiodataTheme.radiusLg),
                  onTap: () {
                    setState(() => _selectedTemplate = type);
                    _generatePdf();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 30.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.2.w,
                      vertical: 1.0.h,
                    ),
                    decoration: BoxDecoration(
                      color: BiodataTheme.surfaceWhite,
                      borderRadius:
                          BorderRadius.circular(BiodataTheme.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? BiodataTheme.royalGold
                            : BiodataTheme.deepCharcoal.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color.fromRGBO(212, 175, 55, 0.25),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ]
                          : const [
                              BoxShadow(
                                color: Color.fromRGBO(30, 30, 30, 0.04),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(BiodataTheme.radiusSm),
                            child: Image.asset(
                              template.assetPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(BiodataTheme.radiusSm),
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          // Template name stacked on the preview
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BiodataTheme.captionStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguagePicker() {
    final languages = ['English', 'Hindi', 'Marathi', 'Telugu', 'Kannada'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
          child: Text(AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
            style: BiodataTheme.subHeaderStyle.copyWith(
              color: const Color.fromRGBO(26, 26, 26, 0.85),
            ),
          ),
        ),
        SizedBox(
          height: 6.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = _selectedLanguage == lang;
              return Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: Semantics(
                  label: 'Language: $lang',
                  selected: isSelected,
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!isSelected) {
                          setState(() => _selectedLanguage = lang);
                          _generatePdf();
                        }
                      },
                      borderRadius: BorderRadius.circular(BiodataTheme.radiusPill),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        constraints: const BoxConstraints(minWidth: 48),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected ? BiodataTheme.goldGradient : null,
                          color: isSelected ? null : BiodataTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(BiodataTheme.radiusPill),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color.fromRGBO(212, 175, 55, 0.25),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: BiodataTheme.royalGold.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: BiodataTheme.deepCharcoal.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Text(
                          lang,
                          style: BiodataTheme.subHeaderStyle.copyWith(
                            color: isSelected
                                ? Colors.white
                                : BiodataTheme.deepCharcoal,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _buildDetailsEditor() {
    if (_content == null) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditSection('Personal Details', _content!.personalDetails),
        _buildEditSection(
          'Education & Profession',
          _content!.educationProfession,
        ),
        _buildEditSection('Family Details', _content!.familyDetails),
        _buildEditSection('Location & Contact', _content!.locationContact),
        _buildMultilineEdit('Partner Expectations', 'partnerExpectations'),
        _buildMultilineEdit('About Me', 'aboutMe'),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildEditSection(String title, Map<String, String> data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        decoration: BiodataTheme.sectionCardDecoration(),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(
              _getSectionIcon(title),
              color: BiodataTheme.royalGold,
              size: 22.sp,
            ),
            title: Text(
              title,
              style: BiodataTheme.subHeaderStyle.copyWith(
                fontSize: 14.sp,
                color: BiodataTheme.deepCharcoal,
              ),
            ),
            iconColor: BiodataTheme.royalGold,
            collapsedIconColor: BiodataTheme.deepCharcoal.withValues(alpha: 0.5),
            childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            children: data.keys.map((key) {
              return Padding(
                padding: EdgeInsets.only(bottom: 1.2.h),
                child: TextField(
                  controller: _controllers[key],
                  decoration: BiodataTheme.inputDecoration(labelText: key),
                  onChanged: (value) {
                    data[key] = value;
                    _generatePdf();
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMultilineEdit(String title, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BiodataTheme.sectionCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getSectionIcon(title),
                  color: BiodataTheme.royalGold,
                  size: 22.sp,
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: BiodataTheme.subHeaderStyle.copyWith(
                    fontSize: 14.sp,
                    color: BiodataTheme.deepCharcoal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            TextField(
              controller: _controllers[key],
              maxLines: 4,
              decoration: BiodataTheme.inputDecoration(labelText: title).copyWith(
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) {
                if (key == 'partnerExpectations') {
                  _content = _content!.copyWith(partnerExpectations: value);
                } else if (key == 'aboutMe') {
                  _content = _content!.copyWith(aboutMe: value);
                }
                _generatePdf();
              },
            ),
          ],
        ),
      ),
    );
  }
}
