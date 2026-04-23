import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';

class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  @visibleForTesting
  Box<dynamic> Function(String)? testBoxOpener;

  Box<dynamic> _getBox(String name) {
    if (testBoxOpener != null) return testBoxOpener!(name);
    return Hive.box(name);
  }

  static const String boxAppMetadata = 'app_metadata';
  static const String boxOwnProfile = 'own_profile';
  static const String boxBookmarks = 'bookmarks';
  static const String boxHomeFeed = 'home_feed';
  static const String boxSearchHistory = 'search_history';

  Future<void> init() async {
    await Hive.openBox(boxAppMetadata);
    await Hive.openBox(boxOwnProfile);
    await Hive.openBox(boxBookmarks);
    await Hive.openBox(boxHomeFeed);
    await Hive.openBox(boxSearchHistory);
  }

  /// -------- App Metadata (Referrals, etc.) --------

  Future<void> savePendingReferralId(String referralId) async {
    final box = _getBox(boxAppMetadata);
    await box.put('pending_referral_id', referralId);
  }

  String? getPendingReferralId() {
    final box = _getBox(boxAppMetadata);
    return box.get('pending_referral_id') as String?;
  }

  Future<void> clearPendingReferralId() async {
    final box = _getBox(boxAppMetadata);
    await box.delete('pending_referral_id');
  }

  Future<void> savePendingProfileId(String profileId) async {
    final box = _getBox(boxAppMetadata);
    await box.put('pending_profile_id', profileId);
  }

  String? getPendingProfileId() {
    final box = _getBox(boxAppMetadata);
    return box.get('pending_profile_id') as String?;
  }

  Future<void> clearPendingProfileId() async {
    final box = _getBox(boxAppMetadata);
    await box.delete('pending_profile_id');
  }

  Future<void> savePendingPromoCode(String promoCode) async {
    final box = _getBox(boxAppMetadata);
    await box.put('pending_promo_code', promoCode);
  }

  String? getPendingPromoCode() {
    final box = _getBox(boxAppMetadata);
    return box.get('pending_promo_code') as String?;
  }

  Future<void> clearPendingPromoCode() async {
    final box = _getBox(boxAppMetadata);
    await box.delete('pending_promo_code');
  }

  Future<void> savePendingRewardsFlag(bool flag) async {
    final box = _getBox(boxAppMetadata);
    await box.put('pending_rewards_flag', flag);
  }

  bool getPendingRewardsFlag() {
    final box = _getBox(boxAppMetadata);
    return box.get('pending_rewards_flag', defaultValue: false) as bool;
  }

  Future<void> clearPendingRewardsFlag() async {
    final box = _getBox(boxAppMetadata);
    await box.delete('pending_rewards_flag');
  }

  Future<void> saveLastInstagramPromptDate(DateTime date) async {
    final box = _getBox(boxAppMetadata);
    await box.put('last_instagram_prompt_date', date.toIso8601String());
  }

  DateTime? getLastInstagramPromptDate() {
    final box = _getBox(boxAppMetadata);
    final dateStr = box.get('last_instagram_prompt_date') as String?;
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// -------- Own Profile --------

  Future<void> saveOwnProfile(Map<String, dynamic> profileJson) async {
    final box = _getBox(boxOwnProfile);
    await box.put('profile', profileJson);
  }

  Map<String, dynamic>? getOwnProfile() {
    final box = _getBox(boxOwnProfile);
    final data = box.get('profile');
    if (data == null) return null;
    return _toMapStringDynamic(data as Map);
  }

  /// Recursively converts Map/List from Hive (dynamic keys/values) to Map&lt;String,dynamic&gt;.
  static dynamic _toMapStringDynamic(dynamic v) {
    if (v is Map) {
      return v.map(
        (k, val) => MapEntry(k.toString(), _toMapStringDynamic(val)),
      );
    }
    if (v is List) return v.map(_toMapStringDynamic).toList();
    return v;
  }

  Future<void> clearOwnProfile() async {
    final box = _getBox(boxOwnProfile);
    await box.delete('profile');
  }

  /// -------- Bookmarks --------

  Future<void> saveBookmarks(List<Map<String, dynamic>> bookmarksJson) async {
    final box = _getBox(boxBookmarks);
    await box.put('list', bookmarksJson);
  }

  List<Map<String, dynamic>> getBookmarks() {
    final box = _getBox(boxBookmarks);
    final data = box.get('list');
    if (data == null) return [];
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// -------- Home Feed --------

  Future<void> saveHomeFeed(List<Map<String, dynamic>> feedJson) async {
    final box = _getBox(boxHomeFeed);
    await box.put('initial_page', feedJson);
  }

  List<Map<String, dynamic>> getHomeFeed() {
    final box = _getBox(boxHomeFeed);
    final data = box.get('initial_page');
    if (data == null) return [];
    return (data as List)
        .map((e) => _toMapStringDynamic(e as Map))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Future<void> clearHomeFeed() async {
    final box = _getBox(boxHomeFeed);
    await box.delete('initial_page');
  }

  /// -------- Search History --------

  Future<void> addSearchTerm(String term) async {
    if (term.trim().isEmpty) return;
    final box = _getBox(boxSearchHistory);
    final List<String> history = List<String>.from(
      box.get('history', defaultValue: []),
    );

    // Remove if already exists to move to top
    history.remove(term);
    history.insert(0, term);

    // Limit history to 10 items
    if (history.length > 10) history.removeLast();

    await box.put('history', history);
  }

  List<String> getSearchHistory() {
    final box = _getBox(boxSearchHistory);
    return List<String>.from(box.get('history', defaultValue: []));
  }

  Future<void> clearSearchHistory() async {
    final box = _getBox(boxSearchHistory);
    await box.delete('history');
  }

  /// -------- Guest Mode & Tour --------

  Future<void> setGuestMode(bool isGuest) async {
    final box = _getBox(boxAppMetadata);
    await box.put('is_guest_mode', isGuest);
  }

  bool isGuestMode() {
    final box = _getBox(boxAppMetadata);
    return box.get('is_guest_mode', defaultValue: false) as bool;
  }

  Future<void> setGuestTourCompleted(bool completed) async {
    final box = _getBox(boxAppMetadata);
    await box.put('is_guest_tour_completed', completed);
  }

  bool isGuestTourCompleted() {
    final box = _getBox(boxAppMetadata);
    return box.get('is_guest_tour_completed', defaultValue: false) as bool;
  }

  Future<void> setTourStageCompleted(String stageName, bool completed) async {
    final box = _getBox(boxAppMetadata);
    await box.put('tour_${stageName}_completed', completed);
  }

  bool isTourStageCompleted(String stageName) {
    final box = _getBox(boxAppMetadata);
    return box.get('tour_${stageName}_completed', defaultValue: false) as bool;
  }

  @visibleForTesting
  void reset() {
    testBoxOpener = null;
  }
}
