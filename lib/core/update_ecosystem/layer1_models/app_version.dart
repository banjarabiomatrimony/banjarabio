import 'package:flutter/foundation.dart';

/// 🏷️ [AppVersion]
///
/// Semantic Versioning parser and comparator for Flutter applications.
/// Supports standard formats such as:
/// - `1.3.3+41` (Major.Minor.Patch+Build)
/// - `1.3.3` (Major.Minor.Patch)
/// - `1.2` (Major.Minor)
/// - `2` (Major)
@immutable
class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;
  final int buildNumber;
  final String rawVersion;

  const AppVersion({
    required this.major,
    this.minor = 0,
    this.patch = 0,
    this.buildNumber = 0,
    required this.rawVersion,
  });

  /// Factory parser for version strings.
  /// Handles malformed strings gracefully without throwing.
  factory AppVersion.parse(String versionString) {
    final clean = versionString.trim();
    if (clean.isEmpty) {
      return const AppVersion(major: 0, rawVersion: '0.0.0');
    }

    try {
      int build = 0;
      String versionPart = clean;

      // Extract build number if present (e.g., "1.3.3+41")
      if (clean.contains('+')) {
        final splitPlus = clean.split('+');
        versionPart = splitPlus[0];
        if (splitPlus.length > 1) {
          build = int.tryParse(splitPlus[1]) ?? 0;
        }
      }

      // Parse major.minor.patch
      final segments = versionPart.split('.');
      final major = segments.isNotEmpty ? (int.tryParse(segments[0]) ?? 0) : 0;
      final minor = segments.length > 1 ? (int.tryParse(segments[1]) ?? 0) : 0;
      final patch = segments.length > 2 ? (int.tryParse(segments[2]) ?? 0) : 0;

      return AppVersion(
        major: major,
        minor: minor,
        patch: patch,
        buildNumber: build,
        rawVersion: clean,
      );
    } catch (_) {
      return AppVersion(major: 0, rawVersion: clean);
    }
  }

  /// Convenience fallback for unknown or empty version
  static const AppVersion zero = AppVersion(major: 0, rawVersion: '0.0.0');

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) {
      return major.compareTo(other.major);
    }
    if (minor != other.minor) {
      return minor.compareTo(other.minor);
    }
    if (patch != other.patch) {
      return patch.compareTo(other.patch);
    }
    // If semantic versions match, compare build numbers if either has a build number
    if (buildNumber != other.buildNumber && (buildNumber > 0 || other.buildNumber > 0)) {
      return buildNumber.compareTo(other.buildNumber);
    }
    return 0;
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;
  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppVersion &&
        other.major == major &&
        other.minor == minor &&
        other.patch == patch &&
        other.buildNumber == buildNumber;
  }

  @override
  int get hashCode => Object.hash(major, minor, patch, buildNumber);

  /// Pure semantic version without build number (e.g., "1.3.3")
  String get semVer => '$major.$minor.$patch';

  @override
  String toString() {
    if (buildNumber > 0) {
      return '$major.$minor.$patch+$buildNumber';
    }
    return '$major.$minor.$patch';
  }
}
