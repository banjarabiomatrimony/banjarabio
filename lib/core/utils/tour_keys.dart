import 'package:flutter/material.dart';

class TourKeys {
  static final GlobalKey locationKey = GlobalKey();
  static final GlobalKey searchKey = GlobalKey();
  static final GlobalKey filterKey = GlobalKey();
  static final GlobalKey whatsappKey = GlobalKey();
  static final GlobalKey instagramKey = GlobalKey();
  static final GlobalKey chatKey = GlobalKey();
  
  // Bottom Bar Keys
  static final GlobalKey homeTabKey = GlobalKey();
  static final GlobalKey sharedTabKey = GlobalKey();
  static final GlobalKey profileTabKey = GlobalKey();
  static final GlobalKey settingsTabKey = GlobalKey();
  
  // Profile Detail Page Keys
  static final GlobalKey interestButtonKey = GlobalKey();
  static final GlobalKey shareButtonKey = GlobalKey();
  static final GlobalKey bookmarkButtonKey = GlobalKey();
  static final GlobalKey trustScoreKey = GlobalKey();

  // ─── Matches / Share Hub Screen Keys ───
  static final GlobalKey matchesSearchKey = GlobalKey();
  static final GlobalKey matchesSentTabKey = GlobalKey();
  static final GlobalKey matchesReceivedTabKey = GlobalKey();
  static final GlobalKey matchesMatchedTabKey = GlobalKey();

  // ─── My Profile Screen Keys ───
  static final GlobalKey profileManagePhotosKey = GlobalKey();
  static final GlobalKey profileTrustScoreKey = GlobalKey();
  static final GlobalKey profileExportPdfKey = GlobalKey();
  static final GlobalKey profileSavedProfilesKey = GlobalKey();
  static final GlobalKey profileEditKey = GlobalKey();
}
