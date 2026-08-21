import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/pdf_assets_service.dart';
import 'package:banjarabio/core/services/pdf_service.dart';
import 'package:banjarabio/core/services/pdf/biodata_font_preloader.dart';
import 'package:banjarabio/core/session_manager.dart';

/// ⚡ [BiodataPreloadService]
///
/// Background preloader for Biodata Studio.
/// Pre-warms the profile, template assets, candidate photos, fonts, and pre-renders
/// the default high-resolution A4 Biodata PDF in a background Isolate
/// right after first frame rendering so the Biodata tab opens in 0.00 seconds.
class BiodataPreloadService {
  BiodataPreloadService._();
  static final BiodataPreloadService instance = BiodataPreloadService._();

  ProfileModel? _cachedProfile;
  Uint8List? _cachedPdfData;
  final Map<String, Uint8List> _templateImageCache = {};
  bool _isPreloading = false;
  bool _isReady = false;

  ProfileModel? get cachedProfile => _cachedProfile;
  Uint8List? get cachedPdfData => _cachedPdfData;
  Map<String, Uint8List> get templateImageCache => _templateImageCache;
  bool get isPreloading => _isPreloading;
  bool get isReady => _isReady;

  /// Update cached PDF data from active UI if user changes template/language
  void updateCachedPdf(Uint8List pdfData) {
    _cachedPdfData = pdfData;
    _isReady = true;
  }

  /// Invalidate cache when profile is edited
  void invalidate() {
    _cachedPdfData = null;
    _isReady = false;
  }

  /// Preload template asset image into memory
  Future<Uint8List?> loadTemplateImage(String assetPath) async {
    final cached = _templateImageCache[assetPath];
    if (cached != null) return cached;

    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      _templateImageCache[assetPath] = bytes;
      return bytes;
    } catch (e) {
      AppLogger.error('BiodataPreloadService', 'Error loading template image $assetPath: $e');
      return null;
    }
  }

  /// Run full background prewarm pipeline
  Future<void> preload({bool force = false}) async {
    if (_isPreloading) return;
    if (_isReady && !force && _cachedPdfData != null) return;

    // Skip prewarm for guests or non-logged in users
    if (!SessionManager.instance.isLoggedIn || LocalCacheService().isGuestMode()) {
      AppLogger.debug('BiodataPreloadService', '⏩ Skipping Biodata preload for guest/logged-out session');
      return;
    }

    _isPreloading = true;
    AppLogger.debug('BiodataPreloadService', '🚀 [PRELOAD] Starting Biodata background prewarm pipeline...');

    try {
      // 1. Preload local & regional fonts immediately
      final fontBytes = await BiodataFontPreloader.loadAll();

      // 2. Fetch Profile (Memory / Disk / API)
      ProfileModel? profile;
      final cachedJson = LocalCacheService().getOwnProfile();
      if (cachedJson != null) {
        try {
          profile = ProfileModel.fromJson(cachedJson);
        } catch (_) {}
      }

      if (profile == null) {
        final profileRes = await ProfileRepository().getOwnProfile();
        profileRes.fold(
          onSuccess: (p) => profile = p,
          onFailure: (_) {},
        );
      }

      final currentProfile = profile;
      if (currentProfile == null) {
        _isPreloading = false;
        return;
      }
      _cachedProfile = currentProfile;

      // 3. Pre-cache Top Template Images in Memory
      final defaultTemplate = kBiodataTemplates[0];
      final templateBytes = await loadTemplateImage(defaultTemplate.assetPath);
      for (int i = 1; i < math.min(4, kBiodataTemplates.length); i++) {
        loadTemplateImage(kBiodataTemplates[i].assetPath);
      }

      // 4. Pre-fetch Logo & Candidate Photo
      final assets = await PdfAssetsService.instance.getPdfAssets(currentProfile);

      // 5. Pre-compile PDF in Background Isolate
      final pdfBytes = await PdfService.generateBiodataPdfIsolate(
        currentProfile,
        isLocked: false,
        logoBytes: assets.logoBytes,
        profilePhotoBytes: assets.profilePhotoBytes,
        templateImageBytes: templateBytes,
        accentColor: defaultTemplate.accentColor,
        marginLeft: defaultTemplate.marginLeft,
        marginTop: defaultTemplate.marginTop,
        marginRight: defaultTemplate.marginRight,
        marginBottom: defaultTemplate.marginBottom,
        headerMantra: '॥ जय सेवालाल ॥   ॥ श्री गणेशाय नमः ॥',
        fontBytes: fontBytes,
      );

      _cachedPdfData = pdfBytes;
      _isReady = true;
      AppLogger.info('BiodataPreloadService', '✅ [PRELOAD] Biodata PDF preloaded & cached successfully in background (${pdfBytes.lengthInBytes} bytes)');
    } catch (e) {
      AppLogger.error('BiodataPreloadService', 'Error during Biodata background preload: $e');
    } finally {
      _isPreloading = false;
    }
  }
}
