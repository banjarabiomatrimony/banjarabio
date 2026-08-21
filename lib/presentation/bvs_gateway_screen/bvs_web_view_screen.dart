import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                      color: Colors.black.withValues(alpha: AppColors.opacity20),
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
                      style: TextStyle(
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.headingSmall,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        const Icon(Icons.lock_rounded, size: 10, color: Colors.greenAccent),
                        const SizedBox(width: 4),
                        Text(
                          'banjaravirasat.org.in',
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: Colors.white70,
                            fontWeight: AppTypography.medium,
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
                colors: [AppColors.maroonAccent, AppColors.crimsonDeep, AppColors.error],
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
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.categoryVip),
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
                          color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 54,
                          color: AppColors.crimsonDeep,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'वेबपेज लोड करण्यात अडचण आली',
                        style: TextStyle(
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        SizedBox(height: 1.h),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      SizedBox(height: 2.5.h),
                      TactilePressable(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _hasError = false);
                          _controller.reload();
                        },
                        pressedScale: 0.95,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.crimsonDeep, AppColors.maroonAccent],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'पुन्हा प्रयत्न करा (Retry)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: AppTypography.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  color: isDark
                      ? theme.scaffoldBackgroundColor.withValues(alpha: 0.94)
                      : Colors.white.withValues(alpha: 0.92),
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
                                  color: Colors.amber.withValues(alpha: AppColors.opacity40),
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
                        Text(
                          'अधिकृत BVS पोर्टल उघडत आहे...',
                          style: TextStyle(
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: AppTypography.bold,
                            color: isDark ? AppColors.categoryVip : AppColors.wineDark,
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
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: AppColors.categoryVip.withValues(alpha: isDark ? 0.3 : 0.5),
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
                      color: isDark ? AppColors.amberBgDark : AppColors.goldLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 1.2),
                    ),
                    child: const Icon(
                      Icons.card_membership_rounded,
                      color: AppColors.crimsonDeep,
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
                          style: TextStyle(
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.bodyLarge,
                            color: isDark ? AppColors.primaryDarkContrast : AppColors.wineDark,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'नोंदणीनंतर कार्ड अपलोड करून ₹२००/वर्ष सवलत मिळवा',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: AppTypography.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ScaleTransition(
                    scale: _pulseScale,
                    child: TactilePressable(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.communityIdVerification,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.crimsonDeep, AppColors.maroonAccent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.categoryVip, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity40),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.upload_file_rounded, size: 16, color: Colors.amberAccent),
                            const SizedBox(width: 5),
                            Text(
                              'कार्ड अपलोड',
                              style: TextStyle(
                                fontWeight: AppTypography.bold,
                                fontSize: AppTypography.bodyMedium,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }
}
