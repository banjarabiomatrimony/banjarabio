import 'package:flutter/material.dart';

class TourKeys {
  static GlobalKey locationKey = GlobalKey();
  static GlobalKey searchKey = GlobalKey();
  static GlobalKey filterKey = GlobalKey();
  static GlobalKey whatsappKey = GlobalKey();
  static GlobalKey instagramKey = GlobalKey();
  static GlobalKey chatKey = GlobalKey();
  
  // Bottom Bar Keys
  static GlobalKey homeTabKey = GlobalKey();
  static GlobalKey sharedTabKey = GlobalKey();
  static GlobalKey chatTabKey = GlobalKey();
  static GlobalKey melavaTabKey = GlobalKey();
  static GlobalKey biodataTabKey = GlobalKey();
  static GlobalKey profileTabKey = GlobalKey();
  static GlobalKey settingsTabKey = GlobalKey();
  
  // Profile Detail Page Keys
  static GlobalKey interestButtonKey = GlobalKey();
  static GlobalKey shareButtonKey = GlobalKey();
  static GlobalKey bookmarkButtonKey = GlobalKey();
  static GlobalKey trustScoreKey = GlobalKey();

  // ─── Matches / Share Hub Screen Keys ───
  static GlobalKey matchesSearchKey = GlobalKey();
  static GlobalKey matchesSentTabKey = GlobalKey();
  static GlobalKey matchesReceivedTabKey = GlobalKey();
  static GlobalKey matchesMatchedTabKey = GlobalKey();

  // ─── My Profile Screen Keys ───
  static GlobalKey profileManagePhotosKey = GlobalKey();
  static GlobalKey profileTrustScoreKey = GlobalKey();
  static GlobalKey profileExportPdfKey = GlobalKey();
  static GlobalKey profileSavedProfilesKey = GlobalKey();
  static GlobalKey profileEditKey = GlobalKey();

  /// Reset all keys with brand new instances to avoid duplicate GlobalKey collision
  static void resetAll() {
    locationKey = GlobalKey();
    searchKey = GlobalKey();
    filterKey = GlobalKey();
    whatsappKey = GlobalKey();
    instagramKey = GlobalKey();
    chatKey = GlobalKey();
    homeTabKey = GlobalKey();
    sharedTabKey = GlobalKey();
    chatTabKey = GlobalKey();
    melavaTabKey = GlobalKey();
    biodataTabKey = GlobalKey();
    profileTabKey = GlobalKey();
    settingsTabKey = GlobalKey();
    interestButtonKey = GlobalKey();
    shareButtonKey = GlobalKey();
    bookmarkButtonKey = GlobalKey();
    trustScoreKey = GlobalKey();
    matchesSearchKey = GlobalKey();
    matchesSentTabKey = GlobalKey();
    matchesReceivedTabKey = GlobalKey();
    matchesMatchedTabKey = GlobalKey();
    profileManagePhotosKey = GlobalKey();
    profileTrustScoreKey = GlobalKey();
    profileExportPdfKey = GlobalKey();
    profileSavedProfilesKey = GlobalKey();
    profileEditKey = GlobalKey();
  }
}
