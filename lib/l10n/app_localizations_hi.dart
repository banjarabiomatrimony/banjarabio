// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get genderSelectHeading => 'आपका लिंग है';

  @override
  String get replacePhoto => 'फोटो बदलें';

  @override
  String get errorLoadingAdminStats =>
      'डैशबोर्ड आँकड़े लोड करने में असमर्थ। कृपया रिफ्रेश करने का प्रयास करें।';

  @override
  String get errorLoadingAdminUsers =>
      'उपयोगकर्ता सूची प्राप्त नहीं की जा सकी। कृपया अपना कनेक्शन जांचें।';

  @override
  String get errorLoadingAdminPayments =>
      'भुगतान इतिहास लोड करने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get errorLoadingAdminVerifications =>
      'सत्यापन अनुरोध लोड नहीं किए जा सके। कृपया पुनः प्रयास करें।';

  @override
  String get errorLoadingAdminReferences =>
      'लंबित संदर्भ प्राप्त करने में असमर्थ। कृपया रिफ्रेश करें।';

  @override
  String get errorLoadingAdminCoupons =>
      'कूपन ऑफ़र लोड करने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get errorLoadingAdminCreators =>
      'निर्माता सूची प्राप्त नहीं की जा सकी। कृपया अपना नेटवर्क जांचें।';

  @override
  String get errorAdminActionFailed =>
      'अनुरोधित कार्य पूरा नहीं किया जा सका। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get expressInterest => 'रुचि व्यक्त करें?';

  @override
  String interestConfirmationDesc(String name) {
    return 'क्या आप अपनी रुचि दिखाने के लिए $name के साथ अपनी प्रोफ़ाइल साझा करना चाहते हैं?';
  }

  @override
  String get yesInterest => 'हाँ, रुचि है';

  @override
  String get interest => 'रुचि';

  @override
  String get revenueToday => 'आज का राजस्व (₹)';

  @override
  String get premiumMen => 'प्रीमियम पुरुष';

  @override
  String get premiumWomen => 'प्रीमियम महिलाएं';

  @override
  String get financialPerformance => 'वित्तीय प्रदर्शन';

  @override
  String get demographicsAndPremium => 'जनसांख्यिकी और प्रीमियम';

  @override
  String get revenueTotal => 'कुल राजस्व (₹)';

  @override
  String get monthlyRevenue => 'मासिक राजस्व (₹)';

  @override
  String get pdfRevenue => 'PDF राजस्व (₹)';

  @override
  String get userEngagement => 'उपयोगकर्ता सहभागिता';

  @override
  String get dailyActiveUsers => 'दैनिक सक्रिय उपयोगकर्ता';

  @override
  String get profileViews => 'प्रोफ़ाइल दृश्य';

  @override
  String get totalMessages => 'कुल संदेश';

  @override
  String get safetyAndHealth => 'सुरक्षा और स्वास्थ्य';

  @override
  String get pendingReports => 'लंबित रिपोर्ट';

  @override
  String get totalBlocks => 'कुल ब्लॉक';

  @override
  String get pendingReferences => 'लंबित संदर्भ';

  @override
  String get totalUsers => 'कुल उपयोगकर्ता';

  @override
  String get profiles => 'प्रोफ़ाइल';

  @override
  String get appGrowth => 'ऐप प्रगति';

  @override
  String get completedReferrals => 'पूरे हुए रेफरल';

  @override
  String get activeCreators => 'सक्रिय निर्माता';

  @override
  String get totalFemales => 'कुल महिलाएँ';

  @override
  String get totalMales => 'कुल पुरुष';

  @override
  String get men => 'पुरुष';

  @override
  String get women => 'महिलाएँ';

  @override
  String get sharingProfiles => 'प्रोफ़ाइल साझा करना';

  @override
  String get sharingProfile => 'प्रोफ़ाइल साझा कर रहे हैं...';

  @override
  String get referenceVerified => 'संदर्भ सत्यापित';

  @override
  String get referenceRejected => 'संदर्भ अस्वीकृत';

  @override
  String get aboutSelf => 'स्वयं के बारे में';

  @override
  String get aboutYourself => 'अपने बारे में';

  @override
  String get abusiveBehavior => 'अपमानजनक व्यवहार';

  @override
  String get account => 'खाता';

  @override
  String get accountAndAllDataDeletedSuccessfully =>
      'खाता और सारा डेटा सफलतापूर्वक हटा दिया गया.';

  @override
  String get accountDeletion => 'खाता हटाना';

  @override
  String get actionIsIrreversible => 'यह क्रिया अपरिवर्तनीय है।';

  @override
  String get activeSubscriptionCancelledNoRefund =>
      'आपकी सक्रिय सदस्यता बिना किसी वापसी के रद्द कर दी जाएगी।';

  @override
  String get adFreeExperience => 'विज्ञापन-मुक्त अनुभव';

  @override
  String addClearPhotos(String max) {
    return 'साफ़ तस्वीरें जोड़ें (अधिकतम $max)';
  }

  @override
  String get addPhoto => 'फ़ोटो जोड़ें';

  @override
  String get addPhotosToYourBiodataProfileToIncreaseV =>
      'दृश्यता और विश्वास बढ़ाने के लिए अपने बायोडाटा प्रोफ़ाइल में फ़ोटो जोड़ें';

  @override
  String get addSibling => 'भाई-बहन जोड़ें';

  @override
  String get addTwoReferences => 'दो संदर्भ जोड़ें';

  @override
  String get addYourBrothersAndSisters => 'अपने भाइयों और बहनों को जोड़ें';

  @override
  String get addYourFirstPhoto => 'अपना पहला फ़ोटो जोड़ें';

  @override
  String get additionalPreferences => 'अतिरिक्त प्राथमिकताएं';

  @override
  String get additionalProfessionalInfo => 'अतिरिक्त पेशेवर जानकारी';

  @override
  String get adjust => 'समायोजित करना';

  @override
  String get adjustFilters => 'फ़िल्टर समायोजित करें';

  @override
  String get adminDashboard => 'एडमिन डैशबोर्ड';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get adminLoginRequiresAuthorizedCredentials =>
      'व्यवस्थापक लॉगिन के लिए अधिकृत क्रेडेंशियल की आवश्यकता होती है';

  @override
  String get adminManagement => 'प्रशासनिक प्रबंधन';

  @override
  String get adminPortal => 'व्यवस्थापक पोर्टल';

  @override
  String get advancedFilters => 'उन्नत फिल्टर';

  @override
  String get affluent => 'समृद्ध';

  @override
  String get age => 'आयु';

  @override
  String get ageRange => 'आयु सीमा';

  @override
  String get aiBio => 'AI बायो';

  @override
  String allInDistrict(String district) {
    return '$district में सभी';
  }

  @override
  String get allInSelectedDistrict => 'All in selected District';

  @override
  String get allInSelectedState => 'All in selected State';

  @override
  String allInState(String state) {
    return '$state में सभी';
  }

  @override
  String get allIndia => 'अखिल भारतीय';

  @override
  String allPhotosCount(int count, int max) {
    return 'सभी तस्वीरें ($count/$max)';
  }

  @override
  String get allYourProfileDataPermanentlyRemoved =>
      'आपका सारा प्रोफ़ाइल डेटा स्थायी रूप से हटा दिया जाएगा।';

  @override
  String get almostDone => 'लगभग पूरा हो गया!';

  @override
  String get almostDoneReview =>
      'सभी अनुभागों की समीक्षा करें और अपनी प्रोफ़ाइल पूरी करने के लिए \"बायोडेटा सहेजें\" पर क्लिक करें। आपका बायोडेटा आपकी गोपनीयता सेटिंग्स के आधार पर अन्य समुदाय के सदस्यों को दिखाई देगा।';

  @override
  String anErrorOccurred(Object error) {
    return 'एक त्रुटि हुई: $error';
  }

  @override
  String get and => ' और ';

  @override
  String get annualIncome => 'स्वयं की वार्षिक आय (Self Annual Income)';

  @override
  String get annualIncomeHint =>
      'केवल आपकी सालाना कमाई (जैसे सैलरी/धंधा)। घर की पूरी सेविंग या बैंक बैलेंस न डालें।';

  @override
  String get annulled => 'रद्द किया गया';

  @override
  String get appName => 'बंजारा बायो';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get approve => 'मंज़ूरी देना';

  @override
  String get areYouReadyForDiscussions => 'क्या आप चर्चा के लिए तैयार हैं?';

  @override
  String areYouSureDeleteSelectedPhotos(int count) {
    return 'क्या आप वाकई $count फोटो हटाना चाहते हैं?';
  }

  @override
  String get areYouSureExit => 'क्या आप ऐप बंद करना चाहते हैं?';

  @override
  String get areYouSureLogout => 'क्या आप लॉगआउट करना चाहते हैं?';

  @override
  String get areYouSureYouWantToBlockThisUserYouWillN =>
      'क्या वाकई आपको इस प्रयोगकर्ता को ब्लॉक करना है? आप उनकी प्रोफ़ाइल दोबारा नहीं देख पाएंगे.';

  @override
  String get areYouSureYouWantToDeleteThisPhoto =>
      'क्या आप निश्चित हैं कि आप इस फ़ोटो को हटाना चाहते हैं?';

  @override
  String get areYouSureYouWantToDeleteYourAccount =>
      'क्या आप इस खाते को हटाने के लिए सुनिश्चित हैं?';

  @override
  String get askFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get atLeastOnePhotoRequired => 'कम से कम एक फोटो आवश्यक है';

  @override
  String get awaitingDivorce => 'तलाक प्रतीक्षाधीन';

  @override
  String get bachelorsDegree => 'बैचलर डिग्री';

  @override
  String get back => 'वापस';

  @override
  String get backSide => 'पीछे का हिस्सा';

  @override
  String get backToGoogleSignIn => 'Google साइन इन पर वापस जाएं';

  @override
  String get banjaraMember => 'बंजारा सदस्य';

  @override
  String get banjarabio => 'BanjaraBio';

  @override
  String get biodataDraftRestored => 'बायोडेटा ड्राफ्ट बहाल किया गया!';

  @override
  String get biodataDraftRestoredSuccess =>
      'Biodata draft restored successfully!';

  @override
  String get biodataPdf => 'बायोडाटा PDF';

  @override
  String get biodataSavedSuccessfully => 'बायोडाटा सफलतापूर्वक सेव हो गया!';

  @override
  String get biodataUnlockPlanDesc => 'प्रोफेशनल प्रीमियम टेम्प्लेट अनलॉक करें';

  @override
  String get biodataUnlockPlanName => 'प्रीमियम बायोडेटा';

  @override
  String get birthDetails => 'अतिरिक्त जन्म विवरण';

  @override
  String get birthPlace => 'जन्म स्थान';

  @override
  String get birthPlaceAndTime => 'जन्म स्थान और समय';

  @override
  String get birthTime => 'जन्म समय';

  @override
  String get block => 'ब्लॉक करें';

  @override
  String get blockUser => 'खंड उपयोगकर्ता';

  @override
  String get bloodGroup => 'रक्त समूह';

  @override
  String get blurryLowQualityImages =>
      'धुंधली, गहरी या कम गुणवत्ता वाली छवियां';

  @override
  String get bookmarkLimitReached => 'बुकमार्क की सीमा पूरी हो गई';

  @override
  String get messagingLimitReached => 'संदेश भेजने की सीमा समाप्त';

  @override
  String bookmarksCount(String count) {
    return '$count बुकमार्क';
  }

  @override
  String get bronze => 'कांस्य';

  @override
  String get brother => 'भाई';

  @override
  String get brotherCount => 'भाई';

  @override
  String get browseProfiles => 'प्रोफ़ाइल ब्राउज़ करें';

  @override
  String get business => 'व्यवसाय';

  @override
  String get businessOwner => 'व्यवसाय मालिक';

  @override
  String get byContAcceptTerms => 'जारी रखकर, आप हमारी ';

  @override
  String get camera => 'कैमरा';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get cancelAnytime => 'किसी भी समय रद्द करें';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get chat => 'चैट';

  @override
  String get checkBackSoonForNewMatchesnpullDownToRef =>
      'नए मैचों के लिए जल्द ही दोबारा जाँचें।\nरीफ्रेश करने के लिए नीचे खींचें।';

  @override
  String get checkInbox => 'Check Inbox';

  @override
  String get checkInternet =>
      'कृपया अपना इंटरनेट कनेक्शन जाँचें और पुनः प्रयास करें।';

  @override
  String get checkWhoIsLookingAtYourProfile =>
      'जांचें कि आपकी प्रोफ़ाइल कौन देख रहा है';

  @override
  String get chooseFromGallery => 'गैलरी से चुनें';

  @override
  String get chooseTemplate => 'टेम्पलेट चुनें';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get clearAllFilters => 'सभी फ़िल्टर साफ़ करें';

  @override
  String get clearWellLitPhotos =>
      'स्पष्ट, अच्छी रोशनी वाली तस्वीरें जिनमें आपका चेहरा साफ दिखे';

  @override
  String get close => 'बंद करें';

  @override
  String get comeBackTomorrowFornnewCuratedMatches =>
      'नए क्यूरेटेड मैचों के लिए कल वापस आएँ!';

  @override
  String get communityId => 'Community ID';

  @override
  String get communityIdSubmitted => 'सामुदायिक आईडी जमा की गई';

  @override
  String get communityIdVerification => 'समुदाय पहचान पत्र';

  @override
  String get communityMember => 'Community Member';

  @override
  String get communityVerification => 'सामुदायिक सत्यापन';

  @override
  String get companyName => 'कंपनी का नाम';

  @override
  String get completeVerificationToUnlockPremium =>
      '\'Premium\' स्थिति अनलॉक करने के लिए सत्यापन पूरा करें।';

  @override
  String get completeYourProfileToGetNoticed =>
      'ध्यान आकर्षित करने के लिए अपनी प्रोफ़ाइल पूरी करें!';

  @override
  String get completion => 'समापन';

  @override
  String get complexion => 'रंग';

  @override
  String get compressingUnder500Kb => 'Compressing under 500KB...';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get connectInApp => 'इन-ऐप कनेक्ट';

  @override
  String get connectWithCommunity => 'अपने बंजारा समुदाय से जुड़ें';

  @override
  String get contact => 'संपर्क';

  @override
  String get contactPreferences => 'संपर्क प्राथमिकताएं';

  @override
  String get contactUs => 'हमसे संपर्क करें';

  @override
  String get contactUsTitle => 'हमसे संपर्क करें';

  @override
  String get continueWithFreeAccount => 'मुफ़्त खाते के साथ जारी रखें';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get conversations => 'बातचीत';

  @override
  String get copyLink => 'लिंक कॉपी करें';

  @override
  String copyLinkSubtitle(String name) {
    return '$name की प्रोफ़ाइल का लिंक कॉपी करें';
  }

  @override
  String get couldNotLoadProfile =>
      'हम आपकी प्रोफ़ाइल लोड नहीं कर सके. कृपया पुन: प्रयास करें।';

  @override
  String get createBiodata => 'बायोडाटा बनाएं';

  @override
  String get createProfile => 'प्रोफ़ाइल बनाएं';

  @override
  String criticalFailure(Object error) {
    return 'महत्वपूर्ण विफलता: $error';
  }

  @override
  String get cropPhoto => 'फसल तस्वीर';

  @override
  String get cropRotate => 'काटें और घुमाएँ';

  @override
  String curatedProfilesJustForYou(int count) {
    return '$count आपके लिए चुने गए प्रोफाइल';
  }

  @override
  String get currentLocation => 'वर्तमान स्थान';

  @override
  String get currentPlan => 'वर्तमान प्लान';

  @override
  String get currentResidenceState => 'वर्तमान निवास राज्य';

  @override
  String get currentVillageHint => 'वर्तमान गांव';

  @override
  String get customizeBiodata => 'बायोडाटा अनुकूलित करें';

  @override
  String get daily => 'दैनिक';

  @override
  String get dailyMatch => 'दैनिक मैच';

  @override
  String get dark => 'गहरा';

  @override
  String get dateOfBirth => 'जन्म तिथि';

  @override
  String get daughter => 'बेटी';

  @override
  String daysAgo(String count) {
    return '$countदि पहले';
  }

  @override
  String daysLeft(Object days) {
    return '$days दिन शेष';
  }

  @override
  String daysRemaining(Object days) {
    return '$days दिन शेष';
  }

  @override
  String get delete => 'हटाएं';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountWarning =>
      'यह कार्रवाई स्थायी है और पूर्ववत नहीं की जा सकती।';

  @override
  String deleteCount(Object count) {
    return 'हटाएं ($count)';
  }

  @override
  String get deleteMyAccount => 'मेरा खाता हटाएं';

  @override
  String get deletePhoto => 'फ़ोटो हटाएं';

  @override
  String get deletePhotos => 'फ़ोटो हटाएँ';

  @override
  String deleteSelectedSharesQuery(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'क्या आप वाकई $count चयनित शेयरों को हटाना चाहते हैं?',
      one: 'क्या आप वाकई चयनित शेयर को हटाना चाहते हैं?',
    );
    return '$_temp0';
  }

  @override
  String get deleteShares => 'शेयर हटाएँ';

  @override
  String get deletingYourAccountWillResultIn =>
      'आपका खाता हटाने का परिणाम यह होगा:';

  @override
  String get demo => 'डेमो';

  @override
  String get describeYourselfInterestsHobbies =>
      'अपना, रुचियों का, शौक का वर्णन करें...';

  @override
  String get details => 'विवरण';

  @override
  String get differentSettingsTip =>
      'विभिन्न सेटिंग्स (औपचारिक, अनौपचारिक) में तस्वीरें शामिल करें';

  @override
  String get diploma => 'डिप्लोमा';

  @override
  String get directMessaging => 'सीधा संदेश';

  @override
  String get disabledHint => 'विकलांगों के लिए वैकल्पिक जानकारी';

  @override
  String get disabledTagLabel => 'विकलांग';

  @override
  String get discard => 'रद्द करें';

  @override
  String get discardChanges => 'बदलाव रद्द करें?';

  @override
  String get discardChangesBody =>
      'क्या आप वापस जाना चाहते हैं? आपकी प्रगति ड्राफ्ट के रूप में सेव है।';

  @override
  String discountPercentage(Object percentage, Object score) {
    return '$percentage% छूट (ट्रस्ट स्कोर $score)';
  }

  @override
  String get discoverProfilesFromYourCommunityNsmartM =>
      'अपने समुदाय से प्रोफ़ाइल खोजें।\\nसंगतता स्कोर द्वारा संचालित स्मार्ट मैचमेकिंग।';

  @override
  String get district => 'ज़िला';

  @override
  String districtInState(String state) {
    return '$state में जिला';
  }

  @override
  String get districtInStateLabel => 'District in State';

  @override
  String get divorced => 'तलाकशुदा';

  @override
  String get doctorate => 'डॉक्टरेट';

  @override
  String get documentProofs => 'दस्तावेज़ प्रमाण:';

  @override
  String get documentType => 'दस्तावेज़ प्रकार';

  @override
  String get documentView => 'दस्तावेज़ देखें';

  @override
  String get done => 'हो गया';

  @override
  String get downloadBtn => 'डाउनलोड करना';

  @override
  String get dusky => 'सांवला';

  @override
  String get easiest => 'सबसे आसान';

  @override
  String get edit => 'संपादन करना';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get education => 'शिक्षा';

  @override
  String get educationAndProfession => 'शिक्षा और व्यवसाय';

  @override
  String get educationDetails => 'शिक्षा विवरण';

  @override
  String get educationLabel => 'शिक्षा';

  @override
  String get educationProfession => 'Education & Profession';

  @override
  String get educationProfessionDetails => 'शिक्षा और करियर';

  @override
  String get educationalQualification => 'शैक्षिक योग्यता';

  @override
  String get egSeniorSoftwareEngineer => 'उदा. सीनियर सॉफ्टवेयर इंजीनियर';

  @override
  String get egSpecialization => 'उदा. विशेषज्ञता या ऑनर्स';

  @override
  String get egSpecializationOrHonors => 'उदा. विशेषज्ञता या सम्मान';

  @override
  String get egTime => 'उदा. सुबह 10:30 बजे';

  @override
  String get elderBrother => 'बड़े भाई';

  @override
  String get elderSister => 'बड़ी बहन';

  @override
  String get email => 'ईमेल';

  @override
  String get emailAddress => 'मेल पता';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailSupport => 'ई - मेल समर्थन';

  @override
  String get emailVerification => 'ईमेल सत्यापन';

  @override
  String get emailVerificationTip =>
      'Tip: Check your spam folder if you don\'t see the email.';

  @override
  String get emailVerifiedSuccessfully10Points =>
      'ईमेल सफलतापूर्वक सत्यापित! +10 अंक';

  @override
  String get emptyStr => '₹';

  @override
  String get english => 'English';

  @override
  String get enterBasicInfo =>
      'अपनी बुनियादी जानकारी आधिकारिक दस्तावेज़ों के अनुसार दर्ज करें';

  @override
  String get enterCityVillage => 'शहर/गांव दर्ज करें';

  @override
  String get enterEducationDetails => 'अपनी शिक्षा विवरण दर्ज करें';

  @override
  String get enterFullName => 'अपना पूरा नाम दर्ज करें';

  @override
  String get enterMobileNumber => 'Enter mobile number';

  @override
  String get enterProfessionDetails => 'अपना व्यवसाय विवरण दर्ज करें';

  @override
  String get enterYourBasicInformationAsItAppearsInOf =>
      'अपनी बुनियादी जानकारी वैसे ही दर्ज करें जैसी वह आधिकारिक दस्तावेज़ों में दिखाई देती है';

  @override
  String get enterYourEducationDetails => 'Enter your education details';

  @override
  String get enterYourEmail => 'अपना ईमेल दर्ज करें';

  @override
  String get enterYourPassword => 'अपना पासवर्ड दर्ज करें';

  @override
  String get enterYourProfessionDetails => 'Enter your profession details';

  @override
  String get error => 'गलती';

  @override
  String errorCheckingShareLimits(String error) {
    return 'शेयर सीमा की जांच करने में त्रुटि: $error';
  }

  @override
  String errorCheckingStatus(String error) {
    return 'Error checking status: $error';
  }

  @override
  String errorCheckingViewLimits(String error) {
    return 'व्यू सीमा की जांच करने में त्रुटि: $error';
  }

  @override
  String errorLoadingAdminData(String error) {
    return 'एडमिन डेटा लोड करने में त्रुटि: $error';
  }

  @override
  String errorLoadingRequests(String error) {
    return 'अनुरोध लोड करने में त्रुटि: $error';
  }

  @override
  String errorOccurred(String error) {
    return 'एक त्रुटि हुई: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get everyProfileIsVerifiedWithIdSelfieRefere =>
      'प्रत्येक प्रोफ़ाइल को आईडी, सेल्फी और संदर्भों के साथ सत्यापित किया जाता है।\\nट्रस्ट स्कोर वास्तविक कनेक्शन सुनिश्चित करता है।';

  @override
  String get exit => 'बाहर निकलें';

  @override
  String get exitApp => 'ऐप बंद करें';

  @override
  String get exportBiodataPdf => 'बायोडाटा पीडीएफ निर्यात करें';

  @override
  String get expressInterestDesc =>
      'अपना बायोडाटा सीधे साझा करके अपनी रुचि व्यक्त करें';

  @override
  String failedLoadProfile(String error) {
    return 'प्रोफ़ाइल लोड नहीं हो सकी: $error';
  }

  @override
  String failedSignInGoogle(String error) {
    return 'Google से साइन इन विफल: $error';
  }

  @override
  String get failedSignInGoogleRetry =>
      'Google से साइन इन विफल। कृपया पुनः प्रयास करें।';

  @override
  String failedToBlockUser(Object error) {
    return 'उपयोगकर्ता को ब्लॉक करने में विफल: $error';
  }

  @override
  String failedToDeleteAccount(Object error) {
    return 'खाता हटाने में विफल: $error';
  }

  @override
  String failedToDeletePhotoError(String error) {
    return 'फोटो हटाने में विफल: $error';
  }

  @override
  String get failedToGeneratePdfPreview =>
      'पीडीएफ पूर्वावलोकन उत्पन्न करने में विफल';

  @override
  String failedToLoadBookmarks(Object error) {
    return 'बुकमार्क लोड करने में विफल: $error';
  }

  @override
  String failedToLoadPhotosError(String error) {
    return 'फोटो लोड करने में विफल: $error';
  }

  @override
  String failedToLoadProfileError(Object error) {
    return 'प्रोफ़ाइल लोड करने में विफल: $error';
  }

  @override
  String get failedToLoadProfileInformation =>
      'प्रोफ़ाइल जानकारी लोड करने में विफल';

  @override
  String get failedToLoadProfiles => 'प्रोफाइल लोड करने में विफल';

  @override
  String get failedToLoadReferralData => 'रेफरल डेटा लोड करने में विफल';

  @override
  String failedToLoadSubscription(String error) {
    return 'सदस्यता लोड करने में विफल: $error';
  }

  @override
  String get failedToLoadTrustScoreStats =>
      'विश्वास स्कोर आँकड़े लोड करने में विफल';

  @override
  String failedToLogout(String error) {
    return 'लॉगआउट विफल: $error';
  }

  @override
  String get failedToPrintPdf => 'पीडीएफ प्रिंट करने में विफल';

  @override
  String get failedToProcessImage => 'Failed to process image';

  @override
  String failedToSave(String error) {
    return 'सेव नहीं हो सका: $error';
  }

  @override
  String failedToSavePdf(String error) {
    return 'पीडीएफ सहेजने में विफल: $error';
  }

  @override
  String failedToSaveProfile(String error) {
    return 'प्रोफ़ाइल सेव नहीं हो सकी: $error';
  }

  @override
  String get failedToSharePdf => 'पीडीएफ साझा करने में विफल';

  @override
  String failedToStartChat(String error) {
    return 'चैट शुरू करने में विफल: $error';
  }

  @override
  String failedToSubmitReport(Object error) {
    return 'रिपोर्ट सबमिट करने में विफल: $error';
  }

  @override
  String failedToUpdateBookmark(Object error) {
    return 'बुकमार्क अपडेट करने में विफल: $error';
  }

  @override
  String failedToUpdatePremiumStatus(String error) {
    return 'प्रीमियम स्थिति अपडेट करने में विफल: $error';
  }

  @override
  String failedToUpdatePrimaryPhotoError(String error) {
    return 'प्राथमिक फोटो अपडेट करने में विफल: $error';
  }

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String failedToUploadPhoto(int index) {
    return 'फ़ोटो $index अपलोड नहीं हो सकी';
  }

  @override
  String failedToVerify(String error) {
    return 'सत्यापित करने में विफल: $error';
  }

  @override
  String get fair => 'गोरा';

  @override
  String get fakeProfile => 'नकली प्रोफ़ाइल';

  @override
  String get familyBackground => 'पारिवारिक पृष्ठभूमि';

  @override
  String get familyDetails => 'पारिवारिक विवरण';

  @override
  String get familyFirstValues => 'परिवार-प्रथम मूल्य';

  @override
  String get familyOnly => 'केवल परिवार';

  @override
  String get familyStatus => 'परिवार की स्थिति';

  @override
  String get familyType => 'परिवार का प्रकार';

  @override
  String get faqA1 =>
      'प्रोफ़ाइल टैब पर जाएं और \"बायोडाटा बनाएं\" पर क्लिक करें या अपनी मौजूदा प्रोफ़ाइल संपादित करें। अपना व्यक्तिगत, पारिवारिक और पेशेवर विवरण भरने के लिए बहु-चरणीय फॉर्म का पालन करें।';

  @override
  String get faqA2 =>
      'हाँ, हम गोपनीयता को गंभीरता से लेते हैं। आपके संपर्क विवरण केवल सत्यापित उपयोगकर्ताओं को दिखाए जाते हैं और हमारे सामुदायिक सुरक्षा दिशानिर्देशों का सम्मान करते हैं।';

  @override
  String get faqA3 =>
      'होम स्क्रीन पर, उम्र, स्थान, शिक्षा और पेशे के आधार पर प्रोफाइल को सीमित करने के लिए \"फ़िल्टर\" बटन का उपयोग करें।';

  @override
  String get faqA4 =>
      'प्रीमियम उपयोगकर्ताओं को असीमित प्रोफ़ाइल दृश्य, नए बायोडाटा तक जल्दी पहुंच और खोज परिणामों में बेहतर दृश्यता मिलती है।';

  @override
  String get faqA5 =>
      'अपने सिस्टम से अपनी प्रोफ़ाइल और डेटा को स्थायी रूप से हटाने के लिए मेरी प्रोफ़ाइल > कानूनी और जानकारी > खाता हटाना पर जाएँ।';

  @override
  String get faqQ1 => 'मैं बायोडाटा कैसे बनाऊं?';

  @override
  String get faqQ2 => 'क्या मेरा डेटा सुरक्षित है?';

  @override
  String get faqQ3 => 'मैं प्रोफाइल कैसे फ़िल्टर कर सकता हूँ?';

  @override
  String get faqQ4 => 'प्रीमियम के क्या लाभ हैं?';

  @override
  String get faqQ5 => 'मैं अपना खाता कैसे हटाऊं?';

  @override
  String get faqTitle => 'सामान्य प्रश्न';

  @override
  String get faqs => 'सामान्य प्रश्न';

  @override
  String get farmer => 'किसान';

  @override
  String get fatherName => 'पिता का नाम';

  @override
  String get fatherOccupation => 'पिता का व्यवसाय';

  @override
  String get feet => 'फीट';

  @override
  String get female => 'महिला';

  @override
  String fieldRequired(String field) {
    return '$field आवश्यक है';
  }

  @override
  String get fifteenToTwentyLakh => '₹15 लाख - ₹20 लाख';

  @override
  String get filtered => '(छाना हुआ)';

  @override
  String get findYourPerfectMatch => 'अपना आदर्श साथी खोजें';

  @override
  String get fiveToSevenHalfLakh => '₹5 लाख - ₹7.5 लाख';

  @override
  String get followAndGetFivePercent => 'फॉलो करें और +5% प्राप्त करें';

  @override
  String get followUsOnInstagramBonus =>
      '5% बायोडेटा पूर्णता बोनस प्राप्त करने और नवीनतम मैचों के साथ अपडेट रहने के लिए हमें इंस्टाग्राम पर फॉलो करें।';

  @override
  String forMonths(Object count) {
    return '$count महीनों के लिए';
  }

  @override
  String get free => 'मुफ्त';

  @override
  String get free1PhotonpremiumUpTo6Photos =>
      'मुफ़्त: 1 फ़ोटो\\nप्रीमियम: 6 फ़ोटो तक';

  @override
  String get freePlanDesc => 'बुनियादी सुविधाओं का प्रयास करें';

  @override
  String get freeUserLimitInfo =>
      'Free user limit reached. Upgrade to continue.';

  @override
  String get freeUsersCanUpload1PhotoUpgradeToUploadU =>
      'नि:शुल्क उपयोगकर्ता 1 फोटो अपलोड कर सकते हैं। अधिकतम 5 फ़ोटो अपलोड करने के लिए अपग्रेड करें।';

  @override
  String get friend => 'दोस्त';

  @override
  String get frontSide => 'सामने का हिस्सा';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get gallery => 'गैलरी';

  @override
  String get gender => 'लिंग';

  @override
  String get generateBio => 'बायो जनरेट करें';

  @override
  String get generatingPreview => 'पूर्वावलोकन जनरेट किया जा रहा है...';

  @override
  String get getAProfessionalWellformattedPdfWithoutW =>
      'बिना वॉटरमार्क और सभी विवरण दृश्यमान एक पेशेवर, अच्छी तरह से प्रारूपित पीडीएफ प्राप्त करें।';

  @override
  String get getInTouchWithUs => 'हमारे साथ जुड़े';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get getStartedLabel => 'शुरू करें';

  @override
  String get go => 'जाएं';

  @override
  String get goBack => 'वापस जाओ';

  @override
  String get gold => 'स्वर्ण';

  @override
  String get goldPlanDesc => 'सबसे लोकप्रिय - सर्वोत्तम मूल्य';

  @override
  String get goldPlanName => 'गोल्ड';

  @override
  String get goldVerified => 'Gold Verified';

  @override
  String get gotIt => 'समझ गया';

  @override
  String get gotra => 'गोत्र';

  @override
  String get governmentEmployee => 'सरकारी कर्मचारी';

  @override
  String get governmentId => 'सरकारी आईडी';

  @override
  String get governmentIdVerification => 'सरकारी आईडी सत्यापन';

  @override
  String get governmentIdVerificationSubtitle =>
      '\'Verified\' बैज प्राप्त करने के लिए अपने आधार या पैन की धुंधली प्रति अपलोड करें।';

  @override
  String get governmentJob => 'सरकारी नौकरी';

  @override
  String get govtId => 'Govt ID';

  @override
  String get govtIdVerification => 'सरकारी पहचान पत्र';

  @override
  String get graduate => 'स्नातक';

  @override
  String get great => 'महान!';

  @override
  String get grid => 'ग्रिड';

  @override
  String get groupPhotosNotVisible =>
      'सामूहिक तस्वीरें जहां आप स्पष्ट रूप से दिखाई नहीं दे रहे हैं';

  @override
  String get growth => 'Growth';

  @override
  String get haveQuestionsOrNeedAssistanceOurTeamIsHe =>
      'क्या आपके कोई प्रश्न हैं या सहायता की आवश्यकता है? हमारी टीम आपका आदर्श साथी ढूंढ़ने में आपकी सहायता के लिए यहां मौजूद है।';

  @override
  String get heavilyFilteredEdited => 'भारी फ़िल्टर या संपादित तस्वीरें';

  @override
  String get height => 'ऊँचाई';

  @override
  String get helpOurCommunityGrowAndUnlockPremiumRewa =>
      'हमारे समुदाय को बढ़ने में मदद करें और अपने लिए प्रीमियम पुरस्कार अनलॉक करें।';

  @override
  String get highSchool => 'हाई स्कूल';

  @override
  String get hindi => 'हिंदी';

  @override
  String get home => 'होम';

  @override
  String get homemaker => 'गृहिणी';

  @override
  String hoursAgo(String count) {
    return '$countघं पहले';
  }

  @override
  String get howItWorks => 'यह काम किस प्रकार करता है';

  @override
  String get iUnderstandThatThisActionCannotBeUndone =>
      'मैं समझता हूं कि इस कार्रवाई को पूर्ववत नहीं किया जा सकता.';

  @override
  String idLabel(String id) {
    return 'ID: $id';
  }

  @override
  String get idNumber => 'आईडी नंबर';

  @override
  String get idType => 'ID Type';

  @override
  String get inappropriateBackgrounds => 'अनुचित पृष्ठभूमि वाली तस्वीरें';

  @override
  String get inappropriateContentOrFakeProfile =>
      'अनुपयुक्त सामग्री या नकली प्रोफ़ाइल';

  @override
  String get inappropriatePhotos => 'अनुचित तस्वीरें';

  @override
  String get inches => 'इंच';

  @override
  String get increaseBiodataScore => 'बायोडेटा स्कोर बढ़ाएं!';

  @override
  String get increaseYourTrustScoreToConfirmYourIdent =>
      'अपनी पहचान की पुष्टि करने और विशेष छूट अनलॉक करने के लिए अपना ट्रस्ट स्कोर बढ़ाएं।';

  @override
  String get interestSent => 'रुचि भेजी गई';

  @override
  String get interestConfirmationTitle => 'रुचि व्यक्त करें?';

  @override
  String interestConfirmationMessage(String name) {
    return 'इससे आपकी प्रोफ़ाइल $name के साथ साझा की जाएगी और वे आपसे जुड़ सकेंगे। क्या आप सुनिश्चित हैं?';
  }

  @override
  String interestShared(String name) {
    return '$name के साथ रुचि साझा की गई!';
  }

  @override
  String get introduceYourselfIn30SecondsTalkAboutYou =>
      '30 सेकंड में अपना परिचय दें. अपने परिवार, पेशे और अपेक्षाओं के बारे में बात करें।';

  @override
  String get invalidEmailOrPassword => 'अमान्य ईमेल या पासवर्ड';

  @override
  String get inviteARelative => 'किसी रिश्तेदार को आमंत्रित करें';

  @override
  String get inviteFriendsRewards =>
      'दोस्तों को आमंत्रित करें और प्रीमियम पुरस्कार पाएं!';

  @override
  String get inviteStep1 => 'Step 1';

  @override
  String get inviteStep2 => 'Step 2';

  @override
  String get inviteStep3 => 'Step 3';

  @override
  String get isDisabledPerson => 'क्या आप विकलांग हैं?';

  @override
  String get jobDetails => 'नौकरी का विवरण';

  @override
  String get joinMeOnBanjarabio => 'बंजाराबायो पर मेरे साथ जुड़ें';

  @override
  String get joinOurCommunity => 'हमारे 10K+ समुदाय में शामिल हों!';

  @override
  String get jointFamily => 'संयुक्त परिवार';

  @override
  String get justNow => 'अभी-अभी';

  @override
  String get kannada => 'ಕನ್ನಡ';

  @override
  String get keepBrowsing => 'ब्राउज़ करते रहें';

  @override
  String get keywordSearch => 'कीवर्ड खोज';

  @override
  String get language => 'भाषा';

  @override
  String languageChanged(String language) {
    return 'भाषा $language में बदली गई';
  }

  @override
  String get lastUpdatedJanuary2026 => 'अंतिम अद्यतन: जनवरी 2026';

  @override
  String get legalAndInformation => 'कानूनी और जानकारी';

  @override
  String get linkShare => 'लिंक साझा करें';

  @override
  String get linkedInIntegration => 'LinkedIn एकीकरण';

  @override
  String get linkedInIntegrationSubtitle =>
      'अधिक विश्वास बनाने के लिए अपने पेशेवर प्रोफाइल को कनेक्ट करें।';

  @override
  String get liveSelfie => 'लाइव सेल्फी';

  @override
  String get liveSelfieVerification => 'लाइव सेल्फी सत्यापन';

  @override
  String get livenessCheck => 'जीवंतता की जांच';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get loadingAssets => 'संपत्ति लोड हो रही है...';

  @override
  String get loadingProfile => 'आपकी प्रोफ़ाइल लोड हो रही है...';

  @override
  String get loadingViews => 'दृश्य लोड हो रहे हैं...';

  @override
  String get location => 'स्थान';

  @override
  String get locationDetails => 'स्थान विवरण';

  @override
  String get locationPreferences => 'स्थान और प्राथमिकताएं';

  @override
  String get locationPreview => 'स्थान पूर्वावलोकन';

  @override
  String get login => 'लॉगिन';

  @override
  String loginFailed(String error) {
    return 'लॉगिन विफल: $error';
  }

  @override
  String get loginFailedRetry => 'लॉगिन विफल। कृपया पुनः प्रयास करें।';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get loseMatchesAndSavedProfiles =>
      'आप अपने सभी मैच और सहेजे गए प्रोफ़ाइल खो देंगे।';

  @override
  String get main => 'मुख्य';

  @override
  String get male => 'पुरुष';

  @override
  String get managePhotos => 'फ़ोटो प्रबंधित करें';

  @override
  String get managenphotos => 'तस्वीरें प्रबंधित करें';

  @override
  String get manualSelection => 'मैन्युअल चयन';

  @override
  String get marathi => 'मराठी';

  @override
  String get maritalStatus => 'वैवाहिक स्थिति';

  @override
  String get maritalStatusLabel => 'वैवाहिक स्थिति';

  @override
  String get marriageReadiness => 'विवाह तत्परता';

  @override
  String get married => 'विवाहित';

  @override
  String get maskFamilySuggestionsTip =>
      'Ask family members for photo suggestions';

  @override
  String get mastersDegree => 'मास्टर डिग्री';

  @override
  String matchNOfTotal(int current, int total) {
    return 'मैच $current / $total';
  }

  @override
  String get matched => 'मिलान हुआ';

  @override
  String get sent => 'भेजे गए';

  @override
  String get received => 'प्राप्त हुए';

  @override
  String get matchmakerConsultation => 'मैचमेकर परामर्श';

  @override
  String get matrimonyFor => 'विवाह के लिए';

  @override
  String get maxAge => 'अधिकतम आयु';

  @override
  String get maybeLater => 'शायद बाद में';

  @override
  String get menu => 'मेनू';

  @override
  String get message => 'संदेश';

  @override
  String get messageUsOnWhatsapp => 'हमें व्हाट्सएप पर संदेश भेजें';

  @override
  String get messages => 'संदेशों';

  @override
  String get middleClass => 'मध्यम वर्ग';

  @override
  String get minAge => 'न्यूनतम आयु';

  @override
  String minutesAgo(String count) {
    return '$countमि पहले';
  }

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get mobileVerification => 'मोबाइल सत्यापन';

  @override
  String get mobileVerifiedSuccessfully10Points =>
      'मोबाइल सफलतापूर्वक सत्यापित! +10 अंक';

  @override
  String get month => '/महीना';

  @override
  String get months => 'महीने';

  @override
  String get moreAboutYourStudiesAndWork =>
      'अपनी पढ़ाई और काम के बारे में और बताएं';

  @override
  String get moreOptions => 'अधिक विकल्प';

  @override
  String get mostPopular => 'सबसे लोकप्रिय';

  @override
  String get motherName => 'माँ का नाम';

  @override
  String get motherOccupation => 'माँ का व्यवसाय';

  @override
  String get myProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get name => 'नाम';

  @override
  String get nativePlace => 'मूल स्थान';

  @override
  String get naturalPosesRespectful => 'सम्मानजनक भावों के साथ प्राकृतिक पोज़';

  @override
  String get needProfileToShareToast =>
      'You need to create a profile before sharing it.';

  @override
  String get neverMarried => 'अविवाहित';

  @override
  String get newLabel => 'नया';

  @override
  String get newMatches => 'नये मिलान';

  @override
  String get next => 'आगे';

  @override
  String get nextLabel => 'अगला';

  @override
  String nextRefreshTime(String time) {
    return 'अगला रिफ्रेश: $time';
  }

  @override
  String get no => 'नहीं';

  @override
  String get noBookmarkedProfilesYet =>
      'अभी तक कोई बुकमार्क की गई प्रोफ़ाइल नहीं';

  @override
  String get noConversations => 'अभी तक कोई बातचीत नहीं';

  @override
  String get noDailyMatchesYet => 'अभी तक कोई दैनिक मिलान नहीं';

  @override
  String get noIncome => 'कोई आय नहीं';

  @override
  String get noInternetConnection => 'इंटरनेट कनेक्शन नहीं';

  @override
  String noLocationsFoundForQuery(String query) {
    return '\"$query\" के लिए कोई स्थान नहीं मिला';
  }

  @override
  String get noPendingRequests => 'कोई लंबित अनुरोध नहीं';

  @override
  String get noPendingVerifications => 'No pending verifications';

  @override
  String get noPhotosAdded => 'कोई तस्वीर नहीं जोड़ी गई';

  @override
  String get noPhotosYet => 'अभी तक कोई फ़ोटो नहीं';

  @override
  String get noProfileFound => 'कोई प्रोफ़ाइल नहीं मिली';

  @override
  String get noProfilesFound => 'कोई प्रोफ़ाइल नहीं मिली';

  @override
  String get noProfilesMatchYourFilters =>
      'कोई भी प्रोफ़ाइल आपके फ़िल्टर से मेल नहीं खाती';

  @override
  String get noResultsMessage =>
      'अपने फ़िल्टर बदलकर देखें या नई प्रोफ़ाइल के लिए बाद में जाँचें।';

  @override
  String get noSiblingsAddedYet => 'अभी तक कोई भाई-बहन नहीं जोड़ा गया';

  @override
  String get noTalukasAvailable => 'कोई तालुका उपलब्ध नहीं है';

  @override
  String get noViewsYet => 'अभी तक कोई दृश्य नहीं';

  @override
  String get notAvailable => 'उपलब्ध नहीं';

  @override
  String get notEntered => 'दर्ज नहीं किया';

  @override
  String get notMatchedCantMessage =>
      'आप इस प्रोफ़ाइल से मेल नहीं खाते हैं, इसलिए आप उन्हें सीधे संदेश नहीं भेज सकते।';

  @override
  String get notReadyYet => 'अभी तैयार नहीं';

  @override
  String get notRepresentAppearance =>
      'तस्वीरें जो आपके वर्तमान स्वरूप का प्रतिनिधित्व नहीं करतीं';

  @override
  String get notVerifiedYetPleaseClickTheLinkInYourEm =>
      'अभी तक सत्यापित नहीं हुआ. कृपया अपने ईमेल में दिए गए लिंक पर क्लिक करें।';

  @override
  String get notYetVerifiedBadge => 'अभी तक सत्यापित नहीं';

  @override
  String get nuclearFamily => 'एकल परिवार';

  @override
  String get num100 => '/ 100';

  @override
  String get num123BanjaraTowersPrideSiliconValleynsh =>
      '123, बंजारा टावर्स, प्राइड सिलिकॉन वैली, शिवाजी नगर, पुणे, महाराष्ट्र 411005';

  @override
  String get num15PointsPending => '+15 अंक लंबित';

  @override
  String get num499 => '499';

  @override
  String get num919876543210 => '+91 98765 43210';

  @override
  String get officeAddress => 'कार्यालय का पता';

  @override
  String get ok => 'ठीक है';

  @override
  String get onHold => 'होल्ड पर';

  @override
  String get onboardingTitle1 => 'अपना सही जीवनसाथी खोजें';

  @override
  String get onboardingTitle2 => 'विश्वसनीय समुदाय';

  @override
  String get onboardingTitle3 => 'सुरक्षित और निजी';

  @override
  String get oneTime => 'एक बार';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get openCamera => 'कैमरा खोलें';

  @override
  String get openProfileToShare => 'साझा करने के लिए प्रोफ़ाइल खोलें';

  @override
  String get openSettings => 'खुली सेटिंग';

  @override
  String get openingConversation => 'बातचीत शुरू हो रही है...';

  @override
  String get openingConversationToast => 'Opening conversation...';

  @override
  String get originalVillageHint => 'मूल गांव';

  @override
  String get other => 'अन्य';

  @override
  String get partnerExpectations => 'जीवनसाथी अपेक्षाएं';

  @override
  String get partnerExpectationsHint => 'बताएं कि आप क्या ढूंढ रहे हैं...';

  @override
  String get partnerPreferences => 'साझेदार प्राथमिकताएँ';

  @override
  String get password => 'पासवर्ड';

  @override
  String get pay199ToUnlockFullPdf =>
      'पूर्ण पीडीएफ अनलॉक करने के लिए ₹199 का भुगतान करें';

  @override
  String paymentFailed(String error) {
    return 'भुगतान विफल: $error';
  }

  @override
  String paymentFailedError(String error) {
    return 'भुगतान विफल: $error';
  }

  @override
  String get paymentSuccessful => 'भुगतान सफल! टेम्प्लेट अनलॉक किए गए.';

  @override
  String paymentSuccessfulWelcome(String plan) {
    return 'भुगतान सफल! $plan में आपका स्वागत है';
  }

  @override
  String pdfSavedToDownloads(String path) {
    return 'पीडीएफ डाउनलोड में सहेजा गया: $path';
  }

  @override
  String get pending => 'लंबित';

  @override
  String get pendingVerifications => 'Pending Verifications';

  @override
  String percentComplete(int percentage) {
    return '$percentage% पूर्ण';
  }

  @override
  String get permissionDeniedSettings =>
      'Permission denied. Please enable in settings.';

  @override
  String get permissionRequired => 'अनुमति आवश्यक है';

  @override
  String permissionRequiredMessage(Object type) {
    return 'फोटो अपलोड करने के लिए $type अनुमति आवश्यक है। कृपया इसे ऐप सेटिंग्स में सक्षम करें।';
  }

  @override
  String get personalDetails => 'व्यक्तिगत विवरण';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneSupport => 'फ़ोन सहायता';

  @override
  String get photoAdded => 'Photo added';

  @override
  String photoAddedWithKb(String kb) {
    return 'Photo added ($kb KB)';
  }

  @override
  String get photoGuidelines => 'फोटो दिशानिर्देश';

  @override
  String get photoLimitReached => 'फ़ोटो की सीमा पूरी हो गई';

  @override
  String get photoManagement => 'फ़ोटो प्रबंधन';

  @override
  String get photoUpload => 'फ़ोटो';

  @override
  String get photoUploadedSuccessfully => 'फोटो सफलतापूर्वक अपलोड हो गया';

  @override
  String get photoVisibility => 'फोटो दृश्यता';

  @override
  String get photos => 'तस्वीरें:';

  @override
  String get photosAreAutomaticallyCompressedToEnsure =>
      'तेज़ अपलोड सुनिश्चित करने के लिए तस्वीरें स्वचालित रूप से संपीड़ित होती हैं';

  @override
  String get photosCompressedInfo => 'Photos are compressed to save data.';

  @override
  String photosCount(String count) {
    return '$count फ़ोटो';
  }

  @override
  String get photosDeletedSuccessfully => 'तस्वीरें सफलतापूर्वक हटा दी गईं';

  @override
  String get photosReflectPersonality =>
      'तस्वीरें जो आपके व्यक्तित्व और मूल्यों को दर्शाती हैं';

  @override
  String photosSelectedCount(int count) {
    return '$count चयनित';
  }

  @override
  String get photosToAvoid => 'इन तस्वीरों से बचें';

  @override
  String get physicalSocialAttributes => 'शारीरिक और सामाजिक विवरण';

  @override
  String get physicalStatus => 'शारीरिक स्थिति';

  @override
  String get platinumPlanDesc => 'सभी सुविधाओं के साथ बेहतरीन अनुभव';

  @override
  String get platinumPlanName => 'प्लेटिनम';

  @override
  String pleaseComplete(String fields) {
    return 'कृपया पूरा करें: $fields';
  }

  @override
  String pleaseCompleteRequiredFields(String section) {
    return 'कृपया $section में सभी आवश्यक फ़ील्ड पूरे करें';
  }

  @override
  String get pleaseEnter6DigitOtp => 'कृपया 6 अंकों का ओटीपी दर्ज करें';

  @override
  String get pleaseEnterAValid10DigitMobileNumber =>
      'कृपया एक वैध 10-अंकीय मोबाइल नंबर दर्ज करें';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'कृपया एक मान्य ईमेल पता प्रविष्ट करें';

  @override
  String get pleaseEnterBothEmailPassword =>
      'कृपया ईमेल और पासवर्ड दोनों दर्ज करें';

  @override
  String get pleaseEnterFull6DigitOtp => 'कृपया पूर्ण 6-अंकीय ओटीपी दर्ज करें';

  @override
  String get pleaseFillAllFields => 'कृपया सभी क्षेत्रों को भरें';

  @override
  String get pleaseSelectAnnualIncome => 'कृपया अपनी वार्षिक आय चुनें';

  @override
  String get pleaseSelectEducationLevel => 'कृपया अपना शिक्षा स्तर चुनें';

  @override
  String get pleaseSelectProfession => 'कृपया अपना व्यवसाय चुनें';

  @override
  String get pleaseSelectYourGotra => 'कृपया अपना गोत्र चुनें';

  @override
  String get pleaseSelectYourSurname => 'कृपया अपना उपनाम चुनें';

  @override
  String get pleaseSignInAgain =>
      'बायोडाटा सेव करने के लिए कृपया पुनः साइन इन करें';

  @override
  String get pleaseSpecifyEducation => 'कृपया अपनी शिक्षा निर्दिष्ट करें';

  @override
  String get pleaseSpecifyProfession => 'कृपया अपना व्यवसाय निर्दिष्ट करें';

  @override
  String get pleaseTakeASelfieToVerifyThatYouAreAReal =>
      'यह सत्यापित करने के लिए कि आप वास्तविक व्यक्ति हैं, कृपया एक सेल्फी लें। सुनिश्चित करें कि आप अच्छी रोशनी वाले क्षेत्र में हैं।';

  @override
  String pointsCount(String points) {
    return '+$points अंक';
  }

  @override
  String get postGraduate => 'स्नातकोत्तर';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get premiumFeature => 'यह एक प्रीमियम सुविधा है';

  @override
  String get premiumMembership => 'प्रीमियम सदस्यता';

  @override
  String get premiumTemplate => 'प्रीमियम टेम्पलेट';

  @override
  String get premiumUsers => 'Premium Users';

  @override
  String get preparingBiodata => 'आपका बायोडाटा तैयार किया जा रहा है...';

  @override
  String get previewGenerationFailed =>
      'पूर्वावलोकन जनरेशन विफल रहा. कृपया पुन: प्रयास करें।';

  @override
  String get previous => 'पीछे';

  @override
  String pricePerMonth(Object price) {
    return '₹$price/माह';
  }

  @override
  String get primary => 'प्राथमिक';

  @override
  String get primaryPhoto => 'प्राथमिक फ़ोटो';

  @override
  String get primaryPhotoUpdated => 'प्राथमिक फोटो अपडेट कर दिया गया';

  @override
  String get printBtn => 'छाप';

  @override
  String get prioritySupport => 'प्राथमिकता सहायता';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get privacyS1Content =>
      '• व्यक्तिगत डेटा: नाम, आयु, लिंग, जाति, शिक्षा, पेशा, पारिवारिक विवरण।\\n• संपर्क डेटा: फोन नंबर, ईमेल पता।\\n• मीडिया: आपकी प्रोफ़ाइल पर अपलोड किए गए फ़ोटो।\\n• डिवाइस डेटा: डिवाइस आईडी, आईपी पता (सुरक्षा और विश्लेषण के लिए)।\\n• स्थान डेटा: आस-पास के मिलान सुझाने के लिए अनुमानित स्थान (शहर/जिला)।';

  @override
  String get privacyS1Title => '1. हमारे द्वारा एकत्रित की जाने वाली जानकारी';

  @override
  String get privacyS2Content =>
      '• ऐप कार्यक्षमता: आपकी प्रोफ़ाइल बनाने और मिलान करने के लिए।\\n• खाता प्रबंधन: पहचान सत्यापन और धोखाधड़ी की रोकथाम।\\n• विश्लेषण: ऐप प्रदर्शन को बेहतर बनाने के लिए (फायरबेस का उपयोग करके)।\\n• स्थान: \"मेरे आस-पास\" मिलान दिखाने के लिए (वैकल्पिक)।';

  @override
  String get privacyS2Title => '2. संग्रह का उद्देश्य (डेटा सुरक्षा)';

  @override
  String get privacyS3Content =>
      '• कैमरा और गैलरी: प्रोफ़ाइल फ़ोटो के लिए।\\n• स्थान: शहर/ज़िला स्वतः भरने के लिए।\\n• सूचनाएं: मिलान अलर्ट के लिए।';

  @override
  String get privacyS3Title => '3. डिवाइस अनुमतियां';

  @override
  String get privacyS4Content =>
      '• अन्य उपयोगकर्ता: पंजीकृत सदस्य आपकी प्रोफ़ाइल का विवरण देख सकते हैं (साझा किए जाने तक संपर्क जानकारी को छोड़कर)।\\n• सेवा प्रदाता: हम ऐप चलाने के लिए सुपबेस (डेटाबेस) और फायरबेस (एनालिटिक्स/नोटिफिकेशन) का उपयोग करते हैं। वे सख्त सुरक्षा मानकों के तहत डेटा प्रोसेस करते हैं।';

  @override
  String get privacyS4Title => '4. प्रकटीकरण और तृतीय पक्ष';

  @override
  String get privacyS5Content =>
      'हम आपके डेटा की सुरक्षा के लिए एन्क्रिप्शन का उपयोग करते हैं। आप सेटिंग्स > खाता हटाएं के माध्यम से किसी भी समय अपना खाता और सभी संबंधित डेटा हटा सकते हैं।';

  @override
  String get privacyS5Title => '5. डेटा सुरक्षा और विलोपन';

  @override
  String get privacyS6Content =>
      'यह नीति भारत के कानूनों द्वारा शासित है। कोई भी विवाद महाराष्ट्र की अदालतों की अधिकारिता के अधीन है।';

  @override
  String get privacyS6Title => '6. शासी कानून';

  @override
  String get privacySettings => 'गोपनीय सेटिंग';

  @override
  String get privacySettingsUpdated => 'गोपनीयता सेटिंग्स अपडेट कर दी गईं';

  @override
  String get privacyTitle => 'गोपनीयता नीति';

  @override
  String get privateJob => 'निजी नौकरी';

  @override
  String get privateSectorEmployee => 'निजी क्षेत्र के कर्मचारी';

  @override
  String get pro => 'प्रो';

  @override
  String get proTips => 'प्रो टिप्स';

  @override
  String get processingImage => 'तस्वीर प्रोसेस की जा रही है';

  @override
  String get processingStatusCompressing => 'Compressing...';

  @override
  String get processingStatusPreparing => 'Preparing...';

  @override
  String get processingStatusSelecting => 'Selecting...';

  @override
  String get profession => 'व्यवसाय';

  @override
  String get professionLabel => 'पेशा';

  @override
  String get professional => 'व्यावसायिक';

  @override
  String get professionalDegree => 'प्रोफेशनल डिग्री';

  @override
  String get professionalDoctorEngineerLawyer =>
      'पेशेवर (डॉक्टर/इंजीनियर/वकील)';

  @override
  String get professionalFamilyEventPhotos =>
      'पेशेवर या पारिवारिक समारोह की तस्वीरें';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String profileBoostPerMonth(String count) {
    return '$count प्रोफ़ाइल बूस्ट/महीना';
  }

  @override
  String get profileCompleted => 'प्रोफ़ाइल पूर्ण हुई';

  @override
  String get profileCreatedByTitle => 'प्रोफ़ाइल किसके द्वारा बनाई गई';

  @override
  String get profileDataNotFound => 'प्रोफ़ाइल डेटा नहीं मिला';

  @override
  String get profileInsights => 'प्रोफ़ाइल अंतर्दृष्टि';

  @override
  String get profileLinkCopied => 'प्रोफाइल लिंक क्लिपबोर्ड पर कॉपी की गई!';

  @override
  String get profileNotFound => 'प्रोफ़ाइल नहीं मिला';

  @override
  String get profilePhotos => 'प्रोफ़ाइल तस्वीरें';

  @override
  String get profileRemovedFromSaved => 'प्रोफ़ाइल सहेजी गई सूचि से हटा दी गई';

  @override
  String get profileSaved => 'प्रोफ़ाइल सहेजी गई!';

  @override
  String profileSharedWith(String name) {
    return '$name के साथ प्रोफाइल शेयर की गई';
  }

  @override
  String profileStrengthLabel(Object strength) {
    return 'प्रोफ़ाइल ताकत: $strength';
  }

  @override
  String get profileViewLimitReached => 'प्रोफ़ाइल दृश्य सीमा पूरी हो गई';

  @override
  String profileViewsPerDay(String count) {
    return '$count प्रोफ़ाइल दृश्य/दिन';
  }

  @override
  String get profilesYouSaveWillAppearHere =>
      'आपके द्वारा सहेजी गई प्रोफ़ाइलें यहां दिखाई देंगी';

  @override
  String get provideDetailsAboutYourGotraAndVillageTo =>
      'समुदाय सत्यापित बैज प्राप्त करने के लिए अपने गोत्र और गांव के बारे में विवरण प्रदान करें।';

  @override
  String get provideInformationAboutYourFamilyBackgro =>
      'अपनी पारिवारिक पृष्ठभूमि के बारे में जानकारी प्रदान करें';

  @override
  String get public => 'जनता';

  @override
  String get quick => 'तेज़';

  @override
  String get ready => 'तैयार';

  @override
  String get readyForMarriage => 'शादी के लिए तैयार';

  @override
  String get recentConversations => 'हाल की बातचीत';

  @override
  String get recentPhotosSixMonths =>
      'पिछले 6 महीनों में ली गई हालिया तस्वीरें';

  @override
  String get recentSearches => 'हाल की खोजें';

  @override
  String get recentlyUsed => 'हाल ही में उपयोग किया गया';

  @override
  String get recommendToOthers => 'दूसरों को रेकमेंड करें';

  @override
  String get recommended => 'अनुशंसित';

  @override
  String get recommendedPhotos => 'अनुशंसित तस्वीरें';

  @override
  String get recordAShortIntro => 'एक संक्षिप्त परिचय रिकॉर्ड करें';

  @override
  String get refer3FriendsGet1MonthFree =>
      '3 दोस्तों को रेफर करें, 1 महीना मुफ़्त पाएं!';

  @override
  String get referAndEarn => 'रेफर करें और कमाएं';

  @override
  String get referenceVerification => 'संदर्भ सत्यापन';

  @override
  String get references => 'संदर्भ';

  @override
  String get referralInvite => 'रेफरल आमंत्रण';

  @override
  String referralInviteMessage(Object link) {
    return 'बंजाराबायो से जुड़ें, हमारे समुदाय के लिए सबसे भरोसेमंद वैवाहिक ऐप! शुरू करने के लिए मेरे लिंक का उपयोग करें: $link';
  }

  @override
  String get referralInviteSubject => 'बंजाराबायो में शामिल होने का निमंत्रण';

  @override
  String get referralLinkCopiedToClipboard =>
      'रेफ़रल लिंक क्लिपबोर्ड पर कॉपी किया गया!';

  @override
  String referralShareMessage(String link) {
    return 'बंजाराबायो (BanjaraBio) में शामिल हों, हमारे समुदाय के लिए सबसे भरोसेमंद मैट्रिमोनियल ऐप! शुरू करने के लिए मेरे लिंक का उपयोग करें: $link';
  }

  @override
  String get referralShareSubject => 'BanjaraBio invitation';

  @override
  String get referrals => 'Referrals';

  @override
  String get referralsLabel => 'रेफरल';

  @override
  String get refresh => 'रिफ्रेश';

  @override
  String get reject => 'अस्वीकार करना';

  @override
  String get rejected => 'अस्वीकृत';

  @override
  String get relative => 'रिश्तेदार';

  @override
  String get remainingToday => 'आज शेष';

  @override
  String get remove => 'निकालना';

  @override
  String get removePhoto => 'हटाएं';

  @override
  String get report => 'रिपोर्ट करें';

  @override
  String get reportSubmittedReview =>
      'रिपोर्ट सबमिट कर दी गई है। हमारी टीम 24 घंटे के भीतर इसकी समीक्षा करेगी।';

  @override
  String get reportUser => 'उपयोगकर्ता को रिपोर्ट करें';

  @override
  String get requestDate => 'Request Date';

  @override
  String requestProcessedSuccessfullyMsg(String status) {
    return 'अनुरोध $status सफलतापूर्वक पूरा हुआ';
  }

  @override
  String get requestsSent => 'अनुरोध भेजे गए!';

  @override
  String get requestsSentSuccessfully => 'अनुरोध सफलतापूर्वक भेजे गए!';

  @override
  String get rerecord => 'पुन: रिकॉर्ड';

  @override
  String get reset => 'रीसेट';

  @override
  String get reshare => 'पुनः साझा करना';

  @override
  String get retake => 'फिर से लेना';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get reviewDetails => 'विवरण की समीक्षा करें';

  @override
  String get reviewVideoManuallyInStorageForNow =>
      'अभी के लिए स्टोरेज में मैन्युअल रूप से वीडियो की समीक्षा करें';

  @override
  String get rewards => 'Rewards';

  @override
  String get rewardsLabel => 'पुरस्कार';

  @override
  String get rich => 'धनवान';

  @override
  String get rupeeSymbol => '₹';

  @override
  String get save => 'सेव करें';

  @override
  String get saveBiodata => 'बायोडाटा सेव करें';

  @override
  String get saved => 'सहेजा गया';

  @override
  String get savedProfiles => 'सेव प्रोफ़ाइल';

  @override
  String get sayHelloLabel => 'नमस्ते कहें!';

  @override
  String get search => 'खोजें';

  @override
  String get searchByNameJobEducation => 'नाम, नौकरी, शिक्षा से खोजें...';

  @override
  String get searchProfiles => 'प्रोफ़ाइल खोजें...';

  @override
  String get searchResults => 'खोज परिणाम';

  @override
  String get searchSharedProfiles => 'साझा प्रोफ़ाइल खोजें...';

  @override
  String get searchStateDistrictOrTaluka => 'राज्य, जिला या तालुका खोजें';

  @override
  String get searchUserName => 'उपयोगकर्ता नाम खोजें...';

  @override
  String get secure => 'सुरक्षित';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get selectAnnualIncome => 'सालाना कमाई की श्रेणी चुनें';

  @override
  String get selectAnnualIncomeRange => 'वार्षिक आय सीमा चुनें';

  @override
  String get selectDate => 'तारीख चुनें';

  @override
  String get selectDistrictFirst => 'पहले जिला चुनें';

  @override
  String get selectDocumentType => 'दस्तावेज़ प्रकार चुनें';

  @override
  String get selectEducationLevel => 'अपना शिक्षा स्तर चुनें';

  @override
  String get selectFromYourPhotos => 'अपनी तस्वीरों में से चुनें';

  @override
  String get selectLanguage => 'भाषा चुने';

  @override
  String get selectLocation => 'स्थान चुनें';

  @override
  String get selectState => 'राज्य चुनें';

  @override
  String get selectStateFirst => 'पहले राज्य चुनें';

  @override
  String get selectTalukaOptional => 'तालुका चुनें (वैकल्पिक)';

  @override
  String get selectYourEducationLevel => 'अपना शिक्षा स्तर चुनें';

  @override
  String get selectYourGotra => 'अपना गोत्र चुनें';

  @override
  String get selectYourLocationAndPreferences =>
      'अपना स्थान और प्राथमिकताएँ चुनें';

  @override
  String get selectYourProfession => 'अपना व्यवसाय चुनें';

  @override
  String get selectYourSurname => 'अपना उपनाम चुनें';

  @override
  String get selectedPhotos => 'चयनित तस्वीरें';

  @override
  String get self => 'Self';

  @override
  String get selfEmployed => 'स्वरोजगार';

  @override
  String get selfieSubmitted => 'सेल्फी सबमिट की गई';

  @override
  String get send => 'भेजें';

  @override
  String get sendInterest => 'रुचि भेजें';

  @override
  String get sendMessage => 'मेसेज भेजें';

  @override
  String get sendVerification => 'सत्यापन भेजें';

  @override
  String get sendVerificationRequests => 'सत्यापन अनुरोध भेजें';

  @override
  String get setAsPrimary => 'प्राथमिक के रूप में सेट करें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get settingsAndMenu => 'सेटिंग्स और मेनू';

  @override
  String get sevenHalfToTenLakh => '₹7.5 लाख - ₹10 लाख';

  @override
  String get share => 'शेयर करें';

  @override
  String get shareBtn => 'शेयर करना';

  @override
  String get shareEducationalBackground =>
      'अपनी शैक्षिक और व्यावसायिक जानकारी साझा करें';

  @override
  String shareFailed(String error) {
    return 'शेयर करना विफल रहा: $error';
  }

  @override
  String get shareHub => 'शेयर हब';

  @override
  String get shareInApp => 'इन-ऐप शेयर करें';

  @override
  String get shareLimitReached => 'शेयर की सीमा पूरी हो गई';

  @override
  String get shareLinkOnWhatsapp => 'व्हाट्सएप पर लिंक साझा करें';

  @override
  String get shareMyProfileSubtitle =>
      'अपना बायोडाटा सीधे साझा करके अपनी रुचि व्यक्त करें';

  @override
  String shareMyProfileWith(String name) {
    return '$name के साथ मेरी प्रोफ़ाइल साझा करें';
  }

  @override
  String get shareProfile => 'प्रोफ़ाइल साझा करें';

  @override
  String get shareProfilesWithYourFamilyInstantlyNbui =>
      'अपने परिवार के साथ तुरंत प्रोफ़ाइल साझा करें।\\nभारतीय परिवारों के निर्णय लेने के तरीके के लिए बनाया गया।';

  @override
  String get shareToSocialMedia => 'सोशल मीडिया पर साझा करें';

  @override
  String get shareYourEducationalBackgroundAndProfess =>
      'अपनी शैक्षिक पृष्ठभूमि और पेशेवर विवरण साझा करें';

  @override
  String get shareYourProfileProfessionally =>
      'अपनी प्रोफ़ाइल पेशेवर रूप से साझा करें';

  @override
  String get shared => 'मैचेस';

  @override
  String get sharedProfiles => 'शेयर की गई प्रोफ़ाइल';

  @override
  String sharedVia(String name, String method) {
    return '$method के माध्यम से $name को शेयर किया गया';
  }

  @override
  String sharesPerMonth(String count) {
    return '$count शेयर/महीना';
  }

  @override
  String get sharingBiodataPdf => 'बायोडाटा पीडीएफ साझा करना';

  @override
  String get silver => 'रजत';

  @override
  String get silverPlanDesc => 'शुरुआत करने के लिए उत्तम';

  @override
  String get silverPlanName => 'सिल्वर';

  @override
  String get sister => 'बहन';

  @override
  String get sisterCount => 'बहनें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get smileNaturallyTip =>
      'मिलनसार दिखने के लिए स्वाभाविक रूप से मुस्कुराएं';

  @override
  String get socialMediaTextOverlays =>
      'टेक्स्ट ओवरले वाली सोशल मीडिया की तस्वीरें';

  @override
  String get solicitingMoney => 'पैसे मांगना';

  @override
  String get someone => 'कोई';

  @override
  String get somethingWentWrong => 'कुछ गड़बड़ हो गई';

  @override
  String get son => 'बेटे';

  @override
  String get specifyEducation => 'शिक्षा निर्दिष्ट करें';

  @override
  String get specifyProfession => 'पेशा निर्दिष्ट करें';

  @override
  String get standardProfile => 'मानक प्रोफाइल';

  @override
  String get start => 'शुरू करें';

  @override
  String get startAConversation => 'Start a conversation';

  @override
  String get startConversation => 'बातचीत शुरू करें';

  @override
  String get startRecording => 'रिकॉर्डिंग प्रारंभ करें';

  @override
  String get state => 'राज्य';

  @override
  String get statusWaitingForApproval => 'स्थिति: अनुमोदन की प्रतीक्षा में';

  @override
  String get stay => 'रुकें';

  @override
  String stepNOfTotal(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get student => 'छात्र';

  @override
  String get submit => 'सबमिट करें';

  @override
  String get submitForVerification => 'सत्यापन के लिए सबमिट करें';

  @override
  String get submittedForReview => 'समीक्षा हेतु प्रस्तुत किया गया';

  @override
  String get subscription => 'सदस्यता';

  @override
  String get supportAndHelp => 'सहायता और मदद';

  @override
  String get supportBanjarabioApp => 'support@banjarabio.com';

  @override
  String get surname => 'उपनाम';

  @override
  String get swipe => 'स्वाइप';

  @override
  String get takePhoto => 'फोटो लें';

  @override
  String get taluka => 'तालुका';

  @override
  String talukaInDistrictState(String district, String state) {
    return '$district, $state में तालुका';
  }

  @override
  String get talukaOptional => 'तालुका (वैकल्पिक)';

  @override
  String get tapTheButtonToAddAPhoto => 'फ़ोटो जोड़ने के लिए + बटन पर टैप करें';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get tapToReveal => 'प्रकट करने के लिए टैप करें';

  @override
  String get teacherProfessor => 'शिक्षक/प्रोफेसर';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get template => 'खाका';

  @override
  String get tenToFifteenLakh => '₹10 लाख - ₹15 लाख';

  @override
  String get terms => 'शर्तों';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String get termsConditions => 'नियम एवं शर्तें';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get termsS1Content =>
      'बंजाराबायो एप्लिकेशन का उपयोग करके, आप इन नियमों और शर्तों से बंधे होने के लिए सहमत हैं। यदि आप सहमत नहीं हैं, तो कृपया सेवा का उपयोग न करें।';

  @override
  String get termsS1Title => '1. शर्तों की स्वीकृति';

  @override
  String get termsS2Content =>
      'इस प्लेटफॉर्म पर पंजीकरण करने के लिए आपकी आयु कम से कम 18 वर्ष (महिलाओं के लिए) या 21 वर्ष (पुरुषों के लिए) होनी चाहिए। यह प्लेटफॉर्म कड़ाई से वैवाहिक उद्देश्यों के लिए है।';

  @override
  String get termsS2Title => '2. पात्रता';

  @override
  String get termsS3Content =>
      'आप अपने खाते की साख की गोपनीयता बनाए रखने के लिए जिम्मेदार हैं। पंजीकरण के दौरान प्रदान की गई सभी जानकारी सटीक और सच्ची होनी चाहिए।';

  @override
  String get termsS3Title => '3. उपयोगकर्ता खाता';

  @override
  String get termsS4Content =>
      'उपयोगकर्ताओं को वाणिज्यिक उद्देश्यों, उत्पीड़न, नफरत फैलाने वाले भाषण फैलाने या धोखाधड़ी वाली जानकारी साझा करने के लिए प्लेटफॉर्म का उपयोग करने से प्रतिबंधित किया गया है।';

  @override
  String get termsS4Title => '4. निषिद्ध गतिविधियाँ';

  @override
  String get termsS5Content =>
      'आप अपनी प्रोफ़ाइल सेटिंग्स में \"खाता हटाएं\" अनुभाग के माध्यम से किसी भी समय खाता हटाने का अनुरोध कर सकते हैं।';

  @override
  String get termsS5Title => '5. खाता हटाना';

  @override
  String get termsS6Content =>
      'बंजाराबायो मैच खोजने के लिए एक मंच है। हम सफल मैचों की गारंटी नहीं देते हैं या बुनियादी जांच से परे उपयोगकर्ताओं के चरित्र को सत्यापित नहीं करते हैं। उपयोगकर्ताओं को अपनी उचित सावधानी बरतने के लिए प्रोत्साहित किया जाता है।';

  @override
  String get termsS6Title => '6. देयता की सीमा';

  @override
  String get termsS7Content =>
      'ये शर्तें भारत के कानूनों के अनुसार शासित और व्याख्या की जाएंगी। कोई भी विवाद महाराष्ट्र की अदालतों के अनन्य क्षेत्राधिकार के अधीन होगा।';

  @override
  String get termsS7Title => '7. शासी कानून';

  @override
  String get termsTitle => 'नियम और शर्तें';

  @override
  String get textSuper => 'बहुत अच्छा';

  @override
  String get thisFieldIsRequired => 'यह फ़ील्ड आवश्यक है';

  @override
  String get totalCount => 'कुल:';

  @override
  String get totalProfiles => 'Total Profiles';

  @override
  String get traditionalFormalAttire =>
      'पारंपरिक या औपचारिक पोशाक (साड़ी, सलवार कमीज, कुर्ता)';

  @override
  String get trustScore => 'विश्वास स्कोर';

  @override
  String get trustScoreBeyondBeauty => 'सुंदरता से परे ट्रस्ट स्कोर';

  @override
  String get trustScoreDiscounts => 'विश्वास स्कोर और छूट';

  @override
  String trustScoreShareMessage(String score, String url) {
    return 'मैंने अभी बंजाराबायो पर $score ट्रस्ट स्कोर के साथ अपना प्रोफाइल सत्यापित किया है! मेरा प्रोफाइल देखें और हमारे समुदाय में शामिल हों: $url';
  }

  @override
  String get trustVerification => 'विश्वास और सत्यापन';

  @override
  String get trusted => 'विश्वसनीय';

  @override
  String get trustedMember => 'Trusted Member';

  @override
  String get trustedProfile => 'विश्वसनीय प्रोफाइल';

  @override
  String get tryAdjustingYourFilterCriteria =>
      'अपने फ़िल्टर मानदंड को समायोजित करने का प्रयास करें';

  @override
  String get tryAdjustingYourFiltersToSeeMoreProfiles =>
      'बंजारा समुदाय से अधिक प्रोफ़ाइल देखने के लिए अपने फ़िल्टर समायोजित करने का प्रयास करें';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get trySearchingForADifferentCity =>
      'कोई भिन्न शहर खोजने का प्रयास करें';

  @override
  String get trySearchingForDifferentCity =>
      'किसी अन्य शहर को खोजने का प्रयास करें';

  @override
  String get twentyLakhPlus => '₹20 लाख+';

  @override
  String get twoToFiveLakh => '₹2 लाख - ₹5 लाख';

  @override
  String get typeAMessage => 'एक संदेश टाइप करें...';

  @override
  String get typeMessage => 'संदेश लिखें...';

  @override
  String get unauthorizedAccessAdminsOnly => 'अनधिकृत पहुंच। केवल व्यवस्थापक.';

  @override
  String get under2Lakh => '₹2 लाख से कम';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String unexpectedError(String error) {
    return 'एक अप्रत्याशित त्रुटि हुई: $error';
  }

  @override
  String unexpectedErrorOccurred(String error) {
    return 'एक अप्रत्याशित त्रुटि हुई: $error';
  }

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get unlimitedBookmarks => 'असीमित बुकमार्क';

  @override
  String get unlimitedProfileViews => 'असीमित प्रोफ़ाइल दृश्य';

  @override
  String get unlimitedSharing => 'असीमित शेयरिंग';

  @override
  String get unlockAdvancedFilters => 'उन्नत फ़िल्टर अनलॉक करें';

  @override
  String get unlockNow => 'अभी अनलॉक करें';

  @override
  String get unlockPremiumBiodata => 'प्रीमियम बायोडाटा अनलॉक करें';

  @override
  String get unlockPremiumFeaturesToEnhanceYourBiodat =>
      'अपने बायोडाटा प्रोफ़ाइल को बढ़ाने के लिए प्रीमियम सुविधाओं को अनलॉक करें';

  @override
  String get unlockToDownload =>
      'इस टेम्पलेट को 5+ भाषाओं में डाउनलोड और साझा करने के लिए अनलॉक करें।';

  @override
  String get unmarried => 'अविवाहित';

  @override
  String get unsave => 'अनसेव';

  @override
  String get update => 'अद्यतन';

  @override
  String get updateProfile => 'प्रोफ़ाइल अपडेट करें';

  @override
  String get upgrade => 'उन्नत करना';

  @override
  String get upgradeNow => 'अभी अपग्रेड करें';

  @override
  String get upgradePlan => 'प्लान अपग्रेड करें';

  @override
  String get upgradePremiumFilters =>
      'व्यवसाय, स्थान और अधिक के लिए प्रीमियम फ़िल्टर में अपग्रेड करें।';

  @override
  String get upgradeRequired => 'अपग्रेड आवश्यक';

  @override
  String get upgradeToPremium => 'प्रीमियम में अपग्रेड करें';

  @override
  String get upgradeToPremiumFor6PhotosAdvancedFilter =>
      '6 फ़ोटो और उन्नत फ़िल्टर के लिए प्रीमियम में अपग्रेड करें';

  @override
  String get upgradeToPremiumToAccessGranularFiltersF =>
      'Upgrade to Premium to access granular filters';

  @override
  String get upgradeToUnlockAllFeatures =>
      'सभी सुविधाओं को अनलॉक करने के लिए अपग्रेड करें';

  @override
  String get uploadCommunityCertificateLetter =>
      'सामुदायिक प्रमाणपत्र/पत्र अपलोड करें';

  @override
  String get uploadYourPhotos => 'अपनी बेहतरीन फ़ोटो अपलोड करें';

  @override
  String get uploadedSuccessfully => 'सफलतापूर्वक अपलोड किया गया';

  @override
  String get upperMiddleClass => 'उच्च मध्यम वर्ग';

  @override
  String get useCameraToCapture => 'कैप्चर करने के लिए कैमरे का उपयोग करें';

  @override
  String get useCurrentLocation => 'वर्तमान स्थान का उपयोग करें';

  @override
  String get useEmailPassword => 'ईमेल / पासवर्ड का उपयोग करें';

  @override
  String get useNaturalLightingTip =>
      'सर्वोत्तम परिणामों के लिए प्राकृतिक रोशनी का उपयोग करें';

  @override
  String get userBlockedSuccessfully =>
      'उपयोगकर्ता को सफलतापूर्वक ब्लॉक कर दिया गया';

  @override
  String get userIdNotFound => 'उपयोगकर्ता आईडी नहीं मिली';

  @override
  String get userIdNotFoundToast => 'User ID not found';

  @override
  String get userLabel => 'उपयोगकर्ता';

  @override
  String get userNotUploadedPhoto => 'उपयोगकर्ता ने फ़ोटो अपलोड नहीं किया';

  @override
  String get users => 'Users';

  @override
  String get usingGps => 'जीपीएस का उपयोग करना';

  @override
  String get verificationBadge => 'सत्यापन बैज';

  @override
  String get verificationCodeSent => 'सत्यापन कोड भेजा गया!';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get verificationLinkcodeSent => 'सत्यापन लिंक/कोड भेजा गया!';

  @override
  String get verificationRequests => 'Verification Requests';

  @override
  String get verifications => 'Verifications';

  @override
  String get verified => 'सत्यापित';

  @override
  String get verified10PointsAddedToTrustScore =>
      'सत्यापित! ट्रस्ट स्कोर में +10 अंक जोड़े गए';

  @override
  String get verifiedCommunityMember => 'सत्यापित समुदाय सदस्य';

  @override
  String get verifiedProfile => 'सत्यापित प्रोफाइल';

  @override
  String get verifiedProfileBadge => 'सत्यापित प्रोफाइल';

  @override
  String get verifiedProfilesGet5xMoreResponses =>
      'सत्यापित प्रोफाइल को 5 गुना अधिक प्रतिक्रियाएं मिलती हैं और वे खोज परिणामों में ऊपर दिखाई देते हैं।';

  @override
  String get verifiedTrusted => 'सत्यापित एवं विश्वसनीय';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get verifyEmailAddressHeading => 'Verify Email Address';

  @override
  String verifyLabel(String label) {
    return 'सत्यापित करें $label';
  }

  @override
  String get verifyMobile => 'मोबाइल सत्यापित करें';

  @override
  String get verifyNow => 'अभी सत्यापित करें';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get verifyYourCommunityStatus => 'अपनी सामुदायिक स्थिति सत्यापित करें';

  @override
  String get verifyYourEmailAddressToAddTrustAndReach =>
      'विश्वास बढ़ाने और अधिक प्रोफ़ाइलों तक पहुँचने के लिए अपना ईमेल पता सत्यापित करें।';

  @override
  String get verifyYourMobileNumberToAddTrustAndReach =>
      'विश्वास बढ़ाने और अधिक प्रोफ़ाइल तक पहुंचने के लिए अपना मोबाइल नंबर सत्यापित करें।';

  @override
  String get veryFair => 'बहुत गोरा';

  @override
  String get videoBioIntro => 'वीडियो बायो / परिचय';

  @override
  String get videoIntro => 'वीडियो परिचय';

  @override
  String get videoIntroUploaded => 'वीडियो परिचय अपलोड किया गया';

  @override
  String get videoRecorded => 'वीडियो रिकॉर्ड किया गया!';

  @override
  String get view => 'देखें';

  @override
  String get viewAll => 'सभी को देखें';

  @override
  String get viewBiodata => 'बायोडाटा देखें';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get viewLabel => 'देखें';

  @override
  String get viewProfile => 'प्रोफ़ाइल देखें';

  @override
  String get viewYourBookmarkedProfiles =>
      'अपने बुकमार्क किए गए प्रोफाइल देखें';

  @override
  String get viewsLabel => 'दृश्य';

  @override
  String get village => 'गाँव';

  @override
  String get visibleToAllProfiles => 'सभी प्रोफ़ाइलों के लिए दृश्यमान';

  @override
  String get visibleToCloseMatchesOnly => 'केवल मैच बंद करने के लिए दृश्यमान';

  @override
  String get weEncounteredAnUnexpectedErrorWhileProce =>
      'आपके अनुरोध को संसाधित करते समय हमें एक अप्रत्याशित त्रुटि का सामना करना पड़ा।';

  @override
  String get weWillSendAVerificationRequestToTheirMob =>
      'हम उनके मोबाइल नंबर पर एक सत्यापन अनुरोध भेजेंगे। एक बार जब वे स्वीकृत हो जाते हैं, तो आपको +10 अंक मिलते हैं।';

  @override
  String get weWillVerifyYourCommunityDetailsShortly1 =>
      'हम शीघ्र ही आपके समुदाय विवरण का सत्यापन करेंगे। +15 अंक लंबित।';

  @override
  String get welcomeToBanjaraBio => 'बंजारा बायो में आपका स्वागत है';

  @override
  String get whatDoYouLookFor => 'आप जीवनसाथी में क्या चाहते हैं?';

  @override
  String get whatsApp => 'व्हाट्सएप';

  @override
  String get whatsAppContact => 'व्हाट्सएप संपर्क';

  @override
  String whatsappShareSubtitle(String name) {
    return '$name का विवरण परिवार या दोस्तों के साथ साझा करें';
  }

  @override
  String get whatsappSupport => 'व्हाट्सएप सपोर्ट';

  @override
  String get wheatish => 'गेहुआं';

  @override
  String get whereDoYouWork => 'आप कहाँ काम करते हैं?';

  @override
  String get whoViewedMe => 'मुझे किसने देखा';

  @override
  String get whyBanjaraBio => 'बंजारा बायो क्यों?';

  @override
  String get widowed => 'विधवा/विधुर';

  @override
  String get writeAboutYourself => 'अपने बारे में कुछ लिखें...';

  @override
  String get year => 'वर्ष';

  @override
  String yearsOld(String age) {
    return '$age वर्ष';
  }

  @override
  String get upgradeToShareMore => 'अधिक साझा करने के लिए अपग्रेड करें';

  @override
  String get yes => 'हाँ';

  @override
  String get yesterday => 'कल';

  @override
  String get youNeedAProfileToShareIt =>
      'साझा करने के लिए आपको एक प्रोफ़ाइल की आवश्यकता है।';

  @override
  String get youWillNoLongerSeeThisProfile =>
      'अब आपको यह प्रोफ़ाइल दिखाई नहीं देगी';

  @override
  String get youngerBrother => 'छोटे भाई';

  @override
  String get youngerSister => 'छोटी बहन';

  @override
  String get your => 'आपका';

  @override
  String get yourDailyMatches => 'आपके दैनिक मिलान';

  @override
  String get yourDocumentsAreEncrypted =>
      'आपके दस्तावेज़ एन्क्रिप्टेड हैं और अन्य उपयोगकर्ताओं को कभी नहीं दिखाए जाते हैं। केवल बैज दिखाई देता है।';

  @override
  String get yourDocumentsHaveBeenSubmittedSecurelyWe =>
      'आपके दस्तावेज़ सुरक्षित रूप से जमा कर दिए गए हैं. सत्यापित होने पर हम आपको सूचित करेंगे.';

  @override
  String get yourIntroVideoIsUnderReview10PointsPendi =>
      'आपका परिचय वीडियो समीक्षाधीन है. +10 अंक अनुमोदन हेतु लंबित।';

  @override
  String get yourMatchesWillAppearHereOnceYouBothExpr =>
      'जब आप दोनों रुचि व्यक्त करेंगे तो आपके मैच यहां दिखाई देंगे। अपना आदर्श साथी ढूंढने के लिए प्रोफ़ाइल साझा करते रहें!';

  @override
  String get yourPersonalInviteLink => 'आपका व्यक्तिगत आमंत्रण लिंक';

  @override
  String get yourReferralCode => 'आपका रेफरल कोड';

  @override
  String get yourSelfieHasBeenSubmittedOurTeamWillVer =>
      'आपकी सेल्फी सबमिट कर दी गई है. हमारी टीम इसे आपकी प्रोफ़ाइल फ़ोटो से सत्यापित करेगी।';

  @override
  String get yourTrustScore => 'आपका विश्वास स्कोर';

  @override
  String yrs(Object count) {
    return '$count वर्ष';
  }

  @override
  String get itSAMatch => 'जोड़ी मिल गई!';

  @override
  String sharedProfilesWithEachOther(String name) {
    return 'आपने और $name ने एक-दूसरे के साथ प्रोफाइल साझा किए हैं।';
  }

  @override
  String get mutualMatch => 'आपसी मिलान';

  @override
  String toContact(Object name) {
    return 'को: $name';
  }

  @override
  String fromContact(Object name) {
    return 'से: $name';
  }

  @override
  String countProfileViews(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रोफ़ाइल दृश्य',
      one: '1 प्रोफ़ाइल दृश्य',
    );
    return '$_temp0';
  }

  @override
  String get matchedBadge => 'मिलान हुआ';

  @override
  String get premiumBadge => 'प्रीमियम';

  @override
  String get contactLabel => 'संपर्क';

  @override
  String profileSharedVia(Object profileName, Object title) {
    return '$title के माध्यम से $profileName साझा किया गया';
  }

  @override
  String failedToSendMessage(String error) {
    return 'संदेश भेजने में विफल: $error';
  }

  @override
  String uploadFailed(String error) {
    return 'अपलोड विफल: $error';
  }

  @override
  String updateFailed(String error) {
    return 'अपडेट विफल: $error';
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
  String get villageTanda => 'गांव / तांडा';

  @override
  String get ageLabel => 'आयु';

  @override
  String get heightLabel => 'ऊँचाई';

  @override
  String get surnameLabel => 'उपनाम';

  @override
  String get dateOfBirthLabel => 'जन्म तिथि';

  @override
  String get birthTimeLabel => 'जन्म का समय';

  @override
  String get birthPlaceLabel => 'जन्म स्थान';

  @override
  String get bloodGroupLabel => 'रक्त समूह';

  @override
  String get occupationLabel => 'व्यवसाय';

  @override
  String get annualIncomeLabel => 'वार्षिक आय';

  @override
  String get currentResidence => 'वर्तमान निवास';

  @override
  String get contactPersonLabel => 'संपर्क व्यक्ति';

  @override
  String get bestTimeToContact => 'संपर्क करने का सबसे अच्छा समय';

  @override
  String get limitReached => 'सीमा समाप्त';

  @override
  String get relationLabel => 'संबंध';

  @override
  String get none => 'कोई नहीं';

  @override
  String yearsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'वर्ष',
      one: 'वर्ष',
    );
    return '$_temp0';
  }

  @override
  String brothersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भाई',
      one: '1 भाई',
    );
    return '$_temp0';
  }

  @override
  String sistersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बहनें',
      one: '1 बहन',
    );
    return '$_temp0';
  }

  @override
  String get siblingsLabel => 'भाई-बहन';

  @override
  String siblingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भाई-बहन',
      one: '1 भाई-बहन',
    );
    return '$_temp0';
  }

  @override
  String get company => 'कंपनी';

  @override
  String get job => 'कार्य / नौकरी';

  @override
  String get biodataRequired => 'बायोडाटा आवश्यक है';

  @override
  String get guestRestrictionMessage =>
      'प्रोफ़ाइल के साथ बातचीत करने, रुचि व्यक्त करने या संदेश भेजने के लिए, आपको पहले अपना स्वयं का बायोडाटा बनाना होगा।';

  @override
  String get createNow => 'अभी बनाएं';

  @override
  String get tourLocationTitle => 'स्थान चुनें';

  @override
  String get tourLocationDesc =>
      'अपने आस-पास के मिलान खोजने के लिए राज्य, जिला या तालुका द्वारा प्रोफ़ाइल फ़िल्टर करें।';

  @override
  String get tourSearchTitle => 'प्रोफ़ाइल खोजें';

  @override
  String get tourSearchDesc =>
      'किसी विशिष्ट व्यक्ति की तलाश है? उनका नाम या शिक्षा यहाँ टाइप करें।';

  @override
  String get tourFilterTitle => 'उन्नत फ़िल्टर';

  @override
  String get tourFilterDesc =>
      'केवल वही देखने के लिए आयु, शिक्षा या पेशे के आधार पर सीमित करें जो आप चाहते हैं।';

  @override
  String get tourChatTitle => 'संदेश और चैट';

  @override
  String get tourChatDesc => 'अपनी बातचीत और आने वाली रुचियां यहां देखें।';

  @override
  String get tourBottomHome => 'होम फ़ीड';

  @override
  String get tourBottomHomeDesc =>
      'हजारों सत्यापित प्रोफ़ाइलों को स्क्रॉल करें।';

  @override
  String get tourBottomShared => 'साझा प्रोफ़ाइल';

  @override
  String get tourBottomSharedDesc =>
      'WhatsApp/लिंक के माध्यम से साझा की गई या प्राप्त प्रोफ़ाइल देखें।';

  @override
  String get tourBottomProfile => 'आपकी प्रोफ़ाइल';

  @override
  String get tourBottomProfileDesc =>
      'अपना स्वयं का बायोडाटा और फ़ोटो यहाँ प्रबंधित करें।';

  @override
  String get tourBottomSettings => 'ऐप सेटिंग्स';

  @override
  String get tourBottomSettingsDesc =>
      'भाषा, अधिसूचना सेटिंग्स बदलें या सहायता से संपर्क करें।';

  @override
  String get tourWhatsappTitle => 'WhatsApp सहायता';

  @override
  String get tourWhatsappDesc =>
      'मदद या प्रोफ़ाइल परिवर्तन के लिए हमारे एडमिन से सीधा संपर्क।';

  @override
  String get tourInstagramTitle => 'हमें फॉलो करें';

  @override
  String get tourInstagramDesc =>
      'Instagram पर रोज़ाना नई प्रोफ़ाइल और सफलता की कहानियाँ देखें।';

  @override
  String get tourBookmarkTitle => 'बाद के लिए सहेजें';

  @override
  String get tourBookmarkDesc =>
      'पसंद आने वाली प्रोफ़ाइल को बाद में अपनी सहेजी गई सूची में देखने के लिए बुकमार्क करें।';

  @override
  String get tourInterestTitle => 'रुचि व्यक्त करें';

  @override
  String get tourInterestDesc =>
      'उन्हें यह बताने के लिए दिल भेजें कि आप उनके बायोडाटा में रुचि रखते हैं।';

  @override
  String get tourShareTitle => 'परिवार के साथ साझा करें';

  @override
  String get tourShareDesc =>
      'उनकी राय के लिए WhatsApp के माध्यम से माता-पिता या रिश्तेदारों के साथ आसानी से प्रोफ़ाइल साझा करें।';

  @override
  String get chooseHowToStart => 'चुनें कि आप कैसे शुरू करना चाहते हैं';

  @override
  String get exploreAsGuest => 'अतिथि के रूप में अन्वेषण करें';

  @override
  String get exitGuestMode => 'गेस्ट मोड से बाहर निकलें';

  @override
  String get guestModeDesc =>
      'अपनी प्रोफ़ाइल बनाने से पहले ऐप का निर्देशित दौरा करें।';

  @override
  String get createMyBiodata => 'मेरा बायोडेटा बनाएं';

  @override
  String get createBiodataDesc =>
      'अपनी प्रोफ़ाइल भरें और तुरंत जुड़ना शुरू करें।';

  @override
  String get needHelpContactAdmin => 'मदद चाहिए? व्यवस्थापक से संपर्क करें';

  @override
  String get noMatchesYet => 'अभी तक कोई मैच नहीं';

  @override
  String get noProfilesSharedYet => 'अभी तक कोई प्रोफ़ाइल साझा नहीं किया गया';

  @override
  String get noProfilesReceived => 'कोई प्रोफ़ाइल प्राप्त नहीं हुआ';

  @override
  String get mutualMatchesDesc =>
      'जब दोनों उपयोगकर्ता एक-दूसरे में रुचि दिखाएंगे तो परस्पर मैच यहां दिखाई देंगे';

  @override
  String get startSharingProfilesDesc =>
      'सही जीवनसाथी खोजने में मदद करने के लिए परिवार और दोस्तों के साथ प्रोफ़ाइल साझा करना शुरू करें';

  @override
  String get profilesSharedWithYouDesc =>
      'आपके परिवार और दोस्तों द्वारा आपके साथ साझा किए गए प्रोफ़ाइल यहां दिखाई देंगे';

  @override
  String get enterVillageManually => 'गांव/अन्य नाम दर्ज करें';

  @override
  String get enterVillageHint => 'गांव या तांडा का नाम दर्ज करें...';

  @override
  String get specificLocation => 'विशिष्ट स्थान';

  @override
  String get skipAndSelectLevel => 'छोड़ें और तालुका/जिला चुनें';

  @override
  String get optional => 'वैकल्पिक';

  @override
  String get tourMatchesSearchTitle => 'साझा प्रोफ़ाइल खोजें';

  @override
  String get tourMatchesSearchDesc =>
      'नाम या शिक्षा का उपयोग करके आपके साथ या आपके द्वारा साझा की गई प्रोफ़ाइल शीघ्रता से खोजें।';

  @override
  String get tourMatchesSentTitle => 'भेजी गई प्रोफ़ाइल';

  @override
  String get tourMatchesSentDesc =>
      'आपके द्वारा परिवार और दोस्तों के साथ साझा की गई सभी प्रोफ़ाइल यहां दिखाई देती हैं।';

  @override
  String get tourMatchesReceivedTitle => 'प्राप्त प्रोफ़ाइल';

  @override
  String get tourMatchesReceivedDesc =>
      'दूसरों द्वारा व्हाट्सएप या लिंक के माध्यम से आपके साथ साझा की गई प्रोफ़ाइल।';

  @override
  String get tourMatchesMatchedTitle => 'मैच हुई प्रोफ़ाइल';

  @override
  String get tourMatchesMatchedDesc =>
      'आपसी मैच जहां आप और दूसरे व्यक्ति दोनों ने रुचि व्यक्त की!';

  @override
  String get tourProfilePhotosTitle => 'फोटो प्रबंधित करें';

  @override
  String get tourProfilePhotosDesc =>
      'अपनी प्रोफ़ाइल फोटो अपलोड करें, क्रम बदलें या हटाएँ ताकि एक शानदार पहली छाप पड़े।';

  @override
  String get tourProfileTrustTitle => 'ट्रस्ट स्कोर';

  @override
  String get tourProfileTrustDesc =>
      'आपकी विश्वसनीयता स्कोर। अपना आईडी, सेल्फी और समुदाय सत्यापित करके इसे बढ़ाएं।';

  @override
  String get tourProfilePdfTitle => 'बायोडेटा PDF एक्सपोर्ट करें';

  @override
  String get tourProfilePdfDesc =>
      'अपने बायोडेटा का एक प्रोफेशनल PDF बनाएं और परिवार के सदस्यों के साथ साझा करें।';

  @override
  String get tourProfileSavedTitle => 'सहेजी गई प्रोफ़ाइल';

  @override
  String get tourProfileSavedDesc =>
      'बाद में समीक्षा के लिए आपके द्वारा बुकमार्क की गई सभी प्रोफ़ाइल देखें।';

  @override
  String get tourProfileEditTitle => 'प्रोफ़ाइल संपादित करें';

  @override
  String get tourProfileEditDesc =>
      'अपनी व्यक्तिगत जानकारी, फोटो और प्राथमिकताएं कभी भी अपडेट करें।';

  @override
  String get basicPlanName => 'बेसिक';

  @override
  String get premiumPlanName => 'प्रीमियम';

  @override
  String get vipPlanName => 'वीआईपी';

  @override
  String get basicPlanDesc => 'आपकी खोज के लिए आवश्यक सुविधाएँ';

  @override
  String get premiumPlanDesc => 'उन्नत सुविधाएँ और बेहतर दृश्यता';

  @override
  String get vipPlanDesc => 'प्राथमिकता सहायता के साथ बेहतरीन अनुभव';

  @override
  String get paymentSuccessfulPdfUnlocked => 'भुगतान सफल! पीडीएफ अनलॉक.';

  @override
  String get standardPlanName => 'स्टैंडर्ड';

  @override
  String get standardPlanDesc =>
      'एक महीने के लिए प्रीमियम सुविधाओं का प्रयास करें';

  @override
  String get eternalPlanName => 'इटर्नल - शादी तक';

  @override
  String get eternalPlanDesc => 'समाप्ति के बारे में फिर कभी चिंता न करें';

  @override
  String get elitePlanName => 'एलीट';

  @override
  String get elitePlanDesc => 'वीआईपी एक्सेस के साथ चुनिंदा मैच';

  @override
  String get royalPlanName => 'रॉयल';

  @override
  String get royalPlanDesc => 'समर्पित प्रबंधक आपका मैच ढूँढता है';

  @override
  String get eternalElitePlanName => 'इटर्नल एलीट';

  @override
  String get eternalElitePlanDesc =>
      'अपने करियर पर ध्यान दें, हम आपका साथी ढूंढेंगे';

  @override
  String get selfServicePlans => 'स्वयं सेवा';

  @override
  String get vipMatchmaker => 'वीआईपी मैचमेकर';

  @override
  String get tillUMarry => 'शादी तक';

  @override
  String get lifetime => 'आजीवन';

  @override
  String mrpPrice(Object price) {
    return 'MRP ₹$price';
  }

  @override
  String bulkDiscount(Object percent) {
    return '$percent% की छूट';
  }

  @override
  String youSave(Object amount) {
    return 'आप बचाते हैं ₹$amount';
  }

  @override
  String totalSavings(Object amount) {
    return 'कुल बचत: ₹$amount';
  }

  @override
  String get trustDiscountApplied => 'ट्रस्ट स्कोर छूट लागू';

  @override
  String get couponDiscountApplied => 'कूपन छूट लागू';

  @override
  String contactUnlocks(Object count) {
    return '$count संपर्क अनलॉक/माह';
  }

  @override
  String handpickedMatches(Object count) {
    return '$count चुनिंदा मैच/सप्ताह';
  }

  @override
  String get dedicatedManager => 'समर्पित संबंध प्रबंधक';

  @override
  String get profileMakeover => 'प्रोफेशनल प्रोफ़ाइल मेकओवर';

  @override
  String get featuredBadge => 'एलीट सत्यापित बैज';

  @override
  String get featuresIncluded => 'शामिल सुविधाएं:';

  @override
  String get incognitoMode => 'निजी प्रोफ़ाइल ब्राउज़िंग';

  @override
  String get biodataPremiumIncluded => 'बायोडेटा प्रीमियम शामिल है';

  @override
  String get unlimitedContactUnlocks => 'अनलिमिटेड संपर्क अनलॉक';

  @override
  String get unlimitedHandpickedMatches => 'दैनिक ऑन-डिमांड मैच';

  @override
  String get weeklyCheckIn => 'साप्ताहिक चेक-इन';

  @override
  String get monthlyCheckIn => 'मासिक चेक-इन';

  @override
  String get bestValue => 'सर्वोत्तम मूल्य';

  @override
  String get personalConcierge => 'व्यक्तिगत कंसीयज';

  @override
  String get vipFeatures => 'वीआईपी सुविधाएँ';

  @override
  String get directContactAccess => 'सीधा संपर्क एक्सेस';

  @override
  String get focusOnCareer =>
      'अपने करियर पर ध्यान दें, जबकि हम आपका जीवनसाथी ढूंढते हैं';

  @override
  String get perMonth => '/माह';

  @override
  String get forLifetime => 'आजीवन के लिए';

  @override
  String get emailNotifications => 'ईमेल सूचनाएं';

  @override
  String get dailyMatchPicks => 'दैनिक मैच पिक्स';

  @override
  String get newMatchAlerts => 'नया मैच अलर्ट';

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
  String get signInRequired => 'साइन इन आवश्यक है';

  @override
  String get signInRequiredContent =>
      'कृपया इस सुविधा का उपयोग करने के लिए साइन इन करें या एक खाता बनाएं।';

  @override
  String get watchAdToUnlock => 'अनलॉक करने के लिए विज्ञापन देखें';

  @override
  String get watchAdToUnlockAll => 'सभी को अनलॉक करने के लिए विज्ञापन देखें';

  @override
  String get goProAdFree => 'विज्ञापन-मुक्त अनुभव के लिए प्रो बनें';

  @override
  String get adNotReady =>
      'विज्ञापन अभी तैयार नहीं है। कृपया थोड़ी देर में पुनः प्रयास करें।';

  @override
  String get upgradeToUnlockPremiumFeatures =>
      'सभी विज्ञापनों को हटाने और प्रीमियम बायोडाटा सुविधाओं को अनलॉक करने के लिए अपग्रेड करें।';

  @override
  String get couldNotLaunchWhatsApp => 'व्हाट्सएप लॉन्च नहीं किया जा सका';

  @override
  String get couldNotLaunchDialer => 'फोन डायलर लॉन्च नहीं किया जा सका';

  @override
  String get searchLeads => 'लीड्स खोजें...';

  @override
  String get workspace => 'कार्यक्षेत्र';

  @override
  String get customMessage => 'कस्टम संदेश';

  @override
  String get logCallOutcome => 'कॉल का परिणाम रिकॉर्ड करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get registrationFee => 'पंजीकरण शुल्क';

  @override
  String get unverified => 'असत्यापित';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String unlockMoreVisitors(int count) {
    return 'अनलॉक करें $count और विज़िटर्स!';
  }

  @override
  String get dailyLimitReached => 'दैनिक सीमा समाप्त';

  @override
  String get dailyLimitViewsReached =>
      'आपने अपनी सभी दैनिक प्रोफाइल विज़िट्स का उपयोग कर लिया है।';

  @override
  String get unlockMoreViewsAd =>
      'आज के लिए 5 और विज़िट्स अनलॉक करने के लिए एक त्वरित विज्ञापन देखें!';

  @override
  String get directMessage => 'सीधा संदेश';

  @override
  String get directMessagingPremium =>
      'सीधा संदेश भेजना एक प्रीमियम सुविधा है।';

  @override
  String get unlockDirectMessageAd =>
      'मुफ्त में 1 सीधा संदेश अनलॉक करने के लिए 3 विज्ञापन देखें!';

  @override
  String get premiumAccess => 'प्रीमियम एक्सेस';

  @override
  String get premiumGateSupport =>
      'त्वरित विज्ञापन देखकर हमारे समुदाय का समर्थन करें,\nया विज्ञापन-मुक्त अनुभव के लिए प्रो में अपग्रेड करें।';

  @override
  String get unblockAllProFeatures => 'सभी प्रो सुविधाओं को अनलॉक करें';

  @override
  String get monthly => 'मासिक';

  @override
  String get annual => 'वार्षिक';

  @override
  String get watchQuickAd => 'त्वरित विज्ञापन देखें';

  @override
  String get continueBlockedUntilAdEnds =>
      'विज्ञापन समाप्त होने तक ऐप जारी रखना अवरुद्ध है';

  @override
  String get adCompletedSuccessfully => 'विज्ञापन सफलतापूर्वक पूरा हुआ';

  @override
  String get continueToApp => 'ऐप पर जारी रखें';

  @override
  String get preparingAdExperience => 'विज्ञापन अनुभव तैयार किया जा रहा है...';

  @override
  String get adTemporarilyUnavailable => 'विज्ञापन अस्थायी रूप से अनुपलब्ध है';

  @override
  String get callAdmin => 'एडमिन को कॉल करें';

  @override
  String get banjaraBioPro => 'बंजाराबायो प्रो';

  @override
  String get claimMarriageGift => 'विवाह उपहार का दावा करें';

  @override
  String get tellUsYourStory => 'हमें अपनी कहानी बताएं';

  @override
  String get partnerName => 'साथी का नाम';

  @override
  String get yourSuccessStory => 'आपकी सफलता की कहानी';

  @override
  String get howDidYouMeet => 'आप कैसे मिले? आपको उनके बारे में क्या पसंद है?';

  @override
  String get proofOfMarriage => 'विवाह का प्रमाण';

  @override
  String get instagramLink => 'इंस्टाग्राम रील/स्टोरी लिंक';

  @override
  String get pasteUrlHere => 'यहां यूआरएल पेस्ट करें';

  @override
  String get weddingDate => 'विवाह की तिथि';

  @override
  String get estimatedRefund => 'अनुमानित रिफंड';

  @override
  String get submitForReview => 'समीक्षा के लिए सबमिट करें';

  @override
  String get selectRewardType => 'उपहार का प्रकार चुनें';

  @override
  String get digital => 'डिजिटल';

  @override
  String get refund25 => '25% रिफंड';

  @override
  String get teamVisit => 'टीम विजिट';

  @override
  String get refund35 => '35% रिफंड';

  @override
  String get successSubmission =>
      'सफलता! आपका अनुरोध समीक्षा के लिए सबमिट कर दिया गया है।';
}
