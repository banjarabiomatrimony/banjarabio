// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get genderSelectHeading => 'Your Gender is';

  @override
  String get replacePhoto => 'Replace Photo';

  @override
  String get errorLoadingAdminStats =>
      'Unable to load dashboard statistics. Please try refreshing.';

  @override
  String get errorLoadingAdminUsers =>
      'Could not fetch user list. Please check your connection.';

  @override
  String get errorLoadingAdminPayments =>
      'Failed to load payment history. Please try again.';

  @override
  String get errorLoadingAdminVerifications =>
      'Could not load verification requests. Please try again.';

  @override
  String get errorLoadingAdminReferences =>
      'Unable to fetch pending references. Please refresh.';

  @override
  String get errorLoadingAdminCoupons =>
      'Failed to load coupon offers. Please try again.';

  @override
  String get errorLoadingAdminCreators =>
      'Could not fetch creator list. Please check your network.';

  @override
  String get errorAdminActionFailed =>
      'The requested action could not be completed. Please try again later.';

  @override
  String get expressInterest => 'Express Interest?';

  @override
  String interestConfirmationDesc(String name) {
    return 'Do you want to share your profile with $name to show your interest?';
  }

  @override
  String get yesInterest => 'Yes, Interest';

  @override
  String get interest => 'Interest';

  @override
  String get revenueToday => 'Revenue Today (₹)';

  @override
  String get premiumMen => 'Premium Men';

  @override
  String get premiumWomen => 'Premium Women';

  @override
  String get financialPerformance => 'Financial Performance';

  @override
  String get demographicsAndPremium => 'Demographics & Premium';

  @override
  String get revenueTotal => 'Total Revenue (₹)';

  @override
  String get monthlyRevenue => 'Monthly Revenue (₹)';

  @override
  String get pdfRevenue => 'PDF Revenue (₹)';

  @override
  String get userEngagement => 'User Engagement';

  @override
  String get dailyActiveUsers => 'Daily Active Users';

  @override
  String get profileViews => 'Profile Views';

  @override
  String get totalMessages => 'Total Messages';

  @override
  String get safetyAndHealth => 'Safety & Health';

  @override
  String get pendingReports => 'Pending Reports';

  @override
  String get totalBlocks => 'Total Blocks';

  @override
  String get pendingReferences => 'Pending References';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get profiles => 'Profiles';

  @override
  String get appGrowth => 'App Growth';

  @override
  String get completedReferrals => 'Completed Referrals';

  @override
  String get activeCreators => 'Active Creators';

  @override
  String get totalFemales => 'Total Females';

  @override
  String get totalMales => 'Total Males';

  @override
  String get men => 'Men';

  @override
  String get women => 'Women';

  @override
  String get sharingProfiles => 'Sharing Profiles';

  @override
  String get sharingProfile => 'Sharing profile...';

  @override
  String get referenceVerified => 'Reference Verified';

  @override
  String get referenceRejected => 'Reference Rejected';

  @override
  String get aboutSelf => 'About Self';

  @override
  String get aboutYourself => 'About Yourself';

  @override
  String get abusiveBehavior => 'Abusive Behavior';

  @override
  String get account => 'Account';

  @override
  String get accountAndAllDataDeletedSuccessfully =>
      'Account and all data deleted successfully.';

  @override
  String get accountDeletion => 'Account Deletion';

  @override
  String get actionIsIrreversible => 'This action is irreversible.';

  @override
  String get activeSubscriptionCancelledNoRefund =>
      'Your active subscription will be cancelled without refund.';

  @override
  String get adFreeExperience => 'Ad-free experience';

  @override
  String addClearPhotos(String max) {
    return 'Add clear photos ($max max)';
  }

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get addPhotosToYourBiodataProfileToIncreaseV =>
      'Add photos to your biodata profile to increase visibility and trust';

  @override
  String get addSibling => 'Add Sibling';

  @override
  String get addTwoReferences => 'Add Two References';

  @override
  String get addYourBrothersAndSisters => 'Add your brothers and sisters';

  @override
  String get addYourFirstPhoto => 'Add Your First Photo';

  @override
  String get additionalPreferences => 'Additional Preferences';

  @override
  String get additionalProfessionalInfo => 'Additional Professional Info';

  @override
  String get adjust => 'Adjust';

  @override
  String get adjustFilters => 'Adjust Filters';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get adminLoginRequiresAuthorizedCredentials =>
      'Admin login requires authorized credentials';

  @override
  String get adminManagement => 'Admin Management';

  @override
  String get adminPortal => 'Admin Portal';

  @override
  String get advancedFilters => 'Advanced filters';

  @override
  String get affluent => 'Affluent';

  @override
  String get age => 'Age';

  @override
  String get ageRange => 'Age Range';

  @override
  String get aiBio => 'AI Bio';

  @override
  String allInDistrict(String district) {
    return 'All in $district';
  }

  @override
  String get allInSelectedDistrict => 'All in selected District';

  @override
  String get allInSelectedState => 'All in selected State';

  @override
  String allInState(String state) {
    return 'All in $state';
  }

  @override
  String get allIndia => 'All India';

  @override
  String allPhotosCount(int count, int max) {
    return 'All Photos ($count/$max)';
  }

  @override
  String get allYourProfileDataPermanentlyRemoved =>
      'All your profile data will be permanently removed.';

  @override
  String get almostDone => 'Almost Done!';

  @override
  String get almostDoneReview =>
      'Review all sections and click \"Save Biodata\" to complete your profile. Your biodata will be visible to other community members based on your privacy settings.';

  @override
  String anErrorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get and => ' and ';

  @override
  String get annualIncome => 'Individual Annual Income';

  @override
  String get annualIncomeHint =>
      'Total yearly earnings from salary or business. (NOT family savings)';

  @override
  String get annulled => 'Annulled';

  @override
  String get appName => 'BanjaraBio';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get approve => 'Approve';

  @override
  String get areYouReadyForDiscussions => 'Are you ready for discussions?';

  @override
  String areYouSureDeleteSelectedPhotos(int count) {
    return 'Are you sure you want to delete $count photo(s)?';
  }

  @override
  String get areYouSureExit => 'Are you sure you want to exit the app?';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get areYouSureYouWantToBlockThisUserYouWillN =>
      'Are you sure you want to block this user? You will not be able to see their profile again.';

  @override
  String get areYouSureYouWantToDeleteThisPhoto =>
      'Are you sure you want to delete this photo?';

  @override
  String get areYouSureYouWantToDeleteYourAccount =>
      'Are you sure you want to delete your account?';

  @override
  String get askFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get atLeastOnePhotoRequired => 'At least one photo is required';

  @override
  String get awaitingDivorce => 'Awaiting Divorce';

  @override
  String get bachelorsDegree => 'Bachelor\'s Degree';

  @override
  String get back => 'Back';

  @override
  String get backSide => 'Back Side';

  @override
  String get backToGoogleSignIn => 'Back to Google Sign In';

  @override
  String get banjaraMember => 'Banjara Member';

  @override
  String get banjarabio => 'BanjaraBio';

  @override
  String get biodataDraftRestored => 'Biodata draft restored!';

  @override
  String get biodataDraftRestoredSuccess =>
      'Biodata draft restored successfully!';

  @override
  String get biodataPdf => 'Biodata PDF';

  @override
  String get biodataSavedSuccessfully => 'Biodata saved successfully!';

  @override
  String get biodataUnlockPlanDesc => 'Unlock professional premium templates';

  @override
  String get biodataUnlockPlanName => 'Biodata Premium';

  @override
  String get birthDetails => 'Additional Birth Details';

  @override
  String get birthPlace => 'Birth Place';

  @override
  String get birthPlaceAndTime => 'Birth Place & Time';

  @override
  String get birthTime => 'Birth Time';

  @override
  String get block => 'Block';

  @override
  String get blockUser => 'Block User';

  @override
  String get bloodGroup => 'Blood Group';

  @override
  String get blurryLowQualityImages => 'Blurry, dark, or low-quality images';

  @override
  String get bookmarkLimitReached => 'Bookmark Limit Reached';

  @override
  String get messagingLimitReached => 'Messaging Limit Reached';

  @override
  String bookmarksCount(String count) {
    return '$count bookmarks';
  }

  @override
  String get bronze => 'Bronze';

  @override
  String get brother => 'Brother';

  @override
  String get brotherCount => 'Brothers';

  @override
  String get browseProfiles => 'Browse Profiles';

  @override
  String get business => 'Business';

  @override
  String get businessOwner => 'Business Owner';

  @override
  String get byContAcceptTerms => 'By continuing, you agree to our ';

  @override
  String get camera => 'Camera';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get chat => 'Chat';

  @override
  String get checkBackSoonForNewMatchesnpullDownToRef =>
      'Check back soon for new matches.\\nPull down to refresh.';

  @override
  String get checkInbox => 'Check Inbox';

  @override
  String get checkInternet =>
      'Please check your internet connection and try again.';

  @override
  String get checkWhoIsLookingAtYourProfile =>
      'Check who is looking at your profile';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get chooseTemplate => 'Choose Template';

  @override
  String get clear => 'Clear';

  @override
  String get clearAllFilters => 'Clear All Filters';

  @override
  String get clearWellLitPhotos =>
      'Clear, well-lit photos showing your face clearly';

  @override
  String get close => 'Close';

  @override
  String get comeBackTomorrowFornnewCuratedMatches =>
      'Come back tomorrow for\\nnew curated matches!';

  @override
  String get communityId => 'Community ID';

  @override
  String get communityIdSubmitted => 'Community ID Submitted';

  @override
  String get communityIdVerification => 'Community ID';

  @override
  String get communityMember => 'Community Member';

  @override
  String get communityVerification => 'Community Verification';

  @override
  String get companyName => 'Company Name';

  @override
  String get completeVerificationToUnlockPremium =>
      'Complete verification to unlock \'Premium\' status.';

  @override
  String get completeYourProfileToGetNoticed =>
      'Complete your profile to get noticed!';

  @override
  String get completion => 'COMPLETION';

  @override
  String get complexion => 'Complexion';

  @override
  String get compressingUnder500Kb => 'Compressing under 500KB...';

  @override
  String get confirm => 'Confirm';

  @override
  String get connectInApp => 'CONNECT IN-APP';

  @override
  String get connectWithCommunity => 'Connect with your Banjara community';

  @override
  String get contact => 'Contact';

  @override
  String get contactPreferences => 'Contact Preferences';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get continueWithFreeAccount => 'Continue with Free Account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get conversations => 'Conversations';

  @override
  String get copyLink => 'Copy Link';

  @override
  String copyLinkSubtitle(String name) {
    return 'Copy a link to $name profile';
  }

  @override
  String get couldNotLoadProfile =>
      'We couldn\'t load your profile. Please try again.';

  @override
  String get createBiodata => 'Create Biodata';

  @override
  String get createProfile => 'Create Profile';

  @override
  String criticalFailure(Object error) {
    return 'Critical failure: $error';
  }

  @override
  String get cropPhoto => 'Crop Photo';

  @override
  String get cropRotate => 'Crop & Rotate';

  @override
  String curatedProfilesJustForYou(int count) {
    return '$count curated profiles just for you';
  }

  @override
  String get currentLocation => 'Current Location';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get currentResidenceState => 'Current Residence State';

  @override
  String get currentVillageHint => 'Current village';

  @override
  String get customizeBiodata => 'Customize Biodata';

  @override
  String get daily => 'Daily';

  @override
  String get dailyMatch => 'Daily Match';

  @override
  String get dark => 'Dark';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get daughter => 'Daughter';

  @override
  String daysAgo(String count) {
    return '${count}d ago';
  }

  @override
  String daysLeft(Object days) {
    return '$days days left';
  }

  @override
  String daysRemaining(Object days) {
    return '$days days remaining';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action is permanent and cannot be undone.';

  @override
  String deleteCount(Object count) {
    return 'Delete ($count)';
  }

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get deletePhotos => 'Delete Photos';

  @override
  String deleteSelectedSharesQuery(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete $count selected shares?',
      one: 'Are you sure you want to delete the selected share?',
    );
    return '$_temp0';
  }

  @override
  String get deleteShares => 'Delete Shares';

  @override
  String get deletingYourAccountWillResultIn =>
      'Deleting your account will result in:';

  @override
  String get demo => 'Demo';

  @override
  String get describeYourselfInterestsHobbies =>
      'Describe yourself, interests, hobbies...';

  @override
  String get details => 'Details';

  @override
  String get differentSettingsTip =>
      'Include photos in different settings (formal, casual)';

  @override
  String get diploma => 'Diploma';

  @override
  String get directMessaging => 'Direct messaging';

  @override
  String get disabledHint =>
      'Optional field for physically challenged individuals';

  @override
  String get disabledTagLabel => 'Disabled';

  @override
  String get discard => 'Discard';

  @override
  String get discardChanges => 'Discard Changes?';

  @override
  String get discardChangesBody =>
      'Are you sure you want to go back? Your progress is saved as a draft.';

  @override
  String discountPercentage(Object percentage, Object score) {
    return '$percentage% OFF (Trust Score $score)';
  }

  @override
  String get discoverProfilesFromYourCommunityNsmartM =>
      'Discover profiles from your community.\\nSmart matchmaking powered by compatibility scores.';

  @override
  String get district => 'District';

  @override
  String districtInState(String state) {
    return 'District in $state';
  }

  @override
  String get districtInStateLabel => 'District in State';

  @override
  String get divorced => 'Divorced';

  @override
  String get doctorate => 'Doctorate';

  @override
  String get documentProofs => 'Document Proofs:';

  @override
  String get documentType => 'Document Type';

  @override
  String get documentView => 'Document View';

  @override
  String get done => 'Done';

  @override
  String get downloadBtn => 'Download';

  @override
  String get dusky => 'Dusky';

  @override
  String get easiest => 'Easiest';

  @override
  String get edit => 'Edit';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get education => 'Education';

  @override
  String get educationAndProfession => 'Education & Profession';

  @override
  String get educationDetails => 'Education Details';

  @override
  String get educationLabel => 'Education';

  @override
  String get educationProfession => 'Education & Profession';

  @override
  String get educationProfessionDetails => 'Education & Career';

  @override
  String get educationalQualification => 'Educational Qualification';

  @override
  String get egSeniorSoftwareEngineer => 'e.g. Senior Software Engineer';

  @override
  String get egSpecialization => 'e.g. Specialization or Honors';

  @override
  String get egSpecializationOrHonors => 'e.g. Specialization or Honors';

  @override
  String get egTime => 'e.g. 10:30 AM';

  @override
  String get elderBrother => 'Elder Brother';

  @override
  String get elderSister => 'Elder Sister';

  @override
  String get email => 'Email';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String get emailVerificationTip =>
      'Tip: Check your spam folder if you don\'t see the email.';

  @override
  String get emailVerifiedSuccessfully10Points =>
      'Email Verified Successfully! +10 Points';

  @override
  String get emptyStr => '₹';

  @override
  String get english => 'English';

  @override
  String get enterBasicInfo =>
      'Enter your basic information as it appears in official documents';

  @override
  String get enterCityVillage => 'Enter city/village';

  @override
  String get enterEducationDetails => 'Enter your education details';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterMobileNumber => 'Enter mobile number';

  @override
  String get enterProfessionDetails => 'Enter your profession details';

  @override
  String get enterYourBasicInformationAsItAppearsInOf =>
      'Enter your basic information as it appears in official documents';

  @override
  String get enterYourEducationDetails => 'Enter your education details';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get enterYourProfessionDetails => 'Enter your profession details';

  @override
  String get error => 'Error';

  @override
  String errorCheckingShareLimits(String error) {
    return 'Error checking share limits: $error';
  }

  @override
  String errorCheckingStatus(String error) {
    return 'Error checking status: $error';
  }

  @override
  String errorCheckingViewLimits(String error) {
    return 'Error checking view limits: $error';
  }

  @override
  String errorLoadingAdminData(String error) {
    return 'Error loading admin data: $error';
  }

  @override
  String errorLoadingRequests(String error) {
    return 'Error loading requests: $error';
  }

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get everyProfileIsVerifiedWithIdSelfieRefere =>
      'Every profile is verified with ID, selfie & references.\\nTrust Score ensures genuine connections.';

  @override
  String get exit => 'Exit';

  @override
  String get exitApp => 'Exit App';

  @override
  String get exportBiodataPdf => 'Export Biodata PDF';

  @override
  String get expressInterestDesc =>
      'Express your interest by sharing your biodata directly';

  @override
  String failedLoadProfile(String error) {
    return 'Failed to load profile context: $error';
  }

  @override
  String failedSignInGoogle(String error) {
    return 'Failed to sign in with Google: $error';
  }

  @override
  String get failedSignInGoogleRetry =>
      'Failed to sign in with Google. Please try again.';

  @override
  String failedToBlockUser(Object error) {
    return 'Failed to block user: $error';
  }

  @override
  String failedToDeleteAccount(Object error) {
    return 'Failed to delete account: $error';
  }

  @override
  String failedToDeletePhotoError(String error) {
    return 'Failed to delete photo: $error';
  }

  @override
  String get failedToGeneratePdfPreview => 'Failed to generate PDF preview';

  @override
  String failedToLoadBookmarks(Object error) {
    return 'Failed to load bookmarks: $error';
  }

  @override
  String failedToLoadPhotosError(String error) {
    return 'Failed to load photos: $error';
  }

  @override
  String failedToLoadProfileError(Object error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get failedToLoadProfileInformation =>
      'Failed to load profile information';

  @override
  String get failedToLoadProfiles => 'Failed to load profiles';

  @override
  String get failedToLoadReferralData => 'Failed to load referral data';

  @override
  String failedToLoadSubscription(String error) {
    return 'Failed to load subscription: $error';
  }

  @override
  String get failedToLoadTrustScoreStats => 'Failed to load trust score stats';

  @override
  String failedToLogout(String error) {
    return 'Failed to logout: $error';
  }

  @override
  String get failedToPrintPdf => 'Failed to print PDF';

  @override
  String get failedToProcessImage => 'Failed to process image';

  @override
  String failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String failedToSavePdf(String error) {
    return 'Failed to save PDF: $error';
  }

  @override
  String failedToSaveProfile(String error) {
    return 'Failed to save profile: $error';
  }

  @override
  String get failedToSharePdf => 'Failed to share PDF';

  @override
  String failedToStartChat(String error) {
    return 'Failed to start chat: $error';
  }

  @override
  String failedToSubmitReport(Object error) {
    return 'Failed to submit report: $error';
  }

  @override
  String failedToUpdateBookmark(Object error) {
    return 'Failed to update bookmark: $error';
  }

  @override
  String failedToUpdatePremiumStatus(String error) {
    return 'Failed to update premium status: $error';
  }

  @override
  String failedToUpdatePrimaryPhotoError(String error) {
    return 'Failed to update primary photo: $error';
  }

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String failedToUploadPhoto(int index) {
    return 'Failed to upload photo $index';
  }

  @override
  String failedToVerify(String error) {
    return 'Failed to verify: $error';
  }

  @override
  String get fair => 'Fair';

  @override
  String get fakeProfile => 'Fake Profile';

  @override
  String get familyBackground => 'Family Background';

  @override
  String get familyDetails => 'Family Details';

  @override
  String get familyFirstValues => 'Family-First Values';

  @override
  String get familyOnly => 'Family Only';

  @override
  String get familyStatus => 'Family Status';

  @override
  String get familyType => 'Family Type';

  @override
  String get faqA1 =>
      'Go to the Profile tab and click on \"Create Biodata\" or edit your existing profile. Follow the multi-step form to fill in your personal, family, and professional details.';

  @override
  String get faqA2 =>
      'Yes, we take privacy seriously. Your contact details are only shown to verified users and respect our community safety guidelines.';

  @override
  String get faqA3 =>
      'On the home screen, use the \"Filters\" button to narrow down profiles by age, location, education, and profession.';

  @override
  String get faqA4 =>
      'Premium users get unlimited profile views, early access to new biodatas, and enhanced visibility in search results.';

  @override
  String get faqA5 =>
      'Go to My Profile > Legal & Information > Account Deletion to permanently remove your profile and data from our system.';

  @override
  String get faqQ1 => 'How do I create a biodata?';

  @override
  String get faqQ2 => 'Is my data secure?';

  @override
  String get faqQ3 => 'How can I filter profiles?';

  @override
  String get faqQ4 => 'What are the benefits of Premium?';

  @override
  String get faqQ5 => 'How do I delete my account?';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faqs => 'FAQs';

  @override
  String get farmer => 'Farmer';

  @override
  String get fatherName => 'Father\'s Name';

  @override
  String get fatherOccupation => 'Father\'s Occupation';

  @override
  String get feet => 'feet';

  @override
  String get female => 'Female';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get fifteenToTwentyLakh => '₹15 Lakh - ₹20 Lakh';

  @override
  String get filtered => '(filtered)';

  @override
  String get findYourPerfectMatch => 'Find Your Perfect Match';

  @override
  String get fiveToSevenHalfLakh => '₹5 Lakh - ₹7.5 Lakh';

  @override
  String get followAndGetFivePercent => 'Follow & Get +5%';

  @override
  String get followUsOnInstagramBonus =>
      'Follow us on Instagram to get a 5% biodata completion bonus and stay updated with the latest matches.';

  @override
  String forMonths(Object count) {
    return 'for $count months';
  }

  @override
  String get free => 'Free';

  @override
  String get free1PhotonpremiumUpTo6Photos =>
      'Free: 1 photo\\nPremium: Up to 6 photos';

  @override
  String get freePlanDesc => 'Try basic features';

  @override
  String get freeUserLimitInfo =>
      'Free user limit reached. Upgrade to continue.';

  @override
  String get freeUsersCanUpload1PhotoUpgradeToUploadU =>
      'Free users can upload 1 photo. Upgrade to upload up to 5 photos.';

  @override
  String get friend => 'Friend';

  @override
  String get frontSide => 'Front Side';

  @override
  String get fullName => 'Full Name';

  @override
  String get gallery => 'Gallery';

  @override
  String get gender => 'Gender';

  @override
  String get generateBio => 'Generate Bio';

  @override
  String get generatingPreview => 'Generating preview...';

  @override
  String get getAProfessionalWellformattedPdfWithoutW =>
      'Get a professional, well-formatted PDF without watermarks and with all details visible.';

  @override
  String get getInTouchWithUs => 'Get in touch with us';

  @override
  String get getStarted => 'Get Started';

  @override
  String get getStartedLabel => 'Get Started';

  @override
  String get go => 'Go';

  @override
  String get goBack => 'Go Back';

  @override
  String get gold => 'Gold';

  @override
  String get goldPlanDesc => 'Most popular - Best value';

  @override
  String get goldPlanName => 'Gold';

  @override
  String get goldVerified => 'Gold Verified';

  @override
  String get gotIt => 'Got It';

  @override
  String get gotra => 'Gotra';

  @override
  String get governmentEmployee => 'Government Employee';

  @override
  String get governmentId => 'Government ID';

  @override
  String get governmentIdVerification => 'Government ID Verification';

  @override
  String get governmentIdVerificationSubtitle =>
      'Upload a blurred copy of your Aadhar or PAN to get a \'Verified\' badge.';

  @override
  String get governmentJob => 'Government Job';

  @override
  String get govtId => 'Govt ID';

  @override
  String get govtIdVerification => 'Government ID';

  @override
  String get graduate => 'Graduate';

  @override
  String get great => 'Great!';

  @override
  String get grid => 'Grid';

  @override
  String get groupPhotosNotVisible =>
      'Group photos where you are not clearly visible';

  @override
  String get growth => 'Growth';

  @override
  String get haveQuestionsOrNeedAssistanceOurTeamIsHe =>
      'Have questions or need assistance? Our team is here to help you find your perfect match.';

  @override
  String get heavilyFilteredEdited => 'Heavily filtered or edited photos';

  @override
  String get height => 'Height';

  @override
  String get helpOurCommunityGrowAndUnlockPremiumRewa =>
      'Help our community grow and unlock Premium rewards for yourself.';

  @override
  String get highSchool => 'High School';

  @override
  String get hindi => 'हिंदी';

  @override
  String get home => 'Home';

  @override
  String get homemaker => 'Homemaker';

  @override
  String hoursAgo(String count) {
    return '${count}h ago';
  }

  @override
  String get howItWorks => 'How it works';

  @override
  String get iUnderstandThatThisActionCannotBeUndone =>
      'I understand that this action cannot be undone.';

  @override
  String idLabel(String id) {
    return 'ID: $id';
  }

  @override
  String get idNumber => 'ID Number';

  @override
  String get idType => 'ID Type';

  @override
  String get inappropriateBackgrounds =>
      'Photos with inappropriate backgrounds';

  @override
  String get inappropriateContentOrFakeProfile =>
      'Inappropriate content or fake profile';

  @override
  String get inappropriatePhotos => 'Inappropriate Photos';

  @override
  String get inches => 'inches';

  @override
  String get increaseBiodataScore => 'Increase Biodata Score!';

  @override
  String get increaseYourTrustScoreToConfirmYourIdent =>
      'Increase your Trust Score to confirm your identity and unlock exclusive discounts.';

  @override
  String get interestSent => 'Interest Sent';

  @override
  String get interestConfirmationTitle => 'Express Interest?';

  @override
  String interestConfirmationMessage(String name) {
    return 'This will share your profile with $name and allow them to connect with you. Are you sure?';
  }

  @override
  String interestShared(String name) {
    return 'Interest shared with $name!';
  }

  @override
  String get introduceYourselfIn30SecondsTalkAboutYou =>
      'Introduce yourself in 30 seconds. Talk about your family, profession, and expectations.';

  @override
  String get invalidEmailOrPassword => 'Invalid email or password';

  @override
  String get inviteARelative => 'Invite a Relative';

  @override
  String get inviteFriendsRewards =>
      'Invite friends and unlock premium rewards!';

  @override
  String get inviteStep1 => 'Step 1';

  @override
  String get inviteStep2 => 'Step 2';

  @override
  String get inviteStep3 => 'Step 3';

  @override
  String get isDisabledPerson => 'Are you a disabled person?';

  @override
  String get jobDetails => 'Job Details';

  @override
  String get joinMeOnBanjarabio => 'Join me on BanjaraBio';

  @override
  String get joinOurCommunity => 'Join our 10K+ community!';

  @override
  String get jointFamily => 'Joint Family';

  @override
  String get justNow => 'Just now';

  @override
  String get kannada => 'ಕನ್ನಡ';

  @override
  String get keepBrowsing => 'Keep Browsing';

  @override
  String get keywordSearch => 'Keyword Search';

  @override
  String get language => 'Language';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get lastUpdatedJanuary2026 => 'Last updated: January 2026';

  @override
  String get legalAndInformation => 'Legal & Information';

  @override
  String get linkShare => 'Link Share';

  @override
  String get linkedInIntegration => 'LinkedIn Integration';

  @override
  String get linkedInIntegrationSubtitle =>
      'Connect your professional profile to build more trust.';

  @override
  String get liveSelfie => 'Live Selfie';

  @override
  String get liveSelfieVerification => 'Live Selfie Verification';

  @override
  String get livenessCheck => 'Liveness Check';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingAssets => 'Loading assets...';

  @override
  String get loadingProfile => 'Loading your profile...';

  @override
  String get loadingViews => 'Loading views...';

  @override
  String get location => 'Location';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get locationPreferences => 'Location & Preferences';

  @override
  String get locationPreview => 'Location Preview';

  @override
  String get login => 'Login';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get loginFailedRetry => 'Login failed. Please try again.';

  @override
  String get logout => 'Logout';

  @override
  String get loseMatchesAndSavedProfiles =>
      'You will lose all your matches and saved profiles.';

  @override
  String get main => 'Main';

  @override
  String get male => 'Male';

  @override
  String get managePhotos => 'Manage Photos';

  @override
  String get managenphotos => 'Manage\\nPhotos';

  @override
  String get manualSelection => 'MANUAL SELECTION';

  @override
  String get marathi => 'मराठी';

  @override
  String get maritalStatus => 'Marital Status';

  @override
  String get maritalStatusLabel => 'Marital Status';

  @override
  String get marriageReadiness => 'Marriage Readiness';

  @override
  String get married => 'Married';

  @override
  String get maskFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get mastersDegree => 'Master\'s Degree';

  @override
  String matchNOfTotal(int current, int total) {
    return 'Match $current of $total';
  }

  @override
  String get matched => 'Matched';

  @override
  String get sent => 'Sent';

  @override
  String get received => 'Received';

  @override
  String get matchmakerConsultation => 'Matchmaker consultation';

  @override
  String get matrimonyFor => 'MATRIMONY FOR';

  @override
  String get maxAge => 'Max Age';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get menu => 'Menu';

  @override
  String get message => 'Message';

  @override
  String get messageUsOnWhatsapp => 'Message us on WhatsApp';

  @override
  String get messages => 'MESSAGES';

  @override
  String get middleClass => 'Middle Class';

  @override
  String get minAge => 'Min Age';

  @override
  String minutesAgo(String count) {
    return '${count}m ago';
  }

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get mobileVerification => 'Mobile Verification';

  @override
  String get mobileVerifiedSuccessfully10Points =>
      'Mobile Verified Successfully! +10 Points';

  @override
  String get month => '/month';

  @override
  String get months => 'Months';

  @override
  String get moreAboutYourStudiesAndWork => 'More about your studies and work';

  @override
  String get moreOptions => 'More options';

  @override
  String get mostPopular => 'MOST POPULAR';

  @override
  String get motherName => 'Mother\'s Name';

  @override
  String get motherOccupation => 'Mother\'s Occupation';

  @override
  String get myProfile => 'My Profile';

  @override
  String get name => 'Name';

  @override
  String get nativePlace => 'Native Place';

  @override
  String get naturalPosesRespectful =>
      'Natural poses with respectful expressions';

  @override
  String get needProfileToShareToast =>
      'You need to create a profile before sharing it.';

  @override
  String get neverMarried => 'Never Married';

  @override
  String get newLabel => 'New';

  @override
  String get newMatches => 'New Matches';

  @override
  String get next => 'Next';

  @override
  String get nextLabel => 'Next';

  @override
  String nextRefreshTime(String time) {
    return 'Next refresh: $time';
  }

  @override
  String get no => 'No';

  @override
  String get noBookmarkedProfilesYet => 'No bookmarked profiles yet';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get noDailyMatchesYet => 'No Daily Matches Yet';

  @override
  String get noIncome => 'No Income';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String noLocationsFoundForQuery(String query) {
    return 'No locations found for \"$query\"';
  }

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get noPendingVerifications => 'No pending verifications';

  @override
  String get noPhotosAdded => 'No photos added';

  @override
  String get noPhotosYet => 'No Photos Yet';

  @override
  String get noProfileFound => 'No profile found';

  @override
  String get noProfilesFound => 'No profiles found';

  @override
  String get noProfilesMatchYourFilters => 'No profiles match your filters';

  @override
  String get noResultsMessage =>
      'Try adjusting your filters or check back later for new profiles.';

  @override
  String get noSiblingsAddedYet => 'No siblings added yet';

  @override
  String get noTalukasAvailable => 'No talukas available';

  @override
  String get noViewsYet => 'No views yet';

  @override
  String get notAvailable => 'N/A';

  @override
  String get notEntered => 'Not Entered';

  @override
  String get notMatchedCantMessage =>
      'You are not matched with this profile, so you cant direct message them.';

  @override
  String get notReadyYet => 'Not ready yet';

  @override
  String get notRepresentAppearance =>
      'Photos that do not represent your current appearance';

  @override
  String get notVerifiedYetPleaseClickTheLinkInYourEm =>
      'Not verified yet. Please click the link in your email.';

  @override
  String get notYetVerifiedBadge => 'NOT YET VERIFIED';

  @override
  String get nuclearFamily => 'Nuclear Family';

  @override
  String get num100 => '/ 100';

  @override
  String get num123BanjaraTowersPrideSiliconValleynsh =>
      '123, Banjara Towers, Pride Silicon Valley,\\nShivaji Nagar, Pune, Maharashtra 411005';

  @override
  String get num15PointsPending => '+15 Points Pending';

  @override
  String get num499 => '499';

  @override
  String get num919876543210 => '+91 98765 43210';

  @override
  String get officeAddress => 'Office Address';

  @override
  String get ok => 'OK';

  @override
  String get onHold => 'On Hold';

  @override
  String get onboardingTitle1 => 'Find Your Perfect Match';

  @override
  String get onboardingTitle2 => 'Trusted Community';

  @override
  String get onboardingTitle3 => 'Secure & Private';

  @override
  String get oneTime => 'One Time';

  @override
  String get online => 'Online';

  @override
  String get openCamera => 'Open Camera';

  @override
  String get openProfileToShare => 'Open profile to share';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get openingConversation => 'Opening conversation...';

  @override
  String get openingConversationToast => 'Opening conversation...';

  @override
  String get originalVillageHint => 'Original village';

  @override
  String get other => 'Other';

  @override
  String get partnerExpectations => 'Partner Expectations';

  @override
  String get partnerExpectationsHint => 'Describe what you are looking for...';

  @override
  String get partnerPreferences => 'Partner Preferences';

  @override
  String get password => 'Password';

  @override
  String get pay199ToUnlockFullPdf => 'Pay ₹199 to Unlock Full PDF';

  @override
  String paymentFailed(String error) {
    return 'Payment failed: $error';
  }

  @override
  String paymentFailedError(String error) {
    return 'Payment failed: $error';
  }

  @override
  String get paymentSuccessful => 'Payment successful! Templates unlocked.';

  @override
  String paymentSuccessfulWelcome(String plan) {
    return 'Payment successful! Welcome to $plan';
  }

  @override
  String pdfSavedToDownloads(String path) {
    return 'PDF Saved to Downloads: $path';
  }

  @override
  String get pending => 'Pending';

  @override
  String get pendingVerifications => 'Pending Verifications';

  @override
  String percentComplete(int percentage) {
    return '$percentage% Complete';
  }

  @override
  String get permissionDeniedSettings =>
      'Permission denied. Please enable in settings.';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String permissionRequiredMessage(Object type) {
    return '$type permission is required to upload photos. Please enable it in app settings.';
  }

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get photoAdded => 'Photo added';

  @override
  String photoAddedWithKb(String kb) {
    return 'Photo added ($kb KB)';
  }

  @override
  String get photoGuidelines => 'Photo Guidelines';

  @override
  String get photoLimitReached => 'Photo Limit Reached';

  @override
  String get photoManagement => 'Photo Management';

  @override
  String get photoUpload => 'Photos';

  @override
  String get photoUploadedSuccessfully => 'Photo uploaded successfully';

  @override
  String get photoVisibility => 'Photo Visibility';

  @override
  String get photos => 'Photos:';

  @override
  String get photosAreAutomaticallyCompressedToEnsure =>
      'Photos are automatically compressed to ensure fast upload';

  @override
  String get photosCompressedInfo => 'Photos are compressed to save data.';

  @override
  String photosCount(String count) {
    return '$count photos';
  }

  @override
  String get photosDeletedSuccessfully => 'Photos deleted successfully';

  @override
  String get photosReflectPersonality =>
      'Photos that reflect your personality and values';

  @override
  String photosSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get photosToAvoid => 'Photos to Avoid';

  @override
  String get physicalSocialAttributes => 'Physical & Social Attributes';

  @override
  String get physicalStatus => 'Physical Status';

  @override
  String get platinumPlanDesc => 'Ultimate experience with all features';

  @override
  String get platinumPlanName => 'Platinum';

  @override
  String pleaseComplete(String fields) {
    return 'Please complete: $fields';
  }

  @override
  String pleaseCompleteRequiredFields(String section) {
    return 'Please complete all required fields in $section';
  }

  @override
  String get pleaseEnter6DigitOtp => 'Please enter 6-digit OTP';

  @override
  String get pleaseEnterAValid10DigitMobileNumber =>
      'Please enter a valid 10-digit mobile number';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'Please enter a valid email address';

  @override
  String get pleaseEnterBothEmailPassword =>
      'Please enter both email and password';

  @override
  String get pleaseEnterFull6DigitOtp => 'Please enter full 6-digit OTP';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get pleaseSelectAnnualIncome => 'Please select your annual income';

  @override
  String get pleaseSelectEducationLevel => 'Please select your education level';

  @override
  String get pleaseSelectProfession => 'Please select your profession';

  @override
  String get pleaseSelectYourGotra => 'Please select your gotra';

  @override
  String get pleaseSelectYourSurname => 'Please select your surname';

  @override
  String get pleaseSignInAgain => 'Please sign in again to save your biodata';

  @override
  String get pleaseSpecifyEducation => 'Please specify your education';

  @override
  String get pleaseSpecifyProfession => 'Please specify your profession';

  @override
  String get pleaseTakeASelfieToVerifyThatYouAreAReal =>
      'Please take a selfie to verify that you are a real person. Ensure you are in a well-lit area.';

  @override
  String pointsCount(String points) {
    return '+$points Points';
  }

  @override
  String get postGraduate => 'Post Graduate';

  @override
  String get premium => 'Premium';

  @override
  String get premiumFeature => 'This is a premium feature';

  @override
  String get premiumMembership => 'Premium Membership';

  @override
  String get premiumTemplate => 'Premium Template';

  @override
  String get premiumUsers => 'Premium Users';

  @override
  String get preparingBiodata => 'Preparing your biodata...';

  @override
  String get previewGenerationFailed =>
      'Preview generation failed. Please try again.';

  @override
  String get previous => 'Previous';

  @override
  String pricePerMonth(Object price) {
    return '₹$price/month';
  }

  @override
  String get primary => 'Primary';

  @override
  String get primaryPhoto => 'Primary Photo';

  @override
  String get primaryPhotoUpdated => 'Primary photo updated';

  @override
  String get printBtn => 'Print';

  @override
  String get prioritySupport => 'Priority support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyS1Content =>
      '• Personal Data: Name, age, gender, caste, education, profession, family details.\\n• Contact Data: Phone number, email address.\\n• Media: Photos uploaded to your profile.\\n• Device Data: Device ID, IP address (for security & analytics).\\n• Location Data: Approximate location (City/District) to suggest nearby matches.';

  @override
  String get privacyS1Title => '1. Information We Collect';

  @override
  String get privacyS2Content =>
      '• App Functionality: To create your profile and match-making.\\n• Account Management: Identity verification and fraud prevention.\\n• Analytics: To improve app performance (using Firebase).\\n• Location: To show \"Near Me\" matches (Optional).';

  @override
  String get privacyS2Title => '2. Purpose of Collection (Data Safety)';

  @override
  String get privacyS3Content =>
      '• Camera & Gallery: For profile photos.\\n• Location: To auto-fill city/district.\\n• Notifications: For match alerts.';

  @override
  String get privacyS3Title => '3. Device Permissions';

  @override
  String get privacyS4Content =>
      '• Other Users: Registered members can see your profile details (excluding contact info unless shared).\\n• Service Providers: We use Supabase (Database) and Firebase (Analytics/Notifications) to run the app. They process data under strict security standards.';

  @override
  String get privacyS4Title => '4. Disclosure & Third Parties';

  @override
  String get privacyS5Content =>
      'We use encryption to protect your data. You can delete your account and all associated data at any time via Settings > Delete Account.';

  @override
  String get privacyS5Title => '5. Data Security & Deletion';

  @override
  String get privacyS6Content =>
      'This policy is governed by the laws of India. Any disputes are subject to the jurisdiction of the courts in Maharashtra.';

  @override
  String get privacyS6Title => '6. Governing Law';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get privacySettingsUpdated => 'Privacy settings updated';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privateJob => 'Private Job';

  @override
  String get privateSectorEmployee => 'Private Sector Employee';

  @override
  String get pro => 'PRO';

  @override
  String get proTips => 'Pro Tips';

  @override
  String get processingImage => 'Processing Image';

  @override
  String get processingStatusCompressing => 'Compressing...';

  @override
  String get processingStatusPreparing => 'Preparing...';

  @override
  String get processingStatusSelecting => 'Selecting...';

  @override
  String get profession => 'Profession';

  @override
  String get professionLabel => 'Profession';

  @override
  String get professional => 'Professional';

  @override
  String get professionalDegree => 'Professional Degree';

  @override
  String get professionalDoctorEngineerLawyer =>
      'Professional (Doctor/Engineer/Lawyer)';

  @override
  String get professionalFamilyEventPhotos =>
      'Professional or family event photos';

  @override
  String get profile => 'Profile';

  @override
  String profileBoostPerMonth(String count) {
    return '$count profile boost/month';
  }

  @override
  String get profileCompleted => 'Profile Completed';

  @override
  String get profileCreatedByTitle => 'Profile Created By';

  @override
  String get profileDataNotFound => 'Profile data not found';

  @override
  String get profileInsights => 'Profile Insights';

  @override
  String get profileLinkCopied => 'Profile link copied to clipboard!';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get profilePhotos => 'Profile Photos';

  @override
  String get profileRemovedFromSaved => 'Profile removed from saved';

  @override
  String get profileSaved => 'Profile saved!';

  @override
  String profileSharedWith(String name) {
    return 'Profile shared with $name';
  }

  @override
  String profileStrengthLabel(Object strength) {
    return 'Profile Strength: $strength';
  }

  @override
  String get profileViewLimitReached => 'Profile View Limit Reached';

  @override
  String profileViewsPerDay(String count) {
    return '$count profile views/day';
  }

  @override
  String get profilesYouSaveWillAppearHere =>
      'Profiles you save will appear here';

  @override
  String get provideDetailsAboutYourGotraAndVillageTo =>
      'Provide details about your Gotra and Village to get the Community Verified badge.';

  @override
  String get provideInformationAboutYourFamilyBackgro =>
      'Provide information about your family background';

  @override
  String get public => 'Public';

  @override
  String get quick => 'Quick';

  @override
  String get ready => 'Ready';

  @override
  String get readyForMarriage => 'Ready for marriage';

  @override
  String get recentConversations => 'Recent Conversations';

  @override
  String get recentPhotosSixMonths =>
      'Recent photos taken within the last 6 months';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get recentlyUsed => 'RECENTLY USED';

  @override
  String get recommendToOthers => 'RECOMMEND TO OTHERS';

  @override
  String get recommended => 'Recommended';

  @override
  String get recommendedPhotos => 'Recommended Photos';

  @override
  String get recordAShortIntro => 'Record a Short Intro';

  @override
  String get refer3FriendsGet1MonthFree => 'Refer 3 Friends, Get 1 Month Free!';

  @override
  String get referAndEarn => 'Refer & Earn';

  @override
  String get referenceVerification => 'Reference Verification';

  @override
  String get references => 'References';

  @override
  String get referralInvite => 'Referral Invite';

  @override
  String referralInviteMessage(Object link) {
    return 'Join BanjaraBio, the most trusted matrimonial app for our community! Use my link to get started: $link';
  }

  @override
  String get referralInviteSubject => 'Invitation to Join BanjaraBio';

  @override
  String get referralLinkCopiedToClipboard =>
      'Referral link copied to clipboard!';

  @override
  String referralShareMessage(String link) {
    return 'Join BanjaraBio, the most trusted matrimonial app for our community! Use my link to get started: $link';
  }

  @override
  String get referralShareSubject => 'Invitation to Join BanjaraBio';

  @override
  String get referrals => 'Referrals';

  @override
  String get referralsLabel => 'Referrals';

  @override
  String get refresh => 'Refresh';

  @override
  String get reject => 'Reject';

  @override
  String get rejected => 'Rejected';

  @override
  String get relative => 'Relative';

  @override
  String get remainingToday => 'Remaining Today';

  @override
  String get remove => 'REMOVE';

  @override
  String get removePhoto => 'Remove';

  @override
  String get report => 'Report';

  @override
  String get reportSubmittedReview =>
      'Report submitted. Our team will review it within 24 hours.';

  @override
  String get reportUser => 'Report User';

  @override
  String get requestDate => 'Request Date';

  @override
  String requestProcessedSuccessfullyMsg(String status) {
    return 'Request $status successfully';
  }

  @override
  String get requestsSent => 'Requests Sent!';

  @override
  String get requestsSentSuccessfully => 'Requests sent successfully!';

  @override
  String get rerecord => 'Re-record';

  @override
  String get reset => 'Reset';

  @override
  String get reshare => 'RESHARE';

  @override
  String get retake => 'Retake';

  @override
  String get retry => 'Retry';

  @override
  String get reviewDetails => 'Review Details';

  @override
  String get reviewVideoManuallyInStorageForNow =>
      'Review video manually in Storage for now';

  @override
  String get rewards => 'Rewards';

  @override
  String get rewardsLabel => 'Rewards';

  @override
  String get rich => 'Rich';

  @override
  String get rupeeSymbol => '₹';

  @override
  String get save => 'Save';

  @override
  String get saveBiodata => 'Save Biodata';

  @override
  String get saved => 'Saved';

  @override
  String get savedProfiles => 'Saved Profiles';

  @override
  String get sayHelloLabel => 'Say hello!';

  @override
  String get search => 'Search';

  @override
  String get searchByNameJobEducation => 'Search by name, job, education...';

  @override
  String get searchProfiles => 'Search profiles...';

  @override
  String get searchResults => 'SEARCH RESULTS';

  @override
  String get searchSharedProfiles => 'Search shared profiles...';

  @override
  String get searchStateDistrictOrTaluka => 'Search State, District or Taluka';

  @override
  String get searchUserName => 'Search user name...';

  @override
  String get secure => 'Secure';

  @override
  String get seeAll => 'See All';

  @override
  String get selectAnnualIncome => 'Select yearly income range';

  @override
  String get selectAnnualIncomeRange => 'Select annual income range';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectDistrictFirst => 'Select District first';

  @override
  String get selectDocumentType => 'Select Document Type';

  @override
  String get selectEducationLevel => 'Select your education level';

  @override
  String get selectFromYourPhotos => 'Select from your photos';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get selectState => 'Select State';

  @override
  String get selectStateFirst => 'Select State first';

  @override
  String get selectTalukaOptional => 'Select Taluka (Optional)';

  @override
  String get selectYourEducationLevel => 'Select your education level';

  @override
  String get selectYourGotra => 'Select your gotra';

  @override
  String get selectYourLocationAndPreferences =>
      'Select your location and preferences';

  @override
  String get selectYourProfession => 'Select your profession';

  @override
  String get selectYourSurname => 'Select your search surname';

  @override
  String get selectedPhotos => 'Selected Photos';

  @override
  String get self => 'Self';

  @override
  String get selfEmployed => 'Self Employed';

  @override
  String get selfieSubmitted => 'Selfie Submitted';

  @override
  String get send => 'Send';

  @override
  String get sendInterest => 'Send Interest';

  @override
  String get sendMessage => 'SEND MESSAGE';

  @override
  String get sendVerification => 'Send Verification';

  @override
  String get sendVerificationRequests => 'Send Verification Requests';

  @override
  String get setAsPrimary => 'Set as Primary';

  @override
  String get settings => 'Settings';

  @override
  String get settingsAndMenu => 'Settings & Menu';

  @override
  String get sevenHalfToTenLakh => '₹7.5 Lakh - ₹10 Lakh';

  @override
  String get share => 'Share';

  @override
  String get shareBtn => 'Share';

  @override
  String get shareEducationalBackground =>
      'Share your educational background and professional details';

  @override
  String shareFailed(String error) {
    return 'Share failed: $error';
  }

  @override
  String get shareHub => 'Share Hub';

  @override
  String get shareInApp => 'Share In-App';

  @override
  String get shareLimitReached => 'Share Limit Reached';

  @override
  String get shareLinkOnWhatsapp => 'Share Link on WhatsApp';

  @override
  String get shareMyProfileSubtitle =>
      'Express your interest by sharing your biodata directly';

  @override
  String shareMyProfileWith(String name) {
    return 'Share my profile with $name';
  }

  @override
  String get shareProfile => 'Share Profile';

  @override
  String get shareProfilesWithYourFamilyInstantlyNbui =>
      'Share profiles with your family instantly.\\nBuilt for the way Indian families make decisions.';

  @override
  String get shareToSocialMedia => 'Share to Social Media';

  @override
  String get shareYourEducationalBackgroundAndProfess =>
      'Share your educational background and professional details';

  @override
  String get shareYourProfileProfessionally =>
      'Share your profile professionally';

  @override
  String get shared => 'Matches';

  @override
  String get sharedProfiles => 'Shared Profiles';

  @override
  String sharedVia(String name, String method) {
    return 'Shared $name via $method';
  }

  @override
  String sharesPerMonth(String count) {
    return '$count shares/month';
  }

  @override
  String get sharingBiodataPdf => 'Sharing Biodata PDF';

  @override
  String get silver => 'Silver';

  @override
  String get silverPlanDesc => 'Perfect for getting started';

  @override
  String get silverPlanName => 'Silver';

  @override
  String get sister => 'Sister';

  @override
  String get sisterCount => 'Sisters';

  @override
  String get skip => 'Skip';

  @override
  String get smileNaturallyTip => 'Smile naturally to appear approachable';

  @override
  String get socialMediaTextOverlays =>
      'Photos from social media with text overlays';

  @override
  String get solicitingMoney => 'Soliciting Money';

  @override
  String get someone => 'Someone';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get son => 'Son';

  @override
  String get specifyEducation => 'Specify Education';

  @override
  String get specifyProfession => 'Specify Profession';

  @override
  String get standardProfile => 'Standard Profile';

  @override
  String get start => 'Start';

  @override
  String get startAConversation => 'Start a conversation';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get state => 'State';

  @override
  String get statusWaitingForApproval => 'Status: Waiting for approval';

  @override
  String get stay => 'Stay';

  @override
  String stepNOfTotal(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get student => 'Student';

  @override
  String get submit => 'Submit';

  @override
  String get submitForVerification => 'Submit for Verification';

  @override
  String get submittedForReview => 'Submitted for Review';

  @override
  String get subscription => 'Subscription';

  @override
  String get supportAndHelp => 'Support & Help';

  @override
  String get supportBanjarabioApp => 'support@banjarabio.com';

  @override
  String get surname => 'Surname';

  @override
  String get swipe => 'Swipe';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get taluka => 'Taluka';

  @override
  String talukaInDistrictState(String district, String state) {
    return 'Taluka in $district, $state';
  }

  @override
  String get talukaOptional => 'Taluka (Optional)';

  @override
  String get tapTheButtonToAddAPhoto => 'Tap the + button to add a photo';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get tapToReveal => '✨ Tap to Reveal';

  @override
  String get teacherProfessor => 'Teacher/Professor';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get template => 'Template';

  @override
  String get tenToFifteenLakh => '₹10 Lakh - ₹15 Lakh';

  @override
  String get terms => 'Terms';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsS1Content =>
      'By accessing or using the BanjaraBio application, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the service.';

  @override
  String get termsS1Title => '1. Acceptance of Terms';

  @override
  String get termsS2Content =>
      'You must be at least 18 years old (for females) or 21 years old (for males) to register on this platform. The platform is strictly for matrimonial purposes.';

  @override
  String get termsS2Title => '2. Eligibility';

  @override
  String get termsS3Content =>
      'You are responsible for maintaining the confidentiality of your account credentials. All information provided during registration must be accurate and truthful.';

  @override
  String get termsS3Title => '3. User Account';

  @override
  String get termsS4Content =>
      'Users are prohibited from using the platform for commercial purposes, harassment, spreading hate speech, or sharing fraudulent information.';

  @override
  String get termsS4Title => '4. Prohibited Activities';

  @override
  String get termsS5Content =>
      'You may request account deletion at any time through the \"Delete Account\" section in your profile settings.';

  @override
  String get termsS5Title => '5. Account Deletion';

  @override
  String get termsS6Content =>
      'BanjaraBio is a platform for finding matches. We do not guarantee successful matches or verify the character of users beyond basic checks. Users are encouraged to perform their own due diligence.';

  @override
  String get termsS6Title => '6. Limitation of Liability';

  @override
  String get termsS7Content =>
      'These terms shall be governed by and construed in accordance with the laws of India. Any disputes shall be subject to the exclusive jurisdiction of the courts in Maharashtra.';

  @override
  String get termsS7Title => '7. Governing Law';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get textSuper => 'Super';

  @override
  String get thisFieldIsRequired => 'This field is required';

  @override
  String get totalCount => 'Total:';

  @override
  String get totalProfiles => 'Total Profiles';

  @override
  String get traditionalFormalAttire =>
      'Traditional or formal attire (saree, salwar kameez, kurta)';

  @override
  String get trustScore => 'Trust Score';

  @override
  String get trustScoreBeyondBeauty => 'TRUST SCORE BEYOND BEAUTY';

  @override
  String get trustScoreDiscounts => 'Trust Score & Discounts';

  @override
  String trustScoreShareMessage(String score, String url) {
    return 'I just verified my profile on BanjaraBio with a Trust Score of $score! Check out my profile and join our community: $url';
  }

  @override
  String get trustVerification => 'Trust & Verification';

  @override
  String get trusted => 'Trusted';

  @override
  String get trustedMember => 'Trusted Member';

  @override
  String get trustedProfile => 'Trusted Profile';

  @override
  String get tryAdjustingYourFilterCriteria =>
      'Try adjusting your filter criteria';

  @override
  String get tryAdjustingYourFiltersToSeeMoreProfiles =>
      'Try adjusting your filters to see more profiles from the Banjara community';

  @override
  String get tryAgain => 'Try again';

  @override
  String get trySearchingForADifferentCity =>
      'Try searching for a different city';

  @override
  String get trySearchingForDifferentCity =>
      'Try searching for a different city';

  @override
  String get twentyLakhPlus => '₹20 Lakh+';

  @override
  String get twoToFiveLakh => '₹2 Lakh - ₹5 Lakh';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get unauthorizedAccessAdminsOnly =>
      'Unauthorized access. Admins only.';

  @override
  String get under2Lakh => 'Under ₹2 Lakh';

  @override
  String get undo => 'Undo';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String unexpectedErrorOccurred(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get unlimitedBookmarks => 'Unlimited bookmarks';

  @override
  String get unlimitedProfileViews => 'Unlimited profile views';

  @override
  String get unlimitedSharing => 'Unlimited sharing';

  @override
  String get unlockAdvancedFilters => 'Unlock Advanced Filters';

  @override
  String get unlockNow => 'Unlock now';

  @override
  String get unlockPremiumBiodata => 'Unlock Premium Biodata';

  @override
  String get unlockPremiumFeaturesToEnhanceYourBiodat =>
      'Unlock premium features to enhance your biodata profile';

  @override
  String get unlockToDownload =>
      'Unlock to download and share this template in 5+ languages.';

  @override
  String get unmarried => 'Unmarried';

  @override
  String get unsave => 'Unsave';

  @override
  String get update => 'Update';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get upgradePremiumFilters =>
      'Upgrade to Premium to access granular filters for profession, location, and more.';

  @override
  String get upgradeRequired => 'Upgrade Required';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get upgradeToPremiumFor6PhotosAdvancedFilter =>
      'Upgrade to Premium for 6 photos & advanced filters';

  @override
  String get upgradeToPremiumToAccessGranularFiltersF =>
      'Upgrade to Premium to access granular filters';

  @override
  String get upgradeToUnlockAllFeatures => 'Upgrade to unlock all features';

  @override
  String get uploadCommunityCertificateLetter =>
      'Upload Community Certificate / Letter';

  @override
  String get uploadYourPhotos => 'Upload your best photos';

  @override
  String get uploadedSuccessfully => 'Uploaded Successfully';

  @override
  String get upperMiddleClass => 'Upper Middle Class';

  @override
  String get useCameraToCapture => 'Use camera to capture';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get useEmailPassword => 'Use Email / Password';

  @override
  String get useNaturalLightingTip => 'Use natural lighting for best results';

  @override
  String get userBlockedSuccessfully => 'User blocked successfully';

  @override
  String get userIdNotFound => 'User ID not found';

  @override
  String get userIdNotFoundToast => 'User ID not found';

  @override
  String get userLabel => 'User';

  @override
  String get userNotUploadedPhoto => 'User not uploaded photo';

  @override
  String get users => 'Users';

  @override
  String get usingGps => 'Using GPS';

  @override
  String get verificationBadge => 'Verification badge';

  @override
  String get verificationCodeSent => 'Verification code sent!';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get verificationLinkcodeSent => 'Verification link/code sent!';

  @override
  String get verificationRequests => 'Verification Requests';

  @override
  String get verifications => 'Verifications';

  @override
  String get verified => 'Verified';

  @override
  String get verified10PointsAddedToTrustScore =>
      'Verified! +10 Points added to Trust Score';

  @override
  String get verifiedCommunityMember => 'Verified Community Member';

  @override
  String get verifiedProfile => 'Verified Profile';

  @override
  String get verifiedProfileBadge => 'VERIFIED PROFILE';

  @override
  String get verifiedProfilesGet5xMoreResponses =>
      'Verified profiles get 5x more responses and appear higher in search results.';

  @override
  String get verifiedTrusted => 'Verified & Trusted';

  @override
  String get verify => 'Verify';

  @override
  String get verifyEmailAddressHeading => 'Verify Email Address';

  @override
  String verifyLabel(String label) {
    return 'Verify $label';
  }

  @override
  String get verifyMobile => 'Verify Mobile';

  @override
  String get verifyNow => 'Verify Now';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get verifyYourCommunityStatus => 'Verify Your Community Status';

  @override
  String get verifyYourEmailAddressToAddTrustAndReach =>
      'Verify your email address to add trust and reach more profiles.';

  @override
  String get verifyYourMobileNumberToAddTrustAndReach =>
      'Verify your mobile number to add trust and reach more profiles.';

  @override
  String get veryFair => 'Very Fair';

  @override
  String get videoBioIntro => 'Video Bio / Intro';

  @override
  String get videoIntro => 'Video Introduction';

  @override
  String get videoIntroUploaded => 'Video Intro Uploaded';

  @override
  String get videoRecorded => 'Video Recorded!';

  @override
  String get view => 'VIEW';

  @override
  String get viewAll => 'View All';

  @override
  String get viewBiodata => 'View Biodata';

  @override
  String get viewDetails => 'View Details';

  @override
  String get viewLabel => 'view';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get viewYourBookmarkedProfiles => 'View your bookmarked profiles';

  @override
  String get viewsLabel => 'views';

  @override
  String get village => 'Village';

  @override
  String get visibleToAllProfiles => 'Visible to all profiles';

  @override
  String get visibleToCloseMatchesOnly => 'Visible to close matches only';

  @override
  String get weEncounteredAnUnexpectedErrorWhileProce =>
      'We encountered an unexpected error while processing your request.';

  @override
  String get weWillSendAVerificationRequestToTheirMob =>
      'We will send a verification request to their mobile number. Once they approve, you get +10 Points.';

  @override
  String get weWillVerifyYourCommunityDetailsShortly1 =>
      'We will verify your community details shortly. +15 Points Pending.';

  @override
  String get welcomeToBanjaraBio => 'Welcome to BanjaraBio';

  @override
  String get whatDoYouLookFor => 'What do you look for in a partner?';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get whatsAppContact => 'WhatsApp Contact';

  @override
  String whatsappShareSubtitle(String name) {
    return 'Share $name details with family or friends';
  }

  @override
  String get whatsappSupport => 'WhatsApp Support';

  @override
  String get wheatish => 'Wheatish';

  @override
  String get whereDoYouWork => 'Where do you work?';

  @override
  String get whoViewedMe => 'Who Viewed Me';

  @override
  String get whyBanjaraBio => 'Why BanjaraBio?';

  @override
  String get widowed => 'Widowed';

  @override
  String get writeAboutYourself => 'Write something about yourself...';

  @override
  String get year => 'Year';

  @override
  String yearsOld(String age) {
    return '$age Years';
  }

  @override
  String get upgradeToShareMore =>
      'You have reached your free sharing limit. Upgrade to continue sharing profiles.';

  @override
  String get yes => 'Yes';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get youNeedAProfileToShareIt => 'You need a profile to share it.';

  @override
  String get youWillNoLongerSeeThisProfile =>
      'You will no longer see this profile';

  @override
  String get youngerBrother => 'Younger Brother';

  @override
  String get youngerSister => 'Younger Sister';

  @override
  String get your => 'Your';

  @override
  String get yourDailyMatches => 'Your Daily Matches';

  @override
  String get yourDocumentsAreEncrypted =>
      'Your documents are encrypted and never shown to other users. Only the badge is visible.';

  @override
  String get yourDocumentsHaveBeenSubmittedSecurelyWe =>
      'Your documents have been submitted securely. We will notify you once verified.';

  @override
  String get yourIntroVideoIsUnderReview10PointsPendi =>
      'Your intro video is under review. +10 Points pending approval.';

  @override
  String get yourMatchesWillAppearHereOnceYouBothExpr =>
      'Your matches will appear here once you both express interest. Keep sharing profiles to find your perfect match!';

  @override
  String get yourPersonalInviteLink => 'Your Personal Invite Link';

  @override
  String get yourReferralCode => 'Your Referral Code';

  @override
  String get yourSelfieHasBeenSubmittedOurTeamWillVer =>
      'Your selfie has been submitted. Our team will verify it against your profile photo.';

  @override
  String get yourTrustScore => 'Your Trust Score';

  @override
  String yrs(Object count) {
    return '$count Yrs';
  }

  @override
  String get itSAMatch => 'IT\'S A MATCH!';

  @override
  String sharedProfilesWithEachOther(String name) {
    return 'You and $name have shared profiles with each other.';
  }

  @override
  String get mutualMatch => 'Mutual Match';

  @override
  String toContact(Object name) {
    return 'To: $name';
  }

  @override
  String fromContact(Object name) {
    return 'From: $name';
  }

  @override
  String countProfileViews(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profile views',
      one: '1 profile view',
    );
    return '$_temp0';
  }

  @override
  String get matchedBadge => 'MATCHED';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get contactLabel => 'Contact';

  @override
  String profileSharedVia(Object profileName, Object title) {
    return 'Shared $profileName via $title';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Failed to send message: $error';
  }

  @override
  String uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String updateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String errorWithLabel(String label) {
    return 'Error: $label';
  }

  @override
  String referenceWithNumber(int number) {
    return 'Reference $number';
  }

  @override
  String get villageTanda => 'Village / Tanda';

  @override
  String get ageLabel => 'Age';

  @override
  String get heightLabel => 'Height';

  @override
  String get surnameLabel => 'Surname';

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get birthTimeLabel => 'Birth Time';

  @override
  String get birthPlaceLabel => 'Birth Place';

  @override
  String get bloodGroupLabel => 'Blood Group';

  @override
  String get occupationLabel => 'Occupation';

  @override
  String get annualIncomeLabel => 'Annual Income';

  @override
  String get currentResidence => 'Current Residence';

  @override
  String get contactPersonLabel => 'Contact Person';

  @override
  String get bestTimeToContact => 'Best Time to Contact';

  @override
  String get limitReached => 'Limit Reached';

  @override
  String get relationLabel => 'Relation';

  @override
  String get none => 'None';

  @override
  String yearsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Years',
      one: 'Year',
    );
    return '$_temp0';
  }

  @override
  String brothersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brothers',
      one: '1 brother',
    );
    return '$_temp0';
  }

  @override
  String sistersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sisters',
      one: '1 sister',
    );
    return '$_temp0';
  }

  @override
  String get siblingsLabel => 'Siblings';

  @override
  String siblingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count siblings',
      one: '1 sibling',
    );
    return '$_temp0';
  }

  @override
  String get company => 'Company';

  @override
  String get job => 'Job';

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
  String get chooseHowToStart => 'Choose how you want to start';

  @override
  String get exploreAsGuest => 'Explore as Guest';

  @override
  String get exitGuestMode => 'Exit Guest Mode';

  @override
  String get guestModeDesc =>
      'Take a guided tour of the app before creating your profile.';

  @override
  String get createMyBiodata => 'Create My Biodata';

  @override
  String get createBiodataDesc =>
      'Fill out your profile and start connecting instantly.';

  @override
  String get needHelpContactAdmin => 'Need help? Contact Admin';

  @override
  String get noMatchesYet => 'No Matches Yet';

  @override
  String get noProfilesSharedYet => 'No Profiles Shared Yet';

  @override
  String get noProfilesReceived => 'No Profiles Received';

  @override
  String get mutualMatchesDesc =>
      'Mutual matches will appear here when both users share interest in each other';

  @override
  String get startSharingProfilesDesc =>
      'Start sharing profiles with family and friends to help find the perfect match';

  @override
  String get profilesSharedWithYouDesc =>
      'Profiles shared with you by family and friends will appear here';

  @override
  String get enterVillageManually => 'Enter Village/Other Name';

  @override
  String get enterVillageHint => 'Enter Village or Tanda name...';

  @override
  String get specificLocation => 'SPECIFIC LOCATION';

  @override
  String get skipAndSelectLevel => 'Skip & Select Taluka/District';

  @override
  String get optional => 'Optional';

  @override
  String get tourMatchesSearchTitle => 'Search Shared Profiles';

  @override
  String get tourMatchesSearchDesc =>
      'Quickly find profiles shared with you or by you using name or education.';

  @override
  String get tourMatchesSentTitle => 'Sent Profiles';

  @override
  String get tourMatchesSentDesc =>
      'All the profiles you have shared with family and friends appear here.';

  @override
  String get tourMatchesReceivedTitle => 'Received Profiles';

  @override
  String get tourMatchesReceivedDesc =>
      'Profiles others have shared with you via WhatsApp or Link.';

  @override
  String get tourMatchesMatchedTitle => 'Matched Profiles';

  @override
  String get tourMatchesMatchedDesc =>
      'Mutual matches where both you and the other person expressed interest!';

  @override
  String get tourProfilePhotosTitle => 'Manage Photos';

  @override
  String get tourProfilePhotosDesc =>
      'Upload, reorder, or delete your profile photos to make a great first impression.';

  @override
  String get tourProfileTrustTitle => 'Trust Score';

  @override
  String get tourProfileTrustDesc =>
      'Your credibility score. Verify your ID, selfie, and community to increase it.';

  @override
  String get tourProfilePdfTitle => 'Export Biodata PDF';

  @override
  String get tourProfilePdfDesc =>
      'Generate a professional PDF of your biodata to share with family members.';

  @override
  String get tourProfileSavedTitle => 'Saved Profiles';

  @override
  String get tourProfileSavedDesc =>
      'View all the profiles you have bookmarked for later review.';

  @override
  String get tourProfileEditTitle => 'Edit Profile';

  @override
  String get tourProfileEditDesc =>
      'Update your personal details, photos, and preferences anytime.';

  @override
  String get basicPlanName => 'Basic';

  @override
  String get premiumPlanName => 'Premium';

  @override
  String get vipPlanName => 'VIP';

  @override
  String get basicPlanDesc => 'Essential features for your search';

  @override
  String get premiumPlanDesc => 'Advanced features and better visibility';

  @override
  String get vipPlanDesc => 'Ultimate experience with priority support';

  @override
  String get paymentSuccessfulPdfUnlocked =>
      'Payment Successful! PDF Unlocked.';

  @override
  String get standardPlanName => 'Standard';

  @override
  String get standardPlanDesc => 'Try premium features for a month';

  @override
  String get eternalPlanName => 'Eternal - Till U Marry';

  @override
  String get eternalPlanDesc => 'Never worry about expiry again';

  @override
  String get elitePlanName => 'Elite';

  @override
  String get elitePlanDesc => 'Handpicked matches with VIP access';

  @override
  String get royalPlanName => 'Royal';

  @override
  String get royalPlanDesc => 'Dedicated manager finds your match';

  @override
  String get eternalElitePlanName => 'Eternal Elite';

  @override
  String get eternalElitePlanDesc =>
      'Focus on your career, we find your partner';

  @override
  String get selfServicePlans => 'Self-Service';

  @override
  String get vipMatchmaker => 'VIP Matchmaker';

  @override
  String get tillUMarry => 'Till U Marry';

  @override
  String get lifetime => 'Lifetime';

  @override
  String mrpPrice(Object price) {
    return 'MRP ₹$price';
  }

  @override
  String bulkDiscount(Object percent) {
    return '$percent% OFF';
  }

  @override
  String youSave(Object amount) {
    return 'You Save ₹$amount';
  }

  @override
  String totalSavings(Object amount) {
    return 'Total Savings: ₹$amount';
  }

  @override
  String get trustDiscountApplied => 'Trust Score Discount Applied';

  @override
  String get couponDiscountApplied => 'Coupon Discount Applied';

  @override
  String contactUnlocks(Object count) {
    return '$count Contact Unlocks/month';
  }

  @override
  String handpickedMatches(Object count) {
    return '$count Handpicked Matches/week';
  }

  @override
  String get dedicatedManager => 'Dedicated Relationship Manager';

  @override
  String get profileMakeover => 'Professional Profile Makeover';

  @override
  String get featuredBadge => 'Elite Verified Badge';

  @override
  String get featuresIncluded => 'Features included:';

  @override
  String get incognitoMode => 'Private Profile Browsing';

  @override
  String get biodataPremiumIncluded => 'Biodata Premium Included';

  @override
  String get unlimitedContactUnlocks => 'Unlimited Contact Unlocks';

  @override
  String get unlimitedHandpickedMatches => 'Daily On-Demand Matches';

  @override
  String get weeklyCheckIn => 'Weekly Check-in';

  @override
  String get monthlyCheckIn => 'Monthly Check-in';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get personalConcierge => 'Personal Concierge';

  @override
  String get vipFeatures => 'VIP Features';

  @override
  String get directContactAccess => 'Direct Contact Access';

  @override
  String get focusOnCareer =>
      'Focus on your career, while we find your life partner';

  @override
  String get perMonth => '/month';

  @override
  String get forLifetime => 'for Lifetime';

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
  String get signInRequired => 'Sign in Required';

  @override
  String get signInRequiredContent =>
      'Please sign in or create an account to access this feature.';

  @override
  String get watchAdToUnlock => 'WATCH AD TO UNLOCK';

  @override
  String get watchAdToUnlockAll => 'WATCH AD TO UNLOCK ALL';

  @override
  String get goProAdFree => 'Go Pro for Ad-Free Experience';

  @override
  String get adNotReady => 'Ad not ready yet. Please try again in a moment.';

  @override
  String get upgradeToUnlockPremiumFeatures =>
      'Upgrade to remove all ads and unlock premium biodata features.';

  @override
  String get couldNotLaunchWhatsApp => 'Could not launch WhatsApp';

  @override
  String get couldNotLaunchDialer => 'Could not launch Phone Dialer';

  @override
  String get searchLeads => 'Search leads...';

  @override
  String get workspace => 'Workspace';

  @override
  String get customMessage => 'Custom Message';

  @override
  String get logCallOutcome => 'Log Call Outcome';

  @override
  String get apply => 'Apply';

  @override
  String get registrationFee => 'Registration Fee';

  @override
  String get unverified => 'Unverified';

  @override
  String get signIn => 'Sign in';

  @override
  String unlockMoreVisitors(int count) {
    return 'Unlock $count more visitors!';
  }

  @override
  String get dailyLimitReached => 'Daily Limit Reached';

  @override
  String get dailyLimitViewsReached =>
      'You have used all your daily profile views.';

  @override
  String get unlockMoreViewsAd =>
      'Watch a quick ad to unlock 5 MORE views for today!';

  @override
  String get directMessage => 'Direct Message';

  @override
  String get directMessagingPremium => 'Direct messaging is a Premium feature.';

  @override
  String get unlockDirectMessageAd =>
      'Watch 3 ads to unlock 1 direct message for FREE!';

  @override
  String get premiumAccess => 'PREMIUM ACCESS';

  @override
  String get premiumGateSupport =>
      'Support our community by watching a quick ad,\nor upgrade to Pro for an ad-free experience.';

  @override
  String get unblockAllProFeatures => 'UNBLOCK ALL PRO FEATURES';

  @override
  String get monthly => 'Monthly';

  @override
  String get annual => 'Annual';

  @override
  String get watchQuickAd => 'WATCH QUICK AD';

  @override
  String get continueBlockedUntilAdEnds =>
      'CONTINUE TO APP BLOCKED UNTIL AD ENDS';

  @override
  String get adCompletedSuccessfully => 'AD COMPLETED SUCCESSFULLY';

  @override
  String get continueToApp => 'CONTINUE TO APP';

  @override
  String get preparingAdExperience => 'PREPARING AD EXPERIENCE...';

  @override
  String get adTemporarilyUnavailable => 'AD TEMPORARILY UNAVAILABLE';

  @override
  String get callAdmin => 'Call Admin';

  @override
  String get banjaraBioPro => 'BanjaraBio Pro';

  @override
  String get claimMarriageGift => 'Claim Marriage Gift';

  @override
  String get tellUsYourStory => 'Tell us your Story';

  @override
  String get partnerName => 'Partner\'s Name';

  @override
  String get yourSuccessStory => 'Your Success Story';

  @override
  String get howDidYouMeet => 'How did you meet? What do you like about them?';

  @override
  String get proofOfMarriage => 'Proof of Marriage';

  @override
  String get instagramLink => 'Instagram Reel/Story Link';

  @override
  String get pasteUrlHere => 'Paste the URL here';

  @override
  String get weddingDate => 'Wedding Date';

  @override
  String get estimatedRefund => 'Estimated Refund';

  @override
  String get submitForReview => 'SUBMIT FOR REVIEW';

  @override
  String get selectRewardType => 'Select Reward Type';

  @override
  String get digital => 'Digital';

  @override
  String get refund25 => '25% Refund';

  @override
  String get teamVisit => 'Team Visit';

  @override
  String get refund35 => '35% Refund';

  @override
  String get successSubmission =>
      'Success! Your request has been submitted for review.';
}
