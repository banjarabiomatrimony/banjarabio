// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get genderSelectHeading => 'तुमचे लिंग';

  @override
  String get replacePhoto => 'फोटो बदला';

  @override
  String get errorLoadingAdminStats =>
      'डॅशबोर्ड आकडेवारी लोड करण्यात अक्षम. कृपया रिफ्रेश करण्याचा प्रयत्न करा.';

  @override
  String get errorLoadingAdminUsers =>
      'वापरकर्ता सूची प्राप्त होऊ शकली नाही. कृपया तुमचे कनेक्शन तपासा.';

  @override
  String get errorLoadingAdminPayments =>
      'पेमेंट इतिहास लोड करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorLoadingAdminVerifications =>
      'सत्यापन विनंत्या लोड होऊ शकल्या नाहीत. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorLoadingAdminReferences =>
      'लंबित संदर्भ प्राप्त करण्यात अक्षम. कृपया रिफ्रेश करा.';

  @override
  String get errorLoadingAdminCoupons =>
      'कूपन ऑफर लोड करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorLoadingAdminCreators =>
      'निर्माता सूची प्राप्त होऊ शकली नाही. कृपया तुमचे नेटवर्क तपासा.';

  @override
  String get errorAdminActionFailed =>
      'विनंती केलेली क्रिया पूर्ण होऊ शकली नाही. कृपया नंतर पुन्हा प्रयत्न करा.';

  @override
  String get expressInterest => 'रुची व्यक्त करायची?';

  @override
  String interestConfirmationDesc(String name) {
    return 'तुमची रुची दाखवण्यासाठी तुम्ही तुमची प्रोफाइल $name सोबत शेअर करू इच्छिता का?';
  }

  @override
  String get yesInterest => 'हो, रुची आहे';

  @override
  String get interest => 'रुची';

  @override
  String get revenueToday => 'आजचे उत्पन्न (₹)';

  @override
  String get premiumMen => 'प्रीमियम पुरुष';

  @override
  String get premiumWomen => 'प्रीमियम महिला';

  @override
  String get financialPerformance => 'वित्तीय कामगिरी';

  @override
  String get demographicsAndPremium => 'लोकसंख्याशास्त्र आणि प्रीमियम';

  @override
  String get revenueTotal => 'एकूण महसूल (₹)';

  @override
  String get monthlyRevenue => 'मासिक महसूल (₹)';

  @override
  String get pdfRevenue => 'PDF महसूल (₹)';

  @override
  String get userEngagement => 'वापरकर्ता सहभाग';

  @override
  String get dailyActiveUsers => 'दैनंदिन सक्रिय वापरकर्ते';

  @override
  String get profileViews => 'प्रोफाइल दृश्ये';

  @override
  String get totalMessages => 'एकूण संदेश';

  @override
  String get safetyAndHealth => 'सुरक्षा आणि आरोग्य';

  @override
  String get pendingReports => 'लंबित अहवाल';

  @override
  String get totalBlocks => 'एकूण ब्लॉक्स';

  @override
  String get pendingReferences => 'लंबित संदर्भ';

  @override
  String get totalUsers => 'एकूण वापरकर्ते';

  @override
  String get profiles => 'प्रोफाइल्स';

  @override
  String get appGrowth => 'अॅप प्रगती';

  @override
  String get completedReferrals => 'पूर्ण झालेले रेफरल्स';

  @override
  String get activeCreators => 'सक्रिय निर्माते';

  @override
  String get totalFemales => 'एकूण महिला';

  @override
  String get totalMales => 'एकूण पुरुष';

  @override
  String get men => 'पुरुष';

  @override
  String get women => 'महिला';

  @override
  String get sharingProfiles => 'प्रोफाईल शेअरिंग';

  @override
  String get sharingProfile => 'प्रोफाईल शेअर होत आहे...';

  @override
  String get referenceVerified => 'संदर्भ सत्यापित';

  @override
  String get referenceRejected => 'संदर्भ नाकारला';

  @override
  String get aboutSelf => 'स्वतःबद्दल';

  @override
  String get aboutYourself => 'स्वतःबद्दल';

  @override
  String get abusiveBehavior => 'अपमानकारक वागणूक';

  @override
  String get account => 'खाते';

  @override
  String get accountAndAllDataDeletedSuccessfully =>
      'खाते आणि सर्व डेटा यशस्वीरित्या हटवला.';

  @override
  String get accountDeletion => 'खाते हटवणे';

  @override
  String get actionIsIrreversible => 'ही क्रिया अपरिवर्तनीय आहे.';

  @override
  String get activeSubscriptionCancelledNoRefund =>
      'तुमची सक्रिय सदस्यता कोणत्याही परताव्याशिवाय रद्द केली जाईल.';

  @override
  String get adFreeExperience => 'जाहिरात-मुक्त अनुभव';

  @override
  String addClearPhotos(int max) {
    return 'स्पष्ट फोटो जोडा (जास्तीत जास्त $max)';
  }

  @override
  String get addPhoto => 'फोटो जोडा';

  @override
  String get addPhotosToYourBiodataProfileToIncreaseV =>
      'दृश्यमानता और विश्वास वाढवण्यासाठी तुमच्या बायोडेटा प्रोफाइलमध्ये फोटो जोडा';

  @override
  String get addSibling => 'भाऊ-बहीण जोडा';

  @override
  String get addTwoReferences => 'दोन संदर्भ जोडा';

  @override
  String get addYourBrothersAndSisters => 'तुमच्या भावा-बहिणींना जोडा';

  @override
  String get addYourFirstPhoto => 'तुमचा पहिला फोटो जोडा';

  @override
  String get additionalPreferences => 'अतिरिक्त प्राधान्ये';

  @override
  String get additionalProfessionalInfo => 'अतिरिक्त व्यावसायिक माहिती';

  @override
  String get adjust => 'समायोजित करा';

  @override
  String get adjustFilters => 'फिल्टर समायोजित करा';

  @override
  String get adminDashboard => 'प्रशासक डॅशबोर्ड';

  @override
  String get adminLogin => 'अ‍ॅडमीन लॉगिन';

  @override
  String get adminLoginRequiresAuthorizedCredentials =>
      'प्रशासक लॉगिनसाठी अधिकृत क्रेडेन्शियल्स आवश्यक आहेत';

  @override
  String get adminManagement => 'प्रशासकीय व्यवस्थापन';

  @override
  String get adminPortal => 'प्रशासन पोर्टल';

  @override
  String get advancedFilters => 'प्रगत फिल्टर';

  @override
  String get affluent => 'संपन्न';

  @override
  String get age => 'वय';

  @override
  String get ageRange => 'वय श्रेणी';

  @override
  String get aiBio => 'AI बायो';

  @override
  String allInDistrict(String district) {
    return '$district मधील सर्व';
  }

  @override
  String get allInSelectedDistrict => 'निवडलेल्या जिल्ह्यातील सर्व';

  @override
  String get allInSelectedState => 'निवडलेल्या राज्यातील सर्व';

  @override
  String allInState(String state) {
    return '$state मधील सर्व';
  }

  @override
  String get allIndia => 'संपूर्ण भारत';

  @override
  String allPhotosCount(int count, int max) {
    return 'सर्व फोटो ($count/$max)';
  }

  @override
  String get allYourProfileDataPermanentlyRemoved =>
      'तुमचा सर्व प्रोफाइल डेटा कायमचा काढला जाईल.';

  @override
  String get almostDone => 'जवळजवळ पूर्ण झाले!';

  @override
  String get almostDoneReview =>
      'सर्व विभागांचे पुनरावलोकन करा आणि तुमचे प्रोफाइल पूर्ण करण्यासाठी \"बायोडेटा जतन करा\" वर क्लिक करा. तुमचा बायोडेटा तुमच्या गोपनीयता सेटिंग्जवर आधारित समुदायातील इतर सदस्यांना दिसेल.';

  @override
  String anErrorOccurred(String error) {
    return 'त्रुटी आली: $error';
  }

  @override
  String get and => ' आणि ';

  @override
  String get annualIncome => 'स्वतःचे वार्षिक उत्पन्न (Self Annual Income)';

  @override
  String get annualIncomeHint =>
      'तुमचे एका वर्षाचे उत्पन्न (पगार/व्यवसाय)। कुटुंबाची एकूण बचत किंवा बँक बॅलन्स लिहू नका.';

  @override
  String get annulled => 'रद्द केलेले';

  @override
  String get appName => 'बंजारा बायो';

  @override
  String get applyFilters => 'फिल्टर लागू करा';

  @override
  String get approve => 'मंजूर करा';

  @override
  String get areYouReadyForDiscussions => 'तुम्ही चर्चेसाठी तयार आहात का?';

  @override
  String areYouSureDeleteSelectedPhotos(int count) {
    return 'तुम्हाला खात्री आहे की तुम्ही $count फोटो हटवू इच्छिता?';
  }

  @override
  String get areYouSureExit =>
      'तुम्हाला खात्री आहे की तुम्ही अॅप बंद करू इच्छिता?';

  @override
  String get areYouSureLogout =>
      'तुम्हाला खात्री आहे की तुम्ही लॉगआउट करू इच्छिता?';

  @override
  String get areYouSureYouWantToBlockThisUserYouWillN =>
      'तुमची खात्री आहे की तुम्ही या वापरकर्त्याला ब्लॉक करू इच्छिता? तुम्ही त्यांचे प्रोफाइल पुन्हा पाहू शकणार नाही.';

  @override
  String get areYouSureYouWantToDeleteThisPhoto =>
      'तुमची खात्री आहे की तुम्ही हा फोटो हटवू इच्छिता?';

  @override
  String get areYouSureYouWantToDeleteYourAccount =>
      'तुमची खात्री आहे की तुम्ही तुमचे खाते हटवू इच्छिता?';

  @override
  String get askFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get atLeastOnePhotoRequired => 'कमीतकमी एक फोटो आवश्यक आहे';

  @override
  String get awaitingDivorce => 'घटस्फोट प्रतीक्षित';

  @override
  String get bachelorsDegree => 'बॅचलर पदवी';

  @override
  String get back => 'मागे';

  @override
  String get backSide => 'मागील बाजू';

  @override
  String get backToGoogleSignIn => 'Google साइन इन वर परत';

  @override
  String get banjaraMember => 'बंजारा सदस्य';

  @override
  String get banjarabio => 'बंजाराबायो';

  @override
  String get biodataDraftRestored => 'बायोडेटा मसुदा पुनर्संचयित केला!';

  @override
  String get biodataDraftRestoredSuccess =>
      'बायोडेटा मसुदा यशस्वीरित्या पुनर्संचयित केला!';

  @override
  String get biodataPdf => 'बायोडाटा PDF';

  @override
  String get biodataSavedSuccessfully => 'बायोडाटा यशस्वीरित्या सेव्ह झाला!';

  @override
  String get biodataUnlockPlanDesc =>
      'प्रोफेशनल प्रीमियम टेम्प्लेट्स अनलॉक करा';

  @override
  String get biodataUnlockPlanName => 'बायोडेटा प्रीमियम';

  @override
  String get birthDetails => 'अतिरिक्त जन्म तपशील';

  @override
  String get birthPlace => 'जन्मस्थान';

  @override
  String get birthPlaceAndTime => 'जन्म स्थान आणि वेळ';

  @override
  String get birthTime => 'जन्मवेळ';

  @override
  String get block => 'ब्लॉक करा';

  @override
  String get blockUser => 'वापरकर्ता अवरोधित करा';

  @override
  String get bloodGroup => 'रक्तगट';

  @override
  String get blurryLowQualityImages =>
      'अस्पष्ट, गडद किंवा कमी दर्जाच्या प्रतिमा';

  @override
  String get bookmarkLimitReached => 'बुकमार्क मर्यादा गाठली';

  @override
  String get messagingLimitReached => 'संदेश मर्यादा संपली';

  @override
  String bookmarksCount(int count) {
    return '$count बुकमार्क';
  }

  @override
  String get bronze => 'कांस्य';

  @override
  String get brother => 'भाऊ';

  @override
  String get brotherCount => 'भाऊ';

  @override
  String get browseProfiles => 'प्रोफाइल ब्राउझ करा';

  @override
  String get business => 'व्यवसाय';

  @override
  String get businessOwner => 'व्यवसाय मालक';

  @override
  String get byContAcceptTerms => 'पुढे जाऊन, तुम्ही आमच्या ';

  @override
  String get camera => 'कॅमेरा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get cancelAnytime => 'कधीही रद्द करा';

  @override
  String get changeLanguage => 'भाषा बदला';

  @override
  String get chat => 'चॅट';

  @override
  String get checkBackSoonForNewMatchesnpullDownToRef =>
      'नवीन जुळण्यांसाठी लवकरच परत तपासा.\\nरीफ्रेश करण्यासाठी खाली खेचा.';

  @override
  String get checkInbox => 'इनबॉक्स तपासा';

  @override
  String get checkInternet =>
      'कृपया तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get checkWhoIsLookingAtYourProfile =>
      'तुमचे प्रोफाइल कोण पाहत आहे ते तपासा';

  @override
  String get chooseFromGallery => 'गॅलरीतून निवडा';

  @override
  String get chooseTemplate => 'टेम्पलेट निवडा';

  @override
  String get clear => 'साफ करा';

  @override
  String get clearAllFilters => 'सर्व फिल्टर साफ करा';

  @override
  String get clearWellLitPhotos =>
      'तुमचा चेहरा स्पष्टपणे दिसणारे स्पष्ट आणि चांगले प्रकाश असलेले फोटो';

  @override
  String get close => 'बंद करा';

  @override
  String get comeBackTomorrowFornnewCuratedMatches =>
      'नवीन क्युरेट केलेल्या सामन्यांसाठी\\nउद्या परत या!';

  @override
  String get communityId => 'समाज ओळखपत्र (ID)';

  @override
  String get communityIdSubmitted => 'समुदाय आयडी सबमिट केला';

  @override
  String get communityIdVerification => 'समुदाय ओळखपत्र';

  @override
  String get communityMember => 'समाज सदस्य';

  @override
  String get communityVerification => 'समुदाय पडताळणी';

  @override
  String get companyName => 'कंपनीचे नाव';

  @override
  String get completeVerificationToUnlockPremium =>
      '\'प्रीमियम\' दर्जा अनलॉक करण्यासाठी पडताळणी पूर्ण करा.';

  @override
  String get completeYourProfileToGetNoticed =>
      'लक्षात येण्यासाठी तुमचे प्रोफाइल पूर्ण करा!';

  @override
  String get completion => 'पूर्ण';

  @override
  String get complexion => 'वर्ण';

  @override
  String get compressingUnder500Kb => '५००KB पेक्षा कमी आकार करत आहे...';

  @override
  String get confirm => 'पुष्टी करा';

  @override
  String get connectInApp => 'इन-अॅप कनेक्ट';

  @override
  String get connectWithCommunity => 'आपल्या बंजारा समुदायाशी जोडा';

  @override
  String get contact => 'संपर्क';

  @override
  String get contactPreferences => 'संपर्क प्राधान्ये';

  @override
  String get contactUs => 'आमच्याशी संपर्क साधा';

  @override
  String get contactUsTitle => 'आमच्याशी संपर्क साधा';

  @override
  String get continueWithFreeAccount => 'मोफत खाते सुरू ठेवा';

  @override
  String get continueWithGoogle => 'Google सह सुरू ठेवा';

  @override
  String get conversations => 'संभाषणे';

  @override
  String get copyLink => 'लिंक कॉपी करा';

  @override
  String copyLinkSubtitle(String name) {
    return '$name च्या प्रोफाइलची लिंक कॉपी करा';
  }

  @override
  String get couldNotLoadProfile =>
      'आम्ही तुमचे प्रोफाइल लोड करू शकलो नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get createBiodata => 'बायोडाटा तयार करा';

  @override
  String get createProfile => 'प्रोफाइल तयार करा';

  @override
  String criticalFailure(String error) {
    return 'गंभीर अपयश: $error';
  }

  @override
  String get cropPhoto => 'फोटो क्रॉप करा';

  @override
  String get cropRotate => 'क्रॉप आणि फिरवा';

  @override
  String curatedProfilesJustForYou(int count) {
    return '$count तुमच्यासाठी निवडलेले प्रोफाइल्स';
  }

  @override
  String get currentLocation => 'सध्याचे ठिकाण';

  @override
  String get currentPlan => 'सध्याचा प्लॅन';

  @override
  String get currentResidenceState => 'वर्तमान निवास राज्य';

  @override
  String get currentVillageHint => 'सध्याचे गाव';

  @override
  String get customizeBiodata => 'बायोडेटा सानुकूलित करा';

  @override
  String get daily => 'दैनिक';

  @override
  String get dailyMatch => 'दैनिक सामना';

  @override
  String get dark => 'काळा';

  @override
  String get dateOfBirth => 'जन्मतारीख';

  @override
  String get daughter => 'मुलगी';

  @override
  String daysAgo(int count) {
    return '$countदि पूर्वी';
  }

  @override
  String daysLeft(int days) {
    return '$days दिवस शिल्लक';
  }

  @override
  String daysRemaining(int days) {
    return '$days दिवस शिल्लक';
  }

  @override
  String get delete => 'हटवा';

  @override
  String get deleteAccount => 'खाते हटवा';

  @override
  String get deleteAccountWarning =>
      'ही क्रिया कायमस्वरूपी आहे आणि पूर्ववत करता येणार नाही.';

  @override
  String deleteCount(int count) {
    return 'हटवा ($count)';
  }

  @override
  String get deleteMyAccount => 'माझे खाते हटवा';

  @override
  String get deletePhoto => 'फोटो हटवा';

  @override
  String get deletePhotos => 'फोटो हटवा';

  @override
  String deleteSelectedSharesQuery(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'तुम्हाला $count निवडलेले शेअर्स हटवायचे आहेत का?',
      one: 'तुम्हाला निवडलेला शेअर हटवायचा आहे का?',
    );
    return '$_temp0';
  }

  @override
  String get deleteShares => 'शेअर्स हटवा';

  @override
  String get deletingYourAccountWillResultIn =>
      'तुमचे खाते हटवल्याने पुढील गोष्टी होतील:';

  @override
  String get demo => 'डेमो';

  @override
  String get describeYourselfInterestsHobbies =>
      'स्वतःचे, आवडी, छंद यांचे वर्णन करा...';

  @override
  String get details => 'तपशील';

  @override
  String get differentSettingsTip =>
      'वेगवेगळ्या सेटिंग्जमधील फोटो समाविष्ट करा (औपचारिक, प्रासंगिक)';

  @override
  String get diploma => 'डिप्लोमा';

  @override
  String get directMessaging => 'थेट संदेश';

  @override
  String get disabledHint => 'अपंग व्यक्तींसाठी पर्यायी माहिती';

  @override
  String get disabledTagLabel => 'अपंग';

  @override
  String get discard => 'रद्द करा';

  @override
  String get discardChanges => 'बदल रद्द करायचे?';

  @override
  String get discardChangesBody =>
      'तुम्हाला खात्री आहे की तुम्ही मागे जाऊ इच्छिता? तुमची प्रगती ड्राफ्ट म्हणून सेव्ह केली आहे.';

  @override
  String discountPercentage(int percentage, int score) {
    return '$percentage% सूट (ट्रस्ट स्कोर $score)';
  }

  @override
  String get discoverProfilesFromYourCommunityNsmartM =>
      'तुमच्या समुदायातील प्रोफाइल शोधा.\\nसुसंगतता स्कोअरद्वारे समर्थित स्मार्ट मॅचमेकिंग.';

  @override
  String get district => 'जिल्हा';

  @override
  String districtInState(String state) {
    return '$state मधील जिल्हा';
  }

  @override
  String get districtInStateLabel => 'राज्यातील जिल्हा';

  @override
  String get divorced => 'घटस्फोटित';

  @override
  String get doctorate => 'डॉक्टरेट';

  @override
  String get documentProofs => 'दस्तऐवज पुरावे:';

  @override
  String get documentType => 'दस्तऐवज प्रकार';

  @override
  String get documentView => 'दस्तऐवज दृश्य';

  @override
  String get done => 'पूर्ण';

  @override
  String get downloadBtn => 'डाउनलोड करा';

  @override
  String get dusky => 'सावळा';

  @override
  String get easiest => 'सोपे';

  @override
  String get edit => 'संपादित करा';

  @override
  String get editProfile => 'प्रोफाइल संपादित करा';

  @override
  String get education => 'शिक्षण';

  @override
  String get educationAndProfession => 'शिक्षण आणि व्यवसाय';

  @override
  String get educationDetails => 'शिक्षण तपशील';

  @override
  String get educationLabel => 'शिक्षण';

  @override
  String get educationProfession => 'शिक्षण आणि व्यवसाय';

  @override
  String get educationProfessionDetails => 'शिक्षण आणि करिअर';

  @override
  String get educationalQualification => 'शैक्षणिक पात्रता';

  @override
  String get egSeniorSoftwareEngineer => 'उदा. सीनियर सॉफ्टवेअर इंजिनीअर';

  @override
  String get egSpecialization => 'उदा. विशेषीकरण किंवा ऑनर्स';

  @override
  String get egSpecializationOrHonors => 'उदा. विशेषीकरण किंवा सन्मान';

  @override
  String get egTime => 'उदा. सकाळी १०:३० वाजता';

  @override
  String get elderBrother => 'मोठा भाऊ';

  @override
  String get elderSister => 'मोठी बहीण';

  @override
  String get email => 'ईमेल';

  @override
  String get emailAddress => 'ईमेल पत्ता';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get emailSupport => 'ईमेल समर्थन';

  @override
  String get emailVerification => 'ईमेल सत्यापन';

  @override
  String get emailVerificationTip =>
      'टीप: तुम्हाला ईमेल न दिसल्यास स्पॅम फोल्डर तपासा.';

  @override
  String get emailVerifiedSuccessfully10Points =>
      'ईमेल यशस्वीरित्या सत्यापित! +10 गुण';

  @override
  String get emptyStr => '₹';

  @override
  String get english => 'English';

  @override
  String get enterBasicInfo =>
      'तुमची मूलभूत माहिती अधिकृत कागदपत्रांप्रमाणे प्रविष्ट करा';

  @override
  String get enterCityVillage => 'शहर/गाव प्रविष्ट करा';

  @override
  String get enterEducationDetails => 'तुमचे शिक्षण तपशील प्रविष्ट करा';

  @override
  String get enterFullName => 'तुमचे पूर्ण नाव प्रविष्ट करा';

  @override
  String get enterMobileNumber => 'मोबाईल नंबर टाका';

  @override
  String get enterProfessionDetails => 'तुमचे व्यवसाय तपशील प्रविष्ट करा';

  @override
  String get enterYourBasicInformationAsItAppearsInOf =>
      'तुमची मूलभूत माहिती अधिकृत कागदपत्रांमध्ये दिसते तशी प्रविष्ट करा';

  @override
  String get enterYourEducationDetails => 'तुमच्या शिक्षणाची माहिती टाका';

  @override
  String get enterYourEmail => 'तुमचा ईमेल प्रविष्ट करा';

  @override
  String get enterYourPassword => 'तुमचा पासवर्ड प्रविष्ट करा';

  @override
  String get enterYourProfessionDetails => 'तुमच्या व्यवसायाची माहिती टाका';

  @override
  String get error => 'त्रुटी';

  @override
  String errorCheckingShareLimits(String error) {
    return 'शेअर मर्यादा तपासताना त्रुटी: $error';
  }

  @override
  String errorCheckingStatus(String error) {
    return 'स्थिती तपासण्यात त्रुटी: $error';
  }

  @override
  String errorCheckingViewLimits(String error) {
    return 'दृश्य मर्यादा तपासताना त्रुटी: $error';
  }

  @override
  String errorLoadingAdminData(String error) {
    return 'अ‍ॅडमिन डेटा लोड करताना त्रुटी: $error';
  }

  @override
  String errorLoadingRequests(String error) {
    return 'विनंत्या लोड करताना त्रुटी: $error';
  }

  @override
  String errorOccurred(String error) {
    return 'एक त्रुटी आली: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String get everyProfileIsVerifiedWithIdSelfieRefere =>
      'प्रत्येक प्रोफाईल आयडी, सेल्फी आणि संदर्भांसह सत्यापित केले जाते.\\nट्रस्ट स्कोअर वास्तविक कनेक्शन सुनिश्चित करते.';

  @override
  String get exit => 'बाहेर पडा';

  @override
  String get exitApp => 'अॅप बंद करा';

  @override
  String get exportBiodataPdf => 'बायोडेटा PDF निर्यात करा';

  @override
  String get expressInterestDesc =>
      'तुमचा बायोडाटा थेट शेअर करून तुमची आवड व्यक्त करा';

  @override
  String failedLoadProfile(String error) {
    return 'प्रोफाइल लोड करता आले नाही: $error';
  }

  @override
  String failedSignInGoogle(String error) {
    return 'Google सह साइन इन अयशस्वी: $error';
  }

  @override
  String get failedSignInGoogleRetry =>
      'Google सह साइन इन अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String failedToBlockUser(String error) {
    return 'वापरकर्त्याला ब्लॉक करण्यात अयशस्वी: $error';
  }

  @override
  String failedToDeleteAccount(String error) {
    return 'खाते हटवण्यात अयशस्वी: $error';
  }

  @override
  String failedToDeletePhotoError(String error) {
    return 'फोटो हटवण्यात अयशस्वी: $error';
  }

  @override
  String get failedToGeneratePdfPreview =>
      'PDF पूर्वावलोकन व्युत्पन्न करण्यात अयशस्वी';

  @override
  String failedToLoadBookmarks(String error) {
    return 'बुकमार्क लोड करण्यात अयशस्वी: $error';
  }

  @override
  String failedToLoadPhotosError(String error) {
    return 'फोटो लोड करण्यात अयशस्वी: $error';
  }

  @override
  String failedToLoadProfileError(String error) {
    return 'प्रोफाइल लोड करण्यात अयशस्वी: $error';
  }

  @override
  String get failedToLoadProfileInformation =>
      'प्रोफाइल माहिती लोड करण्यात अयशस्वी';

  @override
  String get failedToLoadProfiles => 'प्रोफाइल लोड करण्यात अयशस्वी';

  @override
  String get failedToLoadReferralData => 'रेफरल डेटा लोड करण्यात अयशस्वी';

  @override
  String failedToLoadSubscription(String error) {
    return 'सदस्यत्व लोड करण्यात अयशस्वी: $error';
  }

  @override
  String get failedToLoadTrustScoreStats =>
      'ट्रस्ट स्कोअरची आकडेवारी लोड करण्यात अयशस्वी';

  @override
  String failedToLogout(String error) {
    return 'लॉगआउट अयशस्वी: $error';
  }

  @override
  String get failedToPrintPdf => 'PDF मुद्रित करण्यात अयशस्वी';

  @override
  String get failedToProcessImage => 'प्रतिमेवर प्रक्रिया करण्यात अयशस्वी';

  @override
  String failedToSave(String error) {
    return 'सेव्ह करता आले नाही: $error';
  }

  @override
  String failedToSavePdf(String error) {
    return 'PDF सेव्ह करण्यात अयशस्वी: $error';
  }

  @override
  String failedToSaveProfile(String error) {
    return 'प्रोफाइल सेव्ह करता आले नाही: $error';
  }

  @override
  String get failedToSharePdf => 'PDF शेअर करण्यात अयशस्वी';

  @override
  String failedToStartChat(String error) {
    return 'चॅट सुरू करण्यात अयशस्वी: $error';
  }

  @override
  String failedToSubmitReport(String error) {
    return 'रिपोर्ट सबमिट करण्यात अयशस्वी: $error';
  }

  @override
  String failedToUpdateBookmark(String error) {
    return 'बुकमार्क अपडेट करण्यात अयशस्वी: $error';
  }

  @override
  String failedToUpdatePremiumStatus(String error) {
    return 'प्रीमियम स्थिती अपडेट करण्यात अयशस्वी: $error';
  }

  @override
  String failedToUpdatePrimaryPhotoError(String error) {
    return 'प्राथमिक फोटो अपडेट करण्यात अयशस्वी: $error';
  }

  @override
  String get failedToUpdateProfile => 'प्रोफाईल अपडेट करण्यात अयशस्वी';

  @override
  String failedToUploadPhoto(String index) {
    return 'फोटो $index अपलोड करता आला नाही';
  }

  @override
  String failedToVerify(String error) {
    return 'सत्यापित करण्यात अयशस्वी: $error';
  }

  @override
  String get fair => 'गोरा';

  @override
  String get fakeProfile => 'बनावट प्रोफाइल';

  @override
  String get familyBackground => 'कौटुंबिक पार्श्वभूमी';

  @override
  String get familyDetails => 'कौटुंबिक माहिती';

  @override
  String get familyFirstValues => 'कुटुंब-प्रथम मूल्ये';

  @override
  String get familyOnly => 'फक्त कुटुंब';

  @override
  String get familyStatus => 'कुटुंब स्थिती';

  @override
  String get familyType => 'कुटुंबाचा प्रकार';

  @override
  String get faqA1 =>
      'प्रोफाइल टॅबवर जा आणि \"बायोडाटा तयार करा\" वर क्लिक करा किंवा तुमच्या विद्यमान प्रोफाइलमध्ये बदल करा. तुमचे वैयक्तिक, कौटुंबिक आणि व्यावसायिक तपशील भरण्यासाठी बहु-चरण फॉर्मचे अनुसरण करा.';

  @override
  String get faqA2 =>
      'होय, आम्ही गोपनीयतेला गांभीर्याने घेतो. तुमचे संपर्क तपशील केवळ सत्यापित वापरकर्त्यांना दाखवले जातात आणि आमच्या समुदाय सुरक्षा मार्गदर्शक तत्त्वांचा आदर करतात.';

  @override
  String get faqA3 =>
      'होम स्क्रीनवर, वय, स्थान, शिक्षण आणि व्यवसायानुसार प्रोफाइल मर्यादित करण्यासाठी \"फिल्टर\" बटण वापरा.';

  @override
  String get faqA4 =>
      'प्रीमियम वापरकर्त्यांना अमर्यादित प्रोफाइल व्ह्यूज, नवीन बायोडाटावर लवकर प्रवेश आणि शोध परिणामांमध्ये वर्धित दृश्यमानता मिळते.';

  @override
  String get faqA5 =>
      'तुमच्या प्रोफाइल आणि डेटाला आमच्या सिस्टममधून कायमस्वरूपी काढून टाकण्यासाठी माझे प्रोफाइल > कायदेशीर आणि माहिती > खाते हटवणे निवडा.';

  @override
  String get faqQ1 => 'मी बायोडाटा कसा तयार करू?';

  @override
  String get faqQ2 => 'माझा डेटा सुरक्षित आहे का?';

  @override
  String get faqQ3 => 'मी प्रोफाइल कसे फिल्टर करू शकतो?';

  @override
  String get faqQ4 => 'प्रीमियमचे फायदे काय आहेत?';

  @override
  String get faqQ5 => 'मी माझे खाते कसे हटवू?';

  @override
  String get faqTitle => 'वारंवार विचारले जाणारे प्रश्न';

  @override
  String get faqs => 'वारंवार विचारले जाणारे प्रश्न';

  @override
  String get farmer => 'शेतकरी';

  @override
  String get fatherName => 'वडिलांचे नाव';

  @override
  String get fatherOccupation => 'वडिलांचा व्यवसाय';

  @override
  String get feet => 'फूट';

  @override
  String get female => 'स्त्री';

  @override
  String fieldRequired(String field) {
    return '$field आवश्यक आहे';
  }

  @override
  String get fifteenToTwentyLakh => '₹१५ लाख - ₹२० लाख';

  @override
  String get filtered => '(फिल्टर केलेले)';

  @override
  String get findYourPerfectMatch => 'तुमची परिपूर्ण जुळणी शोधा';

  @override
  String get fiveToSevenHalfLakh => '₹५ लाख - ₹७.५ लाख';

  @override
  String get followAndGetFivePercent => 'फॉलो करा आणि +५% मिळवा';

  @override
  String get followUsOnInstagramBonus =>
      '५% बायोडेटा पूर्ण बोनस मिळवण्यासाठी आणि नवीन मॅचसह अपडेट राहण्यासाठी आम्हाला इंस्टाग्रामवर फॉलो करा.';

  @override
  String forMonths(int count) {
    return '$count महिन्यांसाठी';
  }

  @override
  String get free => 'मोफत';

  @override
  String get free1PhotonpremiumUpTo6Photos =>
      'विनामूल्य: 1 फोटो\\nप्रीमियम: कमाल 6 फोटो';

  @override
  String get freePlanDesc => 'मूळ वैशिष्ट्ये वापरून पहा';

  @override
  String get freeUserLimitInfo =>
      'मोफत वापरकर्ता मर्यादा संपली. सुरू ठेवण्यासाठी अपग्रेड करा.';

  @override
  String get freeUsersCanUpload1PhotoUpgradeToUploadU =>
      'विनामूल्य वापरकर्ते 1 फोटो अपलोड करू शकतात. 5 पर्यंत फोटो अपलोड करण्यासाठी अपग्रेड करा.';

  @override
  String get friend => 'मित्र';

  @override
  String get frontSide => 'समोरील बाजू';

  @override
  String get fullName => 'पूर्ण नाव';

  @override
  String get gallery => 'गॅलरी';

  @override
  String get gender => 'लिंग';

  @override
  String get generateBio => 'बायो तयार करा';

  @override
  String get generatingPreview => 'पूर्वावलोकन व्युत्पन्न करत आहे...';

  @override
  String get getAProfessionalWellformattedPdfWithoutW =>
      'वॉटरमार्कशिवाय आणि सर्व तपशील दृश्यमान असलेले व्यावसायिक, सु-स्वरूपित PDF मिळवा.';

  @override
  String get getInTouchWithUs => 'आमच्याशी संपर्क साधा';

  @override
  String get getStarted => 'सुरुवात करा';

  @override
  String get getStartedLabel => 'सुरू करा';

  @override
  String get go => 'जा';

  @override
  String get goBack => 'परत जा';

  @override
  String get gold => 'सोने';

  @override
  String get goldPlanDesc => 'सर्वात लोकप्रिय - सर्वोत्तम मूल्य';

  @override
  String get goldPlanName => 'गोल्ड';

  @override
  String get goldVerified => 'गोल्ड व्हेरिफाईड';

  @override
  String get gotIt => 'समजले';

  @override
  String get gotra => 'गोत्र';

  @override
  String get governmentEmployee => 'शासकीय कर्मचारी';

  @override
  String get governmentId => 'सरकारी आयडी';

  @override
  String get governmentIdVerification => 'सरकारी आयडी पडताळणी';

  @override
  String get governmentIdVerificationSubtitle =>
      '\'Verified\' बॅज मिळवण्यासाठी तुमच्या आधार किंवा पॅनची अस्पष्ट प्रत अपलोड करा.';

  @override
  String get governmentJob => 'सरकारी नोकरी';

  @override
  String get govtId => 'शासकीय ओळखपत्र';

  @override
  String get govtIdVerification => 'सरकारी ओळखपत्र';

  @override
  String get graduate => 'पदवीधर';

  @override
  String get great => 'छान!';

  @override
  String get grid => 'ग्रिड';

  @override
  String get groupPhotosNotVisible =>
      'ग्रुप फोटो जिथे तुम्ही स्पष्टपणे दिसत नाही';

  @override
  String get growth => 'वाढ';

  @override
  String get haveQuestionsOrNeedAssistanceOurTeamIsHe =>
      'प्रश्न आहेत किंवा मदत हवी आहे? तुमची परिपूर्ण जुळणी शोधण्यात तुमची मदत करण्यासाठी आमची टीम येथे आहे.';

  @override
  String get heavilyFilteredEdited =>
      'जास्त फिल्टर केलेले किंवा संपादित केलेले फोटो';

  @override
  String get height => 'उंची';

  @override
  String get helpOurCommunityGrowAndUnlockPremiumRewa =>
      'आमच्या समुदायाला वाढण्यास मदत करा आणि स्वतःसाठी प्रीमियम रिवॉर्ड अनलॉक करा.';

  @override
  String get highSchool => 'हायस्कूल';

  @override
  String get hindi => 'हिंदी';

  @override
  String get home => 'मुख्यपृष्ठ';

  @override
  String get homemaker => 'गृहिणी';

  @override
  String hoursAgo(int count) {
    return '$countता पूर्वी';
  }

  @override
  String get howItWorks => 'ते कसे कार्य करते';

  @override
  String get iUnderstandThatThisActionCannotBeUndone =>
      'मला समजते की ही क्रिया पूर्ववत केली जाऊ शकत नाही.';

  @override
  String idLabel(String id) {
    return 'ID: $id';
  }

  @override
  String get idNumber => 'आयडी क्रमांक';

  @override
  String get idType => 'ओळखपत्राचा प्रकार';

  @override
  String get inappropriateBackgrounds => 'अयोग्य पार्श्वभूमी असलेले फोटो';

  @override
  String get inappropriateContentOrFakeProfile =>
      'अयोग्य सामग्री किंवा बनावट प्रोफाइल';

  @override
  String get inappropriatePhotos => 'अयोग्य फोटो';

  @override
  String get inches => 'इंच';

  @override
  String get increaseBiodataScore => 'बायोडेटा स्कोअर वाढवा!';

  @override
  String get increaseYourTrustScoreToConfirmYourIdent =>
      'तुमच्या ओळखीची पुष्टी करण्यासाठी आणि अनन्य सवलती अनलॉक करण्यासाठी तुमचा विश्वास स्कोअर वाढवा।';

  @override
  String get interestSent => 'स्वारस्य पाठवले';

  @override
  String get interestConfirmationTitle => 'रुची व्यक्त करायची?';

  @override
  String interestConfirmationMessage(String name) {
    return 'यामुळे तुमची प्रोफाइल $name सोबत शेअर केली जाईल आणि त्यांना तुमच्याशी संपर्क साधता येईल. तुम्हाला खात्री आहे का?';
  }

  @override
  String interestShared(String name) {
    return '$name सोबत रुची शेअर केली!';
  }

  @override
  String get introduceYourselfIn30SecondsTalkAboutYou =>
      '30 सेकंदात स्वतःचा परिचय करून द्या. तुमचे कुटुंब, व्यवसाय आणि अपेक्षांबद्दल बोला.';

  @override
  String get invalidEmailOrPassword => 'अवैध ईमेल किंवा पासवर्ड';

  @override
  String get inviteARelative => 'नातेवाईकांना आमंत्रित करा';

  @override
  String get inviteFriendsRewards =>
      'मित्रांना आमंत्रित करा आणि प्रीमियम बक्षिसे मिळवा!';

  @override
  String get inviteStep1 => 'पायरी १';

  @override
  String get inviteStep2 => 'पायरी २';

  @override
  String get inviteStep3 => 'पायरी ३';

  @override
  String get isDisabledPerson => 'तुम्ही अपंग आहात का?';

  @override
  String get jobDetails => 'नोकरीचे तपशील';

  @override
  String get joinMeOnBanjarabio => 'मला बंजाराबायो वर सामील व्हा';

  @override
  String get joinOurCommunity => 'आमच्या १०K+ समुदायात सामील व्हा!';

  @override
  String get jointFamily => 'संयुक्त कुटुंब';

  @override
  String get justNow => 'आत्ताच';

  @override
  String get kannada => 'ಕನ್ನಡ';

  @override
  String get keepBrowsing => 'ब्राउझ करत रहा';

  @override
  String get keywordSearch => 'कीवर्ड शोध';

  @override
  String get language => 'भाषा';

  @override
  String languageChanged(String language) {
    return 'भाषा $language मध्ये बदलली';
  }

  @override
  String get lastUpdatedJanuary2026 => 'शेवटचे अपडेट: जानेवारी 2026';

  @override
  String get legalAndInformation => 'कायदेशीर आणि माहिती';

  @override
  String get linkShare => 'लिंक शेअर करा';

  @override
  String get linkedInIntegration => 'LinkedIn एकत्रीकरण';

  @override
  String get linkedInIntegrationSubtitle =>
      'अधिक विश्वास निर्माण करण्यासाठी तुमचे व्यावसायिक प्रोफाइल कनेक्ट करा.';

  @override
  String get liveSelfie => 'लाइव्ह सेल्फी';

  @override
  String get liveSelfieVerification => 'थेट सेल्फी पडताळणी';

  @override
  String get livenessCheck => 'जिवंतपणा तपासा';

  @override
  String get loading => 'लोड होत आहे...';

  @override
  String get loadingAssets => 'मालमत्ता लोड करत आहे...';

  @override
  String get loadingProfile => 'तुमचे प्रोफाइल लोड करत आहे...';

  @override
  String get loadingViews => 'दृश्ये लोड करत आहे...';

  @override
  String get location => 'स्थान';

  @override
  String get locationDetails => 'स्थान तपशील';

  @override
  String get locationPreferences => 'स्थान आणि प्राधान्ये';

  @override
  String get locationPreview => 'स्थान पूर्वावलोकन';

  @override
  String get login => 'लॉगिन';

  @override
  String loginFailed(String error) {
    return 'लॉगिन अयशस्वी: $error';
  }

  @override
  String get loginFailedRetry => 'लॉगिन अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get loseMatchesAndSavedProfiles =>
      'तुम्ही तुमचे सर्व सामने आणि जतन केलेले प्रोफाइल गमावाल.';

  @override
  String get main => 'मुख्य';

  @override
  String get male => 'पुरुष';

  @override
  String get managePhotos => 'फोटो व्यवस्थापित करा';

  @override
  String get managenphotos => 'फोटो व्यवस्थापित करा';

  @override
  String get manualSelection => 'मॅन्युअल निवड';

  @override
  String get marathi => 'मराठी';

  @override
  String get maritalStatus => 'वैवाहिक स्थिती';

  @override
  String get maritalStatusLabel => 'वैवाहिक स्थिती';

  @override
  String get marriageReadiness => 'लग्नासाठी सज्जता';

  @override
  String get married => 'विवाहित';

  @override
  String get maskFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get mastersDegree => 'मास्टर पदवी';

  @override
  String matchNOfTotal(String current, String total) {
    return 'मॅच $current / $total';
  }

  @override
  String get matched => 'जुळले';

  @override
  String get sent => 'पाठवले';

  @override
  String get received => 'मिळाले';

  @override
  String get matchmakerConsultation => 'मॅचमेकर सल्लामसलत';

  @override
  String get matrimonyFor => 'विवाहासाठी';

  @override
  String get maxAge => 'कमाल वय';

  @override
  String get maybeLater => 'कदाचित नंतर';

  @override
  String get menu => 'मेनू';

  @override
  String get message => 'संदेश';

  @override
  String get messageUsOnWhatsapp => 'आम्हाला WhatsApp वर मेसेज करा';

  @override
  String get messages => 'संदेश';

  @override
  String get middleClass => 'मध्यमवर्गीय';

  @override
  String get minAge => 'किमान वय';

  @override
  String minutesAgo(int count) {
    return '$countमि पूर्वी';
  }

  @override
  String get mobileNumber => 'मोबाईल नंबर';

  @override
  String get mobileVerification => 'मोबाइल सत्यापन';

  @override
  String get mobileVerifiedSuccessfully10Points =>
      'मोबाइल यशस्वीरित्या सत्यापित! +10 गुण';

  @override
  String get month => '/ महिना';

  @override
  String get months => 'महिने';

  @override
  String get moreAboutYourStudiesAndWork =>
      'तुमच्या अभ्यासाबद्दल आणि कामाबद्दल अधिक सांगा';

  @override
  String get moreOptions => 'अधिक पर्याय';

  @override
  String get mostPopular => 'सर्वाधिक लोकप्रिय';

  @override
  String get motherName => 'आईचे नाव';

  @override
  String get motherOccupation => 'आईचा व्यवसाय';

  @override
  String get myProfile => 'माझी प्रोफाइल';

  @override
  String get name => 'नाव';

  @override
  String get nativePlace => 'मूळ गाव';

  @override
  String get naturalPosesRespectful => 'आदरणीय अभिव्यक्तीसह नैसर्गिक पोझेस';

  @override
  String get needProfileToShareToast =>
      'शेअर करण्यापूर्वी तुम्हाला प्रोफाईल तयार करावे लागेल.';

  @override
  String get neverMarried => 'अविवाहित';

  @override
  String get newLabel => 'नवीन';

  @override
  String get newMatches => 'नवीन सामने';

  @override
  String get next => 'पुढे';

  @override
  String get nextLabel => 'पुढील';

  @override
  String nextRefreshTime(String time) {
    return 'पुढील रिफ्रेश: $time';
  }

  @override
  String get no => 'नाही';

  @override
  String get noBookmarkedProfilesYet =>
      'अद्याप कोणतेही बुकमार्क केलेले प्रोफाइल नाहीत';

  @override
  String get noConversations => 'अद्याप कोणतेही संभाषण नाही';

  @override
  String get noDailyMatchesYet => 'अद्याप कोणतेही दैनिक सामने नाहीत';

  @override
  String get noIncome => 'उत्पन्न नाही';

  @override
  String get noInternetConnection => 'इंटरनेट कनेक्शन नाही';

  @override
  String noLocationsFoundForQuery(String query) {
    return '\"$query\" साठी कोणतीही ठिकाणे आढळली नाहीत';
  }

  @override
  String get noPendingRequests => 'कोणत्याही प्रलंबित विनंत्या नाहीत';

  @override
  String get noPendingVerifications => 'कोणतेही प्रलंबित व्हेरिफिकेशन नाही';

  @override
  String get noPhotosAdded => 'कोणतेही फोटो जोडले नाहीत';

  @override
  String get noPhotosYet => 'अद्याप कोणतेही फोटो नाहीत';

  @override
  String get noProfileFound => 'कोणतेही प्रोफाइल आढळले नाही';

  @override
  String get noProfilesFound => 'कोणतीही प्रोफाइल सापडली नाही';

  @override
  String get noProfilesMatchYourFilters =>
      'तुमच्या फिल्टरशी कोणतेही प्रोफाइल जुळत नाहीत';

  @override
  String get noResultsMessage =>
      'तुमचे फिल्टर बदलून पहा किंवा नवीन प्रोफाइलसाठी नंतर तपासा.';

  @override
  String get noSiblingsAddedYet => 'अद्याप कोणतेही भावंड जोडलेले नाहीत';

  @override
  String get noTalukasAvailable => 'तालुका उपलब्ध नाही';

  @override
  String get noViewsYet => 'अद्याप दृश्ये नाहीत';

  @override
  String get notAvailable => 'उपलब्ध नाही';

  @override
  String get notEntered => 'प्रविष्ट केलेले नाही';

  @override
  String get notMatchedCantMessage =>
      'तुम्ही या प्रोफाइलशी जुळलेले नाही, त्यामुळे तुम्ही त्यांना थेट संदेश पाठवू शकत नाही.';

  @override
  String get notReadyYet => 'अद्याप तयार नाही';

  @override
  String get notRepresentAppearance =>
      'तुमचे सध्याचे स्वरूप प्रतिबिंबित न करणारे फोटो';

  @override
  String get notVerifiedYetPleaseClickTheLinkInYourEm =>
      'अद्याप पडताळणी केली नाही. कृपया तुमच्या ईमेलमधील लिंकवर क्लिक करा.';

  @override
  String get notYetVerifiedBadge => 'अद्याप सत्यापित केलेले नाही';

  @override
  String get nuclearFamily => 'विभक्त कुटुंब';

  @override
  String get num100 => '/ 100';

  @override
  String get num123BanjaraTowersPrideSiliconValleynsh =>
      '123, बंजारा टॉवर्स, प्राइड सिलिकॉन व्हॅली,\\nशिवाजी नगर, पुणे, महाराष्ट्र 411005';

  @override
  String get num15PointsPending => '+15 गुण प्रलंबित';

  @override
  String get num499 => '499';

  @override
  String get num919876543210 => '+९१ ९८७६५ ४३२१०';

  @override
  String get officeAddress => 'कार्यालयाचा पत्ता';

  @override
  String get ok => 'ठीक';

  @override
  String get onHold => 'होल्डवर';

  @override
  String get onboardingTitle1 => 'तुमचा योग्य जोडीदार शोधा';

  @override
  String get onboardingTitle2 => 'विश्वसनीय समुदाय';

  @override
  String get onboardingTitle3 => 'सुरक्षित आणि खाजगी';

  @override
  String get oneTime => 'एक वेळ';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get openCamera => 'कॅमेरा उघडा';

  @override
  String get openProfileToShare => 'शेअर करण्यासाठी प्रोफाइल उघडा';

  @override
  String get openSettings => 'सेटिंग्ज उघडा';

  @override
  String get openingConversation => 'संभाषण सुरू होत आहे...';

  @override
  String get openingConversationToast => 'संभाषण सुरू करत आहे...';

  @override
  String get originalVillageHint => 'मूळ गाव';

  @override
  String get other => 'इतर';

  @override
  String get partnerExpectations => 'जोडीदार अपेक्षा';

  @override
  String get partnerExpectationsHint =>
      'तुम्ही काय शोधत आहात याचे वर्णन करा...';

  @override
  String get partnerPreferences => 'भागीदार प्राधान्ये';

  @override
  String get password => 'पासवर्ड';

  @override
  String get pay199ToUnlockFullPdf => 'पूर्ण PDF अनलॉक करण्यासाठी ₹199 भरा';

  @override
  String paymentFailed(String error) {
    return 'पेमेंट अयशस्वी: $error';
  }

  @override
  String paymentFailedError(String error) {
    return 'पेमेंट अयशस्वी: $error';
  }

  @override
  String get paymentSuccessful => 'पेमेंट यशस्वी झाले! टेम्पलेट अनलॉक केले.';

  @override
  String paymentSuccessfulWelcome(String plan) {
    return 'पेमेंट यशस्वी! $plan मध्ये तुमचे स्वागत आहे';
  }

  @override
  String pdfSavedToDownloads(String path) {
    return 'PDF डाउनलोडमध्ये सेव्ह केली: $path';
  }

  @override
  String get pending => 'प्रलंबित';

  @override
  String get pendingVerifications => 'प्रलंबित व्हेरिफिकेशन्स';

  @override
  String percentComplete(int percentage) {
    return '$percentage% पूर्ण';
  }

  @override
  String get permissionDeniedSettings =>
      'परवानगी नाकारली. कृपया सेटिंग्जमध्ये सुरू करा.';

  @override
  String get permissionRequired => 'परवानगी आवश्यक';

  @override
  String permissionRequiredMessage(String type) {
    return 'फोटो अपलोड करण्यासाठी $type परवानगी आवश्यक आहे. कृपया ती अॅप सेटिंग्जमध्ये सक्षम करा.';
  }

  @override
  String get personalDetails => 'वैयक्तिक माहिती';

  @override
  String get phoneLabel => 'फोन';

  @override
  String get phoneSupport => 'फोन सपोर्ट';

  @override
  String get photoAdded => 'फोटो जोडला';

  @override
  String photoAddedWithKb(int kb) {
    return 'फोटो जोडला ($kb KB)';
  }

  @override
  String get photoGuidelines => 'फोटो मार्गदर्शक तत्त्वे';

  @override
  String get photoLimitReached => 'फोटो मर्यादा गाठली';

  @override
  String get photoManagement => 'फोटो व्यवस्थापन';

  @override
  String get photoUpload => 'फोटो';

  @override
  String get photoUploadedSuccessfully => 'फोटो यशस्वीरित्या अपलोड झाला';

  @override
  String get photoVisibility => 'फोटो दृश्यमानता';

  @override
  String get photos => 'फोटो:';

  @override
  String get photosAreAutomaticallyCompressedToEnsure =>
      'जलद अपलोड सुनिश्चित करण्यासाठी फोटो स्वयंचलितपणे संकुचित केले जातात';

  @override
  String get photosCompressedInfo =>
      'डेटा वाचवण्यासाठी फोटो कॉम्प्रेस केले जातात.';

  @override
  String photosCount(int count) {
    return '$count फोटो';
  }

  @override
  String get photosDeletedSuccessfully => 'फोटो यशस्वीरित्या हटवले';

  @override
  String get photosReflectPersonality =>
      'तुमचे व्यक्तिमत्व आणि मूल्ये प्रतिबिंबित करणारे फोटो';

  @override
  String photosSelectedCount(int count) {
    return '$count निवडले';
  }

  @override
  String get photosToAvoid => 'टाळायचे फोटो';

  @override
  String get physicalSocialAttributes => 'शारीरिक आणि सामाजिक माहिती';

  @override
  String get physicalStatus => 'शारीरिक स्थिती';

  @override
  String get platinumPlanDesc => 'सर्व वैशिष्ट्यांसह उत्कृष्ट अनुभव';

  @override
  String get platinumPlanName => 'प्लॅटिनम';

  @override
  String pleaseComplete(String fields) {
    return 'कृपया पूर्ण करा: $fields';
  }

  @override
  String pleaseCompleteRequiredFields(String section) {
    return 'कृपया $section मधील सर्व आवश्यक फील्ड पूर्ण करा';
  }

  @override
  String get pleaseEnter6DigitOtp => 'कृपया 6-अंकी OTP प्रविष्ट करा';

  @override
  String get pleaseEnterAValid10DigitMobileNumber =>
      'कृपया वैध 10-अंकी मोबाइल नंबर प्रविष्ट करा';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'कृपया वैध ईमेल पत्ता प्रविष्ट करा';

  @override
  String get pleaseEnterBothEmailPassword =>
      'कृपया ईमेल आणि पासवर्ड दोन्ही प्रविष्ट करा';

  @override
  String get pleaseEnterFull6DigitOtp =>
      'कृपया संपूर्ण 6-अंकी OTP प्रविष्ट करा';

  @override
  String get pleaseFillAllFields => 'कृपया सर्व फील्ड भरा';

  @override
  String get pleaseSelectAnnualIncome => 'कृपया तुमचे वार्षिक उत्पन्न निवडा';

  @override
  String get pleaseSelectEducationLevel => 'कृपया तुमचा शिक्षण स्तर निवडा';

  @override
  String get pleaseSelectProfession => 'कृपया तुमचा व्यवसाय निवडा';

  @override
  String get pleaseSelectYourGotra => 'कृपया तुमचे गोत्र निवडा';

  @override
  String get pleaseSelectYourSurname => 'कृपया तुमचे आडनाव निवडा';

  @override
  String get pleaseSignInAgain =>
      'बायोडाटा सेव्ह करण्यासाठी कृपया पुन्हा साइन इन करा';

  @override
  String get pleaseSpecifyEducation => 'कृपया तुमचे शिक्षण निर्दिष्ट करा';

  @override
  String get pleaseSpecifyProfession => 'कृपया तुमचा व्यवसाय निर्दिष्ट करा';

  @override
  String get pleaseTakeASelfieToVerifyThatYouAreAReal =>
      'तुम्ही खरी व्यक्ती आहात हे सत्यापित करण्यासाठी कृपया सेल्फी घ्या. तुम्ही प्रज्वलित क्षेत्रात असल्याची खात्री करा.';

  @override
  String pointsCount(int points) {
    return '+$points गुण';
  }

  @override
  String get postGraduate => 'पदव्युत्तर';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get premiumFeature => 'हे एक प्रीमियम वैशिष्ट्य आहे';

  @override
  String get premiumMembership => 'प्रीमियम सदस्यत्व';

  @override
  String get premiumTemplate => 'प्रीमियम टेम्पलेट';

  @override
  String get premiumUsers => 'प्रीमियम वापरकर्ते';

  @override
  String get preparingBiodata => 'तुमचा बायोडेटा तयार करत आहे...';

  @override
  String get previewGenerationFailed =>
      'पूर्वावलोकन निर्मिती अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get previous => 'मागे';

  @override
  String pricePerMonth(int price) {
    return '₹$price/महिना';
  }

  @override
  String get primary => 'प्राथमिक';

  @override
  String get primaryPhoto => 'प्राथमिक फोटो';

  @override
  String get primaryPhotoUpdated => 'प्राथमिक फोटो अपडेट केला';

  @override
  String get printBtn => 'छापा';

  @override
  String get prioritySupport => 'प्राधान्य समर्थन';

  @override
  String get privacyPolicy => 'गोपनीयता धोरण';

  @override
  String get privacyS1Content =>
      '• वैयक्तिक डेटा: नाव, वय, लिंग, जात, शिक्षण, व्यवसाय, कौटुंबिक तपशील।\\n• संपर्क डेटा: फोन नंबर, ईमेल पत्ता।\\n• मीडिया: तुमच्या प्रोफाइलवर अपलोड केलेले फोटो।\\n• डिव्हाइस डेटा: डिव्हाइस आयडी, आयपी पत्ता (सुरक्षा आणि विश्लेषणासाठी)।\\n• स्थान डेटा: जवळपासचे सामने सुचवण्यासाठी अंदाजे स्थान (शहर/जिल्हा)।';

  @override
  String get privacyS1Title => '1. आम्ही गोळा करत असलेली माहिती';

  @override
  String get privacyS2Content =>
      '• ॲप कार्यक्षमता: तुमचे प्रोफाइल तयार करण्यासाठी आणि जुळणी करण्यासाठी.।\\n• खाते व्यवस्थापन: ओळख पडताळणी आणि फसवणूक रोखणे.।\\n• विश्लेषण: ॲप कार्यप्रदर्शन सुधारण्यासाठी (फायरबेस वापरून).।\\n• स्थान: \"माझ्या जवळील\" सामने दर्शवण्यासाठी (पर्यायी).';

  @override
  String get privacyS2Title => '2. संकलनाचा उद्देश (डेटा सुरक्षा)';

  @override
  String get privacyS3Content =>
      '• कॅमेरा आणि गॅलरी: प्रोफाइल फोटोंसाठी.।\\n• स्थान: शहर/जिल्हा ऑटो-फिल करण्यासाठी.।\\n• सूचना: मॅच अलर्टसाठी.';

  @override
  String get privacyS3Title => '3. डिव्हाइस परवानग्या';

  @override
  String get privacyS4Content =>
      '• इतर वापरकर्ते: नोंदणीकृत सदस्य तुमचे प्रोफाइल तपशील पाहू शकतात (शेअर केल्याशिवाय संपर्क माहिती वगळून).।\\n• सेवा प्रदाता: आम्ही ॲप चालवण्यासाठी सुपबेस (डेटाबेस) आणि फायरबेस (एनालिटिक्स/नोटिफिकेशन्स) वापरतो. ते कडक सुरक्षा मानकांनुसार डेटावर प्रक्रिया करतात.';

  @override
  String get privacyS4Title => '4. प्रकटीकरण आणि तृतीय पक्ष';

  @override
  String get privacyS5Content =>
      'आम्ही तुमच्या डेटाच्या संरक्षणासाठी एन्क्रिप्शन वापरतो. तुम्ही सेटिंग्ज > खाते हटवा याद्वारे कधीही तुमचे खाते आणि सर्व संबंधित डेटा हटवू शकता.';

  @override
  String get privacyS5Title => '5. डेटा सुरक्षा आणि हटवणे';

  @override
  String get privacyS6Content =>
      'हे धोरण भारताच्या कायद्यांद्वारे शासित आहे. कोणताही वाद महाराष्ट्रातील न्यायालयांच्या अधिकारक्षेत्राच्या अधीन आहे।';

  @override
  String get privacyS6Title => '6. नियामक कायदा';

  @override
  String get privacySettings => 'गोपनीयता सेटिंग्ज';

  @override
  String get privacySettingsUpdated => 'गोपनीयता सेटिंग्ज अपडेट केल्या';

  @override
  String get privacyTitle => 'गोपनीयता धोरण';

  @override
  String get privateJob => 'खाजगी नोकरी';

  @override
  String get privateSectorEmployee => 'खाजगी क्षेत्रातील कर्मचारी';

  @override
  String get pro => 'प्रो';

  @override
  String get proTips => 'प्रो टिपा';

  @override
  String get processingImage => 'प्रतिमा प्रक्रिया केली जात आहे';

  @override
  String get processingStatusCompressing => 'कॉम्प्रेस करत आहे...';

  @override
  String get processingStatusPreparing => 'तयार करत आहे...';

  @override
  String get processingStatusSelecting => 'निवडत आहे...';

  @override
  String get profession => 'व्यवसाय';

  @override
  String get professionLabel => 'व्यवसाय';

  @override
  String get professional => 'व्यावसायिक';

  @override
  String get professionalDegree => 'व्यावसायिक पदवी';

  @override
  String get professionalDoctorEngineerLawyer =>
      'व्यावसायिक (डॉक्टर/इंजिनीअर/वकील)';

  @override
  String get professionalFamilyEventPhotos =>
      'व्यावसायिक किंवा कौटुंबिक कार्यक्रमाचे फोटो';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String profileBoostPerMonth(int count) {
    return '$count प्रोफाइल बूस्ट/महिना';
  }

  @override
  String get profileCompleted => 'प्रोफाइल पूर्ण झाले';

  @override
  String get profileCreatedByTitle => 'प्रोफाइल कोणाद्वारे तयार केली गेली';

  @override
  String get profileDataNotFound => 'प्रोफाइल डेटा आढळला नाही';

  @override
  String get profileInsights => 'प्रोफाइल अंतर्दृष्टी';

  @override
  String get profileLinkCopied => 'प्रोफाइल लिंक क्लिपबोर्डवर कॉपी केली!';

  @override
  String get profileNotFound => 'प्रोफाइल आढळले नाही';

  @override
  String get profilePhotos => 'प्रोफाइल फोटो';

  @override
  String get profileRemovedFromSaved => 'जतन केलेल्यामधून प्रोफाइल काढले';

  @override
  String get profileSaved => 'प्रोफाइल जतन केले!';

  @override
  String profileSharedWith(String name) {
    return '$name सोबत प्रोफाइल शेअर केली';
  }

  @override
  String profileStrengthLabel(String strength) {
    return 'प्रोफाइल सामर्थ्य: $strength';
  }

  @override
  String get profileViewLimitReached => 'प्रोफाइल पाहण्याची मर्यादा गाठली';

  @override
  String profileViewsPerDay(int count) {
    return '$count प्रोफाइल दृश्य/दिवस';
  }

  @override
  String get profilesYouSaveWillAppearHere =>
      'तुम्ही सेव्ह केलेले प्रोफाईल येथे दिसतील';

  @override
  String get provideDetailsAboutYourGotraAndVillageTo =>
      'समुदाय सत्यापित बॅज मिळविण्यासाठी तुमचे गोत्र आणि गाव याबद्दल तपशील द्या.';

  @override
  String get provideInformationAboutYourFamilyBackgro =>
      'तुमच्या कौटुंबिक पार्श्वभूमीबद्दल माहिती द्या';

  @override
  String get public => 'सार्वजनिक';

  @override
  String get quick => 'जलद';

  @override
  String get ready => 'तयार';

  @override
  String get readyForMarriage => 'लग्नासाठी तयार';

  @override
  String get recentConversations => 'अलीकडील संभाषणे';

  @override
  String get recentPhotosSixMonths => 'गेल्या ६ महिन्यांत काढलेले अलीकडील फोटो';

  @override
  String get recentSearches => 'अलीकडील शोध';

  @override
  String get recentlyUsed => 'अलीकडे वापरलेले';

  @override
  String get recommendToOthers => 'इतरांना शिफारस (Recommend) करा';

  @override
  String get recommended => 'शिफारस केलेले';

  @override
  String get recommendedPhotos => 'शिफारस केलेले फोटो';

  @override
  String get recordAShortIntro => 'एक लहान परिचय रेकॉर्ड करा';

  @override
  String get refer3FriendsGet1MonthFree =>
      '३ मित्रांना रेफर करा, १ महिना मोफत मिळवा!';

  @override
  String get referAndEarn => 'संदर्भ द्या आणि मिळवा';

  @override
  String get referenceVerification => 'संदर्भ सत्यापन';

  @override
  String get references => 'संदर्भ';

  @override
  String get referralInvite => 'संदर्भ आमंत्रण';

  @override
  String referralInviteMessage(String link) {
    return 'बंजाराबायोमध्ये सामील व्हा, आमच्या समुदायासाठी सर्वात विश्वसनीय वैवाहिक ॲप! सुरू करण्यासाठी माझी लिंक वापरा: $link';
  }

  @override
  String get referralInviteSubject => 'बंजाराबायोमध्ये सामील होण्याचे आमंत्रण';

  @override
  String get referralLinkCopiedToClipboard =>
      'रेफरल लिंक क्लिपबोर्डवर कॉपी केली!';

  @override
  String referralShareMessage(String link) {
    return 'आमच्या समुदायासाठी सर्वात विश्वसनीय वैवाहिक अॅप असलेल्या बंजाराबायो (BanjaraBio) मध्ये सामील व्हा! सुरू करण्यासाठी माझी लिंक वापरा: $link';
  }

  @override
  String get referralShareSubject => 'बंजाराबायो आमंत्रण';

  @override
  String get referrals => 'रेफरल्स';

  @override
  String get referralsLabel => 'रेफरल';

  @override
  String get refresh => 'रिफ्रेश';

  @override
  String get reject => 'नकार द्या';

  @override
  String get rejected => 'नाकारले';

  @override
  String get relative => 'नातेवाईक';

  @override
  String get remainingToday => 'आज बाकी';

  @override
  String get remove => 'काढून टाका';

  @override
  String get removePhoto => 'काढा';

  @override
  String get report => 'तक्रार करा';

  @override
  String get reportSubmittedReview =>
      'रिपोर्ट सबमिट केला. आमची टीम २४ तासांच्या आत त्याचे पुनरावलोकन करेल.';

  @override
  String get reportUser => 'वापरकर्त्याचा अहवाल द्या';

  @override
  String get requestDate => 'विनंती तारीख';

  @override
  String requestProcessedSuccessfullyMsg(String status) {
    return 'विनंती $status यशस्वीरित्या पूर्ण झाली';
  }

  @override
  String get requestsSent => 'विनंत्या पाठवल्या!';

  @override
  String get requestsSentSuccessfully => 'विनंत्या यशस्वीरित्या पाठवल्या!';

  @override
  String get rerecord => 'पुन्हा रेकॉर्ड करा';

  @override
  String get reset => 'रीसेट';

  @override
  String get reshare => 'रीशेअर करा';

  @override
  String get retake => 'पुन्हा घ्या';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get reviewDetails => 'तपशीलांचे पुनरावलोकन करा';

  @override
  String get reviewVideoManuallyInStorageForNow =>
      'आत्तासाठी स्टोरेजमध्ये व्हिडिओचे व्यक्तिचलितपणे पुनरावलोकन करा';

  @override
  String get rewards => 'बक्षिसे';

  @override
  String get rewardsLabel => 'बक्षीस';

  @override
  String get rich => 'श्रीमंत';

  @override
  String get rupeeSymbol => '₹';

  @override
  String get save => 'सेव्ह करा';

  @override
  String get saveBiodata => 'बायोडाटा सेव्ह करा';

  @override
  String get saved => 'जतन केले';

  @override
  String get savedProfiles => 'सेव्ह केलेल्या प्रोफाइल';

  @override
  String get sayHelloLabel => 'हॅलो म्हणा!';

  @override
  String get search => 'शोधा';

  @override
  String get searchByNameJobEducation => 'नाव, नोकरी, शिक्षणाने शोधा...';

  @override
  String get searchProfiles => 'प्रोफाइल शोधा...';

  @override
  String get searchResults => 'शोध निकाल';

  @override
  String get searchSharedProfiles => 'शेअर केलेले प्रोफाईल शोधा...';

  @override
  String get searchStateDistrictOrTaluka => 'राज्य, जिल्हा किंवा तालुका शोधा';

  @override
  String get searchUserName => 'वापरकर्त्याचे नाव शोधा...';

  @override
  String get secure => 'सुरक्षित';

  @override
  String get seeAll => 'सर्व पहा';

  @override
  String get selectAnnualIncome => 'वार्षिक उत्पन्नाची श्रेणी निवडा';

  @override
  String get selectAnnualIncomeRange => 'वार्षिक उत्पन्न श्रेणी निवडा';

  @override
  String get selectDate => 'तारीख निवडा';

  @override
  String get selectDistrictFirst => 'आधी जिल्हा निवडा';

  @override
  String get selectDocumentType => 'दस्तऐवज प्रकार निवडा';

  @override
  String get selectEducationLevel => 'तुमची शिक्षण पातळी निवडा';

  @override
  String get selectFromYourPhotos => 'तुमच्या फोटोंमधून निवडा';

  @override
  String get selectLanguage => 'भाषा निवडा';

  @override
  String get selectLocation => 'स्थान निवडा';

  @override
  String get selectState => 'राज्य निवडा';

  @override
  String get selectStateFirst => 'आधी राज्य निवडा';

  @override
  String get selectTalukaOptional => 'तालुका निवडा (पर्यायी)';

  @override
  String get selectYourEducationLevel => 'तुमची शैक्षणिक पातळी निवडा';

  @override
  String get selectYourGotra => 'तुमचे गोत्र निवडा';

  @override
  String get selectYourLocationAndPreferences =>
      'तुमचे स्थान आणि प्राधान्ये निवडा';

  @override
  String get selectYourProfession => 'तुमचा व्यवसाय निवडा';

  @override
  String get selectYourSurname => 'तुमचे आडनाव निवडा';

  @override
  String get selectedPhotos => 'निवडलेले फोटो';

  @override
  String get self => 'स्वतः';

  @override
  String get selfEmployed => 'स्वयंरोजगार';

  @override
  String get selfieSubmitted => 'सेल्फी सबमिट केला';

  @override
  String get send => 'पाठवा';

  @override
  String get sendInterest => 'स्वारस्य पाठवा';

  @override
  String get sendMessage => 'संदेश पाठवा';

  @override
  String get sendVerification => 'पडताळणी पाठवा';

  @override
  String get sendVerificationRequests => 'पडताळणी विनंत्या पाठवा';

  @override
  String get setAsPrimary => 'प्राथमिक म्हणून सेट करा';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get settingsAndMenu => 'सेटिंग्ज आणि मेनू';

  @override
  String get sevenHalfToTenLakh => '₹७.५ लाख - ₹१० लाख';

  @override
  String get share => 'शेअर करा';

  @override
  String get shareBtn => 'शेअर करा';

  @override
  String get shareEducationalBackground =>
      'तुमचा शैक्षणिक आणि व्यावसायिक तपशील सामायिक करा';

  @override
  String shareFailed(String error) {
    return 'शेअर करण्यात अयशस्वी: $error';
  }

  @override
  String get shareHub => 'शेअर हब';

  @override
  String get shareInApp => 'अॅपमध्ये शेअर करा';

  @override
  String get shareLimitReached => 'शेअरची मर्यादा गाठली';

  @override
  String get shareLinkOnWhatsapp => 'WhatsApp वर लिंक शेअर करा';

  @override
  String get shareMyProfileSubtitle =>
      'तुमचा बायोडाटा थेट शेअर करून तुमचे स्वारस्य व्यक्त करा';

  @override
  String shareMyProfileWith(String name) {
    return '$name सोबत माझी प्रोफाइल शेअर करा';
  }

  @override
  String get shareProfile => 'प्रोफाइल शेअर करा';

  @override
  String get shareProfilesWithYourFamilyInstantlyNbui =>
      'तुमच्या कुटुंबासह प्रोफाईल झटपट शेअर करा.\\nभारतीय कुटुंबे ज्या प्रकारे निर्णय घेतात त्यासाठी तयार केलेले.';

  @override
  String get shareToSocialMedia => 'सोशल मीडियावर शेअर करा';

  @override
  String get shareYourEducationalBackgroundAndProfess =>
      'तुमची शैक्षणिक पार्श्वभूमी आणि व्यावसायिक तपशील शेअर करा';

  @override
  String get shareYourProfileProfessionally =>
      'तुमचे प्रोफाईल प्रोफेशनली शेअर करा';

  @override
  String get shared => 'मॅचेस';

  @override
  String get sharedProfiles => 'शेअर केलेल्या प्रोफाइल';

  @override
  String sharedVia(String name, String method) {
    return '$method द्वारे $name सोबत शेअर केले';
  }

  @override
  String sharesPerMonth(int count) {
    return '$count शेअर्स/महिना';
  }

  @override
  String get sharingBiodataPdf => 'बायोडेटा पीडीएफ शेअर करत आहे';

  @override
  String get silver => 'चांदी';

  @override
  String get silverPlanDesc => 'सुरुवात करण्यासाठी योग्य';

  @override
  String get silverPlanName => 'सिल्वर';

  @override
  String get sister => 'बहीण';

  @override
  String get sisterCount => 'बहिणी';

  @override
  String get skip => 'वगळा';

  @override
  String get smileNaturallyTip => 'मिळनसार दिसण्यासाठी नैसर्गिकरित्या हसा';

  @override
  String get socialMediaTextOverlays =>
      'मजकूर आच्छादनांसह सोशल मीडियावरील फोटो';

  @override
  String get solicitingMoney => 'पैसे मागणे';

  @override
  String get someone => 'कोणीतरी';

  @override
  String get somethingWentWrong => 'काहीतरी चुकले';

  @override
  String get son => 'मुलगा';

  @override
  String get specifyEducation => 'शिक्षण निर्दिष्ट करा';

  @override
  String get specifyProfession => 'व्यवसाय निर्दिष्ट करा';

  @override
  String get standardProfile => 'मानक प्रोफाईल';

  @override
  String get start => 'सुरू करा';

  @override
  String get startAConversation => 'संभाषण सुरू करा';

  @override
  String get startConversation => 'संभाषण सुरू करा';

  @override
  String get startRecording => 'रेकॉर्डिंग सुरू करा';

  @override
  String get state => 'राज्य';

  @override
  String get statusWaitingForApproval => 'स्थिती: मंजुरीची प्रतीक्षा करत आहे';

  @override
  String get stay => 'थांबा';

  @override
  String stepNOfTotal(String current, String total) {
    return 'पायरी $current पैकी $total';
  }

  @override
  String get student => 'विद्यार्थी';

  @override
  String get submit => 'सबमिट करा';

  @override
  String get submitForVerification => 'पडताळणीसाठी सबमिट करा';

  @override
  String get submittedForReview => 'पुनरावलोकनासाठी सबमिट केले';

  @override
  String get subscription => 'सदस्यता';

  @override
  String get supportAndHelp => 'सहाय्य आणि मदत';

  @override
  String get supportBanjarabioApp => 'support@banjarabio.com';

  @override
  String get surname => 'आडनाव';

  @override
  String get swipe => 'स्वाइप';

  @override
  String get takePhoto => 'फोटो काढा';

  @override
  String get taluka => 'तालुका';

  @override
  String talukaInDistrictState(String district, String state) {
    return '$district, $state मधील तालुका';
  }

  @override
  String get talukaOptional => 'तालुका (पर्यायी)';

  @override
  String get tapTheButtonToAddAPhoto => 'फोटो जोडण्यासाठी + बटणावर टॅप करा';

  @override
  String get tapToAddPhoto => 'फोटो जोडण्यासाठी टॅप करा';

  @override
  String get tapToReveal => '✨ प्रकट करण्यासाठी टॅप करा';

  @override
  String get teacherProfessor => 'शिक्षक/प्राध्यापक';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get template => 'साचा';

  @override
  String get tenToFifteenLakh => '₹१० लाख - ₹१५ लाख';

  @override
  String get terms => 'अटी';

  @override
  String get termsAndConditions => 'अटी आणि शर्ती';

  @override
  String get termsConditions => 'नियम आणि अटी';

  @override
  String get termsOfService => 'सेवा अटी';

  @override
  String get termsS1Content =>
      'बंजाराबायो ॲप्लिकेशन वापरून, तुम्ही या अटी व शर्तींचे पालन करण्यास संमती देता. जर तुम्ही सहमत नसाल, तर कृपया सेवा वापरू नका.';

  @override
  String get termsS1Title => '1. अटींची स्वीकृती';

  @override
  String get termsS2Content =>
      'या प्लॅटफॉर्मवर नोंदणी करण्यासाठी तुमचे वय किमान १८ वर्षे (स्त्रियांसाठी) किंवा २१ वर्षे (पुरुषांसाठी) असणे आवश्यक आहे. हे प्लॅटफॉर्म काटेकोरपणे विवाहविषयक कारणांसाठी आहे.';

  @override
  String get termsS2Title => '2. पात्रता';

  @override
  String get termsS3Content =>
      'तुमच्या खात्याची गोपनीयता राखण्यासाठी तुम्ही जबाबदार आहात. नोंदणीदरम्यान दिलेली सर्व माहिती अचूक आणि सत्य असली पाहिजे.';

  @override
  String get termsS3Title => '3. वापरकर्ता खाते';

  @override
  String get termsS4Content =>
      'वापरकर्त्यांना व्यावसायिक हेतू, छळ, द्वेषपूर्ण भाषणाचा प्रसार किंवा फसव्या माहिती शेअर करण्यासाठी प्लॅटफॉर्म वापरण्यास मनाई आहे.';

  @override
  String get termsS4Title => '4. प्रतिबंधित क्रियाकलाप';

  @override
  String get termsS5Content =>
      'तुम्ही तुमच्या प्रोफाइल सेटिंग्जमधील \"खाते हटवा\" विभागाद्वारे कधीही खाते हटवण्याची विनंती करू शकता.';

  @override
  String get termsS5Title => '5. खाते हटवणे';

  @override
  String get termsS6Content =>
      'बंजाराबायो हे सामने शोधण्यासाठी एक प्लॅटफॉर्म आहे. आम्ही यशस्वी सामन्यांची हमी देत नाही किंवा मूलभूत तपासणीच्या पलीकडे वापरकर्त्यांच्या चारित्र्याची पडताळणी करत नाही. वापरकर्त्यांना स्वतःची काळजी घेण्यास प्रोत्साहित केले जाते.';

  @override
  String get termsS6Title => '6. दायित्वाची मर्यादा';

  @override
  String get termsS7Content =>
      'या अटी भारताच्या कायद्यांनुसार शासित आणि अर्थ लावल्या जातील. कोणताही वाद महाराष्ट्रातील न्यायालयांच्या अनन्य अधिकारक्षेत्राच्या अधीन असेल.';

  @override
  String get termsS7Title => '7. नियामक कायदा';

  @override
  String get termsTitle => 'अटी आणि शर्ती';

  @override
  String get textSuper => 'सुपर';

  @override
  String get thisFieldIsRequired => 'हे फील्ड आवश्यक आहे';

  @override
  String get totalCount => 'एकूण:';

  @override
  String get totalProfiles => 'एकूण प्रोफाईल्स';

  @override
  String get traditionalFormalAttire =>
      'पारंपारिक किंवा औपचारिक पेहराव (साडी, सलवार कमीज, कुर्ता)';

  @override
  String get trustScore => 'विश्वास स्कोअर';

  @override
  String get trustScoreBeyondBeauty => 'सौंदर्यापलीकडे ट्रस्ट स्कोअर';

  @override
  String get trustScoreDiscounts => 'ट्रस्ट स्कोअर आणि सवलत';

  @override
  String trustScoreShareMessage(int score, String url) {
    return 'मी नुकताच माझा प्रोफाईल बंजाराबायोवर $score ट्रस्ट स्कोअरसह व्हेरिफाय केला आहे! माझा प्रोफाईल पहा आणि आमच्या समुदायात सामील व्हा: $url';
  }

  @override
  String get trustVerification => 'विश्वास आणि पडताळणी';

  @override
  String get trusted => 'विश्वसनीय';

  @override
  String get trustedMember => 'विश्वसनीय सदस्य';

  @override
  String get trustedProfile => 'विश्वसनीय प्रोफाईल';

  @override
  String get tryAdjustingYourFilterCriteria =>
      'तुमचे फिल्टर निकष समायोजित करण्याचा प्रयत्न करा';

  @override
  String get tryAdjustingYourFiltersToSeeMoreProfiles =>
      'बंजारा समुदायातील अधिक प्रोफाइल पाहण्यासाठी तुमचे फिल्टर समायोजित करण्याचा प्रयत्न करा';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get trySearchingForADifferentCity => 'वेगळे शहर शोधण्याचा प्रयत्न करा';

  @override
  String get trySearchingForDifferentCity =>
      'दुसऱ्या शहराचा शोध घेण्याचा प्रयत्न करा';

  @override
  String get twentyLakhPlus => '₹२० लाख+';

  @override
  String get twoToFiveLakh => '₹२ लाख - ₹५ लाख';

  @override
  String get typeAMessage => 'संदेश टाइप करा...';

  @override
  String get typeMessage => 'संदेश टाइप करा...';

  @override
  String get unauthorizedAccessAdminsOnly => 'अनहित प्रवेश. फक्त प्रशासक.';

  @override
  String get under2Lakh => '₹२ लाखांपेक्षा कमी';

  @override
  String get undo => 'मागे घ्या';

  @override
  String unexpectedError(String error) {
    return 'एक अनपेक्षित त्रुटी आली: $error';
  }

  @override
  String unexpectedErrorOccurred(String error) {
    return 'अनपेक्षित त्रुटी आली: $error';
  }

  @override
  String get unknownUser => 'अज्ञात वापरकर्ता';

  @override
  String get unlimitedBookmarks => 'अमर्यादित बुकमार्क';

  @override
  String get unlimitedProfileViews => 'अमर्यादित प्रोफाइल दृश्य';

  @override
  String get unlimitedSharing => 'अमर्यादित सामायिकरण';

  @override
  String get unlockAdvancedFilters => 'प्रगत फिल्टर अनलॉक करा';

  @override
  String get unlockNow => 'आता अनलॉक करा';

  @override
  String get unlockPremiumBiodata => 'प्रीमियम बायोडेटा अनलॉक करा';

  @override
  String get unlockPremiumFeaturesToEnhanceYourBiodat =>
      'तुमचा बायोडेटा प्रोफाइल वर्धित करण्यासाठी प्रीमियम वैशिष्ट्ये अनलॉक करा';

  @override
  String get unlockToDownload =>
      'हे टेम्पलेट 5+ भाषांमध्ये डाउनलोड आणि शेअर करण्यासाठी अनलॉक करा.';

  @override
  String get unmarried => 'अविवाहित';

  @override
  String get unsave => 'अनसेव्ह';

  @override
  String get update => 'अपडेट करा';

  @override
  String get updateProfile => 'प्रोफाइल अपडेट करा';

  @override
  String get upgrade => 'अपग्रेड करा';

  @override
  String get upgradeNow => 'आता अपग्रेड करा';

  @override
  String get upgradePlan => 'प्लॅन अपग्रेड करा';

  @override
  String get upgradePremiumFilters =>
      'व्यवसाय, स्थान आणि अधिकसाठी प्रीमियम फिल्टरमध्ये अपग्रेड करा.';

  @override
  String get upgradeRequired => 'अपग्रेड आवश्यक';

  @override
  String get upgradeToPremium => 'प्रीमियममध्ये अपग्रेड करा';

  @override
  String get upgradeToPremiumFor6PhotosAdvancedFilter =>
      '6 फोटो आणि प्रगत फिल्टरसाठी प्रीमियम वर श्रेणीसुधारित करा';

  @override
  String get upgradeToPremiumToAccessGranularFiltersF =>
      'प्रगत फिल्टर्स वापरण्यासाठी प्रीमियमवर अपग्रेड करा';

  @override
  String get upgradeToUnlockAllFeatures =>
      'सर्व वैशिष्ट्ये अनलॉक करण्यासाठी श्रेणीसुधारित करा';

  @override
  String get uploadCommunityCertificateLetter =>
      'समुदाय प्रमाणपत्र / पत्र अपलोड करा';

  @override
  String get uploadYourPhotos => 'तुमचे सर्वोत्तम फोटो अपलोड करा';

  @override
  String get uploadedSuccessfully => 'यशस्वीरित्या अपलोड केले';

  @override
  String get upperMiddleClass => 'उच्च मध्यमवर्गीय';

  @override
  String get useCameraToCapture => 'कॅप्चर करण्यासाठी कॅमेरा वापरा';

  @override
  String get useCurrentLocation => 'वर्तमान स्थान वापरा';

  @override
  String get useEmailPassword => 'ईमेल / पासवर्ड वापरा';

  @override
  String get useNaturalLightingTip =>
      'सर्वोत्तम निकालांसाठी नैसर्गिक प्रकाश वापरा';

  @override
  String get userBlockedSuccessfully => 'वापरकर्ता यशस्वीरित्या ब्लॉक केला';

  @override
  String get userIdNotFound => 'युजर आयडी सापडला नाही';

  @override
  String get userIdNotFoundToast => 'वापरकर्ता आयडी सापडला नाही';

  @override
  String get userLabel => 'वापरकर्ता';

  @override
  String get userNotUploadedPhoto => 'वापरकर्त्याने फोटो अपलोड केला नाही';

  @override
  String get users => 'वापरकर्ते';

  @override
  String get usingGps => 'जीपीएस वापरणे';

  @override
  String get verificationBadge => 'पडताळणी बॅज';

  @override
  String get verificationCodeSent => 'पडताळणी कोड पाठवला!';

  @override
  String get verificationFailed => 'व्हेरिफिकेशन अयशस्वी';

  @override
  String get verificationLinkcodeSent => 'पडताळणी लिंक/कोड पाठवला!';

  @override
  String get verificationRequests => 'व्हेरिफिकेशन विनंत्या';

  @override
  String get verifications => 'व्हेरिफिकेशन्स';

  @override
  String get verified => 'सत्यापित';

  @override
  String get verified10PointsAddedToTrustScore =>
      'सत्यापित! ट्रस्ट स्कोअरमध्ये +10 गुण जोडले';

  @override
  String get verifiedCommunityMember => 'सत्यापित समुदाय सदस्य';

  @override
  String get verifiedProfile => 'सत्यापित प्रोफाईल';

  @override
  String get verifiedProfileBadge => 'सत्यापित प्रोफाइल';

  @override
  String get verifiedProfilesGet5xMoreResponses =>
      'सत्यापित प्रोफाइलला ५ पट अधिक प्रतिसाद मिळतात आणि ते शोध निकालांमध्ये अधिक दिसतात.';

  @override
  String get verifiedTrusted => 'सत्यापित आणि विश्वसनीय';

  @override
  String get verify => 'सत्यापित करा';

  @override
  String get verifyEmailAddressHeading => 'ईमेल पत्ता व्हेरिफाय करा';

  @override
  String verifyLabel(String label) {
    return '$label सत्यापित करा';
  }

  @override
  String get verifyMobile => 'मोबाइल सत्यापित करा';

  @override
  String get verifyNow => 'आता सत्यापित करा';

  @override
  String get verifyOtp => 'OTP व्हेरिफाय करा';

  @override
  String get verifyYourCommunityStatus => 'तुमची समुदाय स्थिती सत्यापित करा';

  @override
  String get verifyYourEmailAddressToAddTrustAndReach =>
      'विश्वास जोडण्यासाठी आणि अधिक प्रोफाइलपर्यंत पोहोचण्यासाठी तुमचा ईमेल पत्ता सत्यापित करा.';

  @override
  String get verifyYourMobileNumberToAddTrustAndReach =>
      'विश्वास जोडण्यासाठी आणि अधिक प्रोफाइलपर्यंत पोहोचण्यासाठी तुमचा मोबाइल नंबर सत्यापित करा.';

  @override
  String get veryFair => 'अतिशय गोरा';

  @override
  String get videoBioIntro => 'व्हिडिओ बायो / ओळख';

  @override
  String get videoIntro => 'व्हिडिओ परिचय';

  @override
  String get videoIntroUploaded => 'व्हिडिओ परिचय अपलोड केला';

  @override
  String get videoRecorded => 'व्हिडिओ रेकॉर्ड केला!';

  @override
  String get view => 'पहा';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String get viewBiodata => 'बायोडाटा पहा';

  @override
  String get viewDetails => 'तपशील पहा';

  @override
  String get viewLabel => 'दृश्य';

  @override
  String get viewProfile => 'प्रोफाइल पहा';

  @override
  String get viewYourBookmarkedProfiles => 'तुमचे बुकमार्क केलेले प्रोफाइल पहा';

  @override
  String get viewsLabel => 'दृश्य';

  @override
  String get village => 'गाव';

  @override
  String get visibleToAllProfiles => 'सर्व प्रोफाइलसाठी दृश्यमान';

  @override
  String get visibleToCloseMatchesOnly => 'केवळ सामने बंद करण्यासाठी दृश्यमान';

  @override
  String get weEncounteredAnUnexpectedErrorWhileProce =>
      'तुमच्या विनंतीवर प्रक्रिया करताना आम्हाला एक अनपेक्षित त्रुटी आली.';

  @override
  String get weWillSendAVerificationRequestToTheirMob =>
      'आम्ही त्यांच्या मोबाईल नंबरवर पडताळणी विनंती पाठवू. त्यांनी मंजूर केल्यावर, तुम्हाला +10 गुण मिळतील.';

  @override
  String get weWillVerifyYourCommunityDetailsShortly1 =>
      'आम्ही लवकरच तुमचे समुदाय तपशील सत्यापित करू. +15 गुण प्रलंबित.';

  @override
  String get welcomeToBanjaraBio => 'बंजारा बायो मध्ये स्वागत आहे';

  @override
  String get whatDoYouLookFor => 'तुम्हाला जोडीदारात काय हवे?';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get whatsAppContact => 'व्हॉट्सॲप संपर्क';

  @override
  String whatsappShareSubtitle(String name) {
    return '$name चे तपशील कुटुंब किंवा मित्रांसह शेअर करा';
  }

  @override
  String get whatsappSupport => 'WhatsApp समर्थन';

  @override
  String get wheatish => 'गव्हाळ';

  @override
  String get whereDoYouWork => 'तुम्ही कुठे काम करता?';

  @override
  String get whoViewedMe => 'मला कोणी पाहिले';

  @override
  String get whyBanjaraBio => 'बंजारा बायो का?';

  @override
  String get widowed => 'विधवा/विधुर';

  @override
  String get writeAboutYourself => 'स्वतःबद्दल काही लिहा...';

  @override
  String get year => 'वर्ष';

  @override
  String yearsOld(String age) {
    return '$age वर्षे';
  }

  @override
  String get upgradeToShareMore => 'अधिक शेअर करण्यासाठी अपग्रेड करा';

  @override
  String get yes => 'होय';

  @override
  String get yesterday => 'काल';

  @override
  String get youNeedAProfileToShareIt =>
      'सामायिक करण्यासाठी तुम्हाला प्रोफाइलची आवश्यकता आहे.';

  @override
  String get youWillNoLongerSeeThisProfile =>
      'तुम्हाला यापुढे हे प्रोफाइल दिसणार नाही';

  @override
  String get youngerBrother => 'लहान भाऊ';

  @override
  String get youngerSister => 'लहान बहीण';

  @override
  String get your => 'तुमचे';

  @override
  String get yourDailyMatches => 'तुमचे रोजचे सामने';

  @override
  String get yourDocumentsAreEncrypted =>
      'तुमचे दस्तऐवज कूटबद्ध (Encrypted) आहेत आणि इतर वापरकर्त्यांना कधीही दाखवले जात नाहीत. फक्त बॅज दृश्यमान आहे।';

  @override
  String get yourDocumentsHaveBeenSubmittedSecurelyWe =>
      'तुमचे दस्तऐवज सुरक्षितपणे सबमिट केले गेले आहेत. एकदा सत्यापित केल्यानंतर आम्ही तुम्हाला सूचित करू.';

  @override
  String get yourIntroVideoIsUnderReview10PointsPendi =>
      'तुमचा परिचय व्हिडिओ पुनरावलोकनाखाली आहे. +10 पॉइंट मंजूरी प्रलंबित.';

  @override
  String get yourMatchesWillAppearHereOnceYouBothExpr =>
      'तुम्ही दोघांनी स्वारस्य दाखवल्यानंतर तुमचे सामने येथे दिसतील. तुमची परिपूर्ण जुळणी शोधण्यासाठी प्रोफाइल शेअर करत रहा!';

  @override
  String get yourPersonalInviteLink => 'तुमची वैयक्तिक आमंत्रण लिंक';

  @override
  String get yourReferralCode => 'तुमचा रेफरल कोड';

  @override
  String get yourSelfieHasBeenSubmittedOurTeamWillVer =>
      'तुमचा सेल्फी सबमिट केला गेला आहे. आमची टीम तुमच्या प्रोफाईल फोटोवर त्याची पडताळणी करेल.';

  @override
  String get yourTrustScore => 'तुमचा विश्वास स्कोअर';

  @override
  String yrs(int count) {
    return '$count वर्ष';
  }

  @override
  String get itSAMatch => 'जोडी जमली!';

  @override
  String sharedProfilesWithEachOther(String name) {
    return 'तुम्ही आणि $name ने एकमेकांशी प्रोफाइल शेअर केले आहेत।';
  }

  @override
  String get mutualMatch => 'परस्पर जुळवणी';

  @override
  String toContact(String name) {
    return 'ला: $name';
  }

  @override
  String fromContact(String name) {
    return 'कडून: $name';
  }

  @override
  String countProfileViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रोफाइल व्ह्यू',
      one: '1 प्रोफाइल व्ह्यू',
    );
    return '$_temp0';
  }

  @override
  String get matchedBadge => 'जुळले';

  @override
  String get premiumBadge => 'प्रीमियम';

  @override
  String get contactLabel => 'संपर्क';

  @override
  String profileSharedVia(String profileName, String title) {
    return '$title द्वारे $profileName शेअर केले गेले';
  }

  @override
  String failedToSendMessage(String error) {
    return 'संदेश पाठविण्यात अयशस्वी: $error';
  }

  @override
  String uploadFailed(String error) {
    return 'अपलोड अयशस्वी: $error';
  }

  @override
  String updateFailed(String error) {
    return 'अपडेट अयशस्वी: $error';
  }

  @override
  String errorWithLabel(String label) {
    return 'त्रुटि: $label';
  }

  @override
  String referenceWithNumber(int number) {
    return 'संदर्भ $number';
  }

  @override
  String get villageTanda => 'गाव / तांडा';

  @override
  String get ageLabel => 'वय';

  @override
  String get heightLabel => 'ऊंची';

  @override
  String get surnameLabel => 'आडनाव';

  @override
  String get dateOfBirthLabel => 'जन्म तारीख';

  @override
  String get birthTimeLabel => 'जन्माची वेळ';

  @override
  String get birthPlaceLabel => 'जन्म ठिकाण';

  @override
  String get bloodGroupLabel => 'रक्त गट';

  @override
  String get occupationLabel => 'व्यवसाय';

  @override
  String get annualIncomeLabel => 'वार्षिक उत्पन्न';

  @override
  String get currentResidence => 'सध्याचे निवासस्थान';

  @override
  String get contactPersonLabel => 'संपर्क व्यक्ती';

  @override
  String get bestTimeToContact => 'संपर्क साधण्याची सर्वोत्तम वेळ';

  @override
  String get limitReached => 'मर्यादा संपली';

  @override
  String get relationLabel => 'नाते';

  @override
  String get none => 'काहीही नाही';

  @override
  String yearsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'वर्षे',
      one: 'वर्ष',
    );
    return '$_temp0';
  }

  @override
  String brothersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भाऊ',
      one: '1 भाऊ',
    );
    return '$_temp0';
  }

  @override
  String sistersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बहिणी',
      one: '1 बहीण',
    );
    return '$_temp0';
  }

  @override
  String get siblingsLabel => 'भाऊ-बहीण';

  @override
  String siblingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भावंडे',
      one: '1 भावंड',
    );
    return '$_temp0';
  }

  @override
  String get company => 'कंपनी';

  @override
  String get job => 'नोकरी / कार्य';

  @override
  String get biodataRequired => 'बायोडेटा आवश्यक आहे';

  @override
  String get guestRestrictionMessage =>
      'प्रोफाइलशी संवाद साधण्यासाठी, स्वारस्य व्यक्त करण्यासाठी किंवा संदेश पाठवण्यासाठी, तुम्हाला आधी तुमचा स्वतःचा बायोडेटा तयार करावा लागेल.';

  @override
  String get createNow => 'आत्ताच तयार करा';

  @override
  String get tourLocationTitle => 'ठिकाण निवडा';

  @override
  String get tourLocationDesc =>
      'तुमच्या जवळचे सामने शोधण्यासाठी राज्य, जिल्हा किंवा तालुक्यानुसार प्रोफाइल फिल्टर करा.';

  @override
  String get tourSearchTitle => 'प्रोफाइल शोधा';

  @override
  String get tourSearchDesc =>
      'कोणीतरी विशिष्ट शोधत आहात? त्यांचे नाव किंवा शिक्षण येथे टाइप करा.';

  @override
  String get tourFilterTitle => 'प्रगत फिल्टर';

  @override
  String get tourFilterDesc =>
      'तुम्हाला हवे तेच पाहण्यासाठी वय, शिक्षण किंवा व्यवसायानुसार मर्यादित करा.';

  @override
  String get tourChatTitle => 'संदेश आणि चॅट';

  @override
  String get tourChatDesc => 'तुमची संभाषणे आणि येणारी स्वारस्ये येथे पहा.';

  @override
  String get tourBottomHome => 'होम फीड';

  @override
  String get tourBottomHomeDesc => 'हजारो सत्यापित प्रोफाइल स्क्रोल करा.';

  @override
  String get tourBottomShared => 'सामायिक प्रोफाइल';

  @override
  String get tourBottomSharedDesc =>
      'WhatsApp/लिंकद्वारे सामायिक केलेले किंवा प्राप्त झालेले प्रोफाइल पहा.';

  @override
  String get tourBottomProfile => 'तुमची प्रोफाइल';

  @override
  String get tourBottomProfileDesc =>
      'तुमचा स्वतःचा बायोडेटा आणि फोटो येथे व्यवस्थापित करा.';

  @override
  String get tourBottomSettings => 'अॅप सेटिंग्ज';

  @override
  String get tourBottomSettingsDesc =>
      'भाषा, सूचना सेटिंग्ज बदला किंवा समर्थनाशी संपर्क साधा.';

  @override
  String get tourWhatsappTitle => 'WhatsApp समर्थन';

  @override
  String get tourWhatsappDesc =>
      'मदत किंवा प्रोफाइल बदलांसाठी आमच्या ॲडमिनशी थेट संपर्क साधा.';

  @override
  String get tourInstagramTitle => 'आम्हाला फॉलो करा';

  @override
  String get tourInstagramDesc =>
      'Instagram वर दररोज नवीन प्रोफाइल आणि यशोगाथा पहा.';

  @override
  String get tourBookmarkTitle => 'नंतरसाठी जतन करा';

  @override
  String get tourBookmarkDesc =>
      'आवडलेली प्रोफाइल नंतर तुमच्या जतन केलेल्या सूचीमध्ये पाहण्यासाठी बुकमार्क करा.';

  @override
  String get tourInterestTitle => 'स्वारस्य व्यक्त करा';

  @override
  String get tourInterestDesc =>
      'त्यांना हे कळवण्यासाठी \'हार्ट\' पाठवा की तुम्हाला त्यांच्या बायोडेटामध्ये रस आहे.';

  @override
  String get tourShareTitle => 'कुटुंबासह सामायिक करा';

  @override
  String get tourShareDesc =>
      'त्यांच्या मतासाठी WhatsApp द्वारे तुमच्या पालकांशी किंवा नातेवाईकांशी सहजपणे प्रोफाइल सामायिक करा.';

  @override
  String get chooseHowToStart => 'आपण कसे सुरू करू इच्छिता ते निवडा';

  @override
  String get exploreAsGuest => 'पाहुणे म्हणून फेरफटका मारा';

  @override
  String get exitGuestMode => 'गेस्ट मोडमधून बाहेर पडा';

  @override
  String get guestModeDesc =>
      'तुमची प्रोफाईल बनवण्यापूर्वी ॲपचा मार्गदर्शित फेरफटका मारा.';

  @override
  String get createMyBiodata => 'माझा बायोडेटा तयार करा';

  @override
  String get createBiodataDesc =>
      'तुमची प्रोफाईल भरा आणि त्वरित कनेक्ट होण्यास सुरुवात करा.';

  @override
  String get needHelpContactAdmin => 'मदत हवी आहे? ॲडमिनशी संपर्क साधा';

  @override
  String get noMatchesYet => 'अजून कोणतीही मॅच नाही';

  @override
  String get noProfilesSharedYet => 'अद्याप कोणतेही प्रोफाईल शेअर केले नाही';

  @override
  String get noProfilesReceived => 'कोणतेही प्रोफाईल प्राप्त झाले नाही';

  @override
  String get mutualMatchesDesc =>
      'जेव्हा दोन्ही वापरकर्ते एकमेकांमध्ये रस दाखवतील तेव्हा परस्पर मॅचेस येथे दिसतील';

  @override
  String get startSharingProfilesDesc =>
      'योग्य जोडीदार शोधण्यात मदत करण्यासाठी कुटुंब आणि मित्रांसह प्रोफाईल्स शेअर करण्यास सुरुवात करा';

  @override
  String get profilesSharedWithYouDesc =>
      'तुमच्या कुटुंब आणि मित्रांनी तुमच्यासोबत शेअर केलेले प्रोफाईल्स येथे दिसतील';

  @override
  String get enterVillageManually => 'गाव/इतर नाव प्रविष्ट करा';

  @override
  String get enterVillageHint => 'गाव किंवा तांडाचे नाव प्रविष्ट करा...';

  @override
  String get specificLocation => 'विशिष्ट स्थान';

  @override
  String get skipAndSelectLevel => 'वगळा आणि तालुका/जिल्हा निवडा';

  @override
  String get optional => 'पर्यायी';

  @override
  String get tourMatchesSearchTitle => 'शेअर केलेले प्रोफाइल्स शोधा';

  @override
  String get tourMatchesSearchDesc =>
      'नाव किंवा शिक्षण वापरून तुमच्याशी शेअर केलेले किंवा तुम्ही शेअर केलेले प्रोफाइल्स पटकन शोधा.';

  @override
  String get tourMatchesSentTitle => 'पाठवलेले प्रोफाइल्स';

  @override
  String get tourMatchesSentDesc =>
      'तुम्ही कुटुंब आणि मित्रांसोबत शेअर केलेले सर्व प्रोफाइल्स येथे दिसतात.';

  @override
  String get tourMatchesReceivedTitle => 'प्राप्त प्रोफाइल्स';

  @override
  String get tourMatchesReceivedDesc =>
      'इतरांनी व्हॉट्सअप किंवा लिंकद्वारे तुमच्यासोबत शेअर केलेले प्रोफाइल्स.';

  @override
  String get tourMatchesMatchedTitle => 'जुळलेले प्रोफाइल्स';

  @override
  String get tourMatchesMatchedDesc =>
      'परस्पर सामने जिथे तुम्ही आणि दुसऱ्या व्यक्ती दोघांनीही रस व्यक्त केला!';

  @override
  String get tourProfilePhotosTitle => 'फोटो व्यवस्थापित करा';

  @override
  String get tourProfilePhotosDesc =>
      'उत्तम प्रभाव पाडण्यासाठी तुमचे प्रोफाइल फोटो अपलोड करा, क्रम बदला किंवा काढून टाका.';

  @override
  String get tourProfileTrustTitle => 'ट्रस्ट स्कोअर';

  @override
  String get tourProfileTrustDesc =>
      'तुमचा विश्वासार्हता स्कोअर. तो वाढवण्यासाठी तुमचे आयडी, सेल्फी आणि समुदाय सत्यापित करा.';

  @override
  String get tourProfilePdfTitle => 'बायोडेटा PDF एक्सपोर्ट करा';

  @override
  String get tourProfilePdfDesc =>
      'तुमच्या बायोडेटाची व्यावसायिक PDF तयार करा आणि कुटुंबातील सदस्यांसह शेअर करा.';

  @override
  String get tourProfileSavedTitle => 'जतन केलेले प्रोफाइल्स';

  @override
  String get tourProfileSavedDesc =>
      'नंतर पुनरावलोकनासाठी तुम्ही बुकमार्क केलेले सर्व प्रोफाइल्स पहा.';

  @override
  String get tourProfileEditTitle => 'प्रोफाइल संपादित करा';

  @override
  String get tourProfileEditDesc =>
      'तुमचे वैयक्तिक तपशील, फोटो आणि आवडीनिवडी केव्हाही अपडेट करा.';

  @override
  String get basicPlanName => 'बेसिक';

  @override
  String get premiumPlanName => 'प्रीमियम';

  @override
  String get vipPlanName => 'व्हीआयपी';

  @override
  String get basicPlanDesc => 'तुमच्या शोधासाठी आवश्यक वैशिष्ट्ये';

  @override
  String get premiumPlanDesc => 'प्रगत वैशिष्ट्ये आणि चांगली दृश्यता';

  @override
  String get vipPlanDesc => 'प्राधान्य समर्थनासह उत्कृष्ट अनुभव';

  @override
  String get paymentSuccessfulPdfUnlocked => 'पेमेंट यशस्वी झाले! PDF अनलॉक.';

  @override
  String get standardPlanName => 'स्टैंडर्ड';

  @override
  String get standardPlanDesc =>
      'एक महिन्यासाठी प्रीमियम वैशिष्ट्ये वापरून पहा';

  @override
  String get eternalPlanName => 'इटर्नल - लग्नापर्यंत';

  @override
  String get eternalPlanDesc => 'कालबाह्य होण्याची चिंता पुन्हा कधीही करू नका';

  @override
  String get elitePlanName => 'एलीट';

  @override
  String get elitePlanDesc => 'व्हीआयपी प्रवेशासह निवडक सामने';

  @override
  String get royalPlanName => 'रॉयल';

  @override
  String get royalPlanDesc => 'समर्पित व्यवस्थापक तुमचा जोडीदार शोधतो';

  @override
  String get eternalElitePlanName => 'इटर्नल एलीट';

  @override
  String get eternalElitePlanDesc =>
      'तुमच्या करिअरवर लक्ष केंद्रित करा, आम्ही तुमचा जोडीदार शोधू';

  @override
  String get selfServicePlans => 'स्वयं सेवा';

  @override
  String get vipMatchmaker => 'व्हीआयपी मॅचमेकर';

  @override
  String get tillUMarry => 'लग्नापर्यंत';

  @override
  String get lifetime => 'आजीवन';

  @override
  String mrpPrice(int price) {
    return 'MRP ₹$price';
  }

  @override
  String bulkDiscount(int percent) {
    return '$percent% सूट';
  }

  @override
  String youSave(int amount) {
    return 'तुम्ही वाचवता ₹$amount';
  }

  @override
  String totalSavings(int amount) {
    return 'एकूण बचत: ₹$amount';
  }

  @override
  String get trustDiscountApplied => 'ट्रस्ट स्कोअर सवलत लागू';

  @override
  String get couponDiscountApplied => 'कूपन सवलत लागू';

  @override
  String contactUnlocks(int count) {
    return '$count संपर्क अनलॉक/महिना';
  }

  @override
  String handpickedMatches(int count) {
    return '$count निवडक सामने/आठवडा';
  }

  @override
  String get dedicatedManager => 'समर्पित संबंध व्यवस्थापक';

  @override
  String get profileMakeover => 'व्यावसायिक प्रोफाइल मेकओव्हर';

  @override
  String get featuredBadge => 'एलीट सत्यापित बॅज';

  @override
  String get featuresIncluded => 'समाविष्ट वैशिष्ट्ये:';

  @override
  String get incognitoMode => 'खाजगी प्रोफाइल ब्राउझिंग';

  @override
  String get biodataPremiumIncluded => 'बायोडेटा प्रीमियम समाविष्ट आहे';

  @override
  String get unlimitedContactUnlocks => 'अमर्यादित संपर्क अनलॉक';

  @override
  String get unlimitedHandpickedMatches => 'दैनंदिन ऑन-डिमांड सामने';

  @override
  String get weeklyCheckIn => 'साप्ताहिक चेक-इन';

  @override
  String get monthlyCheckIn => 'मासिक चेक-इन';

  @override
  String get bestValue => 'सर्वोत्तम मूल्य';

  @override
  String get personalConcierge => 'वैयक्तिक मदतनीस';

  @override
  String get vipFeatures => 'व्हीआयपी वैशिष्ट्ये';

  @override
  String get directContactAccess => 'थेट संपर्क एक्सेस';

  @override
  String get focusOnCareer =>
      'तुमच्या करिअरवर लक्ष केंद्रित करा, आम्ही तुमचा जोडीदार शोधतो';

  @override
  String get perMonth => '/महिना';

  @override
  String get forLifetime => 'आजीवनासाठी';

  @override
  String get emailNotifications => 'ईमेल सूचनाएं';

  @override
  String get dailyMatchPicks => 'दैनिक मैच पिक्स';

  @override
  String get newMatchAlerts => 'नया मैच अलर्ट';

  @override
  String extraViewsUnlocked(int count) {
    return '$count अतिरिक्त व्ह्यू दाखवले!';
  }

  @override
  String get sendHeartInterested =>
      'तुम्ही उत्सुक आहात हे दाखवण्यासाठी हार्ट पाठवा.';

  @override
  String get notMatchedCannotMessage =>
      'तुम्ही या प्रोफाइलशी जुळलेले नाही, म्हणून तुम्ही त्यांना थेट संदेश पाठवू शकत नाही.';

  @override
  String get oneMessageUnlocked => '१ मेसेज अनलॉक झाला!';

  @override
  String get seenAllProfiles => 'तुम्ही सर्व प्रोफाइल पाहिली आहेत!';

  @override
  String get signInRequired => 'साइन इन करणे आवश्यक आहे';

  @override
  String get signInRequiredContent =>
      'कृपया या सुविधेचा वापर करण्यासाठी साइन इन करा किंवा खाते तयार करा.';

  @override
  String get watchAdToUnlock => 'अनलॉक करण्यासाठी जाहिरात पहा';

  @override
  String get watchAdToUnlockAll => 'सर्व अनलॉक करण्यासाठी जाहिरात पहा';

  @override
  String get goProAdFree => 'जाहिरात-मुक्त अनुभवासाठी प्रो व्हा';

  @override
  String get adNotReady =>
      'जाहिरात अद्याप तयार नाही. कृपया थोड्या वेळाने पुन्हा प्रयत्न करा.';

  @override
  String get upgradeToUnlockPremiumFeatures =>
      'सर्व जाहिराती काढण्यासाठी आणि प्रीमियम बायोडाटा वैशिष्ट्ये अनलॉक करण्यासाठी अपग्रेड करा.';

  @override
  String get couldNotLaunchWhatsApp => 'व्हॉट्सॲप सुरू करता आले नाही';

  @override
  String get couldNotLaunchDialer => 'फोन डायलर सुरू करता आला नाही';

  @override
  String get searchLeads => 'लीड्स शोधा...';

  @override
  String get workspace => 'वर्कस्पेस';

  @override
  String get customMessage => 'सानुकूल संदेश';

  @override
  String get logCallOutcome => 'कॉलचा निकाल नोंदवा';

  @override
  String get apply => 'लागू करा';

  @override
  String get registrationFee => 'नोंदणी शुल्क';

  @override
  String get unverified => 'असत्यापित';

  @override
  String get signIn => 'साइन इन करा';

  @override
  String unlockMoreVisitors(int count) {
    return 'अनलॉक करा $count आणखी अभ्यागत!';
  }

  @override
  String get dailyLimitReached => 'दैनिक मर्यादा संपली';

  @override
  String get dailyLimitViewsReached =>
      'तुम्ही तुमची सर्व दैनिक प्रोफाइल दृश्ये वापरली आहेत.';

  @override
  String get unlockMoreViewsAd =>
      'आजसाठी आणखी ५ दृश्ये अनलॉक करण्यासाठी एक संक्षिप्त जाहिरात पहा!';

  @override
  String get directMessage => 'थेट संदेश';

  @override
  String get directMessagingPremium =>
      'थेट संदेश पाठवणे हे एक प्रीमियम वैशिष्ट्य आहे.';

  @override
  String get unlockDirectMessageAd =>
      '१ थेट संदेश विनामूल्य अनलॉक करण्यासाठी ३ जाहिराती पहा!';

  @override
  String get premiumAccess => 'प्रीमियम ॲक्सेस';

  @override
  String get premiumGateSupport =>
      'त्वरित जाहिरात पाहून आमच्या समुदायाला पाठिंबा द्या,\nकिंवा जाहिरात-मुक्त अनुभवासाठी प्रो मध्ये अपग्रेड करा.';

  @override
  String get unblockAllProFeatures => 'सर्व प्रो वैशिष्ट्ये अनलॉक करा';

  @override
  String get monthly => 'मासिक';

  @override
  String get annual => 'वार्षिक';

  @override
  String get watchQuickAd => 'त्वरित जाहिरात पहा';

  @override
  String get continueBlockedUntilAdEnds =>
      'जाहिरात संपेपर्यंत ॲप सुरू ठेवता येणार नाही';

  @override
  String get adCompletedSuccessfully => 'जाहिरात यशस्वीरित्या पूर्ण झाली';

  @override
  String get continueToApp => 'ॲपवर सुरू ठेवा';

  @override
  String get preparingAdExperience => 'जाहिरात अनुभव तयार करत आहे...';

  @override
  String get adTemporarilyUnavailable => 'जाहिरात तात्पुरती अनुपलब्ध आहे';

  @override
  String get callAdmin => 'अ‍ॅडमिनला कॉल करा';

  @override
  String get banjaraBioPro => 'बंजाराबायो प्रो';

  @override
  String get claimMarriageGift => 'लग्नाच्या भेटीचा दावा करा';

  @override
  String get tellUsYourStory => 'आम्हाला तुमची कथा सांगा';

  @override
  String get partnerName => 'जोडीदाराचे नाव';

  @override
  String get yourSuccessStory => 'तुमची यशोगाथा';

  @override
  String get howDidYouMeet =>
      'तुम्ही कसं भेटलात? तुम्हाला त्यांच्याबद्दल काय आवडतं?';

  @override
  String get proofOfMarriage => 'लग्नाचा पुरावा';

  @override
  String get instagramLink => 'इन्स्टाग्राम रील/स्टोरी लिंक';

  @override
  String get pasteUrlHere => 'येथे यूआरएल पेस्ट करा';

  @override
  String get weddingDate => 'लग्नाची तारीख';

  @override
  String get estimatedRefund => 'अंदाज रिफंड';

  @override
  String get submitForReview => 'पुनरावलोकनासाठी सबमिट करा';

  @override
  String get selectRewardType => 'भेट प्रकार निवडा';

  @override
  String get digital => 'डिजिटल';

  @override
  String get refund25 => '25% रिफंड';

  @override
  String get teamVisit => 'टीम भेट';

  @override
  String get refund35 => '35% रिफंड';

  @override
  String get successSubmission =>
      'यश! तुमची विनंती पुनरावलोकनासाठी सबमिट केली गेली आहे.';

  @override
  String get melavas => 'मेळावे';

  @override
  String get upcomingMelavas => 'आगामी मेळावे';

  @override
  String get callOrganizer => 'आयोजकाला कॉल करा';

  @override
  String get viewVenue => 'ठिकाण पहा';

  @override
  String get organizer => 'आयोजक';

  @override
  String get venue => 'ठिकाण';

  @override
  String get eventDetails => 'कार्यक्रमाची माहिती';

  @override
  String get browseMatchesTitle => '🔍 स्थळ शोधा (Browse Matches)';

  @override
  String get browseMatchesDesc =>
      'मुलगा, मुलगी, नातेवाईक यांच्यासाठी योग्य स्थळ शोधा.';

  @override
  String get browseMatchesSubtitle =>
      'काही प्रश्नांची उत्तरे द्या आणि योग्य स्थळे पहा';

  @override
  String get forWhomSearching => 'कोणासाठी स्थळ शोधत आहात?';

  @override
  String get lookingForGender => 'वर हवा की वधू हवी?';

  @override
  String get groomBoy => '👦 वर (Groom)';

  @override
  String get brideGirl => '👧 वधू (Bride)';

  @override
  String get selectDistrict => 'जिल्हा निवडा';

  @override
  String get proceedToLogin => 'पुढे जा → लॉग इन करा';

  @override
  String get sibling => 'भाऊ/बहीण';
}
