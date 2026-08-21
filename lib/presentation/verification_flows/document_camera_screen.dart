import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// In-app Document Camera with real-time card guide overlay, auto-crop, and instant review.
class DocumentCameraScreen extends StatefulWidget {
  final String docType; // e.g. 'Aadhaar Card', 'PAN Card'
  final bool isFront; // true for Front, false for Back

  const DocumentCameraScreen({
    super.key,
    required this.docType,
    this.isFront = true,
  });

  @override
  State<DocumentCameraScreen> createState() => _DocumentCameraScreenState();
}

class _DocumentCameraScreenState extends State<DocumentCameraScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;

  // Animation for the subtle document scanner laser line
  late AnimationController _scannerAnimController;
  late Animation<double> _scannerAnimation;

  // State for previewing cropped photo
  File? _capturedCroppedFile;

  // Global key to measure the card viewport
  final GlobalKey _cardFrameKey = GlobalKey();
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scannerAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _scannerAnimController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        AppLogger.error('DocumentCameraScreen', 'No cameras found on device');
        return;
      }

      // Default to back camera
      final backCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(_flashMode);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      AppLogger.error('DocumentCameraScreen', 'Camera init error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerAnimController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
      default:
        nextMode = FlashMode.off;
        break;
    }
    try {
      await _cameraController!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
      HapticFeedback.selectionClick();
    } catch (e) {
      AppLogger.debug('DocumentCameraScreen', 'Flash toggle failed: $e');
    }
  }

  /// Pick from gallery fallback if user already has an image of their ID
  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (picked != null && mounted) {
        Navigator.of(context).pop(File(picked.path));
      }
    } catch (e) {
      AppLogger.error('DocumentCameraScreen', 'Gallery pick error: $e');
    }
  }

  /// Captures photo and automatically crops to the card viewport bounds
  Future<void> _captureDocument() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    HapticFeedback.heavyImpact();

    try {
      // 1. Take high-res picture
      final XFile rawPhoto = await _cameraController!.takePicture();

      // 2. Measure viewfinder geometry relative to preview widget
      final RenderBox? previewBox =
          _previewKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? cardBox =
          _cardFrameKey.currentContext?.findRenderObject() as RenderBox?;

      if (previewBox == null || cardBox == null) {
        // Fallback: return raw photo if measurement unavailable
        if (mounted) {
          setState(() {
            _capturedCroppedFile = File(rawPhoto.path);
            _isCapturing = false;
          });
        }
        return;
      }

      final previewSize = previewBox.size;
      final cardPos = cardBox.localToGlobal(Offset.zero, ancestor: previewBox);
      final cardSize = cardBox.size;

      // Viewfinder relative fractions (0.0 to 1.0)
      final leftRatio = (cardPos.dx / previewSize.width).clamp(0.0, 1.0);
      final topRatio = (cardPos.dy / previewSize.height).clamp(0.0, 1.0);
      final widthRatio = (cardSize.width / previewSize.width).clamp(0.0, 1.0);
      final heightRatio = (cardSize.height / previewSize.height).clamp(0.0, 1.0);

      // 3. Perform image cropping in background isolate
      final croppedFile = await compute(_cropImageTask, {
        'path': rawPhoto.path,
        'leftRatio': leftRatio,
        'topRatio': topRatio,
        'widthRatio': widthRatio,
        'heightRatio': heightRatio,
      });

      if (mounted) {
        setState(() {
          _capturedCroppedFile = croppedFile != null ? File(croppedFile) : File(rawPhoto.path);
          _isCapturing = false;
        });
      }
    } catch (e) {
      AppLogger.error('DocumentCameraScreen', 'Error capturing document: $e');
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  /// Background isolate image crop task
  static Future<String?> _cropImageTask(Map<String, dynamic> args) async {
    try {
      final String rawPath = args['path'];
      final double leftRatio = args['leftRatio'];
      final double topRatio = args['topRatio'];
      final double widthRatio = args['widthRatio'];
      final double heightRatio = args['heightRatio'];

      final rawBytes = await File(rawPath).readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) return rawPath;

      // Fix sensor rotation / EXIF orientation
      final oriented = img.bakeOrientation(decoded);

      // Add a small 2% margin to prevent accidental text cutoff
      const safetyMargin = 0.02;
      final cropLeft = (leftRatio - safetyMargin).clamp(0.0, 1.0);
      final cropTop = (topRatio - safetyMargin).clamp(0.0, 1.0);
      final cropWidth = (widthRatio + (safetyMargin * 2)).clamp(0.0, 1.0 - cropLeft);
      final cropHeight = (heightRatio + (safetyMargin * 2)).clamp(0.0, 1.0 - cropTop);

      final cropX = (cropLeft * oriented.width).round();
      final cropY = (cropTop * oriented.height).round();
      final cropW = (cropWidth * oriented.width).round();
      final cropH = (cropHeight * oriented.height).round();

      final cropped = img.copyCrop(
        oriented,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );

      final jpgBytes = img.encodeJpg(cropped, quality: 90);
      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/doc_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath);
      await outFile.writeAsBytes(jpgBytes);

      // Delete raw uncropped file to save disk space
      try {
        await File(rawPath).delete();
      } catch (_) {}

      return outPath;
    } catch (e) {
      debugPrint('Background crop failed: $e');
      return null;
    }
  }

  void _retake() {
    setState(() {
      _capturedCroppedFile = null;
    });
  }

  void _confirmAndUse() {
    if (_capturedCroppedFile != null) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(_capturedCroppedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAadhaar = widget.docType.toLowerCase().contains('aadhaar');
    final sideLabel = widget.isFront ? 'Front Side' : 'Back Side';
    final docTitle = '${widget.docType} ($sideLabel)';

    // If an image has been captured and cropped, show review UI
    if (_capturedCroppedFile != null) {
      return _buildReviewScreen(theme, docTitle);
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.categoryAstroDark),
              SizedBox(height: 2.h),
              Text(
                'Starting Document Camera...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          key: _previewKey,
          fit: StackFit.expand,
          children: [
            // 1. Live Camera Preview
            Center(
              child: CameraPreview(_cameraController!),
            ),

            // 2. Document Viewfinder Mask Painter (Darkened exterior + clear CR80 card cutout)
            LayoutBuilder(
              builder: (context, constraints) {
                // Standard ID-1 card aspect ratio (85.6mm / 53.98mm = 1.586)
                const cardRatio = 1.586;
                final cardWidth = constraints.maxWidth * 0.88;
                final cardHeight = cardWidth / cardRatio;
                final cardLeft = (constraints.maxWidth - cardWidth) / 2;
                final cardTop = (constraints.maxHeight - cardHeight) / 2 - (constraints.maxHeight * 0.05);

                final cardRect = Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight);

                return Stack(
                  children: [
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _DocumentOverlayPainter(cardRect: cardRect),
                    ),

                    // Card Viewfinder Frame Container for exact geometry measurement
                    Positioned(
                      key: _cardFrameKey,
                      left: cardLeft,
                      top: cardTop,
                      width: cardWidth,
                      height: cardHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            // Animated scan laser line
                            AnimatedBuilder(
                              animation: _scannerAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: cardHeight * _scannerAnimation.value,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.categoryAstroDark.withValues(alpha: 0.0),
                                          AppColors.categoryAstroDark,
                                          Colors.white,
                                          AppColors.categoryAstroDark,
                                          AppColors.categoryAstroDark.withValues(alpha: 0.0),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.categoryAstroDark.withValues(alpha: AppColors.opacity80),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Watermark / Guide icon in the center
                            Center(
                              child: Opacity(
                                opacity: 0.15,
                                child: Icon(
                                  isAadhaar ? Icons.credit_card_rounded : Icons.badge_rounded,
                                  size: 72,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Document Alignment Prompt directly below the card frame
                    Positioned(
                      top: cardTop + cardHeight + 2.h,
                      left: 4.w,
                      right: 4.w,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: AppColors.opacity70),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.categoryAstroDark.withValues(alpha: AppColors.opacity40),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.document_scanner_rounded, color: AppColors.categoryAstroDark, size: 18),
                                SizedBox(width: 2.w),
                                Text(
                                  'Fit $docTitle inside frame',
                                  style:                                   AppTypography.labelStyle(
                                    color: Colors.white,
                                    fontSize: AppTypography.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            'Hold steady • Avoid reflections & glare',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: AppTypography.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // 3. Top Action Bar (Close, Title Badge, Flash Toggle)
            Positioned(
              top: 1.h,
              left: 3.w,
              right: 3.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Title Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: AppColors.opacity70),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      docTitle,
                      style:                       AppTypography.labelStyle(
                        color: Colors.white,
                        fontSize: AppTypography.bodySmall,
                      ),
                    ),
                  ),

                  // Flash Toggle button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _flashMode != FlashMode.off
                            ? AppColors.categoryAstroDark.withValues(alpha: AppColors.opacity30)
                            : Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _flashMode != FlashMode.off
                              ? AppColors.categoryAstroDark
                              : Colors.white24,
                        ),
                      ),
                      child: Icon(
                        _flashMode == FlashMode.torch
                            ? Icons.flashlight_on_rounded
                            : (_flashMode == FlashMode.auto
                                ? Icons.flash_auto_rounded
                                : Icons.flash_off_rounded),
                        color: _flashMode != FlashMode.off ? AppColors.categoryAstroDark : Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),

            // 4. Bottom Controls (Shutter Button & Gallery Picker)
            Positioned(
              bottom: 3.h,
              left: 6.w,
              right: 6.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery fallback button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                    ),
                    tooltip: 'Upload from Gallery',
                    onPressed: _pickFromGallery,
                  ),

                  // Shutter Button
                  GestureDetector(
                    onTap: _captureDocument,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCapturing ? AppColors.categoryAstroDark : Colors.white,
                        ),
                        child: _isCapturing
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.black87,
                                size: 32,
                              ),
                      ),
                    ),
                  ),

                  // Empty spacer for symmetry
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Instant review screen showing the cropped ID document
  Widget _buildReviewScreen(ThemeData theme, String docTitle) {
    return Scaffold(
      backgroundColor: AppColors.canvasCharcoal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review $docTitle',
          style:           AppTypography.titleStyle(
            color: Colors.white,
            fontSize: AppTypography.headingSmall,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.categoryLocation,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _capturedCroppedFile!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.categoryLocation, size: 18),
                  SizedBox(width: 2.w),
                  Text(
                    'Auto-cropped & framed for verification',
                    style:                     AppTypography.bodyStyle(
                      color: Colors.white70,
                      fontWeight: AppTypography.semiBold,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // Action Buttons: Retake vs Use Document
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Row(
                children: [
                  // Retake Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      label: Text(
                        'Retake',
                        style:                         AppTypography.labelStyle(
                          color: Colors.white,
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                      onPressed: _retake,
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // Use Document Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.categoryLocation,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: Text(
                        'Use Document',
                        style:                         AppTypography.labelStyle(
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                      onPressed: _confirmAndUse,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that creates the darkened overlay with a clear rounded card cutout and corner brackets
class _DocumentOverlayPainter extends CustomPainter {
  final Rect cardRect;

  _DocumentOverlayPainter({required this.cardRect});

  @override
  void paint(Canvas canvas, Size size) {
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final cardRRect = RRect.fromRectAndRadius(cardRect, const Radius.circular(16));

    // 1. Dark background overlay with difference cutout
    final bgPath = Path()..addRect(screenRect);
    final cutoutPath = Path()..addRRect(cardRRect);
    final maskPath = Path.combine(PathOperation.difference, bgPath, cutoutPath);

    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.68)
      ..style = PaintingStyle.fill;
    canvas.drawPath(maskPath, bgPaint);

    // 2. Subtle white outline around the card
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: AppColors.opacity35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(cardRRect, borderPaint);

    // 3. High-contrast Golden/Amber Corner Brackets (⌜ ⌝ ⌞ ⌟)
    final cornerPaint = Paint()
      ..color = AppColors.categoryAstroDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;

    const cornerLength = 26.0;
    const r = 16.0;

    // Top-Left corner ⌜
    final tlPath = Path()
      ..moveTo(cardRect.left, cardRect.top + cornerLength)
      ..lineTo(cardRect.left, cardRect.top + r)
      ..arcToPoint(Offset(cardRect.left + r, cardRect.top), radius: const Radius.circular(r))
      ..lineTo(cardRect.left + cornerLength, cardRect.top);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right corner ⌝
    final trPath = Path()
      ..moveTo(cardRect.right - cornerLength, cardRect.top)
      ..lineTo(cardRect.right - r, cardRect.top)
      ..arcToPoint(Offset(cardRect.right, cardRect.top + r), radius: const Radius.circular(r))
      ..lineTo(cardRect.right, cardRect.top + cornerLength);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Left corner ⌞
    final blPath = Path()
      ..moveTo(cardRect.left, cardRect.bottom - cornerLength)
      ..lineTo(cardRect.left, cardRect.bottom - r)
      ..arcToPoint(Offset(cardRect.left + r, cardRect.bottom), radius: const Radius.circular(r))
      ..lineTo(cardRect.left + cornerLength, cardRect.bottom);
    canvas.drawPath(blPath, cornerPaint);

    // Bottom-Right corner ⌟
    final brPath = Path()
      ..moveTo(cardRect.right - cornerLength, cardRect.bottom)
      ..lineTo(cardRect.right - r, cardRect.bottom)
      ..arcToPoint(Offset(cardRect.right, cardRect.bottom - r), radius: const Radius.circular(r))
      ..lineTo(cardRect.right, cardRect.bottom - cornerLength);
    canvas.drawPath(brPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _DocumentOverlayPainter oldDelegate) {
    return oldDelegate.cardRect != cardRect;
  }
}
