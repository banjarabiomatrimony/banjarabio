import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/app_logo_service.dart';

/// Result of loading all assets needed for PDF generation.
class PdfAssets {
  const PdfAssets({
    this.logoBytes,
    this.profilePhotoBytes,
  });

  final Uint8List? logoBytes;
  final Uint8List? profilePhotoBytes;
}

/// Global service for PDF assets: logo (from app cache) and profile photo (fetch, no compression).
/// Use this everywhere PDF is generated so logo and photo loading are consistent and cacheable.
class PdfAssetsService {
  PdfAssetsService._();
  static final PdfAssetsService instance = PdfAssetsService._();

  static const Duration _photoTimeout = Duration(seconds: 12);
  static const int _maxPhotoCacheEntries = 2;

  final Map<String, Uint8List> _photoCache = {};

  /// Logo bytes from global cache (no compression).
  Future<Uint8List?> getLogoBytes() =>
      AppLogoService.instance.getLogoBytes();

  /// Profile photo bytes for first photo; no compression. Results cached by URL.
  Future<Uint8List?> getProfilePhotoBytes(ProfileModel? profile) async {
    if (profile == null || profile.photos.isEmpty) return null;
    final url = profile.photos.first.publicUrl;
    if (url.isEmpty) return null;
    final cached = _photoCache[url];
    if (cached != null) return cached;
    try {
      final data = await NetworkAssetBundle(Uri.parse(url))
          .load('')
          .timeout(
            _photoTimeout,
            onTimeout: () => throw TimeoutException('Profile photo load timeout'),
          );
      final bytes = data.buffer.asUint8List();
      if (_photoCache.length >= _maxPhotoCacheEntries) _photoCache.clear();
      _photoCache[url] = bytes;
      return bytes;
    } catch (e) {
      return null;
    }
  }

  /// Load logo + profile photo in one call. Use this for any PDF generation.
  Future<PdfAssets> getPdfAssets(ProfileModel? profile) async {
    // In tests, return empty assets immediately to avoid isolate/binding/asset loading issues.
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
      return const PdfAssets();
    }
    
    final results = await Future.wait([
      getLogoBytes(),
      getProfilePhotoBytes(profile),
    ]);
    return PdfAssets(
      logoBytes: results[0],
      profilePhotoBytes: results[1],
    );
  }
}
