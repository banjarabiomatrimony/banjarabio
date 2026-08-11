/// Storage bucket configuration – single source of truth.
///
/// Must match SQL: 11_storage.sql policies reference these bucket IDs.
/// Create buckets in Supabase Dashboard: profile-photos (Public), verification-docs (Private).
abstract class StorageConfig {
  StorageConfig._();

  /// Profile photos – public read, authenticated upload to own folder.
  static const String profilePhotos = 'profile-photos';

  /// Verification docs (ID proofs, selfies, video) – private, own folder only.
  static const String verificationDocs = 'verification-docs';

  /// Whether to use Supabase Storage Image Transformations (requires paid plan).
  /// Default is false to prevent 403 FeatureNotEnabled errors on free tier.
  static bool enableImageTransformations = false;
}
