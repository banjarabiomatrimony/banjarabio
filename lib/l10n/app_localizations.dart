import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
    Locale('te'),
  ];

  /// No description provided for @ableBodied.
  ///
  /// In en, this message translates to:
  /// **'Able-Bodied'**
  String get ableBodied;

  /// No description provided for @aboutFamily.
  ///
  /// In en, this message translates to:
  /// **'About Family'**
  String get aboutFamily;

  /// No description provided for @aboutSelf.
  ///
  /// In en, this message translates to:
  /// **'About Self'**
  String get aboutSelf;

  /// No description provided for @aboutYourself.
  ///
  /// In en, this message translates to:
  /// **'About Yourself'**
  String get aboutYourself;

  /// No description provided for @abusiveBehavior.
  ///
  /// In en, this message translates to:
  /// **'Abusive Behavior'**
  String get abusiveBehavior;

  /// No description provided for @acceptAndConnect.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT & CONNECT 💖'**
  String get acceptAndConnect;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountAndAllDataDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account and all data deleted successfully.'**
  String get accountAndAllDataDeletedSuccessfully;

  /// No description provided for @accountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion'**
  String get accountDeletion;

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get acres;

  /// No description provided for @actionIsIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.'**
  String get actionIsIrreversible;

  /// No description provided for @activeCreators.
  ///
  /// In en, this message translates to:
  /// **'Active Creators'**
  String get activeCreators;

  /// No description provided for @activeSubscriptionCancelledNoRefund.
  ///
  /// In en, this message translates to:
  /// **'Your active subscription will be cancelled without refund.'**
  String get activeSubscriptionCancelledNoRefund;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @adCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'AD COMPLETED SUCCESSFULLY'**
  String get adCompletedSuccessfully;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFreeExperience;

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'Ad not ready yet. Please try again in a moment.'**
  String get adNotReady;

  /// No description provided for @adTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AD TEMPORARILY UNAVAILABLE'**
  String get adTemporarilyUnavailable;

  /// No description provided for @addClearPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add clear photos ({max} max)'**
  String addClearPhotos(int max);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addPhotosToYourBiodataProfileToIncreaseV.
  ///
  /// In en, this message translates to:
  /// **'Add photos to your biodata profile to increase visibility and trust'**
  String get addPhotosToYourBiodataProfileToIncreaseV;

  /// No description provided for @addSibling.
  ///
  /// In en, this message translates to:
  /// **'Add Sibling'**
  String get addSibling;

  /// No description provided for @addTwoReferences.
  ///
  /// In en, this message translates to:
  /// **'Add Two References'**
  String get addTwoReferences;

  /// No description provided for @addYourBrothersAndSisters.
  ///
  /// In en, this message translates to:
  /// **'Add your brothers and sisters'**
  String get addYourBrothersAndSisters;

  /// No description provided for @addYourFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Photo'**
  String get addYourFirstPhoto;

  /// No description provided for @additionalPreferences.
  ///
  /// In en, this message translates to:
  /// **'Additional Preferences'**
  String get additionalPreferences;

  /// No description provided for @additionalProfessionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Professional Info'**
  String get additionalProfessionalInfo;

  /// No description provided for @adjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get adjust;

  /// No description provided for @adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Adjust Filters'**
  String get adjustFilters;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLogin;

  /// No description provided for @adminLoginRequiresAuthorizedCredentials.
  ///
  /// In en, this message translates to:
  /// **'Admin login requires authorized credentials'**
  String get adminLoginRequiresAuthorizedCredentials;

  /// No description provided for @adminManagement.
  ///
  /// In en, this message translates to:
  /// **'Admin Management'**
  String get adminManagement;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @advancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get advancedFilters;

  /// No description provided for @affluent.
  ///
  /// In en, this message translates to:
  /// **'Affluent'**
  String get affluent;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @ageAndSurnameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{age} Yrs • {surname}'**
  String ageAndSurnameSubtitle(String age, String surname);

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age Range'**
  String get ageRange;

  /// No description provided for @ageRangeYears.
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} yrs'**
  String ageRangeYears(Object max, Object min);

  /// No description provided for @aiBio.
  ///
  /// In en, this message translates to:
  /// **'AI Bio'**
  String get aiBio;

  /// No description provided for @algorithmInsightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Our matchmaking algorithm evaluates authentic Banjara exogamy rules (checking self gotra & maternal gotra separation), Vedic astrological Guna Milan, verified education & income parameters, and mutual partner preferences.'**
  String get algorithmInsightsDescription;

  /// No description provided for @alignedExpectations.
  ///
  /// In en, this message translates to:
  /// **'Aligned Expectations'**
  String get alignedExpectations;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allInDistrict.
  ///
  /// In en, this message translates to:
  /// **'All in {district}'**
  String allInDistrict(String district);

  /// No description provided for @allInSelectedDistrict.
  ///
  /// In en, this message translates to:
  /// **'All in selected District'**
  String get allInSelectedDistrict;

  /// No description provided for @allInSelectedState.
  ///
  /// In en, this message translates to:
  /// **'All in selected State'**
  String get allInSelectedState;

  /// No description provided for @allInState.
  ///
  /// In en, this message translates to:
  /// **'All in {state}'**
  String allInState(String state);

  /// No description provided for @allIndia.
  ///
  /// In en, this message translates to:
  /// **'All India'**
  String get allIndia;

  /// No description provided for @allPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'All Photos ({count}/{max})'**
  String allPhotosCount(int count, int max);

  /// No description provided for @allProfiles.
  ///
  /// In en, this message translates to:
  /// **'All Profiles'**
  String get allProfiles;

  /// No description provided for @allYourProfileDataPermanentlyRemoved.
  ///
  /// In en, this message translates to:
  /// **'All your profile data will be permanently removed.'**
  String get allYourProfileDataPermanentlyRemoved;

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost Done!'**
  String get almostDone;

  /// No description provided for @almostDoneReview.
  ///
  /// In en, this message translates to:
  /// **'Review all sections and click \"Save Biodata\" to complete your profile. Your biodata will be visible to other community members based on your privacy settings.'**
  String get almostDoneReview;

  /// No description provided for @alreadyHaveProfileLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have a profile? Login'**
  String get alreadyHaveProfileLogin;

  /// No description provided for @alternateRelativeContactNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Alternate / Relative Contact Number (Optional)'**
  String get alternateRelativeContactNumberOptional;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// No description provided for @ancestralLand.
  ///
  /// In en, this message translates to:
  /// **'Ancestral Land'**
  String get ancestralLand;

  /// No description provided for @ancestralLandHoldingsAcres.
  ///
  /// In en, this message translates to:
  /// **'Ancestral Land Holdings (Acres)'**
  String get ancestralLandHoldingsAcres;

  /// No description provided for @ancestralLandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter candidates by family agricultural land ownership'**
  String get ancestralLandSubtitle;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @annualIncome.
  ///
  /// In en, this message translates to:
  /// **'Individual Annual Income'**
  String get annualIncome;

  /// No description provided for @annualIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Total yearly earnings from salary or business. (NOT family savings)'**
  String get annualIncomeHint;

  /// No description provided for @annualIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual Income'**
  String get annualIncomeLabel;

  /// No description provided for @annualIncomeSalary.
  ///
  /// In en, this message translates to:
  /// **'Annual Income / Salary'**
  String get annualIncomeSalary;

  /// No description provided for @annualIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select candidate yearly income expectations'**
  String get annualIncomeSubtitle;

  /// No description provided for @annulled.
  ///
  /// In en, this message translates to:
  /// **'Annulled'**
  String get annulled;

  /// No description provided for @appGrowth.
  ///
  /// In en, this message translates to:
  /// **'App Growth'**
  String get appGrowth;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BanjaraBio'**
  String get appName;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply All Filters'**
  String get applyAllFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @applyFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters ({count} Active)'**
  String applyFiltersCount(Object count);

  /// No description provided for @applyLocation.
  ///
  /// In en, this message translates to:
  /// **'Apply Location'**
  String get applyLocation;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @areYouReadyForDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Are you ready for discussions?'**
  String get areYouReadyForDiscussions;

  /// No description provided for @areYouSureDeleteSelectedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} photo(s)?'**
  String areYouSureDeleteSelectedPhotos(int count);

  /// No description provided for @areYouSureExit.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get areYouSureExit;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @areYouSureYouWantToBlockThisUserYouWillN.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user? You will not be able to see their profile again.'**
  String get areYouSureYouWantToBlockThisUserYouWillN;

  /// No description provided for @areYouSureYouWantToDeleteThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get areYouSureYouWantToDeleteThisPhoto;

  /// No description provided for @areYouSureYouWantToDeleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get areYouSureYouWantToDeleteYourAccount;

  /// No description provided for @askFamilySuggestionsTip.
  ///
  /// In en, this message translates to:
  /// **'Ask family members for photo suggestions'**
  String get askFamilySuggestionsTip;

  /// No description provided for @astro36GunaMilanScore.
  ///
  /// In en, this message translates to:
  /// **'Astro 36 Guna Milan Score'**
  String get astro36GunaMilanScore;

  /// No description provided for @astro36GunaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter matches by minimum astrological compatibility threshold'**
  String get astro36GunaSubtitle;

  /// No description provided for @atLeastOnePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one photo is required'**
  String get atLeastOnePhotoRequired;

  /// No description provided for @awaitingDivorce.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Divorce'**
  String get awaitingDivorce;

  /// No description provided for @bachelorsDegree.
  ///
  /// In en, this message translates to:
  /// **'Bachelor\'s Degree'**
  String get bachelorsDegree;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backSide.
  ///
  /// In en, this message translates to:
  /// **'Back Side'**
  String get backSide;

  /// No description provided for @backToGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Google Sign In'**
  String get backToGoogleSignIn;

  /// No description provided for @banjaraBioPro.
  ///
  /// In en, this message translates to:
  /// **'BanjaraBio Pro'**
  String get banjaraBioPro;

  /// No description provided for @banjaraClanRoots.
  ///
  /// In en, this message translates to:
  /// **'BANJARA CLAN ROOTS'**
  String get banjaraClanRoots;

  /// No description provided for @banjaraGotraClan.
  ///
  /// In en, this message translates to:
  /// **'Banjara Gotra (Clan)'**
  String get banjaraGotraClan;

  /// No description provided for @banjaraGotraCustoms.
  ///
  /// In en, this message translates to:
  /// **'Banjara Gotra Customs (गोत्र व मोसळ)'**
  String get banjaraGotraCustoms;

  /// No description provided for @banjaraGotraSelfClan.
  ///
  /// In en, this message translates to:
  /// **'Banjara Gotra (Self Clan)'**
  String get banjaraGotraSelfClan;

  /// No description provided for @banjaraMember.
  ///
  /// In en, this message translates to:
  /// **'Banjara Member'**
  String get banjaraMember;

  /// No description provided for @banjaraVirasatSangh.
  ///
  /// In en, this message translates to:
  /// **'Banjara Virasat Sangh'**
  String get banjaraVirasatSangh;

  /// No description provided for @banjarabio.
  ///
  /// In en, this message translates to:
  /// **'BanjaraBio'**
  String get banjarabio;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @basicPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Essential features for your search'**
  String get basicPlanDesc;

  /// No description provided for @basicPlanName.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicPlanName;

  /// No description provided for @benefitPdfBiodata.
  ///
  /// In en, this message translates to:
  /// **'Create Beautiful PDF Biodata in 2 Mins'**
  String get benefitPdfBiodata;

  /// No description provided for @benefitShareWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share Directly on WhatsApp'**
  String get benefitShareWhatsApp;

  /// No description provided for @benefitVerifiedProfiles.
  ///
  /// In en, this message translates to:
  /// **'100% Verified Community Profiles'**
  String get benefitVerifiedProfiles;

  /// No description provided for @bestTimeToContact.
  ///
  /// In en, this message translates to:
  /// **'Best Time to Contact'**
  String get bestTimeToContact;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @biodata.
  ///
  /// In en, this message translates to:
  /// **'Biodata'**
  String get biodata;

  /// No description provided for @biodataDraftRestored.
  ///
  /// In en, this message translates to:
  /// **'Biodata draft restored!'**
  String get biodataDraftRestored;

  /// No description provided for @biodataDraftRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biodata draft restored successfully!'**
  String get biodataDraftRestoredSuccess;

  /// No description provided for @biodataPdf.
  ///
  /// In en, this message translates to:
  /// **'Biodata PDF'**
  String get biodataPdf;

  /// No description provided for @biodataPremiumIncluded.
  ///
  /// In en, this message translates to:
  /// **'Biodata Premium Included'**
  String get biodataPremiumIncluded;

  /// No description provided for @biodataRequired.
  ///
  /// In en, this message translates to:
  /// **'Biodata Required'**
  String get biodataRequired;

  /// No description provided for @biodataSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Biodata saved successfully!'**
  String get biodataSavedSuccessfully;

  /// No description provided for @biodataUnlockPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock professional premium templates'**
  String get biodataUnlockPlanDesc;

  /// No description provided for @biodataUnlockPlanName.
  ///
  /// In en, this message translates to:
  /// **'Biodata Premium'**
  String get biodataUnlockPlanName;

  /// No description provided for @birthDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Birth Details'**
  String get birthDetails;

  /// No description provided for @birthPlace.
  ///
  /// In en, this message translates to:
  /// **'Birth Place'**
  String get birthPlace;

  /// No description provided for @birthPlaceAndTime.
  ///
  /// In en, this message translates to:
  /// **'Birth Place & Time'**
  String get birthPlaceAndTime;

  /// No description provided for @birthPlaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Place'**
  String get birthPlaceLabel;

  /// No description provided for @birthTime.
  ///
  /// In en, this message translates to:
  /// **'Birth Time'**
  String get birthTime;

  /// No description provided for @birthTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Time'**
  String get birthTimeLabel;

  /// No description provided for @birthTimeVisibleOnPdf.
  ///
  /// In en, this message translates to:
  /// **'Birth time & birth place visible on PDF'**
  String get birthTimeVisibleOnPdf;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @bloodGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroupLabel;

  /// No description provided for @blurryLowQualityImages.
  ///
  /// In en, this message translates to:
  /// **'Blurry, dark, or low-quality images'**
  String get blurryLowQualityImages;

  /// Title when user hits bookmark limit
  ///
  /// In en, this message translates to:
  /// **'Bookmark Limit Reached'**
  String get bookmarkLimitReached;

  /// No description provided for @bookmarksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bookmarks'**
  String bookmarksCount(int count);

  /// No description provided for @bride.
  ///
  /// In en, this message translates to:
  /// **'Bride'**
  String get bride;

  /// No description provided for @brideGirl.
  ///
  /// In en, this message translates to:
  /// **'👧 Bride (Girl)'**
  String get brideGirl;

  /// No description provided for @brideOption.
  ///
  /// In en, this message translates to:
  /// **'👧 Bride (Girl)'**
  String get brideOption;

  /// No description provided for @bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get bronze;

  /// No description provided for @brother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get brother;

  /// No description provided for @brotherCount.
  ///
  /// In en, this message translates to:
  /// **'Brothers'**
  String get brotherCount;

  /// No description provided for @brothersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 brother} other{{count} brothers}}'**
  String brothersCount(int count);

  /// No description provided for @browseMatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'Search suitable matches for son, daughter, relative.'**
  String get browseMatchesDesc;

  /// No description provided for @browseMatchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions and see suitable matches'**
  String get browseMatchesSubtitle;

  /// No description provided for @browseMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Matches (Browse)'**
  String get browseMatchesTitle;

  /// No description provided for @browseProfiles.
  ///
  /// In en, this message translates to:
  /// **'Browse Profiles'**
  String get browseProfiles;

  /// No description provided for @bulkDiscount.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String bulkDiscount(int percent);

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @businessOwner.
  ///
  /// In en, this message translates to:
  /// **'Business Owner'**
  String get businessOwner;

  /// No description provided for @bvsAnnualPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual Plan'**
  String get bvsAnnualPlanLabel;

  /// No description provided for @bvsAnnualPrice.
  ///
  /// In en, this message translates to:
  /// **'₹200 / Year'**
  String get bvsAnnualPrice;

  /// No description provided for @bvsCardSelected.
  ///
  /// In en, this message translates to:
  /// **'Card Selected'**
  String get bvsCardSelected;

  /// No description provided for @bvsConceptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initiative: Hon. Shri Sanjaybhau Rathod\nMinister, Govt. of Maharashtra'**
  String get bvsConceptSubtitle;

  /// No description provided for @bvsCopyMessageToast.
  ///
  /// In en, this message translates to:
  /// **'🚩 BVS invite message copied!'**
  String get bvsCopyMessageToast;

  /// No description provided for @bvsHeritageEmblemDesc.
  ///
  /// In en, this message translates to:
  /// **'Pohradevi & 12+ Crore community pride'**
  String get bvsHeritageEmblemDesc;

  /// No description provided for @bvsHeritageEmblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Heritage Seal'**
  String get bvsHeritageEmblemTitle;

  /// No description provided for @bvsHowToJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Join BVS & Unlock Discounts?'**
  String get bvsHowToJoinTitle;

  /// No description provided for @bvsJoinCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'⚡ Register on BVS portal to get ₹200/year discount'**
  String get bvsJoinCardSubtitle;

  /// No description provided for @bvsJoinNowButton.
  ///
  /// In en, this message translates to:
  /// **'Join BVS Today (Join Now)'**
  String get bvsJoinNowButton;

  /// No description provided for @bvsMember.
  ///
  /// In en, this message translates to:
  /// **'🏛️ BVS Member'**
  String get bvsMember;

  /// No description provided for @bvsMemberId.
  ///
  /// In en, this message translates to:
  /// **'BVS Member ID No (e.g. 405812)'**
  String get bvsMemberId;

  /// No description provided for @bvsMembershipCard.
  ///
  /// In en, this message translates to:
  /// **'BVS Membership Card'**
  String get bvsMembershipCard;

  /// No description provided for @bvsMonthlyPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get bvsMonthlyPlanLabel;

  /// No description provided for @bvsMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'₹20 / Month'**
  String get bvsMonthlyPrice;

  /// No description provided for @bvsMovementDesc.
  ///
  /// In en, this message translates to:
  /// **'A historic movement to strengthen the unity and future of the Banjara community.'**
  String get bvsMovementDesc;

  /// No description provided for @bvsNotRegisteredYet.
  ///
  /// In en, this message translates to:
  /// **'Not a BVS member yet? Register here »'**
  String get bvsNotRegisteredYet;

  /// No description provided for @bvsOfficialEmblems.
  ///
  /// In en, this message translates to:
  /// **'Official BVS Emblems'**
  String get bvsOfficialEmblems;

  /// No description provided for @bvsShareOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get bvsShareOnWhatsApp;

  /// No description provided for @bvsSpecialDiscountBanner.
  ///
  /// In en, this message translates to:
  /// **'Are you a Banjara Virasat Sangh member? Upload your BVS card to unlock the Annual Plan at just ₹200!'**
  String get bvsSpecialDiscountBanner;

  /// No description provided for @bvsStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Enter your details on the official BVS portal.'**
  String get bvsStep1Desc;

  /// No description provided for @bvsStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Register Online'**
  String get bvsStep1Title;

  /// No description provided for @bvsStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Receive your official digital ID card and Member ID.'**
  String get bvsStep2Desc;

  /// No description provided for @bvsStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Get Membership Card'**
  String get bvsStep2Title;

  /// No description provided for @bvsStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Upload BVS card to activate ₹200/yr subsidized plan.'**
  String get bvsStep3Desc;

  /// No description provided for @bvsStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Upload Card on BanjaraBio'**
  String get bvsStep3Title;

  /// No description provided for @bvsSubsidyCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Huge savings on BanjaraBio Matrimony Subscriptions!'**
  String get bvsSubsidyCardSubtitle;

  /// No description provided for @bvsSubsidyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Special Discount for BVS Members!'**
  String get bvsSubsidyCardTitle;

  /// No description provided for @bvsTitle.
  ///
  /// In en, this message translates to:
  /// **'Banjara Virasat Sangh'**
  String get bvsTitle;

  /// No description provided for @bvsUnityEmblemDesc.
  ///
  /// In en, this message translates to:
  /// **'Hands linked in unity & traditional embroidery'**
  String get bvsUnityEmblemDesc;

  /// No description provided for @bvsUnityEmblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Unity Emblem'**
  String get bvsUnityEmblemTitle;

  /// No description provided for @bvsUploadCardButton.
  ///
  /// In en, this message translates to:
  /// **'Upload BVS Card (Get Discount)'**
  String get bvsUploadCardButton;

  /// No description provided for @bvsUploadCardPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload photo of BVS Membership Card'**
  String get bvsUploadCardPromptSubtitle;

  /// No description provided for @bvsVerifiedActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'👑 BVS Verified Member Discount Active!'**
  String get bvsVerifiedActiveBadge;

  /// No description provided for @bvsVerifiedActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Monthly plan at ₹20 and Annual plan at ₹200 are active for you.'**
  String get bvsVerifiedActiveDesc;

  /// No description provided for @bvsVerifiedSpecialPlan.
  ///
  /// In en, this message translates to:
  /// **'BVS Member Special Plan'**
  String get bvsVerifiedSpecialPlan;

  /// No description provided for @bvsWhatsAppInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Automation Invite'**
  String get bvsWhatsAppInviteTitle;

  /// No description provided for @byContAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get byContAcceptTerms;

  /// No description provided for @callAdmin.
  ///
  /// In en, this message translates to:
  /// **'Call Admin'**
  String get callAdmin;

  /// No description provided for @callOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Call Organizer'**
  String get callOrganizer;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @candidatesMeet.
  ///
  /// In en, this message translates to:
  /// **'Candidates Meet'**
  String get candidatesMeet;

  /// No description provided for @careerPillarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Graduate / Professional background & steady income'**
  String get careerPillarSubtitle;

  /// No description provided for @careerSocioeconomicPillar.
  ///
  /// In en, this message translates to:
  /// **'Career & Socioeconomic Level'**
  String get careerSocioeconomicPillar;

  /// No description provided for @careerWealthHoldings.
  ///
  /// In en, this message translates to:
  /// **'Career & Wealth Holdings'**
  String get careerWealthHoldings;

  /// No description provided for @changeCriteriaOrExitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to change your search options or exit the app?'**
  String get changeCriteriaOrExitPrompt;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @changeOptionsCta.
  ///
  /// In en, this message translates to:
  /// **'Change Options ✏️'**
  String get changeOptionsCta;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatConversationArchived.
  ///
  /// In en, this message translates to:
  /// **'Chat conversation archived'**
  String get chatConversationArchived;

  /// No description provided for @checkBackSoonForNewMatchesnpullDownToRef.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new matches.\\nPull down to refresh.'**
  String get checkBackSoonForNewMatchesnpullDownToRef;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'Check Inbox'**
  String get checkInbox;

  /// No description provided for @checkInternet.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkInternet;

  /// No description provided for @checkWhoIsLookingAtYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Check who is looking at your profile'**
  String get checkWhoIsLookingAtYourProfile;

  /// No description provided for @chipFreeAccess.
  ///
  /// In en, this message translates to:
  /// **'⭐ 100% Free Access'**
  String get chipFreeAccess;

  /// No description provided for @chipNoAccount.
  ///
  /// In en, this message translates to:
  /// **'⚡ No Account Needed'**
  String get chipNoAccount;

  /// No description provided for @chipQuickFilter.
  ///
  /// In en, this message translates to:
  /// **'🔍 1-Min Search'**
  String get chipQuickFilter;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseHowToStart.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to start'**
  String get chooseHowToStart;

  /// No description provided for @chooseQuickIntroTemplate.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE A QUICK INTRO TEMPLATE'**
  String get chooseQuickIntroTemplate;

  /// No description provided for @chooseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose Template'**
  String get chooseTemplate;

  /// No description provided for @claimMarriageGift.
  ///
  /// In en, this message translates to:
  /// **'Claim Marriage Gift'**
  String get claimMarriageGift;

  /// No description provided for @clanExogamyPillar.
  ///
  /// In en, this message translates to:
  /// **'Clan Exogamy (गोत्र व मोसळ)'**
  String get clanExogamyPillar;

  /// No description provided for @clanExogamyPillarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Different paternal Gotra ({gotra}) & Mamakul ({maternalGotra})'**
  String clanExogamyPillarSubtitle(String gotra, String maternalGotra);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All Filters'**
  String get clearAllFilters;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @clearText.
  ///
  /// In en, this message translates to:
  /// **'Clear text'**
  String get clearText;

  /// No description provided for @clearWellLitPhotos.
  ///
  /// In en, this message translates to:
  /// **'Clear, well-lit photos showing your face clearly'**
  String get clearWellLitPhotos;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closePreview.
  ///
  /// In en, this message translates to:
  /// **'Close Preview'**
  String get closePreview;

  /// No description provided for @collegeInstitute.
  ///
  /// In en, this message translates to:
  /// **'College / Institute'**
  String get collegeInstitute;

  /// No description provided for @comeBackTomorrowFornnewCuratedMatches.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for\\nnew curated matches!'**
  String get comeBackTomorrowFornnewCuratedMatches;

  /// No description provided for @communityFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gotra, Mamakul, Origin, Height, Income & Lineage'**
  String get communityFiltersSubtitle;

  /// No description provided for @communityFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Filters (BVS)'**
  String get communityFiltersTitle;

  /// No description provided for @communityId.
  ///
  /// In en, this message translates to:
  /// **'Community ID'**
  String get communityId;

  /// No description provided for @communityIdSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Community ID Submitted'**
  String get communityIdSubmitted;

  /// No description provided for @communityIdVerification.
  ///
  /// In en, this message translates to:
  /// **'Community ID'**
  String get communityIdVerification;

  /// No description provided for @communityMember.
  ///
  /// In en, this message translates to:
  /// **'Community Member'**
  String get communityMember;

  /// No description provided for @communityTrustedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Community Trusted Profiles'**
  String get communityTrustedProfiles;

  /// No description provided for @communityTrustedProfilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vouched Banjara profiles with Community Trust Score > 75%'**
  String get communityTrustedProfilesSubtitle;

  /// No description provided for @communityVerification.
  ///
  /// In en, this message translates to:
  /// **'Community Verification'**
  String get communityVerification;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @companyOrg.
  ///
  /// In en, this message translates to:
  /// **'Company / Org'**
  String get companyOrg;

  /// No description provided for @compareAllPlanFeatures.
  ///
  /// In en, this message translates to:
  /// **'Compare All Plan Features'**
  String get compareAllPlanFeatures;

  /// No description provided for @compatibleRoots.
  ///
  /// In en, this message translates to:
  /// **'Compatible Roots'**
  String get compatibleRoots;

  /// No description provided for @completeVerificationToUnlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Complete verification to unlock \'Premium\' status.'**
  String get completeVerificationToUnlockPremium;

  /// No description provided for @completeYourProfileToGetNoticed.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get noticed!'**
  String get completeYourProfileToGetNoticed;

  /// No description provided for @completedReferrals.
  ///
  /// In en, this message translates to:
  /// **'Completed Referrals'**
  String get completedReferrals;

  /// No description provided for @completion.
  ///
  /// In en, this message translates to:
  /// **'COMPLETION'**
  String get completion;

  /// No description provided for @complexion.
  ///
  /// In en, this message translates to:
  /// **'Complexion'**
  String get complexion;

  /// No description provided for @compressingUnder500Kb.
  ///
  /// In en, this message translates to:
  /// **'Compressing under 500KB...'**
  String get compressingUnder500Kb;

  /// No description provided for @confidentialMatchmaking.
  ///
  /// In en, this message translates to:
  /// **'Confidential & Private Matchmaking'**
  String get confidentialMatchmaking;

  /// No description provided for @confidentialMatchmakingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'High-profile biodatas viewable exclusively with mutual RM consent'**
  String get confidentialMatchmakingSubtitle;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @connectInApp.
  ///
  /// In en, this message translates to:
  /// **'CONNECT IN-APP'**
  String get connectInApp;

  /// No description provided for @connectWithCommunity.
  ///
  /// In en, this message translates to:
  /// **'Connect with your Banjara community'**
  String get connectWithCommunity;

  /// No description provided for @connectionAcceptedToast.
  ///
  /// In en, this message translates to:
  /// **'Connection Accepted! You can now chat directly 🎉'**
  String get connectionAcceptedToast;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @contactPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPersonLabel;

  /// No description provided for @contactPreferences.
  ///
  /// In en, this message translates to:
  /// **'Contact Preferences'**
  String get contactPreferences;

  /// No description provided for @contactUnlocks.
  ///
  /// In en, this message translates to:
  /// **'{count} Contact Unlocks/month'**
  String contactUnlocks(int count);

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @continueAsGuestCta.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest 🚀'**
  String get continueAsGuestCta;

  /// No description provided for @continueBlockedUntilAdEnds.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO APP BLOCKED UNTIL AD ENDS'**
  String get continueBlockedUntilAdEnds;

  /// No description provided for @continueToApp.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO APP'**
  String get continueToApp;

  /// No description provided for @continueWithFreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue with Free Account'**
  String get continueWithFreeAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithStandardFilters.
  ///
  /// In en, this message translates to:
  /// **'Continue with Standard Filters'**
  String get continueWithStandardFilters;

  /// No description provided for @conversationPinnedToTop.
  ///
  /// In en, this message translates to:
  /// **'Conversation pinned to top 📌'**
  String get conversationPinnedToTop;

  /// No description provided for @conversationUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Conversation unpinned'**
  String get conversationUnpinned;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @copyLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy a link to {name} profile'**
  String copyLinkSubtitle(String name);

  /// No description provided for @copyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy Message'**
  String get copyMessage;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer'**
  String get couldNotLaunchDialer;

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL'**
  String get couldNotLaunchUrl;

  /// No description provided for @couldNotLaunchWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not launch WhatsApp'**
  String get couldNotLaunchWhatsApp;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your profile. Please try again.'**
  String get couldNotLoadProfile;

  /// No description provided for @couldNotTriggerSharing.
  ///
  /// In en, this message translates to:
  /// **'Could not trigger sharing'**
  String get couldNotTriggerSharing;

  /// No description provided for @countProfileViews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 profile view} other{{count} profile views}}'**
  String countProfileViews(int count);

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @couponDiscountApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon Discount Applied'**
  String get couponDiscountApplied;

  /// No description provided for @createBiodata.
  ///
  /// In en, this message translates to:
  /// **'Create Biodata'**
  String get createBiodata;

  /// No description provided for @createBiodataCta.
  ///
  /// In en, this message translates to:
  /// **'Create Biodata ✨'**
  String get createBiodataCta;

  /// No description provided for @createBiodataDesc.
  ///
  /// In en, this message translates to:
  /// **'Fill out your profile and start connecting instantly.'**
  String get createBiodataDesc;

  /// No description provided for @createBiodataForSelfOrCandidateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an attractive marriage biodata in 2 minutes, download PDF, share on WhatsApp, and receive matches directly.'**
  String get createBiodataForSelfOrCandidateSubtitle;

  /// No description provided for @createBiodataForSelfOrCandidateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Biodata for Self / Candidate'**
  String get createBiodataForSelfOrCandidateTitle;

  /// No description provided for @createFreeProfile100PercentFree.
  ///
  /// In en, this message translates to:
  /// **'✨ Create Free Profile (100% Free)'**
  String get createFreeProfile100PercentFree;

  /// No description provided for @createMyBiodata.
  ///
  /// In en, this message translates to:
  /// **'Create My Biodata'**
  String get createMyBiodata;

  /// No description provided for @createNow.
  ///
  /// In en, this message translates to:
  /// **'Create Now'**
  String get createNow;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @criticalFailure.
  ///
  /// In en, this message translates to:
  /// **'Critical failure: {error}'**
  String criticalFailure(String error);

  /// No description provided for @cropPhoto.
  ///
  /// In en, this message translates to:
  /// **'Crop Photo'**
  String get cropPhoto;

  /// No description provided for @cropRotate.
  ///
  /// In en, this message translates to:
  /// **'Crop & Rotate'**
  String get cropRotate;

  /// No description provided for @culturallyVerified.
  ///
  /// In en, this message translates to:
  /// **'CULTURALLY VERIFIED'**
  String get culturallyVerified;

  /// No description provided for @curatedProfilesJustForYou.
  ///
  /// In en, this message translates to:
  /// **'{count} curated profiles just for you'**
  String curatedProfilesJustForYou(int count);

  /// No description provided for @currentCity.
  ///
  /// In en, this message translates to:
  /// **'Current City'**
  String get currentCity;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @currentNativeRegion.
  ///
  /// In en, this message translates to:
  /// **'CURRENT & NATIVE REGION'**
  String get currentNativeRegion;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @currentResidence.
  ///
  /// In en, this message translates to:
  /// **'Current Residence'**
  String get currentResidence;

  /// No description provided for @currentResidenceState.
  ///
  /// In en, this message translates to:
  /// **'Current Residence State'**
  String get currentResidenceState;

  /// No description provided for @currentState.
  ///
  /// In en, this message translates to:
  /// **'Current State'**
  String get currentState;

  /// No description provided for @currentVillageHint.
  ///
  /// In en, this message translates to:
  /// **'Current village'**
  String get currentVillageHint;

  /// No description provided for @customMessage.
  ///
  /// In en, this message translates to:
  /// **'Custom Message'**
  String get customMessage;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @customizeBiodata.
  ///
  /// In en, this message translates to:
  /// **'Customize Biodata'**
  String get customizeBiodata;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @dailyActiveUsers.
  ///
  /// In en, this message translates to:
  /// **'Daily Active Users'**
  String get dailyActiveUsers;

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit Reached'**
  String get dailyLimitReached;

  /// No description provided for @dailyLimitViewsReached.
  ///
  /// In en, this message translates to:
  /// **'You have used all your daily profile views.'**
  String get dailyLimitViewsReached;

  /// No description provided for @dailyMatch.
  ///
  /// In en, this message translates to:
  /// **'Daily Match'**
  String get dailyMatch;

  /// No description provided for @dailyMatchPicks.
  ///
  /// In en, this message translates to:
  /// **'Daily Match Picks'**
  String get dailyMatchPicks;

  /// No description provided for @dailyMessageLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily message limit reached.'**
  String get dailyMessageLimitReached;

  /// No description provided for @dailyRewardClaimedSuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Success! {rewardName}'**
  String dailyRewardClaimedSuccess(String rewardName);

  /// No description provided for @dailyViewLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily view limit reached.'**
  String get dailyViewLimitReached;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @daughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get daughter;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'DECLINE'**
  String get decline;

  /// No description provided for @dedicatedManager.
  ///
  /// In en, this message translates to:
  /// **'Dedicated Relationship Manager'**
  String get dedicatedManager;

  /// No description provided for @degreeField.
  ///
  /// In en, this message translates to:
  /// **'Degree / Field'**
  String get degreeField;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteCount.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String deleteCount(int count);

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @deletePhotos.
  ///
  /// In en, this message translates to:
  /// **'Delete Photos'**
  String get deletePhotos;

  /// No description provided for @deleteSelectedSharesQuery.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete the selected share?} other{Are you sure you want to delete {count} selected shares?}}'**
  String deleteSelectedSharesQuery(int count);

  /// No description provided for @deleteShares.
  ///
  /// In en, this message translates to:
  /// **'Delete Shares'**
  String get deleteShares;

  /// No description provided for @deletingYourAccountWillResultIn.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will result in:'**
  String get deletingYourAccountWillResultIn;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demo;

  /// No description provided for @demographicsAndPremium.
  ///
  /// In en, this message translates to:
  /// **'Demographics & Premium'**
  String get demographicsAndPremium;

  /// No description provided for @describeYourselfInterestsHobbies.
  ///
  /// In en, this message translates to:
  /// **'Describe yourself, interests, hobbies...'**
  String get describeYourselfInterestsHobbies;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamond;

  /// No description provided for @dietHabits.
  ///
  /// In en, this message translates to:
  /// **'Diet / Food Habits'**
  String get dietHabits;

  /// No description provided for @differentSettingsTip.
  ///
  /// In en, this message translates to:
  /// **'Include photos in different settings (formal, casual)'**
  String get differentSettingsTip;

  /// No description provided for @differentlyAbled.
  ///
  /// In en, this message translates to:
  /// **'Diff. Abled'**
  String get differentlyAbled;

  /// No description provided for @digital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get digital;

  /// No description provided for @diploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get diploma;

  /// No description provided for @directAdminSupport.
  ///
  /// In en, this message translates to:
  /// **'Direct Admin Support'**
  String get directAdminSupport;

  /// No description provided for @directContactAccess.
  ///
  /// In en, this message translates to:
  /// **'Direct Contact Access'**
  String get directContactAccess;

  /// No description provided for @directContactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Direct Contact Unlocked Profiles'**
  String get directContactUnlocked;

  /// No description provided for @directContactUnlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Phone Number & WhatsApp verified access'**
  String get directContactUnlockedSubtitle;

  /// No description provided for @directMessage.
  ///
  /// In en, this message translates to:
  /// **'Direct Message'**
  String get directMessage;

  /// No description provided for @directMessages.
  ///
  /// In en, this message translates to:
  /// **'Direct Messages'**
  String get directMessages;

  /// No description provided for @directMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay responsive when your match sends you a message.'**
  String get directMessagesSubtitle;

  /// No description provided for @directMessaging.
  ///
  /// In en, this message translates to:
  /// **'Direct messaging'**
  String get directMessaging;

  /// No description provided for @directMessagingPremium.
  ///
  /// In en, this message translates to:
  /// **'Direct messaging is a Premium feature.'**
  String get directMessagingPremium;

  /// No description provided for @directNoteSentToast.
  ///
  /// In en, this message translates to:
  /// **'Direct Note sent with high priority! 💌'**
  String get directNoteSentToast;

  /// No description provided for @directWhatsAppLeads.
  ///
  /// In en, this message translates to:
  /// **'📱 Direct WhatsApp Leads'**
  String get directWhatsAppLeads;

  /// No description provided for @disabledHint.
  ///
  /// In en, this message translates to:
  /// **'Optional field for physically challenged individuals'**
  String get disabledHint;

  /// No description provided for @disabledTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledTagLabel;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go back? Your progress is saved as a draft.'**
  String get discardChangesBody;

  /// No description provided for @discountPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% OFF (Trust Score {score})'**
  String discountPercentage(int percentage, int score);

  /// No description provided for @discoverProfilesFromYourCommunityNsmartM.
  ///
  /// In en, this message translates to:
  /// **'Discover profiles from your community.\\nSmart matchmaking powered by compatibility scores.'**
  String get discoverProfilesFromYourCommunityNsmartM;

  /// No description provided for @displayLayoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Layout'**
  String get displayLayoutLabel;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @districtInState.
  ///
  /// In en, this message translates to:
  /// **'District in {state}'**
  String districtInState(String state);

  /// No description provided for @districtInStateLabel.
  ///
  /// In en, this message translates to:
  /// **'District in State'**
  String get districtInStateLabel;

  /// No description provided for @divorced.
  ///
  /// In en, this message translates to:
  /// **'Divorced'**
  String get divorced;

  /// No description provided for @doctorate.
  ///
  /// In en, this message translates to:
  /// **'Doctorate'**
  String get doctorate;

  /// No description provided for @documentProofs.
  ///
  /// In en, this message translates to:
  /// **'Document Proofs:'**
  String get documentProofs;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @documentView.
  ///
  /// In en, this message translates to:
  /// **'Document View'**
  String get documentView;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @downloadBtn.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadBtn;

  /// No description provided for @downloadWatermarkFreeBiodataDesc.
  ///
  /// In en, this message translates to:
  /// **'Download watermark-free high definition 2-Page Biodata in all formats.'**
  String get downloadWatermarkFreeBiodataDesc;

  /// No description provided for @drinkingHabits.
  ///
  /// In en, this message translates to:
  /// **'Drinking Habits'**
  String get drinkingHabits;

  /// No description provided for @dusky.
  ///
  /// In en, this message translates to:
  /// **'Dusky'**
  String get dusky;

  /// No description provided for @easiest.
  ///
  /// In en, this message translates to:
  /// **'Easiest'**
  String get easiest;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editBiodataInfoPhotos.
  ///
  /// In en, this message translates to:
  /// **'Edit Biodata Info & Photos'**
  String get editBiodataInfoPhotos;

  /// No description provided for @editBiodataInfoPhotosDesc.
  ///
  /// In en, this message translates to:
  /// **'Edit Education, Gotra, Family, Native Tanda & Photo in your master profile.'**
  String get editBiodataInfoPhotosDesc;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @educationAndProfession.
  ///
  /// In en, this message translates to:
  /// **'Education & Profession'**
  String get educationAndProfession;

  /// No description provided for @educationDetails.
  ///
  /// In en, this message translates to:
  /// **'Education Details'**
  String get educationDetails;

  /// No description provided for @educationFieldStream.
  ///
  /// In en, this message translates to:
  /// **'Education Field / Stream'**
  String get educationFieldStream;

  /// No description provided for @educationFieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by specialized degree stream & career path'**
  String get educationFieldSubtitle;

  /// No description provided for @educationLabel.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationLabel;

  /// No description provided for @educationProfession.
  ///
  /// In en, this message translates to:
  /// **'Education & Profession'**
  String get educationProfession;

  /// No description provided for @educationProfessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Education & Career'**
  String get educationProfessionDetails;

  /// No description provided for @educationalQualification.
  ///
  /// In en, this message translates to:
  /// **'Educational Qualification'**
  String get educationalQualification;

  /// No description provided for @egSeniorSoftwareEngineer.
  ///
  /// In en, this message translates to:
  /// **'e.g. Senior Software Engineer'**
  String get egSeniorSoftwareEngineer;

  /// No description provided for @egSpecialization.
  ///
  /// In en, this message translates to:
  /// **'e.g. Specialization or Honors'**
  String get egSpecialization;

  /// No description provided for @egSpecializationOrHonors.
  ///
  /// In en, this message translates to:
  /// **'e.g. Specialization or Honors'**
  String get egSpecializationOrHonors;

  /// No description provided for @egTime.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10:30 AM'**
  String get egTime;

  /// No description provided for @elderBrother.
  ///
  /// In en, this message translates to:
  /// **'Elder Brother'**
  String get elderBrother;

  /// No description provided for @elderSister.
  ///
  /// In en, this message translates to:
  /// **'Elder Sister'**
  String get elderSister;

  /// No description provided for @elitePlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Handpicked matches with VIP access'**
  String get elitePlanDesc;

  /// No description provided for @elitePlanName.
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get elitePlanName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @emailVerificationTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Check your spam folder if you don\'t see the email.'**
  String get emailVerificationTip;

  /// No description provided for @emailVerifiedSuccessfully10Points.
  ///
  /// In en, this message translates to:
  /// **'Email Verified Successfully! +10 Points'**
  String get emailVerifiedSuccessfully10Points;

  /// No description provided for @employmentSector.
  ///
  /// In en, this message translates to:
  /// **'Employment Sector'**
  String get employmentSector;

  /// No description provided for @emptyStr.
  ///
  /// In en, this message translates to:
  /// **'₹'**
  String get emptyStr;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your basic information as it appears in official documents'**
  String get enterBasicInfo;

  /// No description provided for @enterCityVillage.
  ///
  /// In en, this message translates to:
  /// **'Enter city/village'**
  String get enterCityVillage;

  /// No description provided for @enterDistrictExample.
  ///
  /// In en, this message translates to:
  /// **'Enter District (e.g. Nanded, Yavatmal, Nizamabad)'**
  String get enterDistrictExample;

  /// No description provided for @enterEducationDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your education details'**
  String get enterEducationDetails;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @enterProfessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your profession details'**
  String get enterProfessionDetails;

  /// No description provided for @enterVillageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Village or Tanda name...'**
  String get enterVillageHint;

  /// No description provided for @enterVillageManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Village/Other Name'**
  String get enterVillageManually;

  /// No description provided for @enterYourBasicInformationAsItAppearsInOf.
  ///
  /// In en, this message translates to:
  /// **'Enter your basic information as it appears in official documents'**
  String get enterYourBasicInformationAsItAppearsInOf;

  /// No description provided for @enterYourEducationDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your education details'**
  String get enterYourEducationDetails;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @enterYourProfessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your profession details'**
  String get enterYourProfessionDetails;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorAdminActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The requested action could not be completed. Please try again later.'**
  String get errorAdminActionFailed;

  /// No description provided for @errorCheckingShareLimits.
  ///
  /// In en, this message translates to:
  /// **'Error checking share limits: {error}'**
  String errorCheckingShareLimits(String error);

  /// No description provided for @errorCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Error checking status: {error}'**
  String errorCheckingStatus(String error);

  /// No description provided for @errorCheckingViewLimits.
  ///
  /// In en, this message translates to:
  /// **'Error checking view limits: {error}'**
  String errorCheckingViewLimits(String error);

  /// No description provided for @errorLaunchingLink.
  ///
  /// In en, this message translates to:
  /// **'Error launching link'**
  String get errorLaunchingLink;

  /// No description provided for @errorLoadingAdminCoupons.
  ///
  /// In en, this message translates to:
  /// **'Failed to load coupon offers. Please try again.'**
  String get errorLoadingAdminCoupons;

  /// No description provided for @errorLoadingAdminCreators.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch creator list. Please check your network.'**
  String get errorLoadingAdminCreators;

  /// No description provided for @errorLoadingAdminData.
  ///
  /// In en, this message translates to:
  /// **'Error loading admin data: {error}'**
  String errorLoadingAdminData(String error);

  /// No description provided for @errorLoadingAdminPayments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment history. Please try again.'**
  String get errorLoadingAdminPayments;

  /// No description provided for @errorLoadingAdminReferences.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch pending references. Please refresh.'**
  String get errorLoadingAdminReferences;

  /// No description provided for @errorLoadingAdminStats.
  ///
  /// In en, this message translates to:
  /// **'Unable to load dashboard statistics. Please try refreshing.'**
  String get errorLoadingAdminStats;

  /// No description provided for @errorLoadingAdminUsers.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch user list. Please check your connection.'**
  String get errorLoadingAdminUsers;

  /// No description provided for @errorLoadingAdminVerifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load verification requests. Please try again.'**
  String get errorLoadingAdminVerifications;

  /// No description provided for @errorLoadingRequests.
  ///
  /// In en, this message translates to:
  /// **'Error loading requests: {error}'**
  String errorLoadingRequests(String error);

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(String error);

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// No description provided for @errorWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {label}'**
  String errorWithLabel(String label);

  /// No description provided for @estimatedRefund.
  ///
  /// In en, this message translates to:
  /// **'Estimated Refund'**
  String get estimatedRefund;

  /// No description provided for @eternalElitePlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on your career, we find your partner'**
  String get eternalElitePlanDesc;

  /// No description provided for @eternalElitePlanName.
  ///
  /// In en, this message translates to:
  /// **'Eternal Elite'**
  String get eternalElitePlanName;

  /// No description provided for @eternalPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Never worry about expiry again'**
  String get eternalPlanDesc;

  /// No description provided for @eternalPlanName.
  ///
  /// In en, this message translates to:
  /// **'Eternal - Till U Marry'**
  String get eternalPlanName;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @everyProfileIsVerifiedWithIdSelfieRefere.
  ///
  /// In en, this message translates to:
  /// **'Every profile is verified with ID, selfie & references.\\nTrust Score ensures genuine connections.'**
  String get everyProfileIsVerifiedWithIdSelfieRefere;

  /// No description provided for @exactBirthTimeAndKundali.
  ///
  /// In en, this message translates to:
  /// **'Exact Birth Time & Kundali'**
  String get exactBirthTimeAndKundali;

  /// No description provided for @excellentMatch.
  ///
  /// In en, this message translates to:
  /// **'EXCELLENT MATCH'**
  String get excellentMatch;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitGuestMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Guest Mode'**
  String get exitGuestMode;

  /// No description provided for @exogamous.
  ///
  /// In en, this message translates to:
  /// **'EXOGAMOUS'**
  String get exogamous;

  /// No description provided for @exogamyCompliant.
  ///
  /// In en, this message translates to:
  /// **'EXOGAMY COMPLIANT'**
  String get exogamyCompliant;

  /// No description provided for @exogamyRuleDescription.
  ///
  /// In en, this message translates to:
  /// **'In traditional Banjara (Gor) culture, marriages follow strict Clan Exogamy (गोत्र बहिर्विवाह):'**
  String get exogamyRuleDescription;

  /// No description provided for @exploreAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Explore as Guest'**
  String get exploreAsGuest;

  /// No description provided for @exploreMatchmakerPlans.
  ///
  /// In en, this message translates to:
  /// **'Explore Matchmaker Plans'**
  String get exploreMatchmakerPlans;

  /// No description provided for @exploreMatchmakerPlansButton.
  ///
  /// In en, this message translates to:
  /// **'Explore Matchmaker Plans ➔'**
  String get exploreMatchmakerPlansButton;

  /// No description provided for @explorePremiumPlans.
  ///
  /// In en, this message translates to:
  /// **'Explore Premium Plans'**
  String get explorePremiumPlans;

  /// No description provided for @exportBiodataPdf.
  ///
  /// In en, this message translates to:
  /// **'Export Biodata PDF'**
  String get exportBiodataPdf;

  /// No description provided for @expressInterest.
  ///
  /// In en, this message translates to:
  /// **'Express Interest?'**
  String get expressInterest;

  /// No description provided for @expressInterestDesc.
  ///
  /// In en, this message translates to:
  /// **'Express your interest by sharing your biodata directly'**
  String get expressInterestDesc;

  /// No description provided for @extraViewsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} Extra Views Unlocked!'**
  String extraViewsUnlocked(int count);

  /// No description provided for @failedLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile context: {error}'**
  String failedLoadProfile(String error);

  /// No description provided for @failedSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google: {error}'**
  String failedSignInGoogle(String error);

  /// No description provided for @failedSignInGoogleRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google. Please try again.'**
  String get failedSignInGoogleRetry;

  /// No description provided for @failedToBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to block user: {error}'**
  String failedToBlockUser(String error);

  /// No description provided for @failedToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String failedToDeleteAccount(String error);

  /// No description provided for @failedToDeletePhotoError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete photo: {error}'**
  String failedToDeletePhotoError(String error);

  /// No description provided for @failedToGeneratePdfPreview.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF preview'**
  String get failedToGeneratePdfPreview;

  /// No description provided for @failedToLoadBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookmarks: {error}'**
  String failedToLoadBookmarks(String error);

  /// No description provided for @failedToLoadPhotosError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load photos: {error}'**
  String failedToLoadPhotosError(String error);

  /// No description provided for @failedToLoadProfileError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String failedToLoadProfileError(String error);

  /// No description provided for @failedToLoadProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile information'**
  String get failedToLoadProfileInformation;

  /// No description provided for @failedToLoadProfiles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profiles'**
  String get failedToLoadProfiles;

  /// No description provided for @failedToLoadReferralData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load referral data'**
  String get failedToLoadReferralData;

  /// No description provided for @failedToLoadSubscription.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscription: {error}'**
  String failedToLoadSubscription(String error);

  /// No description provided for @failedToLoadTrustScoreStats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load trust score stats'**
  String get failedToLoadTrustScoreStats;

  /// No description provided for @failedToLogout.
  ///
  /// In en, this message translates to:
  /// **'Failed to logout: {error}'**
  String failedToLogout(String error);

  /// No description provided for @failedToPrintPdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to print PDF'**
  String get failedToPrintPdf;

  /// No description provided for @failedToProcessImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image'**
  String get failedToProcessImage;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @failedToSavePdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to save PDF: {error}'**
  String failedToSavePdf(String error);

  /// No description provided for @failedToSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile: {error}'**
  String failedToSaveProfile(String error);

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failedToSendMessage(String error);

  /// No description provided for @failedToSendNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to send note: {error}'**
  String failedToSendNote(Object error);

  /// No description provided for @failedToSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to share PDF'**
  String get failedToSharePdf;

  /// No description provided for @failedToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to start chat: {error}'**
  String failedToStartChat(String error);

  /// No description provided for @failedToSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report: {error}'**
  String failedToSubmitReport(String error);

  /// No description provided for @failedToUpdateBookmark.
  ///
  /// In en, this message translates to:
  /// **'Failed to update bookmark: {error}'**
  String failedToUpdateBookmark(String error);

  /// No description provided for @failedToUpdatePremiumStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update premium status: {error}'**
  String failedToUpdatePremiumStatus(String error);

  /// No description provided for @failedToUpdatePrimaryPhotoError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update primary photo: {error}'**
  String failedToUpdatePrimaryPhotoError(String error);

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @failedToUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo {index}'**
  String failedToUploadPhoto(String index);

  /// No description provided for @failedToVerify.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify: {error}'**
  String failedToVerify(String error);

  /// No description provided for @failedWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedWithError(Object error);

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @fakeProfile.
  ///
  /// In en, this message translates to:
  /// **'Fake Profile'**
  String get fakeProfile;

  /// No description provided for @familyBackground.
  ///
  /// In en, this message translates to:
  /// **'Family Background'**
  String get familyBackground;

  /// No description provided for @familyDetails.
  ///
  /// In en, this message translates to:
  /// **'Family Details'**
  String get familyDetails;

  /// No description provided for @familyFirstValues.
  ///
  /// In en, this message translates to:
  /// **'Family-First Values'**
  String get familyFirstValues;

  /// No description provided for @familyOnly.
  ///
  /// In en, this message translates to:
  /// **'Family Only'**
  String get familyOnly;

  /// No description provided for @familyReputationVetted.
  ///
  /// In en, this message translates to:
  /// **'Family Background & Reputation Vetted'**
  String get familyReputationVetted;

  /// No description provided for @familyReputationVettedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clean background check conducted by field relationship managers'**
  String get familyReputationVettedSubtitle;

  /// No description provided for @familyStatus.
  ///
  /// In en, this message translates to:
  /// **'Family Status'**
  String get familyStatus;

  /// No description provided for @familyStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select socioeconomic family status requirement'**
  String get familyStatusSubtitle;

  /// No description provided for @familyStructure.
  ///
  /// In en, this message translates to:
  /// **'Family Structure'**
  String get familyStructure;

  /// No description provided for @familyStructureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select nuclear or joint family preferences'**
  String get familyStructureSubtitle;

  /// No description provided for @familyType.
  ///
  /// In en, this message translates to:
  /// **'Family Type'**
  String get familyType;

  /// No description provided for @familyValues.
  ///
  /// In en, this message translates to:
  /// **'Family Values'**
  String get familyValues;

  /// No description provided for @familyValuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by cultural and social outlook'**
  String get familyValuesSubtitle;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Go to the Profile tab and click on \"Create Biodata\" or edit your existing profile. Follow the multi-step form to fill in your personal, family, and professional details.'**
  String get faqA1;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Yes, we take privacy seriously. Your contact details are only shown to verified users and respect our community safety guidelines.'**
  String get faqA2;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'On the home screen, use the \"Filters\" button to narrow down profiles by age, location, education, and profession.'**
  String get faqA3;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Premium users get unlimited profile views, early access to new biodatas, and enhanced visibility in search results.'**
  String get faqA4;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Go to My Profile > Legal & Information > Account Deletion to permanently remove your profile and data from our system.'**
  String get faqA5;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I create a biodata?'**
  String get faqQ1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faqQ2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How can I filter profiles?'**
  String get faqQ3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'What are the benefits of Premium?'**
  String get faqQ4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get faqQ5;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fatherName;

  /// No description provided for @fatherOccupation.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Occupation'**
  String get fatherOccupation;

  /// No description provided for @featuredBadge.
  ///
  /// In en, this message translates to:
  /// **'Elite Verified Badge'**
  String get featuredBadge;

  /// No description provided for @featuresIncluded.
  ///
  /// In en, this message translates to:
  /// **'Features included:'**
  String get featuresIncluded;

  /// No description provided for @feet.
  ///
  /// In en, this message translates to:
  /// **'feet'**
  String get feet;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// No description provided for @fifteenToTwentyLakh.
  ///
  /// In en, this message translates to:
  /// **'₹15 Lakh - ₹20 Lakh'**
  String get fifteenToTwentyLakh;

  /// No description provided for @fiftyPercentOffVipUpgrade.
  ///
  /// In en, this message translates to:
  /// **'🔥 50% OFF VIP Upgrade'**
  String get fiftyPercentOffVipUpgrade;

  /// No description provided for @filterAstrologicalCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Filter candidate astrological horoscope compatibility'**
  String get filterAstrologicalCompatibility;

  /// No description provided for @filterCandidateHomeState.
  ///
  /// In en, this message translates to:
  /// **'Filter candidate home state or current residing district'**
  String get filterCandidateHomeState;

  /// No description provided for @filterProfiles.
  ///
  /// In en, this message translates to:
  /// **'Filter profiles'**
  String get filterProfiles;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'(filtered)'**
  String get filtered;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filtersResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Filters reset to default'**
  String get filtersResetToDefault;

  /// No description provided for @financialPerformance.
  ///
  /// In en, this message translates to:
  /// **'Financial Performance'**
  String get financialPerformance;

  /// No description provided for @findYourPerfectMatch.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Match'**
  String get findYourPerfectMatch;

  /// No description provided for @fiveToSevenHalfLakh.
  ///
  /// In en, this message translates to:
  /// **'₹5 Lakh - ₹7.5 Lakh'**
  String get fiveToSevenHalfLakh;

  /// No description provided for @focusOnCareer.
  ///
  /// In en, this message translates to:
  /// **'Focus on your career, while we find your life partner'**
  String get focusOnCareer;

  /// No description provided for @followAndGetFivePercent.
  ///
  /// In en, this message translates to:
  /// **'Follow & Get +5%'**
  String get followAndGetFivePercent;

  /// No description provided for @followDailyMatchUpdates.
  ///
  /// In en, this message translates to:
  /// **'Follow Daily Match Updates'**
  String get followDailyMatchUpdates;

  /// No description provided for @followUsOnInstagramBonus.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram to get a 5% biodata completion bonus and stay updated with the latest matches.'**
  String get followUsOnInstagramBonus;

  /// No description provided for @forLifetime.
  ///
  /// In en, this message translates to:
  /// **'for Lifetime'**
  String get forLifetime;

  /// No description provided for @forMonths.
  ///
  /// In en, this message translates to:
  /// **'for {count} months'**
  String forMonths(int count);

  /// No description provided for @forMyDaughter.
  ///
  /// In en, this message translates to:
  /// **'👧 For My Daughter'**
  String get forMyDaughter;

  /// No description provided for @forMyRelative.
  ///
  /// In en, this message translates to:
  /// **'👨‍👩‍👧 For My Relative'**
  String get forMyRelative;

  /// No description provided for @forMySibling.
  ///
  /// In en, this message translates to:
  /// **'👫 For My Sibling'**
  String get forMySibling;

  /// No description provided for @forMySon.
  ///
  /// In en, this message translates to:
  /// **'👦 For My Son'**
  String get forMySon;

  /// No description provided for @forMyself.
  ///
  /// In en, this message translates to:
  /// **'👤 For Myself'**
  String get forMyself;

  /// No description provided for @forOther.
  ///
  /// In en, this message translates to:
  /// **'✨ For Someone Else'**
  String get forOther;

  /// No description provided for @forWhomSearching.
  ///
  /// In en, this message translates to:
  /// **'Who are you searching a match for?'**
  String get forWhomSearching;

  /// No description provided for @foundYourPartner.
  ///
  /// In en, this message translates to:
  /// **'Found your Partner?'**
  String get foundYourPartner;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @free1PhotonpremiumUpTo6Photos.
  ///
  /// In en, this message translates to:
  /// **'Free: 1 photo\\nPremium: Up to 6 photos'**
  String get free1PhotonpremiumUpTo6Photos;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @freePlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Try basic features'**
  String get freePlanDesc;

  /// No description provided for @freeUserLimitInfo.
  ///
  /// In en, this message translates to:
  /// **'Free user limit reached. Upgrade to continue.'**
  String get freeUserLimitInfo;

  /// No description provided for @freeUsersCanUpload1PhotoUpgradeToUploadU.
  ///
  /// In en, this message translates to:
  /// **'Free users can upload 1 photo. Upgrade to upload up to 5 photos.'**
  String get freeUsersCanUpload1PhotoUpgradeToUploadU;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @fromContact.
  ///
  /// In en, this message translates to:
  /// **'From: {name}'**
  String fromContact(String name);

  /// No description provided for @frontSide.
  ///
  /// In en, this message translates to:
  /// **'Front Side'**
  String get frontSide;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @fullKundaliAvailableOnMutual.
  ///
  /// In en, this message translates to:
  /// **'Full Kundali chart available on mutual match interest.'**
  String get fullKundaliAvailableOnMutual;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderSelectHeading.
  ///
  /// In en, this message translates to:
  /// **'Your Gender is'**
  String get genderSelectHeading;

  /// No description provided for @generateBio.
  ///
  /// In en, this message translates to:
  /// **'Generate Bio'**
  String get generateBio;

  /// No description provided for @generatingPreview.
  ///
  /// In en, this message translates to:
  /// **'Generating preview...'**
  String get generatingPreview;

  /// No description provided for @getAProfessionalWellformattedPdfWithoutW.
  ///
  /// In en, this message translates to:
  /// **'Get a professional, well-formatted PDF without watermarks and with all details visible.'**
  String get getAProfessionalWellformattedPdfWithoutW;

  /// No description provided for @getInTouchWithUs.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us'**
  String get getInTouchWithUs;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @getStartedLabel.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedLabel;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @goProAdFree.
  ///
  /// In en, this message translates to:
  /// **'Go Pro for Ad-Free Experience'**
  String get goProAdFree;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @goldMember.
  ///
  /// In en, this message translates to:
  /// **'⭐ Gold Member'**
  String get goldMember;

  /// No description provided for @goldPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Most popular - Best value'**
  String get goldPlanDesc;

  /// No description provided for @goldPlanName.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get goldPlanName;

  /// No description provided for @goldVerified.
  ///
  /// In en, this message translates to:
  /// **'Gold Verified'**
  String get goldVerified;

  /// No description provided for @goodMatch.
  ///
  /// In en, this message translates to:
  /// **'GOOD MATCH'**
  String get goodMatch;

  /// No description provided for @gorBanjara.
  ///
  /// In en, this message translates to:
  /// **'Gor / Banjara'**
  String get gorBanjara;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @gotra.
  ///
  /// In en, this message translates to:
  /// **'Gotra'**
  String get gotra;

  /// No description provided for @governmentEmployee.
  ///
  /// In en, this message translates to:
  /// **'Government Employee'**
  String get governmentEmployee;

  /// No description provided for @governmentId.
  ///
  /// In en, this message translates to:
  /// **'Government ID'**
  String get governmentId;

  /// No description provided for @governmentIdVerification.
  ///
  /// In en, this message translates to:
  /// **'Government ID Verification'**
  String get governmentIdVerification;

  /// No description provided for @governmentIdVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a blurred copy of your Aadhar or PAN to get a \'Verified\' badge.'**
  String get governmentIdVerificationSubtitle;

  /// No description provided for @governmentJob.
  ///
  /// In en, this message translates to:
  /// **'Government Job'**
  String get governmentJob;

  /// No description provided for @govtId.
  ///
  /// In en, this message translates to:
  /// **'Govt ID'**
  String get govtId;

  /// No description provided for @govtIdVerification.
  ///
  /// In en, this message translates to:
  /// **'Government ID'**
  String get govtIdVerification;

  /// No description provided for @govtIdVerified.
  ///
  /// In en, this message translates to:
  /// **'Govt ID / Aadhaar Verified'**
  String get govtIdVerified;

  /// No description provided for @govtIdVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only show candidates with 100% verified Govt ID badge'**
  String get govtIdVerifiedSubtitle;

  /// No description provided for @graduate.
  ///
  /// In en, this message translates to:
  /// **'Graduate'**
  String get graduate;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @groom.
  ///
  /// In en, this message translates to:
  /// **'Groom'**
  String get groom;

  /// No description provided for @groomBoy.
  ///
  /// In en, this message translates to:
  /// **'👦 Groom (Boy)'**
  String get groomBoy;

  /// No description provided for @groomOption.
  ///
  /// In en, this message translates to:
  /// **'👦 Groom (Boy)'**
  String get groomOption;

  /// No description provided for @groupPhotosNotVisible.
  ///
  /// In en, this message translates to:
  /// **'Group photos where you are not clearly visible'**
  String get groupPhotosNotVisible;

  /// No description provided for @growYourWeddingBusiness.
  ///
  /// In en, this message translates to:
  /// **'Grow Your Wedding Business'**
  String get growYourWeddingBusiness;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @guestModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a guided tour of the app before creating your profile.'**
  String get guestModeDesc;

  /// No description provided for @guestModeInstantBrowseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore BanjaraBio instantly without an account to see features and available profiles.'**
  String get guestModeInstantBrowseSubtitle;

  /// No description provided for @guestModeInstantBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode (Instant Browse)'**
  String get guestModeInstantBrowseTitle;

  /// No description provided for @guestRestrictedContent.
  ///
  /// In en, this message translates to:
  /// **'To view all details, save profiles, and communicate with matches, please create your biodata or change your search options.'**
  String get guestRestrictedContent;

  /// No description provided for @guestRestrictionMessage.
  ///
  /// In en, this message translates to:
  /// **'To interact with profiles, express interest, or send messages, you need to create your own biodata first.'**
  String get guestRestrictionMessage;

  /// No description provided for @gunaMilanScore.
  ///
  /// In en, this message translates to:
  /// **'Guna Milan (36 Points)'**
  String get gunaMilanScore;

  /// No description provided for @gunasMatchedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / 36 Gunas Matched ({percentage}%)'**
  String gunasMatchedCount(int count, int percentage);

  /// No description provided for @gunasMatchedStatus.
  ///
  /// In en, this message translates to:
  /// **'28 / 36 Gunas Matched'**
  String get gunasMatchedStatus;

  /// No description provided for @habitatNativeOrigin.
  ///
  /// In en, this message translates to:
  /// **'Habitat / Native Origin'**
  String get habitatNativeOrigin;

  /// No description provided for @habitatPillarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shared cultural values & open relocation preferences'**
  String get habitatPillarSubtitle;

  /// No description provided for @habitatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter candidate living environment & origin type'**
  String get habitatSubtitle;

  /// No description provided for @habitatTandaPillar.
  ///
  /// In en, this message translates to:
  /// **'Habitat, Tanda & Lifestyle'**
  String get habitatTandaPillar;

  /// No description provided for @handpickedMatches.
  ///
  /// In en, this message translates to:
  /// **'{count} Handpicked Matches/week'**
  String handpickedMatches(int count);

  /// No description provided for @haveQuestionsOrNeedAssistanceOurTeamIsHe.
  ///
  /// In en, this message translates to:
  /// **'Have questions or need assistance? Our team is here to help you find your perfect match.'**
  String get haveQuestionsOrNeedAssistanceOurTeamIsHe;

  /// No description provided for @headerBlessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select which divine blessing is engraved at the top of your PDF'**
  String get headerBlessingSubtitle;

  /// No description provided for @headerBlessingTitle.
  ///
  /// In en, this message translates to:
  /// **'🪔 Header Blessing / Deity Mantra'**
  String get headerBlessingTitle;

  /// No description provided for @heavilyFilteredEdited.
  ///
  /// In en, this message translates to:
  /// **'Heavily filtered or edited photos'**
  String get heavilyFilteredEdited;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @helpOurCommunityGrowAndUnlockPremiumRewa.
  ///
  /// In en, this message translates to:
  /// **'Help our community grow and unlock Premium rewards for yourself.'**
  String get helpOurCommunityGrowAndUnlockPremiumRewa;

  /// No description provided for @hideAlgorithmInsights.
  ///
  /// In en, this message translates to:
  /// **'Hide Algorithm Insights'**
  String get hideAlgorithmInsights;

  /// No description provided for @highMatch.
  ///
  /// In en, this message translates to:
  /// **'HIGH MATCH'**
  String get highMatch;

  /// No description provided for @highSchool.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get highSchool;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @homemaker.
  ///
  /// In en, this message translates to:
  /// **'Homemaker'**
  String get homemaker;

  /// No description provided for @horoscopeChartVerified.
  ///
  /// In en, this message translates to:
  /// **'Horoscope chart verified & matched.'**
  String get horoscopeChartVerified;

  /// No description provided for @horoscopeKundali.
  ///
  /// In en, this message translates to:
  /// **'Horoscope & Kundali (कुंडली)'**
  String get horoscopeKundali;

  /// No description provided for @horoscopeKundaliAttached.
  ///
  /// In en, this message translates to:
  /// **'Horoscope / Kundali Attached'**
  String get horoscopeKundaliAttached;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @houseOwnership.
  ///
  /// In en, this message translates to:
  /// **'House Ownership'**
  String get houseOwnership;

  /// No description provided for @howDidYouMeet.
  ///
  /// In en, this message translates to:
  /// **'How did you meet? What do you like about them?'**
  String get howDidYouMeet;

  /// No description provided for @howIsScoreCalculated.
  ///
  /// In en, this message translates to:
  /// **'How is this score calculated?'**
  String get howIsScoreCalculated;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @iUnderstandThatThisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'I understand that this action cannot be undone.'**
  String get iUnderstandThatThisActionCannotBeUndone;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idLabel(String id);

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @idType.
  ///
  /// In en, this message translates to:
  /// **'ID Type'**
  String get idType;

  /// No description provided for @identityDetails.
  ///
  /// In en, this message translates to:
  /// **'Identity Details'**
  String get identityDetails;

  /// No description provided for @inappropriateBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'Photos with inappropriate backgrounds'**
  String get inappropriateBackgrounds;

  /// No description provided for @inappropriateContentOrFakeProfile.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content or fake profile'**
  String get inappropriateContentOrFakeProfile;

  /// No description provided for @inappropriatePhotos.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Photos'**
  String get inappropriatePhotos;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'inches'**
  String get inches;

  /// No description provided for @incognitoMode.
  ///
  /// In en, this message translates to:
  /// **'Private Profile Browsing'**
  String get incognitoMode;

  /// No description provided for @incomeHiddenFromPdf.
  ///
  /// In en, this message translates to:
  /// **'Hidden from shared PDF for privacy'**
  String get incomeHiddenFromPdf;

  /// No description provided for @incomeSalaryVerified.
  ///
  /// In en, this message translates to:
  /// **'Income / Salary Verified'**
  String get incomeSalaryVerified;

  /// No description provided for @incomeSalaryVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Candidates with verified salary slip or ITR documentation'**
  String get incomeSalaryVerifiedSubtitle;

  /// No description provided for @incomeVisibleOnPdf.
  ///
  /// In en, this message translates to:
  /// **'Package & income details visible on PDF'**
  String get incomeVisibleOnPdf;

  /// No description provided for @increaseBiodataScore.
  ///
  /// In en, this message translates to:
  /// **'Increase Biodata Score!'**
  String get increaseBiodataScore;

  /// No description provided for @increaseYourTrustScoreToConfirmYourIdent.
  ///
  /// In en, this message translates to:
  /// **'Increase your Trust Score to confirm your identity and unlock exclusive discounts.'**
  String get increaseYourTrustScoreToConfirmYourIdent;

  /// No description provided for @india.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get india;

  /// No description provided for @instagramLink.
  ///
  /// In en, this message translates to:
  /// **'Instagram Reel/Story Link'**
  String get instagramLink;

  /// No description provided for @instagramStories.
  ///
  /// In en, this message translates to:
  /// **'Instagram Stories'**
  String get instagramStories;

  /// No description provided for @instantAlert.
  ///
  /// In en, this message translates to:
  /// **'Instant Alert'**
  String get instantAlert;

  /// No description provided for @instantMatchAlerts.
  ///
  /// In en, this message translates to:
  /// **'Instant Match Alerts'**
  String get instantMatchAlerts;

  /// No description provided for @instantMatchAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified immediately when mutual interest is accepted.'**
  String get instantMatchAlertsSubtitle;

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @interestConfirmationDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to share your profile with {name} to show your interest?'**
  String interestConfirmationDesc(String name);

  /// No description provided for @interestConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'This will share your profile with {name} and allow them to connect with you. Are you sure?'**
  String interestConfirmationMessage(String name);

  /// No description provided for @interestConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Express Interest?'**
  String get interestConfirmationTitle;

  /// No description provided for @interestDeclinedToast.
  ///
  /// In en, this message translates to:
  /// **'Interest declined'**
  String get interestDeclinedToast;

  /// No description provided for @interestSent.
  ///
  /// In en, this message translates to:
  /// **'INTEREST SENT'**
  String get interestSent;

  /// No description provided for @interestShared.
  ///
  /// In en, this message translates to:
  /// **'Interest shared with {name}!'**
  String interestShared(String name);

  /// No description provided for @introduceYourselfIn30SecondsTalkAboutYou.
  ///
  /// In en, this message translates to:
  /// **'Introduce yourself in 30 seconds. Talk about your family, profession, and expectations.'**
  String get introduceYourselfIn30SecondsTalkAboutYou;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidEmailOrPassword;

  /// No description provided for @inviteARelative.
  ///
  /// In en, this message translates to:
  /// **'Invite a Relative'**
  String get inviteARelative;

  /// No description provided for @inviteFriendsRewards.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and unlock premium rewards!'**
  String get inviteFriendsRewards;

  /// No description provided for @inviteRelativesToVouch.
  ///
  /// In en, this message translates to:
  /// **'Invite Relatives to Vouch'**
  String get inviteRelativesToVouch;

  /// No description provided for @inviteStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1'**
  String get inviteStep1;

  /// No description provided for @inviteStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2'**
  String get inviteStep2;

  /// No description provided for @inviteStep3.
  ///
  /// In en, this message translates to:
  /// **'Step 3'**
  String get inviteStep3;

  /// No description provided for @isDisabledPerson.
  ///
  /// In en, this message translates to:
  /// **'Are you a disabled person?'**
  String get isDisabledPerson;

  /// No description provided for @itSAMatch.
  ///
  /// In en, this message translates to:
  /// **'IT\'S A MATCH!'**
  String get itSAMatch;

  /// No description provided for @job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get job;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @joinBvsNow.
  ///
  /// In en, this message translates to:
  /// **'Join BVS (Register Here)'**
  String get joinBvsNow;

  /// No description provided for @joinMeOnBanjarabio.
  ///
  /// In en, this message translates to:
  /// **'Join me on BanjaraBio'**
  String get joinMeOnBanjarabio;

  /// No description provided for @joinOurCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our 10K+ community!'**
  String get joinOurCommunity;

  /// No description provided for @jointFamily.
  ///
  /// In en, this message translates to:
  /// **'Joint Family'**
  String get jointFamily;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get kannada;

  /// No description provided for @keepBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Keep Browsing'**
  String get keepBrowsing;

  /// No description provided for @keywordSearch.
  ///
  /// In en, this message translates to:
  /// **'Keyword Search'**
  String get keywordSearch;

  /// No description provided for @kundaliGunasPillar.
  ///
  /// In en, this message translates to:
  /// **'Kundali & Gunas (अष्टकूट जुळणी)'**
  String get kundaliGunasPillar;

  /// No description provided for @kundaliHoroscopeAttached.
  ///
  /// In en, this message translates to:
  /// **'Kundali / Horoscope Attached'**
  String get kundaliHoroscopeAttached;

  /// No description provided for @kundaliHoroscopeAttachedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only show profiles with uploaded Janam Kundali chart'**
  String get kundaliHoroscopeAttachedSubtitle;

  /// No description provided for @kundaliOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Kundali Available on Request'**
  String get kundaliOnRequest;

  /// No description provided for @kundaliPillarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No severe Manglik Dosha; high compatibility score'**
  String get kundaliPillarSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// No description provided for @languageSwitcherLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSwitcherLabel;

  /// No description provided for @lastUpdatedJanuary2026.
  ///
  /// In en, this message translates to:
  /// **'Last updated: January 2026'**
  String get lastUpdatedJanuary2026;

  /// No description provided for @legalAndInformation.
  ///
  /// In en, this message translates to:
  /// **'Legal & Information'**
  String get legalAndInformation;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// No description provided for @linkRequiredForRefund.
  ///
  /// In en, this message translates to:
  /// **'Link required for refund'**
  String get linkRequiredForRefund;

  /// No description provided for @linkShare.
  ///
  /// In en, this message translates to:
  /// **'Link Share'**
  String get linkShare;

  /// No description provided for @linkedInIntegration.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn Integration'**
  String get linkedInIntegration;

  /// No description provided for @linkedInIntegrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your professional profile to build more trust.'**
  String get linkedInIntegrationSubtitle;

  /// No description provided for @liveSelfie.
  ///
  /// In en, this message translates to:
  /// **'Live Selfie'**
  String get liveSelfie;

  /// No description provided for @liveSelfieVerification.
  ///
  /// In en, this message translates to:
  /// **'Live Selfie Verification'**
  String get liveSelfieVerification;

  /// No description provided for @liveSync.
  ///
  /// In en, this message translates to:
  /// **'LIVE SYNC'**
  String get liveSync;

  /// No description provided for @livenessCheck.
  ///
  /// In en, this message translates to:
  /// **'Liveness Check'**
  String get livenessCheck;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingAssets.
  ///
  /// In en, this message translates to:
  /// **'Loading assets...'**
  String get loadingAssets;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading your profile...'**
  String get loadingProfile;

  /// No description provided for @loadingViews.
  ///
  /// In en, this message translates to:
  /// **'Loading views...'**
  String get loadingViews;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationAndState.
  ///
  /// In en, this message translates to:
  /// **'Location & Native State'**
  String get locationAndState;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @locationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Location & Preferences'**
  String get locationPreferences;

  /// No description provided for @locationPreview.
  ///
  /// In en, this message translates to:
  /// **'Location Preview'**
  String get locationPreview;

  /// No description provided for @logCallOutcome.
  ///
  /// In en, this message translates to:
  /// **'Log Call Outcome'**
  String get logCallOutcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginAndCreateBiodataCta.
  ///
  /// In en, this message translates to:
  /// **'Login & Create Biodata ✨'**
  String get loginAndCreateBiodataCta;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @loginFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailedRetry;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @lookingForGender.
  ///
  /// In en, this message translates to:
  /// **'Looking For (Gender)'**
  String get lookingForGender;

  /// No description provided for @loseMatchesAndSavedProfiles.
  ///
  /// In en, this message translates to:
  /// **'You will lose all your matches and saved profiles.'**
  String get loseMatchesAndSavedProfiles;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @mamakulAndTandaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mamakul: {mamakul} • Tanda: {tanda}'**
  String mamakulAndTandaSubtitle(String mamakul, String tanda);

  /// No description provided for @mamakulLabel.
  ///
  /// In en, this message translates to:
  /// **'Mamakul (मोसळ)'**
  String get mamakulLabel;

  /// No description provided for @mamakulRule.
  ///
  /// In en, this message translates to:
  /// **'Maternal Gotras are verified to ensure complete cultural harmony and lineage respect.'**
  String get mamakulRule;

  /// No description provided for @mamakulTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Mamakul / Mosam (मोसळ):'**
  String get mamakulTitle;

  /// No description provided for @managePhotos.
  ///
  /// In en, this message translates to:
  /// **'Manage Photos'**
  String get managePhotos;

  /// No description provided for @managenphotos.
  ///
  /// In en, this message translates to:
  /// **'Manage\\nPhotos'**
  String get managenphotos;

  /// No description provided for @manglikDosha.
  ///
  /// In en, this message translates to:
  /// **'Manglik / Kuja Dosha'**
  String get manglikDosha;

  /// No description provided for @manualSelection.
  ///
  /// In en, this message translates to:
  /// **'MANUAL SELECTION'**
  String get manualSelection;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;

  /// No description provided for @maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatus;

  /// No description provided for @maritalStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatusLabel;

  /// No description provided for @marriageReadiness.
  ///
  /// In en, this message translates to:
  /// **'Marriage Readiness'**
  String get marriageReadiness;

  /// No description provided for @marriageRewardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share marriage proof & get up to 35% Refund!'**
  String get marriageRewardSubtitle;

  /// No description provided for @married.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get married;

  /// No description provided for @maskFamilySuggestionsTip.
  ///
  /// In en, this message translates to:
  /// **'Ask family members for photo suggestions'**
  String get maskFamilySuggestionsTip;

  /// No description provided for @mastersDegree.
  ///
  /// In en, this message translates to:
  /// **'Master\'s Degree'**
  String get mastersDegree;

  /// No description provided for @matchCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Match Compatibility'**
  String get matchCompatibility;

  /// No description provided for @matchNOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Match {current} of {total}'**
  String matchNOfTotal(String current, String total);

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get matched;

  /// No description provided for @matchedBadge.
  ///
  /// In en, this message translates to:
  /// **'MATCHED'**
  String get matchedBadge;

  /// No description provided for @matchesCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Matches Category'**
  String get matchesCategoryLabel;

  /// No description provided for @matchmakerConsultation.
  ///
  /// In en, this message translates to:
  /// **'Matchmaker consultation'**
  String get matchmakerConsultation;

  /// No description provided for @matchmakerFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Contact, RM Handpicked, 36 Guna Score & Land Holdings'**
  String get matchmakerFiltersSubtitle;

  /// No description provided for @matchmakerFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Matchmaker Filters'**
  String get matchmakerFiltersTitle;

  /// No description provided for @matchmakerPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Elite • Royal • Eternal Elite'**
  String get matchmakerPlansSubtitle;

  /// No description provided for @maternalGotraMamakul.
  ///
  /// In en, this message translates to:
  /// **'Maternal Gotra (Mamakul / मोसळ)'**
  String get maternalGotraMamakul;

  /// No description provided for @maternalGotraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exclude or specify maternal lineage to avoid customary gotra clash'**
  String get maternalGotraSubtitle;

  /// No description provided for @matrimonyFor.
  ///
  /// In en, this message translates to:
  /// **'MATRIMONY FOR'**
  String get matrimonyFor;

  /// No description provided for @maxAge.
  ///
  /// In en, this message translates to:
  /// **'Max Age'**
  String get maxAge;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @melavaBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover regional matrimonial get-togethers across India. Reach organizers directly to participate.'**
  String get melavaBannerSubtitle;

  /// No description provided for @melavaBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Banjara Parichay Melavas'**
  String get melavaBannerTitle;

  /// No description provided for @melavaEventCount.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String melavaEventCount(int count);

  /// No description provided for @melavas.
  ///
  /// In en, this message translates to:
  /// **'Melavas'**
  String get melavas;

  /// No description provided for @men.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get men;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messageUsOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Message us on WhatsApp'**
  String get messageUsOnWhatsapp;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'MESSAGES'**
  String get messages;

  /// Title when user hits messaging limit
  ///
  /// In en, this message translates to:
  /// **'Messaging Limit Reached'**
  String get messagingLimitReached;

  /// No description provided for @middleClass.
  ///
  /// In en, this message translates to:
  /// **'Middle Class'**
  String get middleClass;

  /// No description provided for @minAge.
  ///
  /// In en, this message translates to:
  /// **'Min Age'**
  String get minAge;

  /// No description provided for @minimumHeight.
  ///
  /// In en, this message translates to:
  /// **'Minimum Height'**
  String get minimumHeight;

  /// No description provided for @minimumHeightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select minimum height requirement for matches'**
  String get minimumHeightSubtitle;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @mobileVerification.
  ///
  /// In en, this message translates to:
  /// **'Mobile Verification'**
  String get mobileVerification;

  /// No description provided for @mobileVerifiedSuccessfully10Points.
  ///
  /// In en, this message translates to:
  /// **'Mobile Verified Successfully! +10 Points'**
  String get mobileVerifiedSuccessfully10Points;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get month;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @monthlyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Monthly Check-in'**
  String get monthlyCheckIn;

  /// No description provided for @monthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Monthly Revenue (₹)'**
  String get monthlyRevenue;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @moreAboutYourStudiesAndWork.
  ///
  /// In en, this message translates to:
  /// **'More about your studies and work'**
  String get moreAboutYourStudiesAndWork;

  /// No description provided for @moreInvitesToUnlockTier.
  ///
  /// In en, this message translates to:
  /// **'{count} more invites to unlock {tier} tier ({reward})'**
  String moreInvitesToUnlockTier(Object count, Object reward, Object tier);

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get motherName;

  /// No description provided for @motherOccupation.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Occupation'**
  String get motherOccupation;

  /// No description provided for @mrpPrice.
  ///
  /// In en, this message translates to:
  /// **'MRP ₹{price}'**
  String mrpPrice(int price);

  /// No description provided for @mustHavePhoto.
  ///
  /// In en, this message translates to:
  /// **'Must Have Photo'**
  String get mustHavePhoto;

  /// No description provided for @mutualMatch.
  ///
  /// In en, this message translates to:
  /// **'Mutual Match'**
  String get mutualMatch;

  /// No description provided for @mutualMatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'Mutual matches will appear here when both users share interest in each other'**
  String get mutualMatchesDesc;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @nakshatraStar.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra (Star)'**
  String get nakshatraStar;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nativeDistrict.
  ///
  /// In en, this message translates to:
  /// **'Native District'**
  String get nativeDistrict;

  /// No description provided for @nativePlace.
  ///
  /// In en, this message translates to:
  /// **'Native Place'**
  String get nativePlace;

  /// No description provided for @naturalPosesRespectful.
  ///
  /// In en, this message translates to:
  /// **'Natural poses with respectful expressions'**
  String get naturalPosesRespectful;

  /// No description provided for @needHelpContactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact Admin'**
  String get needHelpContactAdmin;

  /// No description provided for @needProfileToShareToast.
  ///
  /// In en, this message translates to:
  /// **'You need to create a profile before sharing it.'**
  String get needProfileToShareToast;

  /// No description provided for @neverMarried.
  ///
  /// In en, this message translates to:
  /// **'Never Married'**
  String get neverMarried;

  /// No description provided for @neverMissVerifiedMatch.
  ///
  /// In en, this message translates to:
  /// **'Never miss a verified match, instant message, or profile update.'**
  String get neverMissVerifiedMatch;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @newMatchAlerts.
  ///
  /// In en, this message translates to:
  /// **'New Match Alerts'**
  String get newMatchAlerts;

  /// No description provided for @newMatches.
  ///
  /// In en, this message translates to:
  /// **'New Matches'**
  String get newMatches;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLabel;

  /// No description provided for @nextRefreshTime.
  ///
  /// In en, this message translates to:
  /// **'Next refresh: {time}'**
  String nextRefreshTime(String time);

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noBookmarkedProfilesYet.
  ///
  /// In en, this message translates to:
  /// **'No bookmarked profiles yet'**
  String get noBookmarkedProfilesYet;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @noDailyMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'No Daily Matches Yet'**
  String get noDailyMatchesYet;

  /// No description provided for @noIncome.
  ///
  /// In en, this message translates to:
  /// **'No Income'**
  String get noIncome;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @noLocationsFoundForQuery.
  ///
  /// In en, this message translates to:
  /// **'No locations found for \"{query}\"'**
  String noLocationsFoundForQuery(String query);

  /// No description provided for @noMatchesYet.
  ///
  /// In en, this message translates to:
  /// **'No Matches Yet'**
  String get noMatchesYet;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @noPendingVerifications.
  ///
  /// In en, this message translates to:
  /// **'No pending verifications'**
  String get noPendingVerifications;

  /// No description provided for @noPhotosAdded.
  ///
  /// In en, this message translates to:
  /// **'No photos added'**
  String get noPhotosAdded;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No Photos Yet'**
  String get noPhotosYet;

  /// No description provided for @noProfileFound.
  ///
  /// In en, this message translates to:
  /// **'No profile found'**
  String get noProfileFound;

  /// No description provided for @noProfilesFound.
  ///
  /// In en, this message translates to:
  /// **'No profiles found'**
  String get noProfilesFound;

  /// No description provided for @noProfilesMatchYourFilters.
  ///
  /// In en, this message translates to:
  /// **'No profiles match your filters'**
  String get noProfilesMatchYourFilters;

  /// No description provided for @noProfilesReceived.
  ///
  /// In en, this message translates to:
  /// **'No Profiles Received'**
  String get noProfilesReceived;

  /// No description provided for @noProfilesSharedYet.
  ///
  /// In en, this message translates to:
  /// **'No Profiles Shared Yet'**
  String get noProfilesSharedYet;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or check back later for new profiles.'**
  String get noResultsMessage;

  /// No description provided for @noSiblingsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No siblings added yet'**
  String get noSiblingsAddedYet;

  /// No description provided for @noTalukasAvailable.
  ///
  /// In en, this message translates to:
  /// **'No talukas available'**
  String get noTalukasAvailable;

  /// No description provided for @noViewsYet.
  ///
  /// In en, this message translates to:
  /// **'No views yet'**
  String get noViewsYet;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @normalFit.
  ///
  /// In en, this message translates to:
  /// **'Normal / Fit'**
  String get normalFit;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @notEntered.
  ///
  /// In en, this message translates to:
  /// **'Not Entered'**
  String get notEntered;

  /// No description provided for @notMatchedCannotMessage.
  ///
  /// In en, this message translates to:
  /// **'You are not matched with this profile, so you can\'t direct message them.'**
  String get notMatchedCannotMessage;

  /// No description provided for @notMatchedCantMessage.
  ///
  /// In en, this message translates to:
  /// **'You are not matched with this profile, so you cant direct message them.'**
  String get notMatchedCantMessage;

  /// No description provided for @notReadyYet.
  ///
  /// In en, this message translates to:
  /// **'Not ready yet'**
  String get notReadyYet;

  /// No description provided for @notRepresentAppearance.
  ///
  /// In en, this message translates to:
  /// **'Photos that do not represent your current appearance'**
  String get notRepresentAppearance;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @notVerifiedYetPleaseClickTheLinkInYourEm.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet. Please click the link in your email.'**
  String get notVerifiedYetPleaseClickTheLinkInYourEm;

  /// No description provided for @notWorking.
  ///
  /// In en, this message translates to:
  /// **'Not Working'**
  String get notWorking;

  /// No description provided for @notYetVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'NOT YET VERIFIED'**
  String get notYetVerifiedBadge;

  /// No description provided for @nuclearFamily.
  ///
  /// In en, this message translates to:
  /// **'Nuclear Family'**
  String get nuclearFamily;

  /// No description provided for @num100.
  ///
  /// In en, this message translates to:
  /// **'/ 100'**
  String get num100;

  /// No description provided for @num123BanjaraTowersPrideSiliconValleynsh.
  ///
  /// In en, this message translates to:
  /// **'123, Banjara Towers, Pride Silicon Valley,\\nShivaji Nagar, Pune, Maharashtra 411005'**
  String get num123BanjaraTowersPrideSiliconValleynsh;

  /// No description provided for @num15PointsPending.
  ///
  /// In en, this message translates to:
  /// **'+15 Points Pending'**
  String get num15PointsPending;

  /// No description provided for @num499.
  ///
  /// In en, this message translates to:
  /// **'499'**
  String get num499;

  /// No description provided for @num919876543210.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43210'**
  String get num919876543210;

  /// No description provided for @occupationLabel.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupationLabel;

  /// No description provided for @officeAddress.
  ///
  /// In en, this message translates to:
  /// **'Office Address'**
  String get officeAddress;

  /// No description provided for @officialBiodataPdfShared.
  ///
  /// In en, this message translates to:
  /// **'Official Biodata PDF Shared 📄'**
  String get officialBiodataPdfShared;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get onHold;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Match'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Trusted Community'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get onboardingTitle3;

  /// No description provided for @oneFreeNote.
  ///
  /// In en, this message translates to:
  /// **'1 FREE 💌'**
  String get oneFreeNote;

  /// No description provided for @oneHundredPercentCompliant.
  ///
  /// In en, this message translates to:
  /// **'100% Compliant'**
  String get oneHundredPercentCompliant;

  /// No description provided for @oneHundredPercentPrivate.
  ///
  /// In en, this message translates to:
  /// **'100% Private'**
  String get oneHundredPercentPrivate;

  /// No description provided for @oneMessageUnlocked.
  ///
  /// In en, this message translates to:
  /// **'1 Message Unlocked!'**
  String get oneMessageUnlocked;

  /// No description provided for @oneMonthFree.
  ///
  /// In en, this message translates to:
  /// **'1 Month Free'**
  String get oneMonthFree;

  /// No description provided for @onePhotoLockedTeaser.
  ///
  /// In en, this message translates to:
  /// **'📸 1 Photo (🔒 +{count})'**
  String onePhotoLockedTeaser(int count);

  /// No description provided for @oneTapSelect.
  ///
  /// In en, this message translates to:
  /// **'1-Tap Select'**
  String get oneTapSelect;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One Time'**
  String get oneTime;

  /// No description provided for @oneYearVip.
  ///
  /// In en, this message translates to:
  /// **'1 Year VIP'**
  String get oneYearVip;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @onlyDobShownOnPdf.
  ///
  /// In en, this message translates to:
  /// **'Only Date of Birth shown on PDF'**
  String get onlyDobShownOnPdf;

  /// No description provided for @onlyShowProfilesWithPhoto.
  ///
  /// In en, this message translates to:
  /// **'Only show profiles with verified photo albums'**
  String get onlyShowProfilesWithPhoto;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCamera;

  /// No description provided for @openProfileToShare.
  ///
  /// In en, this message translates to:
  /// **'Open profile to share'**
  String get openProfileToShare;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @openToRelocate.
  ///
  /// In en, this message translates to:
  /// **'Open to Relocate'**
  String get openToRelocate;

  /// No description provided for @openingConversation.
  ///
  /// In en, this message translates to:
  /// **'Opening conversation...'**
  String get openingConversation;

  /// No description provided for @openingConversationToast.
  ///
  /// In en, this message translates to:
  /// **'Opening conversation...'**
  String get openingConversationToast;

  /// No description provided for @option1Badge.
  ///
  /// In en, this message translates to:
  /// **'OPTION 1 • NO LOGIN NEEDED'**
  String get option1Badge;

  /// No description provided for @option2Badge.
  ///
  /// In en, this message translates to:
  /// **'OPTION 2 • MOST POPULAR • 100% FREE'**
  String get option2Badge;

  /// No description provided for @option3Badge.
  ///
  /// In en, this message translates to:
  /// **'OPTION 3 • GUEST MODE'**
  String get option3Badge;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @orCustomizeYourNote.
  ///
  /// In en, this message translates to:
  /// **'OR CUSTOMIZE YOUR NOTE'**
  String get orCustomizeYourNote;

  /// No description provided for @organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// No description provided for @originalVillageHint.
  ///
  /// In en, this message translates to:
  /// **'Original village'**
  String get originalVillageHint;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @ownHouseVilla.
  ///
  /// In en, this message translates to:
  /// **'Own House / Villa'**
  String get ownHouseVilla;

  /// No description provided for @ownResidentialHouseVilla.
  ///
  /// In en, this message translates to:
  /// **'Own Residential House / Villa'**
  String get ownResidentialHouseVilla;

  /// No description provided for @ownResidentialHouseVillaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Family owns self-acquired or independent residential house'**
  String get ownResidentialHouseVillaSubtitle;

  /// No description provided for @partnerExpectations.
  ///
  /// In en, this message translates to:
  /// **'Partner Expectations'**
  String get partnerExpectations;

  /// No description provided for @partnerExpectationsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you are looking for...'**
  String get partnerExpectationsHint;

  /// No description provided for @partnerName.
  ///
  /// In en, this message translates to:
  /// **'Partner\'s Name'**
  String get partnerName;

  /// No description provided for @partnerPreferences.
  ///
  /// In en, this message translates to:
  /// **'Partner Preferences'**
  String get partnerPreferences;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pasteUrlHere.
  ///
  /// In en, this message translates to:
  /// **'Paste the URL here'**
  String get pasteUrlHere;

  /// No description provided for @pay199ToUnlockFullPdf.
  ///
  /// In en, this message translates to:
  /// **'Pay ₹199 to Unlock Full PDF'**
  String get pay199ToUnlockFullPdf;

  /// No description provided for @payInstantUnlock.
  ///
  /// In en, this message translates to:
  /// **'Pay ₹{price} Instant Unlock'**
  String payInstantUnlock(Object price);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailed(String error);

  /// No description provided for @paymentFailedError.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailedError(String error);

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful! Templates unlocked.'**
  String get paymentSuccessful;

  /// No description provided for @paymentSuccessfulPdfUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful! PDF Unlocked.'**
  String get paymentSuccessfulPdfUnlocked;

  /// No description provided for @paymentSuccessfulWelcome.
  ///
  /// In en, this message translates to:
  /// **'Payment successful! Welcome to {plan}'**
  String paymentSuccessfulWelcome(String plan);

  /// No description provided for @pdfDisplayStudio.
  ///
  /// In en, this message translates to:
  /// **'PDF Display Studio'**
  String get pdfDisplayStudio;

  /// No description provided for @pdfDisplayStudioDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize header deity blessings and toggle confidential fields on your shareable PDF.'**
  String get pdfDisplayStudioDesc;

  /// No description provided for @pdfRevenue.
  ///
  /// In en, this message translates to:
  /// **'PDF Revenue (₹)'**
  String get pdfRevenue;

  /// No description provided for @pdfSavedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'PDF Saved to Downloads: {path}'**
  String pdfSavedToDownloads(String path);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pendingReferences.
  ///
  /// In en, this message translates to:
  /// **'Pending References'**
  String get pendingReferences;

  /// No description provided for @pendingReports.
  ///
  /// In en, this message translates to:
  /// **'Pending Reports'**
  String get pendingReports;

  /// No description provided for @pendingVerifications.
  ///
  /// In en, this message translates to:
  /// **'Pending Verifications'**
  String get pendingVerifications;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% Complete'**
  String percentComplete(int percentage);

  /// No description provided for @percentCompleteBadge.
  ///
  /// In en, this message translates to:
  /// **'{score}% Complete'**
  String percentCompleteBadge(int score);

  /// No description provided for @percentMatchBadge.
  ///
  /// In en, this message translates to:
  /// **'{score}% Match'**
  String percentMatchBadge(int score);

  /// No description provided for @percentTrustBadge.
  ///
  /// In en, this message translates to:
  /// **'{score}% Trust'**
  String percentTrustBadge(int score);

  /// No description provided for @permissionDeniedSettings.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please enable in settings.'**
  String get permissionDeniedSettings;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'{type} permission is required to upload photos. Please enable it in app settings.'**
  String permissionRequiredMessage(String type);

  /// No description provided for @personalConcierge.
  ///
  /// In en, this message translates to:
  /// **'Personal Concierge'**
  String get personalConcierge;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @phoneSupport.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get photoAdded;

  /// No description provided for @photoAddedWithKb.
  ///
  /// In en, this message translates to:
  /// **'Photo added ({kb} KB)'**
  String photoAddedWithKb(int kb);

  /// No description provided for @photoGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Photo Guidelines'**
  String get photoGuidelines;

  /// No description provided for @photoLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Photo Limit Reached'**
  String get photoLimitReached;

  /// No description provided for @photoManagement.
  ///
  /// In en, this message translates to:
  /// **'Photo Management'**
  String get photoManagement;

  /// No description provided for @photoUpload.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photoUpload;

  /// No description provided for @photoUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded successfully'**
  String get photoUploadedSuccessfully;

  /// No description provided for @photoVisibility.
  ///
  /// In en, this message translates to:
  /// **'Photo Visibility'**
  String get photoVisibility;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos:'**
  String get photos;

  /// No description provided for @photosAreAutomaticallyCompressedToEnsure.
  ///
  /// In en, this message translates to:
  /// **'Photos are automatically compressed to ensure fast upload'**
  String get photosAreAutomaticallyCompressedToEnsure;

  /// No description provided for @photosCompressedInfo.
  ///
  /// In en, this message translates to:
  /// **'Photos are compressed to save data.'**
  String get photosCompressedInfo;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String photosCount(int count);

  /// No description provided for @photosDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Photos deleted successfully'**
  String get photosDeletedSuccessfully;

  /// No description provided for @photosReflectPersonality.
  ///
  /// In en, this message translates to:
  /// **'Photos that reflect your personality and values'**
  String get photosReflectPersonality;

  /// No description provided for @photosSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String photosSelectedCount(int count);

  /// No description provided for @photosToAvoid.
  ///
  /// In en, this message translates to:
  /// **'Photos to Avoid'**
  String get photosToAvoid;

  /// No description provided for @physicalHealthStatus.
  ///
  /// In en, this message translates to:
  /// **'Physical Health Status'**
  String get physicalHealthStatus;

  /// No description provided for @physicalHealthStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select physical disability match preferences'**
  String get physicalHealthStatusSubtitle;

  /// No description provided for @physicalSocialAttributes.
  ///
  /// In en, this message translates to:
  /// **'Physical & Social Attributes'**
  String get physicalSocialAttributes;

  /// No description provided for @physicalStatus.
  ///
  /// In en, this message translates to:
  /// **'Physical Status'**
  String get physicalStatus;

  /// No description provided for @physicallyChallenged.
  ///
  /// In en, this message translates to:
  /// **'Physically Challenged'**
  String get physicallyChallenged;

  /// No description provided for @pickNote.
  ///
  /// In en, this message translates to:
  /// **'Pick Note'**
  String get pickNote;

  /// No description provided for @pinCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pin Code'**
  String get pinCodeLabel;

  /// No description provided for @planetaryLagnaAlignment.
  ///
  /// In en, this message translates to:
  /// **'Planetary Lagna & Ashtakoot Alignment'**
  String get planetaryLagnaAlignment;

  /// No description provided for @platinumPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Ultimate experience with all features'**
  String get platinumPlanDesc;

  /// No description provided for @platinumPlanName.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get platinumPlanName;

  /// No description provided for @pleaseAcceptVendorPartnerTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the vendor partner terms'**
  String get pleaseAcceptVendorPartnerTerms;

  /// No description provided for @pleaseComplete.
  ///
  /// In en, this message translates to:
  /// **'Please complete: {fields}'**
  String pleaseComplete(String fields);

  /// No description provided for @pleaseCompleteRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields in {section}'**
  String pleaseCompleteRequiredFields(String section);

  /// No description provided for @pleaseEnter6DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter 6-digit OTP'**
  String get pleaseEnter6DigitOtp;

  /// No description provided for @pleaseEnterAValid10DigitMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get pleaseEnterAValid10DigitMobileNumber;

  /// No description provided for @pleaseEnterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress;

  /// No description provided for @pleaseEnterBothEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password'**
  String get pleaseEnterBothEmailPassword;

  /// No description provided for @pleaseEnterFull6DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter full 6-digit OTP'**
  String get pleaseEnterFull6DigitOtp;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @pleaseFillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllRequiredFields;

  /// No description provided for @pleaseSelectAnnualIncome.
  ///
  /// In en, this message translates to:
  /// **'Please select your annual income'**
  String get pleaseSelectAnnualIncome;

  /// No description provided for @pleaseSelectEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Please select your education level'**
  String get pleaseSelectEducationLevel;

  /// No description provided for @pleaseSelectOrWriteShortNote.
  ///
  /// In en, this message translates to:
  /// **'Please select or write a short intro note'**
  String get pleaseSelectOrWriteShortNote;

  /// No description provided for @pleaseSelectProfession.
  ///
  /// In en, this message translates to:
  /// **'Please select your profession'**
  String get pleaseSelectProfession;

  /// No description provided for @pleaseSelectYourGotra.
  ///
  /// In en, this message translates to:
  /// **'Please select your gotra'**
  String get pleaseSelectYourGotra;

  /// No description provided for @pleaseSelectYourSurname.
  ///
  /// In en, this message translates to:
  /// **'Please select your surname'**
  String get pleaseSelectYourSurname;

  /// No description provided for @pleaseSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to save your biodata'**
  String get pleaseSignInAgain;

  /// No description provided for @pleaseSpecifyEducation.
  ///
  /// In en, this message translates to:
  /// **'Please specify your education'**
  String get pleaseSpecifyEducation;

  /// No description provided for @pleaseSpecifyProfession.
  ///
  /// In en, this message translates to:
  /// **'Please specify your profession'**
  String get pleaseSpecifyProfession;

  /// No description provided for @pleaseTakeASelfieToVerifyThatYouAreAReal.
  ///
  /// In en, this message translates to:
  /// **'Please take a selfie to verify that you are a real person. Ensure you are in a well-lit area.'**
  String get pleaseTakeASelfieToVerifyThatYouAreAReal;

  /// No description provided for @pointsCount.
  ///
  /// In en, this message translates to:
  /// **'+{points} Points'**
  String pointsCount(int points);

  /// No description provided for @postGraduate.
  ///
  /// In en, this message translates to:
  /// **'Post Graduate'**
  String get postGraduate;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumAccess.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM ACCESS'**
  String get premiumAccess;

  /// No description provided for @premiumBadge.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premiumBadge;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'This is a premium feature'**
  String get premiumFeature;

  /// No description provided for @premiumFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ID Verification, Trust Score, Horoscope, Lifestyle & Activity'**
  String get premiumFiltersSubtitle;

  /// No description provided for @premiumFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Filters'**
  String get premiumFiltersTitle;

  /// No description provided for @premiumGateSupport.
  ///
  /// In en, this message translates to:
  /// **'Support our community by watching a quick ad,\nor upgrade to Pro for an ad-free experience.'**
  String get premiumGateSupport;

  /// No description provided for @premiumMembership.
  ///
  /// In en, this message translates to:
  /// **'Premium Membership'**
  String get premiumMembership;

  /// No description provided for @premiumMen.
  ///
  /// In en, this message translates to:
  /// **'Premium Men'**
  String get premiumMen;

  /// No description provided for @premiumPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Advanced features and better visibility'**
  String get premiumPlanDesc;

  /// No description provided for @premiumPlanName.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlanName;

  /// No description provided for @premiumPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard • Silver • Gold • Platinum • Eternal'**
  String get premiumPlansSubtitle;

  /// No description provided for @premiumPriceFiltersInactive.
  ///
  /// In en, this message translates to:
  /// **'Premium price filters are currently inactive.'**
  String get premiumPriceFiltersInactive;

  /// No description provided for @premiumTemplate.
  ///
  /// In en, this message translates to:
  /// **'Premium Template'**
  String get premiumTemplate;

  /// No description provided for @premiumUsers.
  ///
  /// In en, this message translates to:
  /// **'Premium Users'**
  String get premiumUsers;

  /// No description provided for @premiumWomen.
  ///
  /// In en, this message translates to:
  /// **'Premium Women'**
  String get premiumWomen;

  /// No description provided for @preparingAdExperience.
  ///
  /// In en, this message translates to:
  /// **'PREPARING AD EXPERIENCE...'**
  String get preparingAdExperience;

  /// No description provided for @preparingBiodata.
  ///
  /// In en, this message translates to:
  /// **'Preparing your biodata...'**
  String get preparingBiodata;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previewCustomizedBiodata.
  ///
  /// In en, this message translates to:
  /// **'Preview Customized Biodata'**
  String get previewCustomizedBiodata;

  /// No description provided for @previewGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview generation failed. Please try again.'**
  String get previewGenerationFailed;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'₹{price}/month'**
  String pricePerMonth(int price);

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @primaryContactHiddenOnPdf.
  ///
  /// In en, this message translates to:
  /// **'Hidden for privacy'**
  String get primaryContactHiddenOnPdf;

  /// No description provided for @primaryContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Primary Contact Number'**
  String get primaryContactNumber;

  /// No description provided for @primaryContactVisibleOnPdf.
  ///
  /// In en, this message translates to:
  /// **'Registered calling number visible on PDF'**
  String get primaryContactVisibleOnPdf;

  /// No description provided for @primaryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Primary Photo'**
  String get primaryPhoto;

  /// No description provided for @primaryPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Primary photo updated'**
  String get primaryPhotoUpdated;

  /// No description provided for @printBtn.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printBtn;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get prioritySupport;

  /// No description provided for @privacyAndContentSwitches.
  ///
  /// In en, this message translates to:
  /// **'🔒 Privacy & Content Switches'**
  String get privacyAndContentSwitches;

  /// No description provided for @privacyAndContentSwitchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle visibility of sensitive fields on your shared PDF'**
  String get privacyAndContentSwitchesSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyS1Content.
  ///
  /// In en, this message translates to:
  /// **'• Personal Data: Name, age, gender, caste, education, profession, family details.\\n• Contact Data: Phone number, email address.\\n• Media: Photos uploaded to your profile.\\n• Device Data: Device ID, IP address (for security & analytics).\\n• Location Data: Approximate location (City/District) to suggest nearby matches.'**
  String get privacyS1Content;

  /// No description provided for @privacyS1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyS1Title;

  /// No description provided for @privacyS2Content.
  ///
  /// In en, this message translates to:
  /// **'• App Functionality: To create your profile and match-making.\\n• Account Management: Identity verification and fraud prevention.\\n• Analytics: To improve app performance (using Firebase).\\n• Location: To show \"Near Me\" matches (Optional).'**
  String get privacyS2Content;

  /// No description provided for @privacyS2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Purpose of Collection (Data Safety)'**
  String get privacyS2Title;

  /// No description provided for @privacyS3Content.
  ///
  /// In en, this message translates to:
  /// **'• Camera & Gallery: For profile photos.\\n• Location: To auto-fill city/district.\\n• Notifications: For match alerts.'**
  String get privacyS3Content;

  /// No description provided for @privacyS3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Device Permissions'**
  String get privacyS3Title;

  /// No description provided for @privacyS4Content.
  ///
  /// In en, this message translates to:
  /// **'• Other Users: Registered members can see your profile details (excluding contact info unless shared).\\n• Service Providers: We use Supabase (Database) and Firebase (Analytics/Notifications) to run the app. They process data under strict security standards.'**
  String get privacyS4Content;

  /// No description provided for @privacyS4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Disclosure & Third Parties'**
  String get privacyS4Title;

  /// No description provided for @privacyS5Content.
  ///
  /// In en, this message translates to:
  /// **'We use encryption to protect your data. You can delete your account and all associated data at any time via Settings > Delete Account.'**
  String get privacyS5Content;

  /// No description provided for @privacyS5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Data Security & Deletion'**
  String get privacyS5Title;

  /// No description provided for @privacyS6Content.
  ///
  /// In en, this message translates to:
  /// **'This policy is governed by the laws of India. Any disputes are subject to the jurisdiction of the courts in Maharashtra.'**
  String get privacyS6Content;

  /// No description provided for @privacyS6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Governing Law'**
  String get privacyS6Title;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @privacySettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings updated'**
  String get privacySettingsUpdated;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privateJob.
  ///
  /// In en, this message translates to:
  /// **'Private Job'**
  String get privateJob;

  /// No description provided for @privateSectorEmployee.
  ///
  /// In en, this message translates to:
  /// **'Private Sector Employee'**
  String get privateSectorEmployee;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @proTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips'**
  String get proTips;

  /// No description provided for @proceedToLogin.
  ///
  /// In en, this message translates to:
  /// **'Proceed → Login'**
  String get proceedToLogin;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing Image'**
  String get processingImage;

  /// No description provided for @processingStatusCompressing.
  ///
  /// In en, this message translates to:
  /// **'Compressing...'**
  String get processingStatusCompressing;

  /// No description provided for @processingStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get processingStatusPreparing;

  /// No description provided for @processingStatusSelecting.
  ///
  /// In en, this message translates to:
  /// **'Selecting...'**
  String get processingStatusSelecting;

  /// No description provided for @profession.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get profession;

  /// No description provided for @professionLabel.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get professionLabel;

  /// No description provided for @professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// No description provided for @professionalDegree.
  ///
  /// In en, this message translates to:
  /// **'Professional Degree'**
  String get professionalDegree;

  /// No description provided for @professionalDoctorEngineerLawyer.
  ///
  /// In en, this message translates to:
  /// **'Professional (Doctor/Engineer/Lawyer)'**
  String get professionalDoctorEngineerLawyer;

  /// No description provided for @professionalFamilyEventPhotos.
  ///
  /// In en, this message translates to:
  /// **'Professional or family event photos'**
  String get professionalFamilyEventPhotos;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileBoostPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} profile boost/month'**
  String profileBoostPerMonth(int count);

  /// No description provided for @profileCompleted.
  ///
  /// In en, this message translates to:
  /// **'Profile Completed'**
  String get profileCompleted;

  /// No description provided for @profileCreatedByTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Created By'**
  String get profileCreatedByTitle;

  /// No description provided for @profileDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile data not found'**
  String get profileDataNotFound;

  /// No description provided for @profileInsights.
  ///
  /// In en, this message translates to:
  /// **'Profile Insights'**
  String get profileInsights;

  /// No description provided for @profileLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Profile link copied to clipboard!'**
  String get profileLinkCopied;

  /// No description provided for @profileMakeover.
  ///
  /// In en, this message translates to:
  /// **'Professional Profile Makeover'**
  String get profileMakeover;

  /// No description provided for @profileManagedBy.
  ///
  /// In en, this message translates to:
  /// **'Profile Managed By'**
  String get profileManagedBy;

  /// No description provided for @profileManagedBySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select who created and manages the candidate biodata'**
  String get profileManagedBySubtitle;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @profilePhotos.
  ///
  /// In en, this message translates to:
  /// **'Profile Photos'**
  String get profilePhotos;

  /// No description provided for @profileRemovedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile removed from saved'**
  String get profileRemovedFromSaved;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved!'**
  String get profileSaved;

  /// No description provided for @profileSharedVia.
  ///
  /// In en, this message translates to:
  /// **'Shared {profileName} via {title}'**
  String profileSharedVia(String profileName, String title);

  /// No description provided for @profileSharedWith.
  ///
  /// In en, this message translates to:
  /// **'Profile shared with {name}'**
  String profileSharedWith(String name);

  /// No description provided for @profileStrengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Strength: {strength}'**
  String profileStrengthLabel(String strength);

  /// No description provided for @profileViewLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Profile View Limit Reached'**
  String get profileViewLimitReached;

  /// No description provided for @profileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile Views'**
  String get profileViews;

  /// No description provided for @profileViewsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} profile views/day'**
  String profileViewsPerDay(int count);

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @profilesSharedWithYouDesc.
  ///
  /// In en, this message translates to:
  /// **'Profiles shared with you by family and friends will appear here'**
  String get profilesSharedWithYouDesc;

  /// No description provided for @profilesYouSaveWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Profiles you save will appear here'**
  String get profilesYouSaveWillAppearHere;

  /// No description provided for @proofOfMarriage.
  ///
  /// In en, this message translates to:
  /// **'Proof of Marriage'**
  String get proofOfMarriage;

  /// No description provided for @provideDetailsAboutYourGotraAndVillageTo.
  ///
  /// In en, this message translates to:
  /// **'Provide details about your Gotra and Village to get the Community Verified badge.'**
  String get provideDetailsAboutYourGotraAndVillageTo;

  /// No description provided for @provideInformationAboutYourFamilyBackgro.
  ///
  /// In en, this message translates to:
  /// **'Provide information about your family background'**
  String get provideInformationAboutYourFamilyBackgro;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @quick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quick;

  /// No description provided for @quickOneTapSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick 1-Tap Suggestions:'**
  String get quickOneTapSuggestions;

  /// No description provided for @rashiMoonSign.
  ///
  /// In en, this message translates to:
  /// **'Rashi (Moon Sign)'**
  String get rashiMoonSign;

  /// No description provided for @readAll.
  ///
  /// In en, this message translates to:
  /// **'Read All'**
  String get readAll;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @readyForMarriage.
  ///
  /// In en, this message translates to:
  /// **'Ready for marriage'**
  String get readyForMarriage;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @recentConversations.
  ///
  /// In en, this message translates to:
  /// **'Recent Conversations'**
  String get recentConversations;

  /// No description provided for @recentPhotosSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Recent photos taken within the last 6 months'**
  String get recentPhotosSixMonths;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @recentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY USED'**
  String get recentlyUsed;

  /// No description provided for @recommendToOthers.
  ///
  /// In en, this message translates to:
  /// **'RECOMMEND TO OTHERS'**
  String get recommendToOthers;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @recommendedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Recommended Photos'**
  String get recommendedPhotos;

  /// No description provided for @recordAShortIntro.
  ///
  /// In en, this message translates to:
  /// **'Record a Short Intro'**
  String get recordAShortIntro;

  /// No description provided for @refer3FriendsGet1MonthFree.
  ///
  /// In en, this message translates to:
  /// **'Refer 3 Friends, Get 1 Month Free!'**
  String get refer3FriendsGet1MonthFree;

  /// No description provided for @referAndEarn.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referAndEarn;

  /// No description provided for @referenceRejected.
  ///
  /// In en, this message translates to:
  /// **'Reference Rejected'**
  String get referenceRejected;

  /// No description provided for @referenceVerification.
  ///
  /// In en, this message translates to:
  /// **'Reference Verification'**
  String get referenceVerification;

  /// No description provided for @referenceVerified.
  ///
  /// In en, this message translates to:
  /// **'Reference Verified'**
  String get referenceVerified;

  /// No description provided for @referenceWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference {number}'**
  String referenceWithNumber(int number);

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// No description provided for @referralInvite.
  ///
  /// In en, this message translates to:
  /// **'Referral Invite'**
  String get referralInvite;

  /// No description provided for @referralInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Join BanjaraBio, the most trusted matrimonial app for our community! Use my link to get started: {link}'**
  String referralInviteMessage(String link);

  /// No description provided for @referralInviteSubject.
  ///
  /// In en, this message translates to:
  /// **'Invitation to Join BanjaraBio'**
  String get referralInviteSubject;

  /// No description provided for @referralLinkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Referral link copied to clipboard!'**
  String get referralLinkCopiedToClipboard;

  /// No description provided for @referralRewardsTiers.
  ///
  /// In en, this message translates to:
  /// **'Referral Rewards Tiers 👑'**
  String get referralRewardsTiers;

  /// No description provided for @referralShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join BanjaraBio, the most trusted matrimonial app for our community! Use my link to get started: {link}'**
  String referralShareMessage(String link);

  /// No description provided for @referralShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Invitation to Join BanjaraBio'**
  String get referralShareSubject;

  /// No description provided for @referrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get referrals;

  /// No description provided for @referralsLabel.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get referralsLabel;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refund25.
  ///
  /// In en, this message translates to:
  /// **'25% Refund'**
  String get refund25;

  /// No description provided for @refund35.
  ///
  /// In en, this message translates to:
  /// **'35% Refund'**
  String get refund35;

  /// No description provided for @registrationFee.
  ///
  /// In en, this message translates to:
  /// **'Registration Fee'**
  String get registrationFee;

  /// No description provided for @registrationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Registration Submitted!'**
  String get registrationSubmitted;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @relationLabel.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relationLabel;

  /// No description provided for @relationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select Relationship'**
  String get relationSubtitle;

  /// No description provided for @relative.
  ///
  /// In en, this message translates to:
  /// **'Relative'**
  String get relative;

  /// No description provided for @relocationPreference.
  ///
  /// In en, this message translates to:
  /// **'Relocation Preference'**
  String get relocationPreference;

  /// No description provided for @remainingToday.
  ///
  /// In en, this message translates to:
  /// **'Remaining Today'**
  String get remainingToday;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePhoto;

  /// No description provided for @replacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace Photo'**
  String get replacePhoto;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reportSubmittedReview.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Our team will review it within 24 hours.'**
  String get reportSubmittedReview;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get requestDate;

  /// No description provided for @requestProcessedSuccessfullyMsg.
  ///
  /// In en, this message translates to:
  /// **'Request {status} successfully'**
  String requestProcessedSuccessfullyMsg(String status);

  /// No description provided for @requestsSent.
  ///
  /// In en, this message translates to:
  /// **'Requests Sent!'**
  String get requestsSent;

  /// No description provided for @requestsSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Requests sent successfully!'**
  String get requestsSentSuccessfully;

  /// No description provided for @rerecord.
  ///
  /// In en, this message translates to:
  /// **'Re-record'**
  String get rerecord;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset All Filters'**
  String get resetAllFilters;

  /// No description provided for @reshare.
  ///
  /// In en, this message translates to:
  /// **'RESHARE'**
  String get reshare;

  /// No description provided for @resumeDraftCta.
  ///
  /// In en, this message translates to:
  /// **'Resume Draft Now 👉'**
  String get resumeDraftCta;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @revenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue Today (₹)'**
  String get revenueToday;

  /// No description provided for @revenueTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue (₹)'**
  String get revenueTotal;

  /// No description provided for @reviewDetails.
  ///
  /// In en, this message translates to:
  /// **'Review Details'**
  String get reviewDetails;

  /// No description provided for @reviewVideoManuallyInStorageForNow.
  ///
  /// In en, this message translates to:
  /// **'Review video manually in Storage for now'**
  String get reviewVideoManuallyInStorageForNow;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @rewardsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsLabel;

  /// No description provided for @rich.
  ///
  /// In en, this message translates to:
  /// **'Rich'**
  String get rich;

  /// No description provided for @rmHandpickedMatches.
  ///
  /// In en, this message translates to:
  /// **'RM Handpicked Matches'**
  String get rmHandpickedMatches;

  /// No description provided for @rmHandpickedMatchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profiles curated and vetted by your Personal Relationship Manager'**
  String get rmHandpickedMatchesSubtitle;

  /// No description provided for @royalBanjaraTemplatesWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Royal Banjara Templates'**
  String royalBanjaraTemplatesWithCount(Object count);

  /// No description provided for @royalPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Dedicated manager finds your match'**
  String get royalPlanDesc;

  /// No description provided for @royalPlanName.
  ///
  /// In en, this message translates to:
  /// **'Royal'**
  String get royalPlanName;

  /// No description provided for @rupeeSymbol.
  ///
  /// In en, this message translates to:
  /// **'₹'**
  String get rupeeSymbol;

  /// No description provided for @safetyAndHealth.
  ///
  /// In en, this message translates to:
  /// **'Safety & Health'**
  String get safetyAndHealth;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveBiodata.
  ///
  /// In en, this message translates to:
  /// **'Save Biodata'**
  String get saveBiodata;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Saved Profiles'**
  String get savedProfiles;

  /// No description provided for @sayHelloLabel.
  ///
  /// In en, this message translates to:
  /// **'Say hello!'**
  String get sayHelloLabel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchByNameJobEducation.
  ///
  /// In en, this message translates to:
  /// **'Search by name, job, education...'**
  String get searchByNameJobEducation;

  /// No description provided for @searchLeads.
  ///
  /// In en, this message translates to:
  /// **'Search leads...'**
  String get searchLeads;

  /// No description provided for @searchMatchesForRelativesCta.
  ///
  /// In en, this message translates to:
  /// **'Find Matches for Relatives 👉'**
  String get searchMatchesForRelativesCta;

  /// No description provided for @searchMatchesForRelativesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search thousands of verified profiles for son, daughter, brother or sister directly without creating a profile.'**
  String get searchMatchesForRelativesSubtitle;

  /// No description provided for @searchMatchesForRelativesTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Matches for Relatives'**
  String get searchMatchesForRelativesTitle;

  /// No description provided for @searchProfiles.
  ///
  /// In en, this message translates to:
  /// **'Search profiles...'**
  String get searchProfiles;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'SEARCH RESULTS'**
  String get searchResults;

  /// No description provided for @searchSharedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Search shared profiles...'**
  String get searchSharedProfiles;

  /// No description provided for @searchStateDistrictOrTaluka.
  ///
  /// In en, this message translates to:
  /// **'Search State, District or Taluka'**
  String get searchStateDistrictOrTaluka;

  /// No description provided for @searchUserName.
  ///
  /// In en, this message translates to:
  /// **'Search user name...'**
  String get searchUserName;

  /// No description provided for @secure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get secure;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @seenAllProfiles.
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen all profiles!'**
  String get seenAllProfiles;

  /// No description provided for @selectAnnualIncome.
  ///
  /// In en, this message translates to:
  /// **'Select yearly income range'**
  String get selectAnnualIncome;

  /// No description provided for @selectAnnualIncomeRange.
  ///
  /// In en, this message translates to:
  /// **'Select annual income range'**
  String get selectAnnualIncomeRange;

  /// No description provided for @selectAppLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get selectAppLanguageTitle;

  /// No description provided for @selectBiodataLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Biodata Language'**
  String get selectBiodataLanguage;

  /// No description provided for @selectBudgetRange.
  ///
  /// In en, this message translates to:
  /// **'Select Budget Range'**
  String get selectBudgetRange;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectDistrictFirst.
  ///
  /// In en, this message translates to:
  /// **'Select District first'**
  String get selectDistrictFirst;

  /// No description provided for @selectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Select Document Type'**
  String get selectDocumentType;

  /// No description provided for @selectEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Select your education level'**
  String get selectEducationLevel;

  /// No description provided for @selectFromYourPhotos.
  ///
  /// In en, this message translates to:
  /// **'Select from your photos'**
  String get selectFromYourPhotos;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @selectMaritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Select marital status requirement'**
  String get selectMaritalStatus;

  /// No description provided for @selectMatchPreference.
  ///
  /// In en, this message translates to:
  /// **'Select match preference for groom or bride search'**
  String get selectMatchPreference;

  /// No description provided for @selectPaternalGotra.
  ///
  /// In en, this message translates to:
  /// **'Select candidate paternal Gotra customary clan'**
  String get selectPaternalGotra;

  /// No description provided for @selectRewardType.
  ///
  /// In en, this message translates to:
  /// **'Select Reward Type'**
  String get selectRewardType;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @selectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select State first'**
  String get selectStateFirst;

  /// No description provided for @selectTalukaOptional.
  ///
  /// In en, this message translates to:
  /// **'Select Taluka (Optional)'**
  String get selectTalukaOptional;

  /// No description provided for @selectYourEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Select your education level'**
  String get selectYourEducationLevel;

  /// No description provided for @selectYourGotra.
  ///
  /// In en, this message translates to:
  /// **'Select your gotra'**
  String get selectYourGotra;

  /// No description provided for @selectYourLocationAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'Select your location and preferences'**
  String get selectYourLocationAndPreferences;

  /// No description provided for @selectYourProfession.
  ///
  /// In en, this message translates to:
  /// **'Select your profession'**
  String get selectYourProfession;

  /// No description provided for @selectYourSurname.
  ///
  /// In en, this message translates to:
  /// **'Select your search surname'**
  String get selectYourSurname;

  /// No description provided for @selectedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Selected Photos'**
  String get selectedPhotos;

  /// No description provided for @self.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get self;

  /// No description provided for @selfAndMamakulSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Self: {self} • Mamakul: {mamakul}'**
  String selfAndMamakulSubtitle(String self, String mamakul);

  /// No description provided for @selfClanRule.
  ///
  /// In en, this message translates to:
  /// **'Bride & Groom must not share the same paternal Gotra (e.g. Rathod, Pawar, Chavan, Jadhav).'**
  String get selfClanRule;

  /// No description provided for @selfClanTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Self Clan (गोत्र):'**
  String get selfClanTitle;

  /// No description provided for @selfEmployed.
  ///
  /// In en, this message translates to:
  /// **'Self Employed'**
  String get selfEmployed;

  /// No description provided for @selfServicePlans.
  ///
  /// In en, this message translates to:
  /// **'Self-Service'**
  String get selfServicePlans;

  /// No description provided for @selfieSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Selfie Submitted'**
  String get selfieSubmitted;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendHeartInterested.
  ///
  /// In en, this message translates to:
  /// **'Send a heart to show you\'re interested.'**
  String get sendHeartInterested;

  /// No description provided for @sendInterest.
  ///
  /// In en, this message translates to:
  /// **'Send Interest'**
  String get sendInterest;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'SEND MESSAGE'**
  String get sendMessage;

  /// No description provided for @sendToCandidateWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send to Bride/Groom on WhatsApp 🚩'**
  String get sendToCandidateWhatsApp;

  /// No description provided for @sendVerification.
  ///
  /// In en, this message translates to:
  /// **'Send Verification'**
  String get sendVerification;

  /// No description provided for @sendVerificationRequests.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Requests'**
  String get sendVerificationRequests;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @setAsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set as Primary'**
  String get setAsPrimary;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAndMenu.
  ///
  /// In en, this message translates to:
  /// **'Settings & Menu'**
  String get settingsAndMenu;

  /// No description provided for @sevenHalfToTenLakh.
  ///
  /// In en, this message translates to:
  /// **'₹7.5 Lakh - ₹10 Lakh'**
  String get sevenHalfToTenLakh;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareBtn.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareBtn;

  /// No description provided for @shareEducationalBackground.
  ///
  /// In en, this message translates to:
  /// **'Share your educational background and professional details'**
  String get shareEducationalBackground;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(String error);

  /// No description provided for @shareHub.
  ///
  /// In en, this message translates to:
  /// **'Share Hub'**
  String get shareHub;

  /// No description provided for @shareInApp.
  ///
  /// In en, this message translates to:
  /// **'Share In-App'**
  String get shareInApp;

  /// No description provided for @shareLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Share Limit Reached'**
  String get shareLimitReached;

  /// No description provided for @shareLinkOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Share Link on WhatsApp'**
  String get shareLinkOnWhatsapp;

  /// No description provided for @shareMyProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Express your interest by sharing your biodata directly'**
  String get shareMyProfileSubtitle;

  /// No description provided for @shareMyProfileWith.
  ///
  /// In en, this message translates to:
  /// **'Share my profile with {name}'**
  String shareMyProfileWith(String name);

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @shareProfilesWithYourFamilyInstantlyNbui.
  ///
  /// In en, this message translates to:
  /// **'Share profiles with your family instantly.\\nBuilt for the way Indian families make decisions.'**
  String get shareProfilesWithYourFamilyInstantlyNbui;

  /// No description provided for @shareToSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Share to Social Media'**
  String get shareToSocialMedia;

  /// No description provided for @shareYourEducationalBackgroundAndProfess.
  ///
  /// In en, this message translates to:
  /// **'Share your educational background and professional details'**
  String get shareYourEducationalBackgroundAndProfess;

  /// No description provided for @shareYourProfileProfessionally.
  ///
  /// In en, this message translates to:
  /// **'Share your profile professionally'**
  String get shareYourProfileProfessionally;

  /// No description provided for @shared.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get shared;

  /// No description provided for @sharedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Shared Profiles'**
  String get sharedProfiles;

  /// Text shown when two users share profiles with each other
  ///
  /// In en, this message translates to:
  /// **'You and {name} have shared profiles with each other.'**
  String sharedProfilesWithEachOther(String name);

  /// No description provided for @sharedVia.
  ///
  /// In en, this message translates to:
  /// **'Shared {name} via {method}'**
  String sharedVia(String name, String method);

  /// No description provided for @sharesPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} shares/month'**
  String sharesPerMonth(int count);

  /// No description provided for @sharingBiodataPdf.
  ///
  /// In en, this message translates to:
  /// **'Sharing Biodata PDF'**
  String get sharingBiodataPdf;

  /// No description provided for @sharingProfile.
  ///
  /// In en, this message translates to:
  /// **'Sharing profile...'**
  String get sharingProfile;

  /// No description provided for @sharingProfiles.
  ///
  /// In en, this message translates to:
  /// **'Sharing Profiles'**
  String get sharingProfiles;

  /// No description provided for @sibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get sibling;

  /// No description provided for @siblingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sibling} other{{count} siblings}}'**
  String siblingsCount(int count);

  /// No description provided for @siblingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Siblings'**
  String get siblingsLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in Required'**
  String get signInRequired;

  /// No description provided for @signInRequiredContent.
  ///
  /// In en, this message translates to:
  /// **'Please sign in or create an account to access this feature.'**
  String get signInRequiredContent;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @silverPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfect for getting started'**
  String get silverPlanDesc;

  /// No description provided for @silverPlanName.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silverPlanName;

  /// No description provided for @similarMatches.
  ///
  /// In en, this message translates to:
  /// **'Similar Matches'**
  String get similarMatches;

  /// No description provided for @sister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get sister;

  /// No description provided for @sisterCount.
  ///
  /// In en, this message translates to:
  /// **'Sisters'**
  String get sisterCount;

  /// No description provided for @sistersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sister} other{{count} sisters}}'**
  String sistersCount(int count);

  /// No description provided for @sixMonthsFree.
  ///
  /// In en, this message translates to:
  /// **'6 Months Free'**
  String get sixMonthsFree;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @skipAndSelectLevel.
  ///
  /// In en, this message translates to:
  /// **'Skip & Select Taluka/District'**
  String get skipAndSelectLevel;

  /// No description provided for @skipAndUseDistrict.
  ///
  /// In en, this message translates to:
  /// **'Skip & Use District'**
  String get skipAndUseDistrict;

  /// No description provided for @smartRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Smart Recommendations'**
  String get smartRecommendations;

  /// No description provided for @smartRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive curated bio recommendations tailored for you.'**
  String get smartRecommendationsSubtitle;

  /// No description provided for @smileNaturallyTip.
  ///
  /// In en, this message translates to:
  /// **'Smile naturally to appear approachable'**
  String get smileNaturallyTip;

  /// No description provided for @smokingHabits.
  ///
  /// In en, this message translates to:
  /// **'Smoking Habits'**
  String get smokingHabits;

  /// No description provided for @socialMediaTextOverlays.
  ///
  /// In en, this message translates to:
  /// **'Photos from social media with text overlays'**
  String get socialMediaTextOverlays;

  /// No description provided for @solicitingMoney.
  ///
  /// In en, this message translates to:
  /// **'Soliciting Money'**
  String get solicitingMoney;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @son.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get son;

  /// No description provided for @sortServicesBy.
  ///
  /// In en, this message translates to:
  /// **'Sort Services By'**
  String get sortServicesBy;

  /// No description provided for @specificLocation.
  ///
  /// In en, this message translates to:
  /// **'SPECIFIC LOCATION'**
  String get specificLocation;

  /// No description provided for @specified.
  ///
  /// In en, this message translates to:
  /// **'Specified'**
  String get specified;

  /// No description provided for @specifyEducation.
  ///
  /// In en, this message translates to:
  /// **'Specify Education'**
  String get specifyEducation;

  /// No description provided for @specifyProfession.
  ///
  /// In en, this message translates to:
  /// **'Specify Profession'**
  String get specifyProfession;

  /// No description provided for @standardFilters.
  ///
  /// In en, this message translates to:
  /// **'Standard Filters'**
  String get standardFilters;

  /// No description provided for @standardFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Basic demographic criteria for all registered members'**
  String get standardFiltersSubtitle;

  /// No description provided for @standardPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Try premium features for a month'**
  String get standardPlanDesc;

  /// No description provided for @standardPlanName.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standardPlanName;

  /// No description provided for @standardProfile.
  ///
  /// In en, this message translates to:
  /// **'Standard Profile'**
  String get standardProfile;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @startAConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startAConversation;

  /// No description provided for @startChatting.
  ///
  /// In en, this message translates to:
  /// **'START CHATTING 💬'**
  String get startChatting;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @startSharingProfilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Start sharing profiles with family and friends to help find the perfect match'**
  String get startSharingProfilesDesc;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @stateInIndia.
  ///
  /// In en, this message translates to:
  /// **'State in India'**
  String get stateInIndia;

  /// No description provided for @statusWaitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Status: Waiting for approval'**
  String get statusWaitingForApproval;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @stayConnectedOnBanjaraBio.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected on BanjaraBio'**
  String get stayConnectedOnBanjaraBio;

  /// No description provided for @step1SelectCategory.
  ///
  /// In en, this message translates to:
  /// **'1. Select Your Service Category'**
  String get step1SelectCategory;

  /// No description provided for @step1SelectCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the primary wedding service you provide'**
  String get step1SelectCategorySubtitle;

  /// No description provided for @step2BusinessContact.
  ///
  /// In en, this message translates to:
  /// **'2. Business & Contact Information'**
  String get step2BusinessContact;

  /// No description provided for @step2BusinessContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter authentic details for community clients'**
  String get step2BusinessContactSubtitle;

  /// No description provided for @step3ServiceSpecs.
  ///
  /// In en, this message translates to:
  /// **'3. Dynamic Service Specifications'**
  String get step3ServiceSpecs;

  /// No description provided for @step3ServiceSpecsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Specific details tailored for {category}'**
  String step3ServiceSpecsSubtitle(Object category);

  /// No description provided for @step4PricingExperience.
  ///
  /// In en, this message translates to:
  /// **'4. Pricing & Experience'**
  String get step4PricingExperience;

  /// No description provided for @step4PricingExperienceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help families understand your package range'**
  String get step4PricingExperienceSubtitle;

  /// No description provided for @stepCounterFormat.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepCounterFormat(int current, int total);

  /// No description provided for @stepLabelDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get stepLabelDetails;

  /// No description provided for @stepLabelGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get stepLabelGoal;

  /// No description provided for @stepLabelSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get stepLabelSignIn;

  /// No description provided for @stepLabelType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get stepLabelType;

  /// No description provided for @stepLabelWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get stepLabelWelcome;

  /// No description provided for @stepNOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepNOfTotal(String current, String total);

  /// No description provided for @strictPrivacyNotificationNote.
  ///
  /// In en, this message translates to:
  /// **'100% Strict Privacy: Bookmarks & profile views are completely private and never triggered as notifications.'**
  String get strictPrivacyNotificationNote;

  /// No description provided for @strongBanjaraClanAlignment.
  ///
  /// In en, this message translates to:
  /// **'Strong Banjara Clan & Astro Alignment'**
  String get strongBanjaraClanAlignment;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @subCaste.
  ///
  /// In en, this message translates to:
  /// **'Sub-Caste'**
  String get subCaste;

  /// No description provided for @subCasteJatiVariant.
  ///
  /// In en, this message translates to:
  /// **'Sub-Caste / Jati Variant'**
  String get subCasteJatiVariant;

  /// No description provided for @subCasteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by regional Banjara cultural designation'**
  String get subCasteSubtitle;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT FOR REVIEW'**
  String get submitForReview;

  /// No description provided for @submitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for Verification'**
  String get submitForVerification;

  /// No description provided for @submitVendorRegistration.
  ///
  /// In en, this message translates to:
  /// **'Submit Vendor Registration'**
  String get submitVendorRegistration;

  /// No description provided for @submittedForReview.
  ///
  /// In en, this message translates to:
  /// **'Submitted for Review'**
  String get submittedForReview;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @subsidizedPricePill.
  ///
  /// In en, this message translates to:
  /// **'Subsidized: ₹20 / month  •  ₹200 / year'**
  String get subsidizedPricePill;

  /// No description provided for @successSubmission.
  ///
  /// In en, this message translates to:
  /// **'Success! Your request has been submitted for review.'**
  String get successSubmission;

  /// No description provided for @supportAndHelp.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get supportAndHelp;

  /// No description provided for @supportBanjarabioApp.
  ///
  /// In en, this message translates to:
  /// **'support@banjarabio.com'**
  String get supportBanjarabioApp;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @surnameLabel.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surnameLabel;

  /// No description provided for @swipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get swipe;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @taluka.
  ///
  /// In en, this message translates to:
  /// **'Taluka'**
  String get taluka;

  /// No description provided for @talukaInDistrictState.
  ///
  /// In en, this message translates to:
  /// **'Taluka in {district}, {state}'**
  String talukaInDistrictState(String district, String state);

  /// No description provided for @talukaOptional.
  ///
  /// In en, this message translates to:
  /// **'Taluka (Optional)'**
  String get talukaOptional;

  /// No description provided for @tapAgainToChat.
  ///
  /// In en, this message translates to:
  /// **'Tap again to Chat ➔'**
  String get tapAgainToChat;

  /// No description provided for @tapAgainToJoin.
  ///
  /// In en, this message translates to:
  /// **'Tap again to Join ➔'**
  String get tapAgainToJoin;

  /// No description provided for @tapAgainToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap again to Open ➔'**
  String get tapAgainToOpen;

  /// No description provided for @tapAgainToView.
  ///
  /// In en, this message translates to:
  /// **'Tap again to View ➔'**
  String get tapAgainToView;

  /// No description provided for @tapAnyThemeToApply.
  ///
  /// In en, this message translates to:
  /// **'Tap any theme to instantly apply it to your biodata.'**
  String get tapAnyThemeToApply;

  /// No description provided for @tapTheButtonToAddAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add a photo'**
  String get tapTheButtonToAddAPhoto;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @tapToPreviewKundali.
  ///
  /// In en, this message translates to:
  /// **'Tap to preview Kundali chart & planetary alignments'**
  String get tapToPreviewKundali;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'✨ Tap to Reveal'**
  String get tapToReveal;

  /// No description provided for @targetBiodataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which biodata are you looking for?'**
  String get targetBiodataQuestion;

  /// No description provided for @targetGenderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select Gender (Bride / Groom)'**
  String get targetGenderSubtitle;

  /// No description provided for @teacherProfessor.
  ///
  /// In en, this message translates to:
  /// **'Teacher/Professor'**
  String get teacherProfessor;

  /// No description provided for @teamVisit.
  ///
  /// In en, this message translates to:
  /// **'Team Visit'**
  String get teamVisit;

  /// No description provided for @tellUsYourStory.
  ///
  /// In en, this message translates to:
  /// **'Tell us your Story'**
  String get tellUsYourStory;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get telugu;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @tenToFifteenLakh.
  ///
  /// In en, this message translates to:
  /// **'₹10 Lakh - ₹15 Lakh'**
  String get tenToFifteenLakh;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsS1Content.
  ///
  /// In en, this message translates to:
  /// **'By accessing or using the BanjaraBio application, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the service.'**
  String get termsS1Content;

  /// No description provided for @termsS1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get termsS1Title;

  /// No description provided for @termsS2Content.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old (for females) or 21 years old (for males) to register on this platform. The platform is strictly for matrimonial purposes.'**
  String get termsS2Content;

  /// No description provided for @termsS2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Eligibility'**
  String get termsS2Title;

  /// No description provided for @termsS3Content.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account credentials. All information provided during registration must be accurate and truthful.'**
  String get termsS3Content;

  /// No description provided for @termsS3Title.
  ///
  /// In en, this message translates to:
  /// **'3. User Account'**
  String get termsS3Title;

  /// No description provided for @termsS4Content.
  ///
  /// In en, this message translates to:
  /// **'Users are prohibited from using the platform for commercial purposes, harassment, spreading hate speech, or sharing fraudulent information.'**
  String get termsS4Content;

  /// No description provided for @termsS4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Prohibited Activities'**
  String get termsS4Title;

  /// No description provided for @termsS5Content.
  ///
  /// In en, this message translates to:
  /// **'You may request account deletion at any time through the \"Delete Account\" section in your profile settings.'**
  String get termsS5Content;

  /// No description provided for @termsS5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Account Deletion'**
  String get termsS5Title;

  /// No description provided for @termsS6Content.
  ///
  /// In en, this message translates to:
  /// **'BanjaraBio is a platform for finding matches. We do not guarantee successful matches or verify the character of users beyond basic checks. Users are encouraged to perform their own due diligence.'**
  String get termsS6Content;

  /// No description provided for @termsS6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Limitation of Liability'**
  String get termsS6Title;

  /// No description provided for @termsS7Content.
  ///
  /// In en, this message translates to:
  /// **'These terms shall be governed by and construed in accordance with the laws of India. Any disputes shall be subject to the exclusive jurisdiction of the courts in Maharashtra.'**
  String get termsS7Content;

  /// No description provided for @termsS7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Governing Law'**
  String get termsS7Title;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @textSuper.
  ///
  /// In en, this message translates to:
  /// **'Super'**
  String get textSuper;

  /// No description provided for @themesCount.
  ///
  /// In en, this message translates to:
  /// **'Themes ({count})'**
  String themesCount(Object count);

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @threeXReplies.
  ///
  /// In en, this message translates to:
  /// **'3x Replies'**
  String get threeXReplies;

  /// No description provided for @tier4Vip.
  ///
  /// In en, this message translates to:
  /// **'TIER 4 VIP'**
  String get tier4Vip;

  /// No description provided for @tillUMarry.
  ///
  /// In en, this message translates to:
  /// **'Till U Marry'**
  String get tillUMarry;

  /// No description provided for @tipPersonalizedNotes.
  ///
  /// In en, this message translates to:
  /// **'Tip: Personalized notes get 3x replies'**
  String get tipPersonalizedNotes;

  /// No description provided for @toContact.
  ///
  /// In en, this message translates to:
  /// **'To: {name}'**
  String toContact(String name);

  /// No description provided for @topDelivery.
  ///
  /// In en, this message translates to:
  /// **'Top Delivery'**
  String get topDelivery;

  /// No description provided for @totalBlocks.
  ///
  /// In en, this message translates to:
  /// **'Total Blocks'**
  String get totalBlocks;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get totalCount;

  /// No description provided for @totalFemales.
  ///
  /// In en, this message translates to:
  /// **'Total Females'**
  String get totalFemales;

  /// No description provided for @totalMales.
  ///
  /// In en, this message translates to:
  /// **'Total Males'**
  String get totalMales;

  /// No description provided for @totalMessages.
  ///
  /// In en, this message translates to:
  /// **'Total Messages'**
  String get totalMessages;

  /// No description provided for @totalProfiles.
  ///
  /// In en, this message translates to:
  /// **'Total Profiles'**
  String get totalProfiles;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings: ₹{amount}'**
  String totalSavings(int amount);

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @tourBookmarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Found a profile you like? Bookmark it to view it later in your Saved list.'**
  String get tourBookmarkDesc;

  /// No description provided for @tourBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Save for later'**
  String get tourBookmarkTitle;

  /// No description provided for @tourBottomHome.
  ///
  /// In en, this message translates to:
  /// **'Home Feed'**
  String get tourBottomHome;

  /// No description provided for @tourBottomHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Scroll through thousands of verified profiles.'**
  String get tourBottomHomeDesc;

  /// No description provided for @tourBottomProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get tourBottomProfile;

  /// No description provided for @tourBottomProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your own biodata and photos here.'**
  String get tourBottomProfileDesc;

  /// No description provided for @tourBottomSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get tourBottomSettings;

  /// No description provided for @tourBottomSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Change language, notification settings, or contact support.'**
  String get tourBottomSettingsDesc;

  /// No description provided for @tourBottomShared.
  ///
  /// In en, this message translates to:
  /// **'Shared Profiles'**
  String get tourBottomShared;

  /// No description provided for @tourBottomSharedDesc.
  ///
  /// In en, this message translates to:
  /// **'See profiles you\'ve shared or received via WhatsApp/Link.'**
  String get tourBottomSharedDesc;

  /// No description provided for @tourChatDesc.
  ///
  /// In en, this message translates to:
  /// **'View your conversations and incoming interests here.'**
  String get tourChatDesc;

  /// No description provided for @tourChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages & Chat'**
  String get tourChatTitle;

  /// No description provided for @tourFilterDesc.
  ///
  /// In en, this message translates to:
  /// **'Narrow down by Age, Education, or Profession to see only who you want.'**
  String get tourFilterDesc;

  /// No description provided for @tourFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get tourFilterTitle;

  /// No description provided for @tourInstagramDesc.
  ///
  /// In en, this message translates to:
  /// **'See daily new profiles and success stories on Instagram.'**
  String get tourInstagramDesc;

  /// No description provided for @tourInstagramTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get tourInstagramTitle;

  /// No description provided for @tourInterestDesc.
  ///
  /// In en, this message translates to:
  /// **'Send a heart to let them know you\'re interested in their biodata.'**
  String get tourInterestDesc;

  /// No description provided for @tourInterestTitle.
  ///
  /// In en, this message translates to:
  /// **'Express Interest'**
  String get tourInterestTitle;

  /// No description provided for @tourLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Filter profiles by State, District, or Taluka to find matches near you.'**
  String get tourLocationDesc;

  /// No description provided for @tourLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get tourLocationTitle;

  /// No description provided for @tourMatchesMatchedDesc.
  ///
  /// In en, this message translates to:
  /// **'Mutual matches where both you and the other person expressed interest!'**
  String get tourMatchesMatchedDesc;

  /// No description provided for @tourMatchesMatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'Matched Profiles'**
  String get tourMatchesMatchedTitle;

  /// No description provided for @tourMatchesReceivedDesc.
  ///
  /// In en, this message translates to:
  /// **'Profiles others have shared with you via WhatsApp or Link.'**
  String get tourMatchesReceivedDesc;

  /// No description provided for @tourMatchesReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Received Profiles'**
  String get tourMatchesReceivedTitle;

  /// No description provided for @tourMatchesSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Quickly find profiles shared with you or by you using name or education.'**
  String get tourMatchesSearchDesc;

  /// No description provided for @tourMatchesSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Shared Profiles'**
  String get tourMatchesSearchTitle;

  /// No description provided for @tourMatchesSentDesc.
  ///
  /// In en, this message translates to:
  /// **'All the profiles you have shared with family and friends appear here.'**
  String get tourMatchesSentDesc;

  /// No description provided for @tourMatchesSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent Profiles'**
  String get tourMatchesSentTitle;

  /// No description provided for @tourProfileEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your personal details, photos, and preferences anytime.'**
  String get tourProfileEditDesc;

  /// No description provided for @tourProfileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get tourProfileEditTitle;

  /// No description provided for @tourProfilePdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate a professional PDF of your biodata to share with family members.'**
  String get tourProfilePdfDesc;

  /// No description provided for @tourProfilePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Biodata PDF'**
  String get tourProfilePdfTitle;

  /// No description provided for @tourProfilePhotosDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload, reorder, or delete your profile photos to make a great first impression.'**
  String get tourProfilePhotosDesc;

  /// No description provided for @tourProfilePhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Photos'**
  String get tourProfilePhotosTitle;

  /// No description provided for @tourProfileSavedDesc.
  ///
  /// In en, this message translates to:
  /// **'View all the profiles you have bookmarked for later review.'**
  String get tourProfileSavedDesc;

  /// No description provided for @tourProfileSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Profiles'**
  String get tourProfileSavedTitle;

  /// No description provided for @tourProfileTrustDesc.
  ///
  /// In en, this message translates to:
  /// **'Your credibility score. Verify your ID, selfie, and community to increase it.'**
  String get tourProfileTrustDesc;

  /// No description provided for @tourProfileTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get tourProfileTrustTitle;

  /// No description provided for @tourSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Looking for someone specific? Type their name or education here.'**
  String get tourSearchDesc;

  /// No description provided for @tourSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Profiles'**
  String get tourSearchTitle;

  /// No description provided for @tourShareDesc.
  ///
  /// In en, this message translates to:
  /// **'Easily share profiles via WhatsApp with your parents or relatives for their opinion.'**
  String get tourShareDesc;

  /// No description provided for @tourShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share with family'**
  String get tourShareTitle;

  /// No description provided for @tourWhatsappDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct contact with our admin for help or profile changes.'**
  String get tourWhatsappDesc;

  /// No description provided for @tourWhatsappTitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get tourWhatsappTitle;

  /// No description provided for @traditionalFormalAttire.
  ///
  /// In en, this message translates to:
  /// **'Traditional or formal attire (saree, salwar kameez, kurta)'**
  String get traditionalFormalAttire;

  /// No description provided for @translatesWholePdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Translates whole PDF (keys & profile info)'**
  String get translatesWholePdfDesc;

  /// No description provided for @trustAllianceBadge.
  ///
  /// In en, this message translates to:
  /// **'✦ TRUST ALLIANCE'**
  String get trustAllianceBadge;

  /// No description provided for @trustDiscountApplied.
  ///
  /// In en, this message translates to:
  /// **'Trust Score Discount Applied'**
  String get trustDiscountApplied;

  /// No description provided for @trustLevel.
  ///
  /// In en, this message translates to:
  /// **'TRUST LEVEL'**
  String get trustLevel;

  /// No description provided for @trustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get trustScore;

  /// No description provided for @trustScoreBeyondBeauty.
  ///
  /// In en, this message translates to:
  /// **'TRUST SCORE BEYOND BEAUTY'**
  String get trustScoreBeyondBeauty;

  /// No description provided for @trustScoreDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Trust Score & Discounts'**
  String get trustScoreDiscounts;

  /// No description provided for @trustScoreShareMessage.
  ///
  /// In en, this message translates to:
  /// **'I just verified my profile on BanjaraBio with a Trust Score of {score}! Check out my profile and join our community: {url}'**
  String trustScoreShareMessage(int score, String url);

  /// No description provided for @trustVerification.
  ///
  /// In en, this message translates to:
  /// **'Trust & Verification'**
  String get trustVerification;

  /// No description provided for @trusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get trusted;

  /// No description provided for @trustedCommunityBadge.
  ///
  /// In en, this message translates to:
  /// **'100% Trusted Community'**
  String get trustedCommunityBadge;

  /// No description provided for @trustedMember.
  ///
  /// In en, this message translates to:
  /// **'Trusted Member'**
  String get trustedMember;

  /// No description provided for @trustedProfile.
  ///
  /// In en, this message translates to:
  /// **'Trusted Profile'**
  String get trustedProfile;

  /// No description provided for @tryAdjustingYourFilterCriteria.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filter criteria'**
  String get tryAdjustingYourFilterCriteria;

  /// No description provided for @tryAdjustingYourFiltersToSeeMoreProfiles.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters to see more profiles from the Banjara community'**
  String get tryAdjustingYourFiltersToSeeMoreProfiles;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @trySearchingForADifferentCity.
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different city'**
  String get trySearchingForADifferentCity;

  /// No description provided for @trySearchingForDifferentCity.
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different city'**
  String get trySearchingForDifferentCity;

  /// No description provided for @twentyLakhPlus.
  ///
  /// In en, this message translates to:
  /// **'₹20 Lakh+'**
  String get twentyLakhPlus;

  /// No description provided for @twoMonthsFree.
  ///
  /// In en, this message translates to:
  /// **'2 Months Free'**
  String get twoMonthsFree;

  /// No description provided for @twoToFiveLakh.
  ///
  /// In en, this message translates to:
  /// **'₹2 Lakh - ₹5 Lakh'**
  String get twoToFiveLakh;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @typeCustomIntroNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Type your custom matrimonial intro note here...\n(e.g., family background, career aspirations, shared values)'**
  String get typeCustomIntroNoteHint;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @unauthorizedAccessAdminsOnly.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access. Admins only.'**
  String get unauthorizedAccessAdminsOnly;

  /// No description provided for @unblockAllProFeatures.
  ///
  /// In en, this message translates to:
  /// **'UNBLOCK ALL PRO FEATURES'**
  String get unblockAllProFeatures;

  /// No description provided for @under2Lakh.
  ///
  /// In en, this message translates to:
  /// **'Under ₹2 Lakh'**
  String get under2Lakh;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedError(String error);

  /// No description provided for @unexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedErrorOccurred(String error);

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @unlimitedBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Unlimited bookmarks'**
  String get unlimitedBookmarks;

  /// No description provided for @unlimitedContactUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Contact Unlocks'**
  String get unlimitedContactUnlocks;

  /// No description provided for @unlimitedHandpickedMatches.
  ///
  /// In en, this message translates to:
  /// **'Daily On-Demand Matches'**
  String get unlimitedHandpickedMatches;

  /// No description provided for @unlimitedProfileViews.
  ///
  /// In en, this message translates to:
  /// **'Unlimited profile views'**
  String get unlimitedProfileViews;

  /// No description provided for @unlimitedSharing.
  ///
  /// In en, this message translates to:
  /// **'Unlimited sharing'**
  String get unlimitedSharing;

  /// No description provided for @unlockAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Unlock Advanced Filters'**
  String get unlockAdvancedFilters;

  /// No description provided for @unlockCommunityFiltersDesc.
  ///
  /// In en, this message translates to:
  /// **'Filter Gotra, Maternal Gotra (मोसळ), Sub-Caste, Tanda/Origin, Height, Income & Lineage for just ₹20/mo or ₹200/yr.'**
  String get unlockCommunityFiltersDesc;

  /// No description provided for @unlockCommunityFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Community Filters (BVS)'**
  String get unlockCommunityFiltersTitle;

  /// No description provided for @unlockDirectMessageAd.
  ///
  /// In en, this message translates to:
  /// **'Watch 3 ads to unlock 1 direct message for FREE!'**
  String get unlockDirectMessageAd;

  /// No description provided for @unlockForPriceButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock for ₹20/mo or ₹200/yr ➔'**
  String get unlockForPriceButton;

  /// No description provided for @unlockMatchmakerFiltersDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct contact numbers, 36 Guna Score, Ancestral Land Holdings & RM Curation available on VIP Matchmaker plans.'**
  String get unlockMatchmakerFiltersDesc;

  /// No description provided for @unlockMatchmakerFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Matchmaker Filters'**
  String get unlockMatchmakerFiltersTitle;

  /// No description provided for @unlockMoreViewsAd.
  ///
  /// In en, this message translates to:
  /// **'Watch a quick ad to unlock 5 MORE views for today!'**
  String get unlockMoreViewsAd;

  /// No description provided for @unlockMoreVisitors.
  ///
  /// In en, this message translates to:
  /// **'Unlock {count} more visitors!'**
  String unlockMoreVisitors(int count);

  /// No description provided for @unlockNow.
  ///
  /// In en, this message translates to:
  /// **'Unlock now'**
  String get unlockNow;

  /// No description provided for @unlockPremiumBiodata.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Biodata'**
  String get unlockPremiumBiodata;

  /// No description provided for @unlockPremiumFeaturesToEnhanceYourBiodat.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium features to enhance your biodata profile'**
  String get unlockPremiumFeaturesToEnhanceYourBiodat;

  /// No description provided for @unlockPremiumFiltersDesc.
  ///
  /// In en, this message translates to:
  /// **'Access Govt ID Verified, Kundali Dosha, Diet, Sector, and Active Responder filters with Premium self-service plans.'**
  String get unlockPremiumFiltersDesc;

  /// No description provided for @unlockPremiumFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Filters'**
  String get unlockPremiumFiltersTitle;

  /// No description provided for @unlockToDownload.
  ///
  /// In en, this message translates to:
  /// **'Unlock to download and share this template in 5+ languages.'**
  String get unlockToDownload;

  /// No description provided for @unmarried.
  ///
  /// In en, this message translates to:
  /// **'Unmarried'**
  String get unmarried;

  /// No description provided for @unsave.
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsave;

  /// No description provided for @unsavedDraftBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Your entered information is saved safely. Tap to resume.'**
  String get unsavedDraftBodyGeneric;

  /// No description provided for @unsavedDraftBodyWithName.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s biodata draft is saved. Resume from where you left.'**
  String unsavedDraftBodyWithName(String name);

  /// No description provided for @unsavedDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'📝 Unsaved Biodata Draft Found!'**
  String get unsavedDraftTitle;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @upcomingMelavas.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Melavas'**
  String get upcomingMelavas;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(String error);

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// No description provided for @upgradePremiumFilters.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to access granular filters for profession, location, and more.'**
  String get upgradePremiumFilters;

  /// No description provided for @upgradeRequired.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Required'**
  String get upgradeRequired;

  /// No description provided for @upgradeToCommunityButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Community (₹20/mo or ₹200/yr)'**
  String get upgradeToCommunityButton;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @upgradeToPremiumFor6PhotosAdvancedFilter.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium for 6 photos & advanced filters'**
  String get upgradeToPremiumFor6PhotosAdvancedFilter;

  /// No description provided for @upgradeToPremiumToAccessGranularFiltersF.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to access granular filters'**
  String get upgradeToPremiumToAccessGranularFiltersF;

  /// No description provided for @upgradeToShareMore.
  ///
  /// In en, this message translates to:
  /// **'You have reached your free sharing limit. Upgrade to continue sharing profiles.'**
  String get upgradeToShareMore;

  /// No description provided for @upgradeToUnlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock all features'**
  String get upgradeToUnlockAllFeatures;

  /// No description provided for @upgradeToUnlockPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to remove all ads and unlock premium biodata features.'**
  String get upgradeToUnlockPremiumFeatures;

  /// No description provided for @uploadBvsCardPrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload your Banjara Virasat Sangh (BVS) Membership Card'**
  String get uploadBvsCardPrompt;

  /// No description provided for @uploadCommunityCertificateLetter.
  ///
  /// In en, this message translates to:
  /// **'Upload Community Certificate / Letter'**
  String get uploadCommunityCertificateLetter;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(String error);

  /// No description provided for @uploadYourPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload your best photos'**
  String get uploadYourPhotos;

  /// No description provided for @uploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Successfully'**
  String get uploadedSuccessfully;

  /// No description provided for @upperMiddleClass.
  ///
  /// In en, this message translates to:
  /// **'Upper Middle Class'**
  String get upperMiddleClass;

  /// No description provided for @useCameraToCapture.
  ///
  /// In en, this message translates to:
  /// **'Use camera to capture'**
  String get useCameraToCapture;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @useEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Use Email / Password'**
  String get useEmailPassword;

  /// No description provided for @useNaturalLightingTip.
  ///
  /// In en, this message translates to:
  /// **'Use natural lighting for best results'**
  String get useNaturalLightingTip;

  /// No description provided for @userBlockRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'User block request submitted'**
  String get userBlockRequestSubmitted;

  /// No description provided for @userBlockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get userBlockedSuccessfully;

  /// No description provided for @userEngagement.
  ///
  /// In en, this message translates to:
  /// **'User Engagement'**
  String get userEngagement;

  /// No description provided for @userIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'User ID not found'**
  String get userIdNotFound;

  /// No description provided for @userIdNotFoundToast.
  ///
  /// In en, this message translates to:
  /// **'User ID not found'**
  String get userIdNotFoundToast;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @userNotUploadedPhoto.
  ///
  /// In en, this message translates to:
  /// **'User not uploaded photo'**
  String get userNotUploadedPhoto;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @usingGps.
  ///
  /// In en, this message translates to:
  /// **'Using GPS'**
  String get usingGps;

  /// No description provided for @vadhuVarSuchakInitiative.
  ///
  /// In en, this message translates to:
  /// **'Vadhu Var Suchak Initiative'**
  String get vadhuVarSuchakInitiative;

  /// No description provided for @vendorNetworkEffectDesc.
  ///
  /// In en, this message translates to:
  /// **'Self-register your services to receive direct 1-click WhatsApp inquiries from thousands of Banjara families.'**
  String get vendorNetworkEffectDesc;

  /// No description provided for @vendorRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vendor Registration'**
  String get vendorRegistration;

  /// No description provided for @vendorRegistrationSubmittedCongrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! {name} has been submitted for verified vendor listing on the BanjaraBio Network.'**
  String vendorRegistrationSubmittedCongrats(Object name);

  /// No description provided for @vendorTermsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to provide authentic, verified wedding services to Banjara community families with 100% transparency.'**
  String get vendorTermsAgreement;

  /// No description provided for @vendorVerificationDeskNote.
  ///
  /// In en, this message translates to:
  /// **'Our vendor verification desk will verify and activate your listing within 2-4 hours.'**
  String get vendorVerificationDeskNote;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// No description provided for @verificationBadge.
  ///
  /// In en, this message translates to:
  /// **'Verification badge'**
  String get verificationBadge;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent!'**
  String get verificationCodeSent;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @verificationLinkcodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification link/code sent!'**
  String get verificationLinkcodeSent;

  /// No description provided for @verificationRequests.
  ///
  /// In en, this message translates to:
  /// **'Verification Requests'**
  String get verificationRequests;

  /// No description provided for @verifications.
  ///
  /// In en, this message translates to:
  /// **'Verifications'**
  String get verifications;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @verified10PointsAddedToTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Verified! +10 Points added to Trust Score'**
  String get verified10PointsAddedToTrustScore;

  /// No description provided for @verifiedBiodata.
  ///
  /// In en, this message translates to:
  /// **'Verified Biodata'**
  String get verifiedBiodata;

  /// No description provided for @verifiedCommunityMember.
  ///
  /// In en, this message translates to:
  /// **'Verified Community Member'**
  String get verifiedCommunityMember;

  /// No description provided for @verifiedCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Verified'**
  String verifiedCountBadge(int count);

  /// No description provided for @verifiedHoroscopeOnMutual.
  ///
  /// In en, this message translates to:
  /// **'Verified horoscope chart on mutual match interest'**
  String get verifiedHoroscopeOnMutual;

  /// No description provided for @verifiedProfile.
  ///
  /// In en, this message translates to:
  /// **'Verified Profile'**
  String get verifiedProfile;

  /// No description provided for @verifiedProfileBadge.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED PROFILE'**
  String get verifiedProfileBadge;

  /// No description provided for @verifiedProfilesGet5xMoreResponses.
  ///
  /// In en, this message translates to:
  /// **'Verified profiles get 5x more responses and appear higher in search results.'**
  String get verifiedProfilesGet5xMoreResponses;

  /// No description provided for @verifiedSalary.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED SALARY'**
  String get verifiedSalary;

  /// No description provided for @verifiedTrusted.
  ///
  /// In en, this message translates to:
  /// **'Verified & Trusted'**
  String get verifiedTrusted;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verifyEmailAddressHeading.
  ///
  /// In en, this message translates to:
  /// **'Verify Email Address'**
  String get verifyEmailAddressHeading;

  /// No description provided for @verifyLabel.
  ///
  /// In en, this message translates to:
  /// **'Verify {label}'**
  String verifyLabel(String label);

  /// No description provided for @verifyMobile.
  ///
  /// In en, this message translates to:
  /// **'Verify Mobile'**
  String get verifyMobile;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @verifyYourCommunityStatus.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Community Status'**
  String get verifyYourCommunityStatus;

  /// No description provided for @verifyYourEmailAddressToAddTrustAndReach.
  ///
  /// In en, this message translates to:
  /// **'Verify your email address to add trust and reach more profiles.'**
  String get verifyYourEmailAddressToAddTrustAndReach;

  /// No description provided for @verifyYourMobileNumberToAddTrustAndReach.
  ///
  /// In en, this message translates to:
  /// **'Verify your mobile number to add trust and reach more profiles.'**
  String get verifyYourMobileNumberToAddTrustAndReach;

  /// No description provided for @veryFair.
  ///
  /// In en, this message translates to:
  /// **'Very Fair'**
  String get veryFair;

  /// No description provided for @vettedFamily.
  ///
  /// In en, this message translates to:
  /// **'VETTED FAMILY'**
  String get vettedFamily;

  /// No description provided for @videoBioIntro.
  ///
  /// In en, this message translates to:
  /// **'Video Bio / Intro'**
  String get videoBioIntro;

  /// No description provided for @videoIntro.
  ///
  /// In en, this message translates to:
  /// **'Video Introduction'**
  String get videoIntro;

  /// No description provided for @videoIntroUploaded.
  ///
  /// In en, this message translates to:
  /// **'Video Intro Uploaded'**
  String get videoIntroUploaded;

  /// No description provided for @videoRecorded.
  ///
  /// In en, this message translates to:
  /// **'Video Recorded!'**
  String get videoRecorded;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get view;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewBiodata.
  ///
  /// In en, this message translates to:
  /// **'View Biodata'**
  String get viewBiodata;

  /// No description provided for @viewBiodataPdf.
  ///
  /// In en, this message translates to:
  /// **'View Biodata PDF'**
  String get viewBiodataPdf;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewLabel.
  ///
  /// In en, this message translates to:
  /// **'view'**
  String get viewLabel;

  /// No description provided for @viewPremiumPlansButton.
  ///
  /// In en, this message translates to:
  /// **'View Premium Plans ➔'**
  String get viewPremiumPlansButton;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @viewVenue.
  ///
  /// In en, this message translates to:
  /// **'View Venue'**
  String get viewVenue;

  /// No description provided for @viewYourBookmarkedProfiles.
  ///
  /// In en, this message translates to:
  /// **'View your bookmarked profiles'**
  String get viewYourBookmarkedProfiles;

  /// No description provided for @viewsLabel.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get viewsLabel;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @villageTanda.
  ///
  /// In en, this message translates to:
  /// **'Village / Tanda'**
  String get villageTanda;

  /// No description provided for @villageTandaExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pohradevi Tanda, Sevadas Nagar...'**
  String get villageTandaExampleHint;

  /// No description provided for @vipFeatures.
  ///
  /// In en, this message translates to:
  /// **'VIP Features'**
  String get vipFeatures;

  /// No description provided for @vipFiftyPercentOff.
  ///
  /// In en, this message translates to:
  /// **'50% OFF VIP'**
  String get vipFiftyPercentOff;

  /// No description provided for @vipMatchmaker.
  ///
  /// In en, this message translates to:
  /// **'VIP Matchmaker'**
  String get vipMatchmaker;

  /// No description provided for @vipNote.
  ///
  /// In en, this message translates to:
  /// **'VIP NOTE 👑'**
  String get vipNote;

  /// No description provided for @vipPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Ultimate experience with priority support'**
  String get vipPlanDesc;

  /// No description provided for @vipPlanName.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get vipPlanName;

  /// No description provided for @vipPropertyAssets.
  ///
  /// In en, this message translates to:
  /// **'VIP PROPERTY & ASSET HOLDINGS'**
  String get vipPropertyAssets;

  /// No description provided for @vipRoyal.
  ///
  /// In en, this message translates to:
  /// **'👑 VIP Royal'**
  String get vipRoyal;

  /// No description provided for @vipSpotlightElitePool.
  ///
  /// In en, this message translates to:
  /// **'VIP Spotlight & Elite Pool'**
  String get vipSpotlightElitePool;

  /// No description provided for @vipSpotlightElitePoolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top-tier prominent Banjara families with premium background checks'**
  String get vipSpotlightElitePoolSubtitle;

  /// No description provided for @visibleToAllProfiles.
  ///
  /// In en, this message translates to:
  /// **'Visible to all profiles'**
  String get visibleToAllProfiles;

  /// No description provided for @visibleToCloseMatchesOnly.
  ///
  /// In en, this message translates to:
  /// **'Visible to close matches only'**
  String get visibleToCloseMatchesOnly;

  /// No description provided for @vouchBadgeRequirementNotice.
  ///
  /// In en, this message translates to:
  /// **'Get 5 vouches from verified members to earn the \"Community Trusted\" badge.'**
  String get vouchBadgeRequirementNotice;

  /// No description provided for @watchAdToUnlock.
  ///
  /// In en, this message translates to:
  /// **'WATCH AD TO UNLOCK'**
  String get watchAdToUnlock;

  /// No description provided for @watchAdToUnlockAll.
  ///
  /// In en, this message translates to:
  /// **'WATCH AD TO UNLOCK ALL'**
  String get watchAdToUnlockAll;

  /// No description provided for @watchQuickAd.
  ///
  /// In en, this message translates to:
  /// **'WATCH QUICK AD'**
  String get watchQuickAd;

  /// No description provided for @weEncounteredAnUnexpectedErrorWhileProce.
  ///
  /// In en, this message translates to:
  /// **'We encountered an unexpected error while processing your request.'**
  String get weEncounteredAnUnexpectedErrorWhileProce;

  /// No description provided for @weWillSendAVerificationRequestToTheirMob.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification request to their mobile number. Once they approve, you get +10 Points.'**
  String get weWillSendAVerificationRequestToTheirMob;

  /// No description provided for @weWillVerifyYourCommunityDetailsShortly1.
  ///
  /// In en, this message translates to:
  /// **'We will verify your community details shortly. +15 Points Pending.'**
  String get weWillVerifyYourCommunityDetailsShortly1;

  /// No description provided for @weddingDate.
  ///
  /// In en, this message translates to:
  /// **'Wedding Date'**
  String get weddingDate;

  /// No description provided for @weeklyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Weekly Check-in'**
  String get weeklyCheckIn;

  /// No description provided for @welcomeBackAccountFound.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Your account has been found.'**
  String get welcomeBackAccountFound;

  /// No description provided for @welcomeToBanjaraBio.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BanjaraBio'**
  String get welcomeToBanjaraBio;

  /// No description provided for @whatDoYouLookFor.
  ///
  /// In en, this message translates to:
  /// **'What do you look for in a partner?'**
  String get whatDoYouLookFor;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @whatsAppContact.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Contact'**
  String get whatsAppContact;

  /// No description provided for @whatsAppRishtaCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share premium biodata image card with QR code on WhatsApp'**
  String get whatsAppRishtaCardSubtitle;

  /// No description provided for @whatsAppRishtaCardTitle.
  ///
  /// In en, this message translates to:
  /// **'🚩 WhatsApp Rishta Card (Image + QR)'**
  String get whatsAppRishtaCardTitle;

  /// No description provided for @whatsAppStatusCardPremium.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Status Card (Premium)'**
  String get whatsAppStatusCardPremium;

  /// No description provided for @whatsappHelp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Help'**
  String get whatsappHelp;

  /// No description provided for @whatsappShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share {name} details with family or friends'**
  String whatsappShareSubtitle(String name);

  /// No description provided for @whatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupport;

  /// No description provided for @wheatish.
  ///
  /// In en, this message translates to:
  /// **'Wheatish'**
  String get wheatish;

  /// No description provided for @whereDoYouWork.
  ///
  /// In en, this message translates to:
  /// **'Where do you work?'**
  String get whereDoYouWork;

  /// No description provided for @whoIsThisForQuestion.
  ///
  /// In en, this message translates to:
  /// **'Who are you searching for?'**
  String get whoIsThisForQuestion;

  /// No description provided for @whoViewedMe.
  ///
  /// In en, this message translates to:
  /// **'Who Viewed Me'**
  String get whoViewedMe;

  /// No description provided for @whyBanjaraBio.
  ///
  /// In en, this message translates to:
  /// **'Why BanjaraBio?'**
  String get whyBanjaraBio;

  /// No description provided for @widowed.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get widowed;

  /// No description provided for @women.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get women;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get working;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @writeAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Write something about yourself...'**
  String get writeAboutYourself;

  /// No description provided for @writeCustomBlessing.
  ///
  /// In en, this message translates to:
  /// **'Write Custom Blessing / Deity Name'**
  String get writeCustomBlessing;

  /// No description provided for @writeCustomBlessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type any family Kuldevi, Guru, or personalized deity mantra'**
  String get writeCustomBlessingSubtitle;

  /// No description provided for @writeYourOwnGenuineMessage.
  ///
  /// In en, this message translates to:
  /// **'Write your own genuine message or edit the selected template above:'**
  String get writeYourOwnGenuineMessage;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @yearsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Year} other{Years}}'**
  String yearsLabel(int count);

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} Years'**
  String yearsOld(String age);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @yesInterest.
  ///
  /// In en, this message translates to:
  /// **'Yes, Interest'**
  String get yesInterest;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @youNeedAProfileToShareIt.
  ///
  /// In en, this message translates to:
  /// **'You need a profile to share it.'**
  String get youNeedAProfileToShareIt;

  /// No description provided for @youSave.
  ///
  /// In en, this message translates to:
  /// **'You Save ₹{amount}'**
  String youSave(int amount);

  /// No description provided for @youWillNoLongerSeeThisProfile.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see this profile'**
  String get youWillNoLongerSeeThisProfile;

  /// No description provided for @youngerBrother.
  ///
  /// In en, this message translates to:
  /// **'Younger Brother'**
  String get youngerBrother;

  /// No description provided for @youngerSister.
  ///
  /// In en, this message translates to:
  /// **'Younger Sister'**
  String get youngerSister;

  /// No description provided for @your.
  ///
  /// In en, this message translates to:
  /// **'Your'**
  String get your;

  /// No description provided for @yourDailyMatches.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Matches'**
  String get yourDailyMatches;

  /// No description provided for @yourDocumentsAreEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Your documents are encrypted and never shown to other users. Only the badge is visible.'**
  String get yourDocumentsAreEncrypted;

  /// No description provided for @yourDocumentsHaveBeenSubmittedSecurelyWe.
  ///
  /// In en, this message translates to:
  /// **'Your documents have been submitted securely. We will notify you once verified.'**
  String get yourDocumentsHaveBeenSubmittedSecurelyWe;

  /// No description provided for @yourIntroVideoIsUnderReview10PointsPendi.
  ///
  /// In en, this message translates to:
  /// **'Your intro video is under review. +10 Points pending approval.'**
  String get yourIntroVideoIsUnderReview10PointsPendi;

  /// No description provided for @yourMatchesWillAppearHereOnceYouBothExpr.
  ///
  /// In en, this message translates to:
  /// **'Your matches will appear here once you both express interest. Keep sharing profiles to find your perfect match!'**
  String get yourMatchesWillAppearHereOnceYouBothExpr;

  /// No description provided for @yourPersonalInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Invite Link'**
  String get yourPersonalInviteLink;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get yourReferralCode;

  /// No description provided for @yourSelfieHasBeenSubmittedOurTeamWillVer.
  ///
  /// In en, this message translates to:
  /// **'Your selfie has been submitted. Our team will verify it against your profile photo.'**
  String get yourSelfieHasBeenSubmittedOurTeamWillVer;

  /// No description provided for @yourSuccessStory.
  ///
  /// In en, this message translates to:
  /// **'Your Success Story'**
  String get yourSuccessStory;

  /// No description provided for @yourTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Your Trust Score'**
  String get yourTrustScore;

  /// No description provided for @yrs.
  ///
  /// In en, this message translates to:
  /// **'{count} Yrs'**
  String yrs(int count);

  /// No description provided for @zeroPercentCommission.
  ///
  /// In en, this message translates to:
  /// **'💰 0% Commission'**
  String get zeroPercentCommission;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn', 'mr', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
