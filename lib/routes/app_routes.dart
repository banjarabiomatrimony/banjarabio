import 'package:flutter/material.dart';

import 'package:banjarabio/core/animations/premium_page_route.dart';
import 'package:banjarabio/presentation/authentication_screen/authentication_screen.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/biodata_creation_screen.dart';
import 'package:banjarabio/presentation/biodata_screen/biodata_screen.dart';
import 'package:banjarabio/presentation/filter_screen/filter_screen.dart';
import 'package:banjarabio/presentation/main_navigation_screen/main_navigation_screen.dart';
import 'package:banjarabio/presentation/self_profile_screen/self_profile_screen.dart';
import 'package:banjarabio/presentation/photo_management_screen/widgets/photo_management_screen.dart';
import 'package:banjarabio/presentation/match_profile_screen/match_profile_screen.dart';
import 'package:banjarabio/presentation/shared_profiles_screen/shared_profiles_screen.dart';
import 'package:banjarabio/presentation/splash_screen/splash_screen.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/biodata_editor_screen.dart';
import 'package:banjarabio/presentation/subscription_screen/subscription_screen.dart';
import 'package:banjarabio/presentation/account_screen/account_screen.dart';
import 'package:banjarabio/presentation/settings_screen/settings_screen.dart';
import 'package:banjarabio/presentation/ads/premium_gate_screen.dart';
import 'package:banjarabio/presentation/saved_profiles_screen/saved_profiles_screen.dart';
import 'package:banjarabio/presentation/chat/conversation_list_screen.dart';
import 'package:banjarabio/presentation/chat/chat_screen.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/presentation/analytics/who_viewed_me_screen.dart';
import 'package:banjarabio/presentation/static_pages/contact_us_screen.dart';
import 'package:banjarabio/presentation/static_pages/terms_conditions_screen.dart';
import 'package:banjarabio/presentation/static_pages/privacy_policy_screen.dart';
import 'package:banjarabio/presentation/static_pages/account_deletion_screen.dart';
import 'package:banjarabio/presentation/static_pages/faq_screen.dart';
import 'package:banjarabio/presentation/trust_score_screen/trust_score_screen.dart';
import 'package:banjarabio/presentation/verification_flows/mobile_verification_screen.dart';
import 'package:banjarabio/presentation/verification_flows/email_verification_screen.dart';
import 'package:banjarabio/presentation/verification_flows/live_selfie_screen.dart';
import 'package:banjarabio/presentation/verification_flows/govt_id_verification_screen.dart';
import 'package:banjarabio/presentation/verification_flows/community_id_screen.dart';
import 'package:banjarabio/presentation/verification_flows/reference_verification_screen.dart';
import 'package:banjarabio/presentation/verification_flows/video_intro_screen.dart';
import 'package:banjarabio/presentation/admin_screen/admin_dashboard_screen.dart';
import 'package:banjarabio/presentation/staff_screen/staff_dashboard_screen.dart';
import 'package:banjarabio/presentation/referral_screen/referral_invite_screen.dart';

import 'package:banjarabio/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:banjarabio/presentation/onboarding_screen/relative_intake_screen.dart';
import 'package:banjarabio/presentation/initial_language_screen/initial_language_screen.dart';
import 'package:banjarabio/presentation/onboarding_selection_screen/onboarding_selection_screen.dart';
import 'package:banjarabio/presentation/user_type_selection_screen/user_type_selection_screen.dart';
import 'package:banjarabio/notification/widgets/activity_hub_screen.dart';
import 'package:banjarabio/presentation/bvs_gateway_screen/bvs_gateway_screen.dart';
import 'package:banjarabio/presentation/bvs_gateway_screen/bvs_web_view_screen.dart';
import 'package:banjarabio/presentation/services_screen/services_screen.dart';
import 'package:banjarabio/presentation/inbox_screen/inbox_screen.dart';
import 'package:banjarabio/presentation/vendor_registration_screen/vendor_registration_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/';
  static const String userTypeSelection = '/user-type-selection';
  static const String bvsGateway = '/bvs-gateway';
  static const String bvsWebView = '/bvs-web-view';
  static const String matchProfile = '/match-profile-screen';
  static const String profileDetail = '/profile-detail-screen';
  static const String sharedProfiles = '/shared-profiles-screen';
  static const String authentication = '/authentication-screen';
  static const String biodataCreation = '/biodata-creation-screen';
  static const String home = '/home-screen';
  static const String photoManagement = '/photo-management-screen';
  static const String selfProfile = '/self-profile-screen';
  static const String myProfile = '/my-profile-screen';
  static const String filter = '/filter-screen';
  static const String subscription = '/subscription';
  static const String savedProfiles = '/saved-profiles-screen';
  static const String contactUs = '/contact-us-screen';
  static const String termsConditions = '/terms-conditions-screen';
  static const String privacyPolicy = '/privacy-policy-screen';
  static const String accountDeletion = '/account-deletion-screen';
  static const String faq = '/faq-screen';
  static const String trustScore = '/trust-score-screen';
  static const String mobileVerification = '/mobile-verification-screen';
  static const String emailVerification = '/email-verification-screen';
  static const String liveSelfie = '/live-selfie-screen';
  static const String govtIdVerification = '/govt-id-verification-screen';
  static const String communityIdVerification =
      '/community-id-verification-screen';
  static const String referenceVerification = '/reference-verification-screen';
  static const String videoIntro = '/video-intro-screen';
  static const String biodataPdf = '/biodata-pdf-screen';
  static const String adminDashboard = '/admin-dashboard';
  static const String referralInvite = '/referral-invite';
  static const String account = '/account-screen';
  static const String settings = '/settings-screen';
  static const String conversationList = '/conversation-list';
  static const String chatScreen = '/chat-screen';
  static const String whoViewedMe = '/who-viewed-me';
  static const String biodataEditor = '/biodata-editor';
  static const String onboarding = '/onboarding';
  static const String initialLanguageSelection = '/initial-language-selection';
  static const String onboardingSelection = '/onboarding-selection';
  static const String activityHub = '/activity-hub';
  static const String staffDashboard = '/staff-dashboard';
  static const String premiumGate = '/premium-gate';
  static const String relativeIntake = '/relative-intake';
  static const String servicesHub = '/services-hub';
  static const String vendorRegistration = '/vendor-registration';
  static const String connect = '/connect-screen';
  static const String appPreferences = '/app-preferences-screen';

  static Map<String, WidgetBuilder> get routes => {
    initial: (context) => const SplashScreen(),
    matchProfile: (context) => const MatchProfileScreen(),
    profileDetail: (context) => const MatchProfileScreen(),
    sharedProfiles: (context) => const SharedProfilesScreen(),
    authentication: (context) => const AuthenticationScreen(),
    biodataCreation: (context) => const BiodataCreationScreen(),
    home: (context) => const MainNavigationScreen(),
    photoManagement: (context) => const PhotoManagementScreen(),
    selfProfile: (context) => const SelfProfileScreen(),
    myProfile: (context) => const SelfProfileScreen(),
    filter: (context) => const FilterScreen(),
    subscription: (context) => const SubscriptionScreen(),
    savedProfiles: (context) => const SavedProfilesScreen(),
    contactUs: (context) => const ContactUsScreen(),
    termsConditions: (context) => const TermsConditionsScreen(),
    privacyPolicy: (context) => const PrivacyPolicyScreen(),
    accountDeletion: (context) => const AccountDeletionScreen(),
    faq: (context) => const FAQScreen(),
    trustScore: (context) => const TrustScoreScreen(),
    mobileVerification: (context) => const MobileVerificationScreen(),
    emailVerification: (context) => const EmailVerificationScreen(),
    liveSelfie: (context) => const LiveSelfieScreen(),
    govtIdVerification: (context) => const GovtIdVerificationScreen(),
    communityIdVerification: (context) => const CommunityIdScreen(),
    referenceVerification: (context) => const ReferenceVerificationScreen(),
    videoIntro: (context) => const VideoIntroScreen(),
    biodataPdf: (context) => const BiodataScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    referralInvite: (context) => const ReferralInviteScreen(),
    account: (context) => const AccountScreen(),
    settings: (context) => const SettingsScreen(),
    conversationList: (context) => const ConversationListScreen(),
    chatScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ConversationModel) return ChatScreen(conversation: args);
      // Invalid/missing args: show conversation list so user can pick one
      return const ConversationListScreen();
    },
    whoViewedMe: (context) => const WhoViewedMeScreen(),
    biodataEditor: (context) => const BiodataEditorScreen(),
    onboarding: (context) => const OnboardingScreen(),
    initialLanguageSelection: (context) => const InitialLanguageScreen(),
    onboardingSelection: (context) => const OnboardingSelectionScreen(),
    activityHub: (context) => const ActivityHubScreen(),
    staffDashboard: (context) => const StaffDashboardScreen(),
    premiumGate: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return PremiumGateScreen(
        onComplete: args?['onComplete'] ?? () => Navigator.pop(context),
        onPremiumPurchased: args?['onPremiumPurchased'] ?? () {},
      );
    },
    relativeIntake: (context) => const RelativeIntakeScreen(),
    userTypeSelection: (context) => const UserTypeSelectionScreen(),
    bvsGateway: (context) => const BvsGatewayScreen(),
    bvsWebView: (context) {
      final url = ModalRoute.of(context)?.settings.arguments as String?;
      return BvsWebViewScreen(initialUrl: url);
    },
    servicesHub: (context) => const ServicesScreen(),
    vendorRegistration: (context) => const VendorRegistrationScreen(),
    connect: (context) => const InboxScreen(),
    appPreferences: (context) => const SettingsScreen(),
  };

  /// Generates premium animated routes for named navigation.
  /// Usage in MaterialApp:
  /// ```dart
  /// MaterialApp(onGenerateRoute: AppRoutes.onGenerateRoute)
  /// ```
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return buildPremiumRoute(builder, settings);
    }
    // Fallback for legacy or rewritten path variations
    if (settings.name == '/vendor-registration' ||
        settings.name == vendorRegistration) {
      return buildPremiumRoute(
          (context) => const VendorRegistrationScreen(), settings);
    }
    if (settings.name == '/match-profile-screen' ||
        settings.name == '/profile-detail-screen' ||
        settings.name == '/profile-detail') {
      return buildPremiumRoute((context) => const MatchProfileScreen(), settings);
    }
    if (settings.name == '/self-profile-screen' ||
        settings.name == '/my-profile-screen' ||
        settings.name == '/my-profile') {
      return buildPremiumRoute((context) => const SelfProfileScreen(), settings);
    }
    return null;
  }
}
