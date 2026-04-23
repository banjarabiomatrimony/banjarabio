// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get genderSelectHeading => 'ನಿಮ್ಮ ಲಿಂಗ';

  @override
  String get replacePhoto => 'ಫೋಟೋ ಬದಲಾಯಿಸಿ';

  @override
  String get errorLoadingAdminStats =>
      'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಅಂಕಿಅಂಶಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorLoadingAdminUsers =>
      'ಬಳಕೆದಾರರ ಪಟ್ಟಿಯನ್ನು ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get errorLoadingAdminPayments =>
      'ಪಾವತಿ ಇತಿಹಾಸವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorLoadingAdminVerifications =>
      'ಪರಿಶೀಲನೆ ವಿನಂತಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorLoadingAdminReferences =>
      'ಬಾಕಿ ಉಳಿದಿರುವ ಉಲ್ಲೇಖಗಳನ್ನು ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get errorLoadingAdminCoupons =>
      'ಕೂಪನ್ ಕೊಡುಗೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorLoadingAdminCreators =>
      'ಕ್ರಿಯೇಟರ್ ಪಟ್ಟಿಯನ್ನು ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ನೆಟ್‌ವರ್ಕ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get errorAdminActionFailed =>
      'ವಿನಂತಿಸಿದ ಕ್ರಿಯೆಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get expressInterest => 'ಆಸಕ್ತಿಯನ್ನು ವ್ಯಕ್ತಪಡಿಸಬೇಕೆ?';

  @override
  String interestConfirmationDesc(String name) {
    return 'ನಿಮ್ಮ ಆಸಕ್ತಿಯನ್ನು ತೋರಿಸಲು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಅನ್ನು $name ಅವರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಲು ನೀವು ಬಯಸುವಿರಾ?';
  }

  @override
  String get yesInterest => 'ಹೌದು, ಆಸಕ್ತಿ ಇದೆ';

  @override
  String get interest => 'ಆಸಕ್ತಿ';

  @override
  String get revenueToday => 'ಇಂದಿನ ಆದಾಯ (₹)';

  @override
  String get premiumMen => 'ಪ್ರೀಮಿಯಂ ಪುರುಷರು';

  @override
  String get premiumWomen => 'ಪ್ರೀಮಿಯಂ ಮಹಿಳೆಯರು';

  @override
  String get financialPerformance => 'ಹಣಕಾಸಿನ ಸಾಧನೆ';

  @override
  String get demographicsAndPremium => 'ಜನಸಂಖ್ಯಾಶಾಸ್ತ್ರ ಮತ್ತು ಪ್ರೀಮಿಯಂ';

  @override
  String get revenueTotal => 'ಒಟ್ಟು ಆದಾಯ (₹)';

  @override
  String get monthlyRevenue => 'ಮಾಸಿಕ ಆದಾಯ (₹)';

  @override
  String get pdfRevenue => 'PDF ಆದಾಯ (₹)';

  @override
  String get userEngagement => 'ಬಳಕೆದಾರರ ತೊಡಗಿಸಿಕೊಳ್ಳುವಿಕೆ';

  @override
  String get dailyActiveUsers => 'ದೈನಂದಿನ ಸಕ್ರಿಯ ಬಳಕೆದಾರರು';

  @override
  String get profileViews => 'ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಣೆಗಳು';

  @override
  String get totalMessages => 'ಒಟ್ಟು ಸಂದೇಶಗಳು';

  @override
  String get safetyAndHealth => 'ಸುರಕ್ಷತೆ ಮತ್ತು ಆರೋಗ್ಯ';

  @override
  String get pendingReports => 'ಬಾಕಿ ಉಳಿದಿರುವ ವರದಿಗಳು';

  @override
  String get totalBlocks => 'ಒಟ್ಟು ಬ್ಲಾಕ್‌ಗಳು';

  @override
  String get pendingReferences => 'ಬಾಕಿ ಉಳಿದಿರುವ ಉಲ್ಲೇಖಗಳು';

  @override
  String get totalUsers => 'ಒಟ್ಟು ಬಳಕೆದಾರರು';

  @override
  String get profiles => 'ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get appGrowth => 'ಅಪ್ಲಿಕೇಶನ್ ಬೆಳವಣಿಗೆ';

  @override
  String get completedReferrals => 'ಪೂರ್ಣಗೊಂಡ ರೆಫರಲ್‌ಗಳು';

  @override
  String get activeCreators => 'ಸಕ್ರಿಯ ಕ್ರಿಯೇಟರ್‌ಗಳು';

  @override
  String get totalFemales => 'ಒಟ್ಟು ಮಹಿಳೆಯರು';

  @override
  String get totalMales => 'ಒಟ್ಟು ಪುರುಷರು';

  @override
  String get men => 'ಪುರುಷರು';

  @override
  String get women => 'ಮಹಿಳೆಯರು';

  @override
  String get sharingProfiles => 'ಪ್ರೊಫೈಲ್‌ಗಳ ಹಂಚಿಕೆ';

  @override
  String get sharingProfile => 'ಪ್ರೊಫೈಲ್ ಹಂಚಿಕೆಯಾಗುತ್ತಿದೆ...';

  @override
  String get referenceVerified => 'ಉಲ್ಲೇಖವನ್ನು ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get referenceRejected => 'ಉಲ್ಲೇಖವನ್ನು ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get aboutSelf => 'ನನ್ನ ಬಗ್ಗೆ';

  @override
  String get aboutYourself => 'ನಿಮ್ಮ ಬಗ್ಗೆ';

  @override
  String get abusiveBehavior => 'ಅಪಹಾಸ್ಯ ವರ್ತನೆ';

  @override
  String get account => 'ಖಾತೆ';

  @override
  String get accountAndAllDataDeletedSuccessfully =>
      'ಖಾತೆ ಮತ್ತು ಎಲ್ಲಾ ಡೇಟಾ ಅಳಿಸಲಾಗಿದೆ.';

  @override
  String get accountDeletion => 'ಖಾತೆ ಅಳಿಸುವಿಕೆ';

  @override
  String get actionIsIrreversible => 'ಈ ಕ್ರಿಯೆಯು ಬದಲಾಯಿಸಲಾಗದು.';

  @override
  String get activeSubscriptionCancelledNoRefund =>
      'ನಿಮ್ಮ ಸಕ್ರಿಯ ಚಂದಾದಾರಿಕೆಯನ್ನು ಯಾವುದೇ ಮರುಪಾವತಿ ಇಲ್ಲದೆ ರದ್ದುಗೊಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get adFreeExperience => 'ಜಾಹೀರಾತು ರಹಿತ ಅನುಭವ';

  @override
  String addClearPhotos(String max) {
    return 'ಸ್ಪಷ್ಟ ಫೋಟೋಗಳನ್ನು ಸೇರಿಸಿ (ಗರಿಷ್ಠ $max)';
  }

  @override
  String get addPhoto => 'ಫೋಟೋ ಸೇರಿಸಿ';

  @override
  String get addPhotosToYourBiodataProfileToIncreaseV =>
      'ಹೆಚ್ಚಿನ ಮನ್ನಣೆಗಾಗಿ ಪ್ರೊಫೈಲ್‌ಗೆ ಫೋಟೋ ಸೇರಿಸಿ';

  @override
  String get addSibling => 'ಸಹೋದರ/ಸಹೋದರಿಯನ್ನು ಸೇರಿಸಿ';

  @override
  String get addTwoReferences => 'ಎರಡು ಉಲ್ಲೇಖಗಳನ್ನು ಸೇರಿಸಿ';

  @override
  String get addYourBrothersAndSisters => 'ನಿಮ್ಮ ಸಹೋದರ ಸಹೋದರಿಯರನ್ನು ಸೇರಿಸಿ';

  @override
  String get addYourFirstPhoto => 'ನಿಮ್ಮ ಮೊದಲ ಫೋಟೋ ಸೇರಿಸಿ';

  @override
  String get additionalPreferences => 'ಹೆಚ್ಚುವರಿ ಆದ್ಯತೆಗಳು';

  @override
  String get additionalProfessionalInfo => 'ಹೆಚ್ಚುವರಿ ವೃತ್ತಿಪರ ಮಾಹಿತಿ';

  @override
  String get adjust => 'ಹೊಂದಿಸಿ';

  @override
  String get adjustFilters => 'ಫಿಲ್ಟರ್ ಹೊಂದಿಸಿ';

  @override
  String get adminDashboard => 'ಅಡ್ಮಿನ್ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get adminLoginRequiresAuthorizedCredentials =>
      'ಅಡ್ಮಿನ್ ಲಾಗಿನ್‌ಗಾಗಿ ಅಧಿಕೃತ ರುಜುವಾತುಗಳು ಅಗತ್ಯವಿದೆ';

  @override
  String get adminManagement => 'ಅಡ್ಮಿನ್ ನಿರ್ವಹಣೆ';

  @override
  String get adminPortal => 'ಅಡ್ಮಿನ್ ಪೋರ್ಟಲ್';

  @override
  String get advancedFilters => 'ಸುಧಾರಿತ ಫಿಲ್ಟರ್‌ಗಳು';

  @override
  String get affluent => 'ಸಂಪನ್ನ';

  @override
  String get age => 'ವಯಸ್ಸು';

  @override
  String get ageRange => 'ವಯಸ್ಸಿನ ವ್ಯಾಪ್ತಿ';

  @override
  String get aiBio => 'AI ಬಯೋ';

  @override
  String allInDistrict(String district) {
    return '$district ನಲ್ಲಿರುವ ಎಲ್ಲವೂ';
  }

  @override
  String get allInSelectedDistrict => 'All in selected District';

  @override
  String get allInSelectedState => 'All in selected State';

  @override
  String allInState(String state) {
    return '$state ನಲ್ಲಿರುವ ಎಲ್ಲವೂ';
  }

  @override
  String get allIndia => 'ಅಖಿಲ ಭಾರತ';

  @override
  String allPhotosCount(int count, int max) {
    return 'ಎಲ್ಲಾ ಫೋಟೋಗಳು ($count/$max)';
  }

  @override
  String get allYourProfileDataPermanentlyRemoved =>
      'ನಿಮ್ಮ ಎಲ್ಲಾ ಪ್ರೊಫೈಲ್ ಡೇಟಾವನ್ನು ಶಾಶ್ವತವಾಗಿ ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ.';

  @override
  String get almostDone => 'ಬಹುತೇಕ ಮುಗಿದಿದೆ!';

  @override
  String get almostDoneReview =>
      'ಎಲ್ಲಾ ವಿಭಾಗಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಪೂರ್ಣಗೊಳಿಸಲು \"ಬಯೋಡೇಟಾ ಉಳಿಸಿ\" ಕ್ಲಿಕ್ ಮಾಡಿ. ನಿಮ್ಮ ಗೌಪ್ಯತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳ ಆಧಾರದ ಮೇಲೆ ನಿಮ್ಮ ಬಯೋಡೇಟಾ ಇತರ ಸಮುದಾಯದ ಸದಸ್ಯರಿಗೆ ಗೋಚರಿಸುತ್ತದೆ.';

  @override
  String anErrorOccurred(Object error) {
    return 'ದೋಷ ಸಂಭವಿಸಿದೆ: $error';
  }

  @override
  String get and => ' ಮತ್ತು ';

  @override
  String get annualIncome => 'ಸ್ವಂತ ವಾರ್ಷಿಕ ಆದಾಯ (Self Annual Income)';

  @override
  String get annualIncomeHint =>
      'ನಿಮ್ಮ ವಾರ್ಷಿಕ ಗಳಿಕೆ ಮಾತ್ರ (ಉದಾ. ಸಂಬಳ/ವ್ಯಾಪಾರ). ಮನೆಯ ಒಟ್ಟು ಉಳಿತಾಯ ಅಥವಾ ಬ್ಯಾಂಕ್ ಬ್ಯಾಲೆನ್ಸ್ ನಮೂದಿಸಬೇಡಿ.';

  @override
  String get annulled => 'ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get appName => 'ಬಂಜಾರ ಬಯೋ';

  @override
  String get applyFilters => 'ಫಿಲ್ಟರ್‌ಗಳನ್ನು ಅನ್ವಯಿಸಿ';

  @override
  String get approve => 'ಅನುಮೋದಿಸಿ';

  @override
  String get areYouReadyForDiscussions => 'ನೀವು ಚರ್ಚೆಗೆ ಸಿದ್ಧವೇ?';

  @override
  String areYouSureDeleteSelectedPhotos(int count) {
    return 'ಆಯ್ದ $count ಫೋಟೋಗಳನ್ನು ಅಳಿಸಲು ನೀವು ಖಚಿತವೇ?';
  }

  @override
  String get areYouSureExit => 'ನೀವು ಅಪ್ಲಿಕೇಶನ್ ತೊರೆಯಲು ಖಚಿತವಾಗಿ ಬಯಸುತ್ತೀರಾ?';

  @override
  String get areYouSureLogout => 'ನೀವು ಲಾಗ್‌ಔಟ್ ಮಾಡಲು ಖಚಿತವಾಗಿ ಬಯಸುತ್ತೀರಾ?';

  @override
  String get areYouSureYouWantToBlockThisUserYouWillN =>
      'ಈ ಬಳಕೆದಾರರನ್ನು ಬ್ಲಾಕ್ ಮಾಡಲು ನೀವು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ? ನೀವು ಅವರ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಮತ್ತೆ ನೋಡಲು ಸಾಧ್ಯವಾಗುವುದಿಲ್ಲ.';

  @override
  String get areYouSureYouWantToDeleteThisPhoto => 'ಈ ಫೋಟೋ ಅಳಿಸಲು ನೀವು ಖಚಿತವೇ?';

  @override
  String get areYouSureYouWantToDeleteYourAccount =>
      'ನಿಮ್ಮ ಖಾತೆ ಅಳಿಸಲು ಖಚಿತವೇ?';

  @override
  String get askFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get atLeastOnePhotoRequired => 'ಕನಿಷ್ಠ ಒಂದು ಫೋಟೋ ಅಗತ್ಯವಿದೆ';

  @override
  String get awaitingDivorce => 'ವಿಚ್ಛೇದನ ನಿರೀಕ್ಷೆಯಲ್ಲಿದೆ';

  @override
  String get bachelorsDegree => 'ಪದವಿ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get backSide => 'ಹಿಂಭಾಗದ ಭಾಗ';

  @override
  String get backToGoogleSignIn => 'Google ಸೈನ್ ಇನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get banjaraMember => 'ಬಂಜಾರ ಸದಸ್ಯ';

  @override
  String get banjarabio => 'BanjaraBio';

  @override
  String get biodataDraftRestored => 'ಬಯೋಡೇಟಾ ಕರಡು ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ!';

  @override
  String get biodataDraftRestoredSuccess =>
      'Biodata draft restored successfully!';

  @override
  String get biodataPdf => 'ಬಯೋಡೇಟಾ PDF';

  @override
  String get biodataSavedSuccessfully => 'ಬಯೋಡೇಟಾ ಯಶಸ್ವಿಯಾಗಿ ಉಳಿಸಲಾಗಿದೆ!';

  @override
  String get biodataUnlockPlanDesc =>
      'ವೃತ್ತಿಪರ ಪ್ರೀಮಿಯಂ ಟೆಂಪ್ಲೇಟ್‌ಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಿ';

  @override
  String get biodataUnlockPlanName => 'ಪ್ರೀಮಿಯಂ ಬಯೋಡೇಟಾ';

  @override
  String get birthDetails => 'ಹೆಚ್ಚುವರಿ ಜನ್ಮ ವಿವರಗಳು';

  @override
  String get birthPlace => 'ಹುಟ್ಟಿದ ಸ್ಥಳ';

  @override
  String get birthPlaceAndTime => 'ಜನ್ಮ ಸ್ಥಳ ಮತ್ತು ಸಮಯ';

  @override
  String get birthTime => 'ಹುಟ್ಟಿದ ಸಮಯ';

  @override
  String get block => 'ಬ್ಲಾಕ್ ಮಾಡಿ';

  @override
  String get blockUser => 'ಬಳಕೆದಾರರನ್ನು ಬ್ಲಾಕ್ ಮಾಡಿ';

  @override
  String get bloodGroup => 'ರಕ್ತ ಗುಂಪು';

  @override
  String get blurryLowQualityImages =>
      'ಅಸ್ಪಷ್ಟ, ಕತ್ತಲೆ ಅಥವಾ ಕಡಿಮೆ ಗುಣಮಟ್ಟದ ಚಿತ್ರಗಳು';

  @override
  String get bookmarkLimitReached => 'ಬುಕ್‌ಮಾರ್ಕ್ ಮಿತಿ ಮೀರಿದೆ';

  @override
  String get messagingLimitReached => 'ಸಂದೇಶ ಕಳುಹಿಸುವ ಮಿತಿ ಮೀರಿದೆ';

  @override
  String bookmarksCount(String count) {
    return '$count ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು';
  }

  @override
  String get bronze => 'ಕಂಚು';

  @override
  String get brother => 'ಸಹೋದರ';

  @override
  String get brotherCount => 'ಅಣ್ಣತಮ್ಮಂದಿರು';

  @override
  String get browseProfiles => 'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಬ್ರೌಸ್ ಮಾಡಿ';

  @override
  String get business => 'ವ್ಯಾಪಾರ';

  @override
  String get businessOwner => 'ಉದ್ಯಮಿ';

  @override
  String get byContAcceptTerms => 'ಮುಂದುವರಿಸುವ ಮೂಲಕ, ನೀವು ನಮ್ಮ ';

  @override
  String get camera => 'ಕ್ಯಾಮರಾ';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get cancelAnytime => 'ಯಾವಾಗ ಬೇಕಾದರೂ ರದ್ದುಮಾಡಿ';

  @override
  String get changeLanguage => 'ಭಾಷೆ ಬದಲಾಯಿಸಿ';

  @override
  String get chat => 'ಚಾಟ್';

  @override
  String get checkBackSoonForNewMatchesnpullDownToRef =>
      'ಹೊಸ ಪಂದ್ಯಗಳಿಗಾಗಿ ಮತ್ತೆ ಪರಿಶೀಲಿಸಿ.\\nರಿಫ್ರೆಶ್ ಮಾಡಲು ಕೆಳಗೆ ಎಳೆಯಿರಿ.';

  @override
  String get checkInbox => 'Check Inbox';

  @override
  String get checkInternet =>
      'ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get checkWhoIsLookingAtYourProfile =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಯಾರು ವೀಕ್ಷಿಸುತ್ತಿದ್ದಾರೆ ಎಂದು ಪರಿಶೀಲಿಸಿ';

  @override
  String get chooseFromGallery => 'ಗ್ಯಾಲರಿಯಿಂದ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get chooseTemplate => 'ಟೆಂಪ್ಲೇಟ್ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get clear => 'ತೆರವು ಮಾಡಿ';

  @override
  String get clearAllFilters => 'ಎಲ್ಲಾ ಫಿಲ್ಟರ್ ತೆರವುಗೊಳಿಸಿ';

  @override
  String get clearWellLitPhotos =>
      'ನಿಮ್ಮ ಮುಖ ಸ್ಪಷ್ಟವಾಗಿ ಕಾಣಿಸುವ ಸ್ಪಷ್ಟ, ಉತ್ತಮ ಬೆಳಕಿನ ಫೋಟೋಗಳು';

  @override
  String get close => 'ಮುಚ್ಚಿ';

  @override
  String get comeBackTomorrowFornnewCuratedMatches =>
      'ಹೊಸ ಪಂದ್ಯಗಳಿಗಾಗಿ\\nನಾಳೆ ಬನ್ನಿ!';

  @override
  String get communityId => 'Community ID';

  @override
  String get communityIdSubmitted => 'ಸಮುದಾಯ ID ಸಲ್ಲಿಸಲಾಗಿದೆ';

  @override
  String get communityIdVerification => 'ಸಮುದಾಯ ಗುರುತಿನ ಚೀಟಿ';

  @override
  String get communityMember => 'Community Member';

  @override
  String get communityVerification => 'ಸಮುದಾಯ ಪರಿಶೀಲನೆ';

  @override
  String get companyName => 'ಕಂಪನಿ ಹೆಸರು';

  @override
  String get completeVerificationToUnlockPremium =>
      '\'Premium\' ಸ್ಥಿತಿಯನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಲು ಪರಿಶೀಲನೆಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ.';

  @override
  String get completeYourProfileToGetNoticed =>
      'ಗಮನ ಸೆಳೆಯಲು ಪ್ರೊಫೈಲ್ ಪೂರ್ಣಗೊಳಿಸಿ!';

  @override
  String get completion => 'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ';

  @override
  String get complexion => 'ಚರ್ಮದ ಬಣ್ಣ';

  @override
  String get compressingUnder500Kb => 'Compressing under 500KB...';

  @override
  String get confirm => 'ದೃಢಪಡಿಸಿ';

  @override
  String get connectInApp => 'ಆ್ಯಪ್‌ನಲ್ಲಿ ಸಂಪರ್ಕಿಸಿ';

  @override
  String get connectWithCommunity => 'ನಿಮ್ಮ ಬಂಜಾರ ಸಮುದಾಯದೊಂದಿಗೆ ಸಂಪರ್ಕಿಸಿ';

  @override
  String get contact => 'ಸಂಪರ್ಕ';

  @override
  String get contactPreferences => 'ಸಂಪರ್ಕ ಆದ್ಯತೆಗಳು';

  @override
  String get contactUs => 'ನಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಿ';

  @override
  String get contactUsTitle => 'ನಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಿ';

  @override
  String get continueWithFreeAccount => 'ಉಚಿತ ಖಾತೆಯೊಂದಿಗೆ ಮುಂದುವರಿಯಿರಿ';

  @override
  String get continueWithGoogle => 'Googleನೊಂದಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get conversations => 'ಸಂಭಾಷಣೆಗಳು';

  @override
  String get copyLink => 'ಲಿಂಕ್ ನಕಲಿಸಿ';

  @override
  String copyLinkSubtitle(String name) {
    return '$name ಪ್ರೊಫೈಲ್ ಲಿಂಕ್ ನಕಲಿಸಿ';
  }

  @override
  String get couldNotLoadProfile =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get createBiodata => 'ಬಯೋಡೇಟಾ ತಯಾರಿಸಿ';

  @override
  String get createProfile => 'ಪ್ರೊಫೈಲ್ ರಚಿಸಿ';

  @override
  String criticalFailure(Object error) {
    return 'ನಿರ್ಣಾಯಕ ವಿಫಲತೆ: $error';
  }

  @override
  String get cropPhoto => 'ಕ್ರಾಪ್ ಫೋಟೋ';

  @override
  String get cropRotate => 'ಕ್ರಾಪ್ ಮತ್ತು ರೊಟೇಟ್';

  @override
  String curatedProfilesJustForYou(int count) {
    return '$count ನಿಮಗಾಗಿ ಆಯ್ದ ಪ್ರೊಫೈಲ್‌ಗಳು';
  }

  @override
  String get currentLocation => 'ಪ್ರಸ್ತುತ ಸ್ಥಳ';

  @override
  String get currentPlan => 'ಪ್ರಸ್ತುತ ಯೋಜನೆ';

  @override
  String get currentResidenceState => 'ಪ್ರಸ್ತುತ ವಾಸವಿರುವ ರಾಜ್ಯ';

  @override
  String get currentVillageHint => 'ಪ್ರಸ್ತುತ ಗ್ರಾಮ';

  @override
  String get customizeBiodata => 'ಬಯೋಡೇಟಾವನ್ನು ಕಸ್ಟಮೈಸ್ ಮಾಡಿ';

  @override
  String get daily => 'ದೈನಂದಿನ';

  @override
  String get dailyMatch => 'ದೈನಂದಿನ ಪಂದ್ಯ';

  @override
  String get dark => 'ತುಂಬಾ ಕಪ್ಪು';

  @override
  String get dateOfBirth => 'ಹುಟ್ಟಿದ ದಿನಾಂಕ';

  @override
  String get daughter => 'ಮಗಳು';

  @override
  String daysAgo(String count) {
    return '$countದಿನಗಳ ಹಿಂದೆ';
  }

  @override
  String daysLeft(Object days) {
    return '$days ದಿನಗಳು ಬಾಕಿ';
  }

  @override
  String daysRemaining(Object days) {
    return '$days ದಿನಗಳು ಬಾಕಿ ಇವೆ';
  }

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get deleteAccount => 'ಖಾತೆ ಅಳಿಸಿ';

  @override
  String get deleteAccountWarning => 'ಈ ಕ್ರಿಯೆ ಶಾಶ್ವತ ಮತ್ತು ರದ್ದು ಮಾಡಲಾಗದು.';

  @override
  String deleteCount(Object count) {
    return 'ಅಳಿಸಿ ($count)';
  }

  @override
  String get deleteMyAccount => 'ನನ್ನ ಖಾತೆ ಅಳಿಸಿ';

  @override
  String get deletePhoto => 'ಫೋಟೋ ಅಳಿಸಿ';

  @override
  String get deletePhotos => 'ಫೋಟೋ ಅಳಿಸಿ';

  @override
  String deleteSelectedSharesQuery(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಆಯ್ದ $count ಹಂಚಿಕೆಗಳನ್ನು ಅಳಿಸಲು ನೀವು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ?',
      one: 'ಆಯ್ದ ಹಂಚಿಕೆಯನ್ನು ಅಳಿಸಲು ನೀವು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ?',
    );
    return '$_temp0';
  }

  @override
  String get deleteShares => 'ಹಂಚಿಕೆಗಳನ್ನು ಅಳಿಸಿ';

  @override
  String get deletingYourAccountWillResultIn => 'ಖಾತೆ ಅಳಿಸುವುದರಿಂದ:';

  @override
  String get demo => 'ಡೆಮೊ';

  @override
  String get describeYourselfInterestsHobbies => 'ನಿಮ್ಮ ಬಗ್ಗೆ ವಿವರಿಸಿ...';

  @override
  String get details => 'ವಿವರಗಳು';

  @override
  String get differentSettingsTip =>
      'ವಿಭಿನ್ನ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ (ಔಪಚಾರಿಕ, ಕ್ಯಾಶುಯಲ್) ಫೋಟೋಗಳನ್ನು ಸೇರಿಸಿ';

  @override
  String get diploma => 'ಡಿಪ್ಲೋಮಾ';

  @override
  String get directMessaging => 'ನೇರ ಸಂದೇಶ ಕಳುಹಿಸುವಿಕೆ';

  @override
  String get disabledHint => 'ವಿಕಲಚೇತನರಿಗೆ ಐಚ್ಛಿಕ ಮಾಹಿತಿ';

  @override
  String get disabledTagLabel => 'ವಿಕಲಚೇತನರು';

  @override
  String get discard => 'ತ್ಯಜಿಸಿ';

  @override
  String get discardChanges => 'ಬದಲಾವಣೆಗಳನ್ನು ತ್ಯಜಿಸಬೇಕೇ?';

  @override
  String get discardChangesBody =>
      'ನೀವು ಹಿಂದೆ ಹೋಗಲು ಖಚಿತವಾಗಿ ಬಯಸುತ್ತೀರಾ? ನಿಮ್ಮ ಪ್ರಗತಿ ಡ್ರಾಫ್ಟ್ ಆಗಿ ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String discountPercentage(Object percentage, Object score) {
    return '$percentage% ರಿಯಾಯಿತಿ (ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್ $score)';
  }

  @override
  String get discoverProfilesFromYourCommunityNsmartM =>
      'ನಿಮ್ಮ ಸಮುದಾಯದ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಅನ್ವೇಷಿಸಿ.';

  @override
  String get district => 'ಜಿಲ್ಲೆ';

  @override
  String districtInState(String state) {
    return '$state ನಲ್ಲಿರುವ ಜಿಲ್ಲೆ';
  }

  @override
  String get districtInStateLabel => 'District in State';

  @override
  String get divorced => 'ವಿಚ್ಛೇದಿತ';

  @override
  String get doctorate => 'ಡಾಕ್ಟರೇಟ್';

  @override
  String get documentProofs => 'ದಾಖಲೆ ಪುರಾವೆಗಳು:';

  @override
  String get documentType => 'ದಾಖಲೆ ಪ್ರಕಾರ';

  @override
  String get documentView => 'ದಾಖಲೆ ವೀಕ್ಷಣೆ';

  @override
  String get done => 'ಮುಗಿಯಿತು';

  @override
  String get downloadBtn => 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get dusky => 'ಕಪ್ಪು ಬಣ್ಣ';

  @override
  String get easiest => 'ಸುಲಭ';

  @override
  String get edit => 'ಸಂಪಾದಿಸಿ';

  @override
  String get editProfile => 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ';

  @override
  String get education => 'ಶಿಕ್ಷಣ';

  @override
  String get educationAndProfession => 'ಶಿಕ್ಷಣ ಮತ್ತು ವೃತ್ತಿ';

  @override
  String get educationDetails => 'ಶಿಕ್ಷಣ ವಿವರಗಳು';

  @override
  String get educationLabel => 'ಶಿಕ್ಷಣ';

  @override
  String get educationProfession => 'Education & Profession';

  @override
  String get educationProfessionDetails => 'ಶಿಕ್ಷಣ ಮತ್ತು ವೃತ್ತಿ';

  @override
  String get educationalQualification => 'ಶೈಕ್ಷಣಿಕ ಅರ್ಹತೆ';

  @override
  String get egSeniorSoftwareEngineer => 'ಉದಾ. ಹಿರಿಯ ಸಾಫ್ಟ್‌ವೇರ್ ಇಂಜಿನಿಯರ್';

  @override
  String get egSpecialization => 'ಉದಾ. ವಿಶೇಷತೆ ಅಥವಾ ಗೌರವ';

  @override
  String get egSpecializationOrHonors => 'ಉದಾ. ವಿಶೇಷತೆ ಅಥವಾ ಗೌರವಗಳು';

  @override
  String get egTime => 'ಉದಾ. ಬೆಳಿಗ್ಗೆ 10:30';

  @override
  String get elderBrother => 'ಅಣ್ಣ';

  @override
  String get elderSister => 'ಅಕ್ಕ';

  @override
  String get email => 'ಇಮೇಲ್';

  @override
  String get emailAddress => 'ಇಮೇಲ್ ವಿಳಾಸ';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailSupport => 'ಇಮೇಲ್ ಬೆಂಬಲ';

  @override
  String get emailVerification => 'ಇಮೇಲ್ ಪರಿಶೀಲನೆ';

  @override
  String get emailVerificationTip =>
      'Tip: Check your spam folder if you don\'t see the email.';

  @override
  String get emailVerifiedSuccessfully10Points =>
      'ಇಮೇಲ್ ಯಶಸ್ವಿಯಾಗಿ ಪರಿಶೀಲಿಸಲಾಗಿದೆ! +10 ಅಂಕಗಳು';

  @override
  String get emptyStr => '₹';

  @override
  String get english => 'English';

  @override
  String get enterBasicInfo =>
      'ಅಧಿಕೃತ ದಾಖಲೆಗಳಲ್ಲಿ ಕಾಣಿಸುವಂತೆ ನಿಮ್ಮ ಮೂಲ ಮಾಹಿತಿ ನಮೂದಿಸಿ';

  @override
  String get enterCityVillage => 'ನಗರ/ಹಳ್ಳಿ ನಮೂದಿಸಿ';

  @override
  String get enterEducationDetails => 'ನಿಮ್ಮ ಶಿಕ್ಷಣ ವಿವರಗಳನ್ನು ನಮೂದಿಸಿ';

  @override
  String get enterFullName => 'ನಿಮ್ಮ ಪೂರ್ಣ ಹೆಸರು ನಮೂದಿಸಿ';

  @override
  String get enterMobileNumber => 'Enter mobile number';

  @override
  String get enterProfessionDetails => 'ನಿಮ್ಮ ವೃತ್ತಿ ವಿವರಗಳನ್ನು ನಮೂದಿಸಿ';

  @override
  String get enterYourBasicInformationAsItAppearsInOf =>
      'ದಾಖಲೆಗಳಂತೆ ನಿಮ್ಮ ಮೂಲ ಮಾಹಿತಿ ನೀಡಿ';

  @override
  String get enterYourEducationDetails => 'Enter your education details';

  @override
  String get enterYourEmail => 'ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ';

  @override
  String get enterYourPassword => 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String get enterYourProfessionDetails => 'Enter your profession details';

  @override
  String get error => 'ದೋಷ';

  @override
  String errorCheckingShareLimits(String error) {
    return 'ಹಂಚಿಕೆ ಮಿತಿಗಳನ್ನು ಪರಿಶೀಲಿಸುವಲ್ಲಿ ದೋಷ: $error';
  }

  @override
  String errorCheckingStatus(String error) {
    return 'Error checking status: $error';
  }

  @override
  String errorCheckingViewLimits(String error) {
    return 'ವೀಕ್ಷಣೆ ಮಿತಿಗಳನ್ನು ಪರಿಶೀಲಿಸುವಲ್ಲಿ ದೋಷ: $error';
  }

  @override
  String errorLoadingAdminData(String error) {
    return 'ಅಡ್ಮಿನ್ ಡೇಟಾ ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: $error';
  }

  @override
  String errorLoadingRequests(String error) {
    return 'ವಿನಂತಿಗಳನ್ನು ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: $error';
  }

  @override
  String errorOccurred(String error) {
    return 'ದೋಷ ಸಂಭವಿಸಿದೆ: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get everyProfileIsVerifiedWithIdSelfieRefere =>
      'ಪ್ರತಿ ಪ್ರೊಫೈಲ್ ಗುರುತಿನೊಂದಿಗೆ ಪರಿಶೀಲಿಸಲಾಗಿದೆ.';

  @override
  String get exit => 'ನಿರ್ಗಮಿಸಿ';

  @override
  String get exitApp => 'ಅಪ್ಲಿಕೇಶನ್ ನಿರ್ಗಮಿಸಿ';

  @override
  String get exportBiodataPdf => 'ಬಯೋಡೇಟಾ PDF ರಫ್ತು ಮಾಡಿ';

  @override
  String get expressInterestDesc =>
      'ನಿಮ್ಮ ಬಯೋಡೇಟಾವನ್ನು ನೇರವಾಗಿ ಹಂಚಿಕೊಳ್ಳುವ ಮೂಲಕ ನಿಮ್ಮ ಆಸಕ್ತಿಯನ್ನು ವ್ಯಕ್ತಪಡಿಸಿ';

  @override
  String failedLoadProfile(String error) {
    return 'ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಯಿತು: $error';
  }

  @override
  String failedSignInGoogle(String error) {
    return 'Googleನೊಂದಿಗೆ ಸೈನ್ ಇನ್ ವಿಫಲವಾಯಿತು: $error';
  }

  @override
  String get failedSignInGoogleRetry =>
      'Googleನೊಂದಿಗೆ ಸೈನ್ ಇನ್ ವಿಫಲವಾಯಿತು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String failedToBlockUser(Object error) {
    return 'ಬಳಕೆದಾರರನ್ನು ನಿರ್ಬಂಧಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToDeleteAccount(Object error) {
    return 'ಖಾತೆಯನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToDeletePhotoError(String error) {
    return 'ಫೋಟೋ ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get failedToGeneratePdfPreview => 'PDF ಪೂರ್ವವೀಕ್ಷಣೆ ರಚಿಸಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String failedToLoadBookmarks(Object error) {
    return 'ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToLoadPhotosError(String error) {
    return 'ಫೋಟೋಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToLoadProfileError(Object error) {
    return 'ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get failedToLoadProfileInformation =>
      'ಪ್ರೊಫೈಲ್ ಮಾಹಿತಿ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String get failedToLoadProfiles => 'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String get failedToLoadReferralData => 'ರೆಫರಲ್ ಡೇಟಾ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String failedToLoadSubscription(String error) {
    return 'ಚಂದಾದಾರಿಕೆ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get failedToLoadTrustScoreStats =>
      'ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್ ಅಂಕಿಅಂಶ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String failedToLogout(String error) {
    return 'ಲಾಗ್‌ಔಟ್ ವಿಫಲವಾಯಿತು: $error';
  }

  @override
  String get failedToPrintPdf => 'PDF ಮುದ್ರಿಸಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String get failedToProcessImage => 'Failed to process image';

  @override
  String failedToSave(String error) {
    return 'ಉಳಿಸಲು ವಿಫಲವಾಯಿತು: $error';
  }

  @override
  String failedToSavePdf(String error) {
    return 'PDF ಉಳಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToSaveProfile(String error) {
    return 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಲು ವಿಫಲವಾಯಿತು: $error';
  }

  @override
  String get failedToSharePdf => 'PDF ಹಂಚಿಕೊಳ್ಳಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String failedToStartChat(String error) {
    return 'ಚಾಟ್ ಪ್ರಾರಂಭಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToSubmitReport(Object error) {
    return 'ವರದಿ ಸಲ್ಲಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToUpdateBookmark(Object error) {
    return 'ಬುಕ್‌ಮಾರ್ಕ್ ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToUpdatePremiumStatus(String error) {
    return 'ಪ್ರೀಮಿಯಂ ಸ್ಥಿತಿಯನ್ನು ಅಪ್‌ಡೇಟ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String failedToUpdatePrimaryPhotoError(String error) {
    return 'ಪ್ರಾಥಮಿಕ ಫೋಟೋ ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String failedToUploadPhoto(int index) {
    return 'ಫೋಟೋ $index ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಯಿತು';
  }

  @override
  String failedToVerify(String error) {
    return 'ಪರಿಶೀಲಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get fair => 'ಬಿಳಿ';

  @override
  String get fakeProfile => 'ನಕಲಿ ಪ್ರೊಫೈಲ್';

  @override
  String get familyBackground => 'ಕುಟುಂಬ ಹಿನ್ನೆಲೆ';

  @override
  String get familyDetails => 'ಕುಟುಂಬ ವಿವರಗಳು';

  @override
  String get familyFirstValues => 'ಕುಟುಂಬಕ್ಕೆ ಮೊದಲ ಆದ್ಯತೆ';

  @override
  String get familyOnly => 'ಕುಟುಂಬದವರಿಗೆ ಮಾತ್ರ';

  @override
  String get familyStatus => 'ಕುಟುಂಬ ಸ್ಥಿತಿ';

  @override
  String get familyType => 'ಕುಟುಂಬ ರೀತಿ';

  @override
  String get faqA1 =>
      'ಪ್ರೊಫೈಲ್ ಟ್ಯಾಬ್‌ಗೆ ಹೋಗಿ ಮತ್ತು \"ಬಯೋಡೇಟಾ ರಚಿಸಿ\" ಕ್ಲಿಕ್ ಮಾಡಿ ಅಥವಾ ನಿಮ್ಮ ಅಸ್ತಿತ್ವದಲ್ಲಿರುವ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಎಡಿಟ್ ಮಾಡಿ. ನಿಮ್ಮ ವೈಯಕ್ತಿಕ, ಕುಟುಂಬ ಮತ್ತು ವೃತ್ತಿಪರ ವಿವರಗಳನ್ನು ತುಂಬಲು ಬಹು-ಹಂತದ ಫಾರ್ಮ್ ಅನ್ನು ಅನುಸರಿಸಿ.';

  @override
  String get faqA2 =>
      'ಹೌದು, ನಾವು ಗೌಪ್ಯತೆಯನ್ನು ಗಂಭೀರವಾಗಿ ಪರಿಗಣಿಸುತ್ತೇವೆ. ನಿಮ್ಮ ಸಂಪರ್ಕ ವಿವರಗಳನ್ನು ಪರಿಶೀಲಿಸಿದ ಬಳಕೆದಾರರಿಗೆ ಮಾತ್ರ ತೋರಿಸಲಾಗುತ್ತದೆ ಮತ್ತು ನಮ್ಮ ಸಮುದಾಯದ ಸುರಕ್ಷತಾ ಮಾರ್ಗಸೂಚಿಗಳನ್ನು ಗೌರವಿಸುತ್ತದೆ.';

  @override
  String get faqA3 =>
      'ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ನಲ್ಲಿ, ವಯಸ್ಸು, ಸ್ಥಳ, ಶಿಕ್ಷಣ ಮತ್ತು ವೃತ್ತಿಯ ಮೂಲಕ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಕಿರಿದಾಗಿಸಲು \"ಫಿಲ್ಟರ್‌ಗಳು\" ಬಟನ್ ಬಳಸಿ.';

  @override
  String get faqA4 =>
      'ಪ್ರೀಮಿಯಂ ಬಳಕೆದಾರರು ಅನಿಯಮಿತ ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಣೆಗಳು, ಹೊಸ ಬಯೋಡೇಟಾಗಳಿಗೆ ಆರಂಭಿಕ ಪ್ರವೇಶ ಮತ್ತು ಹುಡುಕಾಟ ಫಲಿತಾಂಶಗಳಲ್ಲಿ ವರ್ಧಿತ ಗೋಚರತೆಯನ್ನು ಪಡೆಯುತ್ತಾರೆ.';

  @override
  String get faqA5 =>
      'ನಮ್ಮ ಸಿಸ್ಟಂನಿಂದ ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಮತ್ತು ಡೇಟಾವನ್ನು ಶಾಶ್ವತವಾಗಿ ತೆಗೆದುಹಾಕಲು ನನ್ನ ಪ್ರೊಫೈಲ್ > ಕಾನೂನು ಮತ್ತು ಮಾಹಿತಿ > ಖಾತೆ ಅಳಿಸುವಿಕೆಗೆ ಹೋಗಿ.';

  @override
  String get faqQ1 => 'ಬಯೋಡೇಟಾವನ್ನು ನಾನು ಹೇಗೆ ರಚಿಸುವುದು?';

  @override
  String get faqQ2 => 'ನನ್ನ ಡೇಟಾ ಸುರಕ್ಷಿತವೇ?';

  @override
  String get faqQ3 => 'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ನಾನು ಹೇಗೆ ಫಿಲ್ಟರ್ ಮಾಡಬಹುದು?';

  @override
  String get faqQ4 => 'ಪ್ರೀಮಿಯಂನ ಪ್ರಯೋಜನಗಳೇನು?';

  @override
  String get faqQ5 => 'ನನ್ನ ಖಾತೆಯನ್ನು ನಾನು ಹೇಗೆ ಅಳಿಸುವುದು?';

  @override
  String get faqTitle => 'ಪದೇ ಪದೇ ಕೇಳಲಾಗುವ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get faqs => 'ಪದೇ ಪದೇ ಕೇಳಲಾಗುವ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get farmer => 'ರೈತ';

  @override
  String get fatherName => 'ತಂದೆ ಹೆಸರು';

  @override
  String get fatherOccupation => 'ತಂದೆ ವೃತ್ತಿ';

  @override
  String get feet => 'ಅಡಿ';

  @override
  String get female => 'ಮಹಿಳೆ';

  @override
  String fieldRequired(String field) {
    return '$field ಅಗತ್ಯವಿದೆ';
  }

  @override
  String get fifteenToTwentyLakh => '15 - 20 ಲಕ್ಷ';

  @override
  String get filtered => '(ಫಿಲ್ಟರ್ ಮಾಡಲಾಗಿದೆ)';

  @override
  String get findYourPerfectMatch => 'ನಿಮ್ಮ ಪರಿಪೂರ್ಣ ಸಂಗಾತಿ ಹುಡುಕಿ';

  @override
  String get fiveToSevenHalfLakh => '5 - 7.5 ಲಕ್ಷ';

  @override
  String get followAndGetFivePercent => 'ಅನುಸರಿಸಿ ಮತ್ತು +5% ಪಡೆಯಿರಿ';

  @override
  String get followUsOnInstagramBonus =>
      '5% ಬಯೋಡೇಟಾ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ ಬೋನಸ್ ಪಡೆಯಲು ಮತ್ತು ಇತ್ತೀಚಿನ ಪಂದ್ಯಗಳೊಂದಿಗೆ ನವೀಕೃತವಾಗಿರಲು ಇನ್‌ಸ್ಟಾಗ್ರಾಮ್‌ನಲ್ಲಿ ನಮ್ಮನ್ನು ಅನುಸರಿಸಿ.';

  @override
  String forMonths(Object count) {
    return '$count ತಿಂಗಳವರೆಗೆ';
  }

  @override
  String get free => 'ಉಚಿತ';

  @override
  String get free1PhotonpremiumUpTo6Photos =>
      'ಉಚಿತ: 1 ಫೋಟೋ\\nಪ್ರೀಮಿಯಂ: 6 ರವರೆಗೆ';

  @override
  String get freePlanDesc => 'ಮೂಲ ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get freeUserLimitInfo =>
      'Free user limit reached. Upgrade to continue.';

  @override
  String get freeUsersCanUpload1PhotoUpgradeToUploadU =>
      'ಗರಿಷ್ಠ 5 ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ.';

  @override
  String get friend => 'ಸ್ನೇಹಿತ';

  @override
  String get frontSide => 'ಮುಂಭಾಗದ ಭಾಗ';

  @override
  String get fullName => 'ಪೂರ್ಣ ಹೆಸರು';

  @override
  String get gallery => 'ಗ್ಯಾಲರಿ';

  @override
  String get gender => 'ಲಿಂಗ';

  @override
  String get generateBio => 'ಬಯೋ ರಚಿಸಿ';

  @override
  String get generatingPreview => 'ಪೂರ್ವವೀಕ್ಷಣೆ ರಚಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get getAProfessionalWellformattedPdfWithoutW =>
      'ವಾಟರ್‌ಮಾರ್ಕ್ ಇಲ್ಲದ ಮತ್ತು ಎಲ್ಲಾ ವಿವರಗಳಿರುವ ವೃತ್ತಿಪರ PDF ಪಡೆಯಿರಿ.';

  @override
  String get getInTouchWithUs => 'ನಮ್ಮೊಂದಿಗೆ ಸಂಪರ್ಕದಲ್ಲಿರಿ';

  @override
  String get getStarted => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get getStartedLabel => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get go => 'ಹೋಗಿ';

  @override
  String get goBack => 'ಹಿಂದೆ ಹೋಗಿ';

  @override
  String get gold => 'ಚಿನ್ನ';

  @override
  String get goldPlanDesc => 'ಅತ್ಯಂತ ಜನಪ್ರಿಯ - ಉತ್ತಮ ಮೌಲ್ಯ';

  @override
  String get goldPlanName => 'ಗೋಲ್డ్';

  @override
  String get goldVerified => 'Gold Verified';

  @override
  String get gotIt => 'ಅರ್ಥವಾಯಿತು';

  @override
  String get gotra => 'ಗೋತ್ರ';

  @override
  String get governmentEmployee => 'ಸರ್ಕಾರಿ ಉದ್ಯೋಗಿ';

  @override
  String get governmentId => 'ಸರ್ಕಾರಿ ID';

  @override
  String get governmentIdVerification => 'ಸರ್ಕಾರಿ ಐಡಿ ಪರಿಶೀಲನೆ';

  @override
  String get governmentIdVerificationSubtitle =>
      '\'Verified\' ಬ್ಯಾಡ್ಜ್ ಪಡೆಯಲು ನಿಮ್ಮ ಆಧಾರ್ ಅಥವಾ ಪ್ಯಾನ್ ನ ಮಸುಕಾದ ಪ್ರತಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get governmentJob => 'ಸರ್ಕಾರಿ ಕೆಲಸ';

  @override
  String get govtId => 'Govt ID';

  @override
  String get govtIdVerification => 'ಸರ್ಕಾರಿ ಗುರುತಿನ ಚೀಟಿ';

  @override
  String get graduate => 'ಪದವೀಧರ';

  @override
  String get great => 'ಗ್ರೇಟ್!';

  @override
  String get grid => 'ಗ್ರಿಡ್';

  @override
  String get groupPhotosNotVisible => 'ನೀವು ಸ್ಪಷ್ಟವಾಗಿ ಕಾಣಿಸದ ಗುಂಪು ಫೋಟೋಗಳು';

  @override
  String get growth => 'Growth';

  @override
  String get haveQuestionsOrNeedAssistanceOurTeamIsHe =>
      'ಪ್ರಶ್ನೆಗಳಿವೆಯೇ ಅಥವಾ ಸಹಾಯ ಬೇಕೇ? ನಮ್ಮ ತಂಡ ಇಲ್ಲಿದೆ.';

  @override
  String get heavilyFilteredEdited =>
      'ಹೆಚ್ಚು ಫಿಲ್ಟರ್ ಮಾಡಿದ ಅಥವಾ ಎಡಿಟ್ ಮಾಡಿದ ಫೋಟೋಗಳು';

  @override
  String get height => 'ಎತ್ತರ';

  @override
  String get helpOurCommunityGrowAndUnlockPremiumRewa =>
      'ನಮ್ಮ ಸಮುದಾಯ ಬೆಳೆಯಲು ಮತ್ತು ನಿಮಗಾಗಿ ಪ್ರೀಮಿಯಂ ಬಹುಮಾನಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಲು ಸಹಾಯ ಮಾಡಿ.';

  @override
  String get highSchool => 'ಪ್ರೌಢಶಾಲೆ';

  @override
  String get hindi => 'ಹಿಂದಿ';

  @override
  String get home => 'ಮುಖ್ಯ';

  @override
  String get homemaker => 'ಗೃಹಿಣಿ';

  @override
  String hoursAgo(String count) {
    return '$countಗಂಟೆಗಳ ಹಿಂದೆ';
  }

  @override
  String get howItWorks => 'ಇದು ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get iUnderstandThatThisActionCannotBeUndone =>
      'ಈ ಕ್ರಿಯೆಯನ್ನು ರದ್ದುಗೊಳಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ ಎಂದು ನಾನು ಅರ್ಥಮಾಡಿಕೊಂಡಿದ್ದೇನೆ.';

  @override
  String idLabel(String id) {
    return 'ID: $id';
  }

  @override
  String get idNumber => 'ID ಸಂಖ್ಯೆ';

  @override
  String get idType => 'ID Type';

  @override
  String get inappropriateBackgrounds => 'ಅಸಮರ್ಪಕ ಹಿನ್ನೆಲೆ ಹೊಂದಿರುವ ಫೋಟೋಗಳು';

  @override
  String get inappropriateContentOrFakeProfile =>
      'ಅಸಮಂಜಸ ವಿಷಯ ಅಥವಾ ನಕಲಿ ಪ್ರೊಫೈಲ್';

  @override
  String get inappropriatePhotos => 'ಅನುಚಿತ ಫೋಟೋಗಳು';

  @override
  String get inches => 'ಇಂಚು';

  @override
  String get increaseBiodataScore => 'ಬಯೋಡೇಟಾ ಸ್ಕೋರ್ ಹೆಚ್ಚಿಸಿ!';

  @override
  String get increaseYourTrustScoreToConfirmYourIdent =>
      'ಗುರುತು ದೃಢಪಡಿಸಲು ನಿಮ್ಮ ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್ ಹೆಚ್ಚಿಸಿ.';

  @override
  String get interestSent => 'ಆಸಕ್ತಿ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get interestConfirmationTitle => 'ಆಸಕ್ತಿಯನ್ನು ವ್ಯಕ್ತಪಡಿಸಬೇಕೆ?';

  @override
  String interestConfirmationMessage(String name) {
    return 'ಇದು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಅನ್ನು $name ಅವರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳುತ್ತದೆ ಮತ್ತು ಅವರಿಗೆ ನಿಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಲು ಅನುಮತಿಸುತ್ತದೆ. ನಿಮಗೆ ಖಚಿತವೇ?';
  }

  @override
  String interestShared(String name) {
    return '$name ಅವರೊಂದಿಗೆ ಆಸಕ್ತಿಯನ್ನು ಹಂಚಿಕೊಳ್ಳಲಾಗಿದೆ!';
  }

  @override
  String get introduceYourselfIn30SecondsTalkAboutYou =>
      '30 ಸೆಕೆಂಡುಗಳಲ್ಲಿ ನಿಮ್ಮನ್ನು ಪರಿಚಯಿಸಿಕೊಳ್ಳಿ. ಕುಟುಂಬ, ವೃತ್ತಿ ಬಗ್ಗೆ ಮಾತನಾಡಿ.';

  @override
  String get invalidEmailOrPassword => 'ಅಮಾನ್ಯ ಇಮೇಲ್ ಅಥವಾ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get inviteARelative => 'ಸಂಬಂಧಿಕರನ್ನು ಆಹ್ವಾನಿಸಿ';

  @override
  String get inviteFriendsRewards =>
      'ಸ್ನೇಹಿತರನ್ನು ಆಹ್ವಾನಿಸಿ ಮತ್ತು ಪ್ರೀಮಿಯಂ ಬಹುಮಾನಗಳನ್ನು ಪಡೆಯಿರಿ!';

  @override
  String get inviteStep1 => 'Step 1';

  @override
  String get inviteStep2 => 'Step 2';

  @override
  String get inviteStep3 => 'Step 3';

  @override
  String get isDisabledPerson => 'ನೀವು ವಿಕಲಚೇತನರೇ?';

  @override
  String get jobDetails => 'ಕೆಲಸದ ವಿವರಗಳು';

  @override
  String get joinMeOnBanjarabio => 'BanjaraBio ನಲ್ಲಿ ನನ್ನೊಂದಿಗೆ ಸೇರಿ';

  @override
  String get joinOurCommunity => 'ನಮ್ಮ 10K+ ಸಮುದಾಯಕ್ಕೆ ಸೇರಿ!';

  @override
  String get jointFamily => 'ಅವಿಭಕ್ತ ಕುಟುಂಬ';

  @override
  String get justNow => 'ಈಗಷ್ಟೇ';

  @override
  String get kannada => 'ಕನ್ನಡ';

  @override
  String get keepBrowsing => 'ಬ್ರೌಸಿಂಗ್ ಮುಂದುವರಿಸಿ';

  @override
  String get keywordSearch => 'ಕೀವರ್ಡ್ ಹುಡುಕಾಟ';

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String languageChanged(String language) {
    return 'ಭಾಷೆ $language ಗೆ ಬದಲಾಯಿಸಲಾಗಿದೆ';
  }

  @override
  String get lastUpdatedJanuary2026 => 'ಕೊನೆಯ ನವೀಕರಣ: ಜನವರಿ 2026';

  @override
  String get legalAndInformation => 'ಕಾನೂನು ಮತ್ತು ಮಾಹಿತಿ';

  @override
  String get linkShare => 'ಲಿಂಕ್ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get linkedInIntegration => 'LinkedIn ಏಕೀಕರಣ';

  @override
  String get linkedInIntegrationSubtitle =>
      'ಹೆಚ್ಚು ವಿಶ್ವಾಸವನ್ನು ಬೆಳೆಸಲು ನಿಮ್ಮ ವೃತ್ತಿಪರ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get liveSelfie => 'ಲೈವ್ ಸೆಲ್ಫಿ';

  @override
  String get liveSelfieVerification => 'ಲೈವ್ ಸೆಲ್ಫಿ ಪರಿಶೀಲನೆ';

  @override
  String get livenessCheck => 'ಲೈವ್‌ನೆಸ್ ಪರಿಶೀಲನೆ';

  @override
  String get loading => 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...';

  @override
  String get loadingAssets => 'ಅಸೆಟ್ ಲೋಡ್ ಆಗುತ್ತಿದೆ...';

  @override
  String get loadingProfile => 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಆಗುತ್ತಿದೆ...';

  @override
  String get loadingViews => 'ವೀಕ್ಷಣೆ ಲೋಡ್ ಆಗುತ್ತಿದೆ...';

  @override
  String get location => 'ಸ್ಥಳ';

  @override
  String get locationDetails => 'ಸ್ಥಳದ ವಿವರಗಳು';

  @override
  String get locationPreferences => 'ಸ್ಥಳ ಮತ್ತು ಆದ್ಯತೆಗಳು';

  @override
  String get locationPreview => 'ಸ್ಥಳದ ಪೂರ್ವವೀಕ್ಷಣೆ';

  @override
  String get login => 'ಲಾಗಿನ್';

  @override
  String loginFailed(String error) {
    return 'ಲಾಗಿನ್ ವಿಫಲವಾಯಿತು: $error';
  }

  @override
  String get loginFailedRetry => 'ಲಾಗಿನ್ ವಿಫಲವಾಯಿತು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get logout => 'ಲಾಗ್‌ಔಟ್';

  @override
  String get loseMatchesAndSavedProfiles =>
      'ನಿಮ್ಮ ಎಲ್ಲಾ ಪಂದ್ಯಗಳು ಮತ್ತು ಉಳಿಸಿದ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ನೀವು ಕಳೆದುಕೊಳ್ಳುತ್ತೀರಿ.';

  @override
  String get main => 'ಮುಖ್ಯ';

  @override
  String get male => 'ಪುರುಷ';

  @override
  String get managePhotos => 'ಫೋಟೋಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get managenphotos => 'ಫೋಟೋ\\nನಿರ್ವಹಣೆ';

  @override
  String get manualSelection => 'ಹಸ್ತಚಾಲಿತ ಆಯ್ಕೆ';

  @override
  String get marathi => 'ಮರಾಠಿ';

  @override
  String get maritalStatus => 'ವೈವಾಹಿಕ ಸ್ಥಿತಿ';

  @override
  String get maritalStatusLabel => 'ವೈವಾಹಿಕ ಸ್ಥಿತಿ';

  @override
  String get marriageReadiness => 'ಮದುವೆಗೆ ಸಿದ್ಧತೆ';

  @override
  String get married => 'ವಿವಾಹಿತ';

  @override
  String get maskFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get mastersDegree => 'ಸ್ನಾತಕೋತ್ತರ ಪದವಿ';

  @override
  String matchNOfTotal(int current, int total) {
    return 'ಪಂದ್ಯ $current / $total';
  }

  @override
  String get matched => 'ಹೊಂದಿಕೆಯಾಗಿದೆ';

  @override
  String get sent => 'ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String get received => 'ಸ್ವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get matchmakerConsultation => 'ಮ್ಯಾಚ್‌ಮೇಕರ್ ಸಮಾಲೋಚನೆ';

  @override
  String get matrimonyFor => 'ಮ್ಯಾಟ್ರಿಮನಿ';

  @override
  String get maxAge => 'ಗರಿಷ್ಠ ವಯಸ್ಸು';

  @override
  String get maybeLater => 'ನಂತರ ನೋಡೋಣ';

  @override
  String get menu => 'ಮೆನು';

  @override
  String get message => 'ಸಂದೇಶ';

  @override
  String get messageUsOnWhatsapp => 'WhatsApp ನಲ್ಲಿ ಸಂದೇಶ ಕಳುಹಿಸಿ';

  @override
  String get messages => 'ಸಂದೇಶಗಳು';

  @override
  String get middleClass => 'ಮಧ್ಯಮ ವರ್ಗ';

  @override
  String get minAge => 'ಕನಿಷ್ಠ ವಯಸ್ಸು';

  @override
  String minutesAgo(String count) {
    return '$countನಿಮಿಷಗಳ ಹಿಂದೆ';
  }

  @override
  String get mobileNumber => 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ';

  @override
  String get mobileVerification => 'ಮೊಬೈಲ್ ಪರಿಶೀಲನೆ';

  @override
  String get mobileVerifiedSuccessfully10Points =>
      'ಮೊಬೈಲ್ ಯಶಸ್ವಿಯಾಗಿ ಪರಿಶೀಲಿಸಲಾಗಿದೆ! +10 ಅಂಕಗಳು';

  @override
  String get month => '/ತಿಂಗಳು';

  @override
  String get months => 'ತಿಂಗಳುಗಳು';

  @override
  String get moreAboutYourStudiesAndWork =>
      'ನಿಮ್ಮ ಅಧ್ಯಯನ ಮತ್ತು ಕೆಲಸದ ಬಗ್ಗೆ ಇನ್ನಷ್ಟು ತಿಳಿಸಿ';

  @override
  String get moreOptions => 'ಹೆಚ್ಚಿನ ಆಯ್ಕೆಗಳು';

  @override
  String get mostPopular => 'ಅತ್ಯಂತ ಜನಪ್ರಿಯ';

  @override
  String get motherName => 'ತಾಯಿ ಹೆಸರು';

  @override
  String get motherOccupation => 'ತಾಯಿ ವೃತ್ತಿ';

  @override
  String get myProfile => 'ನನ್ನ ಪ್ರೊಫೈಲ್';

  @override
  String get name => 'ಹೆಸರು';

  @override
  String get nativePlace => 'ಮೂಲ ಸ್ಥಳ';

  @override
  String get naturalPosesRespectful =>
      'ಗೌರವಾನ್ವಿತ ಅಭಿವ್ಯಕ್ತಿಗಳೊಂದಿಗೆ ನೈಸರ್ಗಿಕ ಭಂಗಿಗಳು';

  @override
  String get needProfileToShareToast =>
      'You need to create a profile before sharing it.';

  @override
  String get neverMarried => 'ಅವಿವಾಹಿತ';

  @override
  String get newLabel => 'ಹೊಸ';

  @override
  String get newMatches => 'ಹೊಸ ಹೊಂದಾಣಿಕೆಗಳು';

  @override
  String get next => 'ಮುಂದೆ';

  @override
  String get nextLabel => 'ಮುಂದೆ';

  @override
  String nextRefreshTime(String time) {
    return 'ಮುಂದಿನ ರಿಫ್ರೆಶ್: $time';
  }

  @override
  String get no => 'ಇಲ್ಲ';

  @override
  String get noBookmarkedProfilesYet =>
      'ಇನ್ನೂ ಯಾವುದೇ ಬುಕ್‌ಮಾರ್ಕ್ ಮಾಡಿದ ಪ್ರೊಫೈಲ್‌ಗಳಿಲ್ಲ';

  @override
  String get noConversations => 'ಇನ್ನೂ ಯಾವುದೇ ಸಂಭಾಷಣೆ ಇಲ್ಲ';

  @override
  String get noDailyMatchesYet => 'ಇನ್ನೂ ಯಾವುದೇ ದೈನಂದಿನ ಪಂದ್ಯಗಳಿಲ್ಲ';

  @override
  String get noIncome => 'ಆದಾಯ ಇಲ್ಲ';

  @override
  String get noInternetConnection => 'ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಇಲ್ಲ';

  @override
  String noLocationsFoundForQuery(String query) {
    return '\"$query\" ಗಾಗಿ ಯಾವುದೇ ಸ್ಥಳಗಳು ಕಂಡುಬಂದಿಲ್ಲ';
  }

  @override
  String get noPendingRequests => 'ಯಾವುದೇ ಬಾಕಿ ವಿನಂತಿಗಳಿಲ್ಲ';

  @override
  String get noPendingVerifications => 'No pending verifications';

  @override
  String get noPhotosAdded => 'ಯಾವುದೇ ಫೋಟೋಗಳನ್ನು ಸೇರಿಸಲಾಗಿಲ್ಲ';

  @override
  String get noPhotosYet => 'ಇನ್ನೂ ಯಾವುದೇ ಫೋಟೋಗಳಿಲ್ಲ';

  @override
  String get noProfileFound => 'ಯಾವುದೇ ಪ್ರೊಫೈಲ್ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get noProfilesFound => 'ಯಾವುದೇ ಪ್ರೊಫೈಲ್‌ಗಳು ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get noProfilesMatchYourFilters =>
      'ಯಾವುದೇ ಪ್ರೊಫೈಲ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ';

  @override
  String get noResultsMessage =>
      'ನಿಮ್ಮ ಫಿಲ್ಟರ್‌ಗಳನ್ನು ಸರಿಹೊಂದಿಸಿ ಅಥವಾ ನಂತರ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get noSiblingsAddedYet => 'ಇನ್ನೂ ಯಾರನ್ನೂ ಸೇರಿಸಿಲ್ಲ';

  @override
  String get noTalukasAvailable => 'ಯಾವುದೇ ತಾಲೂಕುಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get noViewsYet => 'ಇನ್ನೂ ಯಾವುದೇ ವೀಕ್ಷಣೆಗಳಿಲ್ಲ';

  @override
  String get notAvailable => 'ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get notEntered => 'ನಮೂದಿಸಿಲ್ಲ';

  @override
  String get notMatchedCantMessage =>
      'ನೀವು ಈ ಪ್ರೊಫೈಲ್‌ಗೆ ಹೊಂದಿಕೆಯಾಗಿಲ್ಲ, ಆದ್ದರಿಂದ ನೀವು ಅವರಿಗೆ ನೇರ ಸಂದೇಶ ಕಳುಹಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get notReadyYet => 'ಇನ್ನೂ ಸಿದ್ಧವಾಗಿಲ್ಲ';

  @override
  String get notRepresentAppearance =>
      'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ನೋಟವನ್ನು ಪ್ರತಿಬಿಂಬಿಸದ ಫೋಟೋಗಳು';

  @override
  String get notVerifiedYetPleaseClickTheLinkInYourEm =>
      'ಇನ್ನೂ ಪರಿಶೀಲಿಸಿಲ್ಲ. ದಯವಿಟ್ಟು ಇಮೇಲ್‌ನಲ್ಲಿರುವ ಲಿಂಕ್ ಕ್ಲಿಕ್ ಮಾಡಿ.';

  @override
  String get notYetVerifiedBadge => 'ಇನ್ನೂ ಪರಿಶೀಲಿಸಲಾಗಿಲ್ಲ';

  @override
  String get nuclearFamily => 'ವಿಭಕ್ತ ಕುಟುಂಬ';

  @override
  String get num100 => '/ 100';

  @override
  String get num123BanjaraTowersPrideSiliconValleynsh =>
      '123, ಬಂಜಾರ ಟವರ್ಸ್, ಶಿವಾಜಿ ನಗರ, ಪುಣೆ, ಮಹಾರಾಷ್ಟ್ರ 411005';

  @override
  String get num15PointsPending => '+15 ಅಂಕಗಳು ಬಾಕಿ ಇವೆ';

  @override
  String get num499 => '499';

  @override
  String get num919876543210 => '+91 98765 43210';

  @override
  String get officeAddress => 'ಕಚೇರಿ ವಿಳಾಸ';

  @override
  String get ok => 'ಸರಿ';

  @override
  String get onHold => 'ತಡೆಹಿಡಿಯಲಾಗಿದೆ';

  @override
  String get onboardingTitle1 => 'ನಿಮ್ಮ ಸರಿಯಾದ ಸಂಗಾತಿ ಹುಡುಕಿ';

  @override
  String get onboardingTitle2 => 'ವಿಶ್ವಾಸಾರ್ಹ ಸಮುದಾಯ';

  @override
  String get onboardingTitle3 => 'ಸುರಕ್ಷಿತ ಮತ್ತು ಖಾಸಗಿ';

  @override
  String get oneTime => 'ಒಂದು ಬಾರಿ';

  @override
  String get online => 'ಆನ್‌ಲೈನ್';

  @override
  String get openCamera => 'ಕ್ಯಾಮರಾ ತೆರೆಯಿರಿ';

  @override
  String get openProfileToShare => 'ಹಂಚಿಕೊಳ್ಳಲು ಪ್ರೊಫೈಲ್ ತೆರೆಯಿರಿ';

  @override
  String get openSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get openingConversation => 'ಸಂಭಾಷಣೆ ತೆರೆಯಲಾಗುತ್ತಿದೆ...';

  @override
  String get openingConversationToast => 'Opening conversation...';

  @override
  String get originalVillageHint => 'ಮೂಲ ಗ್ರಾಮ';

  @override
  String get other => 'ಇತರ';

  @override
  String get partnerExpectations => 'ಸಂಗಾತಿ ನಿರೀಕ್ಷೆಗಳು';

  @override
  String get partnerExpectationsHint =>
      'ನೀವು ಏನನ್ನು ಹುಡುಕುತ್ತಿದ್ದೀರಿ ಎಂದು ವಿವರಿಸಿ...';

  @override
  String get partnerPreferences => 'ಸಂಗಾತಿ ಆದ್ಯತೆಗಳು';

  @override
  String get password => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get pay199ToUnlockFullPdf => 'ಪೂರ್ಣ PDF ಅನ್‌ಲಾಕ್ ಮಾಡಲು ₹199 ಪಾವತಿಸಿ';

  @override
  String paymentFailed(String error) {
    return 'ಪಾವತಿ ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String paymentFailedError(String error) {
    return 'ಪಾವತಿ ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get paymentSuccessful =>
      'ಪಾವತಿ ಯಶಸ್ವಿಯಾಗಿದೆ! ಟೆಂಪ್ಲೇಟ್‌ಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಲಾಗಿದೆ.';

  @override
  String paymentSuccessfulWelcome(String plan) {
    return 'ಪಾವತಿ ಯಶಸ್ವಿಯಾಗಿದೆ! $plan ಗೆ ಸ್ವಾಗತ';
  }

  @override
  String pdfSavedToDownloads(String path) {
    return 'PDF ಅನ್ನು ಡೌನ್‌ಲೋಡ್‌ಗಳಿಗೆ ಉಳಿಸಲಾಗಿದೆ: $path';
  }

  @override
  String get pending => 'ಬಾಕಿ ಉಳಿದಿದೆ';

  @override
  String get pendingVerifications => 'Pending Verifications';

  @override
  String percentComplete(int percentage) {
    return '$percentage% ಪೂರ್ಣ';
  }

  @override
  String get permissionDeniedSettings =>
      'Permission denied. Please enable in settings.';

  @override
  String get permissionRequired => 'ಅನುಮತಿ ಅಗತ್ಯವಿದೆ';

  @override
  String permissionRequiredMessage(Object type) {
    return 'ಫೋಟೋಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲು $type ಅನುಮತಿ ಅಗತ್ಯವಿದೆ. ದಯವಿಟ್ಟು ಅಪ್ಲಿಕೇಶನ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಇದನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.';
  }

  @override
  String get personalDetails => 'ವ್ಯಕ್ತಿಗತ ವಿವರಗಳು';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneSupport => 'ಫೋನ್ ಬೆಂಬಲ';

  @override
  String get photoAdded => 'Photo added';

  @override
  String photoAddedWithKb(String kb) {
    return 'Photo added ($kb KB)';
  }

  @override
  String get photoGuidelines => 'ಫೋಟೋ ಮಾರ್ಗಸೂಚಿ';

  @override
  String get photoLimitReached => 'ಫೋಟೋ ಮಿತಿ ಮೀರಿದೆ';

  @override
  String get photoManagement => 'ಫೋಟೋ ನಿರ್ವಹಣೆ';

  @override
  String get photoUpload => 'ಫೋಟೋಗಳು';

  @override
  String get photoUploadedSuccessfully => 'ಫೋಟೋ ಯಶಸ್ವಿಯಾಗಿ ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ';

  @override
  String get photoVisibility => 'ಫೋಟೋ ಗೋಚರತೆ';

  @override
  String get photos => 'ಫೋಟೋಗಳು:';

  @override
  String get photosAreAutomaticallyCompressedToEnsure =>
      'ವೇಗವಾಗಿ ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ಫೋಟೋ ಸಂಕುಚಿತಗೊಳಿಸಲಾಗುತ್ತದೆ';

  @override
  String get photosCompressedInfo => 'Photos are compressed to save data.';

  @override
  String photosCount(String count) {
    return '$count ಫೋಟೋಗಳು';
  }

  @override
  String get photosDeletedSuccessfully => 'ಫೋಟೋಗಳನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಅಳಿಸಲಾಗಿದೆ';

  @override
  String get photosReflectPersonality =>
      'ನಿಮ್ಮ ವ್ಯಕ್ತಿತ್ವ ಮತ್ತು ಮೌಲ್ಯಗಳನ್ನು ಪ್ರತಿಬಿಂಬಿಸುವ ಫೋಟೋಗಳು';

  @override
  String photosSelectedCount(int count) {
    return '$count ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String get photosToAvoid => 'ತಪ್ಪಿಸಬೇಕಾದ ಫೋಟೋಗಳು';

  @override
  String get physicalSocialAttributes => 'ದೈಹಿಕ ಮತ್ತು ಸಾಮಾಜಿಕ ವಿವರಗಳು';

  @override
  String get physicalStatus => 'ದೈಹಿಕ ಸ್ಥಿತಿ';

  @override
  String get platinumPlanDesc => 'ಎಲ್ಲಾ ವೈಶಿಷ್ಟ್ಯಗಳೊಂದಿಗೆ ಅಂತಿಮ ಅನುಭವ';

  @override
  String get platinumPlanName => 'ಪ್ಲಾಟಿನಂ';

  @override
  String pleaseComplete(String fields) {
    return 'ಭರ್ತಿ ಮಾಡಿ: $fields';
  }

  @override
  String pleaseCompleteRequiredFields(String section) {
    return '$section ನಲ್ಲಿ ಎಲ್ಲಾ ಅಗತ್ಯ ಕ್ಷೇತ್ರಗಳನ್ನು ಭರ್ತಿ ಮಾಡಿ';
  }

  @override
  String get pleaseEnter6DigitOtp => 'ದಯವಿಟ್ಟು 6-ಅಂಕಿಯ OTP ನಮೂದಿಸಿ';

  @override
  String get pleaseEnterAValid10DigitMobileNumber =>
      'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ 10-ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get pleaseEnterBothEmailPassword =>
      'ಇಮೇಲ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ಎರಡನ್ನೂ ನಮೂದಿಸಿ';

  @override
  String get pleaseEnterFull6DigitOtp => 'ದಯವಿಟ್ಟು 6-ಅಂಕಿಯ ಪೂರ್ಣ OTP ನಮೂದಿಸಿ';

  @override
  String get pleaseFillAllFields => 'ದಯವಿಟ್ಟು ಎಲ್ಲಾ ಕ್ಷೇತ್ರಗಳನ್ನು ಭರ್ತಿ ಮಾಡಿ';

  @override
  String get pleaseSelectAnnualIncome => 'ನಿಮ್ಮ ವಾರ್ಷಿಕ ಆದಾಯ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get pleaseSelectEducationLevel => 'ನಿಮ್ಮ ಶಿಕ್ಷಣ ಮಟ್ಟ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get pleaseSelectProfession => 'ನಿಮ್ಮ ವೃತ್ತಿ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get pleaseSelectYourGotra => 'ನಿಮ್ಮ ಗೋತ್ರ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get pleaseSelectYourSurname => 'ನಿಮ್ಮ ಉಪನಾಮ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get pleaseSignInAgain => 'ಬಯೋಡೇಟಾ ಉಳಿಸಲು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String get pleaseSpecifyEducation => 'ನಿಮ್ಮ ಶಿಕ್ಷಣ ನಿರ್ದಿಷ್ಟಪಡಿಸಿ';

  @override
  String get pleaseSpecifyProfession => 'ನಿಮ್ಮ ವೃತ್ತಿ ನಿರ್ದಿಷ್ಟಪಡಿಸಿ';

  @override
  String get pleaseTakeASelfieToVerifyThatYouAreAReal =>
      'ನೀವು ನಿಜವಾದ ವ್ಯಕ್ತಿ ಎಂದು ಪರಿಶೀಲಿಸಲು ದಯವಿಟ್ಟು ಸೆಲ್ಫಿ ತೆಗೆದುಕೊಳ್ಳಿ.';

  @override
  String pointsCount(String points) {
    return '+$points ಅಂಕಗಳು';
  }

  @override
  String get postGraduate => 'ಸ್ನಾತಕೋತ್ತರ';

  @override
  String get premium => 'ಪ್ರೀಮಿಯಂ';

  @override
  String get premiumFeature => 'ಇದು ಪ್ರೀಮಿಯಂ ವೈಶಿಷ್ಟ್ಯವಾಗಿದೆ';

  @override
  String get premiumMembership => 'ಪ್ರೀಮಿಯಂ ಸದಸ್ಯತ್ವ';

  @override
  String get premiumTemplate => 'ಪ್ರೀಮಿಯಂ ಟೆಂಪ್ಲೇಟ್';

  @override
  String get premiumUsers => 'Premium Users';

  @override
  String get preparingBiodata => 'ನಿಮ್ಮ ಬಯೋಡೇಟಾವನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get previewGenerationFailed =>
      'ಪೂರ್ವವೀಕ್ಷಣೆ ರಚನೆ ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get previous => 'ಹಿಂದೆ';

  @override
  String pricePerMonth(Object price) {
    return '₹$price/ತಿಂಗಳು';
  }

  @override
  String get primary => 'ಪ್ರಾಥಮಿಕ';

  @override
  String get primaryPhoto => 'ಪ್ರಾಥಮಿಕ ಫೋಟೋ';

  @override
  String get primaryPhotoUpdated => 'ಪ್ರಾಥಮಿಕ ಫೋಟೋ ನವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get printBtn => 'ಮುದ್ರಿಸು';

  @override
  String get prioritySupport => 'ಆದ್ಯತೆಯ ಬೆಂಬಲ';

  @override
  String get privacyPolicy => 'ಗೌಪ್ಯತಾ ನೀತಿಗೆ';

  @override
  String get privacyS1Content =>
      '• ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ: ಹೆಸರು, ವಯಸ್ಸು, ಲಿಂಗ, ಜಾತಿ, ಶಿಕ್ಷಣ, ವೃತ್ತಿ, ಕುಟುಂಬದ ವಿವರಗಳು.\\n• ಸಂಪರ್ಕ ಮಾಹಿತಿ: ಫೋನ್ ಸಂಖ್ಯೆ, ಇಮೇಲ್ ವಿಳಾಸ.\\n• ಮಾಧ್ಯಮ: ನಿಮ್ಮ ಪ್ರೊಫೈಲ್‌ಗೆ ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ಫೋಟೋಗಳು.\\n• ಸಾಧನದ ಮಾಹಿತಿ: ಸಾಧನದ ಐಡಿ, ಐಪಿ ವಿಳಾಸ (ಸುರಕ್ಷತೆ ಮತ್ತು ವಿಶ್ಲೇಷಣೆಗಾಗಿ).\\n• ಸ್ಥಳದ ಮಾಹಿತಿ: ಹತ್ತಿರದ ಸಂಬಂಧಗಳನ್ನು ಸೂಚಿಸಲು ಅಂದಾಜು ಸ್ಥಳ (ನಗರ/ಜಿಲ್ಲೆ).';

  @override
  String get privacyS1Title => '1. ನಾವು ಸಂಗ್ರಹಿಸುವ ಮಾಹಿತಿ';

  @override
  String get privacyS2Content =>
      '• ಅಪ್ಲಿಕೇಶನ್ ಕಾರ್ಯಚಟುವಟಿಕೆ: ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ರಚಿಸಲು ಮತ್ತು ಮ್ಯಾಚ್-ಮೇಕಿಂಗ್‌ಗಾಗಿ.\\n• ಖಾತೆ ನಿರ್ವಹಣೆ: ಗುರುತಿನ ಪರಿಶೀಲನೆ ಮತ್ತು ವಂಚನೆ ತಡೆಗಟ್ಟುವಿಕೆ.\\n• ವಿಶ್ಲೇಷಣೆ: ಅಪ್ಲಿಕೇಶನ್ ಕಾರ್ಯಕ್ಷಮತೆಯನ್ನು ಸುಧಾರಿಸಲು (ಫೈರ್‌ಬೇಸ್ ಬಳಸಿ).\\n• ಸ್ಥಳ: \"ನನ್ನ ಹತ್ತಿರ\" ಇರುವ ಮ್ಯಾಚ್‌ಗಳನ್ನು ತೋರಿಸಲು (ಐಚ್ಛಿಕ).';

  @override
  String get privacyS2Title => '2. ಸಂಗ್ರಹಣೆಯ ಉದ್ದೇಶ (ಡೇಟಾ ಸುರಕ್ಷತೆ)';

  @override
  String get privacyS3Content =>
      '• ಕ್ಯಾಮೆರಾ ಮತ್ತು ಗ್ಯಾಲರಿ: ಪ್ರೊಫೈಲ್ ಫೋಟೋಗಳಿಗಾಗಿ.\\n• ಸ್ಥಳ: ನಗರ/ಜಿಲ್ಲೆಯನ್ನು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ತುಂಬಲು.\\n• ಅಧಿಸೂಚನೆಗಳು: ಮ್ಯಾಚ್ ಅಲರ್ಟ್‌ಗಳಿಗಾಗಿ.';

  @override
  String get privacyS3Title => '3. ಸಾಧನದ ಅನುಮತಿಗಳು';

  @override
  String get privacyS4Content =>
      '• ಇತರ ಬಳಕೆದಾರರು: ನೋಂದಾಯಿತ ಸದಸ್ಯರು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ವಿವರಗಳನ್ನು ನೋಡಬಹುದು (ಹಂಚಿಕೊಳ್ಳದ ಹೊರತು ಸಂಪರ್ಕ ಮಾಹಿತಿಯನ್ನು ಹೊರತುಪಡಿಸಿ).\\n• ಸೇವಾ ಪೂರೈಕೆದಾರರು: ಅಪ್ಲಿಕೇಶನ್ ನಡೆಸಲು ನಾವು ಸುಪಬೇಸ್ (ಡೇಟಾಬೇಸ್) ಮತ್ತು ಫೈರ್‌ಬೇಸ್ (ಅನಾಲಿಟಿಕ್ಸ್/ನೋಟಿಫಿಕೇಶನ್) ಬಳಸುತ್ತೇವೆ. ಅವರು ಕಟ್ಟುನಿಟ್ಟಾದ ಭದ್ರತಾ ಮಾನದಂಡಗಳ ಅಡಿಯಲ್ಲಿ ಡೇಟಾವನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸುತ್ತಾರೆ.';

  @override
  String get privacyS4Title => '4. ಬಹಿರಂಗಪಡಿಸುವಿಕೆ ಮತ್ತು ಮೂರನೇ ವ್ಯಕ್ತಿಗಳು';

  @override
  String get privacyS5Content =>
      'ನಿಮ್ಮ ಡೇಟಾವನ್ನು ರಕ್ಷಿಸಲು ನಾವು ಎನ್‌ಕ್ರಿಪ್ಶನ್ ಬಳಸುತ್ತೇವೆ. ಸೆಟ್ಟಿಂಗ್‌ಗಳು > ಖಾತೆ ಅಳಿಸಿ ಮೂಲಕ ನೀವು ಯಾವುದೇ ಸಮಯದಲ್ಲಿ ನಿಮ್ಮ ಖಾತೆ ಮತ್ತು ಸಂಬಂಧಿತ ಎಲ್ಲಾ ಡೇಟಾವನ್ನು ಅಳಿಸಬಹುದು.';

  @override
  String get privacyS5Title => '5. ಡೇಟಾ ಸುರಕ್ಷತೆ ಮತ್ತು ಅಳಿಸುವಿಕೆ';

  @override
  String get privacyS6Content =>
      'ಈ ನೀತಿಯು ಭಾರತದ ಕಾನೂನುಗಳಿಗೆ ಒಳಪಟ್ಟಿರುತ್ತದೆ. ಯಾವುದೇ ವಿವಾದಗಳು ಮಹಾರಾಷ್ಟ್ರದ ನ್ಯಾಯಾಲಯಗಳ ವ್ಯಾಪ್ತಿಗೆ ಒಳಪಡುತ್ತವೆ.';

  @override
  String get privacyS6Title => '6. ನಿಯಂತ್ರಕ ಕಾನೂನು';

  @override
  String get privacySettings => 'ಗೌಪ್ಯತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get privacySettingsUpdated => 'ಗೌಪ್ಯತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get privacyTitle => 'ಗೌಪ್ಯತಾ ನೀತಿ';

  @override
  String get privateJob => 'ಖಾಸಗಿ ಕೆಲಸ';

  @override
  String get privateSectorEmployee => 'ಖಾಸಗಿ ವಲಯದ ಉದ್ಯೋಗಿ';

  @override
  String get pro => 'PRO';

  @override
  String get proTips => 'ಪ್ರೊ ಟಿಪ್ಸ್';

  @override
  String get processingImage => 'ಚಿತ್ರವನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get processingStatusCompressing => 'Compressing...';

  @override
  String get processingStatusPreparing => 'Preparing...';

  @override
  String get processingStatusSelecting => 'Selecting...';

  @override
  String get profession => 'ವೃತ್ತಿ';

  @override
  String get professionLabel => 'ವృತ್ತಿ';

  @override
  String get professional => 'ವೃತ್ತಿಪರ';

  @override
  String get professionalDegree => 'ವೃತ್ತಿಪರ ಪದವಿ';

  @override
  String get professionalDoctorEngineerLawyer =>
      'ವೃತ್ತಿಪರ (ಡಾಕ್ಟರ್/ಇಂಜಿನಿಯರ್/ವಕೀಲ)';

  @override
  String get professionalFamilyEventPhotos =>
      'ವೃತ್ತಿಪರ ಅಥವಾ ಕೌಟುಂಬಿಕ ಕಾರ್ಯಕ್ರಮದ ಫೋಟೋಗಳು';

  @override
  String get profile => 'ಪ್ರೊಫೈಲ್';

  @override
  String profileBoostPerMonth(String count) {
    return '$count ಪ್ರೊಫೈಲ್ ಬೂಸ್ಟ್/ತಿಂಗಳು';
  }

  @override
  String get profileCompleted => 'ಪ್ರೊಫೈಲ್ ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get profileCreatedByTitle => 'ಪ್ರೊಫೈಲ್ ರಚಿಸಿದವರು';

  @override
  String get profileDataNotFound => 'ಪ್ರೊಫೈಲ್ ಡೇಟಾ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get profileInsights => 'ಪ್ರೊಫೈಲ್ ಒಳನೋಟಗಳು';

  @override
  String get profileLinkCopied =>
      'ಪ್ರೊಫೈಲ್ ಲಿಂಕ್ ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ!';

  @override
  String get profileNotFound => 'ಪ್ರೊಫೈಲ್ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get profilePhotos => 'ಪ್ರೊಫೈಲ್ ಫೋಟೋಗಳು';

  @override
  String get profileRemovedFromSaved =>
      'ಉಳಿಸಿದವುಗಳಿಂದ ಪ್ರೊಫೈಲ್ ತೆಗೆದುಹಾಕಲಾಗಿದೆ';

  @override
  String get profileSaved => 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಲಾಗಿದೆ!';

  @override
  String profileSharedWith(String name) {
    return 'ಪ್ರೊಫೈಲ್ $name ಜೊತೆಗೆ ಹಂಚಿಕೊಳ್ಳಲಾಗಿದೆ';
  }

  @override
  String profileStrengthLabel(Object strength) {
    return 'ಪ್ರೊಫೈಲ್ ಸಾಮರ್ಥ್ಯ: $strength';
  }

  @override
  String get profileViewLimitReached => 'ವೀಕ್ಷಣೆ ಮಿತಿ ಮೀರಿದೆ';

  @override
  String profileViewsPerDay(String count) {
    return '$count ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಣೆಗಳು/ದಿನ';
  }

  @override
  String get profilesYouSaveWillAppearHere =>
      'ನೀವು ಉಳಿಸುವ ಪ್ರೊಫೈಲ್‌ಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ';

  @override
  String get provideDetailsAboutYourGotraAndVillageTo =>
      'ಸಮುದಾಯ ಪರಿಶೀಲಿತ ಬ್ಯಾಡ್ಜ್ ಪಡೆಯಲು ನಿಮ್ಮ ಗೋತ್ರ ಮತ್ತು ಗ್ರಾಮದ ವಿವರಗಳನ್ನು ನೀಡಿ.';

  @override
  String get provideInformationAboutYourFamilyBackgro =>
      'ನಿಮ್ಮ ಕುಟುಂಬದ ವಿವರ ನೀಡಿ';

  @override
  String get public => 'ಸಾರ್ವಜನಿಕ';

  @override
  String get quick => 'ವೇಗ';

  @override
  String get ready => 'ಸಿದ್ಧವಾಗಿದೆ';

  @override
  String get readyForMarriage => 'ಮದುವೆಗೆ ಸಿದ್ಧ';

  @override
  String get recentConversations => 'ಇತ್ತೀಚಿನ ಸಂಭಾಷಣೆಗಳು';

  @override
  String get recentPhotosSixMonths =>
      'ಕಳೆದ 6 ತಿಂಗಳುಗಳಲ್ಲಿ ತೆಗೆದ ಇತ್ತೀಚಿನ ಫೋಟೋಗಳು';

  @override
  String get recentSearches => 'ಇತ್ತೀಚಿನ ಹುಡುಕಾಟಗಳು';

  @override
  String get recentlyUsed => 'ಇತ್ತೀಚೆಗೆ ಬಳಸಿದ';

  @override
  String get recommendToOthers => 'ಇತರರಿಗೆ ಶಿಫಾರಸು ಮಾಡಿ';

  @override
  String get recommended => 'ಸೂಚಿಸಲಾಗಿದೆ';

  @override
  String get recommendedPhotos => 'ಶಿಫಾರಸು ಮಾಡಲಾದ ಫೋಟೋಗಳು';

  @override
  String get recordAShortIntro => 'ಕಿರು ಪರಿಚಯ ರೆಕಾರ್ಡ್ ಮಾಡಿ';

  @override
  String get refer3FriendsGet1MonthFree =>
      '3 ಸ್ನೇಹಿತರನ್ನು ರೆಫರ್ ಮಾಡಿ, 1 ತಿಂಗಳು ಉಚಿತವಾಗಿ ಪಡೆಯಿರಿ!';

  @override
  String get referAndEarn => 'ರೆಫರ್ ಮಾಡಿ ಮತ್ತು ಗಳಿಸಿ';

  @override
  String get referenceVerification => 'ಉಲ್ಲೇಖ ಪರಿಶೀಲನೆ';

  @override
  String get references => 'ಉಲ್ಲೇಖಗಳು';

  @override
  String get referralInvite => 'ರೆಫರಲ್ ಆಹ್ವಾನ';

  @override
  String referralInviteMessage(Object link) {
    return 'ನಮ್ಮ ಸಮುದಾಯದ ಅತ್ಯಂತ ವಿಶ್ವಾಸಾರ್ಹ ವೈವಾಹಿಕ ಅಪ್ಲಿಕೇಶನ್ ಆದ ಬಂಜಾರಾಬಯೋಗೆ ಸೇರಿ! ಪ್ರಾರಂಭಿಸಲು ನನ್ನ ಲಿಂಕ್ ಬಳಸಿ: $link';
  }

  @override
  String get referralInviteSubject => 'ಬಂಜಾರಾಬಯೋಗೆ ಸೇರಲು ಆಮಂತ್ರಣ';

  @override
  String get referralLinkCopiedToClipboard =>
      'ರೆಫರಲ್ ಲಿಂಕ್ ಅನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ!';

  @override
  String referralShareMessage(String link) {
    return 'ನಮ್ಮ ಸಮುದಾಯಕ್ಕಾಗಿ ಅತ್ಯಂತ ವಿಶ್ವಾಸಾರ್ಹ ವೈವಾಹಿಕ ಅಪ್ಲಿಕೇಶನ್ ಆದ ಬಂಜಾರಾಬಯೋ (BanjaraBio) ಗೆ ಸೇರಿ! ಪ್ರಾರಂಭಿಸಲು ನನ್ನ ಲಿಂಕ್ ಬಳಸಿ: $link';
  }

  @override
  String get referralShareSubject => 'BanjaraBio invitation';

  @override
  String get referrals => 'Referrals';

  @override
  String get referralsLabel => 'ರೆಫರಲ್‌ಗಳು';

  @override
  String get refresh => 'ರಿಫ್ರೆಶ್';

  @override
  String get reject => 'ತಿರಸ್ಕರಿಸಿ';

  @override
  String get rejected => 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get relative => 'ಬಂಧು';

  @override
  String get remainingToday => 'ಇಂದು ಬಾಕಿ ಇದೆ';

  @override
  String get remove => 'ತೆಗೆದು ಹಾಕಿ';

  @override
  String get removePhoto => 'ತೆಗೆದು ಹಾಕಿ';

  @override
  String get report => 'ವರದಿ ಮಾಡಿ';

  @override
  String get reportSubmittedReview =>
      'ವರದಿಯನ್ನು ಸಲ್ಲಿಸಲಾಗಿದೆ. ನಮ್ಮ ತಂಡವು 24 ಗಂಟೆಗಳ ಒಳಗೆ ಅದನ್ನು ಪರಿಶೀಲಿಸುತ್ತದೆ.';

  @override
  String get reportUser => 'ಬಳಕೆದಾರರನ್ನು ವರದಿ ಮಾಡಿ';

  @override
  String get requestDate => 'Request Date';

  @override
  String requestProcessedSuccessfullyMsg(String status) {
    return 'ವಿನಂತಿಯನ್ನು $status ಯಶಸ್ವಿಯಾಗಿ ಪೂರ್ಣಗೊಳಿಸಲಾಗಿದೆ';
  }

  @override
  String get requestsSent => 'ವಿನಂತಿ ಕಳುಹಿಸಲಾಗಿದೆ!';

  @override
  String get requestsSentSuccessfully =>
      'ವಿನಂತಿಗಳನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಕಳುಹಿಸಲಾಗಿದೆ!';

  @override
  String get rerecord => 'ಮತ್ತೆ ರೆಕಾರ್ಡ್ ಮಾಡಿ';

  @override
  String get reset => 'ರೀಸೆಟ್';

  @override
  String get reshare => 'ಮರುಹಂಚಿಕೆ';

  @override
  String get retake => 'ಮತ್ತೆ ತೆಗೆದುಕೊಳ್ಳಿ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get reviewDetails => 'ವಿವರಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get reviewVideoManuallyInStorageForNow =>
      'ಈಗಿನವರೆಗೆ ಸ್ಟೋರೇಜ್‌ನಲ್ಲಿ ಮ್ಯಾನುವಲ್ ಆಗಿ ಪರಿಶೀಲಿಸಿ';

  @override
  String get rewards => 'Rewards';

  @override
  String get rewardsLabel => 'ಬಹುಮಾನಗಳು';

  @override
  String get rich => 'ಶ್ರೀಮಂತ';

  @override
  String get rupeeSymbol => '₹';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get saveBiodata => 'ಬಯೋಡೇಟಾ ಉಳಿಸಿ';

  @override
  String get saved => 'ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get savedProfiles => 'ಉಳಿಸಿದ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get sayHelloLabel => 'ಹಲೋ ಹೇಳಿ!';

  @override
  String get search => 'ಹುಡುಕಿ';

  @override
  String get searchByNameJobEducation => 'ಹೆಸರು, ಉದ್ಯೋಗ, ಶಿಕ್ಷಣದಿಂದ ಹುಡುಕಿ...';

  @override
  String get searchProfiles => 'ಪ್ರೊಫೈಲ್ ಹುಡುಕಿ...';

  @override
  String get searchResults => 'ಹುಡುಕಾಟ ಫಲಿತಾಂಶಗಳು';

  @override
  String get searchSharedProfiles => 'ಹಂಚಿದ ಪ್ರೊಫೈಲ್ ಹುಡುಕಿ...';

  @override
  String get searchStateDistrictOrTaluka => 'ಸ್ಥಳ ಹುಡುಕಿ';

  @override
  String get searchUserName => 'ಬಳಕೆದಾರರನ್ನು ಹುಡುಕಿ...';

  @override
  String get secure => 'ಸುರಕ್ಷಿತ';

  @override
  String get seeAll => 'ಎಲ್ಲ ನೋಡಿ';

  @override
  String get selectAnnualIncome => 'ವಾರ್ಷಿಕ ಆದಾಯ ವ್ಯಾಪ್ತಿ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectAnnualIncomeRange => 'ವಾರ್ಷಿಕ ಆದಾಯ ಶ್ರೇಣಿ ಆರಿಸಿ';

  @override
  String get selectDate => 'ದಿನಾಂಕ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get selectDistrictFirst => 'ಮೊದಲು ಜಿಲ್ಲೆಯನ್ನು ಆರಿಸಿ';

  @override
  String get selectDocumentType => 'ದಾಖಲೆ ಪ್ರಕಾರ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectEducationLevel => 'ನಿಮ್ಮ ಶಿಕ್ಷಣ ಮಟ್ಟ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectFromYourPhotos => 'ನಿಮ್ಮ ಫೋಟೋಗಳಿಂದ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get selectLanguage => 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectLocation => 'ಸ್ಥಳ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectState => 'ರಾಜ್ಯ ಆರಿಸಿ';

  @override
  String get selectStateFirst => 'ಮೊದಲು ರಾಜ್ಯವನ್ನು ಆರಿಸಿ';

  @override
  String get selectTalukaOptional => 'ತಾಲೂಕು ಆರಿಸಿ (ಐಚ್ಛಿಕ)';

  @override
  String get selectYourEducationLevel => 'ಶಿಕ್ಷಣ ಮಟ್ಟ ಆರಿಸಿ';

  @override
  String get selectYourGotra => 'ನಿಮ್ಮ ಗೋತ್ರ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectYourLocationAndPreferences => 'ಸ್ಥಳ ಮತ್ತು ಆದ್ಯತೆ ಆರಿಸಿ';

  @override
  String get selectYourProfession => 'ನಿಮ್ಮ ವೃತ್ತಿ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectYourSurname => 'ನಿಮ್ಮ ಉಪನಾಮ ಆಯ್ಕೆ ಮಾಡಿ';

  @override
  String get selectedPhotos => 'ಆಯ್ದ ಫೋಟೋಗಳು';

  @override
  String get self => 'Self';

  @override
  String get selfEmployed => 'ಸ್ವಯಂ ಉದ್ಯೋಗಿ';

  @override
  String get selfieSubmitted => 'ಸೆಲ್ಫಿ ಸಲ್ಲಿಸಲಾಗಿದೆ';

  @override
  String get send => 'ಕಳುಹಿಸಿ';

  @override
  String get sendInterest => 'ಆಸಕ್ತಿ ಕಳುಹಿಸಿ';

  @override
  String get sendMessage => 'ಸಂದೇಶ ಕಳುಹಿಸಿ';

  @override
  String get sendVerification => 'ಪರಿಶೀಲನೆ ಕಳುಹಿಸಿ';

  @override
  String get sendVerificationRequests => 'ಪರಿಶೀಲನಾ ವಿನಂತಿ ಕಳುಹಿಸಿ';

  @override
  String get setAsPrimary => 'ಪ್ರಾಥಮಿಕವಾಗಿ ಹೊಂದಿಸಿ';

  @override
  String get settings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get settingsAndMenu => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು ಮತ್ತು ಮೆನು';

  @override
  String get sevenHalfToTenLakh => '7.5 - 10 ಲಕ್ಷ';

  @override
  String get share => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get shareBtn => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get shareEducationalBackground =>
      'ನಿಮ್ಮ ಶೈಕ್ಷಣಿಕ ಮತ್ತು ವೃತ್ತಿಪರ ವಿವರಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String shareFailed(String error) {
    return 'ಹಂಚಿಕೊಳ್ಳಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get shareHub => 'ಹಂಚಿಕೆ ಹಬ್';

  @override
  String get shareInApp => 'ಅಪ್ಲಿಕೇಶನ್‌ನಲ್ಲಿ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get shareLimitReached => 'ಹಂಚಿಕೆ ಮಿತಿ ಮೀರಿದೆ';

  @override
  String get shareLinkOnWhatsapp => 'WhatsApp ನಲ್ಲಿ ಲಿಂಕ್ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get shareMyProfileSubtitle =>
      'ನಿಮ್ಮ ಬಯೋಡೇಟಾವನ್ನು ನೇರವಾಗಿ ಹಂಚಿಕೊಳ್ಳುವ ಮೂಲಕ ನಿಮ್ಮ ಆಸಕ್ತಿಯನ್ನು ವ್ಯಕ್ತಪಡಿಸಿ';

  @override
  String shareMyProfileWith(String name) {
    return '$name ಅವರೊಂದಿಗೆ ನನ್ನ ಪ್ರೊಫೈಲ್ ಹಂಚಿಕೊಳ್ಳಿ';
  }

  @override
  String get shareProfile => 'ಪ್ರೊಫೈಲ್ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get shareProfilesWithYourFamilyInstantlyNbui =>
      'ಪ್ರೊಫೈಲ್ ಅನ್ನು ತಕ್ಷಣ ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get shareToSocialMedia => 'ಸೋಷಿಯಲ್ ಮೀಡಿಯಾಗೆ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get shareYourEducationalBackgroundAndProfess =>
      'ನಿಮ್ಮ ಶೈಕ್ಷಣಿಕ ಮತ್ತು ವೃತ್ತಿ ವಿವರ ನೀಡಿ';

  @override
  String get shareYourProfileProfessionally =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ವೃತ್ತಿಪರವಾಗಿ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get shared => 'ಮ್ಯಾಚ್‌ಗಳು';

  @override
  String get sharedProfiles => 'ಹಂಚಿದ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String sharedVia(String name, String method) {
    return '$method ಮೂಲಕ $name ಹಂಚಿಕೊಳ್ಳಲಾಗಿದೆ';
  }

  @override
  String sharesPerMonth(String count) {
    return '$count ಶೇರ್‌ಗಳು/ತಿಂಗಳು';
  }

  @override
  String get sharingBiodataPdf => 'ಬಯೋಡೇಟಾ PDF ಹಂಚಿಕೊಳ್ಳಲಾಗುತ್ತಿದೆ';

  @override
  String get silver => 'ಬೆಳ್ಳಿ';

  @override
  String get silverPlanDesc => 'ಪ್ರಾರಂಭಿಸಲು ಸೂಕ್ತವಾಗಿದೆ';

  @override
  String get silverPlanName => 'ಸಿಲ್ವರ್';

  @override
  String get sister => 'ಸಹೋದರಿ';

  @override
  String get sisterCount => 'ಅಕ್ಕತಂಗಿಯರು';

  @override
  String get skip => 'ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String get smileNaturallyTip => 'ಸ್ನೇಹಪರವಾಗಿ ಕಾಣಲು ನೈಸರ್ಗಿಕವಾಗಿ ಸ್ಮಿತವಾಗಿರಿ';

  @override
  String get socialMediaTextOverlays =>
      'ಪಠ್ಯದ ಓವರ್‌ಲೇಗಳೊಂದಿಗೆ ಸಾಮಾಜಿಕ ಮಾಧ್ಯಮದ ಫೋಟೋಗಳು';

  @override
  String get solicitingMoney => 'ಹಣ ಕೇಳುವುದು';

  @override
  String get someone => 'ಯಾರೋ';

  @override
  String get somethingWentWrong => 'ಏನೋ ತಪ್ಪಾಯಿತು';

  @override
  String get son => 'ಮಗ';

  @override
  String get specifyEducation => 'ಶಿಕ್ಷಣವನ್ನು ನಿರ್ದಿಷ್ಟಪಡಿಸಿ';

  @override
  String get specifyProfession => 'ವೃತ್ತಿಯನ್ನು ನಿರ್ದಿಷ್ಟಪಡಿಸಿ';

  @override
  String get standardProfile => 'ಸಾಮಾನ್ಯ ಪ್ರೊಫೈಲ್';

  @override
  String get start => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get startAConversation => 'Start a conversation';

  @override
  String get startConversation => 'ಸಂಭಾಷಣೆ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get startRecording => 'ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get state => 'ರಾಜ್ಯ';

  @override
  String get statusWaitingForApproval => 'ಸ್ಥಿತಿ: ಅನುಮೋದನೆಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ';

  @override
  String get stay => 'ಇಲ್ಲಿಯೇ ಇರಿ';

  @override
  String stepNOfTotal(int current, int total) {
    return 'ಹಂತ $current / $total';
  }

  @override
  String get student => 'ವಿದ್ಯಾರ್ಥಿ';

  @override
  String get submit => 'ಸಲ್ಲಿಸಿ';

  @override
  String get submitForVerification => 'ಪರಿಶೀಲನೆಗಾಗಿ ಸಲ್ಲಿಸಿ';

  @override
  String get submittedForReview => 'ಪರಿಶೀಲನೆಗಾಗಿ ಸಲ್ಲಿಸಲಾಗಿದೆ';

  @override
  String get subscription => 'ಸದಸ್ಯತ್ವ';

  @override
  String get supportAndHelp => 'ಬೆಂಬಲ ಮತ್ತು ಸಹಾಯ';

  @override
  String get supportBanjarabioApp => 'support@banjarabio.com';

  @override
  String get surname => 'ಉಪನಾಮ';

  @override
  String get swipe => 'ಸ್ಪೈಪ್';

  @override
  String get takePhoto => 'ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get taluka => 'ತಾಲ್ಲೂಕು';

  @override
  String talukaInDistrictState(String district, String state) {
    return '$district, $state ನಲ್ಲಿರುವ ತಾಲೂಕು';
  }

  @override
  String get talukaOptional => 'ತಾಲೂಕು (ಐಚ್ಛಿಕ)';

  @override
  String get tapTheButtonToAddAPhoto => 'ಫೋಟೋ ಸೇರಿಸಲು + ಬಟನ್ ಒತ್ತಿರಿ';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get tapToReveal => '✨ ನೋಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get teacherProfessor => 'ಶಿಕ್ಷಕ/ಪ್ರಾಧ್ಯಾಪಕ';

  @override
  String get telugu => 'ತೆಲುಗು';

  @override
  String get template => 'ಟೆಂಪ್ಲೇಟ್';

  @override
  String get tenToFifteenLakh => '10 - 15 ಲಕ್ಷ';

  @override
  String get terms => 'ನಿಯಮಗಳಿಗೆ';

  @override
  String get termsAndConditions => 'ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು';

  @override
  String get termsConditions => 'ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು';

  @override
  String get termsOfService => 'ಸೇವಾ ನಿಯಮಗಳು';

  @override
  String get termsS1Content =>
      'ಈ ನಿಯಮಗಳು ಭಾರತದ ಕಾನೂನುಗಳಿಗೆ ಒಳಪಟ್ಟಿರುತ್ತವೆ. ಯಾವುದೇ ವಿವಾದಗಳು ಮಹಾರಾಷ್ಟ್ರದ ನ್ಯಾಯಾಲಯಗಳ ವ್ಯಾಪ್ತಿಗೆ ಒಳಪಡುತ್ತವೆ.';

  @override
  String get termsS1Title => '1. ನಿಯಮಗಳ ಅಂಗೀಕಾರ';

  @override
  String get termsS2Content =>
      'ಈ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ನಲ್ಲಿ ನೋಂದಾಯಿಸಲು ನೀವು ಕನಿಷ್ಠ 18 ವರ್ಷ ವಯಸ್ಸಿನವರಾಗಿರಬೇಕು (ಮಹಿಳೆಯರಿಗೆ) ಅಥವಾ 21 ವರ್ಷ ವಯಸ್ಸಿನವರಾಗಿರಬೇಕು (ಪುರುಷರಿಗೆ). ಈ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಕಟ್ಟುನಿಟ್ಟಾಗಿ ವೈವಾಹಿಕ ಉದ್ದೇಶಗಳಿಗಾಗಿ ಮಾತ್ರ.';

  @override
  String get termsS2Title => '2. ಅರ್ಹತೆ';

  @override
  String get termsS3Content =>
      'ನಿಮ್ಮ ಖಾತೆಯ ಮಾಹಿತಿಯ ಗೌಪ್ಯತೆಯನ್ನು ಕಾಪಾಡುವ ಜವಾಬ್ದಾರಿ ನಿಮ್ಮದಾಗಿರುತ್ತದೆ. ನೋಂದಣಿ ಸಮಯದಲ್ಲಿ ಒದಗಿಸಿದ ಎಲ್ಲಾ ಮಾಹಿತಿಗಳು ನಿಖರ ಮತ್ತು ನಿಜವಾಗಿರಬೇಕು.';

  @override
  String get termsS3Title => '3. ಬಳಕೆದಾರ ಖಾತೆ';

  @override
  String get termsS4Content =>
      'ಬಳಕೆದಾರರು ವಾಣಿಜ್ಯ ಉದ್ದೇಶಗಳಿಗಾಗಿ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಬಳಸುವುದನ್ನು, ಕಿರುಕುಳ ನೀಡುವುದನ್ನು, ದ್ವೇಷದ ಭಾಷಣವನ್ನು ಹರಡುವುದನ್ನು ಅಥವಾ ವಂಚನೆಯ ಮಾಹಿತಿ ಹಂಚಿಕೊಳ್ಳುವುದನ್ನು ನಿಷೇಧಿಸಲಾಗಿದೆ.';

  @override
  String get termsS4Title => '4. ನಿಷೇಧಿತ ಚಟುವಟಿಕೆಗಳು';

  @override
  String get termsS5Content =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿನ \"ಖಾತೆ ಅಳಿಸಿ\" ವಿಭಾಗದ ಮೂಲಕ ನೀವು ಯಾವುದೇ ಸಮಯದಲ್ಲಿ ಖಾತೆ ಅಳಿಸುವಿಕೆಯನ್ನು ಕೋರಬಹುದು.';

  @override
  String get termsS5Title => '5. ಖಾತೆ ಅಳಿಸುವಿಕೆ';

  @override
  String get termsS6Content =>
      'ಬಂಜಾರಬಯೋ ಸಂಬಂಧಗಳನ್ನು ಹುಡುಕುವ ಒಂದು ವೇದಿಕೆಯಾಗಿದೆ. ನಾವು ಯಶಸ್ವಿ ಸಂಬಂಧದ ಗ್ಯಾರಂಟಿ ನೀಡುವುದಿಲ್ಲ ಅಥವಾ ಮೂಲಭೂತ ತಪಾಸಣೆಗಳನ್ನು ಹೊರತುಪಡಿಸಿ ಬಳಕೆದಾರರ ಗುಣಲಕ್ಷಣವನ್ನು ಪರಿಶೀಲಿಸುವುದಿಲ್ಲ.';

  @override
  String get termsS6Title => '6. ಹೊಣೆಗಾರಿಕೆಯ ಮಿತಿ';

  @override
  String get termsS7Content =>
      'ಈ ನಿಯಮಗಳಿಗೆ ಸಂಬಂಧಿಸಿದಂತೆ ನೀವು ಯಾವುದೇ ಪ್ರಶ್ನೆಗಳನ್ನು ಹೊಂದಿದ್ದರೆ, ದಯವಿಟ್ಟು ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ ವಿಭಾಗದ ಮೂಲಕ ನಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get termsS7Title => '7. ನಿಯಂತ್ರಕ ಕಾನೂನು';

  @override
  String get termsTitle => 'ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು';

  @override
  String get textSuper => 'ಸೂಪರ್';

  @override
  String get thisFieldIsRequired => 'ಈ ಕ್ಷೇತ್ರ ಅಗತ್ಯ';

  @override
  String get totalCount => 'ಒಟ್ಟು:';

  @override
  String get totalProfiles => 'Total Profiles';

  @override
  String get traditionalFormalAttire =>
      'ಸಾಂಪ್ರದಾಯಿಕ ಅಥವಾ ಔಪಚಾರಿಕ ಉಡುಗೆ (ಸೀರೆ, ಸಲ್ವಾರ್ ಕಮೀಜ್, ಕುರ್ತಾ)';

  @override
  String get trustScore => 'ನಂಬಿಕೆ ಸ್ಕೋರ್';

  @override
  String get trustScoreBeyondBeauty => 'ಸೌಂದರ್ಯ ಮೀರಿ ವಿಶ್ವಾಸದ ಸ್ಕೋರ್';

  @override
  String get trustScoreDiscounts => 'ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್ ಮತ್ತು ರಿಯಾಯಿತಿ';

  @override
  String trustScoreShareMessage(String score, String url) {
    return 'ನಾನು ಈಗಷ್ಟೇ ಬಂಜಾರಬಯೋದಲ್ಲಿ $score ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್‌ನೊಂದಿಗೆ ನನ್ನ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಪರಿಶೀಲಿಸಿದ್ದೇನೆ! ನನ್ನ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ನಮ್ಮ ಸಮುದಾಯಕ್ಕೆ ಸೇರಿ: $url';
  }

  @override
  String get trustVerification => 'ವಿಶ್ವಾಸ ಮತ್ತು ಪರಿಶೀಲನೆ';

  @override
  String get trusted => 'ವಿಶ್ವಾಸಾರ್ಹ';

  @override
  String get trustedMember => 'Trusted Member';

  @override
  String get trustedProfile => 'ವಿಶ್ವಾಸಾರ್ಹ ಪ್ರೊಫೈಲ್';

  @override
  String get tryAdjustingYourFilterCriteria => 'ಫಿಲ್ಟರ್ ಬದಲಾಯಿಸಲು ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get tryAdjustingYourFiltersToSeeMoreProfiles =>
      'ಹೆಚ್ಚಿನ ಪ್ರೊಫೈಲ್ ನೋಡಲು ಫಿಲ್ಟರ್ ಹೊಂದಿಸಿ';

  @override
  String get tryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get trySearchingForADifferentCity => 'ಬೇರೆ ನಗರ ಹುಡುಕಲು ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get trySearchingForDifferentCity =>
      'ಬೇರೆ ನಗರಕ್ಕಾಗಿ ಹುಡುಕಲು ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get twentyLakhPlus => '₹20 ಲಕ್ಷ+';

  @override
  String get twoToFiveLakh => '₹2 - ₹5 ಲಕ್ಷ';

  @override
  String get typeAMessage => 'ಸಂದೇಶ ಬರೆಯಿರಿ...';

  @override
  String get typeMessage => 'ಸಂದೇಶ ಟೈಪ್ ಮಾಡಿ...';

  @override
  String get unauthorizedAccessAdminsOnly =>
      'ಅನಧಿಕೃತ ಪ್ರವೇಶ. ಅಡ್ಮಿನ್‌ಗಳಿಗೆ ಮಾತ್ರ.';

  @override
  String get under2Lakh => '₹2 ಲಕ್ಷಕ್ಕಿಂತ ಕಡಿಮೆ';

  @override
  String get undo => 'ರದ್ದುಮಾಡು';

  @override
  String unexpectedError(String error) {
    return 'ಅನಿರೀಕ್ಷಿತ ದೋಷ ಸಂಭವಿಸಿದೆ: $error';
  }

  @override
  String unexpectedErrorOccurred(String error) {
    return 'ಅನಿರೀಕ್ಷಿತ ದೋಷ ಸಂಭವಿಸಿದೆ: $error';
  }

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get unlimitedBookmarks => 'ಅನಿಯಮಿತ ಬುಕ್‌ಮಾರ್ಕ್‌ಗಳು';

  @override
  String get unlimitedProfileViews => 'ಅನಿಯಮಿತ ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಣೆಗಳು';

  @override
  String get unlimitedSharing => 'ಅನಿಯಮಿತ ಹಂಚಿಕೆ';

  @override
  String get unlockAdvancedFilters => 'ಸುಧಾರಿತ ಫಿಲ್ಟರ್‌ಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಿ';

  @override
  String get unlockNow => 'ಈಗ ಅನ್‌ಲಾಕ್ ಮಾಡಿ';

  @override
  String get unlockPremiumBiodata => 'ಪ್ರೀಮಿಯಂ ಬಯೋಡೇಟಾ ಅನ್‌ಲಾಕ್ ಮಾಡಿ';

  @override
  String get unlockPremiumFeaturesToEnhanceYourBiodat =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಸುಧಾರಿಸಲು ಪ್ರೀಮಿಯಂ ಬಳಸಿ';

  @override
  String get unlockToDownload =>
      'ಈ ಟೆಂಪ್ಲೇಟ್ ಅನ್ನು 5+ ಭಾಷೆಗಳಲ್ಲಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ಮತ್ತು ಹಂಚಿಕೊಳ್ಳಲು ಅನ್‌ಲಾಕ್ ಮಾಡಿ.';

  @override
  String get unmarried => 'ಅವಿವಾಹಿತ';

  @override
  String get unsave => 'ಅನ್‌ಸೇವ್';

  @override
  String get update => 'ನವೀಕರಿಸಿ';

  @override
  String get updateProfile => 'ಪ್ರೊಫೈಲ್ ಅಪ್‌ಡೇಟ್ ಮಾಡಿ';

  @override
  String get upgrade => 'ಅಪ್‌ಗ್ರೇಡ್';

  @override
  String get upgradeNow => 'ಈಗ ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String get upgradePlan => 'ಪ್ಲಾನ್ ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String get upgradePremiumFilters =>
      'ವೃತ್ತಿ, ಸ್ಥಳ ಮತ್ತು ಹೆಚ್ಚಿನ ಫಿಲ್ಟರ್‌ಗಳಿಗೆ ಪ್ರೀಮಿಯಂಗೆ ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ.';

  @override
  String get upgradeRequired => 'ಅಪ್‌ಗ್ರೇಡ್ ಅಗತ್ಯವಿದೆ';

  @override
  String get upgradeToPremium => 'ಪ್ರೀಮಿಯಂಗೆ ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String get upgradeToPremiumFor6PhotosAdvancedFilter =>
      'ಹೆಚ್ಚಿನ ಫೋಟೋ ಮತ್ತು ಫಿಲ್ಟರ್‌ಗಾಗಿ ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String get upgradeToPremiumToAccessGranularFiltersF =>
      'Upgrade to Premium to access granular filters';

  @override
  String get upgradeToUnlockAllFeatures =>
      'ಎಲ್ಲಾ ವೈಶಿಷ್ಟ್ಯ ಅನ್‌ಲಾಕ್ ಮಾಡಲು ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String get uploadCommunityCertificateLetter =>
      'ಸಮುದಾಯ ಪ್ರಮಾಣಪತ್ರ / ಪತ್ರ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get uploadYourPhotos => 'ನಿಮ್ಮ ಉತ್ತಮ ಫೋಟೋಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get uploadedSuccessfully => 'ಯಶಸ್ವಿಯಾಗಿ ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get upperMiddleClass => 'ಉನ್ನತ ಮಧ್ಯಮ ವರ್ಗ';

  @override
  String get useCameraToCapture => 'ಸೆರೆಹಿಡಿಯಲು ಕ್ಯಾಮೆರಾ ಬಳಸಿ';

  @override
  String get useCurrentLocation => 'ಪ್ರಸ್ತುತ ಸ್ಥಳ ಬಳಸಿ';

  @override
  String get useEmailPassword => 'ಇಮೇಲ್ / ಪಾಸ್‌ವರ್ಡ್ ಬಳಸಿ';

  @override
  String get useNaturalLightingTip =>
      'ಉತ್ತಮ ಫಲಿತಾಂಶಗಳಿಗಾಗಿ ನೈಸರ್ಗಿಕ ಬೆಳಕನ್ನು ಬಳಸಿ';

  @override
  String get userBlockedSuccessfully =>
      'ಬಳಕೆದಾರರನ್ನು ಯಶಸ್ವಿಯಾಗಿ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ';

  @override
  String get userIdNotFound => 'ಬಳಕೆದಾರ ಐಡಿ ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get userIdNotFoundToast => 'User ID not found';

  @override
  String get userLabel => 'ಬಳಕೆದಾರ';

  @override
  String get userNotUploadedPhoto => 'ಬಳಕೆದಾರರು ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿಲ್ಲ';

  @override
  String get users => 'Users';

  @override
  String get usingGps => 'GPS ಬಳಸಲಾಗುತ್ತಿದೆ';

  @override
  String get verificationBadge => 'ಪರಿಶೀಲನಾ ಬ್ಯಾಡ್ಜ್';

  @override
  String get verificationCodeSent => 'ಪರಿಶೀಲನಾ ಕೋಡ್ ಕಳುಹಿಸಲಾಗಿದೆ!';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get verificationLinkcodeSent => 'ಪರಿಶೀಲನಾ ಲಿಂಕ್/ಕೋಡ್ ಕಳುಹಿಸಲಾಗಿದೆ!';

  @override
  String get verificationRequests => 'Verification Requests';

  @override
  String get verifications => 'Verifications';

  @override
  String get verified => 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get verified10PointsAddedToTrustScore =>
      'ಪರಿಶೀಲಿಸಲಾಗಿದೆ! ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್‌ಗೆ +10 ಅಂಕಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String get verifiedCommunityMember => 'ಪರಿಶೀಲಿತ ಸಮುದಾಯ ಸದಸ್ಯ';

  @override
  String get verifiedProfile => 'ಪರಿಶೀಲಿಸಿದ ಪ್ರೊಫೈಲ್';

  @override
  String get verifiedProfileBadge => 'ಪರಿಶೀಲಿಸಿದ ಪ್ರೊಫೈಲ್';

  @override
  String get verifiedProfilesGet5xMoreResponses =>
      'ಪರಿಶೀಲಿಸಿದ ಪ್ರೊಫೈಲ್‌ಗಳು 5 ಪಟ್ಟು ಹೆಚ್ಚು ಪ್ರತಿಕ್ರಿಯೆಗಳನ್ನು ಪಡೆಯುತ್ತವೆ ಮತ್ತು ಹುಡುಕಾಟ ಫಲಿತಾಂಶಗಳಲ್ಲಿ ಉನ್ನತವಾಗಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ.';

  @override
  String get verifiedTrusted => 'ಪರಿಶೀಲಿಸಿದ ಮತ್ತು ವಿಶ್ವಾಸಾರ್ಹ';

  @override
  String get verify => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get verifyEmailAddressHeading => 'Verify Email Address';

  @override
  String verifyLabel(String label) {
    return '$label ಪರಿಶೀಲಿಸಿ';
  }

  @override
  String get verifyMobile => 'ಮೊಬೈಲ್ ಪರಿಶೀಲಿಸಿ';

  @override
  String get verifyNow => 'ಈಗ ಪರಿಶೀಲಿಸಿ';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get verifyYourCommunityStatus => 'ನಿಮ್ಮ ಸಮುದಾಯ ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ';

  @override
  String get verifyYourEmailAddressToAddTrustAndReach =>
      'ನಂಬಿಕೆ ಹೆಚ್ಚಿಸಲು ನಿಮ್ಮ ಇಮೇಲ್ ವಿಳಾಸ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get verifyYourMobileNumberToAddTrustAndReach =>
      'ನಂಬಿಕೆ ಹೆಚ್ಚಿಸಲು ಮತ್ತು ಹೆಚ್ಚಿನ ಪ್ರೊಫೈಲ್ ತಲುಪಲು ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get veryFair => 'ಬಹಳ ಬಿಳಿ';

  @override
  String get videoBioIntro => 'ವೀಡಿಯೊ ಬಯೋ / ಪರಿಚಯ';

  @override
  String get videoIntro => 'ವೀಡಿಯೊ ಪರಿಚಯ';

  @override
  String get videoIntroUploaded => 'ವೀಡಿಯೊ ಪರಿಚಯ ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get videoRecorded => 'ವೀಡಿಯೊ ರೆಕಾರ್ಡ್ ಆಗಿದೆ!';

  @override
  String get view => 'ವೀಕ್ಷಿಸಿ';

  @override
  String get viewAll => 'ಎಲ್ಲವನ್ನೂ ನೋಡಿ';

  @override
  String get viewBiodata => 'ಬಯೋಡೇಟಾ ವೀಕ್ಷಿಸಿ';

  @override
  String get viewDetails => 'ವಿವರಗಳನ್ನು ವೀಕ್ಷಿಸಿ';

  @override
  String get viewLabel => 'ನೋಟ';

  @override
  String get viewProfile => 'ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಿಸಿ';

  @override
  String get viewYourBookmarkedProfiles => 'ಬುಕ್‌ಮಾರ್ಕ್ ಮಾಡಿದ ಪ್ರೊಫೈಲ್ ನೋಡಿ';

  @override
  String get viewsLabel => 'ನೋಟಗಳು';

  @override
  String get village => 'ಗ್ರಾಮ';

  @override
  String get visibleToAllProfiles => 'ಎಲ್ಲರಿಗೂ ಕಾಣಿಸುತ್ತದೆ';

  @override
  String get visibleToCloseMatchesOnly => 'ಹತ್ತಿರದವರಿಗೆ ಮಾತ್ರ ಕಾಣಿಸುತ್ತದೆ';

  @override
  String get weEncounteredAnUnexpectedErrorWhileProce =>
      'ವಿನಂತಿ ಪ್ರಕ್ರಿಯೆಗೊಳಿಸುವಾಗ ದೋಷ ಸಂಭವಿಸಿದೆ.';

  @override
  String get weWillSendAVerificationRequestToTheirMob =>
      'ನಾವು ಅವರ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಗೆ ವಿನಂತಿ ಕಳುಹಿಸುತ್ತೇವೆ. ಅವರು ಅನುಮೋದಿಸಿದರೆ, ನೀವು +10 ಅಂಕ ಪಡೆಯುತ್ತೀರಿ.';

  @override
  String get weWillVerifyYourCommunityDetailsShortly1 =>
      'ನಿಮ್ಮ ಸಮುದಾಯ ವಿವರಗಳನ್ನು ನಾವು ಶೀಘ್ರದಲ್ಲೇ ಪರಿಶೀಲಿಸುತ್ತೇವೆ. +15 ಅಂಕಗಳು ಬಾಕಿ ಇವೆ.';

  @override
  String get welcomeToBanjaraBio => 'ಬಂಜಾರ ಬಯೋಗೆ ಸ್ವಾಗತ';

  @override
  String get whatDoYouLookFor => 'ಸಂಗಾತಿಯಲ್ಲಿ ನೀವು ಏನು ಹುಡುಕುತ್ತೀರಿ?';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get whatsAppContact => 'ವಾಟ್ಸಾಪ್ ಸಂಪರ್ಕ';

  @override
  String whatsappShareSubtitle(String name) {
    return '$name ವಿವರಗಳನ್ನು ಕುಟುಂಬ ಅಥವಾ ಸ್ನೇಹಿತರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಿ';
  }

  @override
  String get whatsappSupport => 'WhatsApp ಬೆಂಬಲ';

  @override
  String get wheatish => 'ಗೋಧಿ ಬಣ್ಣ';

  @override
  String get whereDoYouWork => 'ನೀವು ಎಲ್ಲಿ ಕೆಲಸ ಮಾಡುತ್ತೀರಿ?';

  @override
  String get whoViewedMe => 'ನನ್ನನ್ನು ಯಾರು ನೋಡಿದರು';

  @override
  String get whyBanjaraBio => 'ಬಂಜಾರ ಬಯೋ ಏಕೆ?';

  @override
  String get widowed => 'ವಿಧವೆ/ವಿಧುರ';

  @override
  String get writeAboutYourself => 'ನಿಮ್ಮ ಬಗ್ಗೆ ಏನಾದರೂ ಬರೆಯಿರಿ...';

  @override
  String get year => 'ವರ್ಷ';

  @override
  String yearsOld(String age) {
    return '$age ವರ್ಷ';
  }

  @override
  String get upgradeToShareMore => 'ಹೆಚ್ಚು ಹಂಚಿಕೊಳ್ಳಲು ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ';

  @override
  String get yes => 'ಹೌದು';

  @override
  String get yesterday => 'ನಿನ್ನೆ';

  @override
  String get youNeedAProfileToShareIt =>
      'ಹಂಚಿಕೊಳ್ಳಲು ನಿಮಗೆ ಪ್ರೊಫೈಲ್ ಅಗತ್ಯವಿದೆ.';

  @override
  String get youWillNoLongerSeeThisProfile =>
      'ನೀವು ಇನ್ನು ಮುಂದೆ ಈ ಪ್ರೊಫೈಲ್ ಅನ್ನು ನೋಡುವುದಿಲ್ಲ';

  @override
  String get youngerBrother => 'ತಮ್ಮ';

  @override
  String get youngerSister => 'ತಂಗಿ';

  @override
  String get your => 'ನಿಮ್ಮ';

  @override
  String get yourDailyMatches => 'ನಿಮ್ಮ ದೈನಂದಿನ ಪಂದ್ಯಗಳು';

  @override
  String get yourDocumentsAreEncrypted =>
      'ನಿಮ್ಮ ದಾಖಲೆಗಳನ್ನು ಎನ್‌ಕ್ರಿಪ್ಟ್ ಮಾಡಲಾಗಿದೆ ಮತ್ತು ಇತರ ಬಳಕೆದಾರರಿಗೆ ಎಂದಿಗೂ ತೋರಿಸಲಾಗುವುದಿಲ್ಲ. ಬ್ಯಾಡ್ಜ್ ಮಾತ್ರ ಗೋಚರಿಸುತ್ತದೆ.';

  @override
  String get yourDocumentsHaveBeenSubmittedSecurelyWe =>
      'ನಿಮ್ಮ ದಾಖಲೆಗಳನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಸಲ್ಲಿಸಲಾಗಿದೆ. ಪರಿಶೀಲಿಸಿದ ನಂತರ ನಾವು ನಿಮಗೆ ತಿಳಿಸುತ್ತೇವೆ.';

  @override
  String get yourIntroVideoIsUnderReview10PointsPendi =>
      'ನಿಮ್ಮ ಪರಿಚಯ ವೀಡಿಯೊ ಪರಿಶೀಲನೆಯಲ್ಲಿದೆ. +10 ಅಂಕಗಳು ಬಾಕಿ ಇವೆ.';

  @override
  String get yourMatchesWillAppearHereOnceYouBothExpr =>
      'ನೀವಿಬ್ಬರೂ ಆಸಕ್ತಿ ವ್ಯಕ್ತಪಡಿಸಿದ ನಂತರ ನಿಮ್ಮ ಹೊಂದಾಣಿಕೆಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ. ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳುತ್ತಿರಿ!';

  @override
  String get yourPersonalInviteLink => 'ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಆಹ್ವಾನ ಲಿಂಕ್';

  @override
  String get yourReferralCode => 'ನಿಮ್ಮ ರೆಫರಲ್ ಕೋಡ್';

  @override
  String get yourSelfieHasBeenSubmittedOurTeamWillVer =>
      'ನಿಮ್ಮ ಸೆಲ್ಫಿ ಸಲ್ಲಿಸಲಾಗಿದೆ. ನಮ್ಮ ತಂಡವು ಅದನ್ನು ಪರಿಶೀಲಿಸುತ್ತದೆ.';

  @override
  String get yourTrustScore => 'ನಿಮ್ಮ ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್';

  @override
  String yrs(Object count) {
    return '$count ವರ್ಷ';
  }

  @override
  String get itSAMatch => 'ಹೊಂದಾಣಿಕೆಯಾಗಿದೆ!';

  @override
  String sharedProfilesWithEachOther(String name) {
    return 'ನೀವು ಮತ್ತು $name ಪರಸ್ಪರ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಹಂಚಿಕೊಂಡಿದ್ದೀರಿ.';
  }

  @override
  String get mutualMatch => 'ಪರಸ್ಪರ ಹೊಂದಾಣಿಕೆ';

  @override
  String toContact(Object name) {
    return 'ಇವರಿಗೆ: $name';
  }

  @override
  String fromContact(Object name) {
    return 'ಇವರಿಂದ: $name';
  }

  @override
  String countProfileViews(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಣೆಗಳು',
      one: '1 ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಣೆ',
    );
    return '$_temp0';
  }

  @override
  String get matchedBadge => 'ಹೊಂದಿಕೆಯಾಗಿದೆ';

  @override
  String get premiumBadge => 'ಪ್ರೀಮಿಯಂ';

  @override
  String get contactLabel => 'ಸಂಪರ್ಕ';

  @override
  String profileSharedVia(Object profileName, Object title) {
    return '$title ಮೂಲಕ $profileName ಹಂಚಿಕೊಳ್ಳಲಾಗಿದೆ';
  }

  @override
  String failedToSendMessage(String error) {
    return 'ಸಂದೇಶ ಕಳುಹಿಸಲು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String uploadFailed(String error) {
    return 'ಅಪ್‌ಲೋಡ್ ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String updateFailed(String error) {
    return 'ಅಪ್‌ಡೇಟ್ ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String errorWithLabel(String label) {
    return 'ದೋಷ: $label';
  }

  @override
  String referenceWithNumber(int number) {
    return 'ಉಲ್ಲೇಖ $number';
  }

  @override
  String get villageTanda => 'ಗ್ರಾಮ / ತಾಂಡಾ';

  @override
  String get ageLabel => 'ವಯಸ್ಸು';

  @override
  String get heightLabel => 'ಎತ್ತರ';

  @override
  String get surnameLabel => 'ಮನೆತನದ ಹೆಸರು';

  @override
  String get dateOfBirthLabel => 'ಹುಟ್ಟಿದ ದಿನಾಂಕ';

  @override
  String get birthTimeLabel => 'ಹುಟ್ಟಿದ ಸಮಯ';

  @override
  String get birthPlaceLabel => 'ಹುಟ್ಟಿದ ಸ್ಥಳ';

  @override
  String get bloodGroupLabel => 'ರಕ್ತದ ಗುಂಪು';

  @override
  String get occupationLabel => 'ವೃತ್ತಿ';

  @override
  String get annualIncomeLabel => 'ವಾರ್ಷಿಕ ಆದಾಯ';

  @override
  String get currentResidence => 'ಪ್ರಸ್ತುತ ನಿವಾಸ';

  @override
  String get contactPersonLabel => 'ಸಂಪರ್ಕ ವ್ಯಕ್ತಿ';

  @override
  String get bestTimeToContact => 'ಸಂಪರ್ಕಿಸಲು ಉತ್ತಮ ಸಮಯ';

  @override
  String get limitReached => 'ಮಿತಿ ಮೀರಿದೆ';

  @override
  String get relationLabel => 'ಸಂಬಂಧ';

  @override
  String get none => 'ಯಾವುದೂ ಇಲ್ಲ';

  @override
  String yearsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ವರ್ಷಗಳು',
      one: 'ವರ್ಷ',
    );
    return '$_temp0';
  }

  @override
  String brothersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಹೋದರರು',
      one: '1 ಸಹೋದರ',
    );
    return '$_temp0';
  }

  @override
  String sistersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಸಹೋದರಿಯರು',
      one: '1 ಸಹೋದರಿ',
    );
    return '$_temp0';
  }

  @override
  String get siblingsLabel => 'ಸಹೋದರ-ಸಹೋದರಿಯರು';

  @override
  String siblingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಒಡಹುಟ್ಟಿದವರು',
      one: '1 ಒಡಹುಟ್ಟಿದವರು',
    );
    return '$_temp0';
  }

  @override
  String get company => 'ಕಂಪನಿ';

  @override
  String get job => 'ಕೆಲಸ / ಉದ್ಯೋಗ';

  @override
  String get biodataRequired => 'Biodata Required';

  @override
  String get guestRestrictionMessage =>
      'To interact with profiles, express interest, or send messages, you need to create your own biodata first.';

  @override
  String get createNow => 'Create Now';

  @override
  String get tourLocationTitle => 'Select Location';

  @override
  String get tourLocationDesc =>
      'Filter profiles by State, District, or Taluka to find matches near you.';

  @override
  String get tourSearchTitle => 'Search Profiles';

  @override
  String get tourSearchDesc =>
      'Looking for someone specific? Type their name or education here.';

  @override
  String get tourFilterTitle => 'Advanced Filters';

  @override
  String get tourFilterDesc =>
      'Narrow down by Age, Education, or Profession to see only who you want.';

  @override
  String get tourChatTitle => 'Messages & Chat';

  @override
  String get tourChatDesc =>
      'View your conversations and incoming interests here.';

  @override
  String get tourBottomHome => 'Home Feed';

  @override
  String get tourBottomHomeDesc =>
      'Scroll through thousands of verified profiles.';

  @override
  String get tourBottomShared => 'Shared Profiles';

  @override
  String get tourBottomSharedDesc =>
      'See profiles you\'ve shared or received via WhatsApp/Link.';

  @override
  String get tourBottomProfile => 'Your Profile';

  @override
  String get tourBottomProfileDesc =>
      'Manage your own biodata and photos here.';

  @override
  String get tourBottomSettings => 'App Settings';

  @override
  String get tourBottomSettingsDesc =>
      'Change language, notification settings, or contact support.';

  @override
  String get tourWhatsappTitle => 'WhatsApp Support';

  @override
  String get tourWhatsappDesc =>
      'Direct contact with our admin for help or profile changes.';

  @override
  String get tourInstagramTitle => 'Follow Us';

  @override
  String get tourInstagramDesc =>
      'See daily new profiles and success stories on Instagram.';

  @override
  String get tourBookmarkTitle => 'Save for later';

  @override
  String get tourBookmarkDesc =>
      'Found a profile you like? Bookmark it to view it later in your Saved list.';

  @override
  String get tourInterestTitle => 'Express Interest';

  @override
  String get tourInterestDesc =>
      'Send a heart to let them know you\'re interested in their biodata.';

  @override
  String get tourShareTitle => 'Share with family';

  @override
  String get tourShareDesc =>
      'Easily share profiles via WhatsApp with your parents or relatives for their opinion.';

  @override
  String get chooseHowToStart =>
      'ನೀವು ಹೇಗೆ ಪ್ರಾರಂಭಿಸಲು ಬಯಸುತ್ತೀರಿ ಎಂಬುದನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get exploreAsGuest => 'ಅತಿಥಿಯಾಗಿ ಅನ್ವೇಷಿಸಿ';

  @override
  String get exitGuestMode => 'ಗೆಸ್ಟ್ ಮೋಡ್‌ನಿಂದ ನಿರ್ಗಮಿಸಿ';

  @override
  String get guestModeDesc =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ರಚಿಸುವ ಮೊದಲು ಅಪ್ಲಿಕೇಶನ್‌ನ ಮಾರ್ಗದರ್ಶಿ ಪ್ರವಾಸವನ್ನು ತೆಗೆದುಕೊಳ್ಳಿ.';

  @override
  String get createMyBiodata => 'ನನ್ನ ಬಯೋಡೇಟಾವನ್ನು ರಚಿಸಿ';

  @override
  String get createBiodataDesc =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಭರ್ತಿ ಮಾಡಿ ಮತ್ತು ತಕ್ಷಣ ಸಂಪರ್ಕಿಸಲು ಪ್ರಾರಂಭಿಸಿ.';

  @override
  String get needHelpContactAdmin => 'ಸಹಾಯ ಬೇಕೇ? ನಿರ್ವಾಹಕರನ್ನು ಸಂಪರ್ಕಿಸಿ';

  @override
  String get noMatchesYet => 'ಇನ್ನೂ ಯಾವುದೇ ಮ್ಯಾಚ್‌ಗಳಿಲ್ಲ';

  @override
  String get noProfilesSharedYet => 'ಇನ್ನೂ ಯಾವುದೇ ಪ್ರೊಫೈಲ್ ಹಂಚಿಕೊಂಡಿಲ್ಲ';

  @override
  String get noProfilesReceived => 'ಯಾವುದೇ ಪ್ರೊಫೈಲ್ ಸ್ವೀಕರಿಸಿಲ್ಲ';

  @override
  String get mutualMatchesDesc =>
      'ಇಬ್ಬರು ಬಳಕೆದಾರರು ಪರಸ್ಪರ ಆಸಕ್ತಿಯನ್ನು ಹಂಚಿಕೊಂಡಾಗ ಪರಸ್ಪರ ಮ್ಯಾಚ್‌ಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ';

  @override
  String get startSharingProfilesDesc =>
      'ಪರಿಪೂರ್ಣ ಮ್ಯಾಚ್ ಅನ್ನು ಹುಡುಕಲು ಸಹಾಯ ಮಾಡಲು ಕುಟುಂಬ ಮತ್ತು ಸ್ನೇಹಿತರೊಂದಿಗೆ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಲು ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get profilesSharedWithYouDesc =>
      'ನಿಮ್ಮ ಕುಟುಂಬ ಮತ್ತು ಸ್ನೇಹಿತರಿಂದ ನಿಮ್ಮೊಂದಿಗೆ ಹಂಚಿಕೊಂಡ ಪ್ರೊಫೈಲ್‌ಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ';

  @override
  String get enterVillageManually => 'ಗ್ರಾಮ/ಇತರ ಹೆಸರನ್ನು ನಮೂದಿಸಿ';

  @override
  String get enterVillageHint => 'ಗ್ರಾಮ ಅಥವಾ ತಾಂಡಾ ಹೆಸರನ್ನು ನಮೂದಿಸಿ...';

  @override
  String get specificLocation => 'ನಿರ್ದಿಷ್ಟ ಸ್ಥಳ';

  @override
  String get skipAndSelectLevel =>
      'ಬಿಟ್ಟುಬಿಡಿ ಮತ್ತು ತಾಲ್ಲೂಕು/ಜಿಲ್ಲೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get optional => 'ಐಚ್ಛಿಕ';

  @override
  String get tourMatchesSearchTitle => 'ಹಂಚಿಕೊಂಡ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get tourMatchesSearchDesc =>
      'ಹೆಸರು ಅಥವಾ ಶಿಕ್ಷಣವನ್ನು ಬಳಸಿಕೊಂಡು ನಿಮ್ಮೊಂದಿಗೆ ಅಥವಾ ನೀವು ಹಂಚಿಕೊಂಡ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ತ್ವರಿತವಾಗಿ ಹುಡುಕಿ.';

  @override
  String get tourMatchesSentTitle => 'ಕಳುಹಿಸಿದ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get tourMatchesSentDesc =>
      'ನೀವು ಕುಟುಂಬ ಮತ್ತು ಸ್ನೇಹಿತರೊಂದಿಗೆ ಹಂಚಿಕೊಂಡ ಎಲ್ಲಾ ಪ್ರೊಫೈಲ್‌ಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ.';

  @override
  String get tourMatchesReceivedTitle => 'ಸ್ವೀಕರಿಸಿದ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get tourMatchesReceivedDesc =>
      'ವಾಟ್ಸಾಪ್ ಅಥವಾ ಲಿಂಕ್ ಮೂಲಕ ಇತರರು ನಿಮ್ಮೊಂದಿಗೆ ಹಂಚಿಕೊಂಡ ಪ್ರೊಫೈಲ್‌ಗಳು.';

  @override
  String get tourMatchesMatchedTitle => 'ಹೊಂದಾಣಿಕೆಯಾದ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get tourMatchesMatchedDesc =>
      'ಇಬ್ಬರೂ ಪರಸ್ಪರ ಆಸಕ್ತಿ ವ್ಯಕ್ತಪಡಿಸಿದ ಪಂದ್ಯಗಳು!';

  @override
  String get tourProfilePhotosTitle => 'ಫೋಟೋಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get tourProfilePhotosDesc =>
      'ಉತ್ತಮ ಪ್ರಭಾವ ಬೀರಲು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಫೋಟೋಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ, ಮರುಹೊಂದಿಸಿ ಅಥವಾ ಅಳಿಸಿ.';

  @override
  String get tourProfileTrustTitle => 'ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್';

  @override
  String get tourProfileTrustDesc =>
      'ನಿಮ್ಮ ವಿಶ್ವಾಸಾರ್ಹತೆಯ ಸ್ಕೋರ್. ಇದನ್ನು ಹೆಚ್ಚಿಸಲು ನಿಮ್ಮ ಐಡಿ, ಸೆಲ್ಫಿ ಮತ್ತು ಸಮುದಾಯವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get tourProfilePdfTitle => 'ಬಯೋಡೇಟಾ PDF ರಫ್ತು ಮಾಡಿ';

  @override
  String get tourProfilePdfDesc =>
      'ನಿಮ್ಮ ಬಯೋಡೇಟಾದ ವೃತ್ತಿಪರ PDF ಅನ್ನು ರಚಿಸಿ ಮತ್ತು ಕುಟುಂಬದ ಸದಸ್ಯರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get tourProfileSavedTitle => 'ಉಳಿಸಿದ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get tourProfileSavedDesc =>
      'ನಂತರ ವೀಕ್ಷಿಸಲು ನೀವು ಬುಕ್‌ಮಾರ್ಕ್ ಮಾಡಿದ ಎಲ್ಲಾ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ನೋಡಿ.';

  @override
  String get tourProfileEditTitle => 'ಪ್ರೊಫೈಲ್ ಎಡಿಟ್ ಮಾಡಿ';

  @override
  String get tourProfileEditDesc =>
      'ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ವಿವರಗಳು, ಫೋಟೋಗಳು ಮತ್ತು ಆದ್ಯತೆಗಳನ್ನು ಯಾವಾಗ ಬೇಕಾದರೂ ಅಪ್‌ಡೇಟ್ ಮಾಡಿ.';

  @override
  String get basicPlanName => 'ಬೇಸಿಕ್';

  @override
  String get premiumPlanName => 'ಪ್ರೀಮಿಯಂ';

  @override
  String get vipPlanName => 'ವಿಐಪಿ';

  @override
  String get basicPlanDesc => 'ನಿಮ್ಮ ಹುಡುಕಾಟಕ್ಕೆ ಅಗತ್ಯವಿರುವ ವೈಶಿಷ್ಟ್ಯಗಳು';

  @override
  String get premiumPlanDesc => 'ಸುಧಾರಿತ ವೈಶಿಷ್ಟ್ಯಗಳು ಮತ್ತು ಉತ್ತಮ ಗೋಚರತೆ';

  @override
  String get vipPlanDesc => 'ಆದ್ಯತೆಯ ಬೆಂಬಲದೊಂದಿಗೆ ಅತ್ಯುತ್ತಮ ಅನುಭವ';

  @override
  String get paymentSuccessfulPdfUnlocked =>
      'ಪಾವತಿ ಯಶಸ್ವಿಯಾಗಿದೆ! PDF ಅನ್‌ಲಾಕ್ ಆಗಿದೆ.';

  @override
  String get standardPlanName => 'ಸ್ಟ್ಯಾಂಡರ್ಡ್';

  @override
  String get standardPlanDesc =>
      'ಒಂದು ತಿಂಗಳವರೆಗೆ ಪ್ರೀಮಿಯಂ ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get eternalPlanName => 'ಎಟರ್ನಲ್ - ಮದುವೆಯಾಗುವವರೆಗೆ';

  @override
  String get eternalPlanDesc => 'ಅವಧಿ ಮುಗಿಯುವ ಬಗ್ಗೆ ಇನ್ನು ಮುಂದೆ ಚಿಂತಿಸಬೇಡಿ';

  @override
  String get elitePlanName => 'ಎಲೈಟ್';

  @override
  String get elitePlanDesc => 'ವಿಐಪಿ ಪ್ರವೇಶದೊಂದಿಗೆ ಆಯ್ದ ಪಂದ್ಯಗಳು';

  @override
  String get royalPlanName => 'ರಾಯಲ್';

  @override
  String get royalPlanDesc =>
      'ಸಮರ್ಪಿತ ವ್ಯವಸ್ಥಾಪಕರು ನಿಮ್ಮ ಸಂಗಾತಿಯನ್ನು ಹುಡುಕುತ್ತಾರೆ';

  @override
  String get eternalElitePlanName => 'ಎಟರ್ನಲ್ ಎಲೈಟ್';

  @override
  String get eternalElitePlanDesc =>
      'ನಿಮ್ಮ ವೃತ್ತಿಜೀವನದ ಮೇಲೆ ಗಮನ ಹರಿಸಿ, ನಾವು ನಿಮ್ಮ ಜೀವನ ಸಂಗಾತಿಯನ್ನು ಹುಡುಕುತ್ತೇವೆ';

  @override
  String get selfServicePlans => 'ಸ್ವಯಂ ಸೇವೆ';

  @override
  String get vipMatchmaker => 'ವಿಐಪಿ ಮ್ಯಾಚ್ ಸೃಷ್ಟಿಕರ್ತ';

  @override
  String get tillUMarry => 'ಮದುವೆಯಾಗುವವರೆಗೆ';

  @override
  String get lifetime => 'ಜೀವಿತಾವಧಿ';

  @override
  String mrpPrice(Object price) {
    return 'MRP ₹$price';
  }

  @override
  String bulkDiscount(Object percent) {
    return '$percent% ರಿಯಾಯಿತಿ';
  }

  @override
  String youSave(Object amount) {
    return 'ನೀವು ಉಳಿಸುತ್ತೀರಿ ₹$amount';
  }

  @override
  String totalSavings(Object amount) {
    return 'ಒಟ್ಟು ಉಳಿತಾಯ: ₹$amount';
  }

  @override
  String get trustDiscountApplied => 'ಟ್ರಸ್ಟ್ ಸ್ಕೋರ್ ರಿಯಾಯಿತಿ ಅನ್ವಯಿಸಲಾಗಿದೆ';

  @override
  String get couponDiscountApplied => 'ಕೂಪನ್ ರಿಯಾಯಿತಿ ಅನ್ವಯಿಸಲಾಗಿದೆ';

  @override
  String contactUnlocks(Object count) {
    return '$count ಸಂಪರ್ಕ ಅನ್‌ಲಾಕ್‌ಗಳು/ತಿಂಗಳು';
  }

  @override
  String handpickedMatches(Object count) {
    return '$count ಆಯ್ದ ಪಂದ್ಯಗಳು/ವಾರ';
  }

  @override
  String get dedicatedManager => 'ಸಮರ್ಪಿತ ಸಂಬಂಧ ವ್ಯವಸ್ಥಾಪಕ';

  @override
  String get profileMakeover => 'ವೃತ್ತಿಪರ ಪ್ರೊಫೈಲ್ ಮೇಕ್ ಓವರ್';

  @override
  String get featuredBadge => 'ಎಲೈಟ್ ವೆರಿಫೈಡ್ ಬ್ಯಾಡ್ಜ್';

  @override
  String get featuresIncluded => 'ಒಳಗೊಂಡಿರುವ ವೈಶಿಷ್ಟ್ಯಗಳು:';

  @override
  String get incognitoMode => 'ಖಾಸಗಿ ಪ್ರೊಫೈಲ್ ಬ್ರೌಸಿಂಗ್';

  @override
  String get biodataPremiumIncluded => 'ಬಯೋಡೇಟಾ ಪ್ರೀಮಿಯಂ ಒಳಗೊಂಡಿದೆ';

  @override
  String get unlimitedContactUnlocks => 'ಅನಿಯಮಿತ ಸಂಪರ್ಕ ಅನ್‌ಲಾಕ್‌ಗಳು';

  @override
  String get unlimitedHandpickedMatches => 'ದೈನಂದಿನ ಬೇಡಿಕೆಯ ಪಂದ್ಯಗಳು';

  @override
  String get weeklyCheckIn => 'ಸಾಪ್ತಾಹಿಕ ಚೆಕ್-ಇನ್';

  @override
  String get monthlyCheckIn => 'ಮಾಸಿಕ ಚೆಕ್-ಇನ್';

  @override
  String get bestValue => 'ಅತ್ಯುತ್ತಮ ಮೌಲ್ಯ';

  @override
  String get personalConcierge => 'ವೈಯಕ್ತಿಕ ಸಹಾಯಕಿ';

  @override
  String get vipFeatures => 'ವಿಐಪಿ ವೈಶಿಷ್ಟ್ಯಗಳು';

  @override
  String get directContactAccess => 'ನೇರ ಸಂಪರ್ಕ ಪ್ರವೇಶ';

  @override
  String get focusOnCareer =>
      'ನಿಮ್ಮ ವೃತ್ತಿಜೀವನದ ಮೇಲೆ ಗಮನ ಹರಿಸಿ, ನಾವು ನಿಮ್ಮ ಜೀವನ ಸಂಗಾತಿಯನ್ನು ಹುಡುಕುತ್ತೇವೆ';

  @override
  String get perMonth => '/ತಿಂಗಳು';

  @override
  String get forLifetime => 'ಜೀವಿತಾವಧಿಗೆ';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get dailyMatchPicks => 'Daily Match Picks';

  @override
  String get newMatchAlerts => 'New Match Alerts';

  @override
  String extraViewsUnlocked(int count) {
    return '$count Extra Views Unlocked!';
  }

  @override
  String get sendHeartInterested => 'Send a heart to show you\'re interested.';

  @override
  String get notMatchedCannotMessage =>
      'You are not matched with this profile, so you can\'t direct message them.';

  @override
  String get oneMessageUnlocked => '1 Message Unlocked!';

  @override
  String get seenAllProfiles => 'You\'ve seen all profiles!';

  @override
  String get signInRequired => 'ಸೈನ್ ಇನ್ ಅಗತ್ಯವಿದೆ';

  @override
  String get signInRequiredContent =>
      'ಈ ವೈಶಿಷ್ಟ್ಯವನ್ನು ಬಳಸಲು ದಯವಿಟ್ಟು ಸೈನ್ ಇನ್ ಮಾಡಿ ಅಥವಾ ಖಾತೆಯನ್ನು ರಚಿಸಿ.';

  @override
  String get watchAdToUnlock => 'ಅನ್‌ಲಾಕ್ ಮಾಡಲು ಜಾಹೀರಾತು ನೋಡಿ';

  @override
  String get watchAdToUnlockAll => 'ಎಲ್ಲವನ್ನೂ ಅನ್‌ಲಾಕ್ ಮಾಡಲು ಜಾಹೀರಾತು ನೋಡಿ';

  @override
  String get goProAdFree => 'ಜಾಹೀರಾತು ರಹಿತ ಅನುಭವಕ್ಕಾಗಿ ಪ್ರೊ ಆಗಿ';

  @override
  String get adNotReady =>
      'ಜಾಹೀರಾತು ಇನ್ನೂ ಸಿದ್ಧವಾಗಿಲ್ಲ. ದಯವಿಟ್ಟು ಸ್ವಲ್ಪ ಸಮಯದ ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get upgradeToUnlockPremiumFeatures =>
      'ಎಲ್ಲಾ ಜಾಹೀರಾತುಗಳನ್ನು ತೆಗೆದುಹಾಕಲು ಮತ್ತು ಪ್ರೀಮಿಯಂ ಬಯೋಡೇಟಾ ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಲು ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ.';

  @override
  String get couldNotLaunchWhatsApp => 'ವಾಟ್ಸಾಪ್ ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get couldNotLaunchDialer => 'ಫೋನ್ ಡಯಲರ್ ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get searchLeads => 'ಲೀಡ್‌ಗಳನ್ನು ಹುಡುಕಿ...';

  @override
  String get workspace => 'ವರ್ಕ್‌ಸ್ಪೇಸ್';

  @override
  String get customMessage => 'ಕಸ್ಟಮ್ ಸಂದೇಶ';

  @override
  String get logCallOutcome => 'ಕರೆ ಫಲಿತಾಂಶವನ್ನು ದಾಖಲಿಸಿ';

  @override
  String get apply => 'ಅನ್ವಯಿಸು';

  @override
  String get registrationFee => 'ನೋಂದಣಿ ಶುಲ್ಕ';

  @override
  String get unverified => 'ಪರಿಶೀಲಿಸದ';

  @override
  String get signIn => 'ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String unlockMoreVisitors(int count) {
    return 'ಮತ್ತಷ್ಟು $count ಸಂದರ್ಶಕರನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಿ!';
  }

  @override
  String get dailyLimitReached => 'ದೈನಂದಿನ ಮಿತಿ ಮೀರಿದೆ';

  @override
  String get dailyLimitViewsReached =>
      'ನಿಮ್ಮ ಎಲ್ಲಾ ದೈನಂದಿನ ಪ್ರೊಫೈಲ್ ವೀಕ್ಷಣೆಗಳನ್ನು ನೀವು ಬಳಸಿದ್ದೀರಿ.';

  @override
  String get unlockMoreViewsAd =>
      'ಇಂದಿನ 5 ಹೆಚ್ಚಿನ ವೀಕ್ಷಣೆಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಲು ತ್ವರಿತ ಜಾಹೀರಾತು ನೋಡಿ!';

  @override
  String get directMessage => 'ನೇರ ಸಂದೇಶ';

  @override
  String get directMessagingPremium =>
      'ನೇರ ಸಂದೇಶ ಕಳುಹಿಸುವುದು ಪ್ರೀಮಿಯಂ ವೈಶಿಷ್ಟ್ಯವಾಗಿದೆ.';

  @override
  String get unlockDirectMessageAd =>
      '1 ನೇರ ಸಂದೇಶವನ್ನು ಉಚಿತವಾಗಿ ಅನ್‌ಲಾಕ್ ಮಾಡಲು 3 ಜಾಹೀರಾತುಗಳನ್ನು ನೋಡಿ!';

  @override
  String get premiumAccess => 'ಪ್ರೀಮಿಯಂ ಪ್ರವೇಶ';

  @override
  String get premiumGateSupport =>
      'ತ್ವರಿತ ಜಾಹೀರಾತನ್ನು ವೀಕ್ಷಿಸುವ ಮೂಲಕ ನಮ್ಮ ಸಮುದಾಯವನ್ನು ಬೆಂಬಲಿಸಿ,\nಅಥವಾ ಜಾಹೀರಾತು-ಮುಕ್ತ ಅನುಭವಕ್ಕಾಗಿ ಪ್ರೊಗೆ ಅಪ್‌ಗ್ರೇಡ್ ಮಾಡಿ.';

  @override
  String get unblockAllProFeatures => 'ಎಲ್ಲಾ ಪ್ರೊ ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಅನ್ಲಾక్ ಮಾಡಿ';

  @override
  String get monthly => 'ಮಾಸಿಕ';

  @override
  String get annual => 'ವಾರ್ಷಿಕ';

  @override
  String get watchQuickAd => 'ತ್ವರಿತ ಜಾಹೀರಾತನ್ನು ವೀಕ್ಷಿಸಿ';

  @override
  String get continueBlockedUntilAdEnds =>
      'ಜಾಹೀರಾತು ಮುಗಿಯುವವರೆಗೆ ಅಪ್ಲಿಕೇಶನ್ ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ';

  @override
  String get adCompletedSuccessfully => 'ಜಾಹೀರಾತು ಯಶಸ್ವಿಯಾಗಿ ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get continueToApp => 'ಅಪ್ಲಿಕೇಶನ್ ಮುಂದುವರಿಸಿ';

  @override
  String get preparingAdExperience =>
      'ಜಾಹೀರಾತು ಅನುಭವವನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get adTemporarilyUnavailable => 'ಜಾಹೀರಾತು ತಾತ್ಕಾಲಿಕವಾಗಿ ಅಲಭ್ಯವಾಗಿದೆ';

  @override
  String get callAdmin => 'ಅಡ್ಮಿನ್ ಗೆ ಕರೆ ಮಾಡಿ';

  @override
  String get banjaraBioPro => 'ಬಂಜಾರಬಯೋ ಪ್ರೊ';

  @override
  String get claimMarriageGift => 'ಮದುವೆ ಉಡುಗೊರೆಯನ್ನು ಪಡೆಯಿರಿ';

  @override
  String get tellUsYourStory => 'ನಿಮ್ಮ ಕಥೆಯನ್ನು ನಮಗೆ ತಿಳಿಸಿ';

  @override
  String get partnerName => 'ಜೊತೆಗಾರನ ಹೆಸರು';

  @override
  String get yourSuccessStory => 'ನಿಮ್ಮ ಯಶಸ್ಸಿನ ಕಥೆ';

  @override
  String get howDidYouMeet => 'ನೀವು ಹೇಗೆ ಭೇಟಿಯಾದಿರಿ? ಅವರಲ್ಲಿ ನಿಮಗೆ ಏನು ಇಷ್ಟ?';

  @override
  String get proofOfMarriage => 'ಮದುವೆಯ ಪುರಾವೆ';

  @override
  String get instagramLink => 'ಇನ್ಸ್ಟಾಗ್ರಾಮ್ ರೀಲ್/ಸ್ಟೋರಿ ಲಿಂಕ್';

  @override
  String get pasteUrlHere => 'ಇಲ್ಲಿ ಯುಆರ್ಎಲ್ ಪೇಸ್ಟ್ ಮಾಡಿ';

  @override
  String get weddingDate => 'ಮದುವೆಯ ದಿನಾಂಕ';

  @override
  String get estimatedRefund => 'ಅಂದಾಜು ಮರುಪಾವತಿ';

  @override
  String get submitForReview => 'ಪರಿಶೀಲನೆಗಾಗಿ ಸಲ್ಲಿಸಿ';

  @override
  String get selectRewardType => 'ಉಡುಗೊರೆ ಪ್ರಕಾರವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get digital => 'ಡಿಜಿಟಲ್';

  @override
  String get refund25 => '25% ಮರುಪಾವತಿ';

  @override
  String get teamVisit => 'ತಂಡದ ಭೇಟಿ';

  @override
  String get refund35 => '35% ಮರುಪಾವತಿ';

  @override
  String get successSubmission =>
      'ಯಶಸ್ಸು! ನಿಮ್ಮ ವಿನಂತಿಯನ್ನು ಪರಿಶೀಲನೆಗಾಗಿ ಸಲ್ಲಿಸಲಾಗಿದೆ.';
}
