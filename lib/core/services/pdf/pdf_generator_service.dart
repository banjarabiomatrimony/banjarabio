import 'dart:async';
import 'dart:isolate';

import 'package:banjarabio/core/models/biodata_content.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';
import 'package:banjarabio/core/services/pdf/biodata_font_manager.dart';
import 'package:banjarabio/core/services/pdf/biodata_font_preloader.dart';
import 'package:banjarabio/core/services/pdf/templates/biodata_template_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/app_logger.dart';

class PdfGenerationParams {
  final BiodataContent content;
  final BiodataTemplateType templateType;
  final String language;
  final Uint8List? logoBytes;
  final Uint8List? profilePhotoBytes;
  final Uint8List? templateImageBytes;
  final bool isLandscape;
  final bool isPremiumTemplate;
  final bool isPaid;
  final RootIsolateToken? rootIsolateToken;

  PdfGenerationParams({
    required this.content,
    required this.templateType,
    required this.language,
    this.logoBytes,
    this.profilePhotoBytes,
    this.templateImageBytes,
    required this.isLandscape,
    required this.isPremiumTemplate,
    required this.isPaid,
    this.rootIsolateToken,
  });
}

/// Request object meant for Isolate communication
class _PdfWorkerRequest {
  final int id;
  final PdfGenerationParams params;
  final TransferableTypedData? logoTransferable;
  final TransferableTypedData? photoTransferable;
  final TransferableTypedData? templateTransferable;

  _PdfWorkerRequest({
    required this.id,
    required this.params,
    this.logoTransferable,
    this.photoTransferable,
    this.templateTransferable,
  });
}

/// Response object from Isolate
class _PdfWorkerResponse {
  final int id;
  final TransferableTypedData? pdfData;
  final String? error;

  _PdfWorkerResponse({required this.id, this.pdfData, this.error});
}

/// Manages a persistent background isolate for PDF generation.
/// This prevents the overhead of spawning a new isolate for every generation request,
/// which is critical for "1 crore level" scale/stability.
class PdfIsolateManager {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  final Map<int, Completer<Uint8List>> _completers = {};
  int _requestIdCounter = 0;

  bool _isInitialized = false;
  Future<void>? _initFuture;

  Future<void> init() async {
    // 1. Check if already initialized and ready
    if (_isInitialized && _sendPort != null) return;

    // 2. Future Lock: Prevent concurrent initialization attempts
    // If init is already in progress, wait for the existing future
    if (_initFuture != null) {
      return _initFuture;
    }

    // 3. Start initialization
    _initFuture = _initializeIsolate();

    try {
      await _initFuture;
    } catch (e) {
      AppLogger.error('PdfGeneratorService', 'PdfIsolateManager init failed: $e');

      // Cleanup partial state if spawn failed
      _receivePort?.close();
      _receivePort = null;

      _initFuture = null; // Allow retry on failure
      _isInitialized = false;
      _sendPort = null;
      rethrow;
    }
  }

  Future<void> _initializeIsolate() async {
    final rootToken = RootIsolateToken.instance;
    final completer = Completer<void>();

    // Preload fonts in main isolate (avoids AssetManifest error in isolate)
    final fontBytes = await BiodataFontPreloader.loadAll();
    if (fontBytes.isEmpty) {
      throw StateError(
        'BiodataFontPreloader.loadAll() returned no fonts. '
        'Check network access.',
      );
    }

    _receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      _biodataIsolateEntry,
      _PdfInitMessage(_receivePort!.sendPort, rootToken, fontBytes),
      debugName: 'BiodataPdfIsolate',
    );

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isInitialized = true;
        if (!completer.isCompleted) {
          completer.complete();
        }
      } else if (message is _PdfWorkerResponse) {
        final completer = _completers.remove(message.id);
        if (completer != null) {
          if (message.error != null) {
            completer.completeError(message.error!);
          } else {
            completer.complete(message.pdfData!.materialize().asUint8List());
          }
        }
      }
    });

    // Wait until the isolate sends back its SendPort (fully ready)
    return completer.future;
  }

  Future<Uint8List> generate(PdfGenerationParams params) async {
    if (!_isInitialized || _sendPort == null) {
      // Fallback or auto-init? Better to fail or init.
      // If used without init, we try to init just in case.
      await init();
    }

    // 3. Backpressure Protection
    // Prevent flooding the isolate with too many requests ("1 crore scale" stability)
    if (_completers.length >= 5) {
      throw Exception(
        'Too many pending PDF generation requests. Please wait a moment.',
      );
    }

    final id = _requestIdCounter++;
    final completer = Completer<Uint8List>();
    _completers[id] = completer;

    // Zero-copy transfer optimization
    TransferableTypedData? logoTransferable;
    if (params.logoBytes != null) {
      logoTransferable = TransferableTypedData.fromList([params.logoBytes!]);
    }

    TransferableTypedData? photoTransferable;
    if (params.profilePhotoBytes != null) {
      photoTransferable = TransferableTypedData.fromList([
        params.profilePhotoBytes!,
      ]);
    }

    TransferableTypedData? templateTransferable;
    if (params.templateImageBytes != null) {
      templateTransferable = TransferableTypedData.fromList([
        params.templateImageBytes!,
      ]);
    }

    _sendPort!.send(
      _PdfWorkerRequest(
        id: id,
        params: params, // Params itself is small text data
        logoTransferable: logoTransferable,
        photoTransferable: photoTransferable,
        templateTransferable: templateTransferable,
      ),
    );

    // 2. Timeout safety for "1 crore scale" stability
    // If isolate crashes/hangs, we don't want UI to wait forever
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _completers.remove(id);
        throw TimeoutException('PDF generation timed out');
      },
    );
  }

  void dispose() {
    _sendPort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isInitialized = false;
    _receivePort?.close();
    _receivePort = null;
    // Cancel pending requests
    for (var completer in _completers.values) {
      completer.completeError('Isolate disposed');
    }
    _completers.clear();
  }
}

class _PdfInitMessage {
  final SendPort sendPort;
  final RootIsolateToken? token;
  final Map<String, Uint8List> fontBytes;
  _PdfInitMessage(this.sendPort, this.token, this.fontBytes);
}

/// Entry point for the persistent isolate
Future<void> _biodataIsolateEntry(_PdfInitMessage initMessage) async {
  final receivePort = ReceivePort();
  initMessage.sendPort.send(receivePort.sendPort);

  // Initialize platform channels ONCE
  if (initMessage.token != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(initMessage.token!);
  }

  // Pre-load common fonts if possible (optional optimization)
  // await BiodataFontManager.getFontForLanguage('English');

  // 1. Font Cache to avoid parsing assets on every request
  final Map<String, pw.Font> fontCache = {};

  receivePort.listen((message) async {
    if (message is _PdfWorkerRequest) {
      try {
        final stopwatch = Stopwatch()..start();
        final params = message.params;

        // Materialize images inside isolate
        Uint8List? logoBytes;
        if (message.logoTransferable != null) {
          logoBytes = message.logoTransferable!.materialize().asUint8List();
        }

        Uint8List? profilePhotoBytes;
        if (message.photoTransferable != null) {
          profilePhotoBytes = message.photoTransferable!
              .materialize()
              .asUint8List();
        }

        Uint8List? templateImageBytes;
        if (message.templateTransferable != null) {
          templateImageBytes = message.templateTransferable!
              .materialize()
              .asUint8List();
        }

        AppLogger.debug('PdfGeneratorService', '[PDF ISOLATE] Processing Request #${message.id}');

        // 1. Load fonts from pre-loaded bytes (no AssetManifest in isolate)
        final fontBytes = initMessage.fontBytes;
        final font =
            fontCache['${params.language}_regular'] ??
            BiodataFontManager.getFontForLanguageFromBytes(
              fontBytes,
              params.language,
            );
        fontCache['${params.language}_regular'] = font;

        final boldFont =
            fontCache['${params.language}_bold'] ??
            BiodataFontManager.getFontForLanguageFromBytes(
              fontBytes,
              params.language,
              bold: true,
            );
        fontCache['${params.language}_bold'] = boldFont;

        final mantraFont =
            fontCache['mantra'] ??
            BiodataFontManager.getMantraFontFromBytes(fontBytes);
        fontCache['mantra'] = mantraFont;

        // 2. Create template
        final template = BiodataTemplateFactory.createTemplate(
          type: params.templateType,
          content: params.content,
          language: params.language,
          font: font,
          boldFont: boldFont,
          mantraFont: mantraFont,
          templateImage: templateImageBytes != null && templateImageBytes.isNotEmpty
              ? pw.MemoryImage(templateImageBytes)
              : null,
          logo: logoBytes != null && logoBytes.isNotEmpty
              ? pw.MemoryImage(logoBytes)
              : null,
          profilePhoto: profilePhotoBytes != null && profilePhotoBytes.isNotEmpty
              ? pw.MemoryImage(profilePhotoBytes)
              : null,
          // Temp bypass for growth campaign: premium features are free, keep original check dormant.
          // In future, change to: params.isPremiumTemplate && !params.isPaid
          isLocked: false,
        );
        template.isLandscape = params.isLandscape;

        // 5. Generate
        final doc = await template.generate();
        final bytes = await doc.save();

        debugPrint(
          '[PDF ISOLATE] Request #${message.id} Success: ${stopwatch.elapsedMilliseconds}ms',
        );

        initMessage.sendPort.send(
          _PdfWorkerResponse(
            id: message.id,
            pdfData: TransferableTypedData.fromList([bytes]),
          ),
        );
      } catch (e, stack) {
        AppLogger.error('PdfGeneratorService', '[PDF ISOLATE] Request #${message.id} Failed: $e');
        AppLogger.debug('PdfGeneratorService', stack.toString());
        initMessage.sendPort.send(
          _PdfWorkerResponse(id: message.id, error: e.toString()),
        );
      }
    }
  });
}

// Keep the old service for backward compatibility if needed,
// but direct it to use the new manager approach or just keep simpler helper.
class PdfGeneratorService {
  // Static helper NOT recommended for persistent isolate usage
  // because we need to manage lifecycle.
  // Leaving this for legacy calls but marking deprecated.

  @Deprecated('Use PdfIsolateManager instead')
  static Future<Uint8List> generate(PdfGenerationParams params) async {
    // Falls back to compute for one-off calls
    final manager = PdfIsolateManager();
    await manager.init();
    try {
      final result = await manager.generate(params);
      manager.dispose();
      return result;
    } catch (e) {
      manager.dispose();
      rethrow;
    }
  }
}
