/// Admin configuration – single source of truth for admin access.
///
/// Must match SQL: fn_is_admin checks auth.users.email for this value.
/// To change admin email: update here and run:
/// `UPDATE public.profiles SET is_admin = true WHERE email = 'your@email.com';`
abstract class AdminConfig {
  AdminConfig._();

  /// Email that grants admin access (bypasses profile requirement).
  static const String adminEmail = 'admin@banjarabio.com';

  /// Check if the given email is the admin email (case-insensitive).
  static bool isAdminEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return email.trim().toLowerCase() == adminEmail.toLowerCase();
  }
}
