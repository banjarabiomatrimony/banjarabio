import 'dart:async';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/utils/startup_workflow.dart';

/// Authentication screen with Google Sign-In.
/// 
/// 🚀 10M DAU ARCHITECTURE:
/// - Flat widget tree (max depth ~8) to avoid O(n²) layout passes
/// - Zero 40px box shadows — GPU-friendly with max 8px blur
/// - No nested scroll views — single `SingleChildScrollView` only
/// - `RepaintBoundary` isolates the loading overlay from the static content
/// - `const` constructors wherever possible to reuse Element tree
class AuthenticationScreen extends StatefulWidget {
  /// When true, renders without Scaffold/SafeArea/background wrappers for
  /// embedding inside a parent layout (e.g., onboarding stepper PageView).
  final bool embedded;

  const AuthenticationScreen({super.key, this.embedded = false});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  bool _showEmailLogin = false;
  String? _errorMessage;
  bool _isHandlingAuth = false;
  /// Guards against stale Supabase session events (tokenRefreshed) that fire
  /// immediately on subscription. Only set to true when the user actively
  /// taps a login button on THIS screen instance.
  bool _userInitiatedLogin = false;
  String _loginType = kDebugMode ? 'Tester' : 'User';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StreamSubscription<AppAuthStatus>? _authSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint('AuthenticationScreen: initState start (embedded=${widget.embedded})');
    _setupAuthListener();
    debugPrint('AuthenticationScreen: initState complete');
  }

  void _setupAuthListener() {
    _authSubscription = _authRepository.authStateChanges.listen((status) {
      if (status == AppAuthStatus.authenticated) {
        // In embedded mode, only react to auth events that the user triggered
        // on THIS screen. Ignore stale/cached session events (tokenRefreshed).
        if (widget.embedded && !_userInitiatedLogin) {
          debugPrint('AuthenticationScreen: Ignoring stale auth event (embedded, no user action)');
          return;
        }
        _handleSuccessfulAuth();
      }
    });

    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTesterCredentials();
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateTesterCredentials() {
    if (!mounted || !kDebugMode) return;
    setState(() {
      if (_loginType == 'Tester') {
        _emailController.text = 'tester@banjarabio.com';
        _passwordController.text = 'Tester@123';
      } else {
        _emailController.clear();
        _passwordController.clear();
      }
    });
  }

  // ─── Auth Logic (unchanged, production-hardened) ───

  Future<void> _handleSuccessfulAuth() async {
    if (_isHandlingAuth || !mounted) return;
    _isHandlingAuth = true;

    try {
      final callbackRes = await _authRepository.handleAuthCallback();
      callbackRes.fold(
        onSuccess: (_) {},
        onFailure: (error) => debugPrint('Auth callback warning: $error'),
      );

      // 🚀 Logged in successfully -> Ensure guest mode is OFF
      await LocalCacheService().setGuestMode(false);

      final userId = AppSupabaseClient.currentUserId;
      if (userId != null) AnalyticsService.logLogin(userId);

      // Deep link intercept
      final pendingProfileId = LocalCacheService().getPendingProfileId();
      if (pendingProfileId != null) {
        await LocalCacheService().clearPendingProfileId();
        if (mounted) {
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed(AppRoutes.profileDetail, arguments: pendingProfileId);
        }
        return;
      }

      // 🚀 Use centralized navigation
      if (mounted) {
        await StartupWorkflow.navigateBasedOnStatus(context);
      }
    } catch (e) {
      debugPrint('Auth error: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushReplacementNamed(AppRoutes.authentication);
      }
    } finally {
      _isHandlingAuth = false;
    }
  }

  Future<void> _signInWithGoogle() async {
    _userInitiatedLogin = true;
    AnalyticsService.logSignUpStart('google');
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await _authRepository.signInWithGoogle();
      await response.fold(
        onSuccess: (_) {/* OAuth redirect — auth listener handles it */},
        onFailure: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = AppLocalizations.of(context)
                      ?.failedSignInGoogle(error.toString()) ??
                  'Failed to sign in with Google: $error';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)?.failedSignInGoogleRetry ??
              'Failed to sign in with Google. Please try again.';
        });
      }
    }
  }

  Future<void> _signInWithEmail() async {
    _userInitiatedLogin = true;
    AnalyticsService.logSignUpStart('email');

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage = AppLocalizations.of(context)
                ?.pleaseEnterBothEmailPassword ??
            'Please enter both email and password');
      }
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await _authRepository.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      await response.fold(
        onSuccess: (success) async {
          if (success) {
            await _handleSuccessfulAuth();
          } else {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = AppLocalizations.of(context)?.invalidEmailOrPassword ??
                    'Invalid email or password';
              });
            }
          }
        },
        onFailure: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.contains('Invalid login credentials')
                  ? (AppLocalizations.of(context)?.invalidEmailOrPassword ?? 'Invalid email or password')
                  : (AppLocalizations.of(context)?.loginFailed(error.toString()) ?? 'Login failed: $error');
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)?.loginFailedRetry ??
              'Login failed. Please try again.';
        });
      }
    }
  }

  // ─── UI (10M DAU optimized — flat tree, no heavy GPU ops) ───

  @override
  Widget build(BuildContext context) {
    debugPrint('AuthenticationScreen: build start');
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Core content stack shared by both standalone and embedded modes
    final coreStack = Stack(
            children: [
              // ── Main scrollable content ──
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),

                      // Logo — simple circle, no heavy shadow
                      Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: const AppLogoImage(),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Welcome text
                      Text(
                        l10n?.welcomeToBanjaraBio ?? 'Welcome to BanjaraBio',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        l10n?.connectWithCommunity ?? 'Connect with your Banjara community',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 5.h),

                      // Auth section — Google or Email
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Column(
                          children: [
                            if (!_showEmailLogin) _buildGoogleButton(theme, l10n),
                            if (_showEmailLogin) _buildEmailForm(theme, l10n),

                            SizedBox(height: 1.h),

                            // Toggle login method
                            TextButton(
                              onPressed: () => setState(() {
                                _showEmailLogin = !_showEmailLogin;
                                _errorMessage = null;
                              }),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showEmailLogin ? Icons.arrow_back : Icons.email_outlined,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  SizedBox(width: 1.w),
                                  Flexible(
                                    child: Text(
                                      _showEmailLogin
                                          ? (l10n?.backToGoogleSignIn ?? 'Back to Google Sign In')
                                          : (l10n?.useEmailPassword ?? 'Use Email / Password'),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Error message
                            if (_errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(top: 1.2.h),
                                child: Container(
                                  padding: EdgeInsets.all(1.2.h),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.error.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
                                      SizedBox(width: 2.w),
                                      Flexible(
                                        child: Text(
                                          _errorMessage!,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // "Why BanjaraBio?" divider
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: theme.dividerColor.withValues(alpha: 0.3))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Text(
                              l10n?.whyBanjaraBio ?? 'Why BanjaraBio?',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: theme.dividerColor.withValues(alpha: 0.3))),
                        ],
                      ),

                      SizedBox(height: 1.5.h),

                      // Benefits — lightweight cards, no heavy shadows
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildBenefit(theme, Icons.verified_user, l10n?.verified ?? 'Verified')),
                                SizedBox(width: 2.w),
                                Expanded(child: _buildBenefit(theme, Icons.security, l10n?.secure ?? 'Secure')),
                                SizedBox(width: 2.w),
                                Expanded(child: _buildBenefit(theme, Icons.touch_app, l10n?.quick ?? 'Quick')),
                              ],
                            ),
                            SizedBox(height: 0.8.h),
                            Row(
                              children: [
                                Expanded(child: _buildBenefit(theme, Icons.thumb_up, l10n?.easiest ?? 'Easiest')),
                                SizedBox(width: 2.w),
                                Expanded(child: _buildBenefit(theme, Icons.favorite, l10n?.trusted ?? 'Trusted')),
                                SizedBox(width: 2.w),
                                Expanded(child: _buildBenefit(theme, Icons.card_giftcard, l10n?.free ?? 'Free')),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Terms & privacy
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: l10n?.byContAcceptTerms ?? 'By continuing, you agree to our '),
                              TextSpan(
                                text: l10n?.terms ?? 'Terms',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: l10n?.and ?? ' and '),
                              TextSpan(
                                text: l10n?.privacyPolicy ?? 'Privacy Policy',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),

              // ── Loading Overlay (isolated via RepaintBoundary) ──
              if (_isLoading)
                RepaintBoundary(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );

    // Embedded mode: skip Scaffold/gradient/SafeArea wrappers
    if (widget.embedded) return coreStack;

    // Standalone mode: full-screen with gradient background
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(child: coreStack),
      ),
    );
  }

  // ─── Lightweight sub-widgets ───

  Widget _buildGoogleButton(ThemeData theme, AppLocalizations? l10n) {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        child: InkWell(
          onTap: _isLoading ? null : _signInWithGoogle,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: 2.5.h, height: 2.5.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/google_icon.png', width: 3.h, height: 3.h),
                      SizedBox(width: 1.5.h),
                      Flexible(
                        child: Text(
                          l10n?.continueWithGoogle ?? 'Continue with Google',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      children: [
        // Email field
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: l10n?.email ?? 'Email',
            hintText: l10n?.enterYourEmail ?? 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 1.5.h),

        // Password field
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: l10n?.password ?? 'Password',
            hintText: l10n?.enterYourPassword ?? 'Enter your password',
            prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          obscureText: true,
        ),
        SizedBox(height: 2.h),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 7.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signInWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 1,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 2.5.h, height: 2.5.h,
                    child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    l10n?.login ?? 'Login',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 1.5.h),

        // Debug: Login type selector
        if (kDebugMode)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _loginType,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                items: ['Tester', 'Admin', 'Staff'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type == 'Tester'
                              ? Icons.person
                              : type == 'Staff'
                                  ? Icons.badge_outlined
                                  : Icons.admin_panel_settings,
                          color: type == 'Tester'
                              ? Colors.blue
                              : type == 'Staff'
                                  ? Colors.green
                                  : Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 1.5.h),
                        Text(type, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        if (type == 'Tester') ...[
                          const Expanded(child: SizedBox()),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.demo ?? 'Demo',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _loginType = val!;
                    _emailController.clear();
                    _passwordController.clear();
                    if (val == 'Tester') {
                      _emailController.text = 'tester@banjarabio.com';
                      _passwordController.text = 'Tester@123';
                    } else if (val == 'Staff') {
                      _emailController.text = 'chinthakindibhavani@gmail.com';
                      _passwordController.text = 'Bhavani@123';
                    }
                  });
                },
              ),
            ),
          ),

        if (kDebugMode && _loginType == 'Admin')
          Padding(
            padding: EdgeInsets.only(top: 1.5.h),
            child: Container(
              padding: EdgeInsets.all(1.5.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.orange, size: 18),
                  SizedBox(width: 1.5.h),
                  Expanded(
                    child: Text(
                      l10n?.adminLoginRequiresAuthorizedCredentials ?? 'Admin login requires authorized credentials',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBenefit(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(0.8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
