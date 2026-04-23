/// Share/matching configuration – single source of truth.
///
/// Must match SQL: 06_shares.sql, 14_automated_match_trigger.sql.
/// Auto-match trigger (fn_auto_match_shares) runs on INSERT/UPDATE of profile_shares status.
abstract class ShareConfig {
  ShareConfig._();

  /// Allowed profile_shares.status values (14/06 CHECK constraint).
  static const List<String> statusValues = [
    'pending',
    'viewed',
    'interested',
    'rejected',
    'new',
    'matched',
  ];

  /// Sharing methods (06_shares CHECK constraint).
  static const List<String> sharingMethods = ['whatsapp', 'in_app', 'link'];

  /// Status that triggers match UI and chat creation (15_chat_and_notifications).
  static const String matchedStatus = 'matched';

  static bool isValidStatus(String status) =>
      statusValues.contains(status.toLowerCase());
  static bool isValidSharingMethod(String method) =>
      sharingMethods.contains(method.toLowerCase());
}
