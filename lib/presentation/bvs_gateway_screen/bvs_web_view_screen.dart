import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/routes/app_routes.dart';

class BvsWebViewScreen extends StatefulWidget {
  final String? initialUrl;

  const BvsWebViewScreen({
    super.key,
    this.initialUrl,
  });

  @override
  State<BvsWebViewScreen> createState() => _BvsWebViewScreenState();
}

class _BvsWebViewScreenState extends State<BvsWebViewScreen>
    with TickerProviderStateMixin {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasError = false;
  String? _errorMessage;
  bool _canGoBack = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  late AnimationController _dockController;
  late Animation<Offset> _dockSlide;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dockSlide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _dockController, curve: Curves.easeOutCubic));

    _dockController.forward();

    final urlToLoad = widget.initialUrl ??
        'https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=mr';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                if (progress == 100) {
                  _hasError = false;
                }
              });
              _updateNavState();
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _loadingProgress = 15;
                _hasError = false;
              });
              _updateNavState();
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _loadingProgress = 100;
              });
              _updateNavState();
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted && error.isForMainFrame == true) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(urlToLoad));
  }

  Future<void> _updateNavState() async {
    final canBack = await _controller.canGoBack();
    if (mounted) {
      setState(() {
        _canGoBack = canBack;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dockController.dispose();
    super.dispose();
  }

  Future<void> _handleBackPress() async {
    HapticFeedback.lightImpact();
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleText = l10n?.bvsTitle ?? 'बणजारा विरासत संघ';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amberAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/bvs_logo_gold.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Row(
                      children: [
                        Icon(Icons.lock_rounded, size: 10, color: Colors.greenAccent),
                        SizedBox(width: 4),
                        Text(
                          'banjaravirasat.org.in',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(
              _canGoBack ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: _canGoBack ? 'Previous Page' : 'Back',
            onPressed: _handleBackPress,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              tooltip: 'Close',
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 4),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5A000F), Color(0xFF8B1A2E), Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 3,
          bottom: _loadingProgress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    minHeight: 3,
                  ),
                )
              : null,
        ),
        body: Stack(
          children: [
            if (_hasError)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B1A2E).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 54,
                          color: Color(0xFF8B1A2E),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      const Text(
                        'वेबपेज लोड करण्यात अडचण आली',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (_errorMessage != null) ...[
                        SizedBox(height: 1.h),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                      SizedBox(height: 2.5.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _hasError = false);
                          _controller.reload();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B1A2E),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('पुन्हा प्रयत्न करा (Retry)'),
                      ),
                    ],
                  ),
                ),
              )
            else
              WebViewWidget(controller: _controller),

            // Shimmer Cultural Loading State while progress < 50
            if (_loadingProgress > 0 && _loadingProgress < 50 && !_hasError)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.92),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _pulseScale,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/bvs_logo_gold.png',
                                width: 56,
                                height: 56,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        const Text(
                          'अधिकृत BVS पोर्टल उघडत आहे...',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B0E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SlideTransition(
          position: _dockSlide,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.3.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 1.2),
                    ),
                    child: const Icon(
                      Icons.card_membership_rounded,
                      color: Color(0xFF5A000F),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.bvsMembershipCard ?? 'BVS ओळखपत्र',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF6B0E1E),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'नोंदणीनंतर कार्ड अपलोड करून ₹२००/वर्ष सवलत मिळवा',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ScaleTransition(
                    scale: _pulseScale,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.communityIdVerification,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1A2E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
                        elevation: 3,
                        shadowColor: const Color(0xFF8B1A2E).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file_rounded, size: 16, color: Colors.amberAccent),
                      label: const Text(
                        'कार्ड अपलोड',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
